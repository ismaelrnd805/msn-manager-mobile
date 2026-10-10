// Tableaux de bord : requêtes Drift agrégées pour l'accueil (spec §5 Accueil).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:msn_core/data/app_database.dart';

import 'providers.dart';

/// Résumé des urgences : commandes à traiter, échéances, demandes en attente,
/// devis actifs, solde à encaisser. N'affiche JAMAIS de cartes décoratives.
final resumeTableauBordProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final db = await ref.watch(baseDeDonneesProvider.future);
  final aujourdhui = DateTime.now().toUtc();
  final dans7Jours = aujourdhui.add(const Duration(days: 7)).toIso8601String().substring(0, 10);

  final commandesATraiter = await db.customSelect(
    "SELECT c.numero, c.statut, cl.nom_affiche AS client "
    "FROM commandes c JOIN demandes d ON d.id = c.demande_id "
    "JOIN clients cl ON cl.id = d.client_id "
    "WHERE c.deleted_at IS NULL AND c.statut NOT IN ('livree','annulee') "
    "ORDER BY c.created_at LIMIT 20",
  ).get();

  final echeances = await db.customSelect(
    "SELECT t.titre AS libelle, t.echeance FROM taches t "
    "WHERE t.deleted_at IS NULL AND t.statut NOT IN ('terminee','annulee') "
    "AND t.echeance IS NOT NULL AND date(t.echeance) <= ? "
    "ORDER BY t.echeance LIMIT 20",
    variables: [Variable.withString(dans7Jours)],
  ).get();

  final demandesEnAttente = await db.customSelect(
    "SELECT d.besoin_resume AS libelle, d.statut FROM demandes d "
    "WHERE d.deleted_at IS NULL AND d.statut IN ('a_qualifier','en_attente_client') "
    "ORDER BY d.created_at DESC LIMIT 20",
  ).get();

  final devisActifs = await db.customSelect(
    "SELECT dv.numero AS libelle, dv.statut FROM devis dv "
    "WHERE dv.deleted_at IS NULL AND dv.statut IN ('presente','modification_demandee') "
    "ORDER BY dv.created_at DESC LIMIT 20",
  ).get();

  final solde = await db.customSelect(
    "SELECT COALESCE(SUM(f.total), 0) AS total, COALESCE(( "
    "SELECT SUM(p.montant) FROM paiements p WHERE p.statut = 'confirme' "
    "AND p.deleted_at IS NULL), 0) AS encaisse FROM factures f "
    "WHERE f.deleted_at IS NULL AND f.statut IN ('emise','partiellement_payee')",
  ).getSingle();

  Map<String, Object?> ligne(r) => {'libelle': r.data['libelle'] ?? r.data['numero'], 'statut': r.data['statut']};

  return {
    'commandes_a_traiter': commandesATraiter
        .map((r) => {'libelle': '${r.data['numero']} — ${r.data['client']}', 'statut': r.data['statut']})
        .toList(),
    'echeances_proches': echeances.map((r) => {'libelle': r.data['libelle'], 'statut': r.data['echeance']}).toList(),
    'demandes_en_attente': demandesEnAttente.map(ligne).toList(),
    'devis_actifs': devisActifs.map(ligne).toList(),
    'solde_a_encaisser': (solde.data['total'] as int) - (solde.data['encaisse'] as int),
  };
});
