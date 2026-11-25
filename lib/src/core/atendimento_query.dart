/// Monta os parâmetros da API de atendimento (`LstClienteAtendimento`).
///
/// O pacote devolve os nomes OData já prontos (`$filter`, `$orderby`, `skip`,
/// `top`). O adaptador de cada app é quem decide como enviar: o BackOffice
/// repassa direto; o Gestão remove o `$` porque o `ApiHelper` o adiciona em
/// `getOData`.
class AtendimentoQuery {
  const AtendimentoQuery({
    this.startDate,
    this.endDate,
    this.supervisor,
    this.agent,
    this.client,
    this.serviceType,
    this.modality,
  });

  /// Início do período (já normalizado para 00:00:00.000 local).
  final DateTime? startDate;

  /// Fim do período (já normalizado para 23:59:59.999 local).
  final DateTime? endDate;

  final String? supervisor;
  final String? agent;
  final String? client;

  /// Rótulo do filtro: `Vendas` / `Não Vendas`.
  final String? serviceType;

  /// Rótulo do filtro: `Presencial` / `Remoto`.
  final String? modality;

  static const String orderBy = 'dataHoraInicioAtendimento asc';

  static DateTime startOfDay(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  static DateTime endOfDay(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day, 23, 59, 59, 999);
  }

  /// `DataHoraInicioAtendimento ge '...' and ...` — igual ao `filterText` dos
  /// apps, mas com escape de apóstrofo (OData usa `''`).
  String get odataFilter {
    final filters = <String>[];

    if (startDate != null) {
      filters.add("DataHoraInicioAtendimento ge '${startDate.toString()}'");
    }
    if (endDate != null) {
      filters.add("DataHoraInicioAtendimento le '${endDate.toString()}'");
    }
    if (supervisor != null) {
      filters.add("CodSupervisor eq ${_quote(supervisor!)}");
    }
    if (client != null) {
      filters.add("CodPessoa eq ${_quote(client!)}");
    }
    if (agent != null) {
      filters.add("CodRepres eq ${_quote(agent!)}");
    }
    if (serviceType != null) {
      final type = serviceType == 'Vendas' ? 0 : 1;
      filters.add('TipoAtendimento eq $type');
    }
    if (modality != null) {
      final code = modality == 'Presencial' ? '0' : '1';
      filters.add("ModalidadeAtendimento eq '$code'");
    }

    return filters.join(' and ');
  }

  /// Parâmetros de uma página de atendimentos.
  Map<String, String> serviceParams({
    required int page,
    required int pageSize,
  }) {
    final filter = odataFilter;
    return <String, String>{
      if (filter.isNotEmpty) r'$filter': filter,
      r'$orderby': orderBy,
      'skip': '${page * pageSize}',
      'top': '$pageSize',
    };
  }

  /// Clientes sem atendimento no período (marcadores cinza).
  Map<String, String> clientParams() => <String, String>{
        if (agent != null) 'codRepres': agent!,
        if (startDate != null) 'dataInicial': startDate.toString(),
        if (endDate != null) 'dataFinal': endDate.toString(),
      };

  /// Parâmetros do painel de estatísticas.
  Map<String, String> statisticsParams() => <String, String>{
        'dataInicio': startDate == null ? '' : _sqlDate(startDate!),
        'dataFim': endDate == null ? '' : _sqlDate(endDate!),
        if (supervisor != null) 'codSupervisor': supervisor!,
        if (agent != null) 'codRepresentante': agent!,
        if (client != null) 'codCliente': client!,
      };

  AtendimentoQuery copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? supervisor,
    String? agent,
    String? client,
    String? serviceType,
    String? modality,
  }) {
    return AtendimentoQuery(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      supervisor: supervisor ?? this.supervisor,
      agent: agent ?? this.agent,
      client: client ?? this.client,
      serviceType: serviceType ?? this.serviceType,
      modality: modality ?? this.modality,
    );
  }

  static String _quote(String value) => "'${value.replaceAll("'", "''")}'";

  static String _sqlDate(DateTime value) {
    final local = value.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }
}
