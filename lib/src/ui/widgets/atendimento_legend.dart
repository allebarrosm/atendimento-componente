import 'package:flutter/material.dart';

import '../../core/atendimento_situacao.dart';
import '../theme/atendimento_theme.dart';

/// Legenda de situações/modalidades — usada no Web (como no BackOffice).
class AtendimentoLegend extends StatelessWidget {
  const AtendimentoLegend({super.key, this.compact = false});

  final bool compact;

  static const _items = <AtendimentoSituacao>[
    AtendimentoSituacao.visitadoComAgenda,
    AtendimentoSituacao.naoVisitadoComAgenda,
    AtendimentoSituacao.visitadoSemAgenda,
    AtendimentoSituacao.naoVisitadoSemAgenda,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final situacao in _items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AtendimentoTheme.assetForSituation(situacao),
                  width: compact ? 16 : 20,
                  height: compact ? 16 : 20,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    situacao.label,
                    style: TextStyle(fontSize: compact ? 11 : 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
