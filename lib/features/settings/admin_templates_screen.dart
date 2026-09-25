/// Édition des modèles de messages (admin) — les variables {{...}} sont
/// remplacées automatiquement à l'utilisation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/template_engine.dart';
import '../../core/providers/database_provider.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/services_providers.dart';
import '../../core/theme/msn_theme.dart';
import '../communication/communication_providers.dart';

class AdminTemplatesScreen extends ConsumerWidget {
  const AdminTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(messageTemplatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Modèles de messages')),
      body: templates.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final t = list[index];
            return Card(
              child: ListTile(
                title: Text(t.titre,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13.5)),
                subtitle: Text(
                    '${t.categorie.label} · code ${t.code}',
                    style: const TextStyle(fontSize: 11.5)),
                trailing: const Icon(Icons.edit, size: 18),
                onTap: () => _edit(context, ref, t),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _edit(
      BuildContext context, WidgetRef ref, MessageTemplate template) async {
    final titre = TextEditingController(text: template.titre);
    final corps = TextEditingController(text: template.corps);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le modèle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titre,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: corps,
                maxLines: 8,
                decoration:
                    const InputDecoration(labelText: 'Corps du message'),
              ),
              const SizedBox(height: 10),
              const Text('Variables disponibles :',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: TemplateEngine.variablesDocumentees
                    .map((v) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: MsnColors.accentSoft,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('{{$v}}',
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  fontFamily: 'monospace',
                                  color: MsnColors.primaryDark)),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Enregistrer')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(templatesDaoProvider).upsertMessageTemplate(
          MessageTemplate(
            id: template.id,
            code: template.code,
            titre: titre.text.trim(),
            categorie: template.categorie,
            corps: corps.text,
            actif: template.actif,
            ordre: template.ordre,
            updatedAt: DateTime.now(),
          ),
        );
    await ref.read(activityLoggerProvider).log(
          action: ActivityAction.modification,
          entite: 'modele_message',
          entityId: template.id,
          details: 'Modèle « ${template.titre} » modifié.',
        );
  }
}
