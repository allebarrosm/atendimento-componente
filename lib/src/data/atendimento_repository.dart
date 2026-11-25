import 'dart:convert';
import 'dart:math' as math;

import 'package:roteiro/core.dart' show GeoPoint;

import '../core/agendamentos_filtro.dart';
import '../core/atendimento.dart';
import '../core/atendimento_query.dart';
import '../core/atendimento_statistics.dart';
import '../core/modalidade.dart';
import 'atendimento_api.dart';

/// Página de atendimentos já normalizada pelo repositório.
class AtendimentoPage {
  const AtendimentoPage({
    required this.services,
    required this.haveServices,
  });

  final List<Atendimento> services;

  /// A API devolveu algum atendimento (ou cliente agendado) no período.
  final bool haveServices;

  static const empty = AtendimentoPage(services: [], haveServices: false);
}

/// Regras de dados do atendimento: paginação, normalização de coordenadas,
/// agrupamento de atendimentos repetidos no mesmo ponto e estatísticas.
///
/// É Dart puro: o transporte vem de [AtendimentoApi] e o geocoder é injetado.
class AtendimentoRepository {
  AtendimentoRepository(
    this.api, {
    this.geocoder,
    this.pageSize = 50,
    this.maxPagesPerLoad = 10,
  });

  final AtendimentoApi api;

  /// Geocodifica o endereço quando o cliente ainda não tem coordenada.
  final AtendimentoGeocoder? geocoder;

  final int pageSize;

  /// Limite de páginas do primeiro carregamento (evita loop infinito).
  final int maxPagesPerLoad;

  /// Carrega uma página e devolve os atendimentos prontos para o mapa.
  ///
  /// Na primeira página também busca os clientes sem atendimento do período,
  /// como os apps fazem hoje (marcadores cinza).
  Future<AtendimentoResult<AtendimentoPage>> fetchPage({
    required AtendimentoQuery query,
    required int page,
    bool includeClientsWithoutService = true,
  }) async {
    final onlyNotAttended =
        query.agendamentos == AgendamentosFiltro.naoAtendidos;
    final onlyAttended = query.agendamentos == AgendamentosFiltro.atendidos;

    // "Não atendidos" é uma consulta única: o endpoint devolve a lista toda e
    // não entende `skip`/`top`. A partir da 2ª página não há mais nada.
    if (onlyNotAttended && page > 0) {
      return const AtendimentoResult.success(AtendimentoPage.empty);
    }

    final raw = <Map<String, dynamic>>[];
    var haveServices = false;

    // Basta o período: o representante é opcional na consulta (e o filtro
    // "Agendamentos" precisa dessa chamada também no modo "Vazio").
    final canCallClients =
        query.clientParams().containsKey('dataInicial');

    final callClients = page == 0 &&
        !onlyAttended &&
        canCallClients &&
        (includeClientsWithoutService || onlyNotAttended);

    // As duas chamadas saem juntas: o tempo total passa a ser o da mais lenta
    // (o endpoint de clientes sem atendimento costuma ser a mais demorada).
    final clientsFuture =
        callClients ? api.getClientsWithoutService(query.clientParams()) : null;
    final servicesFuture = !onlyNotAttended
        ? api.getServices(query.serviceParams(page: page, pageSize: pageSize))
        : null;

    final clientsResponse =
        clientsFuture == null ? null : await clientsFuture;
    final servicesResponse =
        servicesFuture == null ? null : await servicesFuture;

    if (clientsResponse != null) {
      if (!clientsResponse.success && onlyNotAttended) {
        return AtendimentoResult.error(
          clientsResponse.errorMessage ??
              'Não foi possível carregar os clientes não atendidos.',
        );
      }
      if (clientsResponse.success && clientsResponse.body != null) {
        raw.addAll(_decodeList(clientsResponse.body!));
      }
    }

    if (servicesResponse != null) {
      if (!servicesResponse.success) {
        return AtendimentoResult.error(
          servicesResponse.errorMessage ??
              'Não foi possível carregar os atendimentos.',
        );
      }

      final servicesJson = _decodeList(servicesResponse.body ?? '');
      if (servicesJson.isNotEmpty) haveServices = true;
      raw.addAll(servicesJson);
    }

    final services = <Atendimento>[];
    for (final json in raw) {
      var atendimento = Atendimento.fromJson(json);

      if (!haveServices &&
          atendimento.situationService != 'NaoVisitadoSemAgenda') {
        haveServices = true;
      }

      atendimento = await _prepareCoordinates(atendimento);
      services.add(atendimento);
    }

    return AtendimentoResult.success(
      AtendimentoPage(
        services: _spreadSharedPoints(services),
        haveServices: haveServices,
      ),
    );
  }

