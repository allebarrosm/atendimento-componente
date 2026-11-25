import 'package:flutter/material.dart';

import '../../core/atendimento_situacao.dart';
import '../../core/modalidade.dart';

/// Cores e ícones do atendimento — iguais nos dois apps.
///
/// Os arquivos vivem no próprio pacote para o layout não depender das pastas de
/// imagens de cada app.
class AtendimentoTheme {
  const AtendimentoTheme._();

  static const String _assetBase = 'packages/atendimento/assets/images';

  static const Color scheduled = Color(0xFF2E86DE);
  static const Color attended = Color(0xFF38D2C0);
  static const Color notAttended = Color(0xFFF2A785);
  static const Color remote = Color(0xFFF2A785);

  /// Ícone da situação do cliente (marcador e filtro).
  static String assetForSituation(AtendimentoSituacao? situacao) {
    switch (situacao) {
      case AtendimentoSituacao.visitadoComAgenda:
        return '$_assetBase/blue_target.png';
      case AtendimentoSituacao.naoVisitadoComAgenda:
        return '$_assetBase/red_target.png';
      case AtendimentoSituacao.naoVisitadoSemAgenda:
        return '$_assetBase/grey_target.png';
      case AtendimentoSituacao.visitadoSemAgenda:
        return '$_assetBase/yellow_target.png';
      case null:
        return '$_assetBase/grey_target.png';
    }
  }

  /// Ícone da modalidade do atendimento.
  static String assetForModality(Modalidade? modalidade, {bool farAway = false}) {
    if (modalidade == Modalidade.remoto) {
      return '$_assetBase/place-yellow.png';
    }
    if (farAway) return '$_assetBase/place-red.png';
    return '$_assetBase/place-green.png';
  }

  /// Ícone usado enquanto o modo de alteração de coordenada está ligado.
  static String get coordinateIcon => '$_assetBase/set_coord_icon.png';

  /// Ícone do marcador selecionado no modo de alteração de coordenada.
  static String get coordinateSelectedIcon =>
      '$_assetBase/set_coord_click_icon.png';

  static Color colorForSituation(AtendimentoSituacao? situacao) {
    switch (situacao) {
      case AtendimentoSituacao.visitadoComAgenda:
        return attended;
      case AtendimentoSituacao.naoVisitadoComAgenda:
        return notAttended;
      case AtendimentoSituacao.visitadoSemAgenda:
        return attended;
      case AtendimentoSituacao.naoVisitadoSemAgenda:
        return scheduled;
      case null:
        return scheduled;
    }
  }
}
