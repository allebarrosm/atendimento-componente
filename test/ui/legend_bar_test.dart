import 'package:atendimento/atendimento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpLegend(WidgetTester tester, double width) async {
    // dpr 1 para a largura lógica ser exatamente a pedida.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = Size(width, 800);
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

  List<Offset> checkboxPositions(WidgetTester tester) {
    final checkboxes = find.byType(Checkbox);
    return <Offset>[
      for (var i = 0; i < 7; i++) tester.getTopLeft(checkboxes.at(i)),
    ];
  }

  testWidgets('na largura cheia mantém as 4 colunas alinhadas em grade',
      (tester) async {
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await pumpLegend(tester, 1600);

    expect(find.byType(Checkbox), findsNWidgets(7));
    final pos = checkboxPositions(tester);

    // Mesma coluna → mesmo x (0/1, 2/3, 4/5; o 6 é a coluna 4).
    expect(pos[0].dx, closeTo(pos[1].dx, 0.5));
    expect(pos[2].dx, closeTo(pos[3].dx, 0.5));
    expect(pos[4].dx, closeTo(pos[5].dx, 0.5));

    // Colunas em ordem crescente.
    expect(pos[0].dx, lessThan(pos[2].dx));
    expect(pos[2].dx, lessThan(pos[4].dx));
    expect(pos[4].dx, lessThan(pos[6].dx));

    // Mesma linha → mesmo y (1ª e 2ª linhas).
    expect(pos[0].dy, closeTo(pos[2].dy, 0.5));
    expect(pos[2].dy, closeTo(pos[4].dy, 0.5));
    expect(pos[4].dy, closeTo(pos[6].dy, 0.5));
    expect(pos[1].dy, closeTo(pos[3].dy, 0.5));
    expect(pos[3].dy, closeTo(pos[5].dy, 0.5));
  });

  testWidgets('diminuindo a janela as colunas descem, sem estourar',
      (tester) async {
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    for (final width in <double>[1600, 900, 640, 480, 360]) {
      await pumpLegend(tester, width);

      expect(
        tester.takeException(),
        isNull,
        reason: 'estourou o layout em $width px',
      );

      expect(find.byType(Checkbox), findsNWidgets(7));

      final barWidth = tester.getSize(find.byType(AtendimentoLegendBar)).width;
      for (var i = 0; i < 7; i++) {
        final rect = tester.getRect(find.byType(Checkbox).at(i));
        expect(
          rect.right,
          lessThanOrEqualTo(barWidth + 0.5),
          reason: 'checkbox $i saiu da legenda em $width px',
        );
      }
    }
  });
}
