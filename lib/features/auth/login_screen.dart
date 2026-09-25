/// Connexion locale par PIN — le téléphone reste verrouillé tant que
/// l'opérateur ne s'est pas identifié. Session en mémoire (expire au
/// redémarrage de l'app).
library;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/theme/msn_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  List<(String, String)> _users = const []; // (id, nom)
  String? _selectedUserId;
  final _pinController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await ref.read(systemDaoProvider).activeUsers();
    final lastUser = await ref.read(systemDaoProvider).getValue('last_user');
    setState(() {
      _users = users.map((u) => (u.id, u.nom)).toList();
      _selectedUserId = _users
          .where((u) => u.$2 == lastUser)
          .map((u) => u.$1)
          .firstOrNull ??
          (_users.isNotEmpty ? _users.first.$1 : null);
    });
  }

  Future<void> _login() async {
    if (_selectedUserId == null) return;
    final user = _users.firstWhere((u) => u.$1 == _selectedUserId);
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).login(user.$2, _pinController.text);
      if (mounted) context.go('/dashboard');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [MsnColors.primary, MsnColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Image.asset(
                      'assets/logo/msn_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('MSN',
                            style: TextStyle(
                                color: MsnColors.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 18)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('MSN Manager',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Connexion',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13)),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_users.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Aucun utilisateur actif. '
                                'Réinstallez l’application ou restaurez une sauvegarde.',
                                style:
                                    TextStyle(color: MsnColors.textSecondary),
                              ),
                            )
                          else ...[
                            DropdownButtonFormField<String>(
                              initialValue: _selectedUserId,
                              decoration:
                                  const InputDecoration(labelText: 'Utilisateur'),
                              items: _users
                                  .map((u) => DropdownMenuItem(
                                        value: u.$1,
                                        child: Text(u.$2),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedUserId = v),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _pinController,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              autofocus: true,
                              onSubmitted: (_) => _login(),
                              decoration: const InputDecoration(
                                labelText: 'Code PIN',
                                prefixIcon: Icon(Icons.lock_outline, size: 20),
                              ),
                            ),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: 10),
                            Text(_error!,
                                style: const TextStyle(
                                    color: MsnColors.danger, fontSize: 12.5)),
                          ],
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed:
                                _loading || _users.isEmpty ? null : _login,
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('SE CONNECTER'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Fonctionne 100% hors connexion. '
                            'Démo : Admin / 1234',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11,
                                color: MsnColors.textSecondary
                                    .withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
