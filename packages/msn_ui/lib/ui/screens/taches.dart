// Tâches de production : échéances, priorités, transitions simples.
import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msn_core/data/app_database.dart';
import 'package:msn_core/domain/regles.dart';
import 'package:uuid/uuid.dart';

import '../../state/providers.dart';
import '../../state/tableaux_bord.dart';

class TachesEcran extends ConsumerStatefulWidget {
  const TachesEcran({super.key});

  @override
  ConsumerState<TachesEcran> createState() => _TachesEcranState();
}

class _TachesEcranState extends ConsumerState<TachesEcran> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tâches de production')),
      body: FutureBuilder<MsnDatabase>(
        future: ref.read(baseDeDonneesProvider.future),
        builder: (context, snapDb) {
          if (snapDb.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final db = snapDb.data!;
          return FutureBuilder<List<Tache>>(
            future: (db.select(db.taches)
                  ..where((t) => t.deletedAt.isNull())
                  ..orderBy([
                    (t) => OrderingTerm.asc(t.echeance),
                    (t) => OrderingTerm.desc(t.createdAt),
                  ]))
                .get(),
            builder: (context, snap) {
              final taches = snap.data ?? const <Tache>[];
              if (taches.isEmpty) {
                return const Center(child: Text('Aucune tâche enregistrée.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: taches.length,
                itemBuilder: (context, i) => _ligne(context, ref, db, taches[i]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _ligne(BuildContext context, WidgetRef ref, MsnDatabase db, Tache t) {
    final urgente = t.priorite == 'urgente' || t.priorite == 'haute';
    return CheckboxListTile(
      value: t.statut == 'terminee',
      onChanged: t.statut == 'terminee'
          ? null
          : (_) async {
              await (db.update(db.taches)..where((x) => x.id.equals(t.id))).write(
                TachesCompanion(
                  statut: const Value('terminee'),
                  termineeAt:
                      Value(DateTime.now().toUtc().toIso8601String()),
                  updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
                  version: Value(t.version + 1),
                ),
              );
              await db.into(db.syncOutbox).insert(SyncOutboxCompanion.insert(
                    id: const Uuid().v4(),
                    appareilId: db.appareilIdLocal,
                    entiteType: 'tache',
                    entiteId: t.id,
                    operation: 'upsert',
                    payloadJson: '{"sync": true}',
                    idempotencyKey: const Uuid().v4(),
                    createdAt: DateTime.now().toUtc().toIso8601String(),
                    updatedAt: DateTime.now().toUtc().toIso8601String(),
                  ));
              ref.invalidate(resumeTableauBordProvider);
              setState(() {});
            },
      title: Text(t.titre,
          style: TextStyle(
              decoration: t.statut == 'terminee' ? TextDecoration.lineThrough : null)),
      subtitle: Text([
        if (t.echeance != null) 'Échéance : ${t.echeance!.substring(0, 10)}',
        LibellesStatuts.commandeStatut(t.statut) == t.statut ? t.statut : t.statut,
      ].join(' · ')),
      secondary: urgente
          ? const Icon(Icons.priority_high, color: Colors.red)
          : const Icon(Icons.radio_button_unchecked),
    );
  }
}
