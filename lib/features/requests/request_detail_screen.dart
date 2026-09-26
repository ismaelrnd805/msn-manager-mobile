/// Détail d'une demande — qualification, actions prêtes (message tarif,
/// devis), fichiers SOURCE et changement de statut.
///
/// C'est ici que le principe « l'app prépare le travail » s'applique :
/// les actions proposées contiennent déjà le contenu prêt à copier.
library;

import 'dart:convert';
import '../../core/database/app_database.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/copy_message_card.dart';
import '../../shared/widgets/feedback.dart';
import '../catalog/catalog_providers.dart';
import '../communication/communication_providers.dart';
import 'requests_providers.dart';

class RequestDetailScreen extends ConsumerWidget {
  const RequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(requestDetailProvider(requestId));
    final files = ref.watch(requestFilesProvider(requestId));

    return detail.when(
      loading: () => Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: Center(
              child: Text('Erreur : $e',
                  style: const TextStyle(color: MsnColors.danger)))),
      data: (row) {
        if (row == null) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Demande introuvable')));
        }
        final r = row.request;
        final swc = ref.watch(serviceDetailProvider(r.serviceId ?? '')).value;

        return Scaffold(
          appBar: AppBar(
            title: Text(r.reference),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Modifier la demande',
                onPressed: () => context.push('/requests/$requestId/edit'),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _onMenu(context, ref, value, r, row.client.nom),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: 'edit', child: Text('Modifier la demande')),
                  PopupMenuItem(
                      value: 'attente',
                      child: Text('Marquer en attente client')),
                  PopupMenuItem(
                      value: 'abandon',
                      child: Text('Abandonner la demande')),
                  PopupMenuItem(
                      value: 'corbeille',
                      child: Text('Mettre à la corbeille')),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              // ── En-tête ───────────────────────────────────────────────
              Row(
                children: [
                  StatusChip.statut(
                      statut: r.statut.name, label: r.statut.label),
                  const Spacer(),
                  PriorityBadge(priorite: r.priorite),
                ],
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _row('Client', row.client.nom),
                      _row('Téléphone', row.client.telephone ?? '—'),
                      _row('Canal', r.canal.label),
                      _row('Service', swc?.service.nom ?? 'Non déterminé'),
                      _row('Reçue le', Formatters.dateTime(r.createdAt)),
                      _row('Deadline souhaitée',
                          Formatters.date(r.deadlineSouhaitee)),
                      if (r.budget != null)
                        _row('Budget indiqué', Formatters.ar(r.budget)),
                      if (r.description != null && r.description!.isNotEmpty)
                        _row('Description', r.description!),
                      if (r.notes != null && r.notes!.isNotEmpty)
                        _row('Notes', r.notes!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Qualification ─────────────────────────────────────────
              if (r.qualificationJson != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('QUALIFICATION',
                                style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: MsnColors.textSecondary)),
                            const Spacer(),
                            TextButton(
                              onPressed: r.serviceId == null
                                  ? null
                                  : () => context.push(
                                      '/requests/$requestId/qualify'),
                              child: const Text('Modifier'),
                            ),
                          ],
                        ),
                        ..._qualificationEntries(r.qualificationJson!).map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('• ${e.key} : ${e.value}',
                                style: const TextStyle(fontSize: 12.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        const Text(
                            'Cette demande n’est pas encore qualifiée. '
                            'Le formulaire du service vous guide question '
                            'par question.',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: MsnColors.textSecondary)),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: r.serviceId == null
                              ? null
                              : () =>
                                  context.push('/requests/$requestId/qualify'),
                          icon: const Icon(Icons.quiz_outlined, size: 18),
                          label: const Text('QUALIFIER LA DEMANDE'),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 14),

              // ── Actions prêtes ────────────────────────────────────────
              Text('ACTIONS PRÊTES'.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: MsnColors.textSecondary,
                      letterSpacing: 0.8)),
              const SizedBox(height: 6),

