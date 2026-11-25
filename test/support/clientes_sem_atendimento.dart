/// Recorte fiel do retorno de
/// `LstClienteAtendimento/GetClientesSemAtendimento` usado para investigar
/// "todos os clientes estão sendo plotados?".
///
/// São 22 clientes reais repetidos em 25 dias (01/11 a 25/11/2026) = 550
/// linhas. Todas com `SituacaoAtendimento = NaoVisitadoSemAgenda`, sem
/// modalidade, sem coordenada de atendimento e `DistanciaAtendimento =
/// Distante`, como a API devolve. As coordenadas do cliente vêm com espaços no
/// fim — de propósito: é o formato que quebrava o `double.tryParse`.
library;

/// Uma linha de cliente sem atendimento (dados reais da API).
class ClienteSemAtendimento {
  const ClienteSemAtendimento({
    required this.codePerson,
    required this.id,
    required this.cnpj,
    required this.fantasy,
    required this.corporateName,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String codePerson;
  final int id;
  final String cnpj;
  final String fantasy;
  final String corporateName;
  final String address;

  /// `LatitudeCliente` cru, com os espaços de preenchimento da API.
  final String latitude;

  /// `LongitudeCliente` cru, com os espaços de preenchimento da API.
  final String longitude;

  Map<String, dynamic> toJson(DateTime dia) => <String, dynamic>{
        'CodPessoa': codePerson,
        'CodRepres': '0000000849',
        'CodSupervisor': '0000000001',
        'RazaoSocial': corporateName,
        'EnderecoCliente': address,
        'LatitudeCliente': latitude,
        'LongitudeCliente': longitude,
        'LatitudeAtendimento': null,
        'LongitudeAtendimento': null,
        'ModalidadeAtendimento': null,
        'TipoAtendimento': 0,
        'DataHoraInicioAtendimento': _isoDay(dia),
        'DuracaoAtendimento': 0,
        'NomeRepresentante': 'AILTON CARLOS MOREIRA JUNIOR (J)',
        'NomeSupervisor': 'SOUZA COMERCIO DE PRODUTOS LTDA - ME',
        'CodMotivoNaoVenda': null,
        'ObservacaoAtendimento': null,
        'DescricaoAtendimento': 'CLIENTE NAO ATENDIDO',
        'SituacaoAtendimento': 'NaoVisitadoSemAgenda',
        'DescricaoSituacaoAtendimento': 'Nao Atendido Sem Agenda',
        'IdPedido': 0,
        'Id': id,
        'Cnpj': cnpj,
        'Fantasia': fantasy,
        'DistanciaAtendimento': 'Distante',
      };
}

/// Os 22 clientes distintos que a API devolveu (um por `CodPessoa`).
const clientesSemAtendimento = <ClienteSemAtendimento>[
  ClienteSemAtendimento(
    codePerson: '0000012565',
    id: 84931351405000106,
    cnpj: '31351405000106',
    fantasy: 'CLIENTE PESSOA JURIDICA SOUZA',
    corporateName: 'CLIENTE PESSOA JURIDICA SOUZA',
    address: 'RUA DOUTOR PASCHOAL DE MUZZIO, 174 JUNDIAI, SP, 13207-080',
    latitude: '-23.1958847         ',
    longitude: '-46.8854853         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000020403',
    id: 84909454774000590,
    cnpj: '09454774000590',
    fantasy: 'MARCIA MITSUE HIRATA CONVENIENCIA',
    corporateName: 'MARCIA MITSUE HIRATA CONVENIENCIA',
    address: 'AV PRESIDENTE GENERAL DUTRA ARUA, 20 MOGI DAS CRUZES, SP, 08771-200',
    latitude: '-3.7376547          ',
    longitude: '-38.5624667         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000022327',
    id: 84938828823000182,
    cnpj: '38828823000182',
    fantasy: 'URCA COMERCIO DE BEBIDAS',
    corporateName: 'URCA COMERCIO DE BEBIDAS E ALIMENTOS LTDA',
    address: 'AV CAMPANELLA, 339 SAO PAULO, SP, 08220-830',
    latitude: '-23.53662           ',
    longitude: '-46.471297          ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000022385',
    id: 84938828823000263,
    cnpj: '38828823000263',
    fantasy: 'URCA COMERCIO DE BEBIDAS E ALIMENTOS LTDA',
    corporateName: 'URCA COMERCIO DE BEBIDAS E ALIMENTOS LTDA',
    address: 'AV  BRIGADEIRO FARIA LIMA, 3567 GUARULHOS, SP, 07130-000',
    latitude: '-23.4242345         ',
    longitude: '-46.5240439         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000035596',
    id: 84934908029000198,
    cnpj: '34908029000198',
    fantasy: 'KEVIN BEBIDAS KEVIN BEBIDAS',
    corporateName: 'KEVIN BEBIDAS KEVIN BEBIDAS',
    address: 'Rua Angélica Catalani, 45 SAO PAULO, SP, 04439-020',
    latitude: '-23.6803149         ',
    longitude: '-46.6684144         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000048075',
    id: 84938828823000344,
    cnpj: '38828823000344',
    fantasy: 'URCA COMERCIO DE BEBIDAS E ALIMENTOS LTDA',
    corporateName: 'URCA COMERCIO DE BEBIDAS E ALIMENTOS LTDA',
    address: 'R PEDRO DE TOLEDO, 170 GUARULHOS, SP, 07140-000',
    latitude: '-23.4362152         ',
    longitude: '-46.5044209         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000048377',
    id: 84955466504000274,
    cnpj: '55466504000274',
    fantasy: 'DJD COMERCIAL LTDA  ALL SHOPPING DAS BEBIDAS',
    corporateName: 'D.J.D. COMERCIO LTDA',
    address: 'AVENIDA JURUA, 387 LOJA 2, BARUERI, SP, 06455-010',
    latitude: '-23.5006726         ',
    longitude: '-46.8551177         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000049424',
    id: 84948426298000122,
    cnpj: '48426298000122',
    fantasy: 'J.G. COMERCIO',
    corporateName: 'J.G.N. COMERCIO DE BEBIDAS E ALIMENTOS LTDA',
    address: 'ESTRADA DOM JOAO NERY, 1568 ANEXO A, SAO PAULO, SP, 08110-000',
    latitude: '-23.1856528         ',
    longitude: '-46.8892222         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000049428',
    id: 84943601197000127,
    cnpj: '43601197000127',
    fantasy: 'FENIX DISTRIBUIDORA DE ALIMENTOS E BEBIDAS',
    corporateName: 'DISTRIBUIDORA FENIX DE ALIMENTOS E BEBIDAS LTDA',
    address: 'AVENIDA CID NELSON JORDANO, 178 TABOAO DA SERRA, SP, 06787-360',
    latitude: '-23.623126          ',
    longitude: '-46.7958793         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000049645',
    id: 84931633477000138,
    cnpj: '31633477000138',
    fantasy: 'DRINK NUSAKINHO',
    corporateName: 'DRINK NUSAKINHO LTDA',
    address: 'AV FRANCISCO FERREIRA LOPES, 4344 SALA 04, MOGI DAS CRUZES, SP, 08745-000',
    latitude: '-23.5419875         ',
    longitude: '-46.2400055         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000050150',
    id: 84961144771000147,
    cnpj: '61144771000147',
    fantasy: 'ADEGA E TABACARA VIKINGS',
    corporateName: '61.144.771 TARCIO FERREIRA DOS SANTOS',
    address: 'ESTRADA DO KOYAMA, 1657 SUZANO, SP, 08633-435',
    latitude: '-23.1856528         ',
    longitude: '-46.8892222         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000050235',
    id: 84938828823000425,
    cnpj: '38828823000425',
    fantasy: 'URCA',
    corporateName: 'URCA COMERCIO DE BEBIDAS E ALIMENTOS LTDA',
    address: 'RUA GAL JERONIMO FURTADO, 572 SAO PAULO, SP, 02237-000',
    latitude: '-23.4655899         ',
    longitude: '-46.5698762         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000050756',
    id: 84909454774000248,
    cnpj: '09454774000248',
    fantasy: 'MARCIA MITSUE HIRATA CONVENIENCIA ME',
    corporateName: 'MARCIA MITSUE HIRATA CONVENIENCIA',
    address: 'AV JAPAO, 2299 A, MOGI DAS CRUZES, SP, 08738-010',
    latitude: '-23.5489123         ',
    longitude: '-46.2039229         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000050999',
    id: 84953914241000102,
    cnpj: '53914241000102',
    fantasy: 'MOSCHION E GUERRA',
    corporateName: 'MOSCHION E GUERRA COMERCIO DE BEBIDAS LTDA',
    address: 'RUA ABILIO PEDRO RAMOS, 544 SAO PAULO, SP, 02279-000',
    latitude: '-23.4611174         ',
    longitude: '-46.5757915         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000051197',
    id: 84906018087000100,
    cnpj: '06018087000100',
    fantasy: 'PIPELINE INFORMATICA',
    corporateName: 'PIPELINE SERVICOS ADMINISTRATIVOS LTDA',
    address: 'R DOS JABORANDIS, 26 QUADRA 17 LOTE 13, MOGI DAS CRUZES, SP, 08771-348',
    latitude: '-23.4627975         ',
    longitude: '-46.2672885         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000053984',
    id: 84903096968000151,
    cnpj: '03096968000151',
    fantasy: 'AUTO POSTO JOAO XXIII - II LTDA',
    corporateName: 'AUTO POSTO JOAO XXIII-II LTDA',
    address: 'AV JOSE MELONI, 1280 A, MOGI DAS CRUZES, SP, 08773-120',
    latitude: '-23.5091943         ',
    longitude: '-46.1953665         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000053985',
    id: 84915218218000194,
    cnpj: '15218218000194',
    fantasy: 'AUTO POSTO TABOAO LTDA',
    corporateName: 'AUTO POSTO TABOAO LTDA',
    address: 'ESTR DO TABOAO DO PARATEI, 100 MOGI DAS CRUZES, SP, 08772-010',
    latitude: '-23.4332571         ',
    longitude: '-46.2666343         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000053986',
    id: 84944288298000152,
    cnpj: '44288298000152',
    fantasy: 'AUTO POSTO EXPEDICIONARIOS LTDA',
    corporateName: 'AUTO POSTO EXPEDICIONARIOS LT',
    address: 'AV FRANCISCO R FILHO, 889 MOGI DAS CRUZES, SP, 08840-000',
    latitude: '-23.5159499         ',
    longitude: '-46.1887541         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000053987',
    id: 84962071196000162,
    cnpj: '62071196000162',
    fantasy: 'AUTO POSTO MOGI DAS CRUZES LTDA',
    corporateName: 'AUTO POSTO MOGI DAS CRUZES LT',
    address: 'AV LOTHAR WALDEMAR HOENNE, 1200 MOGI DAS CRUZES, SP, 08775-000',
    latitude: '-23.5082834         ',
    longitude: '-46.1979445         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000053988',
    id: 84959507558000100,
    cnpj: '59507558000100',
    fantasy: 'AUTO POSTO VILA OLIVEIRA LTDA',
    corporateName: 'AUTO POSTO VILA OLIVEIRA LTDA',
    address: 'R CEL CARDOSO SIQUEIRA, 980 MOGI DAS CRUZES, SP, 08795-020',
    latitude: '-23.5264563         ',
    longitude: '-46.1831844         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000053989',
    id: 84905773587000195,
    cnpj: '05773587000195',
    fantasy: 'AUTO POSTO D. B. MOGI LTDA',
    corporateName: 'AUTO POSTO D. B. MOGI LTDA.',
    address: 'AV JAPAO, 2299 MOGI DAS CRUZES, SP, 08730-330',
    latitude: '-23.5488905         ',
    longitude: '-46.2039682         ',
  ),
  ClienteSemAtendimento(
    codePerson: '0000054478',
    id: 84926733825000109,
    cnpj: '26733825000109',
    fantasy: 'PAULO CESAR FRANCISCO DA SILVA 36314656885',
    corporateName: 'PAULO CESAR FRANCISCO DA SILVA 36314656885',
    address: 'R BEIJA FLOR, 30 POA, SP, 08568-260',
    latitude: '-23.5539466         ',
    longitude: '-46.3444208         ',
  ),
];

/// As 550 linhas da API: os 22 clientes repetidos em [dias] dias.
List<Map<String, dynamic>> clientesSemAtendimentoJson({
  DateTime? inicio,
  int dias = 25,
}) {
  final primeiroDia = inicio ?? DateTime(2026, 11, 1);
  return <Map<String, dynamic>>[
    for (var d = 0; d < dias; d++)
      for (final cliente in clientesSemAtendimento)
        cliente.toJson(DateTime(primeiroDia.year, primeiroDia.month,
            primeiroDia.day + d)),
  ];
}

String _isoDay(DateTime dia) => '${dia.year}-'
    '${dia.month.toString().padLeft(2, '0')}-'
    '${dia.day.toString().padLeft(2, '0')}T00:00:00';
