/// Création / édition d'un devis — lignes pré-remplies depuis le
/// catalogue, calcul automatique des totaux (section 15).
library;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/quote_calculator.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/form_fields.dart';
import '../catalog/catalog_providers.dart';
import '../clients/clients_providers.dart';
import 'quotes_providers.dart';

class _LineDraft {
  final TextEditingController designation;
  final TextEditingController quantite;
  final TextEditingController prixUnitaire;
  String? serviceId;

  _LineDraft({String? designation, double? qte, int? pu, this.serviceId})
      : designation = TextEditingController(text: designation ?? ''),
        quantite = TextEditingController(text: Formatters.qty(qte ?? 1)),
        prixUnitaire = TextEditingController(text: pu?.toString() ?? '');

  DocumentLine toLine() => DocumentLine(
        designation: designation.text.trim().isEmpty
            ? 'Ligne'
            : designation.text.trim(),
        quantite: double.tryParse(quantite.text.replaceAll(',', '.')) ?? 1,
        prixUnitaire: Validators.parseMontant(prixUnitaire.text) ?? 0,
      );

  void dispose() {
    designation.dispose();
    quantite.dispose();
    prixUnitaire.dispose();
  }
}

class QuoteEditScreen extends ConsumerStatefulWidget {
  const QuoteEditScreen({super.key, this.quoteId, this.requestId, this.clientId});

  final String? quoteId;
  final String? requestId;
  final String? clientId;

  @override
  ConsumerState<QuoteEditScreen> createState() => _QuoteEditScreenState();
}

