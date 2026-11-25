/// Filtro "Agendamentos" da consulta de atendimentos.
///
/// Decide **quais endpoints** a consulta chama (a API 06.22.0419 já devolve,
/// em `GetClientesSemAtendimento`, exatamente os clientes que não foram
/// atendidos no período):
///
/// - [todos] (opção "Vazio"): chama `GetOData` + `GetClientesSemAtendimento`;
/// - [atendidos]: chama só `GetOData`;
/// - [naoAtendidos]: chama só `GetClientesSemAtendimento`.
enum AgendamentosFiltro {
  todos('Vazio'),
  atendidos('Atendidos'),
  naoAtendidos('Não Atendidos');

  const AgendamentosFiltro(this.label);

  /// Rótulo exibido no filtro.
  final String label;

  static AgendamentosFiltro fromLabel(String? label) {
    if (label == null) return AgendamentosFiltro.todos;
    final normalized = label.trim().toLowerCase();
    for (final value in values) {
      if (value.label.toLowerCase() == normalized) return value;
    }
    return AgendamentosFiltro.todos;
  }
}
