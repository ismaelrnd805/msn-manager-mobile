import 'package:flutter_test/flutter_test.dart';
import 'package:msn_manager/main.dart';

void main() {
  testWidgets('MSN Manager starts with a login screen', (tester) async {
    final store = MsnStore();
    store.data['users'] = [
      {'id': 'T1', 'username': 'test', 'name': 'Test', 'role': 'member', 'active': true, 'passwordHash': hashPassword('password')}
    ];
    store.normalize();
    await tester.pumpWidget(MsnApp(store: store));
    await tester.pump();
    expect(find.text('MSN Manager'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.textContaining('Démo'), findsNothing);
  });
}