class _QuoteEditScreenState extends ConsumerState<QuoteEditScreen> {
  Client? _client;
  final _lines = <_LineDraft>[];
  final _reduction = TextEditingController(text: '0');
  final _acompte = TextEditingController(text: '0');
  final _delai = TextEditingController();
  final _conditions = TextEditingController();
  final _validite = TextEditingController(text: '15');
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.quoteId != null) {
      // Édition d'un devis existant.
      final quote =
          await ref.read(documentsDaoProvider).quoteById(widget.quoteId!);
      final items =
          await ref.read(documentsDaoProvider).quoteItems(widget.quoteId!);
      if (quote != null) {
        _client = await ref.read(clientsDaoProvider).byId(quote.clientId);
        _reduction.text = quote.reduction.toString();
        _acompte.text = quote.acompte.toString();
        _delai.text = quote.delaiJours?.toString() ?? '';
        _conditions.text = quote.conditions ?? '';
        _validite.text = quote.validiteJours.toString();
        _lines.clear();
        for (final i in items) {
          _lines.add(_LineDraft(
            designation: i.designation,
            qte: i.quantite,
            pu: i.prixUnitaire,
            serviceId: i.serviceId,
          ));
        }
      }
    } else if (widget.requestId != null) {
      // Pré-remplissage depuis une demande ( jamais ressaisir ).
      final row =
          await ref.read(requestsDaoProvider).byId(widget.requestId!);
      if (row != null) {
        _client = row.client;
        if (row.request.serviceId != null) {
          final full = await ref
              .read(catalogDaoProvider)
              .serviceById(row.request.serviceId!);
          if (full != null) {
            _lines.add(_LineDraft(
              designation: full.service.nom,
              qte: 1,
              pu: full.service.prixBase,
              serviceId: full.service.id,
            ));
          }
        }
      }
    } else if (widget.clientId != null) {
      _client = await ref.read(clientsDaoProvider).byId(widget.clientId!);
    } else {
      _lines.add(_LineDraft());
    }
    if (_lines.isEmpty) _lines.add(_LineDraft());
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _pickClient() async {
    final clients = await ref.read(clientsDaoProvider).watchAll().first;
    if (!mounted) return;
    final picked = await showMsnPicker<Client>(
      context: context,
      title: 'Choisir un client',
      items: clients,
      titleOf: (c) => c.nom,
      subtitleOf: (c) => c.telephone ?? '',
    );
    if (picked != null) setState(() => _client = picked);
  }

  Future<void> _addLineFromService() async {
    final services =
        await ref.read(catalogDaoProvider).watchServices(onlyActive: true).first;
    if (!mounted) return;
    final picked = await showMsnPicker<ServiceWithCategoryRow>(
      context: context,
      title: 'Ajouter un service du catalogue',
      items: services,
      titleOf: (s) => s.service.nom,
      subtitleOf: (s) =>
          '${Formatters.ar(s.service.prixBase)} / ${s.service.unite}',
    );
    if (picked != null) {
      setState(() {
        _lines.add(_LineDraft(
          designation: picked.service.nom,
          qte: 1,
          pu: picked.service.prixBase,
          serviceId: picked.service.id,
        ));
      });
    }
  }

  int get _validiteJours => int.tryParse(_validite.text) ?? 15;

  DocumentTotals get _totals => QuoteCalculator.devis(
        lignes: _lines.map((l) => l.toLine()).toList(),
        reduction: Validators.parseMontant(_reduction.text) ?? 0,
        acompte: Validators.parseMontant(_acompte.text) ?? 0,
      );

  Future<void> _save() async {
    if (_client == null) {
      showMsnSnack(context, 'Sélectionnez un client.', error: true);
      return;
    }
    final hasLine = _lines.any((l) => l.designation.text.trim().isNotEmpty);
    if (!hasLine) {
      showMsnSnack(context, 'Ajoutez au moins une ligne.', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final isNew = widget.quoteId == null;
      final id = widget.quoteId ?? 'dev_${now.microsecondsSinceEpoch}';
      final reference = isNew
          ? await ref.read(numberingServiceProvider).next('DEV')
          : (await ref.read(documentsDaoProvider).quoteById(id))!.reference;
      final items = _lines
          .where((l) => l.designation.text.trim().isNotEmpty)
          .toList();
      final totals = QuoteCalculator.devis(
        lignes: items.map((l) => l.toLine()).toList(),
        reduction: Validators.parseMontant(_reduction.text) ?? 0,
        acompte: Validators.parseMontant(_acompte.text) ?? 0,
      );
      final quote = Quote(
        id: id,
        reference: reference,
        clientId: _client!.id,
        requestId: widget.requestId,
        statut: QuoteStatut.brouillon,
        reduction: totals.reduction,
        acompte: totals.acompte,
        delaiJours: int.tryParse(_delai.text.trim()),
        conditions:
            _conditions.text.trim().isEmpty ? null : _conditions.text.trim(),
        validiteJours: _validiteJours,
        montantTotal: totals.total,
        dateEmission: now,
        createdAt: now,
        updatedAt: now,
      );
      final itemRows = <QuoteItem>[];
      for (var i = 0; i < items.length; i++) {
        final l = items[i];
        itemRows.add(QuoteItem(
          id: '${id}_i$i',
          quoteId: id,
          serviceId: l.serviceId,
          designation: l.toLine().designation,
          quantite: l.toLine().quantite,
          prixUnitaire: l.toLine().prixUnitaire,
          ordre: i,
        ));
      }
      await ref.read(documentsDaoProvider).upsertQuoteWithItems(quote, itemRows);
      await ref.read(syncEngineProvider).enqueue(
            entite: 'quotes',
            entityId: id,
            operation: isNew ? SyncOperation.create : SyncOperation.update,
            payload: {'reference': reference, 'total': totals.total},
          );
      await ref.read(activityLoggerProvider).log(
            action:
                isNew ? ActivityAction.creation : ActivityAction.modification,
            entite: 'devis',
            entityId: id,
            details:
                'Devis $reference pour « ${_client!.nom} » — '
                '${Formatters.ar(totals.total)}'
                ' (acompte ${Formatters.ar(totals.acompte)}).',
          );
      if (mounted) {
        showMsnSnack(context, 'Devis $reference enregistré.');
        context.go('/quotes/$id');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()));
    }
    final totals = _totals;
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.quoteId == null ? 'Nouveau devis' : 'Modifier')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(_client?.nom ?? 'Choisir le client'),
              subtitle: _client?.telephone,
              onTap: _pickClient,
            ),
          ),
          const SizedBox(height: 12),

          // ── Lignes ───────────────────────────────────────────────────
          Text('LIGNES DU DEVIS'.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: MsnColors.textSecondary)),
          const SizedBox(height: 6),
          for (var i = 0; i < _lines.length; i++)
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Ligne ${i + 1}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: MsnColors.primaryDark)),
                        ),
                        if (_lines.length > 1)
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () =>
                                setState(() => _lines.removeAt(i)),
                          ),
                      ],
                    ),
                    MsnTextField(
                      label: 'Désignation',
                      controller: _lines[i].designation,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: MsnTextField(
                            label: 'Qté',
                            controller: _lines[i].quantite,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: MsnMoneyField(
                            label: 'Prix unitaire',
                            controller: _lines[i].prixUnitaire,
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Total ligne : '
                        '${Formatters.ar(_lines[i].toLine().totalLigne)}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addLineFromService,
                  icon: const Icon(Icons.storefront, size: 18),
                  label: const Text('Depuis le catalogue',
                      style: TextStyle(fontSize: 12.5)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => setState(() => _lines.add(_LineDraft())),
                child: const Icon(Icons.add, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: MsnMoneyField(
                  label: 'Réduction',
                  controller: _reduction,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MsnMoneyField(
                  label: 'Acompte demandé',
                  controller: _acompte,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MsnTextField(
                  label: 'Délai (jours)',
                  controller: _delai,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MsnTextField(
                  label: 'Validité (jours)',
                  controller: _validite,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          MsnTextField(
            label: 'Conditions',
            controller: _conditions,
            maxLines: 2,
            hint: 'Ex. 2 propositions, 2 corrections incluses…',
          ),
          const SizedBox(height: 12),

          // ── Totaux temps réel ────────────────────────────────────────
          Card(
            color: MsnColors.accentSoft,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _totalRow('Sous-total', Formatters.ar(totals.sousTotal)),
                  _totalRow('Réduction', '- ${Formatters.ar(totals.reduction)}'),
                  _totalRow('TOTAL', Formatters.ar(totals.total), bold: true),
                  _totalRow('Acompte', Formatters.ar(totals.acompte)),
                  _totalRow('Solde après acompte', Formatters.ar(totals.solde)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(widget.quoteId == null
                    ? 'CRÉER LE DEVIS'
                    : 'ENREGISTRER'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                    color: bold
                        ? MsnColors.primaryDark
                        : MsnColors.textSecondary)),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
          ],
        ),
      );

  @override
  void dispose() {
    for (final l in _lines) {
      l.dispose();
    }
    _reduction.dispose();
    _acompte.dispose();
    _delai.dispose();
    _conditions.dispose();
    _validite.dispose();
    super.dispose();
  }
}
