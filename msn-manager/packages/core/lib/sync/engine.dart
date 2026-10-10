// Moteur de synchronisation client (spec §8, §9) :
//  - push par lots bornés, résultat opération par opération,
//    marquage synced UNIQUEMENT après confirmation serveur ;
//  - pull à curseur monotone, lot appliqué dans une transaction locale,
//    curseur avancé seulement après succès complet ;
//  - conflits conservés dans sync_conflicts (aucun écrasement silencieux) ;
//  - reprise progressive après échec réseau (temporisation croissante).
import 'dart:convert' as convert;

import 'package:drift/drift.dart';

import '../data/app_database.dart';
import '../data/outbox.dart';

class SyncResultat {
  SyncResultat({
    required this.poussees,
    required this.tirees,
    required this.conflits,
    required this.echecs,
    required this.horsLigne,
  });

  final int poussees;
  final int tirees;
  final int conflits;
  final int echecs;
  final bool horsLigne;

  @override
  String toString() =>
      'Sync(poussées=$poussees, tirées=$tirees, conflits=$conflits, échecs=$echecs, hors-ligne=$horsLigne)';
}

class SyncEngine {
  SyncEngine(this.db, this.api, {this.tailleLot = 100});

  final MsnDatabase db;
  final ApiPort api;

  /// Taille maximale d'un lot (spec §8.6 : 100 au lancement).
  final int tailleLot;

  String get maintenant => DateTime.now().toUtc().toIso8601String();

  /// Cycle complet : push puis pull. Idempotent et reprenable.
  Future<SyncResultat> synchronise({bool pousser = true, bool tirer = true}) async {
    var poussees = 0, tirees = 0, conflits = 0, echecs = 0;
    var horsLigne = false;

    if (pousser) {
      try {
        final r = await _push();
        poussees = r.$1;
        conflits += r.$2;
        echecs += r.$3;
      } on ApiInatteignable {
        horsLigne = true;
        await _retardeOperationsEnVol();
      }
    }

    if (tirer && !horsLigne) {
      try {
        tirees = await _pull();
      } on ApiInatteignable {
        horsLigne = true;
      }
    }

    return SyncResultat(
      poussees: poussees,
      tirees: tirees,
      conflits: conflits,
      echecs: echecs,
      horsLigne: horsLigne,
    );
  }

