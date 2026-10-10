// Devis : préparation, présentation, acceptation → commande (spec §6.E-F).
// L'acceptation crée la commande UNE seule fois (idempotent côté serveur).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msn_core/data/app_database.dart';
import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:msn_core/domain/regles.dart';
import 'package:uuid/uuid.dart';

import '../../state/providers.dart';
import '../../state/tableaux_bord.dart';

class DevisEcran extends ConsumerStatefulWidget {
  const DevisEcran({super.key});

  @override
  ConsumerState<DevisEcran> createState() => _DevisEcranState();
}

class _DevisEcranState extends ConsumerState<DevisEcran> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devis')),
      body: FutureBuilder<MsnDatabase>(
        future: ref.read(baseDeDonneesProvider.future),
        builder: (context, snapDb) {
          if (snapDb.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final db = snapDb.data!;
          return FutureBuilder<List<Devis>>(
            future: (db.select(db.devis)
                  ..where((t) => t.deletedAt.isNull())
                  ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
                .get(),
            builder: (context, snap) {
              final devis = snap.data ?? const <Devis>[];
              if (devis.isEmpty) {
                return const Center(
                    child: Text('Aucun devis. Préparez-en un depuis une demande.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: devis.length,
                itemBuilder: (context, i) => _carte(context, ref, db, devis[i]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _carte(BuildContext context, WidgetRef ref, MsnDatabase db, Devis dv) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          switch (dv.statut) {
            'accepte' => Icons.check_circle,
            'refuse' => Icons.cancel,
            'presente' => Icons.outgoing_mail,
            'remplace' => Icons.history,
            _ => Icons.drafts,
          },
          color: switch (dv.statut) {
            'accepte' => Colors.green,
            'refuse' => Colors.red,
            'presente' => Colors.blue,
            _ => null,
          },
        ),
        title: Text('${dv.numero} — révision ${dv.revision}'),
        subtitle: Text(
            '${LibellesStatuts.devisStatut(dv.statut)} · total ${formatMga(dv.totalHt)}'),
        trailing: dv.statut == 'presente'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    child: const Text('Accepter'),
                    onPressed: () => _accepter(context, ref, db, dv),
                  ),
                  TextButton(
                    child: const Text('Refuser'),
                    onPressed: () => _refuser(context, ref, db, dv),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  /// Acceptation + confirmation de poursuite → commande créée UNE fois.
  Future<void> _accepter(BuildContext context, WidgetRef ref, MsnDatabase db, Devis dv) async {
    final poursuit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Le client accepte le devis ?'),
        content: const Text(
            'La confirmation crée la commande à partir des lignes du devis. '
            'L\'opération est idempotente : la répéter ne crée jamais de doublon.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmer et créer la commande')),
        ],
      ),
    );
    if (poursuit != true) return;

    final horodatage = DateTime.now().toUtc().toIso8601String();
    await db.transaction(() async {
      // Devis accepté + rattaché à la commande
      await (db.update(db.devis)..where((t) => t.id.equals(dv.id))).write(
        DevisTableCompanion(
          statut: const Value('accepte'),
          accepteAt: Value(horodatage),
          version: Value(dv.version + 1),
        ),
      );
      // Idempotence locale : la commande existe déjà ?
      final existante = await (db.select(db.commandes)
            ..where((t) => t.demandeId.equals(dv.demandeId)))
          .getSingleOrNull();
      if (existante != null) return; // jamais de doublon (spec §6.F)

      final numero = 'CMD-${DateTime.now().year}-'
          '${DateTime.now().millisecondsSinceEpoch % 10000}';
      final commandeId = const Uuid().v4();
      await db.into(db.commandes).insert(CommandesCompanion.insert(
            id: commandeId,
            numero: numero,
            demandeId: dv.demandeId,
            dateConfirmation: Value(horodatage),
            createdAt: horodatage,
            updatedAt: horodatage,
          ));
      await (db.update(db.devis)..where((t) => t.id.equals(dv.id)))
          .write(DevisTableCompanion(commandeId: Value(commandeId)));
      // Lignes de commande = instantané des lignes du devis (prix figés)
      final lignes = await (db.select(db.lignesDevis)
            ..where((t) => t.devisId.equals(dv.id)))
          .get();
      for (final l in lignes) {
        await db.into(db.lignesCommande).insert(LignesCommandeCompanion.insert(
              id: const Uuid().v4(),
              commandeId: commandeId,
              serviceId: Value(l.serviceId),
              description: l.description,
              quantite: l.quantite,
              uniteSnapshot: l.uniteSnapshot,
              prixUnitaire: l.prixUnitaire,
              createdAt: horodatage,
              updatedAt: horodatage,
            ));
      }
      // Opérations d'outbox (devis + commande) — même transaction
      for (final (type, eid) in [('devis', dv.id), ('commande', commandeId)]) {
        await db.into(db.syncOutbox).insert(SyncOutboxCompanion.insert(
              id: const Uuid().v4(),
              appareilId: db.appareilIdLocal,
              entiteType: type,
              entiteId: eid,
              operation: 'upsert',
              payloadJson: '{"sync": true}',
              idempotencyKey: const Uuid().v4(),
              createdAt: horodatage,
              updatedAt: horodatage,
            ));
      }
    });

    ref.invalidate(resumeTableauBordProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Devis accepté — commande créée (une seule fois).')));
      setState(() {});
    }
  }

  Future<void> _refuser(BuildContext context, WidgetRef ref, MsnDatabase db, Devis dv) async {
    await (db.update(db.devis)..where((t) => t.id.equals(dv.id))).write(
      DevisTableCompanion(
        statut: const Value('refuse'),
        version: Value(dv.version + 1),
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );
    setState(() {});
  }
}
