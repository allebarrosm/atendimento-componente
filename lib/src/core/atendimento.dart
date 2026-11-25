import 'package:roteiro/core.dart' show GeoPoint;

import 'atendimento_format.dart';
import 'atendimento_situacao.dart';
import 'modalidade.dart';
import 'tipo_atendimento.dart';

/// Modelo canônico de um atendimento, compartilhado por Gestão e BackOffice.
///
/// O JSON é o mesmo devolvido por `LstClienteAtendimento/GetOData`. Os nomes das
/// chaves ficam concentrados aqui: os apps mapeiam uma vez e o resto do pacote
/// trabalha só com esta classe.
class Atendimento {
  const Atendimento({
    required this.id,
    required this.codePerson,
    required this.startDate,
    required this.corporateName,
    required this.address,
    required this.descriptionSituation,
    this.agentCode,
    this.modality,
    this.type,
    this.orderedRcaId,
    this.reasonCode,
    this.observation,
    this.duration = 0,
    this.clientName,
    this.agentName,
    this.supervisorName,
    this.supervisorCode,
    this.descriptionType,
    this.customerBillingAddress,
    this.latClient,
    this.lonClient,
    this.latService,
    this.lonService,
    this.descriptionService,
    this.distance,
    this.situationService,
    this.cnpj,
    this.orderedId,
    this.fantasy,
  });

  factory Atendimento.fromJson(Map<String, dynamic> json) {
    final client = GeoPoint.fromNullable(
      _double(json['LatitudeCliente']),
      _double(json['LongitudeCliente']),
    );
    final service = GeoPoint.fromNullable(
      _double(json['LatitudeAtendimento']),
      _double(json['LongitudeAtendimento']),
    );

    return Atendimento(
      id: _int(json['Id']) ?? 0,
      agentCode: _text(json['CodRepres']),
      modality: _text(json['ModalidadeAtendimento']),
      type: _int(json['TipoAtendimento']),
      codePerson: _text(json['CodPessoa']) ?? '',
      orderedRcaId: _text(json['PedidoRCAId']),
      reasonCode: _text(json['CodMotivoNaoVenda']),
      observation: _text(json['ObservacaoAtendimento']),
      startDate: _date(json['DataHoraInicioAtendimento']),
      duration: _int(json['DuracaoAtendimento']) ?? 0,
      clientName: _text(json['NomeCliente']),
      agentName: _text(json['NomeRepresentante']),
      supervisorName: _text(json['NomeSupervisor']),
      supervisorCode: _text(json['CodSupervisor']),
      descriptionType: _text(json['TipoDescricao']),
      customerBillingAddress: _text(json['EnderecoFaturamentoCliente']),
      corporateName: _text(json['RazaoSocial']) ?? '',
      address: _text(json['EnderecoCliente']) ?? '',
      latClient: client?.latitude,
      lonClient: client?.longitude,
      latService: service?.latitude,
      lonService: service?.longitude,
      descriptionService: _text(json['DescricaoAtendimento']),
      distance: _text(json['DistanciaAtendimento']),
      situationService: _text(json['SituacaoAtendimento']),
      cnpj: _text(json['Cnpj']),
      orderedId: _int(json['IdPedido']),
      fantasy: _text(json['Fantasia']),
      descriptionSituation: _text(json['DescricaoSituacaoAtendimento']) ?? '',
    );
  }

  final int id;

  /// `CodRepres`.
  final String? agentCode;

  /// `ModalidadeAtendimento` (`"0"` presencial, `"1"` remoto).
  final String? modality;

  /// `TipoAtendimento` (0 venda/orçamento, 1 não venda).
  final int? type;

  /// `CodPessoa` do cliente.
  final String codePerson;

  final String? orderedRcaId;
  final String? reasonCode;
  final String? observation;

  /// `DataHoraInicioAtendimento` (já no fuso local da API).
  final DateTime startDate;

  /// `DuracaoAtendimento` em segundos.
  final int duration;

  final String? clientName;
  final String? agentName;
  final String? supervisorName;
  final String? supervisorCode;
  final String? descriptionType;
  final String? customerBillingAddress;
  final String corporateName;

  /// `EnderecoCliente`.
  final String address;

  final double? latClient;
  final double? lonClient;
  final double? latService;
  final double? lonService;

  final String? descriptionService;

  /// `DistanciaAtendimento` (`"Distante"` quando fora do raio permitido).
  final String? distance;

  /// `SituacaoAtendimento` — ver [situacao].
  final String? situationService;

  final String? cnpj;
  final int? orderedId;
  final String? fantasy;

  /// `DescricaoSituacaoAtendimento` (texto pronto da API).
  final String descriptionSituation;

  Modalidade? get modalidade => Modalidade.fromCode(modality);

  TipoAtendimento? get tipo => TipoAtendimento.fromValue(type);

  AtendimentoSituacao? get situacao =>
      AtendimentoSituacao.fromCode(situationService);

  /// Cliente fora do raio do endereço (linha vermelha no mapa).
  bool get isFarAway => distance == 'Distante';

  /// Nome mais amigável: fantasia → nome do cliente → razão social.
  String get displayName => fantasy?.trim().isNotEmpty == true
      ? fantasy!.trim()
      : (clientName?.trim().isNotEmpty == true
          ? clientName!.trim()
          : corporateName);

  bool get hasValidClientCoord => latClient != null && lonClient != null;

  bool get hasValidServiceCoord => latService != null && lonService != null;

  GeoPoint? get clientLocation => hasValidClientCoord
      ? GeoPoint(latClient!, lonClient!)
      : null;

  GeoPoint? get serviceLocation => hasValidServiceCoord
      ? GeoPoint(latService!, lonService!)
      : null;

