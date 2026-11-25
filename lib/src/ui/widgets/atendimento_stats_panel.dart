import 'package:flutter/material.dart';

import '../../core/atendimento_format.dart';
import '../../core/atendimento_statistics.dart';

/// Painel lateral do Web — reproduz o `InformationViewWithMap` do BackOffice.
class AtendimentoStatsPanel extends StatelessWidget {
  const AtendimentoStatsPanel({
    super.key,
    required this.statistics,
    required this.counters,
    required this.isMap,
    required this.showClient,
    required this.onToggleMap,
    required this.onShowClient,
    this.onLoadMore,
    this.loadingMore = false,
    this.canEditCoordinate = false,
    this.coordinateEditing = false,
    this.onToggleCoordinateEditing,
    this.width = 180,
  });

  final AtendimentoStatistics? statistics;
  final AtendimentoCounters counters;

  final bool isMap;
  final bool showClient;

  final VoidCallback onToggleMap;
  final void Function(bool value) onShowClient;

  final VoidCallback? onLoadMore;
  final bool loadingMore;

  /// Alteração de coordenada só existe no Web.
  final bool canEditCoordinate;
  final bool coordinateEditing;
  final void Function(bool value)? onToggleCoordinateEditing;

  final double width;

  @override
  Widget build(BuildContext context) {
    final stats = statistics ?? AtendimentoStatistics.empty;

    return SizedBox(
      width: width,
      child: Column(
        children: [
          SizedBox(
            width: width,
            height: 32,
            child: OutlinedButton(
              onPressed: onToggleMap,
              child: Text(isMap ? 'Grid' : 'Mapa'),
            ),
          ),
          const SizedBox(height: 4),
          _box(
            context,
            [
              _info(context, 'Atendimentos', Icons.handshake, stats.grandTotal),
              _info(context, 'Vendas', Icons.thumb_up, stats.totalSales),
              _info(context, 'Sem Vendas', Icons.thumb_down, stats.totalNoSales),
              _info(context, 'Orçamento', Icons.description, stats.totalBudget),
              _info(context, 'Presencial', Icons.person, stats.totalOnsite),
              _info(
                context,
                'Remotas',
                Icons.settings_remote,
                stats.totalRemote,
              ),
            ],
          ),
          _box(
            context,
            [
              _info(context, 'Agenda', Icons.event, counters.scheduled),
              _info(
                context,
                'Atendidos',
                Icons.event_available,
                counters.visited,
              ),
              _info(
                context,
                'Não Atendidos',
                Icons.event_busy_rounded,
                counters.notVisited,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Nome Cliente',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Switch(
                  value: showClient,
                  onChanged: onShowClient,
                ),
              ],
            ),
          ),
          if (canEditCoordinate && onToggleCoordinateEditing != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Alterar coordenadas',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Switch(
                    value: coordinateEditing,
                    onChanged: onToggleCoordinateEditing,
                  ),
                ],
              ),
            ),
          if (onLoadMore != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: SizedBox(
                width: width,
                height: 30,
                child: OutlinedButton(
                  onPressed: loadingMore ? null : onLoadMore,
                  child: loadingMore
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Carregar mais'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _box(BuildContext context, List<Widget> items) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(children: items),
    );
  }

  Widget _info(BuildContext context, String title, IconData icon, int value) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            title,
            style: TextStyle(fontSize: 12, color: scheme.onSurface),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            formatCount(value),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: scheme.onSurface,
            ),
          ),
        ),
        Icon(icon, size: 16, color: scheme.primary),
      ],
    );
  }
}
