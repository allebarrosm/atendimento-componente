# atendimento

Componente compartilhado de **Atendimento** para **Gestão** e **BackOffice**:
mapa, marcadores por situação/modalidade, títulos flutuantes, filtros, cards,
grade, estatísticas e alteração de coordenada.

É a mesma ideia do pacote [`roteiro`](../roteiro), aplicada ao Atendimento:

- **Android/iOS** → layout do **Gestão** (mapa + cabeçalho de números + lista de
  cards + painel de filtros inferior).
- **Web** → layout do **BackOffice** (mapa/grade + painel lateral de números +
  grade com as 11 colunas do BackOffice).
- **Alteração de coordenada sempre ativa no Web** (`enableCoordinateEditing`),
  com arrastar do pino, geocodificação por endereço e `Salvar/Cancelar` — sem
  botão de ligar/desligar. No Android fica sempre inativa.
- O `roteiro` já resolvido é reaproveitado para o mapa (`RoteiroMap`),
  `InfoWindow` e `DetailsCard` — o pacote não reimplementa a camada de mapa.

> **Escopo:** o EASYMART ficou de fora de propósito. Ele **registra** o
> atendimento (GPS, distância mínima, pedido, offline); este pacote cobre a
> **leitura/monitoramento**, que é o que Gestão e BackOffice fazem.

---

## O que foi unificado

Antes, cada app tinha a própria cópia de tudo isso (~2,8 mil linhas em cada um,
sem `.g.dart`). O que ficou igual nos dois (e agora mora aqui):

| Peça | Antes | Agora |
|---|---|---|
| Modelo `ServiceData` (29 chaves OData) | 2 cópias, já divergentes | `Atendimento` + `fromJson/toJson` |
| Situação (`"VisitadoComAgenda"` etc.) | string mágica em 30+ pontos | `AtendimentoSituacao` |
| Modalidade / tipo | `"0"`, `"1"`, `0`, `1` espalhados | `Modalidade`, `TipoAtendimento` |
| 7 interruptores do mapa | 2 regras diferentes | `AtendimentoFilter` |
| Contadores agenda/atendidos/não atendidos | 2 `setValues` | `AtendimentoCounters` |
| `$filter`/`$orderby`/`skip`/`top` | 2 `filterText` | `AtendimentoQuery` |
| Estatísticas | 2 modelos idênticos | `AtendimentoStatistics` |
| Paginação + clientes sem atendimento | 2 laços | `AtendimentoRepository` |
| Normalização/espalhamento de coordenadas | 2 cópias (uma com `Random`) | `AtendimentoRepository` |
| Ícones dos marcadores | caminhos duplicados | `AtendimentoMarkerFactory` |
| Títulos flutuantes | 2 regras | `AtendimentoTitleFactory` |
| Alterar coordenada (Web) | só no BackOffice | `AtendimentoStore` (flag) |

### Divergências que o pacote resolveu

Cada uma foi decidida (e tem teste):

1. **Filtro** — o Gestão exigia situação **e** modalidade; o BackOffice mostrava
   só pela modalidade. Agora `matches()` exige as duas dimensões, e "Presencial
   fora do cliente" é uma categoria própria (desligá-la esconde só os distantes).
2. **Coordenada inválida** — o Gestão descartava (`|x| > 180`), o BackOffice
   aceitava. Agora todo JSON passa por `GeoPoint.fromNullable`, que também
   corrige o cadastro sem separador decimal (`-235489337.0`).
3. **Popup do marcador** — Gestão e BackOffice mostravam campos diferentes.
   Agora há dois modos: `compact` (Gestão) e detalhado (BackOffice).
4. **Marcador sem coordenada de atendimento** — o Gestão plotava deslocado, o
   BackOffice escondia. Agora plota com o mesmo deslocamento em âncoras.
5. **Espalhamento de atendimentos no mesmo ponto** — era `Random`, mudava a cada
   recarga. Agora é determinístico (espiral de ângulo áureo).
6. **Escape de apóstrofo em OData** — nenhum dos dois fazia; agora `'` vira `''`.
7. **Chave do Google** — os repositórios carregavam a chave hardcoded. O pacote
   não conhece chave: quem geocodifica é o app, via `AtendimentoGeocoder`.

---

## Estrutura

