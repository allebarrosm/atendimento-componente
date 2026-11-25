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
