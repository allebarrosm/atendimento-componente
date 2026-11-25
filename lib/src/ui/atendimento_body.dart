import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobx/mobx.dart';
import 'package:roteiro/ui.dart'
    show
        RoteiroDetailsCard,
        RoteiroInfoWindowData,
        RoteiroMap,
        RoteiroMapButton,
        RoteiroMapController;

import '../core/atendimento.dart';
import '../core/atendimento_format.dart';
import 'store/atendimento_store.dart';
import 'widgets/atendimento_card.dart';
import 'widgets/atendimento_filter_panel.dart';
import 'widgets/atendimento_grid.dart';
import 'widgets/atendimento_legend_bar.dart';
import 'widgets/atendimento_stats_panel.dart';
import 'widgets/coordinate_editor_bar.dart';

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
    this.initialZoom = 5,
  });

  final AtendimentoStore store;

  /// `null` = detecta pela plataforma.
  final AtendimentoLayout? layout;

  /// Grade customizada (o BackOffice pode injetar o `GridSync` dele).
  final Widget Function(BuildContext context, List<Atendimento> rows)?
      gridBuilder;

  final bool enableStreetView;
  final double initialZoom;

  @override
  State<AtendimentoBody> createState() => _AtendimentoBodyState();
}

class _AtendimentoBodyState extends State<AtendimentoBody> {
  late final RoteiroMapController _mapController = RoteiroMapController(
    onError: widget.store.onError,
  );

  late final List<ReactionDisposer> _disposers;

  bool _showFilters = false;
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
        if (_showFilters)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AtendimentoFilterPanel(
              filter: widget.store.filter,
              showClient: widget.store.showClient,
              onToggleSwitch: widget.store.setFilterSwitch,
              onShowClient: widget.store.setShowClient,
              onClose: () => setState(() => _showFilters = false),
            ),
          ),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    final rows = widget.store.rows;

    return Column(
      children: [
        AtendimentoStatsHeader(items: _headerItems()),
        Expanded(
          child: rows.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      emptyAtendimentoMessage,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
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

  List<MapEntry<String, String?>> _headerItems() {
    final stats = widget.store.statistics;
    final counters = widget.store.counters;
    return [
      MapEntry('Atendimentos', _count(stats?.grandTotal)),
      MapEntry('Vendas', _count(stats?.totalSales)),
      MapEntry('Sem Vendas', _count(stats?.totalNoSales)),
      MapEntry('Orçamento', _count(stats?.totalBudget)),
      MapEntry('Presencial', _count(stats?.totalOnsite)),
      MapEntry('Remotas', _count(stats?.totalRemote)),
      MapEntry('Agenda', _count(counters.scheduled)),
      MapEntry('Atendidos', _count(counters.visited)),
      MapEntry('Não Atendidos', _count(counters.notVisited)),
    ];
  }

  String? _count(int? value) {
    if (value == null || value == 0) return null;
    return formatCount(value);
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
                  onToggleMap: () =>
                      widget.store.setMap(!widget.store.isMap),
                  onShowClient: widget.store.setShowClient,
                ),
              ],
            ),
          ),
          // Barra de legenda/filtros, embaixo do mapa (como no BackOffice).
          Positioned(
            left: 0,
            bottom: 0,
            child: AtendimentoLegendBar(
              filter: widget.store.filter,
              onToggleSwitch: widget.store.setFilterSwitch,
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
          clustering: !store.canEditCoordinate,
          streetViewTarget: store.streetViewCoord,
          infoWindow: selected == null
              ? null
              : RoteiroInfoWindowData(
                  title: selected.displayName,
                  subtitle: selected.address,
                  rows: selected.toViewRows(
                    compact: _layout == AtendimentoLayout.mobile,
                  ),
                ),
          onCloseInfoWindow: store.clearSelection,
          detailsCard:
              selected == null ? null : _detailsCard(context, selected),
          showDetailsCard: selected != null,
          onCloseDetails: store.clearSelection,
          // No Web os botões de mapa/Street View viram as pílulas do topo.
          showMapTypeButton: _layout == AtendimentoLayout.mobile,
          showStreetViewButton:
              _layout == AtendimentoLayout.mobile && widget.enableStreetView,
          customButton: _layout == AtendimentoLayout.mobile
              ? RoteiroMapButton(
                  icon: Icons.arrow_back,
                  tooltip: 'Ver lista',
                  onTap: () => store.setMap(false),
                )
              : null,
          customButtonRight: _layout == AtendimentoLayout.mobile
              ? RoteiroMapButton(
                  icon: Icons.filter_list,
                  tooltip: 'Filtros',
                  active: _showFilters,
                  onTap: () => setState(() => _showFilters = !_showFilters),
                )
              : null,
          onMapTap: (_) => store.clearSelection(),
        ),
        if (_layout == AtendimentoLayout.web) _buildMapPills(context),
        if (store.canEditCoordinate && store.editing != null)
          Positioned(
            left: 12,
            right: 12,
            // No Web a barra fica abaixo das pílulas Satélite/StreetView.
            top: _layout == AtendimentoLayout.web ? 62 : 12,
            child: CoordinateEditorBar(store: store),
          ),
      ],
    );
  }

  /// Pílulas "Satélite" e "StreetView" no topo do mapa (layout do BackOffice).
  Widget _buildMapPills(BuildContext context) {
    final target = widget.store.streetViewCoord;

    // Ao lado do botão de tela cheia (que o mapa desenha em `right: 12`).
    return Positioned(
      // Centralizado com o botão de tela cheia (46px em `top: 12`).
      top: 19,
      right: 66,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill(
            label: _mapController.isNormalType ? 'Satélite' : 'Mapa',
            onTap: _mapController.toggleMapType,
          ),
          const SizedBox(width: 8),
          _pill(
            label: 'StreetView',
            icon: Icons.streetview,
            filled: true,
            onTap: target == null
                ? null
                : () => _mapController.openStreetView(target),
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required String label,
    IconData? icon,
    bool filled = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: filled ? const Color(0xFF7A7A7A) : Colors.white,
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
                  color: filled ? Colors.white : Colors.black,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: filled ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailsCard(BuildContext context, Atendimento selected) {
    final store = widget.store;

    return RoteiroDetailsCard(
      title: selected.displayName,
      subtitle: selected.descriptionSituation,
      address: selected.address,
      onClose: store.clearSelection,
      onStreetView: () {
        final coord = selected.serviceLocation ?? selected.clientLocation;
        if (coord == null) return;
        _mapController.openStreetView(
          LatLng(coord.latitude, coord.longitude),
        );
      },
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
