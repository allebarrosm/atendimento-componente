import 'package:flutter/material.dart';

import '../../core/atendimento_filter.dart';
import '../../core/atendimento_situacao.dart';
import '../../core/modalidade.dart';
import '../theme/atendimento_theme.dart';

/// Legenda com os 7 interruptores do mapa, na barra inferior do Web.
///
/// No BackOffice são **4 colunas** (duas linhas de itens), com o checkbox
/// alinhado na mesma posição em cada coluna. Quando a janela diminui o número
/// de colunas cai (4 → 3 → 2 → 1) e os itens descem de linha, em vez de sair
/// da tela.
class AtendimentoLegendBar extends StatelessWidget {
  const AtendimentoLegendBar({
    super.key,
    required this.filter,
    required this.onToggleSwitch,
    this.widthFactor = 0.84,
    this.itemHeight = 26,
    this.minColumnWidth = 200,
    this.spacing = 12,
  });

  final AtendimentoFilter filter;

  /// Recebe o mesmo identificador de switch dos apps (1..7).
  final void Function(int switchValue, bool value) onToggleSwitch;

  /// Mesma largura relativa usada pelo BackOffice (84% da tela).
  final double widthFactor;

  /// Altura de cada linha: garante o alinhamento horizontal das colunas.
  final double itemHeight;

  /// Largura mínima de uma coluna; abaixo disso o número de colunas diminui.
  final double minColumnWidth;

  /// Espaço horizontal entre duas colunas.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final target = screenWidth * widthFactor;
        final width = constraints.maxWidth.isFinite
            ? (target < constraints.maxWidth ? target : constraints.maxWidth)
            : target;

        final items = <Widget>[
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
          _item(
            AtendimentoTheme.assetForModality(
              Modalidade.presencial,
              farAway: true,
            ),
            'Presencial fora do cliente',
            filter.showInPersonFarAway,
            7,
          ),
        ];

        // 4 colunas no BackOffice; menos quando não cabe (sem estourar).
        final columns =
            (width / minColumnWidth).floor().clamp(1, 4).toInt();
        // O -0.5 evita que arredondamento faça o Wrap quebrar uma coluna.
        final columnWidth =
            (width - spacing * (columns - 1) - 0.5) / columns;
        final perColumn = (items.length / columns).ceil();

        final chunks = <List<Widget>>[];
        for (var i = 0; i < items.length; i += perColumn) {
          chunks.add(
            items.sublist(
              i,
              (i + perColumn) > items.length ? items.length : i + perColumn,
            ),
          );
        }

        return SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Wrap(
              spacing: spacing,
              runSpacing: 2,
              children: [
                for (final chunk in chunks)
                  SizedBox(
                    width: columnWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: chunk,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
