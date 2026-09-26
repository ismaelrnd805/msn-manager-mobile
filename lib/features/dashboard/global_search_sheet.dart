/// Recherche globale — une seule barre pour retrouver une demande,
/// un client ou un service. Ouverte depuis le dashboard (grande barre
/// accessible) ; résultats groupés, navigation directe.
library;

import 'dart:async';

import 'package:drift/drift.dart' show QueryRow;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/database_provider.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';

class GlobalSearchSheet extends ConsumerStatefulWidget {
  const GlobalSearchSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(_).viewInsets.bottom),
        child: const SizedBox(height: 520, child: GlobalSearchSheet()),
      ),
    );
  }

  @override
  ConsumerState<GlobalSearchSheet> createState() => _GlobalSearchSheetState();
}

class _GlobalSearchSheetState extends ConsumerState<GlobalSearchSheet> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => _query = v.trim());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final q = _query.toLowerCase().replaceAll("'", "''");

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher une demande, un client, un service…',
                prefixIcon: const Icon(Icons.search, size: 22),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () =>
                            setState(() => _controller.clear()),
                      ),
              ),
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? const Center(
                    child: Text(
                        'Saisissez au moins un mot-clé (référence, nom, '
                        'téléphone, service).',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12.5,
                            color: MsnColors.textSecondary)))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      _Section(
                        title: 'DEMANDES',
                        future: db.customSelect(
                          '''
                          SELECT r.id AS rid, r.reference AS ref,
                                 r.statut AS statut, r.created_at AS created,
                                 c.nom AS client_nom
                          FROM requests r
                          INNER JOIN clients c ON c.id = r.client_id
                          WHERE r.deleted_at IS NULL AND (
                                LOWER(r.reference) LIKE '%$q%' OR
                                LOWER(COALESCE(r.description,'')) LIKE '%$q%' OR
                                LOWER(c.nom) LIKE '%$q%')
                          ORDER BY r.created_at DESC LIMIT 8
                          ''',
                        ).get(),
                        tileBuilder: (row) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.inbox_outlined, size: 20),
                          title: Text(row.data['ref'] as String,
                              style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700)),
                          subtitle: Text(row.data['client_nom'] as String,
                              style: const TextStyle(fontSize: 12)),
                          onTap: () {
                            Navigator.pop(context);
                            context
                                .push('/requests/${row.data['rid'] as String}');
                          },
                        ),
                      ),
                      _Section(
                        title: 'CLIENTS',
                        future: db.customSelect(
                          '''
                          SELECT id, nom, telephone, created_at AS created
                          FROM clients
                          WHERE deleted_at IS NULL AND (
                                LOWER(nom) LIKE '%$q%' OR
                                COALESCE(telephone,'') LIKE '%$q%')
                          ORDER BY created_at DESC LIMIT 8
                          ''',
                        ).get(),
                        tileBuilder: (row) => ListTile(
                          dense: true,
                          leading:
                              const Icon(Icons.person_outline, size: 20),
                          title: Text(row.data['nom'] as String,
                              style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700)),
                          subtitle: Text(row.data['telephone'] as String? ?? '—',
                              style: const TextStyle(fontSize: 12)),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/clients/${row.data['id'] as String}');
                          },
                        ),
                      ),
                      _Section(
                        title: 'SERVICES',
                        future: db.customSelect(
                          '''
                          SELECT id, nom, prix_base
                          FROM services
                          WHERE deleted_at IS NULL AND LOWER(nom) LIKE '%$q%'
                          ORDER BY nom ASC LIMIT 8
                          ''',
                        ).get(),
                        tileBuilder: (row) => ListTile(
                          dense: true,
                          leading:
                              const Icon(Icons.storefront, size: 20),
                          title: Text(row.data['nom'] as String,
                              style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700)),
                          subtitle: Text(
                              Formatters.ar(row.data['prix_base'] as int),
                              style: const TextStyle(fontSize: 12)),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/catalog/${row.data['id'] as String}');
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.future, required this.tileBuilder});

  final String title;
  final Future<List<QueryRow>> future;
  final Widget Function(QueryRow) tileBuilder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueryRow>>(
      future: future,
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const [];
        if (rows.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: MsnColors.textSecondary,
                      letterSpacing: 0.8)),
            ),
            Card(
              child: Column(
                children: rows.map(tileBuilder).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
