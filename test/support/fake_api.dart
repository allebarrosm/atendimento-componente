import 'dart:convert';

import 'package:atendimento/data.dart';

/// API em memória para os testes de repositório e de store.
class FakeApi implements AtendimentoApi {
  FakeApi({
    this.pages = const [],
    this.clientsWithoutService = const [],
    this.statistics = const <String, dynamic>{},
    this.failStatistics = false,
    this.failServices = false,
    this.failClients = false,
    this.failUpdate = false,
  });

  final List<List<Map<String, dynamic>>> pages;
  final List<Map<String, dynamic>> clientsWithoutService;
  final Map<String, dynamic> statistics;
  final bool failStatistics;
  final bool failServices;
  final bool failClients;
  final bool failUpdate;

  final List<Map<String, String>> updates = [];
  int clientCalls = 0;
  int serviceCalls = 0;

  Map<String, String>? lastServiceParams;
  Map<String, String>? lastClientParams;
  Map<String, String>? lastStatisticsParams;

  @override
  Future<AtendimentoResponse> getServices(Map<String, String> params) async {
    serviceCalls++;
    lastServiceParams = params;
    if (failServices) {
      return const AtendimentoResponse.failure('falha de rede');
    }

    final page = int.parse(params['skip']!) ~/ int.parse(params['top']!);
    final values = page < pages.length ? pages[page] : const [];
    return AtendimentoResponse.ok(jsonEncode(<String, dynamic>{
      'd': {'results': values},
    }));
  }

  @override
  Future<AtendimentoResponse> getClientsWithoutService(
    Map<String, String> params,
  ) async {
    clientCalls++;
    lastClientParams = params;
    if (failClients) {
      return const AtendimentoResponse.failure('falha de clientes');
    }
    return AtendimentoResponse.ok(jsonEncode(clientsWithoutService));
  }

  @override
  Future<AtendimentoResponse> getStatistics(Map<String, String> params) async {
    lastStatisticsParams = params;
    if (failStatistics) {
      return const AtendimentoResponse.failure('sem estatísticas');
    }
    return AtendimentoResponse.ok(jsonEncode(statistics));
  }

  @override
  Future<AtendimentoResponse> updateClientCoordinate(
    Map<String, String> params,
  ) async {
    if (failUpdate) {
      return const AtendimentoResponse.failure('não salvou');
    }
    updates.add(params);
    return const AtendimentoResponse.ok('{}');
  }
}
