/// Données de démonstration (fictives — aucune donnée personnelle réelle).
///
/// Insérées au premier lancement, contrôlées par la clé de paramètres
/// `demo_seeded`. Elles permettent de tester immédiatement l'ensemble du
/// cycle métier : demandes, devis, commandes, factures, paiements…
///
/// Comptes de démo : Admin (PIN 1234, administrateur) / Faniry (PIN 1111,
/// opérateur) — à changer immédiatement en production.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../../utils/id_generator.dart';
import '../../constants/app_constants.dart';
import '../app_database.dart';
import '../daos/system_dao.dart';
import 'default_content.dart';

class DemoData {
  DemoData._();

  static String hashPin(String pin) =>
      sha256.convert(utf8.encode('msn-$pin')).toString();

  /// Insère les données de démo si ce n'est pas déjà fait.
  static Future<void> seedIfNeeded(AppDatabase db) async {
    final system = SystemDao(db);
    final already = await system.getValue(AppConstants.keySeeded);
    if (already == '1') return;

    final now = DateTime.now();
    final year = now.year;

    // ── Utilisateurs ──────────────────────────────────────────────────────
    await system.upsertUser(User(
      id: 'user_admin',
      nom: 'Admin',
      pinHash: hashPin('1234'),
      role: UserRole.admin,
      actif: true,
      createdAt: now,
    ));
    await system.upsertUser(User(
      id: 'user_operateur',
      nom: 'Faniry',
      pinHash: hashPin('1111'),
      role: UserRole.operateur,
      actif: true,
      createdAt: now,
    ));

    // ── Modules ───────────────────────────────────────────────────────────
    const modules = {
      'clients': true,
      'requests': true,
      'orders': true,
      'quotes': true,
      'invoices': true,
      'payments': true,
      'catalog': true,
      'communication': true,
      'documents': true,
      'workflows': true,
      'tasks': true,
      'files': true,
      'sync': true,
      'admin': true,
      'crm_avance': false,
      'comptabilite_avance': false,
      'module_avance': false,
    };
    var ordre = 0;
    for (final entry in modules.entries) {
      await db.into(db.moduleFlags).insertOnConflictUpdate(
            ModuleFlagsCompanion.insert(
              code: entry.key,
              actif: Value(entry.value),
              ordre: Value(ordre++),
            ),
          );
    }

    // ── Paramètres ────────────────────────────────────────────────────────
    await system.setValue(
        AppConstants.keyCompanyName, 'MSN Multi-Services Numériques');
    await system.setValue(
        AppConstants.keyCompanyPhone, AppConstants.defaultCompanyPhone);
    await system.setValue(
        AppConstants.keyCompanyEmail, AppConstants.defaultCompanyEmail);
    await system.setValue(AppConstants.keyDefaultAcomptePercent, '40');

    // ── Catégories (6 branches) — source unique : DefaultCatalog ─────────
    var catOrdre = 0;
    for (final entry in DefaultContent.defaultCategories.entries) {
      await db.into(db.categories).insert(CategoriesCompanion.insert(
            id: entry.key,
            nom: entry.value,
            ordre: Value(catOrdre++),
          ));
    }

    // ── Services & tarifs — source unique : DefaultCatalog ────────────────
    for (final entry in DefaultContent.defaultServices.entries) {
      final s = entry.value;
      await db.into(db.services).insert(ServicesCompanion.insert(
            id: entry.key,
            nom: s.nom,
            categoryId: Value(s.cat),
            prixBase: Value(s.prix),
            unite: Value(s.unite),
            delaiJours: Value(s.delai),
            description: Value(s.desc),
            inclus: Value(s.inclus),
            exclusions: const Value(
                'Tout ce qui n\u2019est pas listé dans « inclus » fait '
                'l\u2019objet d\u2019un devis séparé.'),
            conditions: const Value(
                'Tarif « à partir de » : le prix final dépend de la '
                'complexité et du volume du projet.'),
          ));
    }

    // ── Workflows ─────────────────────────────────────────────────────────
    const logoSteps = [
      'Réception',
      'Qualification',
      'Devis',
      'Validation',
      'Acompte',
      'Brief complet',
      'Production',
      'Proposition V1',
      'Correction',
      'Validation finale',
      'Livraison',
      'Paiement final',
      'Archivage',
    ];
    const memoireSteps = [
      'Réception',
      'Analyse',
      'Devis',
      'Validation',
      'Acompte',
      'Réception fichiers',
      'Production PC',
      'Contrôle',
      'Correction',
      'Validation',
      'Livraison',
      'Paiement final',
      'Archivage',
    ];
    const genericSteps = [
      'Réception',
      'Qualification',
      'Devis',
      'Validation',
      'Acompte',
      'Production',
      'Livraison',
      'Paiement final',
      'Archivage',
    ];

    Future<void> createWorkflow(String id, String nom, String? serviceId,
        List<String> steps) async {
      await db.into(db.workflowTemplates).insert(
            WorkflowTemplatesCompanion.insert(
              id: id,
              nom: nom,
              serviceId: Value(serviceId),
            ),
          );
      var i = 0;
      for (final step in steps) {
        await db.into(db.workflowSteps).insert(WorkflowStepsCompanion.insert(
              id: '${id}_s$i',
              workflowId: id,
              ordre: i,
              nom: step,
              actionsJson: Value(jsonEncode(_actionsFor(step))),
            ));
        i++;
      }
    }

    await createWorkflow('wf_logo', 'Workflow Logo', 'svc_logo', logoSteps);
    await createWorkflow(
        'wf_memoire', 'Workflow Mémoire', 'svc_memoire', memoireSteps);
    await createWorkflow('wf_generic', 'Workflow générique', null, genericSteps);

    // ── Règles métier (Logo) ──────────────────────────────────────────────
    const logoRules = {
      RuleKeys.acompteObligatoire: 'true',
      RuleKeys.propositionsIncluses: '2',
      RuleKeys.correctionsIncluses: '2',
      RuleKeys.paiementFinalAvantLivraison: 'true',
      RuleKeys.validationFinaleObligatoire: 'true',
    };
    for (final entry in logoRules.entries) {
      await db.into(db.businessRules).insert(BusinessRulesCompanion.insert(
            id: 'rule_logo_${entry.key}',
            serviceId: const Value('svc_logo'),
            cle: entry.key,
            valeur: entry.value,
          ));
    }

    // ── Formulaires de qualification ──────────────────────────────────────
    Future<void> createForm(String formId, String serviceId,
        List<(String, QuestionType, bool)> questions) async {
      await db.into(db.qualificationForms).insert(
            QualificationFormsCompanion.insert(
              id: formId,
              serviceId: Value(serviceId),
              nom: 'Formulaire de qualification',
            ),
          );
      var i = 0;
      for (final q in questions) {
        await db.into(db.qualificationQuestions).insert(
              QualificationQuestionsCompanion.insert(
                id: '${formId}_q$i',
                formId: formId,
                ordre: Value(i),
                label: q.$1,
                type: Value(q.$2),
                obligatoire: Value(q.$3),
              ),
            );
        i++;
      }
    }

    await createForm('form_logo', 'svc_logo', const [
      ("Nom de l'entreprise", QuestionType.texte, true),
      ("Activité de l'entreprise", QuestionType.texte, true),
      ('Public cible', QuestionType.texte, false),
      ('Objectif du logo', QuestionType.multiligne, false),
      ('Style souhaité', QuestionType.liste, false),
      ('Couleurs préférées', QuestionType.texte, false),
      ('Utilisations prévues', QuestionType.texte, false),
      ('Références (exemples aimés)', QuestionType.multiligne, false),
      ('Éléments à éviter', QuestionType.texte, false),
      ('Deadline', QuestionType.date, true),
    ]);

    await createForm('form_memoire', 'svc_memoire', const [
      ('Établissement', QuestionType.texte, true),
      ('Niveau (L1, L2, L3, M1, M2…)', QuestionType.texte, true),
      ('Nombre de pages', QuestionType.nombre, true),
      ('Type de travail', QuestionType.liste, false),
      ('Consignes particulières', QuestionType.multiligne, true),
      ('Fichier source', QuestionType.texte, false),
      ('Deadline', QuestionType.date, true),
      ('Type de mise en page', QuestionType.liste, false),
    ]);

    await createForm('form_affiche', 'svc_affiche_simple', const [
      ('Format (A5, A4, A3…)', QuestionType.liste, true),
      ('Événement', QuestionType.texte, true),
      ('Texte principal', QuestionType.multiligne, true),
      ('Date de l’événement', QuestionType.date, false),
      ('Lieu', QuestionType.texte, false),
      ('Contact à afficher', QuestionType.texte, false),
      ('Images fournies ?', QuestionType.texte, false),
      ('Couleurs', QuestionType.texte, false),
      ('Format d’impression', QuestionType.texte, false),
    ]);

    // ── Modèles de messages ───────────────────────────────────────────────
    const templates = [
      (
        'tpl_accueil',
        'ACCUEIL',
        TemplateCategorie.accueil,
        'Accueil',
        'Bonjour {{PRENOM}}, merci d’avoir contacté MSN — Multi-Services '
            'Numériques ! Je suis à votre disposition pour {{SERVICE}}. '
            'Comment puis-je vous aider ?'
      ),
      (
        'tpl_info',
        'DEMANDE_INFO',
        TemplateCategorie.demandeInfo,
        'Demande d’information',
        'Bonjour {{PRENOM}}, pour bien préparer votre projet {{SERVICE}}, '
            'pouvez-vous me préciser : votre besoin exact, la quantité ou le '
            'format souhaité, ainsi que la date à laquelle vous en avez besoin ?'
      ),
      (
        'tpl_tarif',
        'PRESENTATION_TARIF',
        TemplateCategorie.presentationTarif,
        'Présentation tarifaire',
        'Bonjour {{PRENOM}}, voici notre tarif pour {{SERVICE}} :\n\n'
            '{{MONTANT}}\nDélai : {{DELAI}}\n\n'
            'Le prix inclut les fichiers finaux (PDF + PNG). '
            'Souhaitez-vous que je prépare un devis officiel ?'
      ),
      (
        'tpl_devis',
        'DEVIS',
        TemplateCategorie.devis,
        'Envoi du devis',
        'Bonjour {{PRENOM}}, voici votre devis {{REFERENCE}} pour {{SERVICE}}.'
            '\n\nMontant total : {{MONTANT}}\nAcompte : {{SOLDE}} à la commande'
            '\nDélai : {{DELAI}}\n\nLe devis est valable 15 jours. Dès votre '
            'accord et l’acompte reçu, nous démarrons le travail.'
      ),
      (
        'tpl_confirmation',
        'CONFIRMATION',
        TemplateCategorie.confirmation,
        'Confirmation de commande',
        'Bonjour {{PRENOM}}, votre commande {{REFERENCE}} est confirmée ! '
            'Nous commençons immédiatement. Deadline : {{DELAI}}. '
            'Merci de votre confiance.'
      ),
      (
        'tpl_acompte',
        'DEMANDE_ACOMPTE',
        TemplateCategorie.demandeAcompte,
        "Demande d'acompte",
        'Bonjour {{PRENOM}}, pour démarrer votre commande {{REFERENCE}}, '
            'nous avons besoin d’un acompte de {{MONTANT}}.\n\n'
            'MVola : 034 00 000 00\nOrange Money : 032 00 000 00\n'
            'Airtel Money : 033 00 000 00\n\n'
            'Dès réception, la production commence. Reste à payer après '
            'livraison : {{SOLDE}}.'
      ),
      (
        'tpl_paiement_recu',
        'PAIEMENT_RECU',
        TemplateCategorie.paiementRecu,
        'Réception de paiement',
        'Bonjour {{PRENOM}}, nous avons bien reçu votre paiement de '
            '{{MONTANT}} pour {{REFERENCE}}. Merci !\nSolde restant : {{SOLDE}}.'
      ),
      (
        'tpl_fichiers',
        'DEMANDE_FICHIER',
        TemplateCategorie.demandeFichier,
        'Demande de fichiers',
        'Bonjour {{PRENOM}}, pour avancer sur {{REFERENCE}}, merci de nous '
            'envoyer les fichiers suivants : texte, logos ou photos. '
            'Vous pouvez les joindre directement ici.'
      ),
      (
        'tpl_validation',
        'DEMANDE_VALIDATION',
        TemplateCategorie.validation,
        'Demande de validation',
        'Bonjour {{PRENOM}}, voici la proposition pour {{REFERENCE}}. '
            'Si tout vous convient, répondez « VALIDÉ » pour que nous passions '
            'à la suite. Sinon, dites-nous quoi ajuster.'
      ),
      (
        'tpl_correction',
        'CORRECTION',
        TemplateCategorie.correction,
        'Message de correction',
        'Bonjour {{PRENOM}}, bien noté pour vos retours sur {{REFERENCE}}. '
            'Nous appliquons les corrections et vous renvoyons une nouvelle '
            'version rapidement.'
      ),
      (
        'tpl_relance',
        'RELANCE',
        TemplateCategorie.relance,
        'Relance client',
        'Bonjour {{PRENOM}}, petit point rapide sur votre demande '
            '{{REFERENCE}} : avez-vous pu nous transmettre les informations ? '
            'Nous voulons respecter le délai de {{DELAI}}.'
      ),
      (
        'tpl_livraison',
        'LIVRAISON',
        TemplateCategorie.livraison,
        'Livraison',
        'Bonjour {{PRENOM}}, votre commande {{REFERENCE}} est prête ! '
            'Vous trouverez les fichiers finaux en pièce jointe. '
            'N’hésitez pas si vous avez besoin d’un ajustement.'
      ),
      (
        'tpl_solde',
        'DEMANDE_SOLDE',
        TemplateCategorie.solde,
        'Demande du solde',
        'Bonjour {{PRENOM}}, votre commande {{REFERENCE}} est livrée. '
            'Il reste un solde de {{MONTANT}} à régler.\n\n'
            'MVola : 034 00 000 00\nOrange Money : 032 00 000 00\n'
            'Airtel Money : 033 00 000 00\nMerci !'
      ),
      (
        'tpl_remerciement',
        'REMERCIEMENT',
        TemplateCategorie.remerciement,
        'Remerciement',
        'Bonjour {{PRENOM}}, merci d’avoir confié votre projet {{SERVICE}} à '
            'MSN ! N’hésitez pas à nous recommander autour de vous. À bientôt !'
      ),
    ];
    var tplOrdre = 0;
    for (final t in templates) {
      await db.into(db.messageTemplates).insert(
            MessageTemplatesCompanion.insert(
              id: t.$1,
              code: t.$2,
              titre: t.$4,
              categorie: t.$3,
              corps: t.$5,
              ordre: Value(tplOrdre++),
            ),
          );
    }

    // ── Clients ───────────────────────────────────────────────────────────
    await db.into(db.clients).insert(ClientsCompanion.insert(
          id: 'cli_jean',
          nom: 'Jean Rakoto',
          telephone: const Value('034 12 345 67'),
          canalPrefere: const Value(Canal.messenger),
          adresse: const Value('Antananarivo, Anosy'),
          notes: const Value('Client fidèle — vient de la page Facebook.'),
        ));
    await db.into(db.clients).insert(ClientsCompanion.insert(
          id: 'cli_sarah',
          nom: 'Sarah Andriam',
          telephone: const Value('032 45 678 90'),
          canalPrefere: const Value(Canal.whatsapp),
          adresse: const Value('Antananarivo, Isotry'),
        ));
    await db.into(db.clients).insert(ClientsCompanion.insert(
          id: 'cli_abc',
          nom: 'ABC Entreprise',
          telephone: const Value('033 11 222 33'),
          email: const Value('contact@abc-fictive.mg'),
          canalPrefere: const Value(Canal.autre),
          adresse: const Value('Antsirabe'),
          notes: const Value('Société — factures au nom de la société.'),
        ));

    // ── Demandes ──────────────────────────────────────────────────────────
    final seqReq1 = await db.nextSequence('REQ', year);
    await db.into(db.requests).insert(RequestsCompanion.insert(
          id: 'req_demo1',
          reference: IdGenerator.formatReference('REQ', year, seqReq1),
          clientId: 'cli_jean',
          canal: Canal.messenger,
          serviceId: const Value('svc_logo'),
          description:
              const Value('Veut un logo pour sa petite entreprise de couture.'),
          deadlineSouhaitee: Value(now.add(const Duration(days: 7))),
          priorite: const Value(Priorite.haute),
          statut: const Value(RequestStatut.qualifiee),
          notes: const Value('A déjà vu notre page — très motivé.'),
          qualificationJson: const Value(
              '{"Nom de l\'entreprise":"Rakoto Couture","Activité de '
              'l\'entreprise":"Couture sur mesure","Public cible":"Femmes '
              '25-45 ans","Style souhaité":"Moderne"}'),
        ));
    final seqReq2 = await db.nextSequence('REQ', year);
    await db.into(db.requests).insert(RequestsCompanion.insert(
          id: 'req_demo2',
          reference: IdGenerator.formatReference('REQ', year, seqReq2),
          clientId: 'cli_sarah',
          canal: Canal.whatsapp,
          serviceId: const Value('svc_cv'),
          description: const Value('Refonte de son CV pour une candidature.'),
          deadlineSouhaitee: Value(now.add(const Duration(days: 2))),
          budget: const Value(15000),
        ));

    // ── Devis accepté → commande en production ────────────────────────────
    final seqDev = await db.nextSequence('DEV', year);
    await db.into(db.quotes).insert(QuotesCompanion.insert(
          id: 'dev_demo1',
          reference: IdGenerator.formatReference('DEV', year, seqDev),
          clientId: 'cli_jean',
          requestId: const Value('req_demo1'),
          statut: const Value(QuoteStatut.accepte),
          acompte: const Value(60000),
          delaiJours: const Value(7),
          conditions: const Value('2 propositions, 2 corrections incluses.'),
          montantTotal: const Value(150000),
        ));
    await db.into(db.quoteItems).insert(QuoteItemsCompanion.insert(
          id: 'dev_demo1_i0',
          quoteId: 'dev_demo1',
          serviceId: const Value('svc_logo'),
          designation: 'Création de logo',
          quantite: const Value(1.0),
          prixUnitaire: const Value(150000),
        ));

    final seqCmd = await db.nextSequence('CMD', year);
    await db.into(db.orders).insert(OrdersCompanion.insert(
          id: 'cmd_demo1',
          reference: IdGenerator.formatReference('CMD', year, seqCmd),
          clientId: 'cli_jean',
          serviceId: const Value('svc_logo'),
          requestId: const Value('req_demo1'),
          quoteId: const Value('dev_demo1'),
          titre: 'Logo Rakoto Couture',
          statut: const Value(OrderStatut.enCours),
          deadline: Value(now.add(const Duration(days: 7))),
          montantTotal: const Value(150000),
          acompteRequis: const Value(60000),
          briefComplet: const Value(true),
          conditionsAcceptees: const Value(true),
          notes:
              const Value('Style moderne, couleurs bleu et blanc demandées.'),
        ));
    await db.into(db.workflowInstances).insert(
          WorkflowInstancesCompanion.insert(
            id: 'wfi_demo1',
            orderId: 'cmd_demo1',
            workflowId: 'wf_logo',
            currentStepIndex: const Value(6),
          ),
        );
    var stepIdx = 0;
    for (final step in logoSteps) {
      final done = stepIdx < 6;
      await db.into(db.workflowStepStates).insert(
            WorkflowStepStatesCompanion.insert(
              id: 'wfi_demo1_s$stepIdx',
              instanceId: 'wfi_demo1',
              stepId: 'wf_logo_s$stepIdx',
              ordre: stepIdx,
              nom: step,
              actionsJson: Value(jsonEncode(_actionsFor(step))),
              statut: Value(done ? 'terminee' : 'en_attente'),
              completedAt: Value(
                  done ? now.subtract(Duration(days: 6 - stepIdx)) : null),
            ),
          );
      stepIdx++;
    }
    // Fichier SOURCE côté commande.
    await db.into(db.orderFiles).insert(OrderFilesCompanion.insert(
          id: 'file_demo1',
          orderId: const Value('cmd_demo1'),
          dossier: const Value(DossierFichier.source),
          nom: 'brief_logo_rakoto.txt',
          origine: const Value('mobile'),
          note: const Value('Brief validé par le client.'),
        ));

    // ── Facture partiellement payée + paiements ───────────────────────────
    final seqFac = await db.nextSequence('FAC', year);
    await db.into(db.invoices).insert(InvoicesCompanion.insert(
          id: 'fac_demo1',
          reference: IdGenerator.formatReference('FAC', year, seqFac),
          clientId: 'cli_jean',
          orderId: const Value('cmd_demo1'),
          quoteId: const Value('dev_demo1'),
          statut: const Value(InvoiceStatut.partiellementPayee),
          montantTotal: const Value(150000),
          dateEcheance: Value(now.add(const Duration(days: 5))),
        ));
    await db.into(db.invoiceItems).insert(InvoiceItemsCompanion.insert(
          id: 'fac_demo1_i0',
          invoiceId: 'fac_demo1',
          serviceId: const Value('svc_logo'),
          designation: 'Création de logo',
          quantite: const Value(1.0),
          prixUnitaire: const Value(150000),
        ));

    final seqPmt = await db.nextSequence('PMT', year);
    await db.into(db.payments).insert(PaymentsCompanion.insert(
          id: 'pmt_demo1',
          reference: IdGenerator.formatReference('PMT', year, seqPmt),
          clientId: const Value('cli_jean'),
          invoiceId: const Value('fac_demo1'),
          orderId: const Value('cmd_demo1'),
          montant: 60000,
          methode: PaymentMethode.mvola,
          referenceExterne: const Value('MV-20260101-4455'),
          note: const Value('Acompte reçu dès la validation du devis.'),
          datePaiement: Value(now.subtract(const Duration(days: 4))),
        ));

    // ── Rappels & tâches ──────────────────────────────────────────────────
    await db.into(db.reminders).insert(RemindersCompanion.insert(
          id: 'rem_demo1',
          titre: 'Livrer le logo Rakoto Couture',
          type: ReminderType.deadline,
          cibleType: const Value('order'),
          cibleId: const Value('cmd_demo1'),
          dateRappel: now.add(const Duration(days: 7)),
          description: const Value('Deadline convenue avec le client.'),
        ));
    await db.into(db.tasks).insert(TasksCompanion.insert(
          id: 'task_demo1',
          titre: 'Envoyer la proposition V1 au client Jean',
          description:
              const Value('Après production PC, partager les 2 propositions.'),
          priorite: const Value(Priorite.haute),
          echeance: Value(now.add(const Duration(days: 1))),
          cibleType: const Value('order'),
          cibleId: const Value('cmd_demo1'),
        ));

    // ── Journal initial ───────────────────────────────────────────────────
    await db.into(db.activityLog).insert(ActivityLogCompanion.insert(
          id: 'act_seed1',
          userName: 'Admin',
          action: ActivityAction.creation,
          entite: 'commande',
          entityId: const Value('cmd_demo1'),
          details: 'Commande de démonstration créée (données fictives).',
        ));

    await system.setValue(AppConstants.keySeeded, '1');
  }

