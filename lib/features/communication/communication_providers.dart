/// Moteur de communication — préparation automatique des messages.
///
/// Principe MSN : l'app prépare le maximum de travail répétitif. Le
/// compositeur rend un modèle de message avec les variables remplies
/// depuis le contexte (client, service, référence, montants…).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/daos/templates_dao.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/template_engine.dart';
import '../../core/domain/translator.dart';
import '../../core/providers/client_language_provider.dart';
import '../../core/providers/database_provider.dart';
import '../../core/utils/formatters.dart';

/// Contexte de composition transmis aux écrans qui ouvrent le compositeur
/// (demande, commande, devis, catalogue…).
class ComposerArgs {
  const ComposerArgs({
    this.templateCode,
    this.categorie,
    this.clientNom,
    this.serviceNom,
    this.reference,
    this.montant,
    this.delai,
    this.solde,
    this.lien,
    this.attachServiceId,
    this.attachQuoteId,
    this.attachInvoiceId,
    this.attachOrderId,
  });

  final String? templateCode;
  final TemplateCategorie? categorie;
  final String? clientNom;
  final String? serviceNom;
  final String? reference;
  final int? montant;
  final String? delai;
  final int? solde;
  final String? lien;

  // Pour proposer les pièces jointes PDF/image du bon document.
  final String? attachServiceId;
  final String? attachQuoteId;
  final String? attachInvoiceId;
  final String? attachOrderId;
}

class RenderedMessage {
  const RenderedMessage({
    required this.template,
    required this.rendered,
    required this.missingVariables,
    this.langue = ClientLangue.fr,
    this.traductionAuto = false,
  });

  final MessageTemplate template;
  final String rendered;
  final List<String> missingVariables;

  /// Langue du rendu.
  final ClientLangue langue;

  /// Vrai si la traduction malagasy vient du dictionnaire automatique
  /// (aucun corps MG saisi pour ce modèle — message à relire).
  final bool traductionAuto;
}

class CommunicationService {
  CommunicationService(this._dao);

  final TemplatesDao _dao;

  /// Rend un message prêt à copier/partager à partir d'un code de modèle.
  ///
  /// En [ClientLangue.mg] : utilise le corps malagasy SAISI du modèle
  /// (`corpsMg`) s'il existe — sinon rend le corps français et le traduit
  /// via le dictionnaire administrable ([traductionAuto] = vrai, l'opérateur
  /// est invité à compléter la traduction du modèle).
  Future<RenderedMessage> render({
    required String code,
    ComposerArgs? args,
    ClientLangue langue = ClientLangue.fr,
  }) async {
    final template = await _dao.messageTemplateByCode(code);
    if (template == null) {
      throw StateError('Modèle de message introuvable : $code');
    }
    final context = TemplateEngine.context(
      nomClientComplet: args?.clientNom,
      service: args?.serviceNom,
      reference: args?.reference,
      montant: args?.montant == null ? null : Formatters.ar(args!.montant),
      delai: args?.delai,
      date: Formatters.date(DateTime.now()),
      solde: args?.solde == null ? null : Formatters.ar(args!.solde),
      lien: args?.lien,
    );
    var traductionAuto = false;
    var corps = template.corps;
    if (langue == ClientLangue.mg) {
      final corpsMg = template.corpsMg?.trim();
      if (corpsMg != null && corpsMg.isNotEmpty) {
        corps = corpsMg;
      } else {
        // Pas de traduction saisie : dictionnaire automatique.
        final entries = await _dao.activeDictionary();
        corps = DictionaryTranslator.translate(template.corps, entries);
        traductionAuto = true;
      }
    }
    final rendered = TemplateEngine.render(corps, context);
    final missing = TemplateEngine
        .variablesIn(corps)
        .where((v) => !context.containsKey(v))
        .toList();
    return RenderedMessage(
      template: template,
      rendered: rendered,
      missingVariables: missing,
      langue: langue,
      traductionAuto: traductionAuto,
    );
  }

  /// Premiers modèles suggérés pour une catégorie (actions prêtes).
  Future<MessageTemplate?> templateForCode(String code) =>
      _dao.messageTemplateByCode(code);
}

final communicationServiceProvider = Provider<CommunicationService>(
    (ref) => CommunicationService(ref.watch(templatesDaoProvider)));

/// Tous les modèles actifs (écran bibliothèque).
final messageTemplatesProvider =
    StreamProvider<List<MessageTemplate>>((ref) {
  return ref.watch(templatesDaoProvider).watchMessageTemplates();
});

/// Modèles filtrés par catégorie.
final messageTemplatesByCategoryProvider =
    StreamProvider.family<List<MessageTemplate>, TemplateCategorie?>(
        (ref, categorie) {
  return ref
      .watch(templatesDaoProvider)
      .watchMessageTemplates(categorie: categorie);
});
