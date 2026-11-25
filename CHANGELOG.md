# Changelog

## 0.1.0 — 2025-11-25

Primeira versão: componente de Atendimento compartilhado entre Gestão e
BackOffice.

### Núcleo
- `Atendimento` canônico com as 29 chaves de `LstClienteAtendimento/GetOData`,
  `fromJson`/`toJson`, `copyWith` e coordenadas normalizadas (`GeoPoint`).
- `AtendimentoSituacao` (4 situações), `Modalidade` (presencial/remoto) e
  `TipoAtendimento` (venda+não venda) — fim das strings mágicas.
- `AtendimentoFilter` com os mesmos 7 interruptores dos apps (ids 1..7) e
  regra única: situação **e** modalidade.
- `AtendimentoCounters` (agenda/atendidos/não atendidos) e
  `AtendimentoStatistics`.
- `AtendimentoQuery` (OData `$filter`/`$orderby`/`skip`/`top`, parâmetros de
  clientes e estatísticas, escape de apóstrofo).
- Formatação de data, duração, CNPJ/CPF e milhar sem `intl`.

### Dados
- `AtendimentoApi` (contrato de transporte) e `AtendimentoResponse`.
- `AtendimentoRepository`: paginação, clientes sem atendimento na 1ª página,
  geocodificação opcional, deslocamento de atendimento remoto e espalhamento
  determinístico de pinos no mesmo ponto.
- `saveClientCoordinate` (`POST /api/endereco/cordenadas`).

### Interface
- `AtendimentoStore` (MobX): filtro, páginas, marcadores, polylines, títulos,
  seleção, contadores e edição de coordenada.
- `AtendimentoBody` com dois layouts: Android = Gestão (mapa + cabeçalho +
  cards + filtros inferiores) e Web = BackOffice (mapa/grade + painel lateral).
- `AtendimentoFilterPanel`, `AtendimentoCard`, `AtendimentoStatsPanel`,
  `AtendimentoGrid`, `AtendimentoLegend` e `CoordinateEditorBar`.
- Alteração de coordenada **somente no Web** (`enableCoordinateEditing`), com
  arrastar do pino, geocodificação por endereço e salvar/cancelar.
- Mapa reaproveitado do pacote `roteiro` (`RoteiroMap`, `InfoWindow`,
  `DetailsCard`).

### Qualidade
- 68 testes (núcleo, repositório, store e fábrica de títulos).
- `flutter analyze` limpo.
- `flutter build web` do `example` OK.

## 0.1.1 — 2025-11-25

Ajustes de layout para ficar idêntico ao BackOffice no Web.

### Web
- Barra de legenda/filtros embaixo do mapa com os 7 checkboxes (ícone + rótulo),
  no lugar do painel sobreposto.
- Painel lateral no estilo do BackOffice: botão **Grid/Mapa** branco com borda
  preta (56px), cards brancos com borda preta e ícones nas cores do app.
- Pílulas **Satélite** e **StreetView** no topo do mapa.
- **Alteração de coordenada sempre ativa** (sem botão/switch): arrastar o pino
  abre a barra de endereço/coordenada com Salvar/Cancelar. No Android continua
  sempre inativa.
- O mapa **não sai mais da tela** ao aplicar um filtro: o carregamento virou uma
  faixa de progresso no topo.

### Correções
- Pinos de cliente mantêm o ícone da situação no modo de edição; só o cliente
  em edição usa o ícone de alvo.

### 0.1.1 (ajuste)

- Legenda inferior em grade: quatro colunas de mesma largura com os checkboxes
  alinhados (mesmo x por coluna e mesmo y por linha), independente do tamanho do
  rótulo.

- Removida a faixa laranja de carregamento do topo do mapa (o mapa já não sai
  da tela ao filtrar; a atualização acontece sem barra).

## 0.1.2 — 2025-11-25

Ajustes do mobile.

- Cards de indicadores no mobile iguais aos do Gestão: duas caixas com borda,
  "Clientes" com seta para expandir/recolher, "Agendados/Sem Vendas/Orçamento/
  Presencial/Remoto" e a caixa de agenda (Agenda/Atendidos/Não Atendidos), com
  os mesmos ícones/cores e valores com separador de milhar.
- `AtendimentoBody` ganhou `showFilterButton` (default `true`). O Gestão passa
  `false` e abre os interruptores pelo atalho da barra superior, que agora
  funciona também sobre o mapa.

## 0.1.3 — 2025-11-25

- Cards de indicadores do mobile idênticos ao Gestão: rótulo no estilo
  `bodySmall` (itálico, 13, branco herdado), valor no estilo `titleMedium`
  (14, peso normal), ícone na cor primária do tema, borda preta, largura de
  rótulo 92 e os mesmos paddings do `InformationViewWithMap`.

## 0.1.4 — 2025-11-25

- O botão de filtros do mapa (três traços) saiu da visão normal no mobile: lá o
  atalho é o da barra do app. Ele aparece só na **tela cheia**, que passou a ser
  desenhada pelo pacote (mapa com câmera própria, botão de fechar e o filtro
  abrindo em bottom sheet).

## 0.1.5 — 2025-11-25

- Sem atendimentos, a tela não exibe mais a mensagem "Selecione as opções no
  filtro para exibir os atendimentos": lista e grade ficam simplesmente vazias.

## 0.1.6 — 2025-11-25

- Pinos do mapa no mobile: o do cliente (situação) passou de 25 para 30px e o
  do atendimento (presencial/remoto/fora do cliente) de 25 para 22px. Como o
  pino do atendimento é desenhado por cima, menorzinho ele deixa o de trás
  visível. No Web os tamanhos continuam 25/25.

## 0.1.7 — 2025-11-25

- Card do rodapé do mapa igual ao Gestão/BackOffice: `AtendimentoStreetViewCard`
  (450x200) com fechar no topo à direita e **miniatura** do panorama (150x100)
  com a etiqueta "Street View"; tocar na miniatura entra no Street View. Sem
  panorama, fica o mesmo quadro vazio do app.

## 0.1.8 — 2025-11-25

- Tamanho dos pinos no mobile: cliente **66px** e atendimento (presencial/
  remoto/fora do cliente) **50px**. No Web seguem 25/25.

## 0.1.9 — 2025-11-25

- Novo filtro **Agendamentos** (`AgendamentosFiltro`): "Vazio", "Atendidos" e
  "Não Atendidos". Ele decide quais endpoints a consulta chama:
  - "Vazio" (padrão) → `GetOData` + `GetClientesSemAtendimento` (como antes);
  - "Atendidos" → só `GetOData`;
  - "Não Atendidos" → só `GetClientesSemAtendimento` (a API 06.22.0419 já traz
    exatamente os clientes não atendidos), sem paginação.
- No modo "Não Atendidos" o interruptor "Cliente sem agenda" é ligado
  automaticamente para a lista/mapa não virem vazios.
- Clientes sem atendimento (id 0) não são mais deduplicados na lista.
