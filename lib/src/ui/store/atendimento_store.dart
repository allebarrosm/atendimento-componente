import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_floating_map_marker_titles_core/model/floating_marker_title_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: library_prefixes
import 'package:latlong2/latlong.dart' as latlng;
import 'package:mobx/mobx.dart';

import '../../core/agendamentos_filtro.dart';
import '../../core/atendimento.dart';
import '../../core/atendimento_filter.dart';
import '../../core/atendimento_query.dart';
import '../../core/atendimento_situacao.dart';
import '../../core/atendimento_statistics.dart';
import '../../data/atendimento_repository.dart';
import 'atendimento_marker_factory.dart';
import 'atendimento_title_factory.dart';

part 'atendimento_store.g.dart';

/// Estado da tela de atendimento: filtro, paginação, marcadores, títulos,
/// seleção e alteração de coordenada.
///
/// As regras de dados ficam no [AtendimentoRepository]; aqui só mora o que é
/// tela: o que mostrar no mapa/lista e como reagir às ações do usuário.
class AtendimentoStore = AtendimentoStoreBase with _$AtendimentoStore;

abstract class AtendimentoStoreBase with Store {
  AtendimentoStoreBase({
    required this.repository,
    this.filter = const AtendimentoFilter(),
    this.enableCoordinateEditing = false,
    this.onError,
    AtendimentoMarkerFactory? markerFactory,
    this.titleFactory = const AtendimentoTitleFactory(),
  })  : markerFactory = markerFactory ??
            AtendimentoMarkerFactory(
              // No mobile: cliente 66px e atendimento 50px (em pixels do
              // bitmap; é o que dá o tamanho certo na tela do aparelho).
              clientIconSize: kIsWeb ? 25 : 66,
              serviceIconSize: kIsWeb ? 25 : 50,
            ),
        // No Web a edição já nasce ligada (o BackOffice não tem mais o botão
        // de "Alterar coordenadas"); no Android nasce desligada.
        coordinateEditing = enableCoordinateEditing;

  final AtendimentoRepository repository;

  /// Habilita o modo de alteração de coordenada (somente Web).
  final bool enableCoordinateEditing;

  final void Function(String message)? onError;

  final AtendimentoMarkerFactory markerFactory;
  final AtendimentoTitleFactory titleFactory;

  // ---------------------------------------------------------------- dados

  /// Linhas cruas devolvidas pela API (atendimentos + clientes do período).
  @observable
  ObservableList<Atendimento> clients = ObservableList.of([]);

  /// Atendimentos visíveis no filtro atual (marcadores de atendimento).
  @observable
  ObservableList<Atendimento> services = ObservableList.of([]);

  /// Clientes visíveis no filtro atual (marcadores de cliente).
  @observable
  ObservableList<Atendimento> visibleClients = ObservableList.of([]);

  @observable
  AtendimentoStatistics? statistics;

  @observable
  AtendimentoCounters counters = AtendimentoCounters.empty;

  @observable
  bool haveServices = false;

  @observable
  bool loading = false;

  @observable
  bool loadingMore = false;

  @observable
  String? errorMessage;

  @observable
  int page = 0;

  // --------------------------------------------------------------- filtros

  @observable
  AtendimentoFilter filter;

  @observable
  bool showClient = false;

  /// Filtro "Agendamentos" (Vazio / Atendidos / Não Atendidos).
  @observable
  AgendamentosFiltro agendamentos = AgendamentosFiltro.todos;

  @observable
  DateTime? startDate;

  @observable
  DateTime? endDate;

  @observable
  String? agent;

  @observable
  String? agentName;

  @observable
  String? supervisor;

  @observable
  String? supervisorName;

  @observable
  String? client;

  @observable
  String? clientName;

  /// `Vendas` / `Não Vendas`.
  @observable
  String? serviceType;

  /// `Presencial` / `Remoto`.
  @observable
  String? modality;

  // ------------------------------------------------------------------ mapa

  @observable
  ObservableList<Marker> markers = ObservableList.of([]);

  @observable
  Set<Polyline> polylines = <Polyline>{};

  @observable
  ObservableList<FloatingMarkerTitleInfo> titles = ObservableList.of([]);

  @observable
  Atendimento? selected;

