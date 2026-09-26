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

import '../../constants/app_constants.dart';
import '../app_database.dart';
import '../daos/templates_dao.dart';
import '../daos/workflows_dao.dart';

class DefaultContent {
  DefaultContent._();

  static Future<void> ensureDefaults(AppDatabase db) async {
    await _ensureCatalog(db);
    await _ensureBusinessRules(db);
    await _ensureConditions(db);
    await _ensureDictionary(db);
    await _ensureProcessSteps(db);
    await _ensureWorkflowInstructions(db);
    await _ensureQuestionOptions(db);
  }

  // ── Règles métier par défaut ─────────────────────────────────────────────

  /// RÈGLE MSN : la livraison ne peut pas être validée sans encaissement
  /// complet. La règle `paiement_final_avant_livraison` est appliquée à
  /// TOUT service qui n'a pas encore de valeur pour cette clé (idempotent :
  /// un choix explicite de l'administrateur n'est jamais écrasé).
  static Future<void> _ensureBusinessRules(AppDatabase db) async {
    final cle = RuleKeys.paiementFinalAvantLivraison;
    final valeur = RuleKeys.defaults[cle]!;

    final services = await db.select(db.services).get();
    final existing = await db.select(db.businessRules).get();
    final dejaPour = existing
        .where((r) => r.serviceId != null && r.cle == cle)
        .map((r) => r.serviceId!)
        .toSet();

    final now = DateTime.now();
    var i = 0;
    for (final s in services) {
      if (dejaPour.contains(s.id)) continue;
      await db.into(db.businessRules).insert(BusinessRulesCompanion.insert(
            id: 'rule_def_${now.millisecondsSinceEpoch}_$i',
            serviceId: Value(s.id),
            cle: cle,
            valeur: valeur,
          ));
      i++;
    }
  }

  // ── Catalogue officiel MSN — 6 branches numérotées ───────────────────────

  /// SOURCE UNIQUE du catalogue officiel MSN « Multi-Services Numériques »
  /// (tarifs à jour) : les 6 branches (1 à 6) et leurs services.
  /// Utilisé par le seed d'une installation neuve ET par [ensureDefaults]
  /// sur les installations existantes (insertion uniquement de ce qui
  /// manque, par identifiant — idempotent).
  /// Tout reste modifiable depuis le catalogue (prix, services, branches).
  ///
  /// Conventions d'unité :
  ///  - 'pièce' / 'page' / 'tableau' / 'élément' / 'mois' / 'forfait' :
  ///    prix fixe affiché « X Ar / unité » ;
  ///  - 'à partir de' : prix de départ affiché « À partir de X Ar » ;
  ///  - 'devis' : service sur devis affiché « Sur devis » (prix ignoré).
  static const Map<String, String> defaultCategories = {
    'cat_bureautique': 'Services bureautiques',
    'cat_design': 'Design graphique',
    'cat_communication': 'Communication digitale',
    'cat_web': 'Services web & numériques',
    'cat_packs': 'Packs pour entreprises',
    'cat_personnalises': 'Services personnalisés',
  };

