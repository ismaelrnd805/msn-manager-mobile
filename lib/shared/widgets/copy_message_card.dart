/// Carte « MESSAGE PRÊT » — le cœur du principe MSN : ne pas dire à
/// l'utilisateur ce qu'il doit faire, mais lui donner le travail déjà
/// préparé avec ses boutons COPIER / PARTAGER.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/msn_theme.dart';
import 'feedback.dart';

class CopyMessageCard extends StatelessWidget {
  const CopyMessageCard({
    super.key,
    required this.title,
    required this.body,
    this.onShare,
    this.highlight,
  });

  /// Ex. « MESSAGE PRÊT », « PRÉSENTATION TARIFAIRE »…
  final String title;
  final String body;
  final VoidCallback? onShare;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MsnColors.accentSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MsnColors.accent.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  size: 14, color: MsnColors.primary),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: MsnColors.primary,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              if (highlight != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: MsnColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    highlight!,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: MsnColors.primaryDark),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: MsnColors.border),
            ),
            child: SelectableText(
              body,
              style: const TextStyle(
                  fontSize: 13.5, height: 1.45, color: MsnColors.textPrimary),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: body));
                    if (context.mounted) {
                      showMsnSnack(context, 'Message copié — collez-le dans '
                          'Messenger/WhatsApp');
                    }
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('COPIER'),
                ),
              ),
              if (onShare != null) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('PARTAGER'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
