// Planning éditorial Facebook : PRÉPARATION et suivi uniquement.
// Aucune publication automatique n'existe en V1 — conformément à la spécification.
import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msn_core/data/app_database.dart';
import 'package:uuid/uuid.dart';

import '../../state/providers.dart';

class FacebookPlanningEcran extends ConsumerStatefulWidget {
  const FacebookPlanningEcran({super.key});

  @override
  ConsumerState<FacebookPlanningEcran> createState() => _FacebookPlanningEcranState();
}

class _FacebookPlanningEcranState extends ConsumerState<FacebookPlanningEcran> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planning Facebook')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.event),
        label: const Text('Planifier une publication'),
        onPressed: () => _planifie(context, ref),
      ),
      body: FutureBuilder<MsnDatabase>(
        future: ref.read(baseDeDonneesProvider.future),
        builder: (context, snapDb) {
          if (snapDb.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final db = snapDb.data!;
          return FutureBuilder<List<PublicationsFacebookData>>(
            future: (db.select(db.publicationsFacebook)
                  ..where((t) => t.deletedAt.isNull())
                  ..orderBy([(t) => OrderingTerm.asc(t.datePlanifiee)]))
                .get(),
            builder: (context, snap) {
              final pubs = snap.data ?? const <PublicationsFacebookData>[];
              if (pubs.isEmpty) {
                return const Center(
                    child: Text('Aucune publication planifiée.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: pubs.length,
                itemBuilder: (context, i) => _carte(context, ref, db, pubs[i]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _carte(BuildContext context, WidgetRef ref, MsnDatabase db, PublicationsFacebookData p) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(switch (p.statut) {
          'publie_manuellement' => Icons.check_circle,
          'prete' => Icons.schedule,
          'annule' => Icons.cancel,
          _ => Icons.edit_calendar,
        }),
        title: Text(p.titre),
        subtitle: Text(
            '${p.datePlanifiee} · ${p.statut} — préparation et suivi ; la publication se fait manuellement.'),
        trailing: p.statut == 'publie_manuellement'
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (p.statut == 'planifie')
                    TextButton(
                        onPressed: () => _transition(context, ref, db, p, 'prete'),
                        child: const Text('Prête')),
                  if (p.statut == 'prete')
                    TextButton(
                        onPressed: () => _publieManuellement(context, ref, db, p),
                        child: const Text('Publié manuellement')),
                ],
              ),
      ),
    );
  }

  Future<void> _transition(BuildContext context, WidgetRef ref, MsnDatabase db,
      PublicationsFacebookData p, String vers) async {
    await (db.update(db.publicationsFacebook)..where((t) => t.id.equals(p.id)))
        .write(PublicationsFacebookCompanion(
      statut: Value(vers),
      version: Value(p.version + 1),
      updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
    ));
    setState(() {});
  }

  Future<void> _publieManuellement(BuildContext context, WidgetRef ref,
      MsnDatabase db, PublicationsFacebookData p) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publication faite manuellement ?'),
        content: const Text(
            'MSN Manager ne publie PAS automatiquement. Confirmez seulement si la '
            'publication a réellement été faite sur Facebook.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Non')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Oui, publiée')),
        ],
      ),
    );
    if (confirme != true) return;
    final horodatage = DateTime.now().toUtc().toIso8601String();
    await (db.update(db.publicationsFacebook)..where((t) => t.id.equals(p.id)))
        .write(PublicationsFacebookCompanion(
      statut: const Value('publie_manuellement'),
      publieAt: Value(horodatage),
      version: Value(p.version + 1),
      updatedAt: Value(horodatage),
    ));
    setState(() {});
  }

  Future<void> _planifie(BuildContext context, WidgetRef ref) async {
    final titreCtrl = TextEditingController();
    final contenuCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle publication planifiée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titreCtrl, decoration: const InputDecoration(labelText: 'Titre *')),
            TextField(controller: contenuCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Contenu *')),
            TextField(
              controller: dateCtrl,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Date planifiée *'),
              onTap: () async {
                final d = await showDatePicker(
                  context: ctx,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 180)),
                );
                if (d != null) dateCtrl.text = d.toIso8601String().substring(0, 10);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            onPressed: () =>
                (titreCtrl.text.isEmpty || contenuCtrl.text.isEmpty || dateCtrl.text.isEmpty)
                    ? null
                    : Navigator.pop(ctx, true),
            child: const Text('Planifier'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final db = await ref.read(baseDeDonneesProvider.future);
    final horodatage = DateTime.now().toUtc().toIso8601String();
    await db.into(db.publicationsFacebook).insert(PublicationsFacebookCompanion.insert(
          id: const Uuid().v4(),
          titre: titreCtrl.text.trim(),
          contenu: contenuCtrl.text.trim(),
          datePlanifiee: dateCtrl.text,
          createdAt: horodatage,
          updatedAt: horodatage,
        ));
    setState(() {});
  }
}