  @observable
  MarkerId? selectedMarkerId;

  @observable
  LatLng? streetViewCoord;

  /// Lista (mobile) x mapa (web e mobile).
  @observable
  bool isMap = false;

  // ------------------------------------------------- alteração de coordenada

  @observable
  bool coordinateEditing;

  @observable
  Atendimento? editing;

  @observable
  LatLng? editingCoord;

  @observable
  bool savingCoordinate = false;

  /// Nome do endereço digitado no modo de alteração (Web).
  @observable
  String? editingAddress;

  int _markerRequest = 0;

  bool get showCard => selected != null;

  bool get canEditCoordinate =>
      enableCoordinateEditing && coordinateEditing;

  /// Atendimentos exibidos na lista/grade, sem repetir o mesmo atendimento.
  ///
  /// O `Id` do OData **não** identifica um atendimento: em
  /// `GetClientesSemAtendimento` ele é o id do cliente (CNPJ), repetido em
  /// todos os dias do período. Deduplicar só pelo `Id` sumia com 24 dos 25
  /// dias de cada cliente. A chave é o atendimento em si: id + cliente +
  /// data/hora (as duplicatas de paginação têm os três iguais).
  List<Atendimento> get rows {
    final seen = <String>{};
    final result = <Atendimento>[];
    for (final atendimento in services) {
      final key = '${atendimento.id}|${atendimento.codePerson}|'
          '${atendimento.startDate.toIso8601String()}';
      if (seen.add(key)) result.add(atendimento);
    }
    return result;
  }

  bool get hasMore {
    // "Não atendidos" vem inteiro de uma vez (sem paginação).
    if (agendamentos == AgendamentosFiltro.naoAtendidos) return false;

    final total = statistics?.grandTotal ?? 0;
    if (total <= 0) return false;
    return clients.length < total;
  }

  AtendimentoQuery get query => AtendimentoQuery(
        startDate: startDate,
        endDate: endDate,
        supervisor: supervisor,
        agent: agent,
        client: client,
        serviceType: serviceType,
        modality: modality,
        agendamentos: agendamentos,
      );

  // ---------------------------------------------------------------- ações

  /// Carrega estatísticas e as primeiras páginas para o período/filtros.
  @action
  Future<void> load({
    DateTime? start,
    DateTime? end,
    String? agentCode,
    String? agentNameValue,
    String? supervisorCode,
    String? supervisorNameValue,
    String? clientCode,
    String? clientNameValue,
    String? type,
    String? modalityValue,
    AgendamentosFiltro? agendamentosFilter,
  }) async {
    startDate = start == null ? null : AtendimentoQuery.startOfDay(start);
    endDate = end == null ? null : AtendimentoQuery.endOfDay(end);
    agent = agentCode;
    agentName = agentNameValue;
    supervisor = supervisorCode;
    supervisorName = supervisorNameValue;
    client = clientCode;
    clientName = clientNameValue;
    serviceType = type;
    modality = modalityValue;
    final agendamentosAnterior = agendamentos;
    if (agendamentosFilter != null) agendamentos = agendamentosFilter;

    // O interruptor "cliente sem agenda" nasce **desmarcado**: os clientes de
    // `GetClientesSemAtendimento` só entram no mapa/grade quando o usuário
    // liga o interruptor ou escolhe "Não Atendidos" (aí sim a lista inteira é
    // de clientes sem agenda, e o pacote liga o interruptor para ela não vir
    // vazia).
    if (agendamentos == AgendamentosFiltro.naoAtendidos) {
      if (!filter.showServices) {
        filter = filter.copyWith(showServices: true);
      }
    } else if (agendamentosAnterior == AgendamentosFiltro.naoAtendidos &&
        filter.showServices) {
      // Saiu de "Não Atendidos" (para "Vazio" ou "Atendidos"): desliga o
      // interruptor que tinha sido ligado junto com aquele filtro.
      filter = filter.copyWith(showServices: false);
    }

    loading = true;
    errorMessage = null;
    page = 0;

    try {
      // Estatísticas e clientes sem atendimento correm em paralelo com os
      // atendimentos; a tela vai sendo plotada conforme cada um chega.
      final statsFuture = repository.fetchStatistics(query);

      final wantsClients = agendamentos != AgendamentosFiltro.atendidos &&
          query.clientParams().containsKey('dataInicial');
      final clientsFuture = wantsClients
          ? repository.fetchClientsWithoutService(query)
          : null;

      clients.clear();
      services.clear();
      visibleClients.clear();
      haveServices = false;

      if (agendamentos != AgendamentosFiltro.naoAtendidos) {
        var finished = false;
        while (!finished) {
          final result = await repository.fetchPage(
            query: query,
            page: page,
            // Os clientes sem atendimento entram no fim, pelo futuro acima.
            includeClientsWithoutService: false,
          );
          if (!result.isSuccess) {
            _fail(result.errorMessage ?? 'Falha ao carregar atendimentos.');
            break;
          }

          final data = result.value!;
          haveServices = haveServices || data.haveServices;
          clients.addAll(data.services);
          page++;

          // Plota já a página que chegou.
          await _rebuild();

          finished = data.services.isEmpty ||
              data.services.length < repository.pageSize ||
              page >= repository.maxPagesPerLoad;
        }
      }

      if (clientsFuture != null) {
        final clientsResult = await clientsFuture;
        if (!clientsResult.isSuccess) {
          if (agendamentos == AgendamentosFiltro.naoAtendidos) {
            _fail(
              clientsResult.errorMessage ??
                  'Falha ao carregar os clientes não atendidos.',
            );
          }
        } else {
          clients.addAll(clientsResult.value!);
          await _rebuild();
        }
      }

      final stats = await statsFuture;
      statistics =
          stats.isSuccess ? stats.value : AtendimentoStatistics.empty;
    } finally {
      loading = false;
    }
  }

