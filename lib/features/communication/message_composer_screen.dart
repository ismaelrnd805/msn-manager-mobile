/// Compositeur de message — le modèle est rendu avec les variables
/// remplies automatiquement, l'opérateur peut ajuster puis COPIER ou
/// PARTAGER, et joindre le PDF/image du document concerné.
library;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/translator.dart';
import '../../core/providers/client_language_provider.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/theme/msn_theme.dart';
import '../../shared/widgets/copy_message_card.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/language_toggle.dart';
import 'communication_providers.dart';
import 'translation_sheet.dart';

class MessageComposerScreen extends ConsumerStatefulWidget {
  const MessageComposerScreen({super.key, this.args});

  final ComposerArgs? args;

  @override
  ConsumerState<MessageComposerScreen> createState() =>
      _MessageComposerScreenState();
}

class _MessageComposerScreenState extends ConsumerState<MessageComposerScreen> {
  final _body = TextEditingController();
  List<MessageTemplate> _templates = const [];
  MessageTemplate? _selected;
  RenderedMessage? _rendered;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final dao = ref.read(templatesDaoProvider);
    _templates = await dao.allMessageTemplates();
    _templates = _templates.where((t) => t.actif).toList();
    // Modèle initial : celui demandé, sinon premier de la catégorie,
    // sinon accueil.
    final args = widget.args;
    MessageTemplate? initial;
    if (args?.templateCode != null) {
      initial = _templates.where((t) => t.code == args!.templateCode).firstOrNull;
    }
    initial ??= args?.categorie == null
        ? null
        : _templates
            .where((t) => t.categorie == args!.categorie)
            .firstOrNull;
    initial ??= _templates
        .where((t) => t.categorie == TemplateCategorie.accueil)
        .firstOrNull;
    initial ??= _templates.firstOrNull;
    await _select(initial);
  }

  Future<void> _select(MessageTemplate? template) async {
    if (template == null) {
      setState(() => _loading = false);
      return;
    }
    final service = ref.read(communicationServiceProvider);
    final langue = ref.read(clientLangueProvider).value ?? ClientLangue.fr;
    final rendered =
        await service.render(code: template.code, args: widget.args, langue: langue);
    setState(() {
      _selected = template;
      _rendered = rendered;
      _body.text = rendered.rendered;
      _loading = false;
    });
  }

  /// Re-rend le modèle courant dans la langue choisie par la bascule.
  Future<void> _changerLangue(ClientLangue langue) async {
    final template = _selected;
    if (template == null) return;
    final service = ref.read(communicationServiceProvider);
    final rendered = await service.render(
        code: template.code, args: widget.args, langue: langue);
    setState(() {
      _rendered = rendered;
      _body.text = rendered.rendered;
    });
    if (langue == ClientLangue.mg && rendered.traductionAuto) {
      if (mounted) {
        showMsnSnack(
            context,
            'Traduction automatique (dictionnaire) — utilisez « MENU DE '
            'TRADUCTION » pour saisir la version malagasy de ce modèle.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    return Scaffold(
      appBar: AppBar(title: const Text('Message prêt')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
                // ── Bascule FR / Malagasy des textes client ────────────
                LanguageToggleBar(
                  title: 'Message au client',
                  onChanged: _changerLangue,
                ),
                const SizedBox(height: 12),
                // ── Sélecteur de modèle ────────────────────────────────
                DropdownButtonFormField<MessageTemplate>(
                  initialValue: _selected,
                  isExpanded: true,
                  decoration:
                      const InputDecoration(labelText: 'Modèle de message'),
                  items: _templates
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                                '${t.titre} (${t.categorie.label})',
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: _select,
                ),
                const SizedBox(height: 8),
                if (_rendered != null &&
                    _rendered!.langue == ClientLangue.mg)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          _rendered!.traductionAuto
                              ? Icons.info_outline
                              : Icons.verified_outlined,
                          size: 14,
                          color: _rendered!.traductionAuto
                              ? MsnColors.warning
                              : MsnColors.success,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _rendered!.traductionAuto
                                ? 'Version malagasy automatique (dictionnaire) '
                                    '— traduction manuelle non saisie.'
                                : 'Version malagasy officielle de ce modèle.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: _rendered!.traductionAuto
                                  ? MsnColors.warning
                                  : MsnColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_rendered != null &&
                    _rendered!.missingVariables.isNotEmpty)
                  Text(
                    'Variables non fournies : '
                    '${_rendered!.missingVariables.join(', ')} — '
                    'complétez le texte ci-dessous avant l’envoi.',
                    style: const TextStyle(
                        fontSize: 11.5, color: MsnColors.warning),
                  ),
                const SizedBox(height: 12),

                // ── Texte éditable ─────────────────────────────────────
                TextField(
                  controller: _body,
                  maxLines: 12,
                  style: const TextStyle(
                      fontSize: 14, height: 1.45),
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: 'Message à envoyer',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Actions ────────────────────────────────────────────
                CopyMessageCard(
                  title: 'Prêt à coller',
                  body: _body.text,
                  onShare: () async {
                    await ref
                        .read(shareServiceProvider)
                        .shareText(_body.text, subject: _selected?.titre);
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: _body.text));
                          if (context.mounted) {
                            showMsnSnack(
                                context, 'Copié — collez dans Messenger/WhatsApp');
                          }
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('COPIER'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await ref
                              .read(shareServiceProvider)
                              .shareText(_body.text);
                        },
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('PARTAGER'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Traduction malagasy à la volée via le dictionnaire.
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final entries = await ref
                              .read(templatesDaoProvider)
                              .activeDictionary();
                          if (!context.mounted) return;
                          setState(() {
                            _body.text = DictionaryTranslator.translate(
                                _body.text, entries);
                          });
                          final cov = DictionaryTranslator.coverage(
                              _body.text, entries);
                          showMsnSnack(
                              context,
                              cov >= 0.5
                                  ? 'Traduit en malagasy (couverture du '
                                      'dictionnaire : ${(cov * 100).round()}%).'
                                  : 'Traduction partielle — complétez le '
                                      'dictionnaire FR → MG dans '
                                      'l\'administration.');
                        },
                        icon: const Icon(Icons.translate, size: 18),
                        label: const Text('TRADUIRE ICI',
                            style: TextStyle(fontSize: 12.5)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Menu de traduction du modèle FR courant (éditable).
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selected == null
                            ? null
                            : () async {
                                final maj = await showTranslationSheet(
                                    context, ref, _selected!);
                                if (maj) await _select(_selected);
                              },
                        icon: const Icon(Icons.menu_book_outlined, size: 18),
                        label: const Text('MENU DE TRADUCTION',
                            style: TextStyle(fontSize: 12.5)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Pièces jointes PDF / image ─────────────────────────
                if (_hasAttachments(args)) ...[
                  Text('JOINDRE UN DOCUMENT PROFESSIONNEL'.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: MsnColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (args?.attachServiceId != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _shareServicePdf(
                                context, args!.attachServiceId!),
                            icon: const Icon(Icons.picture_as_pdf_outlined,
                                size: 18),
                            label: const Text('Fiche PDF',
                                style: TextStyle(fontSize: 12.5)),
                          ),
                        ),
                      if (args?.attachQuoteId != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _shareQuotePdf(
                                context, args!.attachQuoteId!),
                            icon: const Icon(Icons.picture_as_pdf_outlined,
                                size: 18),
                            label: const Text('Devis PDF',
                                style: TextStyle(fontSize: 12.5)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  bool _hasAttachments(ComposerArgs? args) =>
      args?.attachServiceId != null || args?.attachQuoteId != null;

  Future<void> _shareServicePdf(
      BuildContext context, String serviceId) async {
    try {
      final swc =
          await ref.read(catalogDaoProvider).serviceById(serviceId);
      if (swc == null) return;
      final file = await runWithLoading(
        context,
        'Génération du PDF…',
        () => ref.read(pdfServiceProvider).serviceSheet(swc),
      );
      if (context.mounted) {
        await ref
            .read(shareServiceProvider)
            .shareFile(file.path, subject: swc.service.nom);
      }
    } catch (e) {
      if (context.mounted) showMsnSnack(context, e.toString(), error: true);
    }
  }

  Future<void> _shareQuotePdf(
      BuildContext context, String quoteId) async {
    try {
      final dao = ref.read(documentsDaoProvider);
      final quote = await dao.quoteById(quoteId);
      if (quote == null) return;
      final items = await dao.quoteItems(quoteId);
      final client =
          await ref.read(clientsDaoProvider).byId(quote.clientId);
      if (client == null) return;
      final file = await runWithLoading(
        context,
        'Génération du PDF…',
        () => ref.read(pdfServiceProvider).quote(
              quote: quote,
              client: client,
              items: items,
            ),
      );
      if (context.mounted) {
        await ref.read(shareServiceProvider).shareFile(
              file.path,
              subject: 'Devis ${quote.reference}',
            );
      }
    } catch (e) {
      if (context.mounted) showMsnSnack(context, e.toString(), error: true);
    }
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }
}
