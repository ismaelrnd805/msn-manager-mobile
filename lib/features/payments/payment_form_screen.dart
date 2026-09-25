/// Formulaire d'encaissement — acompte ou solde, toutes méthodes locales
/// (espèces, MVola, Orange Money, Airtel Money, virement).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/enums.dart';
import '../../core/domain/quote_calculator.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/form_fields.dart';
import '../invoices/invoices_providers.dart';
import 'payments_providers.dart';

class PaymentFormScreen extends ConsumerStatefulWidget {
  const PaymentFormScreen({super.key, this.invoiceId, this.orderId});

  final String? invoiceId;
  final String? orderId;

  @override
  ConsumerState<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _montant = TextEditingController();
  final _referenceExterne = TextEditingController();
  final _note = TextEditingController();
  PaymentMethode _methode = PaymentMethode.mvola;
  DateTime _date = DateTime.now();
  bool _saving = false;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final invoiceAsync = ref.watch(invoiceProvider(widget.invoiceId ?? ''));
    if (widget.invoiceId != null && !_initialized && invoiceAsync.value != null) {
      final invoice = invoiceAsync.value!;
      final itemsAsync = ref.watch(invoiceItemsProvider(invoice.id));
      final paidAsync = ref.watch(invoicePaidProvider(invoice.id));
      final items = itemsAsync.value ?? const [];
      final paid = paidAsync.value ?? 0;
      final totals = QuoteCalculator.facture(
        lignes: items
            .map((i) => DocumentLine(
                  designation: i.designation,
                  quantite: i.quantite,
                  prixUnitaire: i.prixUnitaire,
                ))
            .toList(),
        reduction: invoice.reduction,
        paiementsRecus: [paid],
      );
      _montant.text = (totals.solde > 0 ? totals.solde : 0).toString();
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Enregistrer un paiement')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          MsnMoneyField(
            label: 'Montant reçu',
            controller: _montant,
            obligatoire: true,
          ),
          MsnDropdown<PaymentMethode>(
            label: 'Méthode de paiement',
            value: _methode,
            items: PaymentMethode.values,
            itemLabel: (m) => m.label,
            onChanged: (v) => setState(() => _methode = v ?? PaymentMethode.autre),
          ),
          MsnTextField(
            label: 'Référence (transaction, reçu…)',
            controller: _referenceExterne,
            hint: 'Ex. MV-2026…',
          ),
          MsnDateField(
            label: 'Date du paiement',
            value: _date,
            onChanged: (v) {
              if (v != null) setState(() => _date = v);
            },
          ),
          MsnTextField(
            label: 'Note',
            controller: _note,
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('ENREGISTRER LE PAIEMENT'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Le statut de la facture est mis à jour automatiquement '
            '(partiellement payée → payée).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: MsnColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final montant = Validators.parseMontant(_montant.text);
    if (montant == null || montant <= 0) {
      showMsnSnack(context, 'Montant invalide.', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      String? invoiceId = widget.invoiceId;
      String? orderId = widget.orderId;
      String? clientId;

      if (invoiceId != null) {
        final invoice =
            await ref.read(documentsDaoProvider).invoiceById(invoiceId);
        clientId = invoice?.clientId;
        orderId ??= invoice?.orderId;
      }

      await registerPayment(
        ref,
        montant: montant,
        methode: _methode,
        date: _date,
        invoiceId: invoiceId,
        orderId: orderId,
        clientId: clientId,
        referenceExterne: _referenceExterne.text.trim().isEmpty
            ? null
            : _referenceExterne.text.trim(),
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      if (mounted) {
        showMsnSnack(
            context, 'Paiement de ${Formatters.ar(montant)} enregistré.');
        context.pop();
      }
    } catch (e) {
      if (mounted) showMsnSnack(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