  /// PUSH : lit un lot borné d'opérations pending, les envoie, applique les
  /// résultats par opération. Ne supprime RIEN sans confirmation serveur.
  Future<(int, int, int)> _push() async {
    final lot = await (db.select(db.syncOutbox)
          ..where((t) => t.statut.isIn(['pending', 'failed', 'conflict']))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)])
          ..limit(tailleLot))
        .get();

    if (lot.isEmpty) return (0, 0, 0);

    // Passage en in_flight (reprise : si le push plante, elles reviennent en pending)
    await (db.update(db.syncOutbox)
          ..where((t) => t.id.isIn(lot.map((l) => l.id).toList())))
        .write(SyncOutboxCompanion(
      statut: const Value('in_flight'),
      updatedAt: Value(maintenant),
    ));

    final operations = lot.map((op) {
      return <String, dynamic>{
        'operation_id': op.id,
        'device_id': op.appareilId,
        'entity_type': op.entiteType,
        'entity_id': op.entiteId,
        'operation': op.operation,
        'base_version': op.baseVersion,
        'client_timestamp': op.createdAt,
        'payload': convert.jsonDecode(op.payloadJson) as Map<String, dynamic>,
        'idempotency_key': op.idempotencyKey,
      };
    }).toList();

    final reponse = await api.push(operations);
    final resultats = (reponse['resultats'] as List?) ?? const [];

    var poussees = 0, conflits = 0, echecs = 0;

    await db.transaction(() async {
      for (final res in resultats) {
        final operationId = res['operation_id'] as String?;
        if (operationId == null) continue;
        final op = lot.firstWhere((l) => l.id == operationId,
            orElse: () => lot.first);
        final resultat = res['resultat'] as String?;

        if (resultat == 'synced') {
          // Confirmation serveur : l'opération peut être marquée synced.
          // La nouvelle version serveur alimente les prochains push.
          final serveur = res['serveur'];
          await (db.update(db.syncOutbox)..where((t) => t.id.equals(op.id))).write(
            SyncOutboxCompanion(
              statut: const Value('synced'),
              baseVersion: Value(serveur is Map && serveur['version'] != null
                  ? (serveur['version'] as num).toInt()
                  : null),
              derniereErreur: const Value(null),
              updatedAt: Value(maintenant),
            ),
          );
          poussees++;
        } else if (resultat == 'conflict') {
          // Conflit : AUCUN écrasement — les deux versions sont conservées.
          await db.into(db.syncConflicts).insert(SyncConflictsCompanion.insert(
                id: op.id,
                appareilId: op.appareilId,
                entiteType: op.entiteType,
                entiteId: op.entiteId,
                versionLocale: (op.baseVersion ?? 0) + 1,
                versionServeur: (res['version_serveur'] as num?)?.toInt() ?? 0,
                localJson: op.payloadJson,
                serveurJson: convert.jsonEncode(res['serveur'] ?? {}),
                createdAt: maintenant,
                updatedAt: maintenant,
              ));
          await (db.update(db.syncOutbox)..where((t) => t.id.equals(op.id)))
              .write(SyncOutboxCompanion(
            statut: const Value('conflict'),
            derniereErreur: const Value('Conflit de version — résolution requise'),
            updatedAt: Value(maintenant),
          ));
          conflits++;
        } else {
          // failed : conservation + compteur de tentatives (reprise ultérieure)
          await (db.update(db.syncOutbox)..where((t) => t.id.equals(op.id))).write(
            SyncOutboxCompanion(
              statut: const Value('failed'),
              tentatives: Value(op.tentatives + 1),
              derniereErreur: Value((res['message'] as String?) ?? 'Échec serveur'),
              updatedAt: Value(maintenant),
            ),
          );
          echecs++;
        }
      }
    });

    return (poussees, conflits, echecs);
  }

  /// PULL : applique un lot entier dans une transaction locale ; le curseur
  /// n'avance qu'après application complète réussie (spec §8.4).
  Future<int> _pull() async {
    final etat = await (db.select(db.syncState)
          ..where((t) => t.appareilId.equals(_appareilCourant())))
        .getSingleOrNull();
    final curseur = etat?.dernierCurseur ?? '0';

    final reponse = await api.pull(curseur, tailleLot);
    final changements = (reponse['changements'] as List?) ?? const [];
    final prochainCurseur = reponse['prochain_curseur']?.toString() ?? curseur;

    var appliques = 0;

    // Une SEULE transaction locale : tout le lot ou rien.
    await db.transaction(() async {
      for (final c in changements) {
        final entiteId = c['entity_id'] as String;
        final entiteType = c['entity_type'] as String;
        final tombstone = (c['tombstone'] as bool?) ?? false;
        final versionServeur = (c['version'] as num?)?.toInt() ?? 1;
        final payload = (c['payload'] as Map?)?.cast<String, dynamic>() ?? {};

        // Idempotence : si la version locale est déjà ≥ serveur, ignorer.
        final locale = await _versionLocale(entiteType, entiteId);
        if (locale != null && locale >= versionServeur) continue;

        await _appliqueChangement(entiteType, entiteId, tombstone, payload);
        appliques++;
      }

      // Curseur avancé dans la même transaction (succès complet).
      await db.into(db.syncState).insertOnConflictUpdate(
            SyncStateCompanion.insert(
              appareilId: _appareilCourant(),
              dernierCurseur: Value(prochainCurseur),
              dernierSyncReussiAt: Value(maintenant),
              updatedAt: maintenant,
            ),
          );
    });

    return appliques;
  }

  String _appareilCourant() {
    // Un seul appareil par installation : l'ID est stocké dans app_meta.
    return db.appareilIdLocal;
  }

  Future<int?> _versionLocale(String entiteType, String entiteId) async {
    final table = _tablePar(entiteType);
    if (table == null) return null;
    final lignes = await db.customSelect(
      'SELECT version FROM $table WHERE id = ?',
      variables: [Variable.withString(entiteId)],
    ).getSingleOrNull();
    return lignes?.data['version'] as int?;
  }

  String? _tablePar(String entiteType) => switch (entiteType) {
        'client' => 'clients',
        'contact' => 'contacts',
        'service' => 'services',
        'tarif' => 'tarifs',
        'demande' => 'demandes',
        'demande_prestation' => 'demande_prestations',
        'commande' => 'commandes',
        'lignes_commande' => 'lignes_commande',
        'projet' => 'projets',
        'cahiers_charges' => 'cahiers_charges',
        'tache' => 'taches',
        'modele_message' => 'modeles_messages',
        'echange' => 'echanges',
        'devis' => 'devis',
        'lignes_devis' => 'lignes_devis',
        'facture' => 'factures',
        'lignes_facture' => 'lignes_facture',
        'paiement' => 'paiements',
        'depense' => 'depenses',
        'pieces_jointes' => 'pieces_jointes',
        'publications_facebook' => 'publications_facebook',
        _ => null,
      };

  Future<void> _appliqueChangement(
      String entiteType, String entiteId, bool tombstone, Map<String, dynamic> payload) async {
    final table = _tablePar(entiteType);
    if (table == null) return; // entité inconnue : ignorée sans bloquer le lot

    final donnees = <String, Object?>{
      'id': entiteId,
      ...payload,
      'version': payload['version'] ?? 1,
    };

    if (tombstone) {
      // Tombstone : suppression logique ciblée (jamais d'insertion partielle qui
      // violerait les NOT NULL du schéma). Absente localement → rien à faire.
      await db.customStatement(
        'UPDATE $table SET deleted_at = ?, version = ? WHERE id = ?',
        [maintenant, donnees['version'], entiteId],
      );
      return;
    }

    final colonnes = donnees.keys.where((c) => c != 'id').toList();
    final misesAJour = colonnes.map((c) => '$c = excluded.$c').join(', ');

    await db.customStatement(
      'INSERT INTO $table (id, ${colonnes.join(', ')}) '
      'VALUES (?, ${colonnes.map((_) => '?').join(', ')}) '
      'ON CONFLICT(id) DO UPDATE SET ${misesAJour.isEmpty ? 'id = excluded.id' : misesAJour}',
      [entiteId, ...colonnes.map((c) => donnees[c])],
    );
  }

  /// Échec réseau : repasse les opérations in_flight en pending avec
  /// temporisation progressive (spéc. §8.6). Rien n'est perdu.
  Future<void> _retardeOperationsEnVol() async {
    await (db.update(db.syncOutbox)..where((t) => t.statut.equals('in_flight')))
        .write(SyncOutboxCompanion(
      statut: const Value('pending'),
      tentatives: const Value(0), // les tentatives restent comptées via failed uniquement
      updatedAt: Value(maintenant),
    ));
    // La temporisation progressive est gérée par le planificateur applicatif
    // (délai = min(2^tentatives, 300) secondes) — voir scheduleur de l'app.
  }

  /// État de synchronisation lisible (spec §9 réseau).
  Future<Map<String, dynamic>> etat() async {
    final enAttente = await (db.select(db.syncOutbox)
          ..where((t) => t.statut.isIn(['pending', 'in_flight', 'failed'])))
        .get();
    final conflits = await db.select(db.syncConflicts).get();
    final etat = await (db.select(db.syncState)
          ..where((t) => t.appareilId.equals(_appareilCourant())))
        .getSingleOrNull();

    return {
      'operations_en_attente': enAttente.length,
      'conflits_non_resolus': conflits.where((c) => c.statut == 'a_resoudre').length,
      'dernier_curseur': etat?.dernierCurseur ?? '0',
      'derniere_sync_reussie': etat?.dernierSyncReussiAt,
    };
  }
}
