/// Création / édition d'un client (CRM).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/form_fields.dart';

class ClientEditScreen extends ConsumerStatefulWidget {
  const ClientEditScreen({super.key, this.clientId});

  final String? clientId;

  @override
  ConsumerState<ClientEditScreen> createState() => _ClientEditScreenState();
}

class _ClientEditScreenState extends ConsumerState<ClientEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _telephone = TextEditingController();
  final _email = TextEditingController();
  final _adresse = TextEditingController();
  final _notes = TextEditingController();
  Canal? _canalPrefere;
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.clientId == null) {
      setState(() => _loaded = true);
      return;
    }
    final client =
        await ref.read(clientsDaoProvider).byId(widget.clientId!);
    if (client != null) {
      _nom.text = client.nom;
      _telephone.text = client.telephone ?? '';
      _email.text = client.email ?? '';
      _adresse.text = client.adresse ?? '';
      _notes.text = client.notes ?? '';
      _canalPrefere = client.canalPrefere;
    }
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final isNew = widget.clientId == null;
      final id = widget.clientId ?? 'cli_${now.microsecondsSinceEpoch}';
      final client = Client(
        id: id,
        nom: _nom.text.trim(),
        telephone: _telephone.text.trim().isEmpty ? null : _telephone.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        canalPrefere: _canalPrefere,
        adresse: _adresse.text.trim().isEmpty ? null : _adresse.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(clientsDaoProvider).upsert(client);
      await ref.read(syncEngineProvider).enqueue(
            entite: 'clients',
            entityId: id,
            operation: isNew ? SyncOperation.create : SyncOperation.update,
            payload: {
              'nom': client.nom,
              'telephone': client.telephone,
              'email': client.email,
            },
          );
      await ref.read(activityLoggerProvider).log(
            action:
                isNew ? ActivityAction.creation : ActivityAction.modification,
            entite: 'client',
            entityId: id,
            details: isNew
                ? 'Nouveau client enregistré : « ${client.nom} ».'
                : 'Client « ${client.nom} » modifié.',
          );
      if (mounted) {
        showMsnSnack(context, 'Client enregistré.');
        context.go('/clients/$id');
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
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientId == null
            ? 'Nouveau client'
            : 'Modifier le client'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            MsnTextField(
              label: 'Nom complet *',
              controller: _nom,
              prefixIcon: Icons.person_outline,
              validator: (v) => Validators.required(v, label: 'Le nom'),
            ),
            MsnTextField(
              label: 'Téléphone',
              controller: _telephone,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              hint: '034 12 345 67',
              validator: Validators.phone,
            ),
            MsnTextField(
              label: 'Email',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.mail_outline,
            ),
            MsnDropdown<Canal>(
              label: 'Canal de communication préféré',
              value: _canalPrefere,
              items: Canal.values,
              itemLabel: (c) => c.label,
              onChanged: (v) => setState(() => _canalPrefere = v),
            ),
            MsnTextField(
              label: 'Adresse',
              controller: _adresse,
              prefixIcon: Icons.place_outlined,
            ),
            MsnTextField(
              label: 'Notes',
              controller: _notes,
              maxLines: 3,
              hint: 'Historique, préférences, remarques…',
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
                  : Text(widget.clientId == null
                      ? 'CRÉER LE CLIENT'
                      : 'ENREGISTRER'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nom.dispose();
    _telephone.dispose();
    _email.dispose();
    _adresse.dispose();
    _notes.dispose();
    super.dispose();
  }
}