  /// Carrega a próxima página (scroll/grid no Web).
  @action
  Future<void> loadMore() async {
    if (loadingMore || loading || !hasMore) return;

    loadingMore = true;
    try {
      final result = await repository.fetchPage(query: query, page: page);
      if (!result.isSuccess) {
        _fail(result.errorMessage ?? 'Falha ao carregar mais atendimentos.');
        return;
      }
      final data = result.value!;
      haveServices = haveServices || data.haveServices;
      clients.addAll(data.services);
      page++;
      await _rebuild();
    } finally {
      loadingMore = false;
    }
  }

  @action
  Future<void> setFilter(AtendimentoFilter value) async {
    filter = value;
    await _rebuild();
  }

  @action
  Future<void> setFilterSwitch(int switchValue, bool? value) async {
    filter = filter.toggle(switchValue, value ?? false);
    await _rebuild();
  }

  @action
  void setShowClient(bool? value) => showClient = value ?? false;

  @action
  void setMap(bool value) => isMap = value;

  @action
  void select(
    Atendimento atendimento, {
    MarkerId? markerId,
    LatLng? coordinate,
  }) {
    selected = atendimento;
    selectedMarkerId = markerId;
    // O Street View abre no ponto do pino clicado, como no BackOffice: a
    // coordenada do atendimento quando o pino é o dele e a do cliente quando
    // é o pino do cliente. Antes a ordem era sempre "cliente primeiro", o que
    // abria o panorama no endereço do cliente mesmo clicando no atendimento.
    final point = atendimento.locationForMap;
    final coord = coordinate ??
        (point == null ? null : LatLng(point.latitude, point.longitude));
    if (coord != null) streetViewCoord = coord;
  }

  @action
  void clearSelection() {
    selected = null;
    selectedMarkerId = null;
    streetViewCoord = null;
    if (editing != null && !savingCoordinate) {
      unawaited(cancelCoordinateEdit());
    }
  }

  @action
  Future<void> setCoordinateEditing(bool value) async {
    coordinateEditing = value;
    if (!value) await cancelCoordinateEdit();
    await _rebuild();
  }

  /// Inicia a alteração da coordenada do cliente selecionado.
  @action
  void startCoordinateEdit(Atendimento atendimento) {
    if (!enableCoordinateEditing) return;
    editing = atendimento;
    editingAddress = null;
    final coord = atendimento.clientLocation;
    editingCoord = coord == null ? null : LatLng(coord.latitude, coord.longitude);
    selected = atendimento;
  }

