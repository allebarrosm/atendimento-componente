/// Tipo do atendimento (`TipoAtendimento` na API).
enum TipoAtendimento {
  venda(0, 'Venda/Orçamento'),
  naoVenda(1, 'Não Venda');

  const TipoAtendimento(this.value, this.label);

  final int value;
  final String label;

  static TipoAtendimento? fromValue(int? value) {
    for (final tipo in values) {
      if (tipo.value == value) return tipo;
    }
    return null;
  }
}
