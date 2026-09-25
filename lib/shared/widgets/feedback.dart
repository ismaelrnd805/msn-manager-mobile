/// Feedback utilisateur : snackbars, dialogues de confirmation, chargement.
library;

import 'package:flutter/material.dart';

import '../../core/theme/msn_theme.dart';

void showMsnSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            error ? Icons.error_outline : Icons.check_circle_outline,
            color: error ? Colors.redAccent : Colors.greenAccent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: error ? MsnColors.danger : MsnColors.textPrimary,
      duration: Duration(milliseconds: error ? 4000 : 2500),
    ),
  );
}

/// Dialogue de confirmation standard. Renvoie true si confirmé.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmer',
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: danger
              ? FilledButton.styleFrom(backgroundColor: MsnColors.danger)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Overlay de chargement plein écran (génération PDF, import…).
Future<T> runWithLoading<T>(
  BuildContext context,
  String message,
  Future<T> Function() task,
) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(message),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  try {
    return await task();
  } finally {
    navigator.pop();
  }
}