  /// Move o pino enquanto o usuário arrasta (ou depois de geocodificar).
  @action
  void moveEditingCoordinate(LatLng coord) {
    editingCoord = coord;
    _refreshEditingMarker();
  }

  /// Geocodifica o endereço digitado e move o pino (Web).
  @action
  Future<bool> changeAddress(String address) async {
    if (!enableCoordinateEditing || editing == null) return false;

    editingAddress = address;
    final geo = await repository.geocodeAddress(address);
    if (geo == null) {
      _fail('Não foi possível localizar o endereço informado.');
      return false;
    }

    moveEditingCoordinate(LatLng(geo.latitude, geo.longitude));
    return true;
  }

  /// Grava a nova coordenada do cliente no backend.
  @action
  Future<bool> saveCoordinate() async {
    final atendimento = editing;
    final coord = editingCoord;
    if (!enableCoordinateEditing ||
        !coordinateEditing ||
        atendimento == null ||
        coord == null) {
      return false;
    }

    savingCoordinate = true;
    try {
      final result = await repository.saveClientCoordinate(
        codePerson: atendimento.codePerson,
        latitude: coord.latitude,
        longitude: coord.longitude,
      );

      if (!result.isSuccess) {
        _fail(result.errorMessage ?? 'Não foi possível salvar a coordenada.');
        return false;
      }

      _applyCoordinate(atendimento.codePerson, coord);
      editing = null;
      editingCoord = null;
      editingAddress = null;
      await _rebuild();
      return true;
    } finally {
      savingCoordinate = false;
    }
  }

  @action
  Future<void> cancelCoordinateEdit() async {
    editing = null;
    editingCoord = null;
    editingAddress = null;
    await _rebuild();
  }

  // ------------------------------------------------------------- interno

  void _fail(String message) {
    errorMessage = message;
    onError?.call(message);
  }

  void _applyCoordinate(String codePerson, LatLng coord) {
    for (var i = 0; i < clients.length; i++) {
      if (clients[i].codePerson != codePerson) continue;
      clients[i] = clients[i].copyWith(
        latClient: coord.latitude,
        lonClient: coord.longitude,
      );
    }
    final current = selected;
    if (current != null && current.codePerson == codePerson) {
      selected = current.copyWith(
        latClient: coord.latitude,
        lonClient: coord.longitude,
      );
    }
  }

  /// Recalcula lista visível, contadores, marcadores, linhas e títulos.
  @action
  Future<void> _rebuild() async {
    final visibleServices = <Atendimento>[];
    final visibleClients = <Atendimento>[];

    for (final atendimento in clients) {
      if (filter.matches(atendimento)) visibleServices.add(atendimento);
      if (filter.matchesAsClient(atendimento) &&
          atendimento.hasValidClientCoord) {
        visibleClients.add(atendimento);
      }
    }

    services = ObservableList.of(visibleServices);
    this.visibleClients = ObservableList.of(visibleClients);
    counters = AtendimentoCounters.from(clients, filter);

    _buildTitles(visibleServices, visibleClients);
    await _buildMarkers(visibleServices, visibleClients);
  }

  void _buildTitles(
    List<Atendimento> servicesToPlot,
    List<Atendimento> clientsToPlot,
  ) {
    final byClient = <String, FloatingMarkerTitleInfo>{};

    final pins = servicesToPlot
        .where((a) =>
            a.situacao != AtendimentoSituacao.naoVisitadoSemAgenda &&
            a.hasValidServiceCoord)
        .toList();

    for (var i = 0; i < pins.length; i++) {
      final atendimento = pins[i];
      final title = titleFactory.titleFor(atendimento, position: i + 1);
      if (title == null) continue;
      byClient.putIfAbsent(_clientKey(atendimento), () => title);
    }

    for (final atendimento in clientsToPlot) {
      final title = titleFactory.titleFor(atendimento);
      if (title == null) continue;
      byClient.putIfAbsent(_clientKey(atendimento), () => title);
    }

    titles = ObservableList.of(byClient.values.toList());
  }

