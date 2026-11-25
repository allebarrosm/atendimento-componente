import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/atendimento.dart';
import '../theme/atendimento_theme.dart';

/// Cria e cacheia os ícones dos marcadores (`BitmapDescriptor`).
///
/// Antes cada app montava os ícones dentro do store, duplicando caminho e
/// tamanho. Os bytes são redimensionados uma vez e reaproveitados.
///
/// São dois tamanhos: o pino do **cliente** (situação) é maior e o do
/// **atendimento** (presencial/remoto/fora do cliente) é menor, porque ele é
/// desenhado por cima (`zIndex` maior) — assim o pino de trás continua visível.
class AtendimentoMarkerFactory {
  AtendimentoMarkerFactory({
    this.clientIconSize = 50,
    this.serviceIconSize = 42,
  });

  /// Lado do pino do cliente (situação), em pixels lógicos.
  final int clientIconSize;

  /// Lado do pino do atendimento (modalidade), em pixels lógicos.
  final int serviceIconSize;

  final Map<String, Future<BitmapDescriptor>> _cache = {};

  Future<BitmapDescriptor> forSituation(String asset) =>
      _load(asset, clientIconSize);

  Future<BitmapDescriptor> forAtendimento(Atendimento atendimento) {
    return _load(
      AtendimentoTheme.assetForModality(
        atendimento.modalidade,
        farAway: atendimento.isFarAway,
      ),
      serviceIconSize,
    );
  }

  Future<BitmapDescriptor> forClient(
    Atendimento atendimento, {
    bool editing = false,
  }) {
    if (editing) return coordinateIcon;
    return _load(
      AtendimentoTheme.assetForSituation(atendimento.situacao),
      clientIconSize,
    );
  }

  Future<BitmapDescriptor> get coordinateIcon =>
      _load(AtendimentoTheme.coordinateIcon, clientIconSize);

  Future<BitmapDescriptor> get coordinateSelectedIcon =>
      _load(AtendimentoTheme.coordinateSelectedIcon, clientIconSize);

  Future<BitmapDescriptor> _load(String asset, int size) {
    return _cache.putIfAbsent(
      '$asset@$size',
      () => _loadIcon(asset, size),
    );
  }

  Future<BitmapDescriptor> _loadIcon(String asset, int size) async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: size,
      targetHeight: size,
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
