/// Bascule FR / Malagasy — contrôles la langue des textes envoyés au client.
///
/// Présente EN HAUT des écrans qui produisent un texte client (compositeur
/// de messages, visuels réseaux sociaux, partages). L'état est global et
/// persistant : la dernière langue choisie est réutilisée partout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/client_language_provider.dart';
import '../../core/theme/msn_theme.dart';

/// SegmentedButton compact « FR | MG » — à placer en haut de l'écran.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key, this.onChanged});

  /// Callback optionnel appelé APRÈS le changement (pour régénérer le
  /// texte de l'écran hôte dans la nouvelle langue).
  final ValueChanged<ClientLangue>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langue = ref.watch(clientLangueProvider).value ?? ClientLangue.fr;
    return SegmentedButton<ClientLangue>(
      segments: const [
        ButtonSegment(
          value: ClientLangue.fr,
          label: Text('FR',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
          icon: Icon(Icons.language, size: 15),
        ),
        ButtonSegment(
          value: ClientLangue.mg,
          label: Text('MG',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
          icon: Icon(Icons.translate, size: 15),
        ),
      ],
      selected: {langue},
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        side: WidgetStatePropertyAll(BorderSide(
            color: MsnColors.primary.withValues(alpha: 0.45), width: 1)),
        backgroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? MsnColors.primary
                : Colors.white),
        foregroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.white
                : MsnColors.textPrimary),
      ),
      onSelectionChanged: (selection) {
        final nouvelle = selection.first;
        ref.read(clientLangueProvider.notifier).setLangue(nouvelle);
        onChanged?.call(nouvelle);
      },
    );
  }
}

/// Ligne « en haut » standard : titre de section texte client + bascule.
class LanguageToggleBar extends StatelessWidget {
  const LanguageToggleBar({super.key, required this.title, this.onChanged});

  final String title;
  final ValueChanged<ClientLangue>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: MsnColors.textSecondary,
            ),
          ),
        ),
        const Text('Texte client :',
            style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: MsnColors.textSecondary)),
        const SizedBox(width: 8),
        LanguageToggle(onChanged: onChanged),
      ],
    );
  }
}
