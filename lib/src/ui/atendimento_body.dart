import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobx/mobx.dart';
import 'package:roteiro/ui.dart'
    show
        RoteiroCircleButton,
        RoteiroInfoWindowData,
        RoteiroMap,
        RoteiroMapButton,
        RoteiroMapController;

import '../core/atendimento.dart';
import 'store/atendimento_store.dart';
import 'widgets/atendimento_card.dart';
import 'widgets/atendimento_filter_panel.dart';
import 'widgets/atendimento_grid.dart';
import 'widgets/atendimento_legend_bar.dart';
import 'widgets/atendimento_stats_header.dart';
import 'widgets/atendimento_stats_panel.dart';
import 'widgets/atendimento_street_view_card.dart';
import 'widgets/atendimento_coordinate_card.dart';

/// Layout usado pela tela.
///
/// O padrão segue a plataforma: Android/iOS usam o layout do Gestão e o Web usa
/// o layout do BackOffice. Pode ser forçado (útil em testes e no `example`).
enum AtendimentoLayout {
  mobile,
  web;

  static AtendimentoLayout get platform =>
      kIsWeb ? AtendimentoLayout.web : AtendimentoLayout.mobile;
}

/// Corpo da tela de atendimento: mapa, lista/grade, estatísticas e filtros.
///
/// Não tem `Scaffold`: o app decide a moldura (abas, menu, cabeçalho) e só
/// encaixa este widget, como já acontece com o `RoteiroMap`.
class AtendimentoBody extends StatefulWidget {
  const AtendimentoBody({
    super.key,
    required this.store,
    this.layout,
    this.gridBuilder,
    this.enableStreetView = true,
    this.showFilterButton = true,
    this.initialZoom = 5,
  });

  final AtendimentoStore store;

  /// `null` = detecta pela plataforma.
  final AtendimentoLayout? layout;

  /// Grade customizada (o BackOffice pode injetar o `GridSync` dele).
  final Widget Function(BuildContext context, List<Atendimento> rows)?
      gridBuilder;

  final bool enableStreetView;

  /// Botão de filtros que o mapa desenha no mobile. O Gestão usa o atalho da
  /// própria barra (três barras) e desliga este.
  final bool showFilterButton;

  final double initialZoom;

  @override
  State<AtendimentoBody> createState() => _AtendimentoBodyState();
}

class _AtendimentoBodyState extends State<AtendimentoBody> {
  late final RoteiroMapController _mapController = RoteiroMapController(
    onError: widget.store.onError,
  );

  late final List<ReactionDisposer> _disposers;

  bool _fitted = false;

  AtendimentoLayout get _layout => widget.layout ?? AtendimentoLayout.platform;

  @override
  void initState() {
    super.initState();
    // O BackOffice abre no mapa; o Gestão abre na lista (default do store).
    if (_layout == AtendimentoLayout.web) {
      widget.store.setMap(true);
    }
    _disposers = [
      reaction<bool>(
        (_) => widget.store.loading,
        (loading) {
          if (!loading) _fitMarkers();
        },
      ),
      reaction<int>(
        (_) => widget.store.markers.length,
        (_) {
          if (!_fitted) _fitMarkers();
        },
      ),
    ];
  }

  @override
  void dispose() {
    for (final dispose in _disposers) {
      dispose();
    }
    _mapController.dispose();
    super.dispose();
  }

  void _fitMarkers() {
    if (!mounted || widget.store.markers.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _mapController.zoomToFit();
      _fitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => switch (_layout) {
        AtendimentoLayout.mobile => _buildMobile(context),
        AtendimentoLayout.web => _buildWeb(context),
      },
    );
  }

  // --------------------------------------------------------------- mobile