  /// Actions prêtes par étape, utilisées dans les workflows de démo.
  static List<String> _actionsFor(String step) {
    const map = {
      'Réception': ['MESSAGE_ACCUEIL'],
      'Qualification': ['ANALYSE'],
      'Analyse': ['ANALYSE'],
      'Devis': ['MESSAGE_TARIF', 'MESSAGE_DEVIS'],
      'Validation': ['DEMANDER_VALIDATION', 'VALIDER'],
      'Acompte': ['DEMANDER_ACOMPTE', 'ENREGISTRER_ACOMPTE'],
      'Brief complet': ['RECEVOIR_FICHIERS'],
      'Réception fichiers': ['DEMANDER_FICHIERS', 'RECEVOIR_FICHIERS'],
      'Production': ['PRODUIRE'],
      'Production PC': ['PRODUIRE'],
      'Proposition V1': ['PROPOSER_LIVRAISON', 'DEMANDER_VALIDATION'],
      'Contrôle': ['CONTROLE'],
      'Correction': ['APPLIQUER_CORRECTIONS'],
      'Validation finale': ['DEMANDER_VALIDATION', 'VALIDER'],
      'Livraison': ['LIVRER'],
      'Paiement final': ['DEMANDER_SOLDE', 'ENREGISTRER_PAIEMENT'],
      'Archivage': ['ARCHIVER'],
    };
    return map[step] ?? const [];
  }
}
