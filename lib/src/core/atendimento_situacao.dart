/// Situação do atendimento em relação à agenda do cliente.
///
/// Os apps tratavam isso como string mágica (`"VisitadoComAgenda"` etc.) em 30+
/// pontos. O código (`code`) é o valor que vem da API; o rótulo é o texto
/// exibido na interface.
enum AtendimentoSituacao {
  visitadoComAgenda('VisitadoComAgenda', 'Agendado e atendido'),
  naoVisitadoComAgenda('NaoVisitadoComAgenda', 'Agendado e não atendido'),
  visitadoSemAgenda('VisitadoSemAgenda', 'Sem agenda e atendido'),
  naoVisitadoSemAgenda('NaoVisitadoSemAgenda', 'Sem agenda e não atendido');

  const AtendimentoSituacao(this.code, this.label);

  /// Valor devolvido pela API em `SituacaoAtendimento`.
  final String code;

  /// Texto exibido nos filtros e nos cards.
  final String label;

  static AtendimentoSituacao? fromCode(String? code) {
    if (code == null) return null;
    final normalized = code.trim();
    for (final situacao in values) {
      if (situacao.code.toLowerCase() == normalized.toLowerCase()) {
        return situacao;
      }
    }
    return null;
  }

  /// Atendimentos com agenda (aparecem na contagem de agendados).
  bool get hasAgenda =>
      this == visitadoComAgenda || this == naoVisitadoComAgenda;

  /// Atendimentos efetivamente visitados.
  bool get isVisited =>
      this == visitadoComAgenda || this == visitadoSemAgenda;
}
