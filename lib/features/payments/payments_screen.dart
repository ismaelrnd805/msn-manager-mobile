/// Liste globale des paiements — journal des encaissements.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/empty_state.dart';
import 'payments_providers.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paiements')),
      body: payments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Erreur : $e',
                style: const TextStyle(color: MsnColors.danger))),
        data: (list) => list.isEmpty
            ? EmptyState(
                icon: Icons.payments_outlined,
                title: 'Aucun paiement',
                message:
                    'Les acomptes et soldes encaissés apparaîtront ici.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final p = list[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.payments,
                          color: MsnColors.success),
                      title: Text(
                          '${Formatters.ar(p.payment.montant)} — '
                          '${p.payment.methode.label}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: Text(
                          '${p.clientNom} · facture ${p.invoiceReference} · '
                          '${Formatters.date(p.payment.datePaiement)}'
                          '${p.payment.referenceExterne != null ? '\nRéf. ${p.payment.referenceExterne}' : ''}',
                          style: const TextStyle(fontSize: 11.5)),
                      isThreeLine:
                          p.payment.referenceExterne != null,
                      onTap: p.payment.invoiceId != null
                          ? () => context
                              .push('/invoices/${p.payment.invoiceId}')
                          : null,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
