import 'atendimento.dart';
import 'atendimento_filter.dart';
import 'atendimento_situacao.dart';

/// Números do painel (`LstAtendimento/Estatisticas`).
class AtendimentoStatistics {
  const AtendimentoStatistics({
    this.grandTotal = 0,
    this.totalNoSales = 0,
    this.totalSales = 0,
    this.totalOnsite = 0,
    this.totalRemote = 0,
    this.totalBudget = 0,
  });

  factory AtendimentoStatistics.fromJson(Map<String, dynamic> json) {
    return AtendimentoStatistics(
      grandTotal: _int(json['TotalGeral']),
      totalNoSales: _int(json['TotalNaoVendas']),
      totalSales: _int(json['TotalVendas']),
      totalOnsite: _int(json['TotalPresencial']),
      totalRemote: _int(json['TotalRemoto']),
      totalBudget: _int(json['TotalOrcamentos']),
    );
  }

  static const empty = AtendimentoStatistics();

  final int grandTotal;
  final int totalNoSales;
  final int totalSales;
  final int totalOnsite;
  final int totalRemote;
  final int totalBudget;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'TotalGeral': grandTotal,
        'TotalNaoVendas': totalNoSales,
        'TotalVendas': totalSales,
        'TotalPresencial': totalOnsite,
        'TotalRemoto': totalRemote,
        'TotalOrcamentos': totalBudget,
      };
}

/// Contadores de agenda calculados sobre a lista carregada.
///
/// Substitui o `setValues()` que cada app implementava dentro do store.
class AtendimentoCounters {
  const AtendimentoCounters({
    this.scheduled = 0,
    this.visited = 0,
    this.notVisited = 0,
  });

  static const empty = AtendimentoCounters();

  final int scheduled;
  final int visited;
  final int notVisited;

  static AtendimentoCounters from(
    Iterable<Atendimento> clients,
    AtendimentoFilter filter,
  ) {
    var scheduled = 0;
    var visited = 0;
    var notVisited = 0;

    for (final client in clients) {
      final situacao = client.situacao;
      if (situacao == null) continue;

      if (filter.showCheckAndService &&
          situacao == AtendimentoSituacao.visitadoComAgenda) {
        scheduled++;
        visited++;
      } else if (filter.showCheckAndNotService &&
          situacao == AtendimentoSituacao.naoVisitadoComAgenda) {
        scheduled++;
        notVisited++;
      } else if (filter.showNotCheckAndService &&
          situacao == AtendimentoSituacao.visitadoSemAgenda) {
        visited++;
      }
    }

    return AtendimentoCounters(
      scheduled: scheduled,
      visited: visited,
      notVisited: notVisited,
    );
  }
}

int _int(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim()) ?? 0;
}
