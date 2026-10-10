// Accueil : tâches urgentes uniquement — commandes à traiter, échéances proches,
// demandes en attente, devis à relancer, paiements en attente, état de sync (spec §5).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../state/providers.dart';
import '../../state/tableaux_bord.dart';

class AccueilEcran extends ConsumerWidget {
  const AccueilEcran({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resume = ref.watch(resumeTableauBordProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            tooltip: 'Synchroniser maintenant',
            icon: const Icon(Icons.sync),
            onPressed: () async {
              final r = await synchroniser(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(r == null
                      ? 'Serveur injoignable — les modifications restent enregistrées localement.'
                      : r.horsLigne
                          ? 'Hors ligne : ${r.poussees} envoyées, rien perdu.'
                          : 'Synchronisation réussie : ${r.poussees} envoyées, ${r.tirees} reçues.'),
                ));
              }
            },
          ),
        ],
      ),
      body: resume.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (r) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _bloc(context, 'Commandes à traiter', r['commandes_a_traiter'] as List,
                '/commandes', Colors.deepOrange),
            _bloc(context, 'Échéances proches (7 jours)', r['echeances_proches'] as List,
                '/taches', Colors.red),
            _bloc(context, 'Demandes en attente du client',
                r['demandes_en_attente'] as List, '/demandes', Colors.amber.shade700),
            _bloc(context, 'Devis à préparer ou à relancer',
                r['devis_actifs'] as List, '/devis', Colors.blue),
            _blocPaiements(context, r),
            _carteSync(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _bloc(BuildContext context, String titre, List elements, String route,
      Color couleur) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: couleur.withValues(alpha: 0.15),
            child: Text('${elements.length}',
                style: TextStyle(
                    color: couleur, fontWeight: FontWeight.bold))),
        title: Text(titre),
        subtitle: elements.isEmpty
            ? const Text('Rien à signaler')
            : Text(elements
                .take(3)
                .map((e) => (e['libelle'] ?? '?').toString())
                .join(' · ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go(route),
      ),
    );
  }

  Widget _blocPaiements(BuildContext context, Map<String, dynamic> r) {
    final montant = r['solde_a_encaisser'] as int;
    final fmt = NumberFormat('#,###', 'fr_FR');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade50,
          child: Icon(Icons.payments, color: Colors.green.shade700),
        ),
        title: const Text('Paiements en attente (solde dû)'),
        subtitle: Text(
            '${fmt.format(montant).replaceAll(',', ' ')} Ar — factures émises non soldées'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/finances'),
      ),
    );
  }

  Widget _carteSync(BuildContext context, WidgetRef ref) {
    final etat = ref.watch(etatSyncProvider);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: etat.when(
        loading: () => const ListTile(
            leading: CircularProgressIndicator(strokeWidth: 2),
            title: Text('Synchronisation…')),
        error: (e, _) => const ListTile(
            leading: Icon(Icons.sync_problem, color: Colors.orange),
            title: Text('Synchronisation : serveur injoignable'),
            subtitle: Text('Les données restent disponibles hors ligne.')),
        data: (e) {
          final attente = e['operations_en_attente'] as int;
          final conflits = e['conflits_non_resolus'] as int;
          return ListTile(
            leading: Icon(
              conflits > 0
                  ? Icons.sync_problem
                  : attente > 0
                      ? Icons.sync_outlined
                      : Icons.cloud_done,
              color: conflits > 0 ? Colors.red : Colors.green,
            ),
            title: Text(conflits > 0
                ? 'Conflits à résoudre : $conflits'
                : attente > 0
                    ? '$attente modification(s) en attente de synchronisation'
                    : 'Tout est synchronisé'),
            subtitle: Text('Curseur : ${e['dernier_curseur']} · '
                'Dernière réussie : ${e['derniere_sync_reussie'] ?? 'jamais'}'),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => synchroniser(ref),
            ),
          );
        },
      ),
    );
  }
}
