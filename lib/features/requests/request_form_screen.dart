/// Formulaire de demande — CRÉATION et MODIFICATION (réutilisé par les
/// deux modes pour éviter toute implémentation concurrente).
///
/// En modification, chaque champ changé est tracé dans le journal
/// d'activité : quoi, ancienne valeur, nouvelle valeur, utilisateur,
/// date et heure (via ActivityLogger.logFieldChange).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/form_fields.dart';
import '../catalog/catalog_providers.dart';

class RequestFormScreen extends ConsumerStatefulWidget {
  const RequestFormScreen({super.key, this.requestId, this.initialClientId});

  /// Présent → mode édition (pré-rempli) ; absent → création.
  final String? requestId;
  final String? initialClientId;

  @override
  ConsumerState<RequestFormScreen> createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends ConsumerState<RequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _budget = TextEditingController();
  final _notes = TextEditingController();

  Client? _client;
  Canal _canal = Canal.messenger;
  Service? _service;
  DateTime? _deadline;
  Priorite _priorite = Priorite.normale;

  bool _saving = false;
  bool _loaded = false;
  Request? _existing;

  bool get _isEdit => widget.requestId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loadExisting();
    } else if (widget.initialClientId != null) {
      _loadInitialClient();
    }
  }

  Future<void> _loadExisting() async {
    final row = await ref.read(requestsDaoProvider).byId(widget.requestId!);
    if (row == null) {
      if (mounted) {
        showMsnSnack(context, 'Demande introuvable.', error: true);
        context.pop();
      }
      return;
    }
    final services = ref.read(catalogServicesForPickProvider).value ?? [];
    Service? service;
    if (row.request.serviceId != null) {
      service =
          services.where((s) => s.id == row.request.serviceId).firstOrNull;
      if (service == null) {
        final byId = await ref
            .read(catalogDaoProvider)
            .serviceById(row.request.serviceId!);
        service = byId?.service;
      }
    }
    if (!mounted) return;
    setState(() {
      _existing = row.request;
      _client = row.client;
      _service = service;
      _canal = row.request.canal;
      _description.text = row.request.description ?? '';
      _deadline = row.request.deadlineSouhaitee;
      _budget.text =
          row.request.budget == null ? '' : Formatters.ar(row.request.budget);
      _priorite = row.request.priorite;
      _notes.text = row.request.notes ?? '';
      _loaded = true;
    });
  }

  Future<void> _loadInitialClient() async {
    final c =
        await ref.read(clientsDaoProvider).byId(widget.initialClientId!);
    if (c != null) setState(() => _client = c);
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
      leadingOf: (c) => const CircleAvatar(
        child: Icon(Icons.person, size: 20),
      ),
    );
    if (picked != null) setState(() => _client = picked);
  }

  Future<void> _createClientInline() async {
    final controller = TextEditingController();
    final phone = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nom *'),
            ),
            TextField(
              controller: phone,
              decoration: const InputDecoration(labelText: 'Téléphone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Créer')),
        ],
      ),
    );
    if (ok != true || controller.text.trim().isEmpty || !mounted) return;

    final now = DateTime.now();
    final id = 'cli_${now.microsecondsSinceEpoch}';
    final client = Client(
      id: id,
      nom: controller.text.trim(),
      telephone: phone.text.trim().isEmpty ? null : phone.text.trim(),
      canalPrefere: _canal,
      createdAt: now,
      updatedAt: now,
    );
    await ref.read(clientsDaoProvider).upsert(client);
    await ref.read(syncEngineProvider).enqueue(
          entite: 'clients',
          entityId: id,
          operation: SyncOperation.create,
          payload: {'nom': client.nom, 'telephone': client.telephone},
        );
    setState(() => _client = client);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_client == null) {
      showMsnSnack(context, 'Sélectionnez ou créez un client.', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final logger = ref.read(activityLoggerProvider);

      if (_isEdit && _existing != null) {
        final old = _existing!;
        final newBudget = Validators.parseMontant(_budget.text);
        final newDescription =
            _description.text.trim().isEmpty ? null : _description.text.trim();
        final newNotes = _notes.text.trim().isEmpty ? null : _notes.text.trim();

        final updated = Request(
          id: old.id,
          reference: old.reference,
          clientId: _client!.id,
          canal: _canal,
          serviceId: _service?.id,
          description: newDescription,
          deadlineSouhaitee: _deadline,
          budget: newBudget,
          priorite: _priorite,
          statut: old.statut,
          notes: newNotes,
          qualificationJson: old.qualificationJson,
          createdAt: old.createdAt,
          updatedAt: now,
        );
        await ref.read(requestsDaoProvider).upsert(updated);

        // Historique champ par champ : quoi, avant, après, utilisateur,
        // date et heure (le logger horodate tout seul).
        Future<void> trace(String champ, String libelle, String? a, String? b) {
          if (a == b) return Future.value();
          return logger.logFieldChange(
            entite: 'demande',
            entityId: old.id,
            reference: old.reference,
            champ: champ,
            libelleChamp: libelle,
            ancienneValeur: a,
            nouvelleValeur: b,
          );
        }

        await trace('client', 'le client', old.clientId, _client!.id);
        await trace('canal', 'le canal de réception', old.canal.label, _canal.label);
        await trace('service', 'le service', old.serviceId, _service?.id);
        await trace('description', 'la description', old.description, newDescription);
        await trace('deadline', 'la deadline souhaitée',
            old.deadlineSouhaitee?.toIso8601String(), _deadline?.toIso8601String());
        await trace('budget', 'le budget indiqué',
            old.budget?.toString(), newBudget?.toString());
        await trace('priorite', 'la priorité', old.priorite.label, _priorite.label);
        await trace('notes', 'les notes internes', old.notes, newNotes);

        await ref.read(syncEngineProvider).enqueue(
              entite: 'requests',
              entityId: old.id,
              operation: SyncOperation.update,
              payload: {'updatedAt': now.toIso8601String()},
            );
        if (mounted) {
          showMsnSnack(context, 'Demande ${old.reference} mise à jour.');
          context.pop();
        }
      } else {
        final reference =
            await ref.read(numberingServiceProvider).next('REQ');
        final id = 'req_${now.microsecondsSinceEpoch}';
        final request = Request(
          id: id,
          reference: reference,
          clientId: _client!.id,
          canal: _canal,
          serviceId: _service?.id,
          description:
              _description.text.trim().isEmpty ? null : _description.text.trim(),
          deadlineSouhaitee: _deadline,
          budget: Validators.parseMontant(_budget.text),
          priorite: _priorite,
          statut: RequestStatut.nouvelle,
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await ref.read(requestsDaoProvider).upsert(request);
        await ref.read(syncEngineProvider).enqueue(
              entite: 'requests',
              entityId: id,
              operation: SyncOperation.create,
              payload: {
                'reference': reference,
                'clientId': _client!.id,
                'serviceId': _service?.id,
                'canal': _canal.name,
              },
            );
        await logger.log(
              action: ActivityAction.creation,
              entite: 'demande',
              entityId: id,
              details:
                  'Nouvelle demande $reference reçue de « ${_client!.nom} »'
                  '${_service != null ? ' — ${_service!.nom}' : ''}.',
            );
        if (mounted) {
          showMsnSnack(context, 'Demande $reference enregistrée.');
          context.go('/requests/$id');
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(catalogServicesForPickProvider);
    if (_isEdit && !_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modifier la demande')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier la demande' : 'Nouvelle demande'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            // ── Client ──────────────────────────────────────────────────
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(_client?.nom ?? 'Sélectionner un client'),
                subtitle: _client?.telephone == null
                    ? null
                    : Text(_client!.telephone ?? ''),
                trailing: TextButton(
                  onPressed: _createClientInline,
                  child: const Text('+ Créer'),
                ),
                onTap: _pickClient,
              ),
            ),
            const SizedBox(height: 12),

            MsnDropdown<Canal>(
              label: 'Canal de réception',
              value: _canal,
              items: Canal.values,
              itemLabel: (c) => c.label,
              onChanged: (v) => setState(() => _canal = v ?? Canal.autre),
            ),

            // ── Service demandé ─────────────────────────────────────────
            servicesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Erreur services : $e'),
              data: (services) {
                final list = [null, ...services];
                final value = _service != null &&
                        !list.any((s) => s?.id == _service!.id)
                    ? null
                    : _service;
                return MsnDropdown<Service?>(
                  label: 'Service demandé',
                  value: value,
                  items: list,
                  itemLabel: (s) => s?.nom ?? '— Non déterminé —',
                  onChanged: (v) => setState(() => _service = v),
                );
              },
            ),

            MsnTextField(
              label: 'Description de la demande',
              controller: _description,
              maxLines: 3,
              hint: 'Ce que le client demande, avec ses mots…',
            ),
            MsnDateField(
              label: 'Deadline souhaitée',
              value: _deadline,
              onChanged: (v) => setState(() => _deadline = v),
            ),
            MsnMoneyField(
              label: 'Budget indiqué (optionnel)',
              controller: _budget,
            ),
            MsnDropdown<Priorite>(
              label: 'Priorité',
              value: _priorite,
              items: Priorite.values,
              itemLabel: (p) => p.label,
              onChanged: (v) =>
                  setState(() => _priorite = v ?? Priorite.normale),
            ),
            MsnTextField(
              label: 'Notes internes',
              controller: _notes,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(_isEdit
                      ? 'ENREGISTRER LES MODIFICATIONS'
                      : 'ENREGISTRER LA DEMANDE'),
            ),
            if (!_isEdit) ...[
              const SizedBox(height: 6),
              Text(
                'Les fichiers reçus du client pourront être joints depuis '
                'la fiche de la demande (dossier SOURCE), plusieurs à la fois.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    color:
                        MsnColors.textSecondary.withValues(alpha: 0.9)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _description.dispose();
    _budget.dispose();
    _notes.dispose();
    super.dispose();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
