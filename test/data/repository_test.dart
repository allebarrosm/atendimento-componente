import 'package:atendimento/core.dart';
import 'package:atendimento/data.dart';
import 'package:roteiro/core.dart' show GeoPoint;
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_api.dart';
import '../support/fixtures.dart';

void main() {
  final period = AtendimentoQuery(
    startDate: DateTime(2026, 11, 1),
    endDate: DateTime(2026, 11, 30, 23, 59, 59, 999),
    agent: '7',
  );

  group('AtendimentoRepository.fetchPage', () {
    test('junta clientes sem atendimento na primeira página', () async {
      final api = FakeApi(
        pages: [
          [atendimentoJson(id: 1, latService: -8.05, lonService: -34.9)],
        ],
        clientsWithoutService: [
          atendimentoJson(
            id: 2,
            situation: 'NaoVisitadoSemAgenda',
            modality: null,
            codePerson: '200',
          ),
        ],
      );
      final repository = AtendimentoRepository(api);

      final result = await repository.fetchPage(
        query: period,
        page: 0,
      );

      expect(result.isSuccess, isTrue);
      expect(result.value!.services, hasLength(2));
      expect(result.value!.haveServices, isTrue);
      expect(api.lastClientParams!['codRepres'], '7');
      expect(api.lastClientParams!['dataInicial'], isNotNull);
      expect(api.lastServiceParams!['top'], '50');
    });

    test('não busca clientes sem atendimento depois da 1ª página', () async {
      final api = FakeApi(pages: []);
      final repository = AtendimentoRepository(api);

      await repository.fetchPage(query: period, page: 1);

      expect(api.lastClientParams, isNull);
      expect(api.lastServiceParams!['skip'], '50');
    });

    test('não pagina clientes quando falta representante/data', () async {
      final api = FakeApi(pages: []);
      final repository = AtendimentoRepository(api);

      await repository.fetchPage(
        query: const AtendimentoQuery(),
        page: 0,
      );

      expect(api.lastClientParams, isNull);
    });

    test('atendimento remoto sem coordenada é deslocado do cliente', () async {
      final api = FakeApi(
        pages: [
          [
            atendimentoJson(
              id: 1,
              modality: '1',
              latClient: -8.05,
              lonClient: -34.9,
            ),
          ],
        ],
      );
      final repository = AtendimentoRepository(api);

      final result = await repository.fetchPage(
        query: period,
        page: 0,
      );
      final atendimento = result.value!.services.single;

      expect(atendimento.latService, isNotNull);
      expect(atendimento.latService, isNot(-8.05));
      expect(atendimento.lonService, isNot(-34.9));
      expect(
        atendimento.latService! - atendimento.latClient!,
        closeTo(0.000005, 0.0000001),
      );
    });

    test('atendimentos no mesmo ponto não ficam empilhados', () async {
      final api = FakeApi(
        pages: [
          [
            atendimentoJson(id: 1, latService: -8.05, lonService: -34.9),
            atendimentoJson(id: 2, latService: -8.05, lonService: -34.9),
            atendimentoJson(id: 3, latService: -8.05, lonService: -34.9),
          ],
        ],
      );
      final repository = AtendimentoRepository(api);

      final result = await repository.fetchPage(
        query: period,
        page: 0,
      );
      final coords = result.value!.services
          .map((a) => '${a.latService},${a.lonService}')
          .toSet();

      expect(coords, hasLength(3));
      expect(result.value!.services.first.latService, -8.05);
    });

    test('mesma entrada gera o mesmo espalhamento (determinístico)', () async {
      Future<List<String>> coords(List<Map<String, dynamic>> page) async {
        final repository = AtendimentoRepository(FakeApi(pages: [page]));
        final result =
            await repository.fetchPage(query: period, page: 0);
        return result.value!.services
            .map((a) => '${a.latService},${a.lonService}')
            .toList();
      }

      final page = [
        atendimentoJson(id: 1, latService: -8.05, lonService: -34.9),
        atendimentoJson(id: 2, latService: -8.05, lonService: -34.9),
      ];

      expect(await coords(page), await coords(page));
    });

    test('devolve erro da API', () async {
      final api = FakeApi(failServices: true);
      final repository = AtendimentoRepository(api);

      final result = await repository.fetchPage(
        query: period,
        page: 0,
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, 'falha de rede');
    });
  });

  group('AtendimentoRepository filtro de agendamentos', () {
    test('"Não atendidos" chama só GetClientesSemAtendimento', () async {
      final api = FakeApi(
        pages: [
          [atendimentoJson(id: 1)],
        ],
        clientsWithoutService: [
          atendimentoJson(
            id: 2,
            situation: 'NaoVisitadoSemAgenda',
            modality: null,
          ),
        ],
      );
      final repository = AtendimentoRepository(api);

      final result = await repository.fetchPage(
        query: period.copyWith(agendamentos: AgendamentosFiltro.naoAtendidos),
        page: 0,
      );

      expect(result.isSuccess, isTrue);
      expect(result.value!.services, hasLength(1));
      expect(api.clientCalls, 1);
      expect(api.serviceCalls, 0);
    });

    test('"Atendidos" chama só GetOData', () async {
      final api = FakeApi(
        pages: [
          [atendimentoJson(id: 1)],
        ],
      );
      final repository = AtendimentoRepository(api);

      final result = await repository.fetchPage(
        query: period.copyWith(agendamentos: AgendamentosFiltro.atendidos),
        page: 0,
      );

      expect(result.value!.services, hasLength(1));
      expect(api.clientCalls, 0);
      expect(api.serviceCalls, 1);
    });

    test('"Vazio" (padrão) continua chamando os dois', () async {
      final api = FakeApi(
        pages: [
          [atendimentoJson(id: 1)],
        ],
      );
      final repository = AtendimentoRepository(api);

      await repository.fetchPage(query: period, page: 0);

      expect(api.clientCalls, 1);
      expect(api.serviceCalls, 1);
    });

    test('"Não atendidos" não pagina depois da primeira', () async {
      final api = FakeApi(pages: []);
      final repository = AtendimentoRepository(api);

      final result = await repository.fetchPage(
        query: period.copyWith(agendamentos: AgendamentosFiltro.naoAtendidos),
        page: 1,
      );

      expect(result.value!.services, isEmpty);
      expect(api.clientCalls, 0);
      expect(api.serviceCalls, 0);
    });

    test('erro no endpoint de clientes é devolvido no modo "Não atendidos"',
        () async {
      final api = FakeApi(
        clientsWithoutService: const [],
        failClients: true,
      );
      final repository = AtendimentoRepository(api);

      final result = await repository.fetchPage(
        query: period.copyWith(agendamentos: AgendamentosFiltro.naoAtendidos),
        page: 0,
      );

      expect(result.isSuccess, isFalse);
    });
  });

  group('AtendimentoRepository geocoder', () {
    test('geocodifica cliente sem coordenada e grava no backend', () async {
      final api = FakeApi(
        pages: [
          [
            atendimentoJson(
              id: 1,
              latClient: null,
              lonClient: null,
              address: 'Rua Sem Coordenada, 50',
            ),
          ],
        ],
      );
      final repository = AtendimentoRepository(
        api,
        geocoder: (address) async {
          expect(address, 'Rua Sem Coordenada, 50');
          return const GeoPoint(-8.1, -34.95);
        },
      );

      final result = await repository.fetchPage(
        query: period,
        page: 0,
      );

      expect(result.value!.services.single.latClient, -8.1);
      expect(api.updates, hasLength(1));
      expect(api.updates.single['codCliente'], '100');
      expect(api.updates.single['latitude'], '-8.1');
    });

    test('sanitiza o endereço antes de geocodificar', () {
      expect(
        AtendimentoRepository.sanitizeAddress('  Rua  A \n 10  '),
        'Rua A 10',
      );
    });

    test('sem geocoder não tenta buscar coordenada', () async {
      final api = FakeApi(
        pages: [
          [atendimentoJson(id: 1, latClient: null, lonClient: null)],
        ],
      );
      final repository = AtendimentoRepository(api);

      final result = await repository.fetchPage(
        query: period,
        page: 0,
      );

      expect(result.value!.services.single.hasValidClientCoord, isFalse);
      expect(api.updates, isEmpty);
    });
  });

  group('AtendimentoRepository estatísticas e coordenada', () {
    test('lê as estatísticas', () async {
      final api = FakeApi(
        statistics: const <String, dynamic>{
          'TotalGeral': 10,
          'TotalVendas': 4,
          'TotalNaoVendas': 6,
          'TotalPresencial': 8,
          'TotalRemoto': 2,
          'TotalOrcamentos': 1,
        },
      );
      final repository = AtendimentoRepository(api);

      final result = await repository.fetchStatistics(period);

      expect(result.value!.grandTotal, 10);
      expect(result.value!.totalSales, 4);
      expect(api.lastStatisticsParams!['dataInicio'], '2026-11-01 00:00:00');
    });

    test('estatísticas com erro devolvem mensagem', () async {
      final api = FakeApi(failStatistics: true);
      final repository = AtendimentoRepository(api);

      final result = await repository.fetchStatistics(period);

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, 'sem estatísticas');
    });

    test('aceita estatísticas embrulhadas em d', () async {
      final api = FakeApi(
        statistics: const <String, dynamic>{
          'd': <String, dynamic>{'TotalGeral': 3},
        },
      );
      final repository = AtendimentoRepository(api);

      final result = await repository.fetchStatistics(period);

      expect(result.value!.grandTotal, 3);
    });

    test('saveClientCoordinate envia os três campos', () async {
      final api = FakeApi();
      final repository = AtendimentoRepository(api);

      final result = await repository.saveClientCoordinate(
        codePerson: '100',
        latitude: -8.05,
        longitude: -34.9,
      );

      expect(result.isSuccess, isTrue);
      expect(api.updates.single, <String, String>{
        'codCliente': '100',
        'latitude': '-8.05',
        'longitude': '-34.9',
      });
    });
  });
}
