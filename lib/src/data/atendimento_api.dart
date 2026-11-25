import 'package:roteiro/core.dart' show GeoPoint;

/// Resposta crua da API, independente do cliente HTTP de cada app.
class AtendimentoResponse {
  const AtendimentoResponse({
    required this.success,
    this.body,
    this.errorMessage,
  });

  const AtendimentoResponse.ok(this.body)
      : success = true,
        errorMessage = null;

  const AtendimentoResponse.failure(this.errorMessage)
      : success = false,
        body = null;

  final bool success;

  /// Corpo já decodificado como texto JSON.
  final String? body;

  final String? errorMessage;
}

/// Transporte usado pelo `AtendimentoRepository`.
///
/// Cada app implementa em poucas linhas em cima do seu `ApiHelper`/`Api`. O
/// pacote não conhece token, base URL nem OData: só recebe os parâmetros já
/// montados por `AtendimentoQuery`.
abstract class AtendimentoApi {
  /// `GET /api/LstClienteAtendimento/GetOData`.
  Future<AtendimentoResponse> getServices(Map<String, String> params);

  /// `GET /api/LstClienteAtendimento/GetClientesSemAtendimento`.
  Future<AtendimentoResponse> getClientsWithoutService(
    Map<String, String> params,
  );

  /// `GET /api/LstAtendimento/Estatisticas`.
  Future<AtendimentoResponse> getStatistics(Map<String, String> params);

  /// `POST /api/endereco/cordenadas`.
  Future<AtendimentoResponse> updateClientCoordinate(
    Map<String, String> params,
  );
}

/// Resultado simples com mensagem de erro, no formato que os apps já usam.
class AtendimentoResult<T> {
  const AtendimentoResult.success(this.value) : errorMessage = null;

  const AtendimentoResult.error(this.errorMessage) : value = null;

  final T? value;
  final String? errorMessage;

  bool get isSuccess => errorMessage == null;
}

/// Converte um endereço em coordenada (Geocoder2 nos apps).
typedef AtendimentoGeocoder = Future<GeoPoint?> Function(String address);
