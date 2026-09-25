/// Tests de la numérotation : REQ-2026-0001, CMD-2026-0042…
import 'package:flutter_test/flutter_test.dart';

import 'package:msn_manager_mobile/core/utils/id_generator.dart';

void main() {
  group('IdGenerator', () {
    test('formate une référence complète à 4 chiffres', () {
      expect(IdGenerator.formatReference('REQ', 2026, 1), 'REQ-2026-0001');
      expect(IdGenerator.formatReference('CMD', 2026, 42), 'CMD-2026-0042');
      expect(IdGenerator.formatReference('FAC', 2025, 1234), 'FAC-2025-1234');
    });

    test('passe à 5 chiffres au-delà de 9999', () {
      expect(IdGenerator.formatReference('DEV', 2026, 12345), 'DEV-2026-12345');
    });

    test('le préfixe est normalisé en majuscules', () {
      expect(IdGenerator.formatReference('req', 2026, 2), 'REQ-2026-0002');
    });

    test('la clé de compteur est annuelle', () {
      expect(IdGenerator.counterKey('REQ', 2026), 'counter_REQ_2026');
      expect(IdGenerator.counterKey('REQ', 2027), 'counter_REQ_2027');
    });

    test('extrait l\u2019année d\u2019une référence', () {
      expect(IdGenerator.yearOf('CMD-2026-0042'), 2026);
      expect(IdGenerator.yearOf('nimporte-quoi'), isNull);
    });
  });
}
