// Journal d'audit local : opérations importantes tracées (spec §9 règle 14).
import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:msn_core/data/app_database.dart';

import '../../state/providers.dart';

class JournalAuditEcran extends ConsumerWidget {
  const JournalAuditEcran({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal d\'audit')),
      body: FutureBuilder<MsnDatabase>(
        future: ref.read(baseDeDonneesProvider.future),
        builder: (context, snapDb) {
          if (snapDb.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final db = snapDb.data!;
          return FutureBuilder<List<JournalAction>>(
            future: (db.select(db.journalActions)
                  ..orderBy([(t) => OrderingTerm.desc(t.dateAction)])
                  ..limit(500))
                .get(),
            builder: (context, snap) {
              final lignes = snap.data ?? const <JournalAction>[];
              if (lignes.isEmpty) {
                return const Center(
                    child: Text('Aucun événement — les opérations importantes sont tracées ici.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: lignes.length,
                itemBuilder: (context, i) {
                  final j = lignes[i];
                  final date = DateTime.tryParse(j.dateAction);
                  return ListTile(
                    dense: true,
                    leading: Icon(switch (j.action) {
                      'creation' => Icons.add_circle_outline,
                      'livraison' => Icons.local_shipping,
                      'transition' => Icons.rule,
                      'suppression_logique' => Icons.delete_outline,
                      'acceptation' => Icons.thumb_up_outlined,
                      _ => Icons.notes,
                    }),
                    title: Text('${j.action} — ${j.entiteType}'),
                    subtitle: Text(
                        '${date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : j.dateAction} · '
                        'entité ${j.entiteId.substring(0, 8)}…'
                        '${j.motif != null ? ' · ${j.motif}' : ''}'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
