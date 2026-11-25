import 'package:atendimento/atendimento.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/clientes_sem_atendimento.dart';
import '../support/fake_api.dart';

/// Testes com o retorno real de `GetClientesSemAtendimento`: 22 clientes
/// repetidos em 25 dias (550 linhas), todos `NaoVisitadoSemAgenda`, sem
/// modalidade e sem coordenada de atendimento.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final inicio = DateTime(2026, 11, 1);
  final fim = DateTime(2026, 11, 25);

  FakeApi buildApi() => FakeApi(
        pages: const [],
        clientsWithoutService: clientesSemAtendimentoJson(),
        statistics: const <String, dynamic>{'TotalGeral': 0},
      );

  AtendimentoStore buildStore(FakeApi api) => AtendimentoStore(
        repository: AtendimentoRepository(api),
      );

  test('a fixture tem as 550 linhas e as coordenadas com espaço no fim', () {
    final rows = clientesSemAtendimentoJson();

    expect(rows, hasLength(550));
    expect(
      rows.map((row) => row['CodPessoa']).toSet(),
      hasLength(22),
    );
    expect(rows.first['LatitudeCliente'], endsWith(' '));
    expect(rows.every((row) => row['ModalidadeAtendimento'] == null), isTrue);
    expect(rows.every((row) => row['LatitudeAtendimento'] == null), isTrue);
  });

  test('o repositório mantém as 550 linhas com coordenada do cliente', () async {
    final api = buildApi();
    final repository = AtendimentoRepository(api);

    final result = await repository.fetchClientsWithoutService(
      AtendimentoQuery(startDate: inicio, endDate: fim),
    );

    expect(result.isSuccess, isTrue);
    expect(result.value, hasLength(550));
    expect(
      result.value!.every((atendimento) => atendimento.hasValidClientCoord),
      isTrue,
      reason: 'a coordenada vem com espaços no fim da string',
    );
    expect(
      result.value!.every((atendimento) => atendimento.hasValidServiceCoord),
      isFalse,
    );
  });

  group('"Vazio" (Agendamentos = todos)', () {
    late FakeApi api;
    late AtendimentoStore store;

    setUp(() async {
      api = buildApi();
      store = buildStore(api);
      await store.load(start: inicio, end: fim);
    });

    test('chama os dois endpoints', () {
      expect(api.clientCalls, 1);
      expect(api.serviceCalls, 1);
    });

    test('nenhuma das 550 linhas fica de fora', () {
      expect(store.clients, hasLength(550));
      expect(store.services, hasLength(550));
      expect(store.rows, hasLength(550));
      expect(store.filter.showServices, isTrue);
    });

    test('plota um pino por cliente (22), não um por dia', () {
      expect(store.markers, hasLength(22));

      final codigos = clientesSemAtendimento.map((c) => c.codePerson).toSet();
      final pinos = store.markers
          .map((marker) => marker.markerId.value.split('_').last)
          .toSet();
      expect(pinos, codigos);
    });

    test('grade lista 25 dias por cliente, com as datas certas', () {
      final porCliente = <String, int>{};
      for (final atendimento in store.rows) {
        porCliente.update(
          atendimento.codePerson,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }

      expect(porCliente, hasLength(22));
      expect(porCliente.values.every((dias) => dias == 25), isTrue);
      expect(
        store.rows.map((a) => a.startDate).toSet(),
        hasLength(25),
      );
    });

    test('desligar "cliente sem agenda" esconde tudo, sem perder os dados',
        () async {
      await store.setFilterSwitch(3, false);

      expect(store.services, isEmpty);
      expect(store.rows, isEmpty);
      expect(store.markers, isEmpty);
      expect(store.clients, hasLength(550));
    });
  });

  group('"Não Atendidos"', () {
    test('usa só GetClientesSemAtendimento e mostra as 550 linhas', () async {
      final api = buildApi();
      final store = buildStore(api);

      await store.load(
        start: inicio,
        end: fim,
        agendamentosFilter: AgendamentosFiltro.naoAtendidos,
      );

      expect(api.clientCalls, 1);
      expect(api.serviceCalls, 0);
      expect(store.clients, hasLength(550));
      expect(store.rows, hasLength(550));
      expect(store.markers, hasLength(22));
      expect(store.hasMore, isFalse);
    });
  });

  group('"Atendidos"', () {
    test('não chama o endpoint de clientes e não plota nada', () async {
      final api = buildApi();
      final store = buildStore(api);

      await store.load(
        start: inicio,
        end: fim,
        agendamentosFilter: AgendamentosFiltro.atendidos,
      );

      expect(api.clientCalls, 0);
      expect(store.clients, isEmpty);
      expect(store.rows, isEmpty);
      expect(store.markers, isEmpty);
      expect(store.loading, isFalse);
    });
  });
}
