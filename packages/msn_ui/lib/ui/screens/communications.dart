// Communications : préparation depuis un modèle, copie, confirmation manuelle.
// Préparé/copié ≠ envoyé — l'envoi manuel est une action explicite (spec §6).
import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msn_core/data/app_database.dart';
import 'package:msn_core/domain/regles.dart';
import 'package:uuid/uuid.dart';

import '../../state/providers.dart';

class CommunicationsEcran extends ConsumerStatefulWidget {
  const CommunicationsEcran({super.key});

  @override
  ConsumerState<CommunicationsEcran> createState() => _CommunicationsEcranState();
}

class _CommunicationsEcranState extends ConsumerState<CommunicationsEcran> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages et communications')),
      body: FutureBuilder<MsnDatabase>(
        future: ref.read(baseDeDonneesProvider.future),
        builder: (context, snapDb) {
          if (snapDb.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final db = snapDb.data!;
          return FutureBuilder<List<Echange>>(
            future: (db.select(db.echanges)
                  ..where((t) => t.deletedAt.isNull())
                  ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
                .get(),
            builder: (context, snap) {
              final echanges = snap.data ?? const <Echange>[];
              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Préparer un message depuis un modèle'),
                    onPressed: () => _prepare(context, ref, db),
                  ),
                  const SizedBox(height: 12),
                  if (echanges.isEmpty)
                    const Center(child: Text('Aucun échange enregistré.')),
                  for (final e in echanges) _carte(context, ref, db, e),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _carte(BuildContext context, WidgetRef ref, MsnDatabase db, Echange e) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(switch (e.statutEnvoi) {
          'envoi_manuel_confirme' => Icons.check_circle,
          'copiee' => Icons.copy_all,
          'echec' => Icons.error,
          _ => Icons.drafts,
        }),
        title: Text(e.contenu, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
            '${e.canal} · ${e.direction} · ${LibellesStatuts.echangeStatut(e.statutEnvoi)}'),
        trailing: _actions(context, ref, db, e),
      ),
    );
  }

  Widget? _actions(BuildContext context, WidgetRef ref, MsnDatabase db, Echange e) {
    return switch (e.statutEnvoi) {
      'brouillon' || 'prete' || 'echec' || 'copiee' => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Copier le texte',
              icon: const Icon(Icons.copy),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: e.contenu));
                // COPIER ≠ ENVOYER (spec §10.E30)
                if (e.statutEnvoi != 'copiee') {
                  await (db.update(db.echanges)..where((t) => t.id.equals(e.id)))
                      .write(EchangesCompanion(
                    statutEnvoi: const Value('copiee'),
                    dateCopie: Value(DateTime.now().toUtc().toIso8601String()),
                    version: Value(e.version + 1),
                    updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
                  ));
                  setState(() {});
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Texte copié — collez-le dans le canal externe, puis confirmez l\'envoi manuel.')));
                }
              },
            ),
            IconButton(
              tooltip: 'Confirmer l\'envoi manuel',
              icon: const Icon(Icons.mark_email_read),
              onPressed: () async {
                final confirme = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirmer l\'envoi manuel ?'),
                    content: const Text(
                        'Confirmez UNIQUEMENT si vous avez réellement envoyé le message '
                        'via le canal externe. Cette action est historisée.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Non')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Oui, envoyé')),
                    ],
                  ),
                );
                if (confirme != true) return;
                await (db.update(db.echanges)..where((t) => t.id.equals(e.id))).write(
                  EchangesCompanion(
                    statutEnvoi: const Value('envoi_manuel_confirme'),
                    dateEnvoiConfirme: Value(DateTime.now().toUtc().toIso8601String()),
                    version: Value(e.version + 1),
                    updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
                  ),
                );
                setState(() {});
              },
            ),
          ],
        ),
      _ => null,
    };
  }

  /// Prépare un message à partir d'un modèle local : variables connues remplies,
  /// inconnues laissées visibles. Le texte reste MODIFIABLE (spec §6.C).
  Future<void> _prepare(BuildContext context, WidgetRef ref, MsnDatabase db) async {
    final modeles = await (db.select(db.modelesMessages)
          ..where((t) => t.actif.equals(true) & t.deletedAt.isNull()))
        .get();
    if (!context.mounted) return;
    final modele = await showDialog<ModelesMessage>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Choisir un modèle'),
        children: [
          for (final m in modeles)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, m),
              child: Text(m.nom),
            ),
        ],
      ),
    );
    if (modele == null) return;

    final texteCtrl = TextEditingController(text: modele.corpsTemplate);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(modele.nom),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Les variables {xxx} restent visibles : complétez-les. Le texte est modifiable '
                'sans modifier le modèle global (spec §10.E29).'),
            TextField(
                controller: texteCtrl,
                maxLines: 8,
                decoration: const InputDecoration(labelText: 'Texte du message')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Enregistrer en brouillon')),
        ],
      ),
    );
    if (ok != true) return;

    final horodatage = DateTime.now().toUtc().toIso8601String();
    await db.into(db.echanges).insert(EchangesCompanion.insert(
          id: const Uuid().v4(),
          clientId: 'sans-client', // à rattacher : sélection client requise en V1.1
          canal: modele.canal,
          direction: 'sortant',
          contenu: texteCtrl.text,
          modeleId: Value(modele.id),
          statutEnvoi: const Value('prete'),
          datePreparation: Value(horodatage),
          createdAt: horodatage,
          updatedAt: horodatage,
        ));
    setState(() {});
  }
}
