import 'package:flutter/material.dart';

import '../../core/atendimento.dart';
import '../store/atendimento_marker_factory.dart';
import '../theme/atendimento_theme.dart';

/// Card do atendimento na lista (layout do Gestão no Android).
class AtendimentoCard extends StatelessWidget {
  const AtendimentoCard({
    super.key,
    required this.atendimento,
    this.onTap,
  });

  final Atendimento atendimento;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const fontSize = 13.0;
    final modality = modalityLabel(atendimento);

    return Card(
      color: scheme.primaryContainer,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _text(atendimento.startDateText, fontSize),
                  const SizedBox(width: 5),
                  _text(atendimento.durationText, fontSize),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _text(
                      atendimento.agentName ?? 'Não informado',
                      fontSize,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _text(
                      atendimento.corporateName,
                      fontSize,
                      bold: true,
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _text(
                      atendimento.fantasy ?? '',
                      fontSize,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              _text(atendimento.address, fontSize, softWrap: true),
              const SizedBox(height: 5),
              Row(
                children: [
                  _text(
                    atendimento.descriptionSituation,
                    fontSize,
                    color: AtendimentoTheme.notAttended,
                  ),
                  const SizedBox(width: 10),
                  _text(
                    modality,
                    fontSize,
                    color: atendimento.modalidade?.code == '0'
                        ? AtendimentoTheme.attended
                        : AtendimentoTheme.remote,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _text(
                      atendimento.descriptionService ?? '',
                      fontSize,
                      bold: true,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _text(
    String value,
    double fontSize, {
    bool bold = false,
    bool softWrap = false,
    Color? color,
  }) {
    return Text(
      value,
      maxLines: softWrap ? 3 : 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : null,
        color: color,
      ),
    );
  }
}

/// Agrupa os contadores do cabeçalho do mobile.
class AtendimentoStatsHeader extends StatefulWidget {
  const AtendimentoStatsHeader({
    super.key,
    required this.items,
    this.initiallyExpanded = false,
  });

  /// Rótulo → valor (já formatado).
  final List<MapEntry<String, String?>> items;
  final bool initiallyExpanded;

  @override
  State<AtendimentoStatsHeader> createState() => _AtendimentoStatsHeaderState();
}

class _AtendimentoStatsHeaderState extends State<AtendimentoStatsHeader> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visible = _expanded ? widget.items : widget.items.take(2).toList();

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Atendimentos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(
                  _expanded ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 18,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              for (final item in visible)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${item.key}: ',
                      style: TextStyle(fontSize: 12, color: scheme.onSurface),
                    ),
                    Text(
                      item.value ?? '-',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
