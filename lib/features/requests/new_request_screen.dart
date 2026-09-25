/// NOUVELLE DEMANDE — premier geste métier de MSN : enregistrer une
/// demande reçue sur Messenger/WhatsApp/appel (section 8).
///
/// Le client peut être sélectionné ou créé à la volée ; les fichiers
/// reçus du client sont joints au dossier SOURCE ; une référence
/// REQ-2026-XXXX est attribuée automatiquement.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/form_fields.dart';
import '../catalog/catalog_providers.dart';
import '../clients/clients_providers.dart';

class NewRequestScreen extends ConsumerStatefulWidget {
  const NewRequestScreen({super.key, this.initialClientId});

  final String? initialClientId;

  @override
  ConsumerState<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends ConsumerState<NewRequestScreen> {
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

  @override
  void initState() {
    super.initState();
    if (widget.initialClientId != null) {
      _loadInitialClient();
    }
  }

  Future<void> _loadInitialClient() async {
    final c =
        await ref.read(clientsDaoProvider).byId(widget.initialClientId!);
    if (c != null) setState(() => _client = c);
  }

  Future<void> _pickClient() async {
    final clients =
        await ref.read(clientsDaoProvider).watchAll().first;
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
      await ref.read(activityLoggerProvider).log(
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
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(catalogServicesForPickProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle demande')),
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
                subtitle: _client?.telephone,
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
              data: (services) => MsnDropdown<Service?>(
                label: 'Service demandé',
                value: _service,
                items: [null, ...services],
                itemLabel: (s) => s?.nom ?? '— Non déterminé —',
                onChanged: (v) => setState(() => _service = v),
              ),
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
                  : const Text('ENREGISTRER LA DEMANDE'),
            ),
            const SizedBox(height: 6),
            Text(
              'Les fichiers reçus du client pourront être joints depuis la '
              'fiche de la demande (dossier SOURCE).',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  color: MsnColors.textSecondary.withOpacity(0.9)),
            ),
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
