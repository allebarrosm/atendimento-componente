import 'package:atendimento/atendimento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../support/fake_api.dart';
import '../support/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// O `load` carrega os ícones dos pinos (asset real), então precisa rodar
  /// fora do relógio falso do `testWidgets`.
  Future<AtendimentoStore> buildStore(WidgetTester tester) async {
    late AtendimentoStore store;
    await tester.runAsync(() async {
      store = AtendimentoStore(
        repository: AtendimentoRepository(
          FakeApi(pages: [
            [atendimentoJson(id: 1)],
          ]),
        ),
        enableCoordinateEditing: true,
      );
      await store.load();
      await store.setCoordinateEditing(true);
      store.startCoordinateEdit(store.services.first);
    });
    return store;
  }

  testWidgets('mostra street view, dados do cliente e "Mudar Coordenada"',
      (tester) async {
    final store = await buildStore(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AtendimentoCoordinateCard(
            store: store,
            verifyStreetView: (_) async => false,
            onOpenStreetView: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cliente Um'), findsOneWidget);
    expect(find.text('Rua Um, 10'), findsOneWidget);
    expect(find.text('Mudar Coordenada'), findsOneWidget);

    // Mesmo depois de arrastar o botão continua "Mudar Coordenada".
    store.moveEditingCoordinate(const LatLng(-9.0, -35.0));
    await tester.pump();

    expect(find.text('Mudar Coordenada'), findsOneWidget);
    expect(find.text('Confirmar mudança'), findsNothing);
  });

  testWidgets('fechar o card cancela a edição', (tester) async {
    final store = await buildStore(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AtendimentoCoordinateCard(
            store: store,
            verifyStreetView: (_) async => false,
            onOpenStreetView: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(store.editing, isNull);
  });
}
