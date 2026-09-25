/// Numérotation automatique des documents : REQ-2026-0001, DEV-2026-0001,
/// CMD-2026-0042, FAC-2026-0001, PMT-2026-0001.
///
/// Les compteurs sont annuels (remis à zéro chaque année) et persistés
/// dans la table settings — l'incrémentation est atomique (transaction).
library;

import '../database/app_database.dart';
import '../utils/id_generator.dart';

class NumberingService {
  NumberingService(this._db);

  final AppDatabase _db;

  /// Prochaine référence pour un préfixe (REQ, DEV, CMD, FAC, PMT).
  Future<String> next(String prefix) async {
    final year = DateTime.now().year;
    final seq = await _db.nextSequence(prefix.toUpperCase(), year);
    return IdGenerator.formatReference(prefix, year, seq);
  }
}