  /// Coordenada usada no mapa: a do atendimento e, na falta dela, a do cliente.
  GeoPoint? get locationForMap => serviceLocation ?? clientLocation;

  bool get hasMapCoordinate => locationForMap != null;

  String get durationText => formatDuration(duration);

  String get startDateText => formatDateTime(startDate);

  Atendimento copyWith({
    int? id,
    String? agentCode,
    String? modality,
    int? type,
    String? codePerson,
    String? orderedRcaId,
    String? reasonCode,
    String? observation,
    DateTime? startDate,
    int? duration,
    String? clientName,
    String? agentName,
    String? supervisorName,
    String? supervisorCode,
    String? descriptionType,
    String? customerBillingAddress,
    String? corporateName,
    String? address,
    double? latClient,
    double? lonClient,
    double? latService,
    double? lonService,
    String? descriptionService,
    String? distance,
    String? situationService,
    String? cnpj,
    int? orderedId,
    String? fantasy,
    String? descriptionSituation,
  }) {
    return Atendimento(
      id: id ?? this.id,
      agentCode: agentCode ?? this.agentCode,
      modality: modality ?? this.modality,
      type: type ?? this.type,
      codePerson: codePerson ?? this.codePerson,
      orderedRcaId: orderedRcaId ?? this.orderedRcaId,
      reasonCode: reasonCode ?? this.reasonCode,
      observation: observation ?? this.observation,
      startDate: startDate ?? this.startDate,
      duration: duration ?? this.duration,
      clientName: clientName ?? this.clientName,
      agentName: agentName ?? this.agentName,
      supervisorName: supervisorName ?? this.supervisorName,
      supervisorCode: supervisorCode ?? this.supervisorCode,
      descriptionType: descriptionType ?? this.descriptionType,
      customerBillingAddress:
          customerBillingAddress ?? this.customerBillingAddress,
      corporateName: corporateName ?? this.corporateName,
      address: address ?? this.address,
      latClient: latClient ?? this.latClient,
      lonClient: lonClient ?? this.lonClient,
      latService: latService ?? this.latService,
      lonService: lonService ?? this.lonService,
      descriptionService: descriptionService ?? this.descriptionService,
      distance: distance ?? this.distance,
      situationService: situationService ?? this.situationService,
      cnpj: cnpj ?? this.cnpj,
      orderedId: orderedId ?? this.orderedId,
      fantasy: fantasy ?? this.fantasy,
      descriptionSituation: descriptionSituation ?? this.descriptionSituation,
    );
  }

  /// Linhas do popup do mapa.
  ///
  /// [compact] replica o popup do Gestão (data + duração + modalidade num só
  /// campo); `false` replica o do BackOffice (linhas separadas + coordenadas).
  Map<String, String?> toViewRows({bool compact = false}) {
    final base = <String, String?>{
      'Data': compact
          ? '${formatDateTime(startDate)} ${formatDurationLong(duration)} '
              '${modalidade?.label ?? ''}'
          : formatDateTime(startDate),
      'Cliente': fantasy ?? '',
      'Código cliente': codePerson,
      'Razão social': corporateName,
      'CNPJ': formatDocument(cnpj),
      'Endereço Cliente': address.trim(),
    };

    if (!compact) {
      base['Latitude cliente'] = latClient?.toString() ?? '';
      base['Longitude cliente'] = lonClient?.toString() ?? '';
      if (latService != null) base['Latitude atendimento'] = '$latService';
      if (lonService != null) base['Longitude atendimento'] = '$lonService';
    }

    base['Representante'] = agentName ?? '';
    base['Resultado Atendimento'] = descriptionService ?? '';

    if (!compact) {
      base['Modalidade'] = modalidade?.label ?? '';
      base['Duração'] = formatDurationLong(duration);
    }

    return base;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'Id': id,
        'CodRepres': agentCode,
        'ModalidadeAtendimento': modality,
        'TipoAtendimento': type,
        'CodPessoa': codePerson,
        'PedidoRCAId': orderedRcaId,
        'CodMotivoNaoVenda': reasonCode,
        'ObservacaoAtendimento': observation,
        'DataHoraInicioAtendimento': startDate.toIso8601String(),
        'DuracaoAtendimento': duration,
        'NomeCliente': clientName,
        'NomeRepresentante': agentName,
        'NomeSupervisor': supervisorName,
        'CodSupervisor': supervisorCode,
        'TipoDescricao': descriptionType,
        'EnderecoFaturamentoCliente': customerBillingAddress,
        'RazaoSocial': corporateName,
        'EnderecoCliente': address,
        'LatitudeCliente': latClient?.toString(),
        'LongitudeCliente': lonClient?.toString(),
        'LatitudeAtendimento': latService?.toString(),
        'LongitudeAtendimento': lonService?.toString(),
        'DescricaoAtendimento': descriptionService,
        'DistanciaAtendimento': distance,
        'SituacaoAtendimento': situationService,
        'Cnpj': cnpj,
        'IdPedido': orderedId,
        'Fantasia': fantasy,
        'DescricaoSituacaoAtendimento': descriptionSituation,
      };

  @override
  String toString() =>
      'Atendimento($id, $codePerson, ${situationService ?? "-"})';
}

String? _text(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

int? _int(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString().trim());
}

double? _double(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  final text = value.toString().trim().replaceAll(',', '.');
  if (text.isEmpty || text == 'null') return null;
  return double.tryParse(text);
}

DateTime _date(dynamic value) {
  if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
  if (value is DateTime) return value;
  final parsed = DateTime.tryParse(value.toString().trim());
  return parsed ?? DateTime.fromMillisecondsSinceEpoch(0);
}
