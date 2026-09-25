/// Création / édition d'un service : tarifs, délais, conditions ET règles
/// métier configurables (section 23) — sans toucher au code.
library;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/session.dart';
import '../../core/constants/app_constants.dart';
import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/form_fields.dart';

class ServiceEditScreen extends ConsumerStatefulWidget {
  const ServiceEditScreen({super.key, this.serviceId});

  final String? serviceId;

  @override
  ConsumerState<ServiceEditScreen> createState() => _ServiceEditScreenState();
}

class _ServiceEditScreenState extends ConsumerState<ServiceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _description = TextEditingController();
  final _prix = TextEditingController();
  final _unite = TextEditingController(text: 'forfait');
  final _delai = TextEditingController();
  final _inclus = TextEditingController();
  final _exclusions = TextEditingController();
  final _conditions = TextEditingController();

  Category? _category;
  bool _actif = true;

  // Règles métier éditables (section 23).
  bool _acompteObligatoire = false;
  int _propositionsIncluses = 2;
  int _correctionsIncluses = 2;
  bool _paiementFinalAvantLivraison = false;
  bool _validationFinaleObligatoire = false;

  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final categories =
        await ref.read(catalogDaoProvider).watchCategories().first;
    if (widget.serviceId != null) {
      final full =
          await ref.read(catalogDaoProvider).serviceById(widget.serviceId!);
      if (full != null) {
        final s = full.service;
        _nom.text = s.nom;
        _description.text = s.description ?? '';
        _prix.text = s.prixBase.toString();
        _unite.text = s.unite;
        _delai.text = s.delaiJours?.toString() ?? '';
        _inclus.text = s.inclus ?? '';
        _exclusions.text = s.exclusions ?? '';
        _conditions.text = s.conditions ?? '';
        _actif = s.actif;
        _category = categories.where((c) => c.id == s.categoryId).firstOrNull;
      }
      final rules = await ref
          .read(templatesDaoProvider)
          .rulesForService(widget.serviceId);
      for (final r in rules) {
        switch (r.cle) {
          case RuleKeys.acompteObligatoire:
            _acompteObligatoire = r.valeur == 'true';
          case RuleKeys.propositionsIncluses:
            _propositionsIncluses = int.tryParse(r.valeur) ?? 2;
          case RuleKeys.correctionsIncluses:
            _correctionsIncluses = int.tryParse(r.valeur) ?? 2;
          case RuleKeys.paiementFinalAvantLivraison:
            _paiementFinalAvantLivraison = r.valeur == 'true';
          case RuleKeys.validationFinaleObligatoire:
            _validationFinaleObligatoire = r.valeur == 'true';
        }
      }
    }
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    final session = ref.read(sessionProvider);
    if (!(session?.isAdmin ?? false)) {
      showMsnSnack(context,
          'Seul un administrateur peut modifier les tarifs.', error: true);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final isNew = widget.serviceId == null;
      final id =
          widget.serviceId ?? 'svc_${now.microsecondsSinceEpoch}';
      final old =
          isNew ? null : await ref.read(catalogDaoProvider).serviceById(id);
      final service = Service(
        id: id,
        nom: _nom.text.trim(),
        description:
            _description.text.trim().isEmpty ? null : _description.text.trim(),
        categoryId: _category?.id,
        prixBase: Validators.parseMontant(_prix.text) ?? 0,
        unite: _unite.text.trim().isEmpty ? 'forfait' : _unite.text.trim(),
        delaiJours: int.tryParse(_delai.text.trim()),
        inclus: _inclus.text.trim().isEmpty ? null : _inclus.text.trim(),
        exclusions:
            _exclusions.text.trim().isEmpty ? null : _exclusions.text.trim(),
        conditions:
            _conditions.text.trim().isEmpty ? null : _conditions.text.trim(),
        actif: _actif,
        createdAt: old?.service.createdAt ?? now,
        updatedAt: now,
      );
      await ref.read(catalogDaoProvider).upsertService(service);

      // Règles métier (upsert 5 clés).
      final dao = ref.read(templatesDaoProvider);
      final rules = {
        RuleKeys.acompteObligatoire: _acompteObligatoire.toString(),
        RuleKeys.propositionsIncluses: _propositionsIncluses.toString(),
        RuleKeys.correctionsIncluses: _correctionsIncluses.toString(),
        RuleKeys.paiementFinalAvantLivraison:
            _paiementFinalAvantLivraison.toString(),
        RuleKeys.validationFinaleObligatoire:
            _validationFinaleObligatoire.toString(),
      };
      for (final entry in rules.entries) {
        await dao.upsertRule(BusinessRule(
          id: 'rule_${id}_${entry.key}',
          serviceId: id,
          cle: entry.key,
          valeur: entry.value,
          description: RuleKeys.labels[entry.key],
        ));
      }

      await ref.read(syncEngineProvider).enqueue(
            entite: 'services',
            entityId: id,
            operation: isNew ? SyncOperation.create : SyncOperation.update,
            payload: {
              'nom': service.nom,
              'prixBase': service.prixBase,
              'unite': service.unite,
            },
          );

      final logger = ref.read(activityLoggerProvider);
      if (isNew) {
        await logger.log(
          action: ActivityAction.creation,
          entite: 'service',
          entityId: id,
          details:
              'Nouveau service « ${service.nom} » à '
              '${Formatters.ar(service.prixBase)} / ${service.unite}.',
        );
      } else if (old != null && old.service.prixBase != service.prixBase) {
        await logger.log(
          action: ActivityAction.changementTarif,
          entite: 'service',
          entityId: id,
          details:
              'Tarif « ${service.nom} » modifié : '
              '${Formatters.ar(old.service.prixBase)} → '
              '${Formatters.ar(service.prixBase)}.',
        );
      } else {
        await logger.log(
          action: ActivityAction.modification,
          entite: 'service',
          entityId: id,
          details: 'Service « ${service.nom} » modifié.',
        );
      }

      if (mounted) {
        showMsnSnack(
            context, 'Service enregistré — messages, images et PDF à jour.');
        context.go('/catalog/$id');
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
    final categoriesAsync = ref.watch(catalogCategoriesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceId == null
            ? 'Nouveau service'
            : 'Modifier le service'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            MsnTextField(
              label: 'Nom du service *',
              controller: _nom,
              validator: (v) => Validators.required(v, label: 'Le nom'),
            ),
            categoriesAsync.maybeWhen(
              data: (cats) => MsnDropdown<Category?>(
                label: 'Catégorie',
                value: _category,
                items: [null, ...cats],
                itemLabel: (c) => c?.nom ?? '— Sans catégorie —',
                onChanged: (v) => setState(() => _category = v),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            MsnTextField(
              label: 'Description commerciale',
              controller: _description,
              maxLines: 3,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: MsnMoneyField(
                    label: 'Prix de base',
                    controller: _prix,
                    obligatoire: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MsnTextField(
                    label: 'Unité',
                    controller: _unite,
                    hint: 'forfait / page / pièce',
                  ),
                ),
              ],
            ),
            MsnTextField(
              label: 'Délai habituel (jours)',
              controller: _delai,
              keyboardType: TextInputType.number,
            ),
            MsnTextField(
              label: 'Inclus dans le prix',
              controller: _inclus,
              hint: 'Ex. fichiers finaux PDF + PNG',
            ),
            MsnTextField(
              label: 'Exclusions',
              controller: _exclusions,
              hint: 'Ex. impression physique',
            ),
            MnnConditions(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Service actif',
                  style: TextStyle(fontSize: 14)),
              subtitle: const Text(
                  'Les services inactifs n’apparaissent pas dans les '
                  'présentations client.',
                  style: TextStyle(fontSize: 11.5)),
              value: _actif,
              onChanged: (v) => setState(() => _actif = v),
            ),
            const SizedBox(height: 8),

            // ── Règles métier ──────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RÈGLES MÉTIER DU SERVICE',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: MsnColors.textSecondary)),
                    const SizedBox(height: 6),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('Acompte obligatoire',
                          style: TextStyle(fontSize: 13.5)),
                      subtitle: const Text(
                          'Bloque la production tant qu’aucun acompte '
                          'n’est enregistré.',
                          style: TextStyle(fontSize: 11)),
                      value: _acompteObligatoire,
                      onChanged: (v) =>
                          setState(() => _acompteObligatoire = v),
                    ),
                    Row(
                      children: [
                        const Expanded(
                            child: Text('Propositions incluses',
                                style: TextStyle(fontSize: 13.5))),
                        IconButton(
                          onPressed: () => setState(() =>
                              _propositionsIncluses =
                                  (_propositionsIncluses - 1).clamp(0, 99)),
                          icon: const Icon(Icons.remove_circle_outline,
                              size: 20),
                        ),
                        Text('$_propositionsIncluses',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15)),
                        IconButton(
                          onPressed: () => setState(() =>
                              _propositionsIncluses =
                                  (_propositionsIncluses + 1).clamp(0, 99)),
                          icon: const Icon(Icons.add_circle_outline,
                              size: 20),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Expanded(
                            child: Text('Corrections incluses',
                                style: TextStyle(fontSize: 13.5))),
                        IconButton(
                          onPressed: () => setState(() =>
                              _correctionsIncluses =
                                  (_correctionsIncluses - 1).clamp(0, 99)),
                          icon: const Icon(Icons.remove_circle_outline,
                              size: 20),
                        ),
                        Text('$_correctionsIncluses',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15)),
                        IconButton(
                          onPressed: () => setState(() =>
                              _correctionsIncluses =
                                  (_correctionsIncluses + 1).clamp(0, 99)),
                          icon: const Icon(Icons.add_circle_outline,
                              size: 20),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('Paiement final avant livraison',
                          style: TextStyle(fontSize: 13.5)),
                      value: _paiementFinalAvantLivraison,
                      onChanged: (v) => setState(
                          () => _paiementFinalAvantLivraison = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('Validation finale obligatoire',
                          style: TextStyle(fontSize: 13.5)),
                      value: _validationFinaleObligatoire,
                      onChanged: (v) => setState(
                          () => _validationFinaleObligatoire = v),
                    ),
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
                  : const Text('ENREGISTRER LE SERVICE'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget MnnConditions() {
    return MsnTextField(
      label: 'Conditions particulières',
      controller: _conditions,
      maxLines: 2,
      hint: 'Ex. acompte 40%, valable 15 jours…',
    );
  }

  @override
  void dispose() {
    _nom.dispose();
    _description.dispose();
    _prix.dispose();
    _unite.dispose();
    _delai.dispose();
    _inclus.dispose();
    _exclusions.dispose();
    _conditions.dispose();
    super.dispose();
  }
}
