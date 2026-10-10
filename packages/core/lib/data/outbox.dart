// Outbox persistante (spec §9) : toute écriture métier locale crée, DANS LA MÊME
// TRANSACTION, une opération durable. Une fermeture forcée ne perd rien.
import 'dart:convert' as convert;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'app_database.dart';

/// Portail d'API injectable (testable) : transporte les enveloppes d'opérations.
abstract class ApiPort {
  /// POST /sync/push — répond opération par opération.
  Future<Map<String, dynamic>> push(List<Map<String, dynamic>> operations);

  /// GET /sync/pull?cursor=...&limit=...
  Future<Map<String, dynamic>> pull(String curseur, int limite);
}

/// Réseau indisponible : le moteur conserve tout et retente plus tard.
class ApiInatteignable implements Exception {
  ApiInatteignable(this.cause);
  final Object cause;

  @override
  String toString() => 'API inatteignable : $cause';
}

/// Écritures métier + outbox atomiques (une seule transaction Drift).
class OutboxWriter {
  OutboxWriter(this.db, this.appareilId);

  final MsnDatabase db;
  final String appareilId;
  final Uuid _uuid = const Uuid();

  String get maintenant => DateTime.now().toUtc().toIso8601String();

  /// Création/mise à jour complète d'un client, avec opération d'outbox dans
  /// la MÊME transaction (spéc. §9 : « dans la même transaction »).
  Future<String> upsertClient({
    required String id,
    required String typeClient,
    required String nomAffiche,
    String? telephone,
    String? email,
  }) async {
    final horodatage = maintenant;
    final payload = <String, dynamic>{
      'type_client': typeClient,
      'nom_affiche': nomAffiche,
      'telephone_principal': telephone,
      'email_principal': email,
      'actif': true,
    };

    return db.transaction(() async {
      final existant =
          await (db.select(db.clients)..where((t) => t.id.equals(id)))
              .getSingleOrNull();

      if (existant == null) {
        await db.into(db.clients).insert(ClientsCompanion.insert(
              id: id,
              typeClient: typeClient,
              nomAffiche: nomAffiche,
              telephonePrincipal: Value(telephone),
              emailPrincipal: Value(email),
              createdAt: horodatage,
              updatedAt: horodatage,
              version: const Value(1),
            ));
      } else {
        await (db.update(db.clients)..where((t) => t.id.equals(id))).write(
          ClientsCompanion(
            nomAffiche: Value(nomAffiche),
            telephonePrincipal: Value(telephone),
            emailPrincipal: Value(email),
            updatedAt: Value(horodatage),
            version: Value(existant.version + 1),
          ),
        );
      }

      // Opération d'outbox — même transaction que l'écriture métier ci-dessus.
      await db.into(db.syncOutbox).insert(SyncOutboxCompanion.insert(
            id: _uuid.v4(),
            appareilId: appareilId,
            entiteType: 'client',
            entiteId: id,
            operation: 'upsert',
            payloadJson: convert.jsonEncode(payload),
            baseVersion: Value(existant?.version),
            idempotencyKey: _uuid.v4(),
            createdAt: horodatage,
            updatedAt: horodatage,
          ));


      return id;
    });
  }

  /// Création d'une dépense avec outbox (même schéma atomique).
  Future<String> ajouteDepense({
    required String id,
    required String dateDepense,
    required String categorie,
    required String description,
    required int montant,
    String moyen = 'especes',
  }) async {
    final horodatage = maintenant;
    final payload = <String, dynamic>{
      'date_depense': dateDepense,
      'categorie': categorie,
      'description': description,
      'montant': montant,
      'moyen': moyen,
    };

    return db.transaction(() async {
      await db.into(db.depenses).insert(DepensesCompanion.insert(
            id: id,
            dateDepense: dateDepense,
            categorie: categorie,
            description: description,
            montant: montant,
            moyen: moyen,
            createdAt: horodatage,
            updatedAt: horodatage,
          ));
      await db.into(db.syncOutbox).insert(SyncOutboxCompanion.insert(
            id: _uuid.v4(),
            appareilId: appareilId,
            entiteType: 'depense',
            entiteId: id,
            operation: 'upsert',
            payloadJson: convert.jsonEncode(payload),
            idempotencyKey: _uuid.v4(),
            createdAt: horodatage,
            updatedAt: horodatage,
          ));
      return id;
    });
  }

  /// Suppression logique locale + opération d'outbox 'delete'.
  Future<void> supprimeClient(String id, {String? motif}) async {
    final horodatage = maintenant;
    await db.transaction(() async {
      final existant =
          await (db.select(db.clients)..where((t) => t.id.equals(id)))
              .getSingleOrNull();
      if (existant == null || existant.deletedAt != null) {
        return;
      }
      await (db.update(db.clients)..where((t) => t.id.equals(id))).write(
        ClientsCompanion(
          deletedAt: Value(horodatage),
          updatedAt: Value(horodatage),
          version: Value(existant.version + 1),
        ),
      );
      await db.into(db.syncOutbox).insert(SyncOutboxCompanion.insert(
            id: _uuid.v4(),
            appareilId: appareilId,
            entiteType: 'client',
            entiteId: id,
            operation: 'delete',
            payloadJson: convert.jsonEncode({'motif': motif}),
            baseVersion: Value(existant.version),
            idempotencyKey: _uuid.v4(),
            createdAt: horodatage,
            updatedAt: horodatage,
          ));
    });
  }
}
