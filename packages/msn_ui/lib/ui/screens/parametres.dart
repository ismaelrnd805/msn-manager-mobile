// Paramètres : URL du serveur, connexion, appareils, sauvegarde de la base locale.
// AUCUN secret n'est stocké dans le binaire (spec §10).
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../plateforme.dart' show isMobile;
import '../../state/providers.dart';

bool get identiqueMobile => isMobile;
bool get estMobile => isMobile;

class ParametresEcran extends ConsumerStatefulWidget {
  const ParametresEcran({super.key});

  @override
  ConsumerState<ParametresEcran> createState() => _ParametresEcranState();
}

class _ParametresEcranState extends ConsumerState<ParametresEcran> {
  late final TextEditingController _urlCtrl;
  final _emailCtrl = TextEditingController(text: 'admin@msn.mg');
  final _motDePasseCtrl = TextEditingController();
  bool _enCours = false;
  late final String _plateforme = _detectePlateforme();

  static String _detectePlateforme() {
    if (estMobile) return 'android';
    return 'windows';
  }

  @override
  void initState() {
    super.initState();
    _urlCtrl = TextEditingController(text: ref.read(urlServeurProvider));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Connexion au serveur', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        TextField(
          controller: _urlCtrl,
          decoration: const InputDecoration(
            labelText: 'URL de l\'API v1',
            helperText: 'Exemple : https://serveur.msn.mg/api/v1 — HTTPS en production.',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailCtrl,
          decoration: const InputDecoration(labelText: 'Email utilisateur'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _motDePasseCtrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Mot de passe'),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          icon: _enCours
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.login),
          label: const Text('Se connecter et enregistrer cet appareil'),
          onPressed: _enCours ? null : _connexion,
        ),
        const Divider(height: 32),
        Text('Sauvegarde locale', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text(
            'La base locale SQLite est sauvegardée automatiquement à la fermeture. '
            'Pour une copie manuelle, utilisez le bouton ci-dessous (fichier horodaté).'),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Copier la base locale'),
          onPressed: () => _sauvegarde(context),
        ),
        const Divider(height: 32),
        Text('À propos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text(
            'MSN Manager V1 — outil interne Multi-Services Numériques.\n'
            'Fonctionne hors ligne : toutes les modifications sont enregistrées '
            'localement puis synchronisées avec le serveur central.'),
      ],
    );
  }

  Future<void> _connexion() async {
    setState(() => _enCours = true);
    try {
      final deviceId =
          (await ref.read(baseDeDonneesProvider.future)).appareilIdLocal;
      final reponse = await ref.read(apiHttpProvider).post(
        Uri.parse('${_urlCtrl.text.trim()}/auth/login'),
        headers: const {'Content-Type': 'application/json'},
        body: '{"email": "${_emailCtrl.text.trim()}", '
            '"password": "${_motDePasseCtrl.text}", '
            '"device_id": "$deviceId", '
            '"device_name": "MSN App", '
            '"plateforme": "$_plateforme"}',
      );
      if (reponse.statusCode == 200) {
        final donnees = jsonDecode(reponse.body)['data'] as Map<String, dynamic>;
        ref.read(urlServeurProvider.notifier).state = _urlCtrl.text.trim();
        ref.read(jetonProvider.notifier).state =
            donnees['access_token'] as String;
        ref.read(appareilIdProvider.notifier).state = deviceId;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('url_serveur', _urlCtrl.text.trim());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connecté — synchronisation en cours…')));
        await synchroniser(ref);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Connexion refusée (HTTP ${reponse.statusCode}).')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Serveur injoignable : vérifiez l\'URL et le réseau.')));
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

    Future<void> _sauvegarde(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Sauvegarde : copiez le fichier msn_manager.db depuis le dossier '
            'documents de l\'application (voir docs/05-securite.md).')));
  }
}


