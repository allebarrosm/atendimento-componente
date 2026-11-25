// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'atendimento_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AtendimentoStore on AtendimentoStoreBase, Store {
  late final _$clientsAtom =
      Atom(name: 'AtendimentoStoreBase.clients', context: context);

  @override
  ObservableList<Atendimento> get clients {
    _$clientsAtom.reportRead();
    return super.clients;
  }

  @override
  set clients(ObservableList<Atendimento> value) {
    _$clientsAtom.reportWrite(value, super.clients, () {
      super.clients = value;
    });
  }

  late final _$servicesAtom =
      Atom(name: 'AtendimentoStoreBase.services', context: context);

  @override
  ObservableList<Atendimento> get services {
    _$servicesAtom.reportRead();
    return super.services;
  }

  @override
  set services(ObservableList<Atendimento> value) {
    _$servicesAtom.reportWrite(value, super.services, () {
      super.services = value;
    });
  }

  late final _$visibleClientsAtom =
      Atom(name: 'AtendimentoStoreBase.visibleClients', context: context);

  @override
  ObservableList<Atendimento> get visibleClients {
    _$visibleClientsAtom.reportRead();
    return super.visibleClients;
  }

  @override
  set visibleClients(ObservableList<Atendimento> value) {
    _$visibleClientsAtom.reportWrite(value, super.visibleClients, () {
      super.visibleClients = value;
    });
  }

  late final _$statisticsAtom =
      Atom(name: 'AtendimentoStoreBase.statistics', context: context);

  @override
  AtendimentoStatistics? get statistics {
    _$statisticsAtom.reportRead();
    return super.statistics;
  }

  @override
  set statistics(AtendimentoStatistics? value) {
    _$statisticsAtom.reportWrite(value, super.statistics, () {
      super.statistics = value;
    });
  }

  late final _$countersAtom =
      Atom(name: 'AtendimentoStoreBase.counters', context: context);

  @override
  AtendimentoCounters get counters {
    _$countersAtom.reportRead();
    return super.counters;
  }

  @override
  set counters(AtendimentoCounters value) {
    _$countersAtom.reportWrite(value, super.counters, () {
      super.counters = value;
    });
  }

  late final _$haveServicesAtom =
      Atom(name: 'AtendimentoStoreBase.haveServices', context: context);

  @override
  bool get haveServices {
    _$haveServicesAtom.reportRead();
    return super.haveServices;
  }

  @override
  set haveServices(bool value) {
    _$haveServicesAtom.reportWrite(value, super.haveServices, () {
      super.haveServices = value;
    });
  }

  late final _$loadingAtom =
      Atom(name: 'AtendimentoStoreBase.loading', context: context);

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  late final _$loadingMoreAtom =
      Atom(name: 'AtendimentoStoreBase.loadingMore', context: context);

  @override
  bool get loadingMore {
    _$loadingMoreAtom.reportRead();
    return super.loadingMore;
  }

  @override
  set loadingMore(bool value) {
    _$loadingMoreAtom.reportWrite(value, super.loadingMore, () {
      super.loadingMore = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: 'AtendimentoStoreBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$pageAtom =
      Atom(name: 'AtendimentoStoreBase.page', context: context);

  @override
  int get page {
    _$pageAtom.reportRead();
    return super.page;
  }

  @override
  set page(int value) {
    _$pageAtom.reportWrite(value, super.page, () {
      super.page = value;
    });
  }

  late final _$filterAtom =
      Atom(name: 'AtendimentoStoreBase.filter', context: context);

  @override
  AtendimentoFilter get filter {
    _$filterAtom.reportRead();
    return super.filter;
  }

  @override
  set filter(AtendimentoFilter value) {
    _$filterAtom.reportWrite(value, super.filter, () {
      super.filter = value;
    });
  }

  late final _$showClientAtom =
      Atom(name: 'AtendimentoStoreBase.showClient', context: context);

  @override
  bool get showClient {
    _$showClientAtom.reportRead();
    return super.showClient;
  }

  @override
  set showClient(bool value) {
    _$showClientAtom.reportWrite(value, super.showClient, () {
      super.showClient = value;
    });
  }

  late final _$startDateAtom =
      Atom(name: 'AtendimentoStoreBase.startDate', context: context);

  @override
  DateTime? get startDate {
    _$startDateAtom.reportRead();
    return super.startDate;
  }

  @override
  set startDate(DateTime? value) {
    _$startDateAtom.reportWrite(value, super.startDate, () {
      super.startDate = value;
    });
  }

  late final _$endDateAtom =
      Atom(name: 'AtendimentoStoreBase.endDate', context: context);

  @override
  DateTime? get endDate {
    _$endDateAtom.reportRead();
    return super.endDate;
  }

  @override
  set endDate(DateTime? value) {
    _$endDateAtom.reportWrite(value, super.endDate, () {
      super.endDate = value;
    });
  }

  late final _$agentAtom =
      Atom(name: 'AtendimentoStoreBase.agent', context: context);

  @override
  String? get agent {
    _$agentAtom.reportRead();
    return super.agent;
  }

  @override
  set agent(String? value) {
    _$agentAtom.reportWrite(value, super.agent, () {
      super.agent = value;
    });
  }

  late final _$agentNameAtom =
      Atom(name: 'AtendimentoStoreBase.agentName', context: context);

  @override
  String? get agentName {
    _$agentNameAtom.reportRead();
    return super.agentName;
  }

  @override
  set agentName(String? value) {
    _$agentNameAtom.reportWrite(value, super.agentName, () {
      super.agentName = value;
    });
  }

  late final _$supervisorAtom =
      Atom(name: 'AtendimentoStoreBase.supervisor', context: context);

  @override
  String? get supervisor {
    _$supervisorAtom.reportRead();
    return super.supervisor;
  }

  @override
  set supervisor(String? value) {
    _$supervisorAtom.reportWrite(value, super.supervisor, () {
      super.supervisor = value;
    });
  }

  late final _$supervisorNameAtom =
      Atom(name: 'AtendimentoStoreBase.supervisorName', context: context);

  @override
  String? get supervisorName {
    _$supervisorNameAtom.reportRead();
    return super.supervisorName;
  }

  @override
  set supervisorName(String? value) {
    _$supervisorNameAtom.reportWrite(value, super.supervisorName, () {
      super.supervisorName = value;
    });
  }

  late final _$clientAtom =
      Atom(name: 'AtendimentoStoreBase.client', context: context);

  @override
  String? get client {
    _$clientAtom.reportRead();
    return super.client;
  }

  @override
  set client(String? value) {
    _$clientAtom.reportWrite(value, super.client, () {
      super.client = value;
    });
  }

  late final _$clientNameAtom =
      Atom(name: 'AtendimentoStoreBase.clientName', context: context);

  @override
  String? get clientName {
    _$clientNameAtom.reportRead();
    return super.clientName;
  }

  @override
  set clientName(String? value) {
    _$clientNameAtom.reportWrite(value, super.clientName, () {
      super.clientName = value;
    });
  }

  late final _$serviceTypeAtom =
      Atom(name: 'AtendimentoStoreBase.serviceType', context: context);

  @override
  String? get serviceType {
    _$serviceTypeAtom.reportRead();
    return super.serviceType;
  }

  @override
  set serviceType(String? value) {
    _$serviceTypeAtom.reportWrite(value, super.serviceType, () {
      super.serviceType = value;
    });
  }

  late final _$modalityAtom =
      Atom(name: 'AtendimentoStoreBase.modality', context: context);

  @override
  String? get modality {
    _$modalityAtom.reportRead();
    return super.modality;
  }

  @override
  set modality(String? value) {
    _$modalityAtom.reportWrite(value, super.modality, () {
      super.modality = value;
    });
  }

  late final _$markersAtom =
      Atom(name: 'AtendimentoStoreBase.markers', context: context);

  @override
  ObservableList<Marker> get markers {
    _$markersAtom.reportRead();
    return super.markers;
  }

  @override
  set markers(ObservableList<Marker> value) {
    _$markersAtom.reportWrite(value, super.markers, () {
      super.markers = value;
    });
  }

  late final _$polylinesAtom =
      Atom(name: 'AtendimentoStoreBase.polylines', context: context);

  @override
  Set<Polyline> get polylines {
    _$polylinesAtom.reportRead();
    return super.polylines;
  }

  @override
  set polylines(Set<Polyline> value) {
    _$polylinesAtom.reportWrite(value, super.polylines, () {
      super.polylines = value;
    });
  }

  late final _$titlesAtom =
      Atom(name: 'AtendimentoStoreBase.titles', context: context);

  @override
  ObservableList<FloatingMarkerTitleInfo> get titles {
    _$titlesAtom.reportRead();
    return super.titles;
  }

  @override
  set titles(ObservableList<FloatingMarkerTitleInfo> value) {
    _$titlesAtom.reportWrite(value, super.titles, () {
      super.titles = value;
    });
  }

  late final _$selectedAtom =
      Atom(name: 'AtendimentoStoreBase.selected', context: context);

  @override
  Atendimento? get selected {
    _$selectedAtom.reportRead();
    return super.selected;
  }

  @override
  set selected(Atendimento? value) {
    _$selectedAtom.reportWrite(value, super.selected, () {
      super.selected = value;
    });
  }

  late final _$selectedMarkerIdAtom =
      Atom(name: 'AtendimentoStoreBase.selectedMarkerId', context: context);

  @override
  MarkerId? get selectedMarkerId {
    _$selectedMarkerIdAtom.reportRead();
    return super.selectedMarkerId;
  }

  @override
  set selectedMarkerId(MarkerId? value) {
    _$selectedMarkerIdAtom.reportWrite(value, super.selectedMarkerId, () {
      super.selectedMarkerId = value;
    });
  }

  late final _$streetViewCoordAtom =
      Atom(name: 'AtendimentoStoreBase.streetViewCoord', context: context);

  @override
  LatLng? get streetViewCoord {
    _$streetViewCoordAtom.reportRead();
    return super.streetViewCoord;
  }

  @override
  set streetViewCoord(LatLng? value) {
    _$streetViewCoordAtom.reportWrite(value, super.streetViewCoord, () {
      super.streetViewCoord = value;
    });
  }

  late final _$isMapAtom =
      Atom(name: 'AtendimentoStoreBase.isMap', context: context);

  @override
  bool get isMap {
    _$isMapAtom.reportRead();
    return super.isMap;
  }

  @override
  set isMap(bool value) {
    _$isMapAtom.reportWrite(value, super.isMap, () {
      super.isMap = value;
    });
  }

  late final _$coordinateEditingAtom =
      Atom(name: 'AtendimentoStoreBase.coordinateEditing', context: context);

  @override
  bool get coordinateEditing {
    _$coordinateEditingAtom.reportRead();
    return super.coordinateEditing;
  }

  @override
  set coordinateEditing(bool value) {
    _$coordinateEditingAtom.reportWrite(value, super.coordinateEditing, () {
      super.coordinateEditing = value;
    });
  }

  late final _$editingAtom =
      Atom(name: 'AtendimentoStoreBase.editing', context: context);

  @override
  Atendimento? get editing {
    _$editingAtom.reportRead();
    return super.editing;
  }

  @override
  set editing(Atendimento? value) {
    _$editingAtom.reportWrite(value, super.editing, () {
      super.editing = value;
    });
  }

  late final _$editingCoordAtom =
      Atom(name: 'AtendimentoStoreBase.editingCoord', context: context);

  @override
  LatLng? get editingCoord {
    _$editingCoordAtom.reportRead();
    return super.editingCoord;
  }

  @override
  set editingCoord(LatLng? value) {
    _$editingCoordAtom.reportWrite(value, super.editingCoord, () {
      super.editingCoord = value;
    });
  }

  late final _$savingCoordinateAtom =
      Atom(name: 'AtendimentoStoreBase.savingCoordinate', context: context);

  @override
  bool get savingCoordinate {
    _$savingCoordinateAtom.reportRead();
    return super.savingCoordinate;
  }

  @override
  set savingCoordinate(bool value) {
    _$savingCoordinateAtom.reportWrite(value, super.savingCoordinate, () {
      super.savingCoordinate = value;
    });
  }

  late final _$editingAddressAtom =
      Atom(name: 'AtendimentoStoreBase.editingAddress', context: context);

  @override
  String? get editingAddress {
    _$editingAddressAtom.reportRead();
    return super.editingAddress;
  }

  @override
  set editingAddress(String? value) {
    _$editingAddressAtom.reportWrite(value, super.editingAddress, () {
      super.editingAddress = value;
    });
  }

  late final _$loadAsyncAction =
      AsyncAction('AtendimentoStoreBase.load', context: context);

  @override
  Future<void> load(
      {DateTime? start,
      DateTime? end,
      String? agentCode,
      String? agentNameValue,
      String? supervisorCode,
      String? supervisorNameValue,
      String? clientCode,
      String? clientNameValue,
      String? type,
      String? modalityValue}) {
    return _$loadAsyncAction.run(() => super.load(
        start: start,
        end: end,
        agentCode: agentCode,
        agentNameValue: agentNameValue,
        supervisorCode: supervisorCode,
        supervisorNameValue: supervisorNameValue,
        clientCode: clientCode,
        clientNameValue: clientNameValue,
        type: type,
        modalityValue: modalityValue));
  }

  late final _$loadMoreAsyncAction =
      AsyncAction('AtendimentoStoreBase.loadMore', context: context);

  @override
  Future<void> loadMore() {
    return _$loadMoreAsyncAction.run(() => super.loadMore());
  }

  late final _$setFilterAsyncAction =
      AsyncAction('AtendimentoStoreBase.setFilter', context: context);

  @override
  Future<void> setFilter(AtendimentoFilter value) {
    return _$setFilterAsyncAction.run(() => super.setFilter(value));
  }

  late final _$setFilterSwitchAsyncAction =
      AsyncAction('AtendimentoStoreBase.setFilterSwitch', context: context);

  @override
  Future<void> setFilterSwitch(int switchValue, bool? value) {
    return _$setFilterSwitchAsyncAction
        .run(() => super.setFilterSwitch(switchValue, value));
  }

  late final _$setCoordinateEditingAsyncAction = AsyncAction(
      'AtendimentoStoreBase.setCoordinateEditing',
      context: context);

  @override
  Future<void> setCoordinateEditing(bool value) {
    return _$setCoordinateEditingAsyncAction
        .run(() => super.setCoordinateEditing(value));
  }

  late final _$changeAddressAsyncAction =
      AsyncAction('AtendimentoStoreBase.changeAddress', context: context);

  @override
  Future<bool> changeAddress(String address) {
    return _$changeAddressAsyncAction.run(() => super.changeAddress(address));
  }

  late final _$saveCoordinateAsyncAction =
      AsyncAction('AtendimentoStoreBase.saveCoordinate', context: context);

  @override
  Future<bool> saveCoordinate() {
    return _$saveCoordinateAsyncAction.run(() => super.saveCoordinate());
  }

  late final _$cancelCoordinateEditAsyncAction = AsyncAction(
      'AtendimentoStoreBase.cancelCoordinateEdit',
      context: context);

  @override
  Future<void> cancelCoordinateEdit() {
    return _$cancelCoordinateEditAsyncAction
        .run(() => super.cancelCoordinateEdit());
  }

  late final _$_rebuildAsyncAction =
      AsyncAction('AtendimentoStoreBase._rebuild', context: context);

  @override
  Future<void> _rebuild() {
    return _$_rebuildAsyncAction.run(() => super._rebuild());
  }

  late final _$AtendimentoStoreBaseActionController =
      ActionController(name: 'AtendimentoStoreBase', context: context);

  @override
  void setShowClient(bool? value) {
    final _$actionInfo = _$AtendimentoStoreBaseActionController.startAction(
        name: 'AtendimentoStoreBase.setShowClient');
    try {
      return super.setShowClient(value);
    } finally {
      _$AtendimentoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMap(bool value) {
    final _$actionInfo = _$AtendimentoStoreBaseActionController.startAction(
        name: 'AtendimentoStoreBase.setMap');
    try {
      return super.setMap(value);
    } finally {
      _$AtendimentoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void select(Atendimento atendimento, {MarkerId? markerId}) {
    final _$actionInfo = _$AtendimentoStoreBaseActionController.startAction(
        name: 'AtendimentoStoreBase.select');
    try {
      return super.select(atendimento, markerId: markerId);
    } finally {
      _$AtendimentoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelection() {
    final _$actionInfo = _$AtendimentoStoreBaseActionController.startAction(
        name: 'AtendimentoStoreBase.clearSelection');
    try {
      return super.clearSelection();
    } finally {
      _$AtendimentoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void startCoordinateEdit(Atendimento atendimento) {
    final _$actionInfo = _$AtendimentoStoreBaseActionController.startAction(
        name: 'AtendimentoStoreBase.startCoordinateEdit');
    try {
      return super.startCoordinateEdit(atendimento);
    } finally {
      _$AtendimentoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void moveEditingCoordinate(LatLng coord) {
    final _$actionInfo = _$AtendimentoStoreBaseActionController.startAction(
        name: 'AtendimentoStoreBase.moveEditingCoordinate');
    try {
      return super.moveEditingCoordinate(coord);
    } finally {
      _$AtendimentoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
clients: ${clients},
services: ${services},
visibleClients: ${visibleClients},
statistics: ${statistics},
counters: ${counters},
haveServices: ${haveServices},
loading: ${loading},
loadingMore: ${loadingMore},
errorMessage: ${errorMessage},
page: ${page},
filter: ${filter},
showClient: ${showClient},
startDate: ${startDate},
endDate: ${endDate},
agent: ${agent},
agentName: ${agentName},
supervisor: ${supervisor},
supervisorName: ${supervisorName},
client: ${client},
clientName: ${clientName},
serviceType: ${serviceType},
modality: ${modality},
markers: ${markers},
polylines: ${polylines},
titles: ${titles},
selected: ${selected},
selectedMarkerId: ${selectedMarkerId},
streetViewCoord: ${streetViewCoord},
isMap: ${isMap},
coordinateEditing: ${coordinateEditing},
editing: ${editing},
editingCoord: ${editingCoord},
savingCoordinate: ${savingCoordinate},
editingAddress: ${editingAddress}
    ''';
  }
}
