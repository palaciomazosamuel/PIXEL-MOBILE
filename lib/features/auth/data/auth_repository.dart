import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_token_storage.dart';

class AuthRepository {
  const AuthRepository({required this.apiClient, required this.tokenStorage});

  final ApiClient apiClient;
  final SecureTokenStorage tokenStorage;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (!AppConfig.hasApiBaseUrl) {
      throw const AuthException(
        'Falta configurar PIXEL_API_URL para conectar con el backend.',
      );
    }

    try {
      final response = await apiClient.dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: {'correo': email, 'contrasena': password},
      );
      final data = response.data ?? <String, dynamic>{};
      final token = _extractToken(data);
      final user = _extractMap(data, 'usuario');

      if (token == null || token.isEmpty) {
        throw const AuthException(
          'Login recibido, pero no se encontró el token en la respuesta.',
        );
      }

      await tokenStorage.saveToken(token);

      final permisos = await apiClient.dio.get<Map<String, dynamic>>(
        '/api/auth/me/permisos',
      );
      final permissionsPayload = permisos.data ?? <String, dynamic>{};
      final permissionsData =
          _extractMap(permissionsPayload, 'data') ?? permissionsPayload;

      if (!_hasAdminPermission(permissionsData)) {
        await tokenStorage.clear();
        throw const AuthException(
          'Este acceso móvil está reservado para administradores.',
        );
      }

      return <String, dynamic>{
        ...?user,
        'permisos': permissionsData['permisos'] ?? const [],
        'codigos': permissionsData['codigos'] ?? const [],
      };
    } on DioException catch (error) {
      throw AuthException(_messageFromDio(error));
    }
  }

  Future<void> logout() => tokenStorage.clear();

  Future<void> forgotPassword({required String email}) async {
    if (!AppConfig.hasApiBaseUrl) {
      throw const AuthException(
        'Falta configurar PIXEL_API_URL para conectar con el backend.',
      );
    }

    try {
      await apiClient.dio.post<Map<String, dynamic>>(
        '/api/auth/forgot-password',
        data: {'correo': email},
      );
    } on DioException catch (error) {
      throw AuthException(_messageFromDio(error));
    }
  }

  String? _extractToken(Map<String, dynamic> data) {
    for (final key in ['token', 'accessToken', 'jwt']) {
      final value = data[key];
      if (value is String) return value;
    }

    final nestedData = data['data'];
    if (nestedData is Map<String, dynamic>) return _extractToken(nestedData);

    return null;
  }

  Map<String, dynamic>? _extractMap(Map<String, dynamic> data, String key) {
    final direct = data[key];
    if (direct is Map<String, dynamic>) return direct;

    final nestedData = data['data'];
    if (nestedData is Map<String, dynamic>) return _extractMap(nestedData, key);

    return null;
  }

  bool _hasAdminPermission(Map<String, dynamic> data) {
    final codes = data['codigos'] ?? data['permisos'];
    if (codes is List) {
      return codes
          .map((item) => item.toString().toLowerCase())
          .any(
            (code) =>
                code == 'dashboard.admin' || code.startsWith('dashboard.'),
          );
    }

    final text = data.toString().toLowerCase();
    return text.contains('dashboard.admin') ||
        text.contains('admin') ||
        text.contains('administrador');
  }

  String _messageFromDio(DioException error) {
    final status = error.response?.statusCode;
    if (status == 401) return 'Credenciales inválidas o sesión no autorizada.';
    if (status == 403) return 'El usuario no tiene permisos de administrador.';
    if (status != null) return 'Error del backend PIXEL. Código HTTP $status.';
    return 'No se pudo conectar con la API de PIXEL.';
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
