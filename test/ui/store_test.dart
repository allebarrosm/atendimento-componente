import 'dart:async';

import 'package:atendimento/atendimento.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roteiro/core.dart' show GeoPoint;

import '../support/fake_api.dart';
import '../support/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final period = DateTime(2026, 11, 1);

  AtendimentoStore buildStore(
    FakeApi api, {
    bool enableCoordinateEditing = true,
    GeoPoint? geocoded,
    void Function(String)? onError,
    int maxPagesPerLoad = 10,
  }) {
    final repository = AtendimentoRepository(
      api,
      geocoder: geocoded == null ? null : (_) async => geocoded,
      maxPagesPerLoad: maxPagesPerLoad,
    );
    return AtendimentoStore(
      repository: repository,
      enableCoordinateEditing: enableCoordinateEditing,
      onError: onError,
    );
  }

  group('AtendimentoStore.load', () {
    test('carrega páginas, estatísticas, contadores e títulos', () async {
      final api = FakeApi(
        pages: [
          [
            atendimentoJson(id: 1, codePerson: '100'),
            atendimentoJson(
              id: 2,
              codePerson: '200',
              situation: 'NaoVisitadoComAgenda',
            ),
            atendimentoJson(
              id: 3,
              codePerson: '300',
              situation: 'VisitadoSemAgenda',
            ),
          ],
        ],
        statistics: const <String, dynamic>{
          'TotalGeral': 3,
          'TotalVendas': 2,
          'TotalPresencial': 3,
        },
      );
      final store = buildStore(api);

      await store.load(start: period, end: period.add(const Duration(days: 30)));

      expect(store.loading, isFalse);
      expect(store.clients, hasLength(3));
      expect(store.services, hasLength(3));
      expect(store.rows, hasLength(3));
      expect(store.statistics!.grandTotal, 3);
      expect(store.counters.scheduled, 2);
      expect(store.counters.visited, 2);
      expect(store.counters.notVisited, 1);
      expect(store.titles, isNotEmpty);
      expect(store.markers, isNotEmpty);
      expect(store.errorMessage, isNull);
      expect(store.hasMore, isFalse);
    });

    test('filtra "sem agenda" desligado por padrão', () async {
      final api = FakeApi(
        pages: [
          [
            atendimentoJson(id: 1, situation: 'NaoVisitadoSemAgenda'),
            atendimentoJson(id: 2, situation: 'VisitadoComAgenda'),
          ],
        ],
      );
      final store = buildStore(api);

      await store.load();

      expect(store.clients, hasLength(2));
      expect(store.services, hasLength(1));
      expect(store.rows.single.id, 2);
    });

    test('respeita páginas cheias e permite carregar mais', () async {
      final primeiraPagina = <Map<String, dynamic>>[
        for (var i = 1; i <= 50; i++) atendimentoJson(id: i),
      ];
      final segundaPagina = <Map<String, dynamic>>[
        for (var i = 51; i <= 60; i++) atendimentoJson(id: i),
      ];
      final api = FakeApi(
        pages: [primeiraPagina, segundaPagina],
        statistics: const <String, dynamic>{'TotalGeral': 60},
      );
      final store = buildStore(api, maxPagesPerLoad: 1);

      await store.load(start: period);

      expect(store.clients, hasLength(50));
      expect(store.page, 1);
      expect(store.hasMore, isTrue);

      await store.loadMore();

      expect(store.clients, hasLength(60));
      expect(store.page, 2);
      expect(store.hasMore, isFalse);
    });

    test('erro da API vira errorMessage e não derruba a tela', () async {
      final api = FakeApi(failServices: true);
      final mensagens = <String>[];
      final store = buildStore(api, onError: mensagens.add);

      await store.load();

      expect(store.errorMessage, isNotNull);
      expect(store.loading, isFalse);
      expect(mensagens, isNotEmpty);
    });

    test('estatísticas com erro não impedem a lista', () async {
      final api = FakeApi(
        pages: [
          [atendimentoJson()],
        ],
        failStatistics: true,
      );
      final store = buildStore(api);

      await store.load();

      expect(store.statistics!.grandTotal, 0);
      expect(store.services, hasLength(1));
    });
  });

  group('AtendimentoStore agendamentos', () {
    test('"Não atendidos" liga o interruptor de cliente sem agenda', () async {
      final api = FakeApi(
        pages: [],
        clientsWithoutService: [
          atendimentoJson(
            id: 9,
            situation: 'NaoVisitadoSemAgenda',
            modality: null,
          ),
        ],
      );
      final store = buildStore(api);
      await store.load();

      expect(store.filter.showServices, isFalse);

      await store.load(
        start: period,
        agendamentosFilter: AgendamentosFiltro.naoAtendidos,
      );

      expect(store.agendamentos, AgendamentosFiltro.naoAtendidos);
      expect(store.filter.showServices, isTrue);
      expect(store.rows, hasLength(1));
      expect(store.hasMore, isFalse);
    });

    test('"Atendidos" não mexe no interruptor', () async {
      final store = buildStore(FakeApi(pages: []));
      await store.load();
      final before = store.filter.showServices;

      await store.load(agendamentosFilter: AgendamentosFiltro.atendidos);

      expect(store.filter.showServices, before);
      expect(store.agendamentos, AgendamentosFiltro.atendidos);
    });

    test('clientes sem atendimento (id 0) não são deduplicados', () async {
      final api = FakeApi(
        pages: [],
        clientsWithoutService: [
          atendimentoJson(id: 0, situation: 'NaoVisitadoSemAgenda'),
          atendimentoJson(
            id: 0,
            codePerson: '200',
            situation: 'NaoVisitadoSemAgenda',
          ),
        ],
      );
      final store = buildStore(api);

      await store.load(
        start: period,
        agendamentosFilter: AgendamentosFiltro.naoAtendidos,
      );

      expect(store.rows, hasLength(2));
    });
  });

  group('AtendimentoStore carregamento progressivo', () {
    test('plota os atendimentos antes de chegarem os clientes', () async {
      final gate = Completer<void>();
      final api = FakeApi(
        pages: [
          [atendimentoJson(id: 1)],
        ],
        clientsWithoutService: [
          atendimentoJson(
            id: 2,
            codePerson: '200',
            situation: 'VisitadoSemAgenda',
          ),
        ],
        clientsGate: gate,
      );
      final store = buildStore(api);

      final loading = store.load(start: period);

      // Dá tempo de a 1ª página chegar e ser plotada.
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(store.loading, isTrue);
      expect(store.rows, hasLength(1), reason: 'só os atendimentos já vieram');

      gate.complete();
      await loading;

      expect(store.rows, hasLength(2));
    });
  });

  group('AtendimentoStore filtros', () {
    test('setFilterSwitch recalcula lista, contadores e marcadores', () async {
      final api = FakeApi(
        pages: [
          [
            atendimentoJson(id: 1, situation: 'VisitadoComAgenda'),
            atendimentoJson(id: 2, situation: 'NaoVisitadoComAgenda'),
          ],
        ],
      );
      final store = buildStore(api);
      await store.load();
      final antes = store.markers.length;

      await store.setFilterSwitch(1, false);

      expect(store.filter.showCheckAndService, isFalse);
      expect(store.services.map((a) => a.id), isNot(contains(1)));
      expect(store.counters.scheduled, 1);
      expect(store.markers.length, lessThan(antes));
    });

    test('setShowClient é só uma preferência de exibição', () async {
      final store = buildStore(FakeApi(pages: []));
      await store.load();

      store.setShowClient(true);

      expect(store.showClient, isTrue);
    });

    test('selecionar preenche Street View e limpar zera', () async {
      final api = FakeApi(
        pages: [
          [atendimentoJson(id: 1, latClient: -8.05, lonClient: -34.9)],
        ],
      );
      final store = buildStore(api);
      await store.load();

      store.select(store.services.first);

      expect(store.selected, isNotNull);
      expect(store.showCard, isTrue);
      expect(store.streetViewCoord, isNotNull);

      store.clearSelection();

      expect(store.selected, isNull);
      expect(store.showCard, isFalse);
      expect(store.streetViewCoord, isNull);
    });
  });

  group('AtendimentoStore coordenada', () {
    test('alteração só é habilitada quando permitida', () async {
      final api = FakeApi(
        pages: [
          [atendimentoJson(id: 1)],
        ],
      );
      final store = buildStore(api, enableCoordinateEditing: false);
      await store.load();

      store.startCoordinateEdit(store.services.first);
      await store.setCoordinateEditing(true);

      expect(store.editing, isNull);
      expect(store.canEditCoordinate, isFalse);
      expect(await store.saveCoordinate(), isFalse);
    });

    test('arrastar move o pino e salvar grava no backend', () async {
      final api = FakeApi(
        pages: [
          [atendimentoJson(id: 1, codePerson: '100')],
        ],
      );
      final store = buildStore(api);
      await store.load();

      await store.setCoordinateEditing(true);
      store.startCoordinateEdit(store.services.first);
      store.moveEditingCoordinate(const LatLng(-9.0, -35.0));

      expect(store.editingCoord!.latitude, -9.0);
      expect(store.markers.single.position.latitude, -9.0);

      final saved = await store.saveCoordinate();

      expect(saved, isTrue);
      expect(api.updates.single['latitude'], '-9.0');
      expect(store.clients.single.latClient, -9.0);
      expect(store.editing, isNull);
    });

    test('falha ao salvar mantém o modo de edição', () async {
      final api = FakeApi(
        pages: [
          [atendimentoJson(id: 1)],
        ],
        failUpdate: true,
      );
      final store = buildStore(api);
      await store.load();

      await store.setCoordinateEditing(true);
      store.startCoordinateEdit(store.services.first);
      store.moveEditingCoordinate(const LatLng(-9.0, -35.0));

      final saved = await store.saveCoordinate();

      expect(saved, isFalse);
      expect(store.editing, isNotNull);
      expect(store.errorMessage, 'não salvou');
      expect(store.clients.single.latClient, isNot(-9.0));
    });

    test('cancelar restaura a coordenada original', () async {
      final api = FakeApi(
        pages: [
          [atendimentoJson(id: 1, latClient: -8.05, lonClient: -34.9)],
        ],
      );
      final store = buildStore(api);
      await store.load();

      await store.setCoordinateEditing(true);
      store.startCoordinateEdit(store.services.first);
      store.moveEditingCoordinate(const LatLng(-9.0, -35.0));
      await store.cancelCoordinateEdit();

      expect(store.editing, isNull);
      expect(store.editingCoord, isNull);
      expect(store.clients.single.latClient, -8.05);
      expect(store.markers.single.position.latitude, -8.05);
    });

    test('alterar endereço geocodifica e move o pino', () async {
      final api = FakeApi(
        pages: [
          [atendimentoJson(id: 1)],
        ],
      );
      final store = buildStore(api, geocoded: const GeoPoint(-7.5, -35.5));
      await store.load();

      await store.setCoordinateEditing(true);
      store.startCoordinateEdit(store.services.first);

      final ok = await store.changeAddress('Rua Nova, 100');

      expect(ok, isTrue);
      expect(store.editingCoord!.latitude, -7.5);
      expect(store.editingCoord!.longitude, -35.5);
    });

    test('endereço sem geocoder mantém o pino e avisa', () async {
      final api = FakeApi(
        pages: [
          [atendimentoJson(id: 1)],
        ],
      );
      final store = buildStore(api);
      await store.load();

      await store.setCoordinateEditing(true);
      store.startCoordinateEdit(store.services.first);
      final ok = await store.changeAddress('Rua Nova, 100');

      expect(ok, isFalse);
      expect(store.errorMessage, isNotNull);
    });

    test('com a edição desligada a gravação é bloqueada', () async {
      final api = FakeApi(
        pages: [
          [atendimentoJson(id: 1)],
        ],
      );
      final store = buildStore(api);
      await store.load();

      // No Web a edição já nasce ligada; aqui desligamos de propósito.
      await store.setCoordinateEditing(false);
      store.startCoordinateEdit(store.services.first);
      store.moveEditingCoordinate(const LatLng(-9.0, -35.0));

      final saved = await store.saveCoordinate();

      expect(saved, isFalse);
      expect(api.updates, isEmpty);
    });

    test('edição já nasce ligada quando permitida (Web)', () async {
      final store = buildStore(FakeApi(pages: []));

      expect(store.coordinateEditing, isTrue);
      expect(store.canEditCoordinate, isTrue);
    });
  });

  group('AtendimentoTitleFactory', () {
    test('numera o atendimento e omite "sem agenda e não atendido"', () {
      const factory = AtendimentoTitleFactory();

      final numerado = factory.titleFor(atendimento(), position: 3);
      final semAgenda = factory.titleFor(
        atendimento(situation: 'NaoVisitadoSemAgenda'),
        position: 2,
      );
      final cliente = factory.titleFor(
        atendimento(situation: 'NaoVisitadoSemAgenda'),
      );

      expect(numerado!.title, '3 - Cliente Um');
      expect(semAgenda!.title, 'Cliente Um');
      expect(cliente!.title, 'Cliente Um');
    });

    test('sem coordenada não cria título', () {
      const factory = AtendimentoTitleFactory();
      final semCoord = atendimento(latClient: null, lonClient: null);

      expect(factory.titleFor(semCoord), isNull);
    });
  });
}
