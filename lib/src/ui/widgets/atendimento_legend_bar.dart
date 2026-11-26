import 'package:flutter/material.dart';

import '../../core/atendimento_filter.dart';
import '../../core/atendimento_situacao.dart';
import '../../core/modalidade.dart';
import '../theme/atendimento_theme.dart';

/// Legenda com os 7 interruptores do mapa, na barra inferior do Web.
///
/// Os itens são compactos (ícone + rótulo + checkbox logo em seguida) e usam
/// `Wrap`: quando a janela diminui eles quebram para a linha de baixo em vez
/// de sair da tela.
class AtendimentoLegendBar extends StatelessWidget {
  const AtendimentoLegendBar({
    super.key,
    required this.filter,
    required this.onToggleSwitch,
    this.widthFactor = 0.84,
    this.spacing = 12,
    this.itemHeight = 26,
  });

  final AtendimentoFilter filter;

  /// Recebe o mesmo identificador de switch dos apps (1..7).
  final void Function(int switchValue, bool value) onToggleSwitch;

  /// Mesma largura relativa usada pelo BackOffice (84% da tela).
  final double widthFactor;

  /// Espaço horizontal entre dois itens da mesma linha.
  final double spacing;

  /// Altura de cada item.
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final target = screenWidth * widthFactor;
        final width = constraints.maxWidth.isFinite
            ? (target < constraints.maxWidth ? target : constraints.maxWidth)
            : target;

        return SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Wrap(
              spacing: spacing,
              runSpacing: 0,
              children: [
                _item(
                  AtendimentoTheme.assetForSituation(
                    AtendimentoSituacao.visitadoComAgenda,
                  ),
                  'Cliente agendado e atendido',
                  filter.showCheckAndService,
                  1,
                  width,
                ),
                _item(
                  AtendimentoTheme.assetForSituation(
                    AtendimentoSituacao.naoVisitadoComAgenda,
                  ),
                  'Cliente agendado e não atendido',
                  filter.showCheckAndNotService,
                  2,
                  width,
                ),
                _item(
                  AtendimentoTheme.assetForSituation(
                    AtendimentoSituacao.naoVisitadoSemAgenda,
                  ),
                  'Cliente sem agenda',
                  filter.showServices,
                  3,
                  width,
                ),
                _item(
                  AtendimentoTheme.assetForSituation(
                    AtendimentoSituacao.visitadoSemAgenda,
                  ),
                  'Cliente sem agenda e atendido',
                  filter.showNotCheckAndService,
                  4,
                  width,
                ),
                _item(
                  AtendimentoTheme.assetForModality(Modalidade.presencial),
                  'Presencial',
                  filter.showInPerson,
                  5,
                  width,
                ),
                _item(
                  AtendimentoTheme.assetForModality(Modalidade.remoto),
                  'Remoto',
                  filter.showRemote,
                  6,
                  width,
                ),
                _item(
                  AtendimentoTheme.assetForModality(
                    Modalidade.presencial,
                    farAway: true,
                  ),
                  'Presencial fora do cliente',
                  filter.showInPersonFarAway,
                  7,
                  width,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _item(
    String asset,
    String title,
    bool value,
    int switchValue,
    double maxWidth,
  ) {
    return SizedBox(
      height: itemHeight,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => onToggleSwitch(switchValue, !value),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(asset, width: 12, height: 12),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              const SizedBox(width: 2),
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
            ],
          ),
        ),
      ),
    );
  }
}
