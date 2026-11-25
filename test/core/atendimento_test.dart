import 'package:atendimento/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  group('Atendimento.fromJson', () {
    test('lê as 29 chaves do contrato OData', () {
      final json = atendimentoJson(
        latClient: -8.05,
        lonClient: -34.9,
        latService: -8.051,
        lonService: -34.901,
      );
      final value = Atendimento.fromJson(json);

      expect(value.id, 1);
      expect(value.agentCode, '7');
      expect(value.codePerson, '100');
      expect(value.corporateName, 'CLIENTE UM LTDA');
      expect(value.fantasy, 'Cliente Um');
      expect(value.address, 'Rua Um, 10');
      expect(value.duration, 120);
      expect(value.type, 0);
      expect(value.situationService, 'VisitadoComAgenda');
      expect(value.descriptionSituation, 'Atendido');
      expect(value.startDate, DateTime(2026, 11, 20, 9, 30));
      expect(value.modalidade, Modalidade.presencial);
      expect(value.tipo, TipoAtendimento.venda);
      expect(value.situacao, AtendimentoSituacao.visitadoComAgenda);
    });

    test('normaliza coordenada sem separador decimal', () {
      final value = Atendimento.fromJson(
        atendimentoJson(latClient: null, lonClient: null),
      );
      // Simula o cadastro quebrado ("-235489337.0").
      final quebrado = Atendimento.fromJson(
        atendimentoJson(
          latClient: null,
          lonClient: null,
        )..['LatitudeCliente'] = '-235489337.0'
          ..['LongitudeCliente'] = '-347453333.0',
      );

      expect(value.hasValidClientCoord, isFalse);
      expect(quebrado.latClient, closeTo(-23.5489337, 0.0000001));
      expect(quebrado.lonClient, closeTo(-34.7453333, 0.0000001));
      expect(quebrado.hasValidClientCoord, isTrue);
    });

    test('aceita vírgula como separador decimal', () {
      final value = Atendimento.fromJson(
        atendimentoJson(latClient: null, lonClient: null)
          ..['LatitudeCliente'] = '-8,05'
          ..['LongitudeCliente'] = '-34,9',
      );

      expect(value.latClient, -8.05);
      expect(value.lonClient, -34.9);
    });

    test('descarta coordenada (0,0) e valores não numéricos', () {
      final zero = Atendimento.fromJson(
        atendimentoJson(latClient: 0, lonClient: 0),
      );
      final texto = Atendimento.fromJson(
        atendimentoJson(latClient: null, lonClient: null)
          ..['LatitudeCliente'] = 'sem coordenada',
      );

      expect(zero.hasValidClientCoord, isFalse);
      expect(texto.hasValidClientCoord, isFalse);
    });

    test('não confunde coordenada do cliente com a do atendimento', () {
      final soCliente = atendimento();
      final comAtendimento = Atendimento.fromJson(
        atendimentoJson(latService: -8.06, lonService: -34.91),
      );

      expect(soCliente.hasValidClientCoord, isTrue);
      expect(soCliente.hasValidServiceCoord, isFalse);
      expect(soCliente.locationForMap, isNotNull);
      expect(soCliente.locationForMap!.latitude, -8.05);
      expect(comAtendimento.locationForMap!.latitude, -8.06);
    });

    test('Campos vazios viram null (e não string vazia)', () {
      final value = Atendimento.fromJson(
        atendimentoJson()
          ..['NomeCliente'] = '   '
          ..['ObservacaoAtendimento'] = '',
      );

      expect(value.clientName, isNull);
      expect(value.observation, isNull);
    });
  });

  group('Atendimento', () {
    test('displayName prefere fantasia, depois nome, depois razão social', () {
      final comFantasia = atendimento();
      final semFantasia = Atendimento.fromJson(
        atendimentoJson(fantasy: null, clientName: null),
      );
      final comNome = Atendimento.fromJson(
        atendimentoJson(fantasy: null, clientName: 'Fulano'),
      );

      expect(comFantasia.displayName, 'Cliente Um');
      expect(semFantasia.displayName, 'CLIENTE UM LTDA');
      expect(comNome.displayName, 'Fulano');
    });

    test('isFarAway só quando a distância é "Distante"', () {
      expect(atendimento().isFarAway, isFalse);
      expect(atendimento(distance: 'Distante').isFarAway, isTrue);
    });

    test('view rows compacto junta data, duração e modalidade', () {
      final rows = atendimento().toViewRows(compact: true);

      expect(rows['Data'], contains('20/11/2026 09:30'));
      expect(rows['Data'], contains('Presencial'));
      expect(rows.containsKey('Latitude cliente'), isFalse);
      expect(rows['CNPJ'], '12.345.678/0001-99');
    });

    test('view rows detalhado separa modalidade e coordenadas', () {
      final rows = Atendimento.fromJson(
        atendimentoJson(latService: -8.06, lonService: -34.91),
      ).toViewRows();

      expect(rows['Modalidade'], 'Presencial');
      expect(rows['Duração'], '2min');
      expect(rows['Latitude atendimento'], '-8.06');
      expect(rows['Data'], '20/11/2026 09:30');
    });

    test('copyWith troca a coordenada do cliente', () {
      final atualizado = atendimento().copyWith(
        latClient: -9.0,
        lonClient: -35.0,
      );

      expect(atualizado.latClient, -9.0);
      expect(atualizado.lonClient, -35.0);
      expect(atualizado.id, 1);
    });

    test('toJson devolve o mesmo contrato de entrada', () {
      final original = atendimentoJson(latService: -8.06, lonService: -34.91);
      final ida = Atendimento.fromJson(original).toJson();

      expect(ida['Id'], original['Id']);
      expect(ida['CodPessoa'], original['CodPessoa']);
      expect(ida['SituacaoAtendimento'], original['SituacaoAtendimento']);
      expect(ida['RazaoSocial'], original['RazaoSocial']);
    });
  });
}
