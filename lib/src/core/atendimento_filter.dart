import 'atendimento.dart';
import 'atendimento_situacao.dart';
import 'modalidade.dart';

/// Filtros de exibição do mapa/grade do atendimento.
///
/// São os mesmos 7 interruptores dos apps (situação + modalidade) mais o
/// "Nome Cliente". Antes, cada app repetia a regra em `setShowServices` e as
/// cópias divergiram: o Gestão exigia situação **e** modalidade, o BackOffice
/// aceitava só a modalidade. Aqui a regra é única: **as duas dimensões precisam
/// bater** ([matches]).
class AtendimentoFilter {
  const AtendimentoFilter({
    this.showServices = false,
    this.showCheckAndService = true,
    this.showCheckAndNotService = true,
    this.showNotCheckAndService = true,
    this.showInPerson = true,
    this.showRemote = true,
    this.showInPersonFarAway = true,
  });

  /// "Cliente sem agenda" — `NaoVisitadoSemAgenda`.
  final bool showServices;

  /// "Cliente agendado e atendido" — `VisitadoComAgenda`.
  final bool showCheckAndService;

  /// "Cliente agendado e não atendido" — `NaoVisitadoComAgenda`.
  final bool showCheckAndNotService;

  /// "Cliente sem agenda e atendido" — `VisitadoSemAgenda`.
  final bool showNotCheckAndService;

  /// "Presencial" (`ModalidadeAtendimento == "0"`).
  final bool showInPerson;

  /// "Remoto" (`ModalidadeAtendimento == "1"`).
  final bool showRemote;

  /// "Presencial fora do cliente" (`"0"` e `DistanciaAtendimento == Distante`).
  final bool showInPersonFarAway;

  AtendimentoFilter copyWith({
    bool? showServices,
    bool? showCheckAndService,
    bool? showCheckAndNotService,
    bool? showNotCheckAndService,
    bool? showInPerson,
    bool? showRemote,
    bool? showInPersonFarAway,
  }) {
    return AtendimentoFilter(
      showServices: showServices ?? this.showServices,
      showCheckAndService: showCheckAndService ?? this.showCheckAndService,
      showCheckAndNotService:
          showCheckAndNotService ?? this.showCheckAndNotService,
      showNotCheckAndService:
          showNotCheckAndService ?? this.showNotCheckAndService,
      showInPerson: showInPerson ?? this.showInPerson,
      showRemote: showRemote ?? this.showRemote,
      showInPersonFarAway: showInPersonFarAway ?? this.showInPersonFarAway,
    );
  }

  /// Mesmos identificadores usados pelos apps nos switches (1..7).
  AtendimentoFilter toggle(int switchValue, bool value) {
    switch (switchValue) {
      case 1:
        return copyWith(showCheckAndService: value);
      case 2:
        return copyWith(showCheckAndNotService: value);
      case 3:
        return copyWith(showServices: value);
      case 4:
        return copyWith(showNotCheckAndService: value);
      case 5:
        return copyWith(showInPerson: value);
      case 6:
        return copyWith(showRemote: value);
      case 7:
        return copyWith(showInPersonFarAway: value);
      default:
        return this;
    }
  }

  bool matchesSituation(Atendimento atendimento) {
    final situacao = atendimento.situacao;
    if (situacao == null) return false;
    return switch (situacao) {
      AtendimentoSituacao.visitadoComAgenda => showCheckAndService,
      AtendimentoSituacao.naoVisitadoComAgenda => showCheckAndNotService,
      AtendimentoSituacao.visitadoSemAgenda => showNotCheckAndService,
      AtendimentoSituacao.naoVisitadoSemAgenda => showServices,
    };
  }

  bool matchesModality(Atendimento atendimento) {
    final modalidade = atendimento.modalidade;
    if (modalidade == Modalidade.presencial) {
      // "Presencial fora do cliente" é uma categoria própria: desligá-la
      // esconde os pontos distantes sem esconder os presenciais normais.
      if (atendimento.isFarAway) return showInPersonFarAway;
      return showInPerson;
    }
    if (modalidade == Modalidade.remoto) return showRemote;
    // Sem modalidade informada só entra quando o filtro está aberto.
    return showInPerson && showRemote;
  }

  bool matches(Atendimento atendimento) =>
      matchesSituation(atendimento) && matchesModality(atendimento);

  /// Clientes que entram na lista/marcadores por situação (independente da
  /// modalidade) — mesma regra do `clientsWithServices` dos apps.
  bool matchesAsClient(Atendimento atendimento) =>
      matchesSituation(atendimento);

  bool get hasAnySituation =>
      showServices ||
      showCheckAndService ||
      showCheckAndNotService ||
      showNotCheckAndService;

  bool get hasAnyModality =>
      showInPerson || showRemote || showInPersonFarAway;
}
