import 'package:atendimento/core.dart';
import 'package:atendimento/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cards de indicadores expandem e recolhem', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AtendimentoStatsHeader(
              statistics: const AtendimentoStatistics(
                grandTotal: 1200,
                totalSales: 900,
                totalNoSales: 300,
                totalBudget: 150,
                totalOnsite: 800,
                totalRemote: 400,
              ),
              counters: const AtendimentoCounters(
                scheduled: 50,
                visited: 40,
                notVisited: 10,
              ),
            ),
          ),
        ),
      ),
    );

    // Expandido: mostra os dois cards e os valores formatados.
    expect(find.text('Clientes'), findsOneWidget);
    expect(find.text('Agenda'), findsOneWidget);
    expect(find.text('1.200'), findsOneWidget);
    expect(find.text('900'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();

    // Recolhido: só "Clientes" e a seta para baixo.
    expect(find.text('Agenda'), findsNothing);
    expect(find.text('Sem Vendas'), findsNothing);
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_downward));
    await tester.pump();

    expect(find.text('Agenda'), findsOneWidget);
  });

  testWidgets('valores zerados aparecem como "-"', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AtendimentoStatsHeader(
            counters: AtendimentoCounters(),
          ),
        ),
      ),
    );

    // Sem estatísticas carregadas tudo é "-".
    expect(find.text('-'), findsWidgets);
  });
}
