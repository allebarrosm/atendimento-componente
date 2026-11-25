import 'dart:convert';

import 'package:atendimento/atendimento.dart';
import 'package:flutter/material.dart';

void main() => runApp(const AtendimentoExampleApp());

class AtendimentoExampleApp extends StatelessWidget {
  const AtendimentoExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atendimento PoC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF38D2C0)),
      ),
      home: const AtendimentoDemoPage(),
    );
  }
}

class AtendimentoDemoPage extends StatefulWidget {
  const AtendimentoDemoPage({super.key});

  @override
  State<AtendimentoDemoPage> createState() => _AtendimentoDemoPageState();
}

class _AtendimentoDemoPageState extends State<AtendimentoDemoPage> {
  late final AtendimentoStore _store = AtendimentoStore(
    repository: AtendimentoRepository(DemoApi()),
    // A alteração de coordenada só existe no Web.
    enableCoordinateEditing: AtendimentoLayout.platform == AtendimentoLayout.web,
    onError: _showSnack,
  );

  AtendimentoLayout _layout = AtendimentoLayout.platform;

  DateTime _start = DateTime(2026, 11, 1);
  DateTime _end = DateTime(2026, 11, 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() {
    return _store.load(start: _start, end: _end);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickPeriod() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
      initialDateRange: DateTimeRange(start: _start, end: _end),
    );
    if (range == null) return;
    setState(() {
      _start = range.start;
      _end = range.end;
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_layout == AtendimentoLayout.web
            ? 'Atendimento (BackOffice)'
            : 'Atendimento (Gestão)'),
        actions: [
          TextButton.icon(
            onPressed: _pickPeriod,
            icon: const Icon(Icons.date_range, size: 18),
            label: const Text('Período'),
          ),
          const SizedBox(width: 8),
          ToggleButtons(
            isSelected: [
              _layout == AtendimentoLayout.mobile,
              _layout == AtendimentoLayout.web,
            ],
            onPressed: (index) => setState(
              () => _layout = index == 0
                  ? AtendimentoLayout.mobile
                  : AtendimentoLayout.web,
            ),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('Mobile'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('Web'),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: AtendimentoBody(
        store: _store,
        layout: _layout,
        // No Web, o grid pode ser o do BackOffice; aqui usamos o do pacote.
      ),
      floatingActionButton: _layout == AtendimentoLayout.web
          ? null
          : FloatingActionButton.extended(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Recarregar'),
            ),
    );
  }
}

/// API de demonstração: 30 clientes em Recife com situações variadas.
class DemoApi implements AtendimentoApi {
  @override
  Future<AtendimentoResponse> getServices(Map<String, String> params) async {
    final page = int.parse(params['skip']!) ~/ int.parse(params['top']!);
    final all = _demoJson();
    final start = page * 50;
    final values = start >= all.length
        ? const <Map<String, dynamic>>[]
        : all.sublist(start, (start + 50).clamp(0, all.length));
    return AtendimentoResponse.ok(
      jsonEncode(<String, dynamic>{
        'd': {'results': values},
      }),
    );
  }

  @override
  Future<AtendimentoResponse> getClientsWithoutService(
    Map<String, String> params,
  ) async =>
      AtendimentoResponse.ok(
        jsonEncode(_demoJson(onlyWithoutService: true)),
      );

  @override
  Future<AtendimentoResponse> getStatistics(Map<String, String> params) async =>
      AtendimentoResponse.ok(
        jsonEncode(<String, dynamic>{
          'TotalGeral': _demoJson().length,
          'TotalVendas': 12,
          'TotalNaoVendas': 6,
          'TotalPresencial': 18,
          'TotalRemoto': 8,
          'TotalOrcamentos': 4,
        }),
      );

  @override
  Future<AtendimentoResponse> updateClientCoordinate(
    Map<String, String> params,
  ) async {
    debugPrint('Coordenada salva: $params');
    return const AtendimentoResponse.ok('{}');
  }
}

List<Map<String, dynamic>> _demoJson({bool onlyWithoutService = false}) {
  const situations = [
    'VisitadoComAgenda',
    'NaoVisitadoComAgenda',
    'VisitadoSemAgenda',
    'NaoVisitadoSemAgenda',
  ];

  final values = <Map<String, dynamic>>[];

  for (var i = 0; i < 30; i++) {
    final situation = situations[i % situations.length];
    final remote = i % 5 == 0;
    final farAway = !remote && i % 7 == 0;
    final withoutService = situation == 'NaoVisitadoSemAgenda';

    if (onlyWithoutService != withoutService) continue;

    final lat = -8.05 + (i % 6) * 0.012;
    final lon = -34.9 + (i % 7) * 0.015;

    values.add(<String, dynamic>{
      'Id': i + 1,
      'CodRepres': '7',
      'ModalidadeAtendimento': remote ? '1' : '0',
      'TipoAtendimento': i.isEven ? 0 : 1,
      'CodPessoa': '${1000 + i}',
      'PedidoRCAId': null,
      'CodMotivoNaoVenda': null,
      'ObservacaoAtendimento': i % 4 == 0 ? 'Cliente pediu retorno' : null,
      'DataHoraInicioAtendimento':
          DateTime(2026, 11, 20, 8 + (i % 9), 15).toIso8601String(),
      'DuracaoAtendimento': 300 + i * 60,
      'NomeCliente': 'Cliente $i',
      'NomeRepresentante': 'Representante ${(i % 4) + 1}',
      'NomeSupervisor': 'Supervisor',
      'CodSupervisor': '3',
      'TipoDescricao': 'Venda',
      'EnderecoFaturamentoCliente': null,
      'RazaoSocial': 'EMPRESA ${i + 1} LTDA',
      'EnderecoCliente': 'Rua Demo, ${100 + i}',
      'LatitudeCliente': lat.toString(),
      'LongitudeCliente': lon.toString(),
      'LatitudeAtendimento': farAway ? (lat + 0.004).toString() : null,
      'LongitudeAtendimento': farAway ? (lon + 0.004).toString() : null,
      'DescricaoAtendimento': i.isEven ? 'Pedido 123' : null,
      'DistanciaAtendimento': farAway ? 'Distante' : null,
      'SituacaoAtendimento': situation,
      'Cnpj': '12345678000199',
      'IdPedido': i.isEven ? 900 + i : null,
      'Fantasia': 'Fantasia $i',
      'DescricaoSituacaoAtendimento': _situationLabel(situation),
    });
  }

  return values;
}

String _situationLabel(String situation) {
  switch (situation) {
    case 'VisitadoComAgenda':
      return 'Agendado e atendido';
    case 'NaoVisitadoComAgenda':
      return 'Agendado e não atendido';
    case 'VisitadoSemAgenda':
      return 'Sem agenda e atendido';
    default:
      return 'Sem agenda e não atendido';
  }
}
