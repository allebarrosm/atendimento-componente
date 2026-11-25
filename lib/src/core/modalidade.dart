/// Modalidade do atendimento (`ModalidadeAtendimento` na API).
enum Modalidade {
  presencial(0, '0', 'Presencial'),
  remoto(1, '1', 'Remoto');

  const Modalidade(this.value, this.code, this.label);

  final int value;

  /// Valor serializado pela API (`"0"` / `"1"`).
  final String code;

  final String label;

  static Modalidade? fromCode(String? code) {
    if (code == null) return null;
    final normalized = code.trim();
    for (final modalidade in values) {
      if (modalidade.code == normalized) return modalidade;
    }
    return null;
  }

  static Modalidade? fromValue(int? value) {
    for (final modalidade in values) {
      if (modalidade.value == value) return modalidade;
    }
    return null;
  }
}