```
lib/
  core.dart                  # núcleo puro (sem Flutter)
  data.dart                  # contrato de transporte + repositório
  ui.dart                    # store/widgets/tela
  atendimento.dart           # barrel completo
  src/
    core/
      atendimento.dart            # modelo canônico (29 chaves OData)
      atendimento_situacao.dart   # VisitadoComAgenda / ... + rótulos
      modalidade.dart             # presencial / remoto
      tipo_atendimento.dart       # venda+orçamento / não venda
      atendimento_filter.dart     # os 7 switches + "Nome Cliente"
      atendimento_statistics.dart # estatísticas + contadores da agenda
      atendimento_query.dart      # OData: $filter/$orderby/skip/top
      atendimento_format.dart     # data, duração, CNPJ, milhar (sem intl)
    data/
      atendimento_api.dart        # AtendimentoApi/AtendimentoResponse
      atendimento_repository.dart # paginação, coords, estatísticas
    ui/
      store/atendimento_store.dart      # MobX: filtro, mapa, seleção, edição
      store/atendimento_marker_factory.dart
      store/atendimento_title_factory.dart
      widgets/atendimento_card.dart     # card + cabeçalho + legenda
      widgets/atendimento_filter_panel.dart
      widgets/atendimento_grid.dart     # grade do Web
      widgets/atendimento_stats_panel.dart
      widgets/coordinate_editor_bar.dart
      theme/atendimento_theme.dart
      atendimento_body.dart             # layouts mobile/web
      atendimento_screen.dart           # Scaffold de conveniência
assets/images/               # 9 ícones (iguais nos 2 apps)
example/                     # demo Android/Web
test/                        # 93 testes
```

Regra de dependência: `core` não importa Flutter; `data` importa `core`; `ui`
importa `core` + `data` + `roteiro`. Nenhuma camada conhece token, base URL,
SQLite ou `geocoder2`.

---

## Como rodar

```bash
flutter pub get
flutter analyze
flutter test
```

### Web (demo)

O `google_maps_flutter_web` **não injeta** o script do Maps: edite
`example/web/index.html` e troque `YOUR_GOOGLE_MAPS_API_KEY` por uma chave com
**Maps JavaScript API** habilitada (restrita por HTTP referrer).

```bash
cd example
flutter pub get
flutter run -d chrome
# ou
flutter build web
```

No Web o layout do BackOffice aparece por padrão e o botão **Alterar
coordenadas** do painel lateral fica disponível.

### Android (demo)

Troque `YOUR_GOOGLE_MAPS_API_KEY` no `example/android/app/src/main/AndroidManifest.xml`.
O layout do Gestão aparece por padrão; a alteração de coordenada fica desligada.

---

## Uso nos apps

### Dependência

O pacote é consumido por Git, com o commit fixado — o mesmo padrão do `roteiro`:

```yaml
dependencies:
  atendimento:
    git:
      url: https://github.com/allebarrosm/atendimento-componente
      ref: 6d0b93bce4e7cd43a2359ec6d96386ba06f180f4
```

**Gestão e BackOffice já estão configurados assim.** Para atualizar o pacote,
basta trocar o `ref` por um commit/tag novo e rodar `flutter pub get`.

O pacote depende do **mesmo ref do `roteiro`** que os apps usam, então o pub
trata como a mesma origem e não é preciso `dependency_overrides`. Para
desenvolver os dois juntos, crie um `pubspec_overrides.yaml`:

```yaml
dependency_overrides:
  roteiro:
    path: ../roteiro
  atendimento:
    path: ../atendimento
```

### 1. Implemente o transporte (uma vez por app)

O pacote não fala HTTP. Cada app adapta o seu `ServiceRemoteDataSource`.
**Isso já foi feito neste repositório:**

- `Gestao/lib/src/screens/monitoramento/atendimento/infra/atendimento_api_gestao.dart`
- `BackOffice/lib/infra/repositores/service/atendimento_api_backoffice.dart`

O exemplo abaixo é o mesmo código, para referência:

