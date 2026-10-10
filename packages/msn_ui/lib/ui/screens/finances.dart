// Finances : factures, paiements, dépenses, synthèse. Statuts CALCULÉS (spec §6.H).
// Seuls les paiements confirmés réduisent le solde.
import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:msn_core/data/app_database.dart';
import 'package:msn_core/domain/regles.dart';
import 'package:uuid/uuid.dart';

import '../../state/providers.dart';
import '../../state/tableaux_bord.dart';

class FinancesEcran extends ConsumerStatefulWidget {
  const FinancesEcran({super.key});

  @override
  ConsumerState<FinancesEcran> createState() => _FinancesEcranState();
}

class _FinancesEcranState extends ConsumerState<FinancesEcran> {
  int _onglet = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Finances'),
          bottom: TabBar(
            onTap: (i) => setState(() => _onglet = i),
            tabs: const [
              Tab(text: 'Factures'),
              Tab(text: 'Paiements'),
              Tab(text: 'Dépenses'),
            ],
          ),
        ),
        body: FutureBuilder<MsnDatabase>(
          future: ref.read(baseDeDonneesProvider.future),
          builder: (context, snapDb) {
            if (snapDb.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final db = snapDb.data!;
            return TabBarView(children: [
              _factures(context, ref, db),
              _paiements(context, ref, db),
              _depenses(context, ref, db),
            ]);
          },
        ),
      ),
    );
  }

  // ——— FACTURES ———
  Widget _factures(BuildContext context, WidgetRef ref, MsnDatabase db) {
    return FutureBuilder<List<Facture>>(
      future: (db.select(db.factures)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get(),
      builder: (context, snap) {
        final factures = snap.data ?? const <Facture>[];
        if (factures.isEmpty) {
          return const Center(child: Text('Aucune facture.'));
        }
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final f in factures) _carteFacture(context, ref, db, f),
          ],
        );
      },
    );
  }

  Widget _carteFacture(BuildContext context, WidgetRef ref, MsnDatabase db, Facture f) {
    return FutureBuilder<List<Paiement>>(
      future: (db.select(db.paiements)
            ..where((t) => t.factureId.equals(f.id) & t.deletedAt.isNull()))
          .get(),
      builder: (context, snap) {
        final paiements = snap.data ?? const <Paiement>[];
        final solde = soldeFacture(
          totalFacture: f.total,
          paiements: [
            for (final p in paiements)
              {'statut': p.statut, 'montant': p.montant, 'deleted_at': p.deletedAt},
          ],
        );
        final statutCalcule = statutFinancierCalcule(f.total, [
          for (final p in paiements)
            {'statut': p.statut, 'montant': p.montant, 'deleted_at': p.deletedAt},
        ]);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(f.numero, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Chip(label: Text(LibellesStatuts.factureStatut(statutCalcule))),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Total : ${formatMga(f.total)} · Solde dû : ${formatMga(solde)}'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    if (f.statut == 'brouillon')
                      FilledButton(
                        onPressed: () => _emet(context, ref, db, f),
                        child: const Text('Émettre'),
                      ),
                    if (solde > 0 && f.statut != 'annulee')
                      OutlinedButton.icon(
                        icon: const Icon(Icons.add_card),
                        label: const Text('Enregistrer un paiement'),
                        onPressed: () => _paiement(context, ref, db, f, solde),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _emet(BuildContext context, WidgetRef ref, MsnDatabase db, Facture f) async {
    await (db.update(db.factures)..where((t) => t.id.equals(f.id))).write(
      FacturesCompanion(
        statut: const Value('emise'),
        dateEmission: Value(DateTime.now().toUtc().toIso8601String().substring(0, 10)),
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
        version: Value(f.version + 1),
      ),
    );
    await db.into(db.syncOutbox).insert(SyncOutboxCompanion.insert(
          id: const Uuid().v4(),
          appareilId: db.appareilIdLocal,
          entiteType: 'facture',
          entiteId: f.id,
          operation: 'upsert',
          payloadJson: '{"sync": true}',
          idempotencyKey: const Uuid().v4(),
          createdAt: DateTime.now().toUtc().toIso8601String(),
          updatedAt: DateTime.now().toUtc().toIso8601String(),
        ));
    setState(() {});
  }

  Future<void> _paiement(BuildContext context, WidgetRef ref, MsnDatabase db,
      Facture f, int solde) async {
    final montantCtrl = TextEditingController(text: '$solde');
    String moyen = 'mobile_money';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Paiement — ${f.numero}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: montantCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Montant (solde : ${formatMga(solde)})'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: moyen,
                items: const [
                  DropdownMenuItem(value: 'especes', child: Text('Espèces')),
                  DropdownMenuItem(value: 'mobile_money', child: Text('Mobile Money')),
                  DropdownMenuItem(value: 'virement', child: Text('Virement')),
                  DropdownMenuItem(value: 'autre', child: Text('Autre')),
                ],
                onChanged: (v) => setState(() => moyen = v ?? 'especes'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
            FilledButton(
              onPressed: () {
                final montant = int.tryParse(montantCtrl.text);
                if (montant == null || montant <= 0 || montant > solde) return null;
                return Navigator.pop(ctx, true);
              },
              child: const Text('Confirmer (confirmé)'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;

    final montant = int.parse(montantCtrl.text);
    final horodatage = DateTime.now().toUtc().toIso8601String();
    // Idempotence : clé unique locale ; une répétition ne compte jamais deux fois
    final cle = 'paiement-${f.id}-$montant-$horodatage'.hashCode.toString();
    final existant = await (db.select(db.paiements)
          ..where((t) => t.idempotencyKey.equals(cle)))
        .getSingleOrNull();
    if (existant != null) return;

    await db.transaction(() async {
      await db.into(db.paiements).insert(PaiementsCompanion.insert(
            id: const Uuid().v4(),
            factureId: f.id,
            montant: montant,
            datePaiement: horodatage.substring(0, 10),
            moyen: moyen,
            statut: const Value('confirme'),
            idempotencyKey: Value(cle),
            createdAt: horodatage,
            updatedAt: horodatage,
          ));
      await _outbox(db, 'paiement', f.id);
    });
    ref.invalidate(resumeTableauBordProvider);
    setState(() {});
  }

  // ——— PAIEMENTS ———
  Widget _paiements(BuildContext context, WidgetRef ref, MsnDatabase db) {
    return FutureBuilder<List<Paiement>>(
      future: (db.select(db.paiements)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get(),
      builder: (context, snap) {
        final paiements = snap.data ?? const <Paiement>[];
        if (paiements.isEmpty) {
          return const Center(child: Text('Aucun paiement enregistré.'));
        }
        final fmt = NumberFormat('#,###');
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final p in paiements)
              ListTile(
                leading: Icon(
                  p.statut == 'confirme'
                      ? Icons.check_circle
                      : p.statut == 'annule'
                          ? Icons.cancel
                          : Icons.hourglass_top,
                  color: p.statut == 'confirme'
                      ? Colors.green
                      : p.statut == 'annule'
                          ? Colors.red
                          : Colors.grey,
                ),
                title: Text('${fmt.format(p.montant).replaceAll(',', ' ')} Ar — ${p.moyen}'),
                subtitle: Text('${p.datePaiement} · ${p.statut}'),
              ),
          ],
        );
      },
    );
  }

  // ——— DÉPENSES ———
  Widget _depenses(BuildContext context, WidgetRef ref, MsnDatabase db) {
    return FutureBuilder<List<Depense>>(
      future: (db.select(db.depenses)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.dateDepense)]))
          .get(),
      builder: (context, snap) {
        final depenses = snap.data ?? const <Depense>[];
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (depenses.isEmpty)
              const Center(child: Text('Aucune dépense.')),
            for (final d in depenses)
              ListTile(
                leading: const Icon(Icons.shopping_cart_outlined),
                title: Text('${d.description} (${d.categorie})'),
                subtitle: Text('${d.dateDepense} · ${d.moyen}'),
                trailing: Text(
                    '${NumberFormat('#,###').format(d.montant).replaceAll(',', ' ')} Ar'),
              ),
          ],
        );
      },
    );
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
}
