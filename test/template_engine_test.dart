/// Tests du moteur de modèles de messages (variables {{...}}).
import 'package:flutter_test/flutter_test.dart';

import 'package:msn_manager_mobile/core/domain/template_engine.dart';

void main() {
  group('TemplateEngine.render', () {
    test('remplace toutes les variables connues', () {
      final result = TemplateEngine.render(
        'Bonjour {{PRENOM}}, votre devis {{REFERENCE}} : {{MONTANT}}.',
        {
          'PRENOM': 'Jean',
          'REFERENCE': 'DEV-2026-0001',
          'MONTANT': '150 000 Ar',
        },
      );
      expect(result,
          'Bonjour Jean, votre devis DEV-2026-0001 : 150 000 Ar.');
    });

    test('conserve les variables inconnues par défaut', () {
      final result = TemplateEngine.render(
        'Bonjour {{PRENOM}}, {{VARIABLE_INCONNUE}} reste visible.',
        {'PRENOM': 'Jean'},
      );
      expect(result,
          'Bonjour Jean, {{VARIABLE_INCONNUE}} reste visible.');
    });

    test('peut supprimer les variables inconnues', () {
      final result = TemplateEngine.render(
        'Bonjour {{PRENOM}}{{INCONNUE}} !',
        {'PRENOM': 'Jean'},
        keepUnknown: false,
      );
      expect(result, 'Bonjour Jean !');
    });

    test('tolère les espaces dans les accolades', () {
      final result = TemplateEngine.render(
        'Bonjour {{ PRENOM }} et {{  NOM_CLIENT  }}.',
        {'PRENOM': 'Jean', 'NOM_CLIENT': 'Jean Rakoto'},
      );
      expect(result, 'Bonjour Jean et Jean Rakoto.');
    });
  });

  group('TemplateEngine.context', () {
    test('extrait le prénom du nom complet', () {
      final ctx = TemplateEngine.context(nomClientComplet: 'Jean Rakoto');
      expect(ctx['PRENOM'], 'Jean');
      expect(ctx['NOM_CLIENT'], 'Jean Rakoto');
    });

    test('ne contient que les clés fournies', () {
      final ctx = TemplateEngine.context(service: 'Logo');
      expect(ctx.containsKey('SERVICE'), isTrue);
      expect(ctx.containsKey('MONTANT'), isFalse);
      expect(ctx.containsKey('PRENOM'), isFalse);
    });

    test('ignore les valeurs vides', () {
      final ctx = TemplateEngine.context(service: '', reference: 'DEV-1');
      expect(ctx.containsKey('SERVICE'), isFalse);
      expect(ctx['REFERENCE'], 'DEV-1');
    });
  });

  test('variablesIn liste les variables présentes', () {
    final vars = TemplateEngine.variablesIn(
        '{{A}} puis {{B}} puis {{A}} de nouveau.');
    expect(vars, ['A', 'B']);
  });
}