```dart
class GestaoAtendimentoApi implements AtendimentoApi {
  final ServiceRemoteDataSource _dataSource = ServiceRemoteDataSource();

  // O ApiHelper do Gestão adiciona o `$` sozinho em getOData; o pacote manda
  // `$filter`/`$orderby`. Aqui só tiramos o `$`.
  Map<String, String?> _withoutDollar(Map<String, String> params) =>
      params.map((key, value) => MapEntry(key.replaceFirst(r'$', ''), value));

  @override
  Future<AtendimentoResponse> getServices(Map<String, String> params) async {
    final response = await _dataSource.getAllServices(_withoutDollar(params));
    return _map(response);
  }

  @override
  Future<AtendimentoResponse> getClientsWithoutService(
      Map<String, String> params) async {
    final response =
        await _dataSource.getAllClientsNotServices(_withoutDollar(params));
    return _map(response);
  }

  @override
  Future<AtendimentoResponse> getStatistics(Map<String, String> params) async {
    final response = await _dataSource.getStatistics(params);
    return _map(response);
  }

  @override
  Future<AtendimentoResponse> updateClientCoordinate(
      Map<String, String> params) async {
    final response = await _dataSource.updateClientCoord(params);
    return _map(response);
  }

  AtendimentoResponse _map(ResponseHTTP response) => response.sucesso
      ? AtendimentoResponse.ok(response.body)
      : AtendimentoResponse.failure(response.messageError);
}
```

No BackOffice é a mesma coisa com `Api.get/post` (o `_fixParams` já usa os nomes
OData com `$`, então repasse direto).

### 2. Crie o store

```dart
final store = AtendimentoStore(
  repository: AtendimentoRepository(
    BackOfficeAtendimentoApi(),
    // Opcional: sem geocoder o pacote não tenta buscar coordenada.
    geocoder: (address) async {
      final geo = await Geocoder2.getDataFromAddress(
        address: address,
        googleMapApiKey: ParametrosChaves.keyMap,
      );
      return geo == null ? null : GeoPoint(geo.latitude, geo.longitude);
    },
  ),
  // Só o Web liga a alteração de coordenada.
  enableCoordinateEditing: kIsWeb,
  onError: (message) => ToastEvent.showError(message),
);

await store.load(
  start: filtro.dataInicial,
  end: filtro.dataFinal,
  agentCode: filtro.representanteId,
  agentNameValue: filtro.representanteNome,
  supervisorCode: filtro.supervisorId,
  type: filtro.tipoAtendimento,
  modalityValue: filtro.modalidade,
  // Vazio / Atendidos / Não Atendidos (padrão: Vazio).
  agendamentosFilter: AgendamentosFiltro.fromLabel(filtro.agendamentos),
);
```

### Filtro "Agendamentos"

| Opção | Endpoints | O que aparece |
|---|---|---|
| **Vazio** | `GetOData` + `GetClientesSemAtendimento` | atendimentos (clientes não atendidos só com o interruptor ligado) |
| **Atendidos** | só `GetOData` | atendimentos |
| **Não Atendidos** | só `GetClientesSemAtendimento` | clientes não atendidos |

O interruptor **Cliente sem agenda** nasce **desmarcado**: as linhas de
`GetClientesSemAtendimento` (situação `NaoVisitadoSemAgenda`) são carregadas,
mas só entram no mapa/grade quando o usuário o marca. A exceção é o filtro
**"Não Atendidos"**, que o liga sozinho — nesse modo a lista inteira é de
clientes sem agenda e viria vazia sem ele.

O endpoint devolve **uma linha por dia** do período (`Id` repetido, porque é o
id do cliente). Por isso:

- `store.rows` (lista/grade) tem uma linha por dia — 22 clientes × 25 dias = 550
  linhas, mesmo que o `Id` se repita;
- `store.markers` tem **um pino por cliente** (22), já que 25 pinos no mesmo
  ponto não mostrariam nada diferente.

### 3. Encaixe a tela

```dart
// Android: layout do Gestão; Web: layout do BackOffice.
AtendimentoBody(store: store)

// Ou, para forçar/testar:
AtendimentoBody(store: store, layout: AtendimentoLayout.mobile)
AtendimentoBody(store: store, layout: AtendimentoLayout.web)

// Com a grade do próprio BackOffice (GridSync):
AtendimentoBody(
  store: store,
  layout: AtendimentoLayout.web,
  gridBuilder: (context, rows) => GridSync(
    names: store.names,
    gridSource: meuDataSource,
    isLoadingMore: store.loadingMore,
  ),
)
```

