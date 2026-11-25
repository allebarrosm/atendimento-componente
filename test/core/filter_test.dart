import 'package:atendimento/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  group('AtendimentoFilter', () {
    test('padrão dos apps: tudo ligado, menos "sem agenda"', () {
      const filter = AtendimentoFilter();

      expect(filter.showServices, isFalse);
      expect(filter.showCheckAndService, isTrue);
      expect(filter.showCheckAndNotService, isTrue);
      expect(filter.showNotCheckAndService, isTrue);
      expect(filter.showInPerson, isTrue);
      expect(filter.showRemote, isTrue);
      expect(filter.showInPersonFarAway, isTrue);
    });

    test('filtra por situação', () {
      const filter = AtendimentoFilter(showServices: true);

      expect(
        filter.matches(atendimento(situation: 'NaoVisitadoSemAgenda')),
        isTrue,
      );
      expect(
        filter.matches(atendimento(situation: 'VisitadoSemAgenda')),
        isTrue,
      );

      const semNada = AtendimentoFilter(
        showCheckAndService: false,
        showCheckAndNotService: false,
        showNotCheckAndService: false,
      );
      expect(semNada.matches(atendimento()), isFalse);
      expect(semNada.hasAnySituation, isFalse);
    });

    test('filtra por modalidade (presencial, remoto e fora do cliente)', () {
      const soPresencial = AtendimentoFilter(showRemote: false);

      expect(soPresencial.matches(atendimento()), isTrue);
      expect(
        soPresencial.matches(atendimento(modality: '1')),
        isFalse,
      );

      const semFora = AtendimentoFilter(showInPersonFarAway: false);
      expect(
        semFora.matches(atendimento(distance: 'Distante')),
        isFalse,
      );
    });

    test('exige situação E modalidade (correção da divergência)', () {
      // O BackOffice mostrava só pela modalidade; o Gestão exigia as duas.
      // A regra única é: as duas dimensões precisam bater.
      const filter = AtendimentoFilter(showCheckAndService: false);

      final atendimentoPresencial = atendimento();
      expect(
        filter.matchesModality(atendimentoPresencial),
        isTrue,
        reason: 'modalidade continua ligada',
      );
      expect(
        filter.matches(atendimentoPresencial),
        isFalse,
        reason: 'situação está desligada: não pode aparecer',
      );
    });

    test('sem modalidade só entra com os dois filtros abertos', () {
      const semModality = AtendimentoFilter(showRemote: false);
      final desconhecido = atendimento(modality: null);

      expect(semModality.matchesModality(desconhecido), isFalse);
      expect(const AtendimentoFilter().matchesModality(desconhecido), isTrue);
    });

    test('toggle usa os mesmos ids 1..7 dos apps', () {
      const base = AtendimentoFilter();

      expect(base.toggle(1, false).showCheckAndService, isFalse);
      expect(base.toggle(2, false).showCheckAndNotService, isFalse);
      expect(base.toggle(3, true).showServices, isTrue);
      expect(base.toggle(4, false).showNotCheckAndService, isFalse);
      expect(base.toggle(5, false).showInPerson, isFalse);
      expect(base.toggle(6, false).showRemote, isFalse);
      expect(base.toggle(7, false).showInPersonFarAway, isFalse);
      expect(identical(base.toggle(99, false), base), isTrue);
    });

    test('hasAnyModality reflete os três switches', () {
      expect(const AtendimentoFilter().hasAnyModality, isTrue);
      expect(
        const AtendimentoFilter(
          showInPerson: false,
          showRemote: false,
          showInPersonFarAway: false,
        ).hasAnyModality,
        isFalse,
      );
    });
  });

  group('AtendimentoCounters', () {
    test('conta agenda, atendidos e não atendidos como o setValues', () {
      final clients = <Atendimento>[
        atendimento(id: 1, situation: 'VisitadoComAgenda'),
        atendimento(id: 2, situation: 'VisitadoComAgenda'),
        atendimento(id: 3, situation: 'NaoVisitadoComAgenda'),
        atendimento(id: 4, situation: 'VisitadoSemAgenda'),
        atendimento(id: 5, situation: 'NaoVisitadoSemAgenda'),
      ];

      final counters = AtendimentoCounters.from(
        clients,
        const AtendimentoFilter(),
      );

      expect(counters.scheduled, 3);
      expect(counters.visited, 3);
      expect(counters.notVisited, 1);
    });

    test('respeita os switches desligados', () {
      final clients = <Atendimento>[
        atendimento(id: 1, situation: 'VisitadoComAgenda'),
        atendimento(id: 2, situation: 'VisitadoSemAgenda'),
      ];

      final counters = AtendimentoCounters.from(
        clients,
        const AtendimentoFilter(showNotCheckAndService: false),
      );

      expect(counters.scheduled, 1);
      expect(counters.visited, 1);
    });
  });

  group('AtendimentoSituacao', () {
    test('fromCode ignora caixa e espaços', () {
      expect(
        AtendimentoSituacao.fromCode(' visitadocomagenda '),
        AtendimentoSituacao.visitadoComAgenda,
      );
      expect(AtendimentoSituacao.fromCode('Outro'), isNull);
      expect(AtendimentoSituacao.fromCode(null), isNull);
    });

    test('hasAgenda e isVisited', () {
      expect(AtendimentoSituacao.visitadoComAgenda.hasAgenda, isTrue);
      expect(AtendimentoSituacao.naoVisitadoSemAgenda.hasAgenda, isFalse);
      expect(AtendimentoSituacao.naoVisitadoComAgenda.isVisited, isFalse);
      expect(AtendimentoSituacao.visitadoSemAgenda.isVisited, isTrue);
    });
  });
}
