import 'package:flutter/material.dart';

import '../../core/atendimento.dart';
import '../../core/atendimento_format.dart';
import '../store/atendimento_marker_factory.dart';

/// Grade do Web — mesmas colunas do `ServiceDataSource` do BackOffice.
class AtendimentoGrid extends StatelessWidget {
  const AtendimentoGrid({
    super.key,
    required this.rows,
    this.onRowTap,
    this.onLoadMore,
    this.loadingMore = false,
    this.emptyMessage = 'Selecione as opções no filtro para exibir os atendimentos',
  });

  final List<Atendimento> rows;
  final void Function(Atendimento atendimento)? onRowTap;

  final VoidCallback? onLoadMore;
  final bool loadingMore;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(emptyMessage, textAlign: TextAlign.center),
        ),
      );
    }

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowHeight: 40,
            dataRowMinHeight: 34,
            dataRowMaxHeight: 40,
            columnSpacing: 18,
            columns: const [
              DataColumn(label: Text('Data')),
              DataColumn(label: Text('Representante')),
              DataColumn(label: Text('Razão Social')),
              DataColumn(label: Text('Fantasia')),
              DataColumn(label: Text('CNPJ')),
              DataColumn(label: Text('Endereço')),
              DataColumn(label: Text('Modalidade')),
              DataColumn(label: Text('Resultado')),
              DataColumn(label: Text('Observação')),
              DataColumn(label: Text('Situação')),
              DataColumn(label: Text('Duração')),
            ],
            rows: [
              for (final atendimento in rows)
                DataRow(
                  onSelectChanged: onRowTap == null
                      ? null
                      : (_) => onRowTap!(atendimento),
                  cells: [
                    DataCell(Text(atendimento.startDateText)),
                    DataCell(Text(atendimento.agentName ?? '-')),
                    DataCell(Text(atendimento.corporateName)),
                    DataCell(Text(atendimento.fantasy ?? '-')),
                    DataCell(Text(formatDocument(atendimento.cnpj))),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: Text(
                          atendimento.address,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(modalityLabel(atendimento))),
                    DataCell(Text(atendimento.descriptionService ?? '-')),
                    DataCell(Text(atendimento.observation ?? '-')),
                    DataCell(Text(atendimento.descriptionSituation)),
                    DataCell(Text(atendimento.durationText)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