O `AtendimentoBody` **não tem `Scaffold`**: o app mantém abas, menu e o diálogo de
filtro de período/representante, chamando `store.load(...)` como hoje.

### 4. Alteração de coordenada (Web)

Ligada por `enableCoordinateEditing: kIsWeb`, **sem botão de alternar**: no Web
já nasce ativa, no Android nunca é possível alterar. O fluxo:

1. os pinos de cliente ficam arrastáveis e mantêm o ícone da situação;
2. ao arrastar um pino, abre a barra sobre o mapa com endereço, coordenada e
   **Salvar/Cancelar** (o mapa continua interativo);
3. o botão **Localizar** geocodifica o endereço digitado;
4. `Salvar` chama `POST /api/endereco/cordenadas` e atualiza a lista/marcadores.

No Android `saveCoordinate()` é bloqueado e os pinos não arrastam.

---

## Decisões

| Tema | Decisão |
|---|---|
| Escopo | só Gestão + BackOffice (EASYMART registra, não monitora) |
| Layout | Android = Gestão; Web = BackOffice (detectado por `kIsWeb`), com a barra de legenda/filtros embaixo do mapa |
| Edição de coordenada | **sempre ativa no Web**, sempre bloqueada no Android (sem botão) |
| Estado | MobX (como os apps) |
| Mapa | reaproveita `RoteiroMap` do pacote `roteiro` |
| Filtro | situação **e** modalidade; "fora do cliente" é categoria própria |
| Coordenada | `GeoPoint` (normaliza, descarta `(0,0)` e lixo) |
| Espalhamento de pinos | determinístico |
| OData | nomes finais (`$filter`), com escape de `'` |
| Geocoder | injetado pelo app; sem ele, nada é geocodificado |
| Tela | **não** faz parte do pacote além do `AtendimentoBody` |

---

## Limitações conhecidas

- **Grade**: a do pacote é uma `DataTable` simples; o BackOffice deve injetar o
  `GridSync` dele por `gridBuilder` (exportação Excel continua no app).
- **Estatísticas**: dependem do endpoint `LstAtendimento/Estatisticas`; se
  falhar, a tela continua com zeros.
- **Sem drag no Android**: é decisão de produto (regra do pacote).
- **Testes de mapa**: cobrem núcleo/repositório/store; a renderização do Google
  Maps exige chave e é validada manualmente.
- **`pubspec.lock` do BackOffice**: hoje resolve `latlong2 0.8.2` e
  `flutter_floating_map_marker_titles_core 0.3.0`, versões anteriores às que o
  `roteiro` declara. Ao migrar a tela, vale regenerar o lock
  (`flutter pub get`) para alinhar com `latlong2 0.9.x` e `core 1.2.x`.

## Migração (feita)

As duas telas já usam o pacote:

- **Gestão** (`AtendimentoView`): renderiza `AtendimentoBody(layout: mobile)`.
  O app mantém o diálogo de período/representante (`FilterAtendimento`), que
  agora chama `store.load(...)`, e o atalho da barra para os interruptores.
- **BackOffice** (`MonitoringPage`): a aba de atendimento usa
  `AtendimentoBody(layout: web)` com a grade Syncfusion injetada por
  `gridBuilder` (`AtendimentoGridSync`), mantendo as 11 colunas e a exportação.

Removidos dos apps (agora vivem aqui): `ServiceData`, `ServiceStatisticData`,
`ClientCoordinateData`, `ServiceRepositoryImpl`, `GetAllServices`, os stores
antigos (`AtendimentoStore` do Gestão, `GridViewWithMapStore` +
`VariablesStore` do BackOffice), os cards/filtros/painel de estatísticas e as
cópias de `toJsonView`/`filterText`/`getIcon`.

O que continua no app: transporte HTTP (`ServiceRemoteDataSource`), diálogo de
filtro de período/representante, exportação Excel do BackOffice e o cabeçalho
das páginas.

## Próximos passos sugeridos

1. Trocar o `ref` do Git nos dois `pubspec.yaml` conforme o pacote evoluir.
2. No BackOffice, regenerar o `pubspec.lock` para alinhar `latlong2` e
   `flutter_floating_map_marker_titles_core` com o que o `roteiro` declara.
3. Levar o teste de integração do mapa (chave/dispositivo) para o CI.
