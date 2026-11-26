import 'package:atendimento/atendimento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpLegend(WidgetTester tester, double width) async {
    await tester.binding.setSurfaceSize(Size(width, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: AtendimentoLegendBar(
              filter: const AtendimentoFilter(),
              onToggleSwitch: (_, __) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('mostra os 7 interruptores', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLegend(tester, 1600);

    expect(find.byType(Checkbox), findsNWidgets(7));
    expect(tester.takeException(), isNull);
  });

  testWidgets('quebra em linhas quando a janela diminui, sem estourar',
      (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final width in <double>[1600, 900, 640, 480, 360]) {
      await pumpLegend(tester, width);

      expect(
        tester.takeException(),
        isNull,
        reason: 'estourou o layout em $width px',
      );

      final barWidth =
          tester.getSize(find.byType(AtendimentoLegendBar)).width;
      final checkboxes = find.byType(Checkbox);

      for (var i = 0; i < 7; i++) {
        final rect = tester.getRect(checkboxes.at(i));
        expect(
          rect.right,
          lessThanOrEqualTo(barWidth + 0.5),
          reason: 'checkbox $i saiu da legenda em $width px',
        );
      }
    }
  });
}
