import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/atendimento.dart';
import '../theme/atendimento_theme.dart';

/// Cria e cacheia os ícones dos marcadores (`BitmapDescriptor`).
///
/// Antes cada app montava os ícones dentro do store, duplicando caminho e
/// tamanho. Os bytes são redimensionados uma vez e reaproveitados.
class AtendimentoMarkerFactory {
  AtendimentoMarkerFactory({this.iconSize = 25});

  /// Lado do ícone no mapa, em pixels lógicos.
  final int iconSize;

  final Map<String, Future<BitmapDescriptor>> _cache = {};

  Future<BitmapDescriptor> forSituation(String asset) => _load(asset);

  Future<BitmapDescriptor> forAtendimento(Atendimento atendimento) {
    return _load(
      AtendimentoTheme.assetForModality(
        atendimento.modalidade,
        farAway: atendimento.isFarAway,
      ),
    );
  }

  Future<BitmapDescriptor> forClient(
    Atendimento atendimento, {
    bool editing = false,
  }) {
    if (editing) return coordinateIcon;
    return _load(AtendimentoTheme.assetForSituation(atendimento.situacao));
  }

  Future<BitmapDescriptor> get coordinateIcon =>
      _load(AtendimentoTheme.coordinateIcon);

  Future<BitmapDescriptor> get coordinateSelectedIcon =>
      _load(AtendimentoTheme.coordinateSelectedIcon);

  Future<BitmapDescriptor> _load(String asset) {
    return _cache.putIfAbsent(asset, () => _loadIcon(asset));
  }

  Future<BitmapDescriptor> _loadIcon(String asset) async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: iconSize,
      targetHeight: iconSize,
    );
    final frame = await codec.getNextFrame();
    final bytes = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    frame.image.dispose();
    codec.dispose();

    if (bytes == null) {
      throw StateError('Falha ao converter o ícone $asset');
    }

    // `BitmapDescriptor.bytes` só existe nas versões novas; `fromBytes` mantém
    // compatibilidade com google_maps_flutter 2.14 (mesma escolha do roteiro).
    // ignore: deprecated_member_use
    return BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
  }
}

/// Converte a modalidade para o texto usado nos cards.
String modalityLabel(Atendimento atendimento) {
  final modalidade = atendimento.modalidade;
  if (modalidade == null) return 'Cliente sem agenda';
  return modalidade.label;
}
