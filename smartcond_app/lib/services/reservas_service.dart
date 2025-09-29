import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';
import 'auth_service.dart';

class ReservasService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();

  // Obtener token de autenticación
  Future<String?> _getAuthToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Headers con autenticación
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Método genérico para hacer peticiones HTTP con refresh automático de tokens
  Future<http.Response> _makeAuthenticatedRequest(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    // Obtener headers con token actual
    final requestHeaders = headers ?? await _getHeaders();

    // Hacer la petición inicial
    http.Response response;
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: requestHeaders);
        break;
      case 'POST':
        response = await http.post(url, headers: requestHeaders, body: body);
        break;
      case 'PUT':
        response = await http.put(url, headers: requestHeaders, body: body);
        break;
      case 'DELETE':
        response = await http.delete(url, headers: requestHeaders);
        break;
      default:
        throw UnsupportedError('HTTP method $method not supported');
    }

    // Si obtenemos 401, intentar refrescar el token y reintentar
    if (response.statusCode == 401) {
      print('🔄 Token expirado, intentando refresh...');
      final refreshSuccess = await _authService.refreshToken();

      if (refreshSuccess) {
        print('✅ Token refrescado, reintentando petición...');
        // Obtener nuevos headers con el token refrescado
        final newHeaders = await _getHeaders();

        // Reintentar la petición con el nuevo token
        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(url, headers: newHeaders);
            break;
          case 'POST':
            response = await http.post(url, headers: newHeaders, body: body);
            break;
          case 'PUT':
            response = await http.put(url, headers: newHeaders, body: body);
            break;
          case 'DELETE':
            response = await http.delete(url, headers: newHeaders);
            break;
        }
      } else {
        print('❌ No se pudo refrescar el token');
        // Si no se pudo refrescar, devolver la respuesta original con 401
      }
    }

    return response;
  }

  // Obtener todas las áreas comunes disponibles
  Future<Map<String, dynamic>> getAreasComunes() async {
    try {
      final response = await _makeAuthenticatedRequest(
        'GET',
        Uri.parse('${Config.baseUrl}/api/reservations/areas/'),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al obtener áreas comunes: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener disponibilidad de un área común para una fecha específica
  Future<Map<String, dynamic>> getDisponibilidad(
    int areaId,
    String fecha,
  ) async {
    try {
      final response = await _makeAuthenticatedRequest(
        'GET',
        Uri.parse(
          '${Config.baseUrl}/api/reservations/areas/$areaId/disponibilidad/?fecha=$fecha',
        ),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al obtener disponibilidad: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Crear una nueva reserva
  Future<Map<String, dynamic>> crearReserva(
    int areaId,
    Map<String, dynamic> datosReserva,
  ) async {
    try {
      final response = await _makeAuthenticatedRequest(
        'POST',
        Uri.parse('${Config.baseUrl}/api/reservations/areas/$areaId/reservar/'),
        body: json.encode(datosReserva),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al crear reserva: ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener reservas del usuario
  Future<Map<String, dynamic>> getMisReservas() async {
    try {
      final response = await _makeAuthenticatedRequest(
        'GET',
        Uri.parse('${Config.baseUrl}/api/reservations/reservas/mis_reservas/'),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al obtener mis reservas: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Cancelar una reserva
  Future<Map<String, dynamic>> cancelarReserva(
    int reservaId,
    String motivo,
  ) async {
    try {
      final response = await _makeAuthenticatedRequest(
        'POST',
        Uri.parse(
          '${Config.baseUrl}/api/reservations/reservas/$reservaId/cancelar/',
        ),
        body: json.encode({'motivo': motivo}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al cancelar reserva: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Confirmar pago de reserva
  Future<Map<String, dynamic>> confirmarPagoReserva(
    int reservaId,
    Map<String, dynamic> datosPago,
  ) async {
    try {
      final response = await _makeAuthenticatedRequest(
        'POST',
        Uri.parse(
          '${Config.baseUrl}/api/reservations/reservas/$reservaId/confirmar/',
        ),
        body: json.encode(datosPago),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al confirmar pago: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener horarios disponibles para un área y fecha específica (usa el mismo endpoint que getDisponibilidad)
  Future<Map<String, dynamic>> getHorariosDisponibles(
    int areaId,
    String fecha,
  ) async {
    // Este método usa el mismo endpoint que getDisponibilidad
    return getDisponibilidad(areaId, fecha);
  }
}
