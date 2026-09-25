/// Utilitaires de formatage (montants en Ariary, dates en français).
library;

import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  /// Formate un montant entier en Ariary : 150000 -> « 150 000 Ar ».
  static String ar(int? montant) {
    if (montant == null) return '—';
    final f = NumberFormat('#,###', 'fr');
    return '${f.format(montant).replaceAll('\u202f', ' ').replaceAll(',', ' ')} Ar';
  }

  /// Formate une quantité : 2.0 -> « 2 », 2.5 -> « 2,5 ».
  static String qty(double? q) {
    if (q == null) return '—';
    if (q == q.truncateToDouble()) {
      return q.truncate().toString();
    }
    return q.toStringAsFixed(2).replaceAll('.', ',');
  }

  /// 2026-03-14 -> « 14/03/2026 ».
  static String date(DateTime? d) {
    if (d == null) return '—';
    return DateFormat('dd/MM/yyyy').format(d);
  }

  /// « 14/03/2026 09:30 ».
  static String dateTime(DateTime? d) {
    if (d == null) return '—';
    return DateFormat('dd/MM/yyyy HH:mm').format(d);
  }

  /// « ven. 14 mars » — pour les deadlines du dashboard.
  static String dateShort(DateTime? d) {
    if (d == null) return '—';
    return DateFormat('EEE d MMM', 'fr').format(d);
  }

  /// « il y a 3 j » / « aujourd'hui » / « dans 2 j ».
  static String relative(DateTime d, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return "aujourd'hui";
    if (diff == 1) return 'demain';
    if (diff == -1) return 'hier';
    if (diff < 0) return 'il y a ${-diff} j';
    return 'dans $diff j';
  }

  /// Nb de jours restants avant une échéance (négatif si dépassée).
  static int daysUntil(DateTime? deadline, {DateTime? now}) {
    if (deadline == null) return 9999;
    final ref = now ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    final target = DateTime(deadline.year, deadline.month, deadline.day);
    return target.difference(today).inDays;
  }
}
