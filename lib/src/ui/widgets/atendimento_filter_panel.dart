import 'package:flutter/material.dart';

import '../../core/atendimento_filter.dart';
import '../../core/atendimento_situacao.dart';
import '../../core/modalidade.dart';
import '../theme/atendimento_theme.dart';

/// Os 8 interruptores do mapa do atendimento (layout dos dois apps).
///
/// No Android ele abre como painel inferior; no Web pode ser exibido como
/// diálogo. O widget não decide isso: só desenha os switches.
class AtendimentoFilterPanel extends StatelessWidget {
  const AtendimentoFilterPanel({
    super.key,
    required this.filter,
    required this.showClient,
    required this.onToggleSwitch,
    required this.onShowClient,
    this.onClose,
    this.padding = const EdgeInsets.all(10),
  });

  final AtendimentoFilter filter;
  final bool showClient;

  /// Recebe o mesmo identificador de switch dos apps (1..7).
  final void Function(int switchValue, bool value) onToggleSwitch;

  final void Function(bool value) onShowClient;

  final VoidCallback? onClose;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (onClose != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onClose,
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _row(
                        context,
                        label: 'Nome Cliente',
                        value: showClient,
                        onChanged: onShowClient,
                      ),
                      _row(
                        context,
                        label: 'Cliente agendado e atendido',
                        asset: AtendimentoTheme.assetForSituation(
                          AtendimentoSituacao.visitadoComAgenda,
                        ),
                        value: filter.showCheckAndService,
                        onChanged: (v) => onToggleSwitch(1, v),
                      ),
                      _row(
                        context,
                        label: 'Cliente agendado e não atendido',
                        asset: AtendimentoTheme.assetForSituation(
                          AtendimentoSituacao.naoVisitadoComAgenda,
                        ),
                        value: filter.showCheckAndNotService,
                        onChanged: (v) => onToggleSwitch(2, v),
                      ),
                      _row(
                        context,
                        label: 'Cliente sem agenda',
                        asset: AtendimentoTheme.assetForSituation(
                          AtendimentoSituacao.naoVisitadoSemAgenda,
                        ),
                        value: filter.showServices,
                        onChanged: (v) => onToggleSwitch(3, v),
                      ),
                      _row(
                        context,
                        label: 'Cliente sem agenda e atendido',
                        asset: AtendimentoTheme.assetForSituation(
                          AtendimentoSituacao.visitadoSemAgenda,
                        ),
                        value: filter.showNotCheckAndService,
                        onChanged: (v) => onToggleSwitch(4, v),
                      ),
                      _row(
                        context,
                        label: 'Presencial',
                        asset: AtendimentoTheme.assetForModality(
                          Modalidade.presencial,
                        ),
                        value: filter.showInPerson,
                        onChanged: (v) => onToggleSwitch(5, v),
                      ),
                      _row(
                        context,
                        label: 'Remoto',
                        asset: AtendimentoTheme.assetForModality(
                          Modalidade.remoto,
                        ),
                        value: filter.showRemote,
                        onChanged: (v) => onToggleSwitch(6, v),
                      ),
                      _row(
                        context,
                        label: 'Presencial fora do cliente',
                        asset: AtendimentoTheme.assetForModality(
                          Modalidade.presencial,
                          farAway: true,
                        ),
                        value: filter.showInPersonFarAway,
                        onChanged: (v) => onToggleSwitch(7, v),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required String label,
    required bool value,
    required void Function(bool value) onChanged,
    String? asset,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            height: 28,
            width: 28,
            child: Checkbox(
              value: value,
              onChanged: (newValue) => onChanged(newValue ?? false),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          if (asset != null)
            Image.asset(asset, width: 25, height: 25),
        ],
      ),
    );
  }
}
