/// Champs de formulaire réutilisables — cohérence visuelle de toute l'app.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/msn_theme.dart';
import '../../core/utils/validators.dart';

class MsnTextField extends StatelessWidget {
  const MsnTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.obscure = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffix,
    this.autofocus = false,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool enabled;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: obscure ? 1 : maxLines,
        keyboardType: keyboardType,
        obscureText: obscure,
        enabled: enabled,
        autofocus: autofocus,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
          suffixIcon: suffix,
        ),
      ),
    );
  }
}

class MsnDropdown<T> extends StatelessWidget {
  const MsnDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: items
            .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

/// Champ date : affiche la valeur et ouvre un sélecteur.
class MsnDateField extends StatelessWidget {
  const MsnDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'Choisir une date'
        : DateFormat('dd/MM/yyyy').format(value!);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now().add(const Duration(days: 1)),
            firstDate: firstDate ?? DateTime.now().subtract(const Duration(days: 365)),
            lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 3)),
          );
          onChanged(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: value == null
                ? const Icon(Icons.calendar_today, size: 18)
                : IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => onChanged(null),
                  ),
          ),
          child: Text(text,
              style: TextStyle(
                  fontSize: 14,
                  color: value == null
                      ? MsnColors.textSecondary
                      : MsnColors.textPrimary)),
        ),
      ),
    );
  }
}

/// Champ montant en Ariary avec formatage à la saisie.
class MsnMoneyField extends StatelessWidget {
  const MsnMoneyField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.obligatoire = false,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool obligatoire;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return MsnTextField(
      label: '$label (Ar)',
      controller: controller,
      keyboardType: TextInputType.number,
      enabled: enabled,
      validator: (v) => Validators.montant(v, obligatoire: obligatoire),
      onChanged: onChanged,
    );
  }
}

/// Sélecteur générique en bottom sheet (client, service, facture…).
Future<T?> showMsnPicker<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) titleOf,
  String Function(T)? subtitleOf,
  Widget Function(T)? leadingOf,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: leadingOf?.call(item),
                  title: Text(titleOf(item),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: subtitleOf == null
                      ? null
                      : Text(subtitleOf(item)),
                  onTap: () => Navigator.pop(context, item),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
