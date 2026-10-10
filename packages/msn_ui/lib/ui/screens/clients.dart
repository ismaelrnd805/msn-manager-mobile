// Clients : recherche, création avec détection de doublons, fiche détaillée.
// Un client peut avoir plusieurs contacts/demandes/commandes (spec §6.A).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msn_core/data/app_database.dart';
import 'package:msn_core/data/outbox.dart';
import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:uuid/uuid.dart';

import '../../state/providers.dart';
import '../../state/tableaux_bord.dart';

class ClientsEcran extends ConsumerStatefulWidget {
  const ClientsEcran({super.key});

  @override
  ConsumerState<ClientsEcran> createState() => _ClientsEcranState();
}

class _ClientsEcranState extends ConsumerState<ClientsEcran> {
  String _recherche = '';

  @override
  Widget build(BuildContext context) {
    final dbFuture = ref.watch(baseDeDonneesProvider.future);

    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('Nouveau client'),
        onPressed: () => _ouvreFormulaire(context, ref),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher par nom, téléphone ou email…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _recherche = v.trim()),
            ),
          ),
          Expanded(
            child: dbFuture != null
                ? FutureBuilder<List<Client>>(
                    future: dbFuture.then((db) => _lister(db, _recherche)),
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final clients = snap.data ?? const <Client>[];
                      if (clients.isEmpty) {
                        return const Center(child: Text('Aucun client trouvé'));
                      }
                      return ListView.builder(
                        itemCount: clients.length,
                        itemBuilder: (context, i) =>
                            _carteClient(context, ref, clients[i]),
                      );
                    },
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Future<List<Client>> _lister(MsnDatabase db, String terme) async {
    final q = db.select(db.clients)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.nomAffiche)]);
    if (terme.isNotEmpty) {
      q.where((t) =>
          t.nomAffiche.lower().like('%${terme.toLowerCase()}%') |
          t.telephonePrincipal.like('%$terme%') |
          t.emailPrincipal.lower().like('%${terme.toLowerCase()}%'));
    }
    return q.get();
  }

  Widget _carteClient(BuildContext context, WidgetRef ref, Client c) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(c.typeClient == 'entreprise' ? Icons.business : Icons.person),
        ),
        title: Text(c.nomAffiche),
        subtitle: Text([
          if (c.telephonePrincipal != null) c.telephonePrincipal!,
          if (c.emailPrincipal != null) c.emailPrincipal!,
        ].join(' · ')),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            if (v == 'modifier') {
              _ouvreFormulaire(context, ref, existant: c);
            } else if (v == 'supprimer') {
              final confirme = await _confirmeSuppression(context);
              if (confirme == true) {
                final writer = OutboxWriter(
                    await ref.read(baseDeDonneesProvider.future),
                    (await ref.read(baseDeDonneesProvider.future)).appareilIdLocal);
                await writer.supprimeClient(c.id, motif: 'Suppression depuis la fiche client');
                ref.invalidate(resumeTableauBordProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Client marqué supprimé (synchronisation en attente).')));
                }
              }
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'modifier', child: Text('Modifier')),
            PopupMenuItem(value: 'supprimer', child: Text('Supprimer')),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmeSuppression(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce client ?'),
        content: const Text(
            'La suppression est logique : le client disparaît des listes mais '
            'l\'historique (demandes, commandes, audit) est conservé. '
            'La suppression sera synchronisée avec le serveur.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer')),
        ],
      ),
    );
  }
}

/// Formulaire client avec validation et détection de doublons AVANT création.
Future<void> _ouvreFormulaire(BuildContext context, WidgetRef ref,
    {Client? existant}) async {
  final formKey = GlobalKey<FormState>();
  final nomCtrl = TextEditingController(text: existant?.nomAffiche ?? '');
  final telCtrl = TextEditingController(text: existant?.telephonePrincipal ?? '');
  final emailCtrl = TextEditingController(text: existant?.emailPrincipal ?? '');
  var type = existant?.typeClient ?? 'particulier';
  List<Map<String, dynamic>> doublons = [];

  final confirme = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(existant == null ? 'Nouveau client' : 'Modifier le client',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'particulier', label: Text('Particulier')),
                  ButtonSegment(value: 'entreprise', label: Text('Entreprise')),
                ],
                selected: {type},
                onSelectionChanged: (s) => setState(() => type = s.first),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nomCtrl,
                decoration:
                    const InputDecoration(labelText: 'Nom affiché *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nom obligatoire' : null,
                onChanged: (_) => setState(() => doublons = []),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: telCtrl,
                decoration: const InputDecoration(
                    labelText: 'Téléphone principal'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: emailCtrl,
                decoration:
                    const InputDecoration(labelText: 'Email principal'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v != null && v.isNotEmpty && !v.contains('@')
                        ? 'Email invalide'
                        : null,
              ),
              if (doublons.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Doublons potentiels :',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      for (final d in doublons)
                        Text('• ${d['nom_affiche']} (${d['telephone_principal'] ?? 'sans téléphone'})'),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Vérifier les doublons'),
                onPressed: () async {
                  final db = await ref.read(baseDeDonneesProvider.future);
                  final terme = nomCtrl.text.trim();
                  final trouve = await (db.select(db.clients)
                        ..where((t) =>
                            t.deletedAt.isNull() &
                            t.nomAffiche.lower().like('%${terme.toLowerCase()}%') &
                            (existant == null ? const Constant(true) : t.id.equals(existant.id).not()))
                        ..limit(10))
                      .get();
                  setState(() => doublons = [
                        for (final c in trouve)
                          {
                            'nom_affiche': c.nomAffiche,
                            'telephone_principal': c.telephonePrincipal,
                          }
                      ]);
                },
              ),
              const SizedBox(height: 8),
              FilledButton(
                child: Text(existant == null ? 'Créer' : 'Enregistrer'),
                onPressed: () async {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  final db = await ref.read(baseDeDonneesProvider.future);
                  final writer = OutboxWriter(db, db.appareilIdLocal);
                  await writer.upsertClient(
                    id: existant?.id ?? const Uuid().v4(),
                    typeClient: type,
                    nomAffiche: nomCtrl.text.trim(),
                    telephone: telCtrl.text.trim().isEmpty ? null : telCtrl.text.trim(),
                    email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                  );
                  ref.invalidate(resumeTableauBordProvider);
                  if (ctx.mounted) Navigator.pop(ctx, true);
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );

  if (confirme == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Client enregistré localement — synchronisation planifiée.')));
  }
}