  Future<void> _buildMarkers(
    List<Atendimento> servicesToPlot,
    List<Atendimento> clientsToPlot,
  ) async {
    final request = ++_markerRequest;

    final markers = <Marker>{};
    final polylines = <Polyline>{};
    final clientMarkerKeys = <String>{};

    for (final atendimento in clientsToPlot) {
      final coord = atendimento.clientLocation;
      if (coord == null) continue;

      final markerId = MarkerId(
        '${atendimento.situationService}_${_clientKey(atendimento)}',
      );
      if (!clientMarkerKeys.add(markerId.value)) continue;

      final isEditing =
          coordinateEditing && editing?.codePerson == atendimento.codePerson;
      final position = isEditing && editingCoord != null
          ? editingCoord!
          : LatLng(coord.latitude, coord.longitude);

      markers.add(
        Marker(
          markerId: markerId,
          position: position,
          // O pino mantém o ícone da situação mesmo no modo de edição; só o
          // cliente que está sendo editado ganha o ícone de alvo.
          icon: await _iconOrFallback(
            isEditing
                ? markerFactory.coordinateSelectedIcon
                : markerFactory.forClient(atendimento),
          ),
          zIndexInt: isEditing ? 1000 : 0,
          draggable: coordinateEditing && !savingCoordinate,
          onDragEnd: (newCoord) {
            if (!enableCoordinateEditing) return;
            startCoordinateEdit(atendimento);
            moveEditingCoordinate(newCoord);
          },
          onTap: () => select(
            atendimento,
            markerId: markerId,
            coordinate: position,
          ),
        ),
      );
    }

    for (final atendimento in servicesToPlot) {
      final coord = atendimento.serviceLocation;
      if (coord == null) continue;

      final isEditing =
          coordinateEditing && editing?.codePerson == atendimento.codePerson;
      if (isEditing && editingCoord != null) {
        // O pino do atendimento acompanha o cliente enquanto ele é movido.
        continue;
      }

      final position = LatLng(coord.latitude, coord.longitude);

      if (atendimento.isFarAway &&
          (atendimento.situacao?.isVisited ?? false) &&
          atendimento.hasValidClientCoord) {
        polylines.add(
          Polyline(
            polylineId: PolylineId('atendimento_${atendimento.id}'),
            color: Colors.red,
            points: [
              LatLng(atendimento.latClient!, atendimento.lonClient!),
              position,
            ],
            width: 2,
          ),
        );
      }

      markers.add(
        Marker(
          markerId: MarkerId('${atendimento.id}'),
          position: position,
          icon: await _iconOrFallback(
            markerFactory.forAtendimento(atendimento),
          ),
          zIndexInt: 999,
          onTap: () => select(
            atendimento,
            markerId: MarkerId('${atendimento.id}'),
            coordinate: position,
          ),
        ),
      );
    }

    // Uma nova requisição de marcadores já começou: descarta esta.
    if (request != _markerRequest) return;

    this.markers = ObservableList.of(markers.toList());
    this.polylines = polylines;
  }

  void _refreshEditingMarker() {
    final atendimento = editing;
    final coord = editingCoord;
    if (atendimento == null || coord == null) return;

    final key = _clientKey(atendimento);
    final markerId = MarkerId('${atendimento.situationService}_$key');
    final index = markers.indexWhere((m) => m.markerId == markerId);
    if (index < 0) return;

    final current = markers[index];
    markers[index] = current.copyWith(positionParam: coord);

    final titleIndex = titles.indexWhere((t) => t.id == atendimento.id);
    if (titleIndex >= 0) {
      final title = titles[titleIndex];
      titles[titleIndex] = FloatingMarkerTitleInfo(
        title: title.title,
        id: title.id,
        color: title.color,
        latLng: latlng.LatLng(coord.latitude, coord.longitude),
        isBold: title.isBold,
        zIndex: title.zIndex,
      );
    }

    selected = selected?.copyWith(
      latClient: coord.latitude,
      lonClient: coord.longitude,
    );
  }

  /// Ícone que falhou (asset ausente, teste sem bundle) não derruba o mapa.
  Future<BitmapDescriptor> _iconOrFallback(Future<BitmapDescriptor> icon) async {
    try {
      return await icon;
    } catch (_) {
      return BitmapDescriptor.defaultMarker;
    }
  }

  static String _clientKey(Atendimento atendimento) {
    final code = atendimento.codePerson.trim();
    return code.isEmpty ? atendimento.corporateName : code;
  }
}
