// Demandes commerciales : réception du besoin, qualification, prix indicatif.
// Une demande N'EST PAS une commande et peut le rester (spec §6.A-D).
import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:msn_core/data/app_database.dart';
import 'package:msn_core/domain/regles.dart';
import 'package:uuid/uuid.dart';

import '../../state/providers.dart';
import '../../state/tableaux_bord.dart';

class DemandesEcran extends ConsumerStatefulWidget {
  const DemandesEcran({super.key});

  @override
  ConsumerState<DemandesEcran> createState() => _DemandesEcranState();
}

class _DemandesEcranState extends ConsumerState<DemandesEcran> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demandes commerciales')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle demande'),
        onPressed: () => _formulaireDemande(context, ref),
      ),
      body: FutureBuilder<MsnDatabase>(
        future: ref.read(baseDeDonneesProvider.future),
        builder: (context, snapDb) {
          if (snapDb.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final db = snapDb.data!;
          return FutureBuilder<List<Demande>>(
            future: (db.select(db.demandes)
                  ..where((t) => t.deletedAt.isNull())
                  ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
                .get(),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final demandes = snap.data ?? const <Demande>[];
              if (demandes.isEmpty) {
                return const Center(
                    child: Text('Aucune demande — enregistrez le premier besoin reçu.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: demandes.length,
                itemBuilder: (context, i) => _carte(context, ref, db, demandes[i]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _carte(BuildContext context, WidgetRef ref, MsnDatabase db, Demande d) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(d.besoinResume ?? d.messageInitial,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
            '${LibellesStatuts.demandeStatut(d.statut)} · canal ${d.canalOrigine}'
            ' · ${DateFormat('dd/MM').format(d.createdAtDateTime)}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Message initial :',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(d.messageInitial),
                ),
                const SizedBox(height: 8),
                // Actions autorisées selon l'état courant (spec §5 UX)
                Wrap(
                  spacing: 8,
                  children: [
                    if (Statuts.transitionAutorisee('demande', d.statut, 'offre_presentee'))
                      OutlinedButton.icon(
                        icon: const Icon(Icons.request_quote),
                        label: const Text('Présenter l\'offre'),
                        onPressed: () => _transition(context, ref, db, d, 'offre_presentee'),
                      ),
                    if (Statuts.transitionAutorisee('demande', d.statut, 'devis_a_preparer'))
                      OutlinedButton.icon(
                        icon: const Icon(Icons.description),
                        label: const Text('Devis à préparer'),
                        onPressed: () => _transition(context, ref, db, d, 'devis_a_preparer'),
                      ),
                    if (Statuts.transitionAutorisee('demande', d.statut, 'perdue'))
                      OutlinedButton.icon(
                        icon: const Icon(Icons.block),
                        label: const Text('Marquer perdue'),
                        onPressed: () => _perdue(context, ref, db, d),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _transition(BuildContext context, WidgetRef ref, MsnDatabase db,
      Demande d, String vers) async {
    await (db.update(db.demandes)..where((t) => t.id.equals(d.id))).write(
      DemandesCompanion(
        statut: Value(vers),
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
        version: Value(d.version + 1),
      ),
    );
    // Outbox : l'opération partira à la prochaine synchronisation
    await db.into(db.syncOutbox).insert(SyncOutboxCompanion.insert(
          id: const Uuid().v4(),
          appareilId: db.appareilIdLocal,
          entiteType: 'demande',
          entiteId: d.id,
          operation: 'upsert',
          payloadJson:
              '{"besoin_resume": ${_json(d.besoinResume)}, "message_initial": ${_json(d.messageInitial)}, "canal_origine": "${d.canalOrigine}"}',
          baseVersion: Value(d.version),
          idempotencyKey: const Uuid().v4(),
          createdAt: DateTime.now().toUtc().toIso8601String(),
          updatedAt: DateTime.now().toUtc().toIso8601String(),
        ));
    ref.invalidate(resumeTableauBordProvider);
    setState(() {});
  }

  Future<void> _perdue(BuildContext context, WidgetRef ref, MsnDatabase db, Demande d) async {
    final motifCtrl = TextEditingController();
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Marquer la demande comme perdue ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Un motif est requis et sera conservé dans l\'historique.'),
            TextField(
                controller: motifCtrl,
                decoration: const InputDecoration(labelText: 'Motif *')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => motifCtrl.text.trim().isEmpty
                  ? null
                  : Navigator.pop(ctx, true),
              child: const Text('Confirmer')),
        ],
      ),
    );
    if (confirme != true) return;
    await (db.update(db.demandes)..where((t) => t.id.equals(d.id))).write(
      DemandesCompanion(
        statut: const Value('perdue'),
        motifPerte: Value(motifCtrl.text.trim()),
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
        version: Value(d.version + 1),
      ),
    );
    setState(() {});
  }
}

String _json(String? s) =>
    s == null ? 'null' : '"${s.replaceAll('"', '\\"').replaceAll('\n', ' ')}"';

/// Formulaire de création : conserve le message initial TEL QUEL (spec §6.A).
Future<void> _formulaireDemande(BuildContext context, WidgetRef ref) async {
  final formKey = GlobalKey<FormState>();
  final messageCtrl = TextEditingController();
  final resumeCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  String canal = 'messenger';
  String? clientId;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Nouvelle demande', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              FutureBuilder<MsnDatabase>(
                future: ref.read(baseDeDonneesProvider.future),
                builder: (ctx, snap) {
                  final db = snap.data;
                  if (db == null) return const LinearProgressIndicator();
                  return FutureBuilder(
                    future: (db.select(db.clients)
                          ..where((t) => t.deletedAt.isNull()))
                        .get(),
                    builder: (ctx, snapC) {
                      final clients = snapC.data ?? const <Client>[];
                      return DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: 'Client existant *'),
                        items: [
                          for (final c in clients)
                            DropdownMenuItem(value: c.id, child: Text(c.nomAffiche)),
                        ],
                        onChanged: (v) => setState(() => clientId = v),
                        validator: (v) =>
                            v == null ? 'Recherchez ou créez d\'abord le client' : null,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Canal d\'origine'),
                items: const [
                  DropdownMenuItem(value: 'messenger', child: Text('Messenger')),
                  DropdownMenuItem(value: 'facebook', child: Text('Facebook')),
                  DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                  DropdownMenuItem(value: 'email', child: Text('Email')),
                  DropdownMenuItem(value: 'telephone', child: Text('Téléphone')),
                  DropdownMenuItem(value: 'presentiel', child: Text('Présentiel')),
                  DropdownMenuItem(value: 'autre', child: Text('Autre')),
                ],
                initialValue: canal,
                onChanged: (v) => setState(() => canal = v ?? 'messenger'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: messageCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Message initial (tel que reçu) *',
                  helperText: 'Collez le message du client sans le reformuler.',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Message obligatoire' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: resumeCtrl,
                decoration:
                    const InputDecoration(labelText: 'Résumé du besoin'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: dateCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                    labelText: 'Date limite souhaitée',
                    suffixIcon: Icon(Icons.calendar_today)),
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) {
                    dateCtrl.text = d.toIso8601String().substring(0, 10);
                  }
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                child: const Text('Enregistrer la demande'),
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  final db = await ref.read(baseDeDonneesProvider.future);
                  final horodatage = DateTime.now().toUtc().toIso8601String();
                  final id = const Uuid().v4();
                  await db.into(db.demandes).insert(DemandesCompanion.insert(
                        id: id,
                        clientId: clientId!,
                        canalOrigine: canal,
                        messageInitial: messageCtrl.text.trim(),
                        besoinResume: Value(resumeCtrl.text.trim().isEmpty
                            ? null
                            : resumeCtrl.text.trim()),
                        dateLimiteSouhaitee: Value(dateCtrl.text.isEmpty ? null : dateCtrl.text),
                        createdAt: horodatage,
                        updatedAt: horodatage,
                      ));
                  await db.into(db.syncOutbox).insert(SyncOutboxCompanion.insert(
                        id: const Uuid().v4(),
                        appareilId: db.appareilIdLocal,
                        entiteType: 'demande',
                        entiteId: id,
                        operation: 'upsert',
                        payloadJson: '{"canal_origine": "$canal", "message_initial": ${_json(messageCtrl.text)}, "besoin_resume": ${_json(resumeCtrl.text)}}',
                        idempotencyKey: const Uuid().v4(),
                        createdAt: horodatage,
                        updatedAt: horodatage,
                      ));
                  ref.invalidate(resumeTableauBordProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

extension on Demande {
  DateTime get createdAtDateTime => DateTime.tryParse(createdAt) ?? DateTime.now();
}
