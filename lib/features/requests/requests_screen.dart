/// Liste des demandes — recherche, filtres lisibles, SÉLECTION MULTIPLE
/// (appui long), suppression groupée avec confirmation et journalisation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/selection.dart';
import 'requests_providers.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> {
  final _selection = SelectionController<String>();

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  Future<void> _deleteSelected(List<RequestRow> all) async {
    final ids = _selection.selected;
    final refs = all
        .where((r) => ids.contains(r.request.id))
        .map((r) => r.request.reference)
        .toList();
    final ok = await confirmAction(context,
        title: 'Supprimer ${ids.length} demande(s) ?',
        message:
            '${refs.take(3).join(', ')}${refs.length > 3 ? '…' : ''} iront '
            'dans la corbeille (récupérables).',
        danger: true);
    if (!ok || !mounted) return;
    final dao = ref.read(requestsDaoProvider);
    final logger = ref.read(activityLoggerProvider);
    final sync = ref.read(syncEngineProvider);
    for (final id in ids) {
      await dao.softDelete(id);
      await sync.enqueue(
        entite: 'requests',
        entityId: id,
        operation: SyncOperation.update,
        payload: {'deletedAt': DateTime.now().toIso8601String()},
      );
      final row = all.where((r) => r.request.id == id).firstOrNull;
      await logger.log(
        action: ActivityAction.suppression,
        entite: 'demande',
        entityId: id,
        details: 'Demande ${row?.request.reference ?? id} '
            'mise à la corbeille (sélection multiple).',
      );
    }
    setState(() => _selection.clear());
    if (mounted) showMsnSnack(context, '${ids.length} demande(s) supprimée(s).');
  }

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(requestsProvider);
    final filter = ref.watch(requestsFilterProvider);

    return Scaffold(
      appBar: _selection.isSelecting
          ? SelectionAppBar(
              count: _selection.count,
              total: requests.value?.length ?? 0,
              onClose: () => setState(_selection.clear),
              onSelectAll: () => setState(() => _selection.selectAll(
                  (requests.value ?? const [])
                      .map((r) => r.request.id)
                      .toList())),
              onClearSelection: () => setState(_selection.clear),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Supprimer la sélection',
                  onPressed: _selection.count == 0
                      ? null
                      : () => _deleteSelected(requests.value ?? const []),
                ),
              ],
            )
          : AppBar(title: const Text('Demandes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              onChanged: (v) =>
                  ref.read(requestsSearchProvider.notifier).state = v,
              decoration: const InputDecoration(
                hintText: 'Rechercher (réf. ou client)…',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _filterChip(ref, filter, null, 'Toutes'),
                ...RequestStatut.values.map(
                  (s) => _filterChip(ref, filter, s.name, s.label),
                ),
              ],
            ),
          ),
          Expanded(
            child: requests.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Erreur : $e',
                        style: const TextStyle(color: MsnColors.danger)),
                    const SizedBox(height: 8),
                    OutlinedButton(
                        onPressed: () =>
                            ref.invalidate(requestsProvider),
                        child: const Text('Réessayer')),
                  ],
                ),
              ),
              data: (list) => list.isEmpty
                  ? EmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'Aucune demande',
                      message:
                          'Enregistrez ici chaque demande reçue sur Messenger, '
                          'WhatsApp ou par téléphone.',
                      action: FilledButton.icon(
                        onPressed: () => context.push('/requests/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Enregistrer une demande'),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {},
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final r = list[index];
                          final selected =
                              _selection.isSelected(r.request.id);
                          return Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onLongPress: () => setState(
                                  () => _selection.enterSelection(
                                      r.request.id)),
                              onTap: () {
                                if (_selection.isSelecting) {
                                  setState(() =>
                                      _selection.toggle(r.request.id));
                                  return;
                                }
                                context.push('/requests/${r.request.id}');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_selection.isSelecting) ...[
                                      Icon(
                                        selected
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        size: 22,
                                        color: selected
                                            ? MsnColors.primary
                                            : MsnColors.textSecondary
                                                .withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(r.request.reference,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 13,
                                                      color: MsnColors
                                                          .primaryDark)),
                                              const Spacer(),
                                              StatusChip.statut(
                                                  statut:
                                                      r.request.statut.name,
                                                  label:
                                                      r.request.statut.label),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            r.clientNom,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          if (r.request.description !=
                                                  null &&
                                              r.request.description!
                                                  .isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4),
                                              child: Text(
                                                r.request.description!,
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 12.5,
                                                    color: MsnColors
                                                        .textSecondary),
                                              ),
                                            ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              PriorityBadge(
                                                  priorite:
                                                      r.request.priorite),
                                              const Spacer(),
                                              Text(
                                                Formatters.relative(
                                                    r.request.createdAt),
                                                style: const TextStyle(
                                                    fontSize: 11.5,
                                                    color: MsnColors
                                                        .textSecondary),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
      WidgetRef ref, String? current, String? value, String label) {
    final selected = current == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) =>
            ref.read(requestsFilterProvider.notifier).state = value,
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
