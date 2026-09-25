/// Fiche service — description, tarif, règles et les TROIS FORMATS de
/// présentation : message (copier), image (PNG partagé), PDF professionnel.
///
/// Les trois formats utilisent les mêmes données : si le prix change,
/// tout est automatiquement à jour.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/session.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/services_providers.dart';
import '../../core/services/backup_service.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/copy_message_card.dart';
import '../../shared/widgets/feedback.dart';
import '../communication/communication_providers.dart';
import 'catalog_providers.dart';

class ServiceDetailScreen extends ConsumerWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(serviceDetailProvider(serviceId));
    final rules = ref.watch(serviceRulesProvider(serviceId));
    final session = ref.watch(sessionProvider);

    return detail.when(
      loading: () => Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('$e'))),
      data: (row) {
        if (row == null) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Service introuvable')));
        }
        final s = row.service;
        return Scaffold(
          appBar: AppBar(
            title: Text(s.nom),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/catalog/$serviceId/edit'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              Row(
                children: [
                  StatusPill(row.categoryNom),
                  const SizedBox(width: 8),
                  if (!s.actif) const StatusPill('Inactif', muted: true),
                ],
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${Formatters.ar(s.prixBase)} / ${s.unite}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: MsnColors.primaryDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.delaiJours == null
                            ? 'Délai à convenir'
                            : 'Délai habituel : ${s.delaiJours} jours',
                        style: const TextStyle(
                            fontSize: 12, color: MsnColors.textSecondary),
                      ),
                      if (s.description != null) ...[
                        const SizedBox(height: 10),
                        Text(s.description!,
                            style: const TextStyle(fontSize: 13, height: 1.4)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Les trois formats ─────────────────────────────────────
              Text('PRÉSENTATION AU CLIENT (3 FORMATS)'.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: MsnColors.textSecondary)),
              const SizedBox(height: 6),

              CopyMessageCard(
                title: 'Format 1 — Message prêt',
                body: _tarifMessage(s.nom, s.prixBase, s.unite,
                    s.delaiJours),
                onShare: () async {
                  await ref.read(shareServiceProvider).shareText(
                        _tarifMessage(s.nom, s.prixBase, s.unite,
                            s.delaiJours),
                        subject: 'Tarif ${s.nom}',
                      );
                },
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FORMATS 2 & 3 — IMAGE / PDF',
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: MsnColors.textSecondary)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _generateAndShareImage(
                                  context, ref, s.nom),
                              icon: const Icon(Icons.image_outlined,
                                  size: 18),
                              label: const Text('Image',
                                  style: TextStyle(fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _generateAndSharePdf(context, ref),
                              icon: const Icon(Icons.picture_as_pdf_outlined,
                                  size: 18),
                              label: const Text('PDF',
                                  style: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'L’image est un visuel prêt pour les réseaux ; le PDF '
                        'est une fiche professionnelle imprimable. Les deux '
                        'utilisent le même tarif que ci-dessus.',
                        style: TextStyle(
                            fontSize: 11, color: MsnColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Règles métier ─────────────────────────────────────────
              if (rules.value?.isNotEmpty ?? false)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('RÈGLES MÉTIER',
                            style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: MsnColors.textSecondary)),
                        const SizedBox(height: 8),
                        ...(rules.value ?? {}).entries.map(
                              (e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                            RuleKeys.labels[e.key] ?? e.key,
                                            style: const TextStyle(
                                                fontSize: 12.5))),
                                    Text(
                                      _ruleValue(e.key, e.value),
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              if (!(session?.isAdmin ?? false))
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'La modification des services et tarifs est réservée '
                    'à l’administrateur.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11, color: MsnColors.textSecondary),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  String _tarifMessage(
      String nom, int prix, String unite, int? delaiJours) {
    return 'Bonjour, voici notre tarif pour $nom :\n\n'
        '${Formatters.ar(prix)} / $unite\n'
        'Délai : ${delaiJours == null ? 'à convenir' : '$delaiJours jours'}\n\n'
        'Le prix inclut les fichiers finaux. Souhaitez-vous un devis '
        'officiel ?';
  }

  String _ruleValue(String key, String value) {
    if (value == 'true') return 'Oui';
    if (value == 'false') return 'Non';
    return value;
  }

  Future<void> _generateAndShareImage(
      BuildContext context, WidgetRef ref, String nom) async {
    final swc = ref.read(serviceDetailProvider(serviceId)).value;
    if (swc == null) return;
    try {
      final pdf = await runWithLoading(context, 'Génération du visuel…',
          () => ref.read(pdfServiceProvider).serviceSheet(swc));
      final bytes = await File(pdf.path).readAsBytes();
      final pngBytes = await ref
          .read(pdfServiceProvider)
          .rasterizeFirstPage(bytes);
      if (pngBytes == null) {
        throw StateError('Rasterisation impossible sur cet appareil.');
      }
      final dir = await BackupService.generatedDirectory('MSN');
      final file = File(
          '${dir.path}/fiche_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);
      if (context.mounted) {
        await ref
            .read(shareServiceProvider)
            .shareFile(file.path, subject: 'Tarif $nom');
      }
    } catch (e) {
      if (context.mounted) showMsnSnack(context, e.toString(), error: true);
    }
  }

  Future<void> _generateAndSharePdf(
      BuildContext context, WidgetRef ref) async {
    final swc = ref.read(serviceDetailProvider(serviceId)).value;
    if (swc == null) return;
    try {
      final pdf = await runWithLoading(context, 'Génération du PDF…',
          () => ref.read(pdfServiceProvider).serviceSheet(swc));
      if (context.mounted) {
        await ref
            .read(shareServiceProvider)
            .shareFile(pdf.path, subject: 'Fiche ${swc.service.nom}');
      }
    } catch (e) {
      if (context.mounted) showMsnSnack(context, e.toString(), error: true);
    }
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.text, {super.key, this.muted = false});

  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: muted
            ? MsnColors.textSecondary.withOpacity(0.12)
            : MsnColors.accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: muted ? MsnColors.textSecondary : MsnColors.primaryDark)),
    );
  }
}
