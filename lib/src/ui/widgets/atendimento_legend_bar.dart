import 'package:flutter/material.dart';

import '../../core/atendimento_filter.dart';
import '../../core/atendimento_situacao.dart';
import '../../core/modalidade.dart';
import '../theme/atendimento_theme.dart';

/// Legenda com os 7 interruptores do mapa, na barra inferior do Web.
///
/// Reproduz o `LegendMap` do BackOffice: quatro colunas, cada uma com até dois
/// itens (ícone + rótulo + checkbox), rolando na horizontal em telas estreitas.
class AtendimentoLegendBar extends StatelessWidget {
  const AtendimentoLegendBar({
    super.key,
    required this.filter,
    required this.onToggleSwitch,
    this.widthFactor = 0.84,
  });

  final AtendimentoFilter filter;

  /// Recebe o mesmo identificador de switch dos apps (1..7).
  final void Function(int switchValue, bool value) onToggleSwitch;

  /// Mesma largura relativa usada pelo BackOffice (84% da tela).
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SizedBox(
      width: size.width * widthFactor,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
        ),
      ),
    );
  }

  Widget _column(List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 5),
          items[i],
        ],
      ],
    );
  }

  Widget _item(String asset, String title, bool value, int switchValue) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(asset, width: 12, height: 12),
        const SizedBox(width: 5),
        SizedBox(
          width: _labelWidth(title),
          child: Text(title, style: const TextStyle(fontSize: 11)),
        ),
        const SizedBox(width: 5),
        SizedBox(
          height: 20,
          child: Checkbox(
            value: value,
            onChanged: (newValue) =>
                onToggleSwitch(switchValue, newValue ?? false),
          ),
        ),
        const SizedBox(width: 25),
      ],
    );
  }

  /// Mesmas larguras do BackOffice, para a barra ficar idêntica.
  double _labelWidth(String title) {
    if (title.length < 11) return 70;
    if (title.length > 27 || title.length == 18) return 190;
    return 150;
  }
}
