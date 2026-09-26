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

import '../../core/constants/app_constants.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/services/backup_service.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/copy_message_card.dart';
import '../../shared/widgets/feedback.dart';
import '../../core/database/app_database.dart';
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
                        Formatters.tarif(s.prixBase, s.unite),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: MsnColors.primaryDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.delai(s.delaiJours),
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

              // ── Présentation enrichie (v4) ────────────────────────────
              if (s.descriptionDetaillee != null &&
                  s.descriptionDetaillee!.trim().isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PRÉSENTATION DÉTAILLÉE',
                            style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: MsnColors.textSecondary)),
                        const SizedBox(height: 8),
                        Text(s.descriptionDetaillee!,
                            style: const TextStyle(
                                fontSize: 13, height: 1.5)),
                      ],
                    ),
                  ),
                ),
              if (s.avantages != null && s.avantages!.trim().isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AVANTAGES',
                            style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: MsnColors.textSecondary)),
                        const SizedBox(height: 8),
                        ...s.avantages!
                            .split('\n')
                            .where((l) => l.trim().isNotEmpty)
                            .map((l) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check_circle,
                                          size: 15,
                                          color: MsnColors.success),
                                      const SizedBox(width: 7),
                                      Expanded(
                                          child: Text(l.trim(),
                                              style: const TextStyle(
                                                  fontSize: 13))),
                                    ],
                                  ),
                                )),
                      ],
                    ),
                  ),
                ),
              if (s.faq != null && s.faq!.trim().isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('QUESTIONS FRÉQUENTES',
                            style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: MsnColors.textSecondary)),
                        const SizedBox(height: 8),
                        ...s.faq!
                            .split('\n')
                            .where((l) => l.trim().isNotEmpty)
                            .map((l) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 5),
                                  child: Text(l.trim(),
                                      style: const TextStyle(
                                          fontSize: 12.5, height: 1.45)),
                                )),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // ── Processus de prise en charge (administrable) ──────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PROCESSUS DE PRISE EN CHARGE',
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: MsnColors.textSecondary)),
                      const SizedBox(height: 10),
                      _ProcessSteps(ref: ref),
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
    final surDevis = prix <= 0 || unite.trim() == 'devis';
    final tarif = surDevis
        ? 'Sur devis : le tarif est établi après étude de votre projet.'
        : Formatters.tarif(prix, unite);
    final delai = (delaiJours == null || delaiJours <= 0)
        ? 'à convenir selon le projet'
        : '$delaiJours jours';
    return 'Bonjour, voici notre tarif pour $nom :\n\n'
        '$tarif\n'
        'Délai : $delai\n\n'
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
            ? MsnColors.textSecondary.withValues(alpha: 0.12)
            : MsnColors.accent.withValues(alpha: 0.15),
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

/// Liste des étapes du processus client (table process_steps, v4) —
/// contenu administrable depuis Administration > Processus client.
class _ProcessSteps extends StatelessWidget {
  const _ProcessSteps({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final stepsAsync = ref
        .watch(workflowsDaoProvider)
        .watchActiveProcessSteps();
    return StreamBuilder<List<ProcessStep>>(
      stream: stepsAsync,
      builder: (context, snapshot) {
        final steps = snapshot.data ?? const <ProcessStep>[];
        if (steps.isEmpty) {
          return Text(
              'Le parcours client sera affiché ici une fois configuré '
              'dans l\'administration.',
              style: TextStyle(
                  fontSize: 12,
                  color: MsnColors.textSecondary.withValues(alpha: 0.9)));
        }
        return Column(
          children: [
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: MsnColors.accentSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Text('${i + 1}',
                          style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: MsnColors.primaryDark)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(steps[i].titre,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                          if (steps[i].description != null)
                            Text(steps[i].description!,
                                style: TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: MsnColors.textSecondary
                                        .withValues(alpha: 0.95))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
