import 'package:atendimento/atendimento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  testWidgets('sem panorama mostra o quadro vazio e fecha no X', (tester) async {
    var closed = false;
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AtendimentoStreetViewCard(
            coordinate: const LatLng(-8.05, -34.9),
            verify: (_) async => false,
            onOpen: () => opened = true,
            onClose: () => closed = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Indisponível: sem a etiqueta "Street View" e sem abrir panorama.
    expect(find.text('Street View'), findsNothing);
    expect(opened, isFalse);

    await tester.tap(find.byIcon(Icons.close));
    expect(closed, isTrue);
  });
}
