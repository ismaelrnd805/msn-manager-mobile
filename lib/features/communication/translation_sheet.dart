/// Menu de traduction d'un modèle de message — FR vers Malagasy, éditable.
///
/// Chaque modèle FR dispose de SON menu de traduction : à gauche le corps
/// français (référence), à droite le corps malagasy SÉCUTABLE. Le corps
/// MG enregistré est utilisé tel quel par le compositeur quand la bascule
/// « MG » est active (plus de traduction automatique une fois rempli).
/// Un aperçu du dictionnaire aide l'opérateur, et le bouton « Traduire
/// automatiquement » pré-remplit le champ avec le dictionnaire administrable.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/translator.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/theme/msn_theme.dart';
import '../../shared/widgets/feedback.dart';

/// Ouvre le menu de traduction du modèle [template] et renvoie true si le
/// corps MG a été enregistré (l'appelant régénère alors son texte).
Future<bool> showTranslationSheet(
  BuildContext context,
  WidgetRef ref,
  MessageTemplate template,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _TranslationSheet(template: template),
  );
  return result ?? false;
}

class _TranslationSheet extends ConsumerStatefulWidget {
  const _TranslationSheet({required this.template});

  final MessageTemplate template;

  @override
  ConsumerState<_TranslationSheet> createState() => _TranslationSheetState();
}

class _TranslationSheetState extends ConsumerState<_TranslationSheet> {
  late final TextEditingController _mg;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _mg = TextEditingController(text: widget.template.corpsMg ?? '');
  }

  Future<void> _autoTranslate() async {
    final entries = await ref.read(templatesDaoProvider).activeDictionary();
    if (!mounted) return;
    setState(() {
      _mg.text = DictionaryTranslator.translate(widget.template.corps, entries);
    });
    final cov = DictionaryTranslator.coverage(widget.template.corps, entries);
    if (mounted) {
      showMsnSnack(
        context,
        'Pré-traduction appliquée (couverture dictionnaire : '
        '${(cov * 100).round()}%) — relisez et complétez.',
      );
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final mg = _mg.text.trim();
      await ref.read(templatesDaoProvider).upsertMessageTemplate(
            MessageTemplate(
              id: widget.template.id,
              code: widget.template.code,
              titre: widget.template.titre,
              categorie: widget.template.categorie,
              corps: widget.template.corps,
              corpsMg: mg.isEmpty ? null : _mg.text,
              actif: widget.template.actif,
              ordre: widget.template.ordre,
              updatedAt: DateTime.now(),
            ),
          );
      await ref.read(activityLoggerProvider).log(
            action: ActivityAction.modification,
            entite: 'modele_message',
            entityId: widget.template.id,
            details: mg.isEmpty
                ? 'Traduction MG supprimée du modèle « ${widget.template.titre} ».'
                : 'Traduction MG mise à jour pour « ${widget.template.titre} ».',
          );
      if (mounted) {
        Navigator.of(context).pop(true);
        showMsnSnack(context, 'Traduction enregistrée pour ce modèle.');
      }
    } catch (e) {
      if (mounted) showMsnSnack(context, 'Échec : $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.92,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Scaffold(
          appBar: AppBar(
            title: Text('Traduction · ${widget.template.titre}',
                overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                tooltip: 'Pré-traduire avec le dictionnaire',
                onPressed: _autoTranslate,
                icon: const Icon(Icons.auto_awesome),
              ),
            ],
          ),
          body: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(14),
            children: [
              _Panel(
                label: 'TEXTES FRANÇAIS (référence — modifiable via '
                    'l\u2019administration)',
                child: Text(
                  widget.template.corps,
                  style: const TextStyle(
                      fontSize: 13, height: 1.45, color: MsnColors.textPrimary),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'TEXTES MALAGASY (envoyés au client quand la bascule est '
                'sur MG)',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: MsnColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _mg,
                maxLines: 12,
                style: const TextStyle(fontSize: 14, height: 1.45),
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'Corps malagasy de ce modèle '
                      '(variables {nom_client}… conservées)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_outlined, size: 18),
                label: const Text('ENREGISTRER CETTE TRADUCTION'),
              ),
              const SizedBox(height: 6),
              const Text(
                'Astuce : gardez les variables entre accolades '
                '({nom_client}, {reference}…) — elles sont remplacées '
                'automatiquement à l\u2019envoi.',
                style: TextStyle(fontSize: 11.5, color: MsnColors.textSecondary),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mg.dispose();
    super.dispose();
  }
}

/// Carte grise contenant le texte de référence FR.
class _Panel extends StatelessWidget {
  const _Panel({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MsnColors.textSecondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: MsnColors.textSecondary,
              )),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
