import 'package:flutter/material.dart';

import '../../core/atendimento_filter.dart';
import '../../core/atendimento_situacao.dart';
import '../../core/modalidade.dart';
import '../theme/atendimento_theme.dart';

/// Legenda com os 7 interruptores do mapa, na barra inferior do Web.
///
/// Quatro colunas de mesma largura; dentro de cada uma o checkbox fica sempre
/// na mesma posição (alinhado em grade), independente do tamanho do rótulo.
class AtendimentoLegendBar extends StatelessWidget {
  const AtendimentoLegendBar({
    super.key,
    required this.filter,
    required this.onToggleSwitch,
    this.widthFactor = 0.84,
    this.itemHeight = 26,
  });

  final AtendimentoFilter filter;

  /// Recebe o mesmo identificador de switch dos apps (1..7).
  final void Function(int switchValue, bool value) onToggleSwitch;

  /// Mesma largura relativa usada pelo BackOffice (84% da tela).
  final double widthFactor;

  /// Altura de cada linha: garante o alinhamento horizontal das colunas.
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final target = size.width * widthFactor;
        final width = constraints.maxWidth.isFinite
            ? (target < constraints.maxWidth ? target : constraints.maxWidth)
            : target;

        return SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _column([
                  _item(
                    AtendimentoTheme.assetForSituation(
                      AtendimentoSituacao.visitadoComAgenda,
                    ),
                    'Cliente agendado e atendido',
                    filter.showCheckAndService,
                    1,
                  ),
                  _item(
                    AtendimentoTheme.assetForSituation(
                      AtendimentoSituacao.naoVisitadoComAgenda,
                    ),
                    'Cliente agendado e não atendido',
                    filter.showCheckAndNotService,
                    2,
                  ),
                ]),
                _column([
                  _item(
                    AtendimentoTheme.assetForSituation(
                      AtendimentoSituacao.naoVisitadoSemAgenda,
                    ),
                    'Cliente sem agenda',
                    filter.showServices,
                    3,
                  ),
                  _item(
                    AtendimentoTheme.assetForSituation(
                      AtendimentoSituacao.visitadoSemAgenda,
                    ),
                    'Cliente sem agenda e atendido',
                    filter.showNotCheckAndService,
                    4,
                  ),
                ]),
                _column([
                  _item(
                    AtendimentoTheme.assetForModality(Modalidade.presencial),
                    'Presencial',
                    filter.showInPerson,
                    5,
                  ),
                  _item(
                    AtendimentoTheme.assetForModality(Modalidade.remoto),
                    'Remoto',
                    filter.showRemote,
                    6,
                  ),
                ]),
                _column([
                  _item(
                    AtendimentoTheme.assetForModality(
                      Modalidade.presencial,
                      farAway: true,
                    ),
                    'Presencial fora do cliente',
                    filter.showInPersonFarAway,
                    7,
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _column(List<Widget> items) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }

  Widget _item(String asset, String title, bool value, int switchValue) {
    return SizedBox(
      height: itemHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(asset, width: 12, height: 12),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 20,
            width: 20,
            child: Checkbox(
              value: value,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged: (newValue) =>
                  onToggleSwitch(switchValue, newValue ?? false),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}
