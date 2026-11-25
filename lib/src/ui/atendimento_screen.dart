import 'package:flutter/material.dart';

import 'atendimento_body.dart';
import 'store/atendimento_store.dart';

/// Tela completa (com `Scaffold`) para quem quer o atendimento "de fábrica".
///
/// Os apps podem usar só o [AtendimentoBody] dentro da própria moldura.
class AtendimentoScreen extends StatelessWidget {
  const AtendimentoScreen({
    super.key,
    required this.store,
    this.title = 'Atendimento',
    this.layout,
    this.actions,
    this.showAppBar = true,
  });

  final AtendimentoStore store;
  final String title;
  final AtendimentoLayout? layout;
  final List<Widget>? actions;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(title: Text(title), actions: actions)
          : null,
      body: AtendimentoBody(store: store, layout: layout),
    );
  }
}
