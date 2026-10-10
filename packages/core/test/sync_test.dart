// Tests du moteur de synchronisation avec API factice :
// idempotence, reprise après coupure réseau, conflits de version, curseur pull.
// Référence : spéc. MSN Manager V1 §10.F33-F42.
import 'dart:convert' as convert;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:msn_core/data/app_database.dart';
import 'package:msn_core/data/outbox.dart';
import 'package:msn_core/sync/engine.dart';
import 'package:test/test.dart';

import 'aide.dart';

/// API factice pilotée par scénario.
class ApiFausse implements ApiPort {
  ApiFausse();

  /// Opérations reçues (pour compter les répétitions).
  final List<Map<String, dynamic>> pushesRecus = [];

  /// Réponses programmées par idempotency_key.
  final Map<String, Map<String, dynamic>> reponsesParCle = {};

  /// Historique des opérations « déjà traitées » côté serveur (idempotence).
  final Set<String> clesTraitees = {};

  /// Curseur serveur et changements à servir.
  List<Map<String, dynamic>> changementsServeur = [];
  String curseurServeur = '0';

  /// Scénario : lever une coupure réseau au prochain push/pull.
  bool couperReseau = false;

  int pushCount = 0;
  int pullCount = 0;

  @override
  Future<Map<String, dynamic>> push(List<Map<String, dynamic>> operations) async {
    pushCount++;
    if (couperReseau) throw ApiInatteignable('réseau coupé (scénario)');
    final resultats = <Map<String, dynamic>>[];
    for (final op in operations) {
      final cle = op['idempotency_key'] as String;
      pushesRecus.add(op);
      if (clesTraitees.contains(cle)) {
        // Idempotence serveur : résultat précédent renvoyé (spéc. §8.3 point 3)
        resultats.add(reponsesParCle[cle] ?? {
          'operation_id': op['operation_id'], 'resultat': 'synced',
        });
        continue;
      }
      clesTraitees.add(cle);
      final reponse = reponsesParCle[cle] ??
          {
            'operation_id': op['operation_id'],
            'resultat': 'synced',
            'version': (op['base_version'] as int? ?? 0) + 1,
            'serveur': {...op['payload'], 'version': 1},
          };
      resultats.add(reponse);
    }
    return {'resultats': resultats};
  }

  @override
  Future<Map<String, dynamic>> pull(String curseur, int limite) async {
    pullCount++;
    if (couperReseau) throw ApiInatteignable('réseau coupé (scénario)');
    final lot = changementsServeur
        .where((c) => (c['seq'] as int) > int.parse(curseur))
        .take(limite)
        .toList();
    final prochain = lot.isEmpty
        ? curseur
        : (lot.last['seq'] as int).toString();
    return {
      'changements': lot,
      'prochain_curseur': prochain,
      'a_suivre': false,
    };
  }
}