  static const Map<String,
          ({String nom, String cat, int prix, String unite, int delai,
            String desc, String inclus})>
      defaultServices = {
    // ═══ Branche 1 — SERVICES BUREAUTIQUES ═══
    'svc_saisie': (
      nom: 'Saisie de document',
      cat: 'cat_bureautique',
      prix: 700,
      unite: 'page',
      delai: 1,
      desc: 'Saisie rapide et fidèle de vos documents manuscrits, PDF ou '
          'images.',
      inclus: 'Document saisi au format Word ou PDF, relu et corrigé.',
    ),
    'svc_mise_en_forme': (
      nom: 'Mise en forme simple',
      cat: 'cat_bureautique',
      prix: 1000,
      unite: 'page',
      delai: 1,
      desc: 'Polices, tailles, interlignes et alignements harmonisés sur '
          'tout le document.',
      inclus: 'Document mis en forme + export PDF.',
    ),
    'svc_mise_en_page': (
      nom: 'Mise en page professionnelle',
      cat: 'cat_bureautique',
      prix: 1500,
      unite: 'page',
      delai: 2,
      desc: 'Mise en page soignée : sommaire, en-têtes, pagination, '
          'tableaux et figures intégrés.',
      inclus: 'Document professionnel prêt à imprimer (Word + PDF).',
    ),
    'svc_tableau': (
      nom: 'Tableau simple',
      cat: 'cat_bureautique',
      prix: 1000,
      unite: 'tableau',
      delai: 1,
      desc: 'Création et mise en forme de tableaux clairs et lisibles.',
      inclus: 'Tableau intégré à votre document.',
    ),
    'svc_graphique': (
      nom: 'Graphique / figure',
      cat: 'cat_bureautique',
      prix: 1500,
      unite: 'élément',
      delai: 1,
      desc: 'Graphiques et figures professionnels à partir de vos données.',
      inclus: 'Figure haute résolution intégrée au document.',
    ),
    'svc_organigramme': (
      nom: 'Organigramme / schéma',
      cat: 'cat_bureautique',
      prix: 2000,
      unite: 'élément',
      delai: 2,
      desc: 'Organigrammes et schémas de structure clairs et professionnels.',
      inclus: 'Schéma haute résolution (PNG + intégré au document).',
    ),
    'svc_cv': (
      nom: 'CV professionnel',
      cat: 'cat_bureautique',
      prix: 10000,
      unite: 'pièce',
      delai: 2,
      desc: 'CV moderne et percutant, mis en valeur pour vos candidatures.',
      inclus: 'CV en Word + PDF, prénom du fichier personnalisé.',
    ),
    'svc_lettre_pro': (
      nom: 'Lettre / document professionnel',
      cat: 'cat_bureautique',
      prix: 5000,
      unite: 'pièce',
      delai: 1,
      desc: 'Lettres de motivation, courriers officiels et documents '
          'professionnels rédigés et mis en forme.',
      inclus: 'Document final en Word + PDF.',
    ),
    'svc_presentation': (
      nom: 'Présentation PowerPoint',
      cat: 'cat_bureautique',
      prix: 15000,
      unite: 'à partir de',
      delai: 3,
      desc: 'Présentations professionnelles : design cohérent, schémas, '
          'animations sobres. Le prix dépend du nombre de diapositives.',
      inclus: 'Fichier PowerPoint éditable + export PDF.',
    ),
    'svc_memoire': (
      nom: 'Mémoire / rapport',
      cat: 'cat_bureautique',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Mémoires, thèses et rapports : étude du volume et de la '
          'complexité avant tarification.',
      inclus: 'Document conforme aux normes demandées (Word + PDF).',
    ),
    'svc_pack_essentiel': (
      nom: 'Pack Essentiel étudiant',
      cat: 'cat_bureautique',
      prix: 15000,
      unite: 'forfait',
      delai: 2,
      desc: 'Formule étudiante : mise en forme d\u2019un document, '
          'correction de la présentation, numérotation des pages.',
      inclus: 'Les 3 prestations du pack sur un document.',
    ),
    'svc_pack_memoire': (
      nom: 'Pack Mémoire étudiant',
      cat: 'cat_bureautique',
      prix: 30000,
      unite: 'à partir de',
      delai: 7,
      desc: 'Formule étudiante complète : mise en page professionnelle, '
          'sommaire, numérotation, tableaux et figures, harmonisation '
          'générale.',
      inclus: 'Toutes les prestations du pack sur le mémoire.',
    ),

    // ═══ Branche 2 — DESIGN GRAPHIQUE ═══
    'svc_affiche_simple': (
      nom: 'Affiche simple',
      cat: 'cat_design',
      prix: 10000,
      unite: 'pièce',
      delai: 2,
      desc: 'Affiche événementielle claire et efficace, prête à diffuser.',
      inclus: 'Fichier HD (PDF + PNG) prêt à imprimer.',
    ),
    'svc_affiche_pro': (
      nom: 'Affiche professionnelle',
      cat: 'cat_design',
      prix: 20000,
      unite: 'pièce',
      delai: 3,
      desc: 'Affiche soignée avec direction artistique et retouches '
          'incluses.',
      inclus: 'Fichiers HD (PDF + PNG), 2 corrections incluses.',
    ),
    'svc_affiche_premium': (
      nom: 'Affiche premium',
      cat: 'cat_design',
      prix: 30000,
      unite: 'pièce',
      delai: 4,
      desc: 'Affiche haut de gamme : concept créatif, visuels travaillés, '
          'plusieurs propositions.',
      inclus: 'Fichiers HD, 2 propositions, 3 corrections incluses.',
    ),
    'svc_carte_visite': (
      nom: 'Carte de visite',
      cat: 'cat_design',
      prix: 15000,
      unite: 'pièce',
      delai: 2,
      desc: 'Carte de visite recto/verso, design personnalisé, prête à '
          'imprimer.',
      inclus: 'Fichier print-ready (PDF avec fond perdu).',
    ),
    'svc_flyer': (
      nom: 'Flyer',
      cat: 'cat_design',
      prix: 15000,
      unite: 'pièce',
      delai: 2,
      desc: 'Flyer accrocheur pour vos promotions, événements et annonces.',
      inclus: 'Fichier HD (PDF + PNG).',
    ),
    'svc_brochure': (
      nom: 'Brochure',
      cat: 'cat_design',
      prix: 30000,
      unite: 'à partir de',
      delai: 5,
      desc: 'Brochures et livrets multi-pages avec maquette professionnelle. '
          'Le prix dépend du nombre de pages.',
      inclus: 'Maquette complète print-ready (PDF).',
    ),
    'svc_logo': (
      nom: 'Logo',
      cat: 'cat_design',
      prix: 50000,
      unite: 'forfait',
      delai: 7,
      desc: 'Création de logo professionnel : recherches, proposition et '
          'déclinaisons.',
      inclus: 'Version principale + déclinaisons + fichiers finaux '
          '(PNG, PDF, source).',
    ),
    'svc_vectorisation': (
      nom: 'Vectorisation d\u2019un logo',
      cat: 'cat_design',
      prix: 25000,
      unite: 'pièce',
      delai: 2,
      desc: 'Redessin vectoriel de votre logo : net à toutes les tailles, '
          'prêt pour l\u2019impression grand format.',
      inclus: 'Fichier vectoriel (SVG/PDF) + PNG HD.',
    ),
    'svc_invitation': (
      nom: 'Invitation',
      cat: 'cat_design',
      prix: 15000,
      unite: 'pièce',
      delai: 2,
      desc: 'Faire-part et invitations personnalisés (mariage, baptême, '
          'événements).',
      inclus: 'Fichier HD prêt à imprimer ou diffuser.',
    ),
    'svc_visuel_reso': (
      nom: 'Visuel réseaux sociaux',
      cat: 'cat_design',
      prix: 10000,
      unite: 'pièce',
      delai: 1,
      desc: 'Visuels adaptés Facebook, Instagram et WhatsApp, cohérents '
          'avec votre identité.',
      inclus: 'Fichiers aux formats des plateformes (carré + story).',
    ),
    'svc_banniere_fb': (
      nom: 'Bannière Facebook',
      cat: 'cat_design',
      prix: 15000,
      unite: 'pièce',
      delai: 2,
      desc: 'Couverture et bannières professionnelles pour votre page.',
      inclus: 'Fichier aux dimensions officielles de la plateforme.',
    ),
    'svc_menu_catalogue': (
      nom: 'Menu / catalogue',
      cat: 'cat_design',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Menus, catalogues produits et tarifs : étude du nombre de '
          'pages et des photos avant tarification.',
      inclus: 'Maquette print-ready + version numérique.',
    ),
    'svc_pack_logo': (
      nom: 'Pack Logo',
      cat: 'cat_design',
      prix: 50000,
      unite: 'à partir de',
      delai: 5,
      desc: 'Identité de base autour du logo : création du logo, version '
          'principale, version adaptée aux réseaux sociaux, fichier HD.',
      inclus: 'Les 4 éléments du pack.',
    ),
    'svc_pack_identite': (
      nom: 'Pack Identité',
      cat: 'cat_design',
      prix: 100000,
      unite: 'à partir de',
      delai: 10,
      desc: 'Identité visuelle de départ : logo, palette de couleurs, '
          'typographies, carte de visite, mini-guide d\u2019utilisation.',
      inclus: 'Les 5 éléments du pack + mini-guide PDF.',
    ),

    // ═══ Branche 3 — COMMUNICATION DIGITALE ═══
    'svc_publication': (
      nom: 'Création d\u2019une publication',
      cat: 'cat_communication',
      prix: 10000,
      unite: 'pièce',
      delai: 1,
      desc: 'Publication réseaux sociaux complète : visuel + texte '
          'accrocheur.',
      inclus: 'Visuel HD + texte prêt à publier.',
    ),
    'svc_pack5_pub': (
      nom: 'Pack 5 publications',
      cat: 'cat_communication',
      prix: 45000,
      unite: 'forfait',
      delai: 5,
      desc: 'Cinq publications à prix pack, cohérentes entre elles.',
      inclus: '5 visuels + textes, planning de publication.',
    ),
    'svc_pack10_pub': (
      nom: 'Pack 10 publications',
      cat: 'cat_communication',
      prix: 80000,
      unite: 'forfait',
      delai: 8,
      desc: 'Dix publications à prix pack pour un mois d\u2019animation.',
      inclus: '10 visuels + textes, calendrier de publication.',
    ),
    'svc_couverture_fb': (
      nom: 'Création de couverture Facebook',
      cat: 'cat_communication',
      prix: 20000,
      unite: 'pièce',
      delai: 2,
      desc: 'Couverture professionnelle qui met en avant votre activité.',
      inclus: 'Fichier aux dimensions officielles + version mobile.',
    ),
    'svc_calendrier_edito': (
      nom: 'Calendrier éditorial',
      cat: 'cat_communication',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Plan de contenu mensuel : thèmes, formats et dates de '
          'publication.',
      inclus: 'Calendrier éditorial du mois (PDF ou tableur).',
    ),
    'svc_gestion_page': (
      nom: 'Gestion de page',
      cat: 'cat_communication',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Animation complète de votre page : publications, réponses aux '
          'messages, modération.',
      inclus: 'Suivi de la page selon la formule convenue.',
    ),
    'svc_community_mgmt': (
      nom: 'Community management',
      cat: 'cat_communication',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Gestion de votre communauté : animation, modération, relation '
          'client.',
      inclus: 'Accompagnement mensuel selon les besoins.',
    ),
    'svc_creation_contenu': (
      nom: 'Création de contenu',
      cat: 'cat_communication',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Textes, visuels et vidéos courts pour alimenter vos pages.',
      inclus: 'Contenus livrés prêts à publier.',
    ),
    'svc_pack_starter_reso': (
      nom: 'Pack Starter réseaux sociaux',
      cat: 'cat_communication',
      prix: 80000,
      unite: 'mois',
      delai: 30,
      desc: 'Formule mensuelle : 10 publications, création graphique, '
          'calendrier de publication, conseils de communication.',
      inclus: 'Les 4 éléments de la formule mensuelle.',
    ),
    'svc_pack_business_reso': (
      nom: 'Pack Business réseaux sociaux',
      cat: 'cat_communication',
      prix: 150000,
      unite: 'à partir de',
      delai: 30,
      desc: 'Formule mensuelle (par mois) : 15 à 20 publications, création '
          'graphique, calendrier éditorial, programmation, suivi de la '
          'page, rapport mensuel.',
      inclus: 'Les 6 éléments de la formule mensuelle.',
    ),

    // ═══ Branche 4 — SERVICES WEB & NUMÉRIQUES ═══
    // Chaque projet web est étudié selon : le nombre de pages, les
    // fonctionnalités, le design, la base de données, l'administration,
    // l'hébergement et la maintenance — d'où des tarifs sur devis.
    'svc_site': (
      nom: 'Site vitrine simple',
      cat: 'cat_web',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Site de présentation : accueil, services, contact. Chaque '
          'projet est étudié selon le nombre de pages, les '
          'fonctionnalités, le design, la base de données, '
          'l\u2019administration, l\u2019hébergement et la maintenance.',
      inclus: 'Étude, conception, mise en ligne et prise en main.',
    ),
    'svc_site_pro': (
      nom: 'Site professionnel',
      cat: 'cat_web',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Site complet multi-pages avec fonctionnalités avancées. '
          'Chaque projet est étudié avant tarification.',
      inclus: 'Étude, conception, mise en ligne et prise en main.',
    ),
    'svc_landing': (
      nom: 'Landing page',
      cat: 'cat_web',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Page unique optimisée pour une campagne ou une offre.',
      inclus: 'Conception + mise en ligne.',
    ),
    'svc_maintenance_site': (
      nom: 'Maintenance de site',
      cat: 'cat_web',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Mises à jour, sauvegardes et corrections régulières de votre '
          'site.',
      inclus: 'Forfait de maintenance selon la fréquence convenue.',
    ),
    'svc_modif_site': (
      nom: 'Modification / mise à jour',
      cat: 'cat_web',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Modifications de contenu, ajout de pages ou de sections sur un '
          'site existant.',
      inclus: 'Modifications appliquées et vérifiées.',
    ),
    'svc_formulaire_web': (
      nom: 'Formulaire / fonctionnalité web',
      cat: 'cat_web',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Formulaires, réservations, galeries et autres fonctionnalités '
          'sur mesure.',
      inclus: 'Fonctionnalité développée et testée.',
    ),
    'svc_app': (
      nom: 'Conception d\u2019application',
      cat: 'cat_web',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Applications mobiles et web : étude, conception et '
          'développement.',
      inclus: 'Étude du projet, maquettes et proposition technique.',
    ),

    // ═══ Branche 5 — PACKS POUR ENTREPRISES ═══
    'svc_pack_ent_starter': (
      nom: 'Pack Starter',
      cat: 'cat_packs',
      prix: 100000,
      unite: 'à partir de',
      delai: 7,
      desc: 'Pour petites entreprises et entrepreneurs : logo / '
          'optimisation visuelle, carte de visite, 5 visuels réseaux '
          'sociaux, conseils de communication.',
      inclus: 'Les 4 éléments du pack.',
    ),
    'svc_pack_ent_business': (
      nom: 'Pack Business',
      cat: 'cat_packs',
      prix: 200000,
      unite: 'à partir de',
      delai: 14,
      desc: 'Pour entreprises souhaitant améliorer leur présence '
          'numérique : identité visuelle de base, 10 publications, '
          'couverture Facebook, supports commerciaux, calendrier '
          'éditorial.',
      inclus: 'Les 5 éléments du pack.',
    ),
    'svc_pack_ent_pro': (
      nom: 'Pack Pro',
      cat: 'cat_packs',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Pour entreprises ayant des besoins numériques réguliers : '
          'design graphique, communication digitale, supports commerciaux, '
          'site web, maintenance, accompagnement numérique.',
      inclus: 'Formule sur mesure établie après étude des besoins.',
    ),

    // ═══ Branche 6 — SERVICES PERSONNALISÉS ═══
    // Projets qui nécessitent une étude avant tarification.
    'svc_perso_gros_volume': (
      nom: 'Gros volumes de saisie',
      cat: 'cat_personnalises',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Saisie de gros volumes (livres, archives, questionnaires) : '
          'étude du volume avant tarification.',
      inclus: 'Devis établi après échantillonnage du volume.',
    ),
    'svc_perso_memoires': (
      nom: 'Mémoires et rapports complexes',
      cat: 'cat_personnalises',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Documents académiques ou techniques complexes avec exigences '
          'de mise en page avancées.',
      inclus: 'Devis établi après analyse du document.',
    ),
    'svc_perso_catalogues': (
      nom: 'Catalogues',
      cat: 'cat_personnalises',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Catalogues produits multi-pages avec photos et fiches.',
      inclus: 'Devis établi selon le nombre de pages et de produits.',
    ),
    'svc_perso_livres': (
      nom: 'Livres et documents longs',
      cat: 'cat_personnalises',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Mise en page de livres, romans et documents de grande ampleur.',
      inclus: 'Devis établi selon le volume et les normes d\u2019édition.',
    ),
    'svc_perso_sites': (
      nom: 'Sites web',
      cat: 'cat_personnalises',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Projets web personnalisés : étude complète avant proposition.',
      inclus: 'Devis établi après étude des fonctionnalités.',
    ),
    'svc_perso_applications': (
      nom: 'Applications',
      cat: 'cat_personnalises',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Applications mobiles et web sur mesure : cahier des charges '
          'avant tarification.',
      inclus: 'Devis établi après étude du cahier des charges.',
    ),
    'svc_perso_identite': (
      nom: 'Identité visuelle complète',
      cat: 'cat_personnalises',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Identité complète : logo, charte graphique, supports de '
          'communication.',
      inclus: 'Devis établi selon l\u2019étendue des supports.',
    ),
    'svc_perso_reso': (
      nom: 'Gestion de réseaux sociaux',
      cat: 'cat_personnalises',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Gestion mensuelle de vos pages : formule établie selon vos '
          'objectifs.',
      inclus: 'Devis établi selon les objectifs et la fréquence.',
    ),
    'svc_perso_projets': (
      nom: 'Projets d\u2019entreprise',
      cat: 'cat_personnalises',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Projets numériques d\u2019entreprise : accompagnement et '
          'réalisation sur mesure.',
      inclus: 'Devis établi après réunion de cadrage.',
    ),
    'svc_perso_urgent': (
      nom: 'Commandes urgentes ou importantes',
      cat: 'cat_personnalises',
      prix: 0,
      unite: 'devis',
      delai: 0,
      desc: 'Commandes avec délai réduit ou volume important : étude de '
          'faisabilité avant acceptation.',
      inclus: 'Devis et délai confirmés avant démarrage.',
    ),
  };

