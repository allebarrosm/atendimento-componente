import 'package:flutter/material.dart';

import '../../core/atendimento_format.dart';
import '../../core/atendimento_statistics.dart';
import '../theme/atendimento_theme.dart';

/// Cards de indicadores do mobile — mesma composição do Gestão.
///
/// Duas caixas com borda: a primeira mostra "Clientes" e, expandida, vendas,
/// orçamento e modalidade; a segunda (só quando expandida) mostra a agenda.
class AtendimentoStatsHeader extends StatefulWidget {
  const AtendimentoStatsHeader({
    super.key,
    this.statistics,
    required this.counters,
    this.initiallyExpanded = true,
  });

  final AtendimentoStatistics? statistics;
  final AtendimentoCounters counters;
  final bool initiallyExpanded;

  @override
  State<AtendimentoStatsHeader> createState() => _AtendimentoStatsHeaderState();
}

class _AtendimentoStatsHeaderState extends State<AtendimentoStatsHeader> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final stats = widget.statistics;
    final counters = widget.counters;

    return Column(
      children: [
        _box([
          Row(
            children: [
              Expanded(
                child: _info(
                  context,
                  'Clientes',
                  Icons.handshake,
                  AtendimentoTheme.primary,
                  stats?.grandTotal,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Icon(
                  _expanded ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 20,
                ),
              ),
            ],
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  _info(
                    context,
                    'Agendados',
                    Icons.thumb_up,
                    AtendimentoTheme.green,
                    stats?.totalSales,
                  ),
                  _info(
                    context,
                    'Sem Vendas',
                    Icons.thumb_down,
                    AtendimentoTheme.red,
                    stats?.totalNoSales,
                  ),
                  _info(
                    context,
                    'Orçamento',
                    Icons.description,
                    AtendimentoTheme.blue,
                    stats?.totalBudget,
                  ),
                  _info(
                    context,
                    'Presencial',
                    Icons.person,
                    AtendimentoTheme.blue,
                    stats?.totalOnsite,
                  ),
                  _info(
                    context,
                    'Remoto',
                    Icons.settings_remote,
                    AtendimentoTheme.blue,
                    stats?.totalRemote,
                  ),
                ],
              ),
            ),
        ]),
        if (_expanded)
          _box([
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  _info(
                    context,
                    'Agenda',
                    Icons.event,
                    AtendimentoTheme.primary,
                    counters.scheduled == 0 ? null : counters.scheduled,
                  ),
                  _info(
                    context,
                    'Atendidos',
                    Icons.event_available,
                    AtendimentoTheme.green,
                    counters.visited == 0 ? null : counters.visited,
                  ),
                  _info(
                    context,
                    'Não Atendidos',
                    Icons.event_busy_rounded,
                    AtendimentoTheme.red,
                    counters.notVisited == 0 ? null : counters.notVisited,
                  ),
                ],
              ),
            ),
          ]),
      ],
    );
  }

  Widget _box(List<Widget> children) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: MediaQuery.sizeOf(context).width * 0.95,
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outline),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: scheme.primaryContainer,
      ),
      child: Column(children: children),
    );
  }

  Widget _info(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    int? value,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          Text(
            value == null ? '-' : formatCount(value),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: scheme.onPrimaryContainer,
            ),
          ),
          Icon(icon, size: 16, color: color),
        ],
      ),
    );
  }
}
