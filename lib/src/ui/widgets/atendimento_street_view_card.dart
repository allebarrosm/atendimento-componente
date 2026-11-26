import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:roteiro/ui.dart'
    show RoteiroStreetViewRequest, buildDefaultStreetView;

/// Miniatura do panorama (150x100) com a etiqueta "Street View".
///
/// Usada pelo card do mobile e pelo card de confirmação da alteração de
/// coordenada no Web. Enquanto verifica o ponto (ou quando não há panorama)
/// mostra o mesmo quadro vazio dos apps.
class AtendimentoStreetViewPreview extends StatefulWidget {
  const AtendimentoStreetViewPreview({
    super.key,
    required this.coordinate,
    required this.verify,
    this.onTap,
    this.size = const Size(150, 100),
  });

  final LatLng coordinate;

  /// Consulta se existe panorama no ponto (Street View Metadata API).
  final Future<bool> Function(LatLng coordinate) verify;

  /// Chamado ao tocar na miniatura (abre o panorama).
  final VoidCallback? onTap;

  final Size size;

  @override
  State<AtendimentoStreetViewPreview> createState() =>
      _AtendimentoStreetViewPreviewState();
}

class _AtendimentoStreetViewPreviewState
    extends State<AtendimentoStreetViewPreview> {
  /// `null` = verificando, `true` = tem panorama, `false` = não tem.
  bool? _available;
  LatLng? _checked;

  @override
  void initState() {
    super.initState();
    _check();
  }

  @override
  void didUpdateWidget(covariant AtendimentoStreetViewPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coordinate != widget.coordinate) _check();
  }

  Future<void> _check() async {
    final coordinate = widget.coordinate;
    _checked = coordinate;
    setState(() => _available = null);

    bool available;
    try {
      available = await widget.verify(coordinate);
    } catch (_) {
      available = false;
    }

    // Ignora resposta de uma coordenada que já não é a atual.
    if (!mounted || _checked != coordinate) return;
    setState(() => _available = available);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = widget.size;

    if (_available != true) {
      return Container(
        width: size.width,
        height: size.height,
        color: scheme.surfaceContainerHighest,
      );
    }

    final coordinate = widget.coordinate;

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AbsorbPointer(
              child: buildDefaultStreetView(
                context,
                RoteiroStreetViewRequest(
                  latitude: coordinate.latitude,
                  longitude: coordinate.longitude,
                  onClose: () {},
                  // Miniatura de 150x100: sem os controles do Google, que
                  // cobriam a foto e apareciam cortados no Web.
                  showControls: false,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: scheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    Icon(Icons.threesixty_outlined, color: scheme.onSurface),
                    const SizedBox(width: 10),
                    Text(
                      'Street View',
                      style: TextStyle(color: scheme.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de Street View exibido ao selecionar um pino no mapa (mobile).
///
/// Mesmo funcionamento do Gestão: card de 450x200 no rodapé, com fechar no topo
/// à direita e a **miniatura** do panorama. Ao tocar na miniatura, o mapa entra
/// no Street View.
class AtendimentoStreetViewCard extends StatelessWidget {
  const AtendimentoStreetViewCard({
    super.key,
    required this.coordinate,
    required this.verify,
    required this.onOpen,
    this.onClose,
    this.maxWidth = 450,
    this.previewSize = const Size(150, 100),
  });

  final LatLng coordinate;

  /// Consulta se existe panorama no ponto (Street View Metadata API).
  final Future<bool> Function(LatLng coordinate) verify;

  /// Chamado ao tocar na miniatura.
  final VoidCallback onOpen;

  final VoidCallback? onClose;
  final double maxWidth;
  final Size previewSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Material(
            color: scheme.surface,
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 200,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.close, color: scheme.onSurface),
                      onPressed: onClose,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: AtendimentoStreetViewPreview(
                          coordinate: coordinate,
                          verify: verify,
                          onTap: onOpen,
                          size: previewSize,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
