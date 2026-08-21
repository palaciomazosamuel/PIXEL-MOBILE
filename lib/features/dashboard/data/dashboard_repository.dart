import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';

class DashboardRepository {
  const DashboardRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<Map<String, dynamic>> getAdminDashboard() async {
    if (!AppConfig.hasApiBaseUrl) {
      throw const DashboardException(
        'Falta configurar PIXEL_API_URL para consultar el dashboard.',
      );
    }

    try {
      final response = await apiClient.dio.get<Map<String, dynamic>>(
        '/api/dashboard/admin',
        queryParameters: {'anio': DateTime.now().year, 'ultimos': 5},
      );
      final payload = response.data ?? <String, dynamic>{};
      final data = payload['data'];
      return data is Map<String, dynamic> ? data : payload;
    } on DioException catch (error) {
      final message = error.response?.data is Map
          ? (error.response?.data as Map)['message']?.toString()
          : null;
      throw DashboardException(
        message ?? 'No se pudo cargar /api/dashboard/admin.',
      );
    }
  }
}

class DashboardException implements Exception {
  const DashboardException(this.message);

  final String message;

  @override
  String toString() => message;
}
