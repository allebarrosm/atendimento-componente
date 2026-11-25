import 'package:flutter/material.dart';

import '../../core/atendimento_statistics.dart';
import '../theme/atendimento_theme.dart';

/// Painel lateral do Web — reproduz o `InformationViewWithMap` do BackOffice.
///
/// Cards brancos com borda preta, botão Grid/Mapa do mesmo tamanho e as cores
/// dos ícones iguais às do app.
class AtendimentoStatsPanel extends StatelessWidget {
  const AtendimentoStatsPanel({
    super.key,
    required this.statistics,
    required this.counters,
    required this.isMap,
    required this.showClient,
    required this.onToggleMap,
    required this.onShowClient,
    this.width = 180,
  });

  final AtendimentoStatistics? statistics;
  final AtendimentoCounters counters;

  final bool isMap;
  final bool showClient;

  final VoidCallback onToggleMap;
  final void Function(bool value) onShowClient;

  final double width;

  @override
  Widget build(BuildContext context) {
    final stats = statistics ?? AtendimentoStatistics.empty;

    return SizedBox(
      width: width,
      child: Column(
        children: [
          _toggleButton(),
          _box([
            _info('Atendimentos', Icons.handshake, AtendimentoTheme.primary,
                stats.grandTotal),
            _info('Vendas', Icons.thumb_up, AtendimentoTheme.green,
                stats.totalSales),
            _info('Sem Vendas', Icons.thumb_down, AtendimentoTheme.red,
                stats.totalNoSales),
            _info('Orçamento', Icons.description, AtendimentoTheme.blue,
                stats.totalBudget),
            _info('Presencial', Icons.person, AtendimentoTheme.blue,
                stats.totalOnsite),
            _info('Remotas', Icons.settings_remote, AtendimentoTheme.blue,
                stats.totalRemote),
          ]),
          _box([
            _info('Agenda', Icons.event, AtendimentoTheme.primary,
                counters.scheduled == 0 ? null : counters.scheduled),
            _info('Atendidos', Icons.event_available, AtendimentoTheme.green,
                counters.visited == 0 ? null : counters.visited),
            _info('Não Atendidos', Icons.event_busy_rounded,
                AtendimentoTheme.red,
                counters.notVisited == 0 ? null : counters.notVisited),
          ]),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Nome Cliente', style: TextStyle(fontSize: 13)),
                ),
                Switch(
                  value: showClient,
                  onChanged: onShowClient,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Botão Grid/Mapa: mesma caixa branca com borda preta do BackOffice.
  Widget _toggleButton() {
    return InkWell(
      onTap: onToggleMap,
      child: Container(
        height: 56,
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AtendimentoTheme.boxFill,
          border: Border.all(color: AtendimentoTheme.boxBorder),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        alignment: Alignment.center,
        child: Text(
          isMap ? 'Grid' : 'Mapa',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _box(List<Widget> items) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AtendimentoTheme.boxFill,
        border: Border.all(color: AtendimentoTheme.boxBorder),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(children: items),
    );
  }

  Widget _info(String title, IconData icon, Color color, int? value) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            value == null ? '-' : '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        Icon(icon, size: 16, color: color),
      ],
    );
  }
}
