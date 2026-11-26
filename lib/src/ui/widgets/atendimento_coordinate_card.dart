import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roteiro/core.dart' show GeoPoint;

import '../store/atendimento_store.dart';
import 'atendimento_street_view_card.dart';

/// Card de confirmação da alteração de coordenada (Web).
///
/// Mesmo desenho do BackOffice antigo: o panorama do ponto à esquerda e, à
/// direita, os dados do cliente + o botão **Mudar Coordenada**. Ao digitar um
/// endereço (ou arrastar o pino) a coordenada muda e o botão vira
/// **Confirmar mudança**, que grava no backend.
class AtendimentoCoordinateCard extends StatelessWidget {
  const AtendimentoCoordinateCard({
    super.key,
    required this.store,
    required this.verifyStreetView,
    required this.onOpenStreetView,
    this.maxWidth = 620,
  });

  final AtendimentoStore store;

  /// Consulta se existe panorama no ponto.
  final Future<bool> Function(LatLng coordinate) verifyStreetView;

  /// Abre o panorama em tela cheia.
  final void Function(LatLng coordinate) onOpenStreetView;

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final editing = store.editing;
        if (editing == null) return const SizedBox.shrink();

        final scheme = Theme.of(context).colorScheme;
        final coord = store.editingCoord;
        final original = editing.clientLocation;
        final changed = coord != null &&
            (original == null ||
                (coord.latitude - original.latitude).abs() > 1e-9 ||
                (coord.longitude - original.longitude).abs() > 1e-9);

        // A coordenada alterada é a do cliente; o panorama mostra esse ponto.
        final previewCoord = coord ?? _latLng(editing.clientLocation);

        return Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Material(
              color: scheme.surface,
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close, color: scheme.onSurface),
                        tooltip: 'Cancelar',
                        onPressed: () => store.cancelCoordinateEdit(),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (previewCoord == null)
                          Container(
                            width: 150,
                            height: 100,
                            color: scheme.surfaceContainerHighest,
                          )
                        else
                          AtendimentoStreetViewPreview(
                            coordinate: previewCoord,
                            verify: verifyStreetView,
                            onTap: () => onOpenStreetView(previewCoord),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                editing.displayName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                editing.address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                coord == null
                                    ? 'sem coordenada'
                                    : '${coord.latitude.toStringAsFixed(7)}, '
                                        '${coord.longitude.toStringAsFixed(7)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 10),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: scheme.primary,
                                  foregroundColor: scheme.onPrimary,
                                ),
                                onPressed: store.savingCoordinate
                                    ? null
                                    : changed
                                        ? () => store.saveCoordinate()
                                        : () => _askAddress(context),
                                child: Text(
                                  changed
                                      ? 'Confirmar mudança'
                                      : 'Mudar Coordenada',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static LatLng? _latLng(GeoPoint? point) =>
      point == null ? null : LatLng(point.latitude, point.longitude);

  Future<void> _askAddress(BuildContext context) async {
    final editing = store.editing;
    if (editing == null) return;

    final controller = TextEditingController(text: editing.address);
    final address = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mudar coordenada'),
        content: SizedBox(
          width: 420,
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Novo endereço',
              hintText: 'Rua, número, bairro, estado, 00000-000',
            ),
            onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Alterar'),
          ),
        ],
      ),
    );
    controller.dispose();

    final text = address?.trim() ?? '';
    if (text.isEmpty) return;

    final ok = await store.changeAddress(text);
    if (!ok && context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Não foi possível localizar o endereço informado.'),
        ),
      );
    }
  }
}
