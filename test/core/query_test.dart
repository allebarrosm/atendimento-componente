import 'package:atendimento/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AtendimentoQuery', () {
    final start = DateTime(2026, 11, 1);
    final end = DateTime(2026, 11, 30, 23, 59, 59, 999);

    test(r'monta o $filter igual ao filterText dos apps', () {
      final query = AtendimentoQuery(
        startDate: start,
        endDate: end,
        supervisor: '3',
        agent: '7',
        client: '100',
        serviceType: 'Vendas',
        modality: 'Presencial',
      );

      expect(
        query.odataFilter,
        "DataHoraInicioAtendimento ge '2026-11-01 00:00:00.000' and "
        "DataHoraInicioAtendimento le '2026-11-30 23:59:59.999' and "
        "CodSupervisor eq '3' and CodPessoa eq '100' and "
        "CodRepres eq '7' and TipoAtendimento eq 0 and "
        "ModalidadeAtendimento eq '0'",
      );
    });

    test('não vaza o filtro quando só tem data', () {
      final query = AtendimentoQuery(startDate: start);

      expect(query.odataFilter, startsWith("DataHoraInicioAtendimento ge"));
      expect(query.odataFilter.contains(' and '), isFalse);
    });

    test('escapa apóstrofo em OData', () {
      final query = AtendimentoQuery(client: "D'AVILA");

      expect(query.odataFilter, "CodPessoa eq 'D''AVILA'");
    });

    test(r'serviceParams usa $filter/$orderby/skip/top', () {
      final params = AtendimentoQuery(
        startDate: start,
        serviceType: 'Não Vendas',
      ).serviceParams(page: 2, pageSize: 50);

      expect(params[r'$filter'], contains('TipoAtendimento eq 1'));
      expect(params[r'$orderby'], 'dataHoraInicioAtendimento asc');
      expect(params['skip'], '100');
      expect(params['top'], '50');
    });

    test('serviceType/modalidade por rótulo', () {
      final naoVenda = AtendimentoQuery(
        serviceType: 'Não Vendas',
        modality: 'Remoto',
      ).odataFilter;

      expect(naoVenda, contains('TipoAtendimento eq 1'));
      expect(naoVenda, contains("ModalidadeAtendimento eq '1'"));
    });

    test('clientParams e statisticsParams', () {
      final query = AtendimentoQuery(
        startDate: start,
        endDate: end,
        supervisor: '3',
        agent: '7',
        client: '100',
      );

      expect(query.clientParams()['codRepres'], '7');
      expect(query.clientParams()['dataInicial'], '2026-11-01 00:00:00.000');
      expect(query.statisticsParams()['dataInicio'], '2026-11-01 00:00:00');
      expect(query.statisticsParams()['dataFim'], '2026-11-30 23:59:59');
      expect(query.statisticsParams()['codRepresentante'], '7');
      expect(query.statisticsParams()['codSupervisor'], '3');
      expect(query.statisticsParams()['codCliente'], '100');
    });

    test('startOfDay e endOfDay normalizam o período', () {
      final inicio = AtendimentoQuery.startOfDay(DateTime(2026, 11, 25, 15, 20));
      final fim = AtendimentoQuery.endOfDay(DateTime(2026, 11, 25, 15, 20));

      expect(inicio, DateTime(2026, 11, 25));
      expect(fim, DateTime(2026, 11, 25, 23, 59, 59, 999));
    });
  });

  group('AtendimentoStatistics', () {
    test('lê o JSON do Estatisticas', () {
      final stats = AtendimentoStatistics.fromJson(<String, dynamic>{
        'TotalGeral': 1200,
        'TotalNaoVendas': 300,
        'TotalVendas': 900,
        'TotalPresencial': 800,
        'TotalRemoto': 400,
        'TotalOrcamentos': 150,
      });

      expect(stats.grandTotal, 1200);
      expect(stats.totalNoSales, 300);
      expect(stats.totalSales, 900);
      expect(stats.totalOnsite, 800);
      expect(stats.totalRemote, 400);
      expect(stats.totalBudget, 150);
    });

    test('campos ausentes viram zero', () {
      final stats = AtendimentoStatistics.fromJson(<String, dynamic>{});

      expect(stats.grandTotal, 0);
      expect(stats.totalSales, 0);
      expect(AtendimentoStatistics.empty.grandTotal, 0);
    });
  });

  group('Formatação', () {
    test('formatCount separa milhar com ponto', () {
      expect(formatCount(0), '0');
      expect(formatCount(999), '999');
      expect(formatCount(1000), '1.000');
      expect(formatCount(1234567), '1.234.567');
      expect(formatCount(-1234), '-1.234');
    });

    test('formatDuration omite a hora zerada', () {
      expect(formatDuration(45), '00:45');
      expect(formatDuration(90), '01:30');
      expect(formatDuration(3600), '01:00');
      expect(formatDuration(5400), '01:30');
    });

    test('formatDurationLong usa a mesma escala dos apps', () {
      expect(formatDurationLong(30), '30seg');
      expect(formatDurationLong(120), '2min');
      expect(formatDurationLong(7200), '2hora(s)');
      expect(formatDurationLong(86400), '24hora(s)');
      expect(formatDurationLong(90000), '25dia(s)');
    });

    test('formatDateTime no fuso local', () {
      expect(formatDateTime(DateTime(2026, 1, 2, 3, 4)), '02/01/2026 03:04');
    });

    test('formatDocument trata CNPJ, CPF e lixo', () {
      expect(formatDocument('12345678000199'), '12.345.678/0001-99');
      expect(formatDocument('12345678901'), '123.456.789-01');
      expect(formatDocument('123'), '123');
      expect(formatDocument(null), '');
    });
  });
}
