/// Détail commande — le poste de pilotage MSN :
/// « Où suis-je ? Que dois-je faire ? Qu'est-ce qui manque ?
///   Quelle action est prête ? » (section 10 du cahier des charges).
///
/// - Progression du workflow étape par étape (règles métier bloquantes)
/// - Actions prêtes à l'étape courante (messages, paiements, fichiers…)
/// - Fichiers par dossier (SOURCE/TRAVAIL/CORRECTIONS/FINAL/DOCUMENTS)
/// - Checklist TRANSFERT PC avec 9 vérifications obligatoires
library;

import 'dart:convert';
import '../../shared/widgets/badges.dart';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/business_rules.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/transfer_checklist.dart';
import '../../core/domain/workflow_engine.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/feedback.dart';
import '../communication/communication_providers.dart';
import 'orders_providers.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(orderDetailProvider(orderId));
    final instanceAsync = ref.watch(orderInstanceProvider(orderId));
    final paidAsync = ref.watch(orderPaidProvider(orderId));
    final filesAsync = ref.watch(orderFilesProvider(orderId));

    return detail.when(
      loading: () => Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
          appBar: AppBar(), body: Center(child: Text('$e'))),
      data: (row) {
        if (row == null) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Commande introuvable')));
        }
        final order = row.order;
        final instance = instanceAsync.value;
        final states = instance == null
            ? const <WorkflowStepState>[]
            : (ref.watch(instanceStatesProvider(instance.id)).value ??
                const <WorkflowStepState>[]);
        final paid = paidAsync.value ?? 0;
        final files = filesAsync.value ?? const [];

        final progress = WorkflowEngine.progression(
            states.map((s) => s.statut == 'terminee').toList());
        final currentStep =
            states.isEmpty ? null : states[progress.etapeCourante];

        return Scaffold(
          appBar: AppBar(
            title: Text(order.reference),
          ),
          body: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              // ── En-tête ───────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(order.titre,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                  StatusChip.statut(
                      statut: order.statut.name, label: order.statut.label),
                ],
              ),
              const SizedBox(height: 4),
              Text('${row.client.nom} · ${Formatters.ar(order.montantTotal)}',
                  style: const TextStyle(fontSize: 13)),
              if (order.deadline != null)
                Text(
                    'Deadline : ${Formatters.date(order.deadline)} '
                    '(${Formatters.relative(order.deadline!)})',
                    style: const TextStyle(
                        fontSize: 12, color: MsnColors.textSecondary)),
              const SizedBox(height: 12),

              // ── Où suis-je ? ──────────────────────────────────────────
              if (instance != null && states.isNotEmpty) ...[
                Card(
                  color: MsnColors.primary.withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('PROGRESSION',
                                style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: MsnColors.textSecondary)),
                            const Spacer(),
                            Text(
                                '${progress.labelAvancement} — '
                                'étape ${progress.etapeCourante + 1}/${progress.totalEtapes}',
                                style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: MsnColors.primaryDark)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress.avancement,
                            minHeight: 8,
                            backgroundColor: MsnColors.border,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...states.map((s) => _stepTile(
                              context,
                              ref,
                              order: order,
                              instance: instance,
                              states: states,
                              step: s,
                              isCurrent: s.id == currentStep?.id,
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Actions prêtes de l'étape courante ──────────────────
                if (currentStep != null && !progress.terminee) ...[
                  Text('ACTIONS PRÊTES — ${currentStep.nom.toUpperCase()}',
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: MsnColors.primaryDark)),
                  const SizedBox(height: 6),
                  _readyActions(
                      context, ref, order, instance, currentStep, states),
                  const SizedBox(height: 14),
                ],
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      'Aucun workflow instancié pour cette commande. '
                      'L’administrateur peut définir un workflow pour ce '
                      'service dans le catalogue.',
                      style: TextStyle(
                          fontSize: 12.5,
                          color: MsnColors.textSecondary.withValues(alpha: 1)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ── Transfert PC ──────────────────────────────────────────
              _transferCard(context, ref, order, states, paid, files),
              const SizedBox(height: 14),

              // ── Fichiers ──────────────────────────────────────────────
              _filesSection(context, ref, order, files),
              const SizedBox(height: 14),

              // ── Liens ─────────────────────────────────────────────────
              Row(
                children: [
                  if (order.quoteId != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            context.push('/quotes/${order.quoteId}'),
                        icon: const Icon(Icons.request_quote, size: 16),
                        label: const Text('Devis',
                            style: TextStyle(fontSize: 12.5)),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(
                          '/invoices/new?orderId=${order.id}'),
                      icon: const Icon(Icons.receipt_long, size: 16),
                      label: const Text('Facturer',
                          style: TextStyle(fontSize: 12.5)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context
                          .push('/payments/new?orderId=${order.id}'),
                      icon: const Icon(Icons.payments, size: 16),
                      label: const Text('Paiement',
                          style: TextStyle(fontSize: 12.5)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Étapes du workflow
  // ─────────────────────────────────────────────────────────────────────────

  Widget _stepTile(
    BuildContext context,
    WidgetRef ref, {
    required Order order,
    required WorkflowInstance instance,
    required List<WorkflowStepState> states,
    required WorkflowStepState step,
    required bool isCurrent,
  }) {
    final done = step.statut == 'terminee';
    return InkWell(
      onTap: isCurrent ? () => _confirmCompleteStep(context, ref, order, instance, states) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              done
                  ? Icons.check_circle
                  : isCurrent
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
              size: 18,
              color: done
                  ? MsnColors.success
                  : isCurrent
                      ? MsnColors.primary
                      : MsnColors.textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                step.nom,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                  color: done
                      ? MsnColors.textSecondary
                      : MsnColors.textPrimary,
                ),
              ),
            ),
            if (isCurrent && !done)
              TextButton(
                onPressed: () =>
                    _confirmCompleteStep(context, ref, order, instance, states),
                child: const Text('Terminer'),
              ),
          ],
        ),
      ),
    );
  }

  /// Validation des règles métier avant de terminer l'étape (section 23).
  Future<void> _confirmCompleteStep(
    BuildContext context,
    WidgetRef ref,
    Order order,
    WorkflowInstance instance,
    List<WorkflowStepState> states,
  ) async {
    final current = states.firstWhereOrNull((s) => s.statut != 'terminee');
    if (current == null) return;

    // Chargement des règles du service.
    final rulesRows = await ref
        .read(templatesDaoProvider)
        .rulesForService(order.serviceId);
    final rules = RuleSet.fromRows({for (final r in rulesRows) r.cle: r.valeur});
    final paid =
        await ref.read(paymentsDaoProvider).totalForOrder(order.id);
    final filesList =
        await ref.read(ordersDaoProvider).watchFilesForOrder(order.id).first;
    final nbFiles = filesList.length;
    final devisAccepte = order.quoteId != null;
    final ctx = await buildRuleContext(
      ref,
      order: order,
      paidTotal: paid,
      states: states,
      stepName: current.nom,
      devisAccepte: devisAccepte,
      nbFichiers: nbFiles,
    );
    final violations = BusinessRuleEngine.verifier(rules, ctx);

    if (violations.isNotEmpty && context.mounted) {
      final session = ref.read(sessionProvider);
      final canOverride =
          BusinessRuleEngine.exceptionPossible(violations) &&
              (session?.isAdmin ?? false);
      final override = await _showViolationsDialog(
          context, violations, canOverride);
      if (override == null) return; // annulé
      if (override.isNotEmpty) {
        await recordRuleException(
          ref,
          orderId: order.id,
          ruleKey: violations.first.cle,
          raison: override,
          userName: session?.userName ?? 'admin',
        );
      } else {
        return; // refus de l'exception → étape non terminée
      }
    }

    final idx = states.indexOf(current);
    await completeStep(
      ref,
      order: order,
      instance: instance,
      stepState: current,
      nextIndex: idx + 1,
    );
  }

  Future<String?> _showViolationsDialog(
    BuildContext context,
    List<RuleViolation> violations,
    bool canOverride,
  ) {
    final raisonController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Règles métier non satisfaites'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...violations.map((v) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.block, size: 16, color: MsnColors.danger),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(v.message,
                              style: const TextStyle(fontSize: 12.5))),
                    ],
                  ),
                )),
            if (canOverride) ...[
              const SizedBox(height: 4),
              TextField(
                controller: raisonController,
                decoration: const InputDecoration(
                  labelText: 'EXCEPTION AUTORISÉE — raison obligatoire',
                  hintText: 'Ex. client de confiance, acompte promis demain…',
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          if (canOverride)
            FilledButton(
              onPressed: () {
                final raison = raisonController.text.trim();
                if (raison.isEmpty) return;
                Navigator.pop(context, raison);
              },
              child: const Text('Autoriser l’exception'),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Actions prêtes de l'étape courante
  // ─────────────────────────────────────────────────────────────────────────

  Widget _readyActions(
    BuildContext context,
    WidgetRef ref,
    Order order,
    WorkflowInstance instance,
    WorkflowStepState step,
    List<WorkflowStepState> states,
  ) {
    final codes = _actionsOf(step);
    return Card(
      color: MsnColors.accentSoft,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (final code in codes) _actionButton(context, ref, order, code),
            if (codes.isEmpty)
              const Text(
                  'Aucune action prête sur cette étape — marquez-la '
                  'terminée quand le travail est fait.',
                  style: TextStyle(
                      fontSize: 12, color: MsnColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  List<String> _actionsOf(WorkflowStepState step) {
    try {
      final decoded = jsonDecode(step.actionsJson) as List<dynamic>;
      return decoded.cast<String>();
    } catch (_) {
      return const [];
    }
  }

  Widget _actionButton(
      BuildContext context, WidgetRef ref, Order order, String code) {
    final type = ActionCatalog.typeOf(code);
    final label = ActionCatalog.labels[code] ?? code;
    final icon = switch (type) {
      ActionType.message ||
      ActionType.messagePaiement =>
        Icons.chat_bubble_outline,
      ActionType.paiement => Icons.payments_outlined,
      ActionType.fichiers => Icons.attach_file,
      ActionType.production => Icons.computer,
      ActionType.validation => Icons.fact_check_outlined,
      ActionType.tache => Icons.checklist,
    };

    Future<void> onTap() async {
      switch (type) {
        case ActionType.message:
          final args = await _composerArgs(ref, order, code);
          if (context.mounted) {
            context.push('/communication/composer',
                extra: args ?? ComposerArgs(reference: order.reference));
          }
          break;
        case ActionType.messagePaiement:
          final args = await _composerArgs(ref, order, code);
          if (context.mounted) {
            context.push('/communication/composer',
                extra: args ?? ComposerArgs(reference: order.reference));
          }
          break;
        case ActionType.paiement:
          if (context.mounted) {
            context.push('/payments/new?orderId=${order.id}');
          }
          break;
        case ActionType.fichiers:
          try {
            final file = await ref.read(fileIngestServiceProvider).pickAndAttach(
                  orderId: order.id,
                  requestId: null,
                  dossier: DossierFichier.source,
                  note: 'Étape : $label',
                );
            if (file != null && context.mounted) {
              showMsnSnack(context, 'Fichier ajouté : ${file.nom}');
            }
          } catch (e) {
            if (context.mounted) showMsnSnack(context, e.toString(), error: true);
          }
          break;
        case ActionType.production:
          showMsnSnack(context,
              'La production se fait sur le PC. Transférez la commande '
              'quand la checklist est verte.');
          break;
        case ActionType.validation:
          final args = await _composerArgs(ref, order, code);
          if (context.mounted) {
            context.push('/communication/composer',
                extra: args ?? ComposerArgs(reference: order.reference));
          }
          break;
        case ActionType.tache:
          showMsnSnack(context, 'Étape « $label » : marquez-la terminée '
              'une fois le travail effectué.');
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(label, style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }

  /// Prépare le contexte du compositeur avec toutes les variables
  /// déjà remplies (client, montants, solde…).
  Future<ComposerArgs?> _composerArgs(
      WidgetRef ref, Order order, String code) async {
    final full = await ref.read(ordersDaoProvider).byId(order.id);
    final client = full?.client;
    final service = order.serviceId == null
        ? null
        : (await ref.read(catalogDaoProvider).serviceById(order.serviceId!))?.service;
    final paid =
        await ref.read(paymentsDaoProvider).totalForOrder(order.id);
    final solde = order.montantTotal - paid;

    TemplateCategorie? categorie;
    if (code == ActionCatalog.messageAccueil) categorie = TemplateCategorie.accueil;
    if (code == ActionCatalog.demanderAcompte) {
      categorie = TemplateCategorie.demandeAcompte;
    }
    if (code == ActionCatalog.demanderSolde) categorie = TemplateCategorie.solde;
    if (code == ActionCatalog.demanderValidation) {
      categorie = TemplateCategorie.validation;
    }
    if (code == ActionCatalog.demanderFichiers) {
      categorie = TemplateCategorie.demandeFichier;
    }
    if (code == ActionCatalog.messageTarif) {
      categorie = TemplateCategorie.presentationTarif;
    }

    return ComposerArgs(
      categorie: categorie,
      clientNom: client?.nom,
      serviceNom: service?.nom,
      reference: order.reference,
      montant: code == ActionCatalog.demanderAcompte
          ? order.acompteRequis
          : (code == ActionCatalog.demanderSolde ? solde : null),
      solde: solde > 0 ? solde : null,
      delai: order.deadline == null ? null : Formatters.date(order.deadline),
      attachOrderId: order.id,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Transfert PC (section 20)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _transferCard(
    BuildContext context,
    WidgetRef ref,
    Order order,
    List<WorkflowStepState> states,
    int paid,
    List<OrderFile> files,
  ) {
    final devisOk = order.quoteId != null;
    final briefOk = order.briefComplet;
    final items = TransferChecklist.verifier(TransferContext(
      clientIdentifie: true,
      serviceDefini: order.serviceId != null,
      briefTermine: briefOk,
      devisAccepte: devisOk,
      conditionsAcceptees: order.conditionsAcceptees,
      acompteRequis: order.acompteRequis,
      acomptePaye: paid,
      deadlineDefinie: order.deadline != null,
      nbFichiers: files.length,
      workflowSelectionne: states.isNotEmpty,
    ));
    final pret = TransferChecklist.pretPourTransfert(items);
    final dejaTransfere = order.transferePc;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('TRANSFERT VERS LE PC',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: MsnColors.textSecondary)),
                const Spacer(),
                if (dejaTransfere)
                  const Icon(Icons.check_circle,
                      color: MsnColors.success, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            ...items.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        i.ok ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 16,
                        color: i.ok ? MsnColors.success : MsnColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          i.ok ? i.label : '${i.label} — ${i.detail ?? ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: i.ok
                                ? MsnColors.textPrimary
                                : MsnColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
            if (dejaTransfere)
              const Text(
                'Commande transférée. Le PC récupérera les informations à '
                'la prochaine synchronisation et créera les dossiers '
                'de production (SOURCE, TRAVAIL, CORRECTIONS, FINAL, DOCUMENTS).',
                style: TextStyle(fontSize: 12, color: MsnColors.success),
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: pret ? () => _doTransfer(context, ref, order) : null,
                  icon: const Icon(Icons.computer, size: 18),
                  label: const Text('TRANSFÉRER AU PC'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _doTransfer(
      BuildContext context, WidgetRef ref, Order order) async {
    final ok = await confirmAction(
      context,
      title: 'Transférer au PC ?',
      message:
          'La commande ${order.reference} sera marquée « prête pour '
          'production » et transmise au système PC à la synchronisation.',
      confirmLabel: 'Transférer',
    );
    if (!ok) return;
    await transferToPc(ref, order);
    if (context.mounted) {
      showMsnSnack(context,
          'Commande transférée au PC. Pensez à vous synchroniser.');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Fichiers par dossier
  // ─────────────────────────────────────────────────────────────────────────

  Widget _filesSection(BuildContext context, WidgetRef ref, Order order,
      List<OrderFile> files) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('FICHIERS DE LA COMMANDE',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: MsnColors.textSecondary)),
                const Spacer(),
                PopupMenuButton<DossierFichier>(
                  tooltip: 'Joindre un fichier',
                  icon: const Icon(Icons.add, size: 20),
                  onSelected: (dossier) async {
                    try {
                      final file = await ref
                          .read(fileIngestServiceProvider)
                          .pickAndAttach(
                            orderId: order.id,
                            requestId: null,
                            dossier: dossier,
                          );
                      if (file != null && context.mounted) {
                        showMsnSnack(context,
                            'Fichier ajouté dans ${dossier.label}.');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showMsnSnack(context, e.toString(), error: true);
                      }
                    }
                  },
                  itemBuilder: (_) => DossierFichier.values
                      .map((d) => PopupMenuItem(
                            value: d,
                            child: Text('Ajouter dans ${d.label}'),
                          ))
                      .toList(),
                ),
              ],
            ),
            if (files.isEmpty)
              const Text(
                'Aucun fichier. Les copies locales sont organisées comme '
                'sur le PC : CMD-…/SOURCE, TRAVAIL, CORRECTIONS, FINAL, DOCUMENTS.',
                style: TextStyle(
                    fontSize: 12, color: MsnColors.textSecondary),
              )
            else
              ...files.map(
                (f) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.insert_drive_file, size: 18),
                  title: Text(f.nom, style: const TextStyle(fontSize: 12.5)),
                  subtitle: Text('${f.dossier.label} · ${f.origine}',
                      style: const TextStyle(fontSize: 10.5)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (f.cheminLocal != null)
                        IconButton(
                          icon: const Icon(Icons.share, size: 16),
                          onPressed: () => ref
                              .read(shareServiceProvider)
                              .shareFile(f.cheminLocal!, subject: f.nom),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 16),
                        onPressed: () async {
                          final ok = await confirmAction(context,
                              title: 'Supprimer ?',
                              message: '« ${f.nom} » sera supprimé.',
                              danger: true);
                          if (ok) {
                            await ref
                                .read(fileIngestServiceProvider)
                                .deleteFile(f);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
