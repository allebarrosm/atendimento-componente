import 'package:flutter/material.dart' show Color;
import 'package:flutter_floating_map_marker_titles_core/model/floating_marker_title_info.dart';
// ignore: library_prefixes
import 'package:latlong2/latlong.dart' as latlng;

import '../../core/atendimento.dart';
import '../../core/atendimento_situacao.dart';

/// Monta o título flutuante de cada cliente no mapa.
///
/// Mesma regra do Gestão: o número da sequência aparece antes do nome (menos
/// para "sem agenda e não atendido"); clientes sem atendimento plotado mostram
/// só o nome.
class AtendimentoTitleFactory {
  const AtendimentoTitleFactory();

  FloatingMarkerTitleInfo? titleFor(Atendimento atendimento, {int? position}) {
    final coordinate = position == null
        ? atendimento.clientLocation
        : (atendimento.serviceLocation ?? atendimento.clientLocation);
    if (coordinate == null) return null;

    final name = atendimento.clientName?.trim().isNotEmpty == true
        ? atendimento.clientName!.trim()
        : (atendimento.fantasy ?? '');

    final prefix = position == null ||
            atendimento.situacao == AtendimentoSituacao.naoVisitadoSemAgenda
        ? ''
        : '$position - ';

    return FloatingMarkerTitleInfo(
      title: '$prefix$name',
      id: atendimento.id,
      color: const Color(0xFFFFEB3B),
      latLng: latlng.LatLng(coordinate.latitude, coordinate.longitude),
    );
  }
}
