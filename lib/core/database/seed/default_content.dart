/// Contenus par défaut administrables — v4.
///
/// Contrairement aux données de démonstration (insérées une seule fois),
/// ces contenus sont garantis présents sur TOUTES les installations :
/// `ensureDefaults` est appelé à chaque démarrage et n'insère que ce qui
/// manque (tables vides ou étapes sans instructions).
///
/// Tout ce contenu reste modifiable/supprimable depuis l'administration :
/// l'application ne recode jamais ces textes en dur dans l'interface.
library;


import 'package:drift/drift.dart' show Value;

import '../app_database.dart';
import '../daos/templates_dao.dart';
import '../daos/workflows_dao.dart';

class DefaultContent {
  DefaultContent._();

  static Future<void> ensureDefaults(AppDatabase db) async {
    await _ensureConditions(db);
    await _ensureDictionary(db);
    await _ensureProcessSteps(db);
    await _ensureWorkflowInstructions(db);
    await _ensureQuestionOptions(db);
  }

  // ── Options des questions de qualification de type « liste » ─────────────

  /// Une question de liste SANS options produit un menu vide inutilisable
  /// (champ « grisé » aux yeux de l'opérateur). Ce correctif garantit que
  /// toute question de liste a des options : options standard pour les
  /// questions connues, option générique pour les autres. Idempotent.
  static Future<void> _ensureQuestionOptions(AppDatabase db) async {
    const known = <String, List<String>>{
      'type de travail': ['Mémoire', 'Rapport de stage', 'Thèse',
        'Article', 'Exposé', 'Autre'],
      'type de mise en page': ['Standard', 'Avancée',
        'Selon modèle fourni'],
      'style souhaité': ['Moderne', 'Minimaliste', 'Vintage',
        'Ludique', 'Corporate'],
      'format (a5, a4, a3…)': ['A5', 'A4', 'A3', 'A2', 'Personnalisé'],
      'niveau': ['L1', 'L2', 'L3', 'M1', 'M2', 'Doctorat'],
    };
    final questions = await db.select(db.qualificationQuestions).get();
    for (final q in questions) {
      if (q.type != 'liste' ||
          (q.optionsJson != null && q.optionsJson!.trim().isNotEmpty)) {
        continue;
      }
      final key = q.label.toLowerCase().trim();
      final options = known.containsKey(key)
          ? known[key]!
          : const ['À préciser avec le client'];
      await (db.update(db.qualificationQuestions)
            ..where((t) => t.id.equals(q.id)))
          .write(QualificationQuestionsCompanion(
        optionsJson: Value('[${options.map((o) => '"$o"').join(',')}]'),
      ));
    }
  }

  // ── Conditions contractuelles ─────────────────────────────────────────────

