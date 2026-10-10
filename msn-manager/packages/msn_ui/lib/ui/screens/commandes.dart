// Commandes : état courant + actions autorisées dans le même écran (spec §5 UX),
// transitions contrôlées, livraison obligatoire avant « livrée », projets multiples.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msn_core/data/app_database.dart';
import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:msn_core/domain/regles.dart';
import 'package:uuid/uuid.dart';

import '../../state/providers.dart';
import '../../state/tableaux_bord.dart';

class CommandesEcran extends ConsumerStatefulWidget {
  const CommandesEcran({super.key});

  @override
  ConsumerState<CommandesEcran> createState() => _CommandesEcranState();
}

class _CommandesEcranState extends ConsumerState<CommandesEcran> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commandes')),
      body: FutureBuilder<MsnDatabase>(
        future: ref.read(baseDeDonneesProvider.future),
        builder: (context, snapDb) {
          if (snapDb.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final db = snapDb.data!;
          return FutureBuilder<List<Commande>>(
            future: (db.select(db.commandes)
                  ..where((t) => t.deletedAt.isNull())
                  ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
                .get(),
            builder: (context, snap) {
              final commandes = snap.data ?? const <Commande>[];
              if (commandes.isEmpty) {
                return const Center(
                    child: Text('Aucune commande — acceptez un devis pour en créer.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: commandes.length,
                itemBuilder: (context, i) => _carte(context, ref, db, commandes[i]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _carte(BuildContext context, WidgetRef ref, MsnDatabase db, Commande c) {
    final transitions = ['en_attente_validation', 'validee', 'en_production', 'en_correction', 'annulee']
        .where((vers) => Statuts.transitionAutorisee('commande', c.statut, vers))
        .toList();
    final livraisonPossible =
        Statuts.transitionAutorisee('commande', c.statut, 'livree');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(c.numero),
        subtitle: Text(LibellesStatuts.commandeStatut(c.statut)),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (c.motifAnnulation != null)
                  Text('Motif d\'annulation : ${c.motifAnnulation}',
                      style: const TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final vers in transitions)
                      OutlinedButton(
                        onPressed: () =>
                            _transition(context, ref, db, c, vers, requireMotif: vers == 'annulee'),
                        child: Text(LibellesStatuts.commandeStatut(vers)),
                      ),
                    if (livraisonPossible)
                      FilledButton.icon(
                        icon: const Icon(Icons.local_shipping),
                        label: const Text('Enregistrer la livraison'),
                        onPressed: () => _livraison(context, ref, db, c),
                      ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.folder_special),
                      label: const Text('Ajouter un projet'),
                      onPressed: () => _ajouteProjet(context, ref, db, c),
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
      Commande c, String vers, {bool requireMotif = false}) async {
    String? motif;
    if (requireMotif) {
      motif = await _demandeMotif(context, 'Motif d\'annulation (obligatoire)');
      if (motif == null || motif.isEmpty) return;
    }
    await (db.update(db.commandes)..where((t) => t.id.equals(c.id))).write(
      CommandesCompanion(
        statut: Value(vers),
        motifAnnulation: Value(motif),
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
        version: Value(c.version + 1),
      ),
    );
    await _outbox(db, 'commande', c.id);
    ref.invalidate(resumeTableauBordProvider);
    setState(() {});
  }

  /// Livraison : exige un livrable décrit OU des fichiers joints (spec §6.G).
  Future<void> _livraison(BuildContext context, WidgetRef ref, MsnDatabase db, Commande c) async {
    final descCtrl = TextEditingController();
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enregistrer la livraison'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Décrivez le livrable remis au client. Une commande ne passe '
                '« livrée » qu\'avec un événement de livraison (spéc. §6.G).'),
            TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Livrable décrit * (ou fichiers joints)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => descCtrl.text.trim().isEmpty
                ? null
                : Navigator.pop(ctx, true),
            child: const Text('Marquer livrée'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    await db.transaction(() async {
      await (db.update(db.commandes)..where((t) => t.id.equals(c.id))).write(
        CommandesCompanion(
          statut: const Value('livree'),
          updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
          version: Value(c.version + 1),
        ),
      );
      // Événement de livraison dans le journal d'audit local
      await db.into(db.journalActions).insert(JournalActionsCompanion.insert(
            id: const Uuid().v4(),
            entiteType: 'commande',
            entiteId: c.id,
            action: 'livraison',
            apresJson: Value('{"livrable": "${descCtrl.text.trim()}"}'),
            appareilId: db.appareilIdLocal,
            dateAction: DateTime.now().toUtc().toIso8601String(),
            createdAt: DateTime.now().toUtc().toIso8601String(),
            updatedAt: DateTime.now().toUtc().toIso8601String(),
          ));
      await _outbox(db, 'commande', c.id);
    });
    ref.invalidate(resumeTableauBordProvider);
    setState(() {});
  }

  Future<void> _ajouteProjet(BuildContext context, WidgetRef ref, MsnDatabase db, Commande c) async {
    final nomCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau projet dans la commande'),
        content: TextField(
            controller: nomCtrl,
            decoration: const InputDecoration(labelText: 'Nom du projet *')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
              onPressed: () =>
                  nomCtrl.text.trim().isEmpty ? null : Navigator.pop(ctx, true),
              child: const Text('Ajouter')),
        ],
      ),
    );
    if (ok != true) return;
    final horodatage = DateTime.now().toUtc().toIso8601String();
    await db.into(db.projets).insert(ProjetsCompanion.insert(
          id: const Uuid().v4(),
          commandeId: c.id,
          nom: nomCtrl.text.trim(),
          createdAt: horodatage,
          updatedAt: horodatage,
        ));
    await _outbox(db, 'projet', c.id);
    setState(() {});
  }

  Future<void> _outbox(MsnDatabase db, String type, String id) async {
    await db.into(db.syncOutbox).insert(SyncOutboxCompanion.insert(
          id: const Uuid().v4(),
          appareilId: db.appareilIdLocal,
          entiteType: type,
          entiteId: id,
          operation: 'upsert',
          payloadJson: '{"sync": true}',
          idempotencyKey: const Uuid().v4(),
          createdAt: DateTime.now().toUtc().toIso8601String(),
          updatedAt: DateTime.now().toUtc().toIso8601String(),
        ));
  }

  Future<String?> _demandeMotif(BuildContext context, String titre) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titre),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
              onPressed: () => ctrl.text.trim().isEmpty
                  ? null
                  : Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Confirmer')),
        ],
      ),
    );
  }
}