  /// Busca só os clientes que deveriam ter sido atendidos e não foram.
  ///
  /// É a chamada mais demorada da consulta; fica pública para o store disparar
  /// em paralelo com os atendimentos e plotar cada parte assim que chega.
  Future<AtendimentoResult<List<Atendimento>>> fetchClientsWithoutService(
    AtendimentoQuery query,
  ) async {
    final response = await api.getClientsWithoutService(query.clientParams());
    if (!response.success) {
      return AtendimentoResult.error(
        response.errorMessage ??
            'Não foi possível carregar os clientes não atendidos.',
      );
    }

    final result = <Atendimento>[];
    for (final json in _decodeList(response.body ?? '')) {
      result.add(await _prepareCoordinates(Atendimento.fromJson(json)));
    }
    return AtendimentoResult.success(result);
  }

  /// Busca várias páginas de uma vez (primeiro carregamento).
  Future<AtendimentoResult<AtendimentoPage>> fetchFirstLoad(
    AtendimentoQuery query,
  ) async {
    final all = <Atendimento>[];
    var haveServices = false;
    var page = 0;

    while (page < maxPagesPerLoad) {
      final result = await fetchPage(query: query, page: page);
      if (!result.isSuccess) return result;

      final current = result.value!;
      haveServices = haveServices || current.haveServices;
      if (current.services.isEmpty) break;

      all.addAll(current.services);
      page++;

      if (current.services.length < pageSize) break;
    }

    return AtendimentoResult.success(
      AtendimentoPage(services: all, haveServices: haveServices),
    );
  }

  Future<AtendimentoResult<AtendimentoStatistics>> fetchStatistics(
    AtendimentoQuery query,
  ) async {
    final response = await api.getStatistics(query.statisticsParams());
    if (!response.success) {
      return AtendimentoResult.error(
        response.errorMessage ?? 'Não foi possível carregar as estatísticas.',
      );
    }

    try {
      final decoded = jsonDecode(response.body ?? '{}');
      if (decoded is Map<String, dynamic>) {
        // Alguns ambientes devolvem o objeto embrulhado em `d`/`value`.
        final payload = decoded.containsKey('TotalGeral')
            ? decoded
            : (decoded['d'] ?? decoded['value'] ?? decoded);
        if (payload is Map<String, dynamic>) {
          return AtendimentoResult.success(
            AtendimentoStatistics.fromJson(payload),
          );
        }
      }
      return const AtendimentoResult.error(
        'Resposta de estatísticas inválida.',
      );
    } catch (_) {
      return const AtendimentoResult.error(
        'Resposta de estatísticas inválida.',
      );
    }
  }

  /// Grava a coordenada do cliente (`POST /api/endereco/cordenadas`).
  Future<AtendimentoResult<bool>> saveClientCoordinate({
    required String codePerson,
    required double latitude,
    required double longitude,
  }) async {
    final response = await api.updateClientCoordinate(<String, String>{
      'codCliente': codePerson,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    });
    if (!response.success) {
      return AtendimentoResult.error(
        response.errorMessage ?? 'Não foi possível salvar a coordenada.',
      );
    }
    return const AtendimentoResult.success(true);
  }