  /// Insère les branches et services officiels manquants (par identifiant).
  /// Idempotent : n'écrase JAMAIS une branche ou un service déjà existant
  /// (même renommé/retarifé par l'administrateur).
  static Future<void> _ensureCatalog(AppDatabase db) async {
    final existingCats = await db.select(db.categories).get();
    final catIds = existingCats.map((c) => c.id).toSet();
    var branche = 0;
    for (final entry in defaultCategories.entries) {
      if (!catIds.contains(entry.key)) {
        await db.into(db.categories).insert(CategoriesCompanion.insert(
              id: entry.key,
              nom: entry.value,
              ordre: Value(branche),
            ));
      }
      branche++;
    }

    final existingSvcs = await db.select(db.services).get();
    final svcIds = existingSvcs.map((s) => s.id).toSet();
    for (final entry in defaultServices.entries) {
      if (svcIds.contains(entry.key)) continue;
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
    final now = DateTime.now();

    // Conditions OFFICIELLES MSN (catalogue) — ajoutées par identifiant,
    // idempotent, sans jamais écraser un texte modifié par l'administration.
    const officielles = <(String, String, String, String, int)>[
      (
        'cond_off_tarifs',
        'Tarifs « à partir de »',
        'Les tarifs indiqués « à partir de » sont des prix de départ : '
            'le prix final dépend de la complexité et du volume du projet.',
        'devis',
        10,
      ),
      (
        'cond_off_modifications',
        'Modifications',
        'Les corrections prévues dans le brief initial sont incluses '
            'selon le forfait. Toute modification importante ou changement '
            'de demande peut faire l’objet d’une facturation '
            'supplémentaire.',
        'devis',
        11,
      ),
      (
        'cond_off_delais',
        'Délais et commandes urgentes',
        'Le délai est communiqué avant la validation de la commande. Les '
            'commandes urgentes peuvent faire l’objet d’un supplément.',
        'devis',
        12,
      ),
      (
        'cond_off_solde_livraison',
        'Livraison des fichiers',
        'Le solde est réglé avant la livraison finale des fichiers '
            'exploitables.',
        'facture',
        13,
      ),
    ];
    final idsExistants =
        (await db.select(db.conditions).get()).map((c) => c.id).toSet();
    for (final (id, titre, contenu, categorie, ordre) in officielles) {
      if (idsExistants.contains(id)) continue;
      await dao.upsertCondition(Condition(
        id: id,
        titre: titre,
        contenu: contenu,
        categorie: categorie,
        actif: true,
        ordre: ordre,
        createdAt: now,
        updatedAt: now,
      ));
    }

    if (await dao.countConditions() > 0) return;

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
      ('tarifs', 'vidiny', 'commercial'),
      ('délai', 'fe-potoana', 'commercial'),
      ('livraison', 'fanaterana', 'commercial'),
      ('commande', 'baiko', 'commercial'),
      ('service', 'serivisy', 'commercial'),
      ('nos services', 'ny serivisinay', 'commercial'),
      ('impression', 'fanontana', 'technique'),
      ('graphisme', 'fanaovana sary', 'technique'),
      ('logo', 'marika', 'technique'),
      ('flyer', 'flyer (taratasy fampahafantarana)', 'technique'),
      ('photo', 'sary', 'technique'),
      ('photo & vidéo', 'sary sy horonantsary', 'technique'),
      ('bureautique', 'birao', 'technique'),
      ('design', 'design (fanaovana endrika)', 'technique'),
      ('communication', 'fampahafantarana', 'technique'),
      ('web', 'web', 'technique'),
      ('site web', 'site web (tranonkala)', 'technique'),
      ('montage vidéo', 'fanamboarana horonantsary', 'technique'),
      ('format', 'endrika', 'technique'),
      ('fichier', 'rakitra', 'technique'),
      ('correction', 'fanitsiana', 'technique'),
      ('validation', 'fanamarinana', 'commercial'),
      ('contact', 'fifandraisana', 'commercial'),
      ('contactez-nous', 'antsoy izahay', 'commercial'),
      ('appelez-nous', 'antsoy izahay', 'commercial'),
      ('à partir de', 'manomboka', 'commercial'),
      ('gratuit', 'maimaim-poana', 'commercial'),
      ('envoyez-nous un message', 'alefaso eto izahay', 'commercial'),
      ('en cours de traitement', 'eo am-pamokarana', 'suivi'),
      ('terminé', 'vita', 'suivi'),
      ('en retard', 'tafahoatra amin’ny fe-potoana', 'suivi'),
      ('prochaine étape', 'dingana manaraka', 'suivi'),
      // Vocabulaire du catalogue officiel (branches 1 à 6, packs, devis)
      ('services bureautiques', 'serivisin’ny birao', 'technique'),
      ('design graphique', 'design sary', 'technique'),
      ('communication digitale', 'fampahafantarana nomerika', 'technique'),
      ('services web & numériques', 'serivisy web sy nomerika', 'technique'),
      ('packs pour entreprises', 'pack ho an’ny orinasa', 'technique'),
      ('services personnalisés', 'serivisy manokana', 'technique'),
      ('sur devis', 'araka ny tetikasa vidiny', 'commercial'),
      ('entreprise', 'orinasa', 'commercial'),
      ('étudiant', 'mpianatra', 'commercial'),
      ('réseaux sociaux', 'tambajotra sosialy', 'technique'),
      ('publication', 'famoahana', 'technique'),
      ('application', 'rindrambaiko', 'technique'),
      ('maintenance', 'fikojakojana', 'technique'),
      ('commande urgente', 'baiko maika', 'commercial'),
      ('par mois', 'isam-bolana', 'commercial'),
      ('page', 'pejy', 'technique'),
    ];

    // Idempotent PAR TERME : les installations existantes reçoivent les
    // nouveaux termes sans écraser les traductions saisies par l'admin.
    final existing = await db.select(db.dictionaryEntries).get();
    final existingFr = existing.map((e) => e.termeFr.toLowerCase()).toSet();
    var index = existing.length;
    for (final (fr, mg, cat) in entries) {
      if (existingFr.contains(fr.toLowerCase())) continue;
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