              _ReadyMessage(
                code: 'tpl_accueil',
                args: ComposerArgs(
                  clientNom: row.client.nom,
                  serviceNom: swc?.service.nom,
                  reference: r.reference,
                ),
                title: 'Message d’accueil',
              ),
              if (swc != null)
                _ReadyMessage(
                  code: 'tpl_tarif',
                  args: ComposerArgs(
                    clientNom: row.client.nom,
                    serviceNom: swc.service.nom,
                    montant: swc.service.prixBase,
                    delai: swc.service.delaiJours == null
                        ? 'à convenir'
                        : '${swc.service.delaiJours} jours',
                    reference: r.reference,
                    attachServiceId: swc.service.id,
                  ),
                  title: 'Présentation du tarif',
                ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/quotes/new?requestId=$requestId'),
                      icon: const Icon(Icons.request_quote, size: 18),
                      label: const Text('Créer le devis',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/requests/$requestId/qualify'),
                      icon: const Icon(Icons.edit_note, size: 18),
                      label: Text(r.qualificationJson == null
                          ? 'Qualifier'
                          : 'Requalifier',
                          style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Fichiers SOURCE ───────────────────────────────────────
              Row(
                children: [
                  Text('FICHIERS REÇUS (${files.value?.length ?? 0})'
                      .toUpperCase(),
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: MsnColors.textSecondary)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _attachFile(context, ref, r),
                    icon: const Icon(Icons.attach_file, size: 16),
                    label: const Text('Joindre'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Card(
                child: (files.value ?? []).isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                            'Aucun fichier. Les fichiers reçus du client '
                            '(captures, documents) sont classés dans SOURCE.',
                            style: TextStyle(
                                fontSize: 12,
                                color: MsnColors.textSecondary)))
                    : Column(
                        children: files.value!
                            .map((f) => ListTile(
                                  dense: true,
                                  leading: Icon(_fileIcon(f),
                                      size: 20, color: MsnColors.primary),
                                  title: Text(f.nom,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  subtitle: f.note != null
                                      ? Text(f.note!,
                                          style: const TextStyle(
                                              fontSize: 11))
                                      : null,
                                  onTap: () =>
                                      context.push('/files/view', extra: f),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 18),
                                    onPressed: () async {
                                      final ok = await confirmAction(context,
                                          title: 'Supprimer le fichier ?',
                                          message:
                                              '« ${f.nom} » sera supprimé du téléphone.',
                                          danger: true);
                                      if (ok) {
                                        await ref
                                            .read(fileIngestServiceProvider)
                                            .deleteFile(f);
                                      }
                                    },
                                  ),
                                ))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 120,
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 12.5, color: MsnColors.textSecondary))),
            Expanded(
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600))),
          ],
        ),
      );

  IconData _fileIcon(OrderFile f) {
    final ext = (f.mime ?? '').toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext)) {
      return Icons.image_outlined;
    }
    if (ext == 'pdf') return Icons.picture_as_pdf_outlined;
    if (ext == 'txt') return Icons.article_outlined;
    return Icons.insert_drive_file_outlined;
  }

  List<MapEntry<String, String>> _qualificationEntries(String json) {
    try {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return decoded.entries
          .map((e) => MapEntry(e.key, e.value?.toString() ?? ''))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _attachFile(
      BuildContext context, WidgetRef ref, Request r) async {
    try {
      final files = await ref.read(fileIngestServiceProvider).pickAndAttach(
            orderId: null,
            requestId: r.id,
            dossier: DossierFichier.source,
            note: 'Fichier reçu du client',
          );
      if (files.isNotEmpty && context.mounted) {
        showMsnSnack(context,
            '${files.length} fichier(s) ajouté(s) à SOURCE : '
            '${files.map((f) => f.nom).join(', ')}');
      }
    } catch (e) {
      if (context.mounted) showMsnSnack(context, e.toString(), error: true);
    }
  }

  Future<void> _onMenu(BuildContext context, WidgetRef ref, String value,
      Request r, String clientNom) async {
    final dao = ref.read(requestsDaoProvider);
    final logger = ref.read(activityLoggerProvider);
    switch (value) {
      case 'edit':
        if (context.mounted) {
          context.push('/requests/${r.id}/edit');
        }
        break;
      case 'attente':
        await dao.updateStatut(r.id, RequestStatut.enAttente);
        await logger.log(
            action: ActivityAction.changementStatut,
            entite: 'demande',
            entityId: r.id,
            details: 'Demande ${r.reference} mise en attente client.');
        break;
      case 'abandon':
        final ok = await confirmAction(context,
            title: 'Abandonner ?',
            message: 'La demande ${r.reference} sera marquée abandonnée.',
            danger: true);
        if (!ok) return;
        await dao.updateStatut(r.id, RequestStatut.abandonnee);
        await logger.log(
            action: ActivityAction.changementStatut,
            entite: 'demande',
            entityId: r.id,
            details: 'Demande ${r.reference} abandonnée.');
        break;
      case 'corbeille':
        final ok = await confirmAction(context,
            title: 'Corbeille ?',
            message:
                'La demande ${r.reference} ira dans la corbeille (récupérable).',
            danger: true);
        if (!ok) return;
        await dao.softDelete(r.id);
        await ref.read(syncEngineProvider).enqueue(
              entite: 'requests',
              entityId: r.id,
              operation: SyncOperation.update,
              payload: {'deletedAt': DateTime.now().toIso8601String()},
            );
        await logger.log(
            action: ActivityAction.suppression,
            entite: 'demande',
            entityId: r.id,
            details: 'Demande ${r.reference} mise à la corbeille.');
        if (context.mounted) context.go('/requests');
        break;
    }
  }
}

/// Carte message prêt (accueil / tarif) générée automatiquement.
class _ReadyMessage extends ConsumerWidget {
  const _ReadyMessage({required this.code, required this.args, required this.title});

  final String code;
  final ComposerArgs args;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(communicationServiceProvider);
    return FutureBuilder<RenderedMessage>(
      future: service.render(code: code, args: args),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final msg = snapshot.data!;
        return CopyMessageCard(
          title: title,
          body: msg.rendered,
          highlight: msg.missingVariables.isEmpty
              ? null
              : '${msg.missingVariables.length} variable(s) à compléter',
          onShare: () async {
            await ref.read(shareServiceProvider).shareText(
                  msg.rendered,
                  subject: msg.template.titre,
                );
          },
        );
      },
    );
  }
}