  static Future<void> _ensureConditions(AppDatabase db) async {
    final dao = TemplatesDao(db);
    if (await dao.countConditions() > 0) return;

    final now = DateTime.now();
    const defaults = <(String titre, String contenu, String categorie)>[
      (
        'Acompte',
        'Un acompte de 50% est requis avant le démarrage du travail. '
            'Le solde est payable à la livraison.',
        'devis',
      ),
      (
        'Validité du devis',
        'Ce devis est valable 15 jours à compter de sa date d’envoi. '
            'Passé ce délai, les tarifs peuvent être révisés.',
        'devis',
      ),
      (
        'Fichiers du client',
        'Le client fournit tous les fichiers sources (textes, images, '
            'logos) avant le début de la production.',
        'devis',
      ),
      (
        'Retouches',
        'Deux séries de retouches sont incluses. Les retouches '
            'supplémentaires sont facturées séparément.',
        'devis',
      ),
      (
        'Délai de réalisation',
        'Le délai court à compter de la validation du devis et de la '
            'réception complète des fichiers.',
        'devis',
      ),
      (
        'Propriété intellectuelle',
        'Les droits d’usage complets sont cédés au client après le '
            'paiement intégral de la facture.',
        'facture',
      ),
      (
        'Paiement',
        'Paiement par Mobile Money (MVola, Orange Money, Airtel Money) '
            'ou en espèces. Une facture est émise pour chaque règlement.',
        'facture',
      ),
    ];
    for (var i = 0; i < defaults.length; i++) {
      final (titre, contenu, categorie) = defaults[i];
      await dao.upsertCondition(Condition(
        id: 'cond_def_$i',
        titre: titre,
        contenu: contenu,
        categorie: categorie,
        actif: true,
        ordre: i,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

  // ── Dictionnaire français → malagasy ──────────────────────────────────────

  static Future<void> _ensureDictionary(AppDatabase db) async {
    final dao = TemplatesDao(db);
    if (await dao.countDictionary() > 0) return;

    final now = DateTime.now();
    const entries = <(String fr, String mg, String cat)>[
      ('Bonjour', 'Salama', 'salutations'),
      ('Merci', 'Misaotra', 'salutations'),
      ('Au revoir', 'Veloma', 'salutations'),
      ('S’il vous plaît', 'Azafady', 'politesse'),
      ('client', 'mpanjifa', 'commercial'),
      ('demande', 'fangatahana', 'commercial'),
      ('devis', 'tetikasa vidiny', 'commercial'),
      ('facture', 'facture (taratasy fandoavam-bola)', 'commercial'),
      ('paiement', 'fandoavam-bola', 'commercial'),
      ('acompte', 'andoa-m-bola voalohany', 'commercial'),
      ('solde', 'sisa tavela', 'commercial'),
      ('montant', 'vola', 'commercial'),
      ('prix', 'vidiny', 'commercial'),
      ('délai', 'fe-potoana', 'commercial'),
      ('livraison', 'fanaterana', 'commercial'),
      ('commande', 'baiko', 'commercial'),
      ('service', 'serivisy', 'commercial'),
      ('impression', 'fanontana', 'technique'),
      ('graphisme', 'fanaovana sary', 'technique'),
      ('logo', 'marika', 'technique'),
      ('flyer', 'flyer (taratasy fampahafantarana)', 'technique'),
      ('photo', 'sary', 'technique'),
      ('format', 'endrika', 'technique'),
      ('fichier', 'rakitra', 'technique'),
      ('correction', 'fanitsiana', 'technique'),
      ('validation', 'fanamarinana', 'commercial'),
      ('en cours de traitement', 'eo am-pamokarana', 'suivi'),
      ('terminé', 'vita', 'suivi'),
      ('en retard', 'tafahoatra amin’ny fe-potoana', 'suivi'),
      ('prochaine étape', 'dingana manaraka', 'suivi'),
    ];
    var index = 0;
    for (final (fr, mg, cat) in entries) {
      await dao.upsertDictionaryEntry(DictionaryEntry(
        id: 'dict_def_$index',
        termeFr: fr,
        traductionMg: mg,
        categorie: cat,
        actif: true,
        createdAt: now,
        updatedAt: now,
      ));
      index++;
    }
  }

  // ── Processus client (10 étapes, présentation) ────────────────────────────

  static Future<void> _ensureProcessSteps(AppDatabase db) async {
    final dao = WorkflowsDao(db);
    if (await dao.countProcessSteps() > 0) return;

    const steps = <(String titre, String description, String icone)>[
      ('Demande du client', 'Vous nous contactez par Messenger, WhatsApp, '
          'téléphone ou directement au comptoir.', 'inbox'),
      ('Analyse du besoin', 'Nous écoutons votre besoin et identifions le '
          'service adapté.', 'search'),
      ('Qualification', 'Un formulaire précis complète les informations : '
          'format, quantité, délai, exigences.', 'fact_check'),
      ('Devis', 'Vous recevez un devis clair : contenu, prix, délai, '
          'conditions.', 'request_quote'),
      ('Validation', 'Vous validez le devis (et l’acompte éventuel) pour '
          'lancer le travail.', 'verified'),
      ('Réception des fichiers', 'Nous collectons tous vos fichiers sources '
          '(textes, images, logos).', 'attach_file'),
      ('Production', 'Le travail est réalisé sur le PC de production, '
          'selon le brief validé.', 'build'),
      ('Contrôle qualité', 'Vérification complète avant livraison : '
          'contenu, formats, corrections demandées.', 'rule'),
      ('Livraison', 'Vous recevez les fichiers finaux par le canal choisi '
          '(WhatsApp, email, clé USB, impression).', 'local_shipping'),
      ('Finalisation', 'Paiement du solde, archivage du dossier et suivi '
          'de votre satisfaction.', 'task_alt'),
    ];
    final now = DateTime.now();
    var index = 0;
    for (final (titre, description, icone) in steps) {
      await dao.upsertProcessStep(ProcessStep(
        id: 'proc_def_$index',
        titre: titre,
        description: description,
        icone: icone,
        ordre: index,
        actif: true,
        updatedAt: now,
      ));
      index++;
    }
  }

  // ── Instructions des étapes de workflow ───────────────────────────────────

  /// Complète les étapes de workflow qui n'ont aucune fiche d'instructions
  /// (installations v3 mises à jour vers v4, workflows de démo, workflows
  /// créés par l'administration sans détails).
  static Future<void> _ensureWorkflowInstructions(AppDatabase db) async {
    final dao = WorkflowsDao(db);
    final steps = await db.select(db.workflowSteps).get();
    for (final step in steps) {
      if (step.description != null && step.description!.trim().isNotEmpty) {
        continue;
      }
      final fiches = _instructionsFor(step.nom);
      await dao.updateStepInstructions(WorkflowStep(
        id: step.id,
        workflowId: step.workflowId,
        ordre: step.ordre,
        nom: step.nom,
        actionsJson: step.actionsJson,
        description: '${fiches.$1}\n${fiches.$2}',
        responsable: fiches.$3,
        fichiersRequis: fiches.$4,
        resultatAttendu: fiches.$5,
        conditionsValidation: fiches.$6,
      ));
    }
  }

  static (String, String, String, String, String, String) _instructionsFor(
      String nomEtape) {
    const map = <String,
        (String, String, String, String, String, String)>{
      'Réception': (
        'Enregistrer la demande reçue (Messenger, WhatsApp, appel ou '
            'comptoir) et accuser réception au client.',
        'Pourquoi : le client doit savoir que MSN a bien reçu sa demande.',
        'Opérateur d’accueil',
        'Aucun fichier nécessaire.',
        'Demande enregistrée avec référence REQ-… et message d’accueil envoyé.',
        'La demande existe dans le système avec un client identifié.',
      ),
      'Qualification': (
        'Compléter le formulaire de qualification du service : format, '
            'quantité, délai, exigences particulières.',
        'Pourquoi : un brief incomplet produit un travail non conforme.',
        'Opérateur d’accueil',
        'Les échanges avec le client (captures, messages).',
        'Brief complet et compréhensible par la production.',
        'Toutes les questions obligatoires ont une réponse.',
      ),
      'Analyse': (
        'Analyser la faisabilité : matériel, compétences, temps nécessaire.',
        'Pourquoi : détecter les blocages avant de promettre un délai.',
        'Responsable d’agence',
        '—',
        'Faisabilité confirmée ou alternative proposée.',
        'Le service demandé est réalisable dans les délais.',
      ),
      'Devis': (
        'Préparer le devis : lignes de prestation, prix, délai, conditions.',
        'Pourquoi : le client doit connaître le prix avant tout engagement.',
        'Opérateur d’accueil',
        'Tarifs du catalogue à jour.',
        'Devis envoyé au client (message ou PDF).',
        'Le devis contient au moins une ligne et un montant total.',
      ),
      'Validation': (
        'Obtenir l’accord explicite du client sur le devis.',
        'Pourquoi : aucun travail payant ne démarre sans validation.',
        'Opérateur d’accueil',
        '—',
        'Réponse du client (message archivé dans la demande).',
        'Le client a dit « oui » de façon claire.',
      ),
      'Acompte': (
        'Demander et enregistrer l’acompte si requis par les règles.',
        'Pourquoi : sécuriser l’engagement du client et les charges.',
        'Opérateur d’accueil',
        '—',
        'Paiement d’acompte enregistré (référence PMT-…).',
        'L’acompte correspond à la règle métier du service.',
      ),
      'Brief complet': (
        'Vérifier que le brief est complet : fichiers reçus, exigences '
            'comprises, questions posées.',
        'Pourquoi : la production ne doit jamais deviner.',
        'Opérateur d’accueil',
        'Fichiers sources du client.',
        'Checklist de brief complétée.',
        'Aucune question sans réponse côté client.',
      ),
      'Réception fichiers': (
        'Collecter les fichiers sources et les classer dans SOURCE.',
        'Pourquoi : tout le contenu utile doit être au même endroit.',
        'Opérateur d’accueil',
        'Fichiers du client (images, textes, logos).',
        'Fichiers joints à la demande/commande.',
        'Les fichiers s’ouvrent et sont lisibles.',
      ),
      'Production': (
        'Réaliser le travail selon le brief validé.',
        'Pourquoi : c’est le cœur de la valeur livrée au client.',
        'Opérateur de production',
        'Fichiers sources + brief de qualification.',
        'Fichiers de production prêts dans le dossier TRAVAIL.',
        'Le rendu correspond au brief et aux formats demandés.',
      ),
      'Production PC': (
        'Exécuter la production sur le PC (templates, logiciels lourds).',
        'Pourquoi : la qualité et la vitesse dépendent du PC de production.',
        'Opérateur de production',
        'Dossier transféré depuis le mobile.',
        'Fichiers finaux prêts au contrôle.',
        'Le transfert PC est marqué terminé.',
      ),
      'Proposition V1': (
        'Envoyer la première proposition au client pour avis.',
        'Pourquoi : valider la direction artistique tôt.',
        'Opérateur de production',
        'Proposition(s) prête(s).',
        'Proposition partagée avec le client.',
        'Le client a reçu la proposition (canal confirmé).',
      ),
      'Contrôle': (
        'Vérifier : résolution, dimensions, format, textes, images, '
            'demandes spéciales.',
        'Pourquoi : une erreur livrée coûte deux fois plus de temps.',
        'Opérateur de production',
        'Fichiers de production.',
        'Checklist de contrôle cochée.',
        'Aucun point de contrôle en échec.',
      ),
      'Correction': (
        'Appliquer les corrections demandées par le client ou le contrôle.',
        'Pourquoi : livrer exactement ce qui a été validé.',
        'Opérateur de production',
        'Liste des corrections.',
        'Fichiers corrigés.',
        'Chaque correction est vérifiée une par une.',
      ),
      'Validation finale': (
        'Faire valider la version finale par le client.',
        'Pourquoi : verrouiller le contenu avant livraison.',
        'Opérateur d’accueil',
        'Version finale.',
        'Accord final du client.',
        'Le client a validé la version finale.',
      ),
      'Livraison': (
        'Livrer les fichiers finaux par le canal convenu.',
        'Pourquoi : c’est le moment où le client reçoit sa valeur.',
        'Opérateur d’accueil',
        'Fichiers finaux.',
        'Fichiers remis (WhatsApp, email, USB, impression).',
        'Le client confirme la réception.',
      ),
      'Paiement final': (
        'Encaisser le solde restant et enregistrer le paiement.',
        'Pourquoi : clore le cycle financier du dossier.',
        'Opérateur d’accueil',
        'Facture à jour.',
        'Paiement du solde enregistré (référence PMT-…).',
        'Le solde de la facture est à zéro.',
      ),
      'Archivage': (
        'Archiver le dossier : fichiers finaux, paiements, notes.',
        'Pourquoi : retrouver facilement le dossier pour un futur besoin.',
        'Opérateur d’accueil',
        'Dossier complet.',
        'Commande archivée (visible dans l’historique).',
        'Toutes les étapes sont terminées et le solde payé.',
      ),
    };
    return map[nomEtape] ??
        (
          'Étape « $nomEtape » : suivre les consignes internes MSN.',
          'Pourquoi : chaque étape fait avancer la commande vers la '
              'livraison.',
          'Équipe MSN',
          '—',
          'Travail de l’étape terminé.',
          'Le résultat est conforme au brief.',
        );
  }
}
