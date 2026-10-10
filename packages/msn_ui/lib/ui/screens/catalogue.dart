// Catalogue : services, unités tarifaires, tarifs avec historique de validité.
// Modifier un tarif ne change JAMAIS les anciens devis (instantanés, spec §1 règle 5).
import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:msn_core/data/app_database.dart';
import 'package:uuid/uuid.dart';

import '../../state/providers.dart';

class CatalogueEcran extends ConsumerStatefulWidget {
  const CatalogueEcran({super.key});

  @override
  ConsumerState<CatalogueEcran> createState() => _CatalogueEcranState();
}

class _CatalogueEcranState extends ConsumerState<CatalogueEcran> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catalogue de services')),
      body: FutureBuilder<MsnDatabase>(
        future: ref.read(baseDeDonneesProvider.future),
        builder: (context, snapDb) {
          if (snapDb.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final db = snapDb.data!;
          return FutureBuilder<List<Service>>(
            future: (db.select(db.services)
                  ..where((t) => t.deletedAt.isNull())
                  ..orderBy([(t) => OrderingTerm.asc(t.categorie)]))
                .get(),
            builder: (context, snap) {
              final services = snap.data ?? const <Service>[];
              if (services.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Catalogue vide.'),
                      FilledButton(
                        onPressed: () => _importeCatalogue(context, ref, db),
                        child: const Text('Importer le catalogue initial'),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: services.length,
                itemBuilder: (context, i) => _carte(context, ref, db, services[i]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _carte(BuildContext context, WidgetRef ref, MsnDatabase db, Service s) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(s.nom),
        subtitle: Text('${s.categorie} · par ${s.uniteTarifaire} · '
            '${s.actif ? "actif" : "INACTIF"}'
            '${s.necessiteCahierCharges ? " · cahier des charges requis" : ""}'),
        children: [
          FutureBuilder<List<Tarif>>(
            future: (db.select(db.tarifs)
                  ..where((t) => t.serviceId.equals(s.id) & t.deletedAt.isNull())
                  ..orderBy([(t) => OrderingTerm.desc(t.dateDebutValidite)]))
                .get(),
            builder: (context, snap) {
              final tarifs = snap.data ?? const <Tarif>[];
              return Column(
                children: [
                  for (final t in tarifs)
                    ListTile(
                      dense: true,
                      leading: Icon(t.actif ? Icons.attach_money : Icons.money_off,
                          size: 18,
                          color: t.actif ? Colors.green : Colors.grey),
                      title: Text(
                          '${NumberFormat('#,###').format(t.prixUnitaire).replaceAll(',', ' ')} Ar / ${s.uniteTarifaire}'),
                      subtitle: Text(
                          'Validité : ${t.dateDebutValidite} → ${t.dateFinValidite ?? "en cours"}'),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Nouveau tarif'),
                          onPressed: () => _nouveauTarif(context, ref, db, s),
                        ),
                        OutlinedButton.icon(
                          icon: Icon(s.actif ? Icons.toggle_off : Icons.toggle_on),
                          label: Text(s.actif ? 'Désactiver' : 'Réactiver'),
                          onPressed: () async {
                            await (db.update(db.services)
                                  ..where((t) => t.id.equals(s.id)))
                                .write(ServicesCompanion(
                              actif: Value(!s.actif),
                              version: Value(s.version + 1),
                              updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
                            ));
                            await db.into(db.syncOutbox).insert(SyncOutboxCompanion.insert(
                                  id: const Uuid().v4(),
                                  appareilId: db.appareilIdLocal,
                                  entiteType: 'service',
                                  entiteId: s.id,
                                  operation: 'upsert',
                                  payloadJson: '{"actif": ${!s.actif}}',
                                  idempotencyKey: const Uuid().v4(),
                                  createdAt: DateTime.now().toUtc().toIso8601String(),
                                  updatedAt: DateTime.now().toUtc().toIso8601String(),
                                ));
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Nouveau tarif : clôt le tarif courant (historique conservé, anciens devis intacts).
  Future<void> _nouveauTarif(BuildContext context, WidgetRef ref, MsnDatabase db, Service s) async {
    final prixCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nouveau tarif — ${s.nom}'),
        content: TextField(
          controller: prixCtrl,
          keyboardType: TextInputType.number,
          decoration:
              const InputDecoration(labelText: 'Prix unitaire (Ar, entier) *'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
              onPressed: () =>
                  int.tryParse(prixCtrl.text) == null ? null : Navigator.pop(ctx, true),
              child: const Text('Enregistrer')),
        ],
      ),
    );
    if (ok != true) return;

    final horodatage = DateTime.now().toUtc().toIso8601String();
    final aujourdhui = horodatage.substring(0, 10);
    await db.transaction(() async {
      // Clôture du tarif courant (date_fin_validite = aujourd'hui)
      await (db.update(db.tarifs)
            ..where((t) => t.serviceId.equals(s.id) & t.dateFinValidite.isNull()))
          .write(TarifsCompanion(dateFinValidite: Value(aujourdhui)));
      await db.into(db.tarifs).insert(TarifsCompanion.insert(
            id: const Uuid().v4(),
            serviceId: s.id,
            prixUnitaire: int.parse(prixCtrl.text),
            dateDebutValidite: aujourdhui,
            createdAt: horodatage,
            updatedAt: horodatage,
          ));
      await db.into(db.syncOutbox).insert(SyncOutboxCompanion.insert(
            id: const Uuid().v4(),
            appareilId: db.appareilIdLocal,
            entiteType: 'tarif',
            entiteId: s.id,
            operation: 'upsert',
            payloadJson: '{"prix": ${prixCtrl.text}}',
            idempotencyKey: const Uuid().v4(),
            createdAt: horodatage,
            updatedAt: horodatage,
          ));
    });
    setState(() {});
  }

  /// Import du catalogue initial V1 (8 services de la spécification produit).
  Future<void> _importeCatalogue(BuildContext context, WidgetRef ref, MsnDatabase db) async {
    final catalogue = [
      ('SAISIE_DOC', 'Saisie et mise en forme de documents', 'Documents', 'page', 700, false),
      ('MISE_EN_PAGE_ACADEMIQUE', 'Mise en page académique (mémoires, thèses, rapports)', 'Documents', 'page', 1500, false),
      ('CV_LETTRE', 'CV et lettres professionnelles', 'Documents', 'document', 10000, false),
      ('TABLEAUX_PRESENTATIONS', 'Tableaux, graphiques et présentations', 'Bureautique', 'document', 15000, false),
      ('LOGO', 'Création de logo', 'Design graphique', 'projet', 80000, true),
      ('AFFICHE_BROCHURE', 'Affiches, brochures et cartes de visite', 'Design graphique', 'visuel', 25000, false),
      ('SITE_WEB', 'Services web et projets numériques', 'Web', 'projet', 250000, true),
      ('COM_FACEBOOK', 'Communication et planification Facebook', 'Communication', 'forfait_mensuel', 60000, false),
    ];
    final horodatage = DateTime.now().toUtc().toIso8601String();
    await db.transaction(() async {
      for (final (code, nom, cat, unite, prix, complexe) in catalogue) {
        final existant = await (db.select(db.services)
              ..where((t) => t.code.equals(code)))
            .getSingleOrNull();
        if (existant != null) continue;
        final id = const Uuid().v4();
        await db.into(db.services).insert(ServicesCompanion.insert(
              id: id,
              code: code,
              nom: nom,
              categorie: cat,
              uniteTarifaire: unite,
              necessiteCahierCharges: Value(complexe),
              createdAt: horodatage,
              updatedAt: horodatage,
            ));
        await db.into(db.tarifs).insert(TarifsCompanion.insert(
              id: const Uuid().v4(),
              serviceId: id,
              prixUnitaire: prix,
              dateDebutValidite: '2026-01-01',
              createdAt: horodatage,
              updatedAt: horodatage,
            ));
      }
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catalogue initial importé (services déjà présents ignorés).')));
    }
    setState(() {});
  }
}