  /// Geocodifica um endereço; devolve `null` quando não há geocoder.
  Future<GeoPoint?> geocodeAddress(String address) async {
    final clean = sanitizeAddress(address);
    if (clean.isEmpty || geocoder == null) return null;
    try {
      return await geocoder!(clean);
    } catch (_) {
      return null;
    }
  }

  /// Remove quebras de linha e espaços repetidos antes de geocodificar.
  static String sanitizeAddress(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<Atendimento> _prepareCoordinates(Atendimento atendimento) async {
    var current = atendimento;

    if (!current.hasValidClientCoord) {
      final geo = await geocodeAddress(current.address);
      if (geo != null) {
        current = current.copyWith(
          latClient: geo.latitude,
          lonClient: geo.longitude,
        );
        await api.updateClientCoordinate(<String, String>{
          'codCliente': current.codePerson,
          'latitude': geo.latitude.toString(),
          'longitude': geo.longitude.toString(),
        });
      }
    }

    // Atendimento remoto sem coordenada própria: desloca um pouco do cliente
    // para os dois pinos não ficarem exatamente um em cima do outro.
    if (!current.hasValidServiceCoord &&
        current.modalidade == Modalidade.remoto &&
        current.hasValidClientCoord) {
      current = current.copyWith(
        latService: current.latClient! + 0.000005,
        lonService: current.lonClient! + 0.0000001,
      );
    }

    return current;
  }

  /// Atendimentos no mesmo ponto ganhariam um único marcador; espalha os
  /// excedentes em volta do ponto. Determinístico: não muda entre recargas.
  static List<Atendimento> _spreadSharedPoints(List<Atendimento> services) {
    final groups = <String, List<int>>{};
    for (var i = 0; i < services.length; i++) {
      final coord = services[i].serviceLocation;
      if (coord == null) continue;
      groups
          .putIfAbsent(
            '${coord.latitude.toStringAsFixed(6)}_'
            '${coord.longitude.toStringAsFixed(6)}',
            () => <int>[],
          )
          .add(i);
    }

    final result = List<Atendimento>.of(services);
    groups.forEach((_, indexes) {
      if (indexes.length < 2) return;
      final origin = result[indexes.first].serviceLocation!;
      final offsets = _spiral(origin, count: indexes.length - 1, radiusMeters: 2);
      for (var i = 1; i < indexes.length; i++) {
        result[indexes[i]] = result[indexes[i]].copyWith(
          latService: offsets[i - 1].latitude,
          lonService: offsets[i - 1].longitude,
        );
      }
    });

    return result;
  }

  static List<GeoPoint> _spiral(
    GeoPoint origin, {
    required int count,
    required double radiusMeters,
  }) {
    final goldenAngle = math.pi * (3 - math.sqrt(5));
    const metersPerDegree = 111320.0;

    final points = <GeoPoint>[];
    for (var i = 0; i < count; i++) {
      final radius = radiusMeters * math.sqrt((i + 1) / (count + 1));
      final angle = i * goldenAngle;
      final dLat = radius * math.cos(angle) / metersPerDegree;
      final dLon = radius * math.sin(angle) /
          (metersPerDegree * math.cos(origin.latitude * math.pi / 180));
      points.add(GeoPoint(origin.latitude + dLat, origin.longitude + dLon));
    }
    return points;
  }

  static List<Map<String, dynamic>> _decodeList(String body) {
    if (body.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(body);
      final List<dynamic> list;

      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final d = decoded['d'];
        if (d is Map<String, dynamic> && d['results'] is List) {
          list = d['results'] as List<dynamic>;
        } else if (decoded['value'] is List) {
          list = decoded['value'] as List<dynamic>;
        } else if (d is List) {
          list = d;
        } else {
          list = const [];
        }
      } else {
        list = const [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }
}