void main() {
  group('Push (spéc. §8.3, §10.F34, F37, F38)', () {
    test('opération confirmée → statut synced, envoi UNE seule fois (F34/F37)', () async {
      final db = await baseTest();
      final writer = OutboxWriter(db, db.appareilIdLocal);
      final api = ApiFausse();
      final moteur = SyncEngine(db, api);

      await writer.upsertClient(
          id: 'c1', typeClient: 'particulier', nomAffiche: 'Client 1');
      final r = await moteur.synchronise();
      expect(r.poussees, 1);
      expect(r.conflits, 0);

      // Nouveau cycle sans modification : RIEN à renvoyer
      final r2 = await moteur.synchronise();
      expect(r2.poussees, 0);
      expect(api.pushesRecus.where((o) => o['entity_id'] == 'c1'), hasLength(1));
      await db.close();
    });

    test('coupure réseau pendant push : opérations conservées en pending (F38)', () async {
      final db = await baseTest();
      final writer = OutboxWriter(db, db.appareilIdLocal);
      final api = ApiFausse()..couperReseau = true;
      final moteur = SyncEngine(db, api);

      await writer.upsertClient(
          id: 'c-hors', typeClient: 'particulier', nomAffiche: 'Hors ligne');
      final r = await moteur.synchronise();
      expect(r.horsLigne, isTrue);
      expect(r.poussees, 0);

      // AUCUNE donnée perdue : l'opération attend le retour du réseau
      final ops = await db.select(db.syncOutbox).get();
      expect(ops.single.statut, 'pending');

      // Retour du réseau → l'opération part une seule fois
      api.couperReseau = false;
      final r2 = await moteur.synchronise();
      expect(r2.poussees, 1);
      expect(api.pushesRecus, hasLength(1));
      await db.close();
    });

    test('répétition du push avec la même clé → pas de doublon serveur (F37)', () async {
      final db = await baseTest();
      final writer = OutboxWriter(db, db.appareilIdLocal);
      final api = ApiFausse();
      final moteur = SyncEngine(db, api);

      await writer.upsertClient(
          id: 'c-rep', typeClient: 'particulier', nomAffiche: 'Répété');
      await moteur.synchronise();

      // Simule une perte de confirmation : l'opération repasse en pending
      await (db.update(db.syncOutbox)..where((t) => t.statut.equals('synced')))
          .write(const SyncOutboxCompanion(statut: Value('pending')));

      await moteur.synchronise();

      // La clé d'idempotence est identique → le serveur la traite une seule fois
      final cles = api.pushesRecus.map((o) => o['idempotency_key']).toSet();
      expect(cles, hasLength(1));
      await db.close();
    });

    test('échec métier serveur → opération failed, message conservé, reprise possible', () async {
      final db = await baseTest();
      final writer = OutboxWriter(db, db.appareilIdLocal);
      final api = ApiFausse();
      final moteur = SyncEngine(db, api);

      await writer.ajouteDepense(
        id: 'd-err',
        dateDepense: '2026-10-09',
        categorie: 'Test',
        description: 'Dépense refusée',
        montant: 100,
      );
      // Réponse failed programmée pour cette clé
      final op = (await db.select(db.syncOutbox).get()).single;
      api.reponsesParCle[op.idempotencyKey] = {
        'operation_id': op.id,
        'resultat': 'failed',
        'message': 'MONTANT_INVALIDE',
      };

      final r = await moteur.synchronise();
      expect(r.echecs, 1);
      final apres = (await db.select(db.syncOutbox).get()).single;
      expect(apres.statut, 'failed');
      expect(apres.derniereErreur, 'MONTANT_INVALIDE');
      expect(apres.tentatives, 1);
      await db.close();
    });
  });

  group('Pull (spéc. §8.4, §10.F35, F40, F42)', () {
    test('changement distant appliqué et curseur avancé (F35/F36)', () async {
      final db = await baseTest(plateforme: 'windows');
      final api = ApiFausse();
      final moteur = SyncEngine(db, api);

      api.changementsServeur = [
        {
          'seq': 1,
          'entity_type': 'client',
          'entity_id': 'c-distant',
          'version': 1,
          'tombstone': false,
          'payload': {
            'type_client': 'entreprise',
            'nom_affiche': 'Créé depuis Android',
            'created_at': '2026-10-10T00:00:00Z',
            'updated_at': '2026-10-10T00:00:00Z',
          },
        },
      ];

      final r = await moteur.synchronise(pousser: false);
      expect(r.tirees, 1);

      final client = await (db.select(db.clients)
            ..where((t) => t.id.equals('c-distant')))
          .getSingleOrNull();
      expect(client, isNotNull);
      expect(client!.nomAffiche, 'Créé depuis Android');

      final etat = await moteur.etat();
      expect(etat['dernier_curseur'], '1');
      await db.close();
    });

    test('tombstone : ligne locale conservée avec deleted_at ; entité absente ignorée (F42)', () async {
      final db = await baseTest(plateforme: 'windows');
      final writer = OutboxWriter(db, db.appareilIdLocal);
      final api = ApiFausse();
      final moteur = SyncEngine(db, api);

      // 1. Ligne existante localement → marquée supprimée, PAS effacée physiquement
      await writer.upsertClient(
          id: 'c-tomb', typeClient: 'particulier', nomAffiche: 'À supprimer');
      api.changementsServeur = [
        {
          'seq': 2,
          'entity_type': 'client',
          'entity_id': 'c-tomb',
          'version': 3,
          'tombstone': true,
          'payload': {'nom_affiche': 'Supprimé ailleurs'},
        },
      ];
      await moteur.synchronise(pousser: false);
      final client = await (db.select(db.clients)
            ..where((t) => t.id.equals('c-tomb')))
          .getSingleOrNull();
      expect(client, isNotNull); // tombstone = ligne conservée
      expect(client!.deletedAt, isNotNull);

      // 2. Tombstone pour une entité jamais connue localement → ignorée sans erreur
      api.changementsServeur = [
        {
          'seq': 3,
          'entity_type': 'client',
          'entity_id': 'c-jamais-connu',
          'version': 1,
          'tombstone': true,
          'payload': {'nom_affiche': 'X'},
        },
      ];
      await moteur.synchronise(pousser: false); // ne doit PAS lever
      final absent = await (db.select(db.clients)
            ..where((t) => t.id.equals('c-jamais-connu')))
          .getSingleOrNull();
      expect(absent, isNull);
      await db.close();
    });

    test('changement déjà appliqué (version locale ≥ serveur) ignoré : idempotence', () async {
      final db = await baseTest(plateforme: 'windows');
      final writer = OutboxWriter(db, db.appareilIdLocal);
      final api = ApiFausse();
      final moteur = SyncEngine(db, api);

      // Client local déjà en version 5
      await writer.upsertClient(
          id: 'c-local', typeClient: 'particulier', nomAffiche: 'Local v5');
      await db.customStatement(
        'UPDATE clients SET version = 5 WHERE id = ?',
        ['c-local'],
      );

      api.changementsServeur = [
        {
          'seq': 3,
          'entity_type': 'client',
          'entity_id': 'c-local',
          'version': 4, // plus ancienne que la version locale 5
          'tombstone': false,
          'payload': {'nom_affiche': 'Ancien'},
        },
      ];

      final r = await moteur.synchronise(pousser: false);
      expect(r.tirees, 0);
      final client = await (db.select(db.clients)
            ..where((t) => t.id.equals('c-local')))
          .getSingle();
      expect(client.nomAffiche, 'Local v5');
      await db.close();
    });
  });

  group('Conflits (spéc. §8.5, §10.F39, F43)', () {
    test('conflit de version → aucune des deux versions détruite (F39)', () async {
      final db = await baseTest();
      final writer = OutboxWriter(db, db.appareilIdLocal);
      final api = ApiFausse();
      final moteur = SyncEngine(db, api);

      await writer.upsertClient(
          id: 'c-conf', typeClient: 'particulier', nomAffiche: 'Modifié localement');
      final op = (await db.select(db.syncOutbox).get()).single;

      // Le serveur répond conflit avec son état courant
      api.reponsesParCle[op.idempotencyKey] = {
        'operation_id': op.id,
        'resultat': 'conflict',
        'version_serveur': 7,
        'serveur': {'nom_affiche': 'Modifié sur Android', 'version': 7},
      };

      final r = await moteur.synchronise();
      expect(r.conflits, 1);

      // Version locale conservée dans sync_conflicts
      final conflit = await db.select(db.syncConflicts).getSingle();
      expect(conflit.entiteId, 'c-conf');
      expect(conflit.versionServeur, 7);
      expect(conflit.statut, 'a_resoudre');
      final local = convert.jsonDecode(conflit.localJson) as Map<String, dynamic>;
      expect(local['nom_affiche'], 'Modifié localement');
      final serveur = convert.jsonDecode(conflit.serveurJson) as Map<String, dynamic>;
      expect(serveur['nom_affiche'], 'Modifié sur Android');

      // L'opération reste visible en conflit (pas de perte silencieuse)
      final apres = (await db.select(db.syncOutbox).get()).single;
      expect(apres.statut, 'conflict');
      await db.close();
    });
  });

  group('État de synchronisation (spec §9 réseau)', () {
    test('état lisible : en attente, conflits, curseur', () async {
      final db = await baseTest();
      final writer = OutboxWriter(db, db.appareilIdLocal);
      final api = ApiFausse()..couperReseau = true;
      final moteur = SyncEngine(db, api);

      await writer.upsertClient(
          id: 'c-etat', typeClient: 'particulier', nomAffiche: 'État');
      await moteur.synchronise();
      final etat = await moteur.etat();
      expect(etat['operations_en_attente'], 1);
      expect(etat['dernier_curseur'], '0');
      expect(etat['conflits_non_resolus'], 0);
      await db.close();
    });
  });
}
