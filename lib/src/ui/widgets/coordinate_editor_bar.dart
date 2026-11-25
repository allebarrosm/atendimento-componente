import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

import '../store/atendimento_store.dart';

/// Barra de edição de coordenada exibida sobre o mapa (somente Web).
///
/// Permite arrastar o pino (o mapa continua interativo), digitar um endereço
/// para geocodificar e salvar/cancelar a alteração.
class CoordinateEditorBar extends StatefulWidget {
  const CoordinateEditorBar({super.key, required this.store});

  final AtendimentoStore store;

  @override
  State<CoordinateEditorBar> createState() => _CoordinateEditorBarState();
}

class _CoordinateEditorBarState extends State<CoordinateEditorBar> {
  late final TextEditingController _address = TextEditingController(
    text: widget.store.editing?.address ?? '',
  );

  late final List<ReactionDisposer> _disposers;

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _disposers = [
      reaction<int?>(
        (_) => widget.store.editing?.id,
        (_) => _address.text = widget.store.editing?.address ?? '',
      ),
    ];
  }

  @override
  void dispose() {
    for (final dispose in _disposers) {
      dispose();
    }
    _address.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await widget.store.changeAddress(_address.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) _showError('Não foi possível localizar o endereço informado.');
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await widget.store.saveCoordinate();
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      _showError(
        widget.store.errorMessage ?? 'Não foi possível salvar a coordenada.',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final coord = widget.store.editingCoord;

        return Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _address,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Endereço',
                      hintText: 'Digite o endereço e clique em Localizar',
                    ),
                    onSubmitted: (_) => _locate(),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _busy ? null : _locate,
                  child: const Text('Localizar'),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Arraste o pino no mapa para ajustar',
                      style: TextStyle(fontSize: 11),
                    ),
                    Text(
                      coord == null
                          ? 'sem coordenada'
                          : '${coord.latitude.toStringAsFixed(6)}, '
                              '${coord.longitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: widget.store.savingCoordinate
                      ? null
                      : () => widget.store.cancelCoordinateEdit(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: (coord == null || widget.store.savingCoordinate)
                      ? null
                      : _save,
                  child: widget.store.savingCoordinate
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
