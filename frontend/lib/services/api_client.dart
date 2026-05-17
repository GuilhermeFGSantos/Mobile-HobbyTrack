import 'package:dio/dio.dart';
import 'auth_store.dart';

class ApiClient {
  static final Dio dio = _createDio();

  static Dio _createDio() {
    final d = Dio(BaseOptions(
      baseUrl: 'http://localhost:3000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    d.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthStore.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));

    return d;
  }
}

String apiError(dynamic e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (e.response?.statusCode == 401) return 'Sessão expirada. Faça login novamente.';
    if (e.response?.statusCode == 404) return 'Recurso não encontrado.';
    if (e.response?.statusCode != null) {
      return 'Erro ${e.response!.statusCode}. Tente novamente.';
    }
    return 'Sem conexão com o servidor.';
  }
  return 'Erro inesperado. Tente novamente.';
}
