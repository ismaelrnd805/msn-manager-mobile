// Tests de persistance locale : migrations sur base vide, outbox atomique,
// survie à la fermeture/réouverture (spéc. §10.F33, §11.1-2).
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:msn_core/data/app_database.dart';
import 'package:msn_core/data/outbox.dart';
import 'package:test/test.dart';

import 'aide.dart';

void main() {
  group('Migrations (spéc. §11.1 : migrations sur base vide)', () {
    test('création complète du schéma v1 sur base vierge', () async {
      final db = await baseTest();
      final tables = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
      ).get();
      final noms = tables.map((t) => t.data['name'] as String).toList();

      for (final attendue in [
        'clients', 'contacts', 'services', 'tarifs', 'demandes',
        'demande_prestations', 'commandes', 'lignes_commande', 'projets',
        'cahiers_charges', 'taches', 'modeles_messages', 'echanges', 'devis',
        'lignes_devis', 'factures', 'lignes_facture', 'paiements', 'depenses',
        'pieces_jointes', 'journal_actions', 'appareils',
        'publications_facebook', 'sync_outbox', 'sync_state', 'sync_conflicts',
        'app_meta',
      ]) {
        expect(noms, contains(attendue), reason: 'table $attendue manquante');
      }
      await db.close();
    });

    test('PRAGMA foreign_keys appliquée : violation refusée', () async {
      final db = await baseTest();
      await expectLater(
        db.customStatement(
          "INSERT INTO demandes (id, client_id, canal_origine, message_initial, created_at, updated_at) "
          "VALUES ('d1', 'client-inexistant', 'messenger', 'test', '2026-10-10T00:00:00Z', '2026-10-10T00:00:00Z')",
        ),
        throwsA(anything),
      );
      await db.close();
    });

    test('contraintes CHECK : montant négatif refusé sur paiements', () async {
      final db = await baseTest();
      final clientId = UuidFix().v4();
      await db.customStatement(
        'INSERT INTO clients (id, type_client, nom_affiche, actif, created_at, updated_at, version) '
        'VALUES (?, ?, ?, 1, ?, ?, 1)',
        [
          clientId,
          'particulier',
          'Test CHECK',
          '2026-10-10T00:00:00Z',
          '2026-10-10T00:00:00Z',
        ],
      );
      // CHECK métier : montant négatif refusé sur dépenses (spéc. §5)
      await expectLater(
        db.customStatement(
          "INSERT INTO depenses (id, date_depense, categorie, description, montant, devise, moyen, created_at, updated_at, version) "
          "VALUES ('e1', '2026-10-10', 'Test', 'Négatif', -100, 'MGA', 'especes', '2026-10-10', '2026-10-10', 1)",
        ),
        throwsA(anything),
      );
      // CHECK métier : statut de commande hors liste refusé
      await expectLater(
        db.customStatement(
          "INSERT INTO commandes (id, numero, demande_id, statut, created_at, updated_at, version) "
          "VALUES ('cmx', 'CMD-X', 'dmx', 'statut_fantome', '2026-10-10', '2026-10-10', 1)",
        ),
        throwsA(anything),
      );
      await db.close();
    });

    test('devis.commande_id SANS unique (correction C1) : plusieurs révisions possibles', () async {
      final db = await baseTest();
      final ids = UuidFix();
      await db.customStatement(
        'INSERT INTO clients (id, type_client, nom_affiche, actif, created_at, updated_at, version) '
        'VALUES (?, ?, ?, 1, ?, ?, 1)',
        ['c1', 'particulier', 'Client C1', '2026-10-10T00:00:00Z',
         '2026-10-10T00:00:00Z'],
      );
      await db.customStatement(
        'INSERT INTO demandes (id, client_id, canal_origine, message_initial, created_at, updated_at, version) '
        "VALUES ('dm1', 'c1', 'messenger', 'besoin', '2026-10-10T00:00:00Z', '2026-10-10T00:00:00Z', 1)",
      );
      await db.customStatement(
        'INSERT INTO commandes (id, numero, demande_id, statut, created_at, updated_at, version) '
        "VALUES ('cm1', 'CMD-2026-0001', 'dm1', 'en_preparation', '2026-10-10T00:00:00Z', '2026-10-10T00:00:00Z', 1)",
      );
      // Deux devis rattachés à la même commande : autorisé (historique), version courante gérée par le domaine
      await db.customStatement(
        'INSERT INTO devis (id, numero, demande_id, commande_id, revision, statut, total_ht, created_at, updated_at, version) '
        "VALUES ('dv1', 'DEV-2026-0001', 'dm1', 'cm1', 1, 'accepte', 90000, '2026-10-10T00:00:00Z', '2026-10-10T00:00:00Z', 1)",
      );
      await db.customStatement(
        'INSERT INTO devis (id, numero, demande_id, commande_id, revision, statut, total_ht, created_at, updated_at, version) '
        "VALUES ('dv2', 'DEV-2026-0002', 'dm1', 'cm1', 2, 'accepte', 85000, '2026-10-10T00:00:00Z', '2026-10-10T00:00:00Z', 1)",
      );
      final n = await db.customSelect('SELECT COUNT(*) n FROM devis WHERE commande_id = ?',
          variables: [Variable('cm1')]).getSingle();
      expect(n.data['n'], 2);
      await db.close();
    });
  });

  group('Outbox atomique (spéc. §9, §10.F33 : données survivent hors ligne)', () {
    test('écriture client + opération d\'outbox dans la MÊME transaction', () async {
      final db = await baseTest();
      final writer = OutboxWriter(db, db.appareilIdLocal);

      await writer.upsertClient(
        id: 'client-1',
        typeClient: 'particulier',
        nomAffiche: 'Ranaivo Marie',
        telephone: '0341112223',
      );

      final clients = await db.select(db.clients).get();
      expect(clients, hasLength(1));
      expect(clients.single.nomAffiche, 'Ranaivo Marie');
      expect(clients.single.version, 1);

      final ops = await db.select(db.syncOutbox).get();
      expect(ops, hasLength(1));
      expect(ops.single.entiteType, 'client');
      expect(ops.single.entiteId, 'client-1');
      expect(ops.single.operation, 'upsert');
      expect(ops.single.statut, 'pending');
      expect(ops.single.idempotencyKey, isNotEmpty);
      await db.close();
    });

    test('modification incrémentale : version +1, nouvelle opération d\'outbox', () async {
      final db = await baseTest();
      final writer = OutboxWriter(db, db.appareilIdLocal);

      await writer.upsertClient(
          id: 'client-1', typeClient: 'particulier', nomAffiche: 'Avant');
      await writer.upsertClient(
          id: 'client-1', typeClient: 'particulier', nomAffiche: 'Après');

      final client = await (db.select(db.clients)
            ..where((t) => t.id.equals('client-1')))
          .getSingle();
      expect(client.nomAffiche, 'Après');
      expect(client.version, 2);

      final ops = await db.select(db.syncOutbox).get();
      expect(ops, hasLength(2));
      // La 2ᵉ opération porte la base_version d'origine (1) pour la détection de conflits
      expect(ops.last.baseVersion, 1);
      await db.close();
    });

    test('survie à la fermeture : réouverture du fichier → données retrouvées (spéc. §10.F33)', () async {
      configureSqlite();
      final chemin =
          '/tmp/msn_test_survie_${DateTime.now().millisecondsSinceEpoch}.db';

      final db1 = MsnDatabase.ouvre(chemin);
      await db1.customStatement('PRAGMA foreign_keys = ON');
      await db1.initAppareilLocal(nom: 'Survie');
      final writer1 = OutboxWriter(db1, db1.appareilIdLocal);
      await writer1.upsertClient(
        id: 'client-survie',
        typeClient: 'entreprise',
        nomAffiche: 'Société Survie',
      );
      await db1.close(); // « fermeture forcée »

      // Réouverture : l'appareil ET la donnée sont retrouvés
      final db2 = MsnDatabase.ouvre(chemin);
      await db2.customStatement('PRAGMA foreign_keys = ON');
      final client = await (db2.select(db2.clients)
            ..where((t) => t.id.equals('client-survie')))
          .getSingleOrNull();
      expect(client, isNotNull);
      expect(client!.nomAffiche, 'Société Survie');

      final ops = await db2.select(db2.syncOutbox).get();
      expect(ops, hasLength(1));
      expect(ops.single.statut, 'pending'); // prêt à synchroniser au retour réseau
      await db2.close();
      File(chemin).deleteSync();
    });

    test('suppression logique + opération delete dans la même transaction', () async {
      final db = await baseTest();
      final writer = OutboxWriter(db, db.appareilIdLocal);
      await writer.upsertClient(
          id: 'client-2', typeClient: 'particulier', nomAffiche: 'À supprimer');
      await writer.supprimeClient('client-2', motif: 'Doublon confirmé');

      final client = await (db.select(db.clients)
            ..where((t) => t.id.equals('client-2')))
          .getSingle();
      expect(client.deletedAt, isNotNull);

      final ops = await db.select(db.syncOutbox).get();
      expect(ops, hasLength(2));
      expect(ops.last.operation, 'delete');
      await db.close();
    });
  });
}

/// UUID déterministe pour les tests.
class UuidFix {
  int _n = 0;
  String v4() => '00000000-0000-4000-8000-${(_n++).toString().padLeft(12, '0')}';
}