  Widget _buildMobile(BuildContext context) {
    final error = widget.store.errorMessage;

    return Stack(
      children: [
        if (widget.store.isMap) _buildMap(context) else _buildList(context),
        if (error != null)
          Positioned(
            top: 8,
            left: 12,
            right: 12,
            child: _ErrorBanner(message: error),
          ),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    final rows = widget.store.rows;

    return Column(
      children: [
        AtendimentoStatsHeader(
          statistics: widget.store.statistics,
          counters: widget.store.counters,
        ),
        Expanded(
          child: rows.isEmpty
              // Sem atendimentos não exibimos nada (o usuário não pediu aviso).
              ? const SizedBox.shrink()
              : ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (context, index) {
                    final atendimento = rows[index];
                    return AtendimentoCard(
                      atendimento: atendimento,
                      onTap: () {
                        widget.store.select(atendimento);
                        widget.store.setMap(true);
                      },
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            width: 220,
            height: 40,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF38D2C0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => widget.store.setMap(true),
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('Visualizar Mapa'),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ web

  Widget _buildWeb(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 20, top: 5),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 55),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: widget.store.isMap
                      ? _buildMap(context)
                      : (widget.gridBuilder?.call(
                              context, widget.store.rows) ??
                          AtendimentoGrid(
                            rows: widget.store.rows,
                            onRowTap: (atendimento) {
                              widget.store.select(atendimento);
                              widget.store.setMap(true);
                            },
                            loadingMore: widget.store.loadingMore,
                            onLoadMore: widget.store.hasMore
                                ? widget.store.loadMore
                                : null,
                          )),
                ),
                const SizedBox(width: 10),
                AtendimentoStatsPanel(
                  statistics: widget.store.statistics,
                  counters: widget.store.counters,
                  isMap: widget.store.isMap,
                  showClient: widget.store.showClient,
                  onToggleMap: () {
                    // Indo para a grade: fecha o panorama, senão ao voltar
                    // para o mapa ele reapareceria na coordenada antiga.
                    if (widget.store.isMap) _mapController.closeStreetView();
                    widget.store.setMap(!widget.store.isMap);
                  },
                  onShowClient: widget.store.setShowClient,
                ),
              ],
            ),
          ),
          // Barra de legenda/filtros, embaixo do mapa (como no BackOffice).
          // Some junto com o mapa quando o Street View está aberto.
          Positioned(
            left: 0,
            bottom: 0,
            child: Observer(
              builder: (context) => _mapController.isStreetView
                  ? const SizedBox.shrink()
                  : AtendimentoLegendBar(
                      filter: widget.store.filter,
                      onToggleSwitch: widget.store.setFilterSwitch,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ mapa

  Widget _buildMap(BuildContext context) {
    final store = widget.store;
    final selected = store.selected;

    return Stack(
      fit: StackFit.expand,
      children: [
        RoteiroMap(
          controller: _mapController,
          markers: store.markers.toSet(),
          polylines: store.polylines,
          titles: store.showClient ? store.titles.toList() : const [],
          initialZoom: widget.initialZoom,
          // Sem o agrupamento por zoom do `roteiro`: ele tira marcadores da
          // lista a cada mudança de câmera, e o toque chegava com um id que já
          // não existia ("Unknown marker ID ... in onTap" no Android). Também
          // garante que todos os pontos filtrados fiquem plotados.
          clustering: false,
          streetViewTarget: store.streetViewCoord,
          // A janela de detalhes (Data/Cliente/CNPJ...) é só do Web. No
          // mobile o pino selecionado mostra apenas o card de Street View.
          infoWindow: _layout != AtendimentoLayout.web ||
                  selected == null ||
                  !store.showInfoWindow ||
                  store.editing != null
              ? null
              : RoteiroInfoWindowData(
                  title: selected.displayName,
                  subtitle: selected.address,
                  rows: selected.toViewRows(),
                ),
          onCloseInfoWindow: store.closeInfoWindow,
          // No Web não há card: o panorama abre pela pílula ao lado de
          // "Satélite". No mobile o card fica no rodapé, como no Gestão.
          detailsCard: _layout == AtendimentoLayout.mobile
              ? _detailsCard(context, selected, _mapController)
              : null,
          showDetailsCard: _layout == AtendimentoLayout.mobile &&
              selected != null &&
              store.streetViewCoord != null,
          onCloseDetails: store.clearSelection,
          // No Web os botões de mapa/Street View viram as pílulas do topo.
          showMapTypeButton: _layout == AtendimentoLayout.mobile,
          showStreetViewButton:
              _layout == AtendimentoLayout.mobile && widget.enableStreetView,
          // No mobile a tela cheia é nossa (o filtro só aparece lá).
          showFullScreenButton: _layout == AtendimentoLayout.web,
          customButton: _layout == AtendimentoLayout.mobile
              ? RoteiroMapButton(
                  icon: Icons.arrow_back,
                  tooltip: 'Ver lista',
                  onTap: () => store.setMap(false),
                )
              : null,
          onMapTap: (_) => store.closeInfoWindow(),
        ),
        // Tela cheia no canto inferior direito (mobile), como no Gestão.
        if (_layout == AtendimentoLayout.mobile)
          Positioned(
            right: 12,
            bottom: 12,
            child: RoteiroCircleButton(
              icon: Icons.fullscreen,
              tooltip: 'Tela cheia',
              onTap: _openFullscreenMap,
            ),
          ),
        if (_layout == AtendimentoLayout.web) _buildMapPills(context),
        // Confirmação da alteração de coordenada: panorama à esquerda, dados
        // do cliente à direita e o botão Mudar Coordenada (Web).
        if (_layout == AtendimentoLayout.web && store.editing != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 15,
            child: AtendimentoCoordinateCard(
              store: store,
              verifyStreetView: (coord) async {
                final result =
                    await _mapController.streetViewService.verify(coord);
                return result.available;
              },
              onOpenStreetView: _mapController.openStreetView,
            ),
          ),
      ],
    );
  }

  /// Tela cheia do mobile: mapa com câmera própria e o botão de filtros —
  /// que não existe na visão normal (lá o atalho é o da barra do app).
  Future<void> _openFullscreenMap() async {
    final fullController = RoteiroMapController(
      streetViewService: _mapController.streetViewService,
      onError: widget.store.onError,
      initialZoom: _mapController.lastZoom ?? widget.initialZoom,
    );

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Mapa em tela cheia',
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Observer(
            builder: (context) {
              final store = widget.store;
              final selected = store.selected;

              return Stack(
                fit: StackFit.expand,
                children: [
                  RoteiroMap(
                    controller: fullController,
                    markers: store.markers.toSet(),
                    polylines: store.polylines,
                    titles: store.showClient ? store.titles.toList() : const [],
                    initialTarget: _mapController.adjustedLocation,
                    initialZoom: _mapController.lastZoom ?? widget.initialZoom,
                    clustering: false,
                    streetViewTarget: store.streetViewCoord,
                    // Mobile também não mostra a janela de detalhes aqui.
                    detailsCard: _detailsCard(context, selected, fullController),
                    showDetailsCard: selected != null &&
                        store.streetViewCoord != null,
                    onCloseDetails: store.clearSelection,
                    showFullScreenButton: false,
                    customButton: RoteiroMapButton(
                      icon: Icons.close,
                      tooltip: 'Sair da tela cheia',
                      onTap: () => Navigator.of(dialogContext).pop(),
                    ),
                    customButtonRight: widget.showFilterButton
                        ? RoteiroMapButton(
                            icon: Icons.filter_list,
                            tooltip: 'Filtros',
                            onTap: () => _openFilterSheet(dialogContext),
                          )
                        : null,
                    onMapTap: (_) => store.closeInfoWindow(),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    fullController.dispose();
  }

  /// Interruptores em bottom sheet (usado no mapa em tela cheia).
  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Observer(
        builder: (context) => AtendimentoFilterPanel(
          filter: widget.store.filter,
          showClient: widget.store.showClient,
          onToggleSwitch: widget.store.setFilterSwitch,
          onShowClient: widget.store.setShowClient,
          onClose: () => Navigator.of(sheetContext).pop(),
        ),
      ),
    );
  }

  /// Pílulas "Satélite" e "StreetView" no topo do mapa (layout do BackOffice).
  ///
  /// O Street View abre por aqui (não há mais card no rodapé):
  /// - sem ponto selecionado a pílula fica **cinza** e não responde ao toque;
  /// - com ponto selecionado fica branca e abre o panorama no lugar do mapa;
  /// - com o panorama aberto fica **escura** (e fecha ao tocar), enquanto a
  ///   pílula "Satélite/Mapa" some.
  Widget _buildMapPills(BuildContext context) {
    // Ao lado do botão de tela cheia (que o mapa desenha em `right: 12`).
    return Positioned(
      // Centralizado com o botão de tela cheia (46px em `top: 12`).
      top: 19,
      right: 66,
      child: Observer(
        builder: (context) {
          final target = widget.store.streetViewCoord;
          final active = _mapController.isStreetView;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!active) ...[
                _pill(
                  label: _mapController.isNormalType ? 'Satélite' : 'Mapa',
                  onTap: _mapController.toggleMapType,
                ),
                const SizedBox(width: 8),
              ],
              _pill(
                label: 'StreetView',
                icon: Icons.streetview,
                disabled: !active && target == null,
                active: active,
                onTap: active
                    ? _mapController.closeStreetView
                    : target == null
                        ? null
                        : () => _mapController.openStreetView(target),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _pill({
    required String label,
    IconData? icon,
    bool disabled = false,
    bool active = false,
    VoidCallback? onTap,
  }) {
    final background = active
        ? const Color(0xFF1B1B1B)
        : disabled
            ? const Color(0xFF7A7A7A)
            : Colors.white;
    final foreground =
        active || disabled ? Colors.white : Colors.black;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(24),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          // Mais largo e mais achatado.
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: foreground,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LatLng? _selectionCoordinate(Atendimento? selected) {
    if (selected == null) return null;
    final coord = selected.serviceLocation ?? selected.clientLocation;
    if (coord == null) return null;
    return LatLng(coord.latitude, coord.longitude);
  }

  /// Card de Street View do rodapé (mobile). Usa a mesma coordenada do botão
  /// de Street View — o ponto exato do pino clicado.
  Widget? _detailsCard(
    BuildContext context,
    Atendimento? selected,
    RoteiroMapController controller,
  ) {
    final coordinate = widget.store.streetViewCoord ??
        _selectionCoordinate(selected);
    if (coordinate == null) return null;

    return AtendimentoStreetViewCard(
      coordinate: coordinate,
      verify: (coord) async {
        final result = await controller.streetViewService.verify(coord);
        return result.available;
      },
      onOpen: () => controller.openStreetView(coordinate),
      onClose: widget.store.clearSelection,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.errorContainer,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: scheme.onErrorContainer, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: scheme.onErrorContainer, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
