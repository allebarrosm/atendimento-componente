import 'package:atendimento/atendimento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('legenda alinha os checkboxes em grade', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AtendimentoLegendBar(
                filter: const AtendimentoFilter(),
                onToggleSwitch: (_, __) {},
              ),
            ],
          ),
        ),
      ),
    );

    final checkboxes = find.byType(Checkbox);
    expect(checkboxes, findsNWidgets(7));

    final positions = <Offset>[
      for (var i = 0; i < 7; i++) tester.getTopLeft(checkboxes.at(i)),
    ];

    // Mesma coluna → mesmo x (0/1, 2/3, 4/5; o 6 é a coluna 4).
    expect(positions[0].dx, closeTo(positions[1].dx, 0.5));
    expect(positions[2].dx, closeTo(positions[3].dx, 0.5));
    expect(positions[4].dx, closeTo(positions[5].dx, 0.5));

    // Todas as colunas têm a mesma largura → x igual ou crescente e espaçado.
    expect(positions[0].dx, lessThan(positions[2].dx));
    expect(positions[2].dx, lessThan(positions[4].dx));
    expect(positions[4].dx, lessThan(positions[6].dx));

    // Mesma linha → mesmo y (1ª e 2ª linhas).
    expect(positions[0].dy, closeTo(positions[2].dy, 0.5));
    expect(positions[2].dy, closeTo(positions[4].dy, 0.5));
    expect(positions[4].dy, closeTo(positions[6].dy, 0.5));
    expect(positions[1].dy, closeTo(positions[3].dy, 0.5));
    expect(positions[3].dy, closeTo(positions[5].dy, 0.5));
  });
}
