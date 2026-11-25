import 'package:atendimento/core.dart';

/// JSON no formato devolvido por `LstClienteAtendimento/GetOData`.
Map<String, dynamic> atendimentoJson({
  int id = 1,
  String codePerson = '100',
  String? situation = 'VisitadoComAgenda',
  String? modality = '0',
  String? distance,
  double? latClient = -8.05,
  double? lonClient = -34.9,
  double? latService,
  double? lonService,
  String? corporateName = 'CLIENTE UM LTDA',
  String? fantasy = 'Cliente Um',
  String? clientName,
  String address = 'Rua Um, 10',
  String? agentName = 'Representante',
  int duration = 120,
  DateTime? start,
  int type = 0,
  String? cnpj = '12345678000199',
}) {
  return <String, dynamic>{
    'Id': id,
    'CodRepres': '7',
    'ModalidadeAtendimento': modality,
    'TipoAtendimento': type,
    'CodPessoa': codePerson,
    'PedidoRCAId': null,
    'CodMotivoNaoVenda': null,
    'ObservacaoAtendimento': null,
    'DataHoraInicioAtendimento':
        (start ?? DateTime(2026, 11, 20, 9, 30)).toIso8601String(),
    'DuracaoAtendimento': duration,
    'NomeCliente': clientName,
    'NomeRepresentante': agentName,
    'NomeSupervisor': 'Supervisor',
    'CodSupervisor': '3',
    'TipoDescricao': 'Venda',
    'EnderecoFaturamentoCliente': null,
    'RazaoSocial': corporateName,
    'EnderecoCliente': address,
    'LatitudeCliente': latClient?.toString(),
    'LongitudeCliente': lonClient?.toString(),
    'LatitudeAtendimento': latService?.toString(),
    'LongitudeAtendimento': lonService?.toString(),
    'DescricaoAtendimento': 'Pedido 123',
    'DistanciaAtendimento': distance,
    'SituacaoAtendimento': situation,
    'Cnpj': cnpj,
    'IdPedido': null,
    'Fantasia': fantasy,
    'DescricaoSituacaoAtendimento': 'Atendido',
  };
}

Atendimento atendimento({
  int id = 1,
  String codePerson = '100',
  String? situation = 'VisitadoComAgenda',
  String? modality = '0',
  String? distance,
  double? latClient = -8.05,
  double? lonClient = -34.9,
  double? latService,
  double? lonService,
  DateTime? start,
}) {
  return Atendimento.fromJson(
    atendimentoJson(
      id: id,
      codePerson: codePerson,
      situation: situation,
      modality: modality,
      distance: distance,
      latClient: latClient,
      lonClient: lonClient,
      latService: latService,
      lonService: lonService,
      start: start,
    ),
  );
}
