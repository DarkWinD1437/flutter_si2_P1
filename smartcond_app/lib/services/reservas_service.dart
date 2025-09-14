import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReservasService {
  static const String baseUrl =
      'https://smart-condominium-backend.onrender.com';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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

  // Obtener todas las áreas comunes disponibles
  Future<Map<String, dynamic>> getAreasComunes() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/reservations/areas-comunes/'),
        headers: headers,
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
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/reservations/disponibilidad/$areaId/$fecha/'),
        headers: headers,
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
    Map<String, dynamic> datosReserva,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/reservations/reservas/'),
        headers: headers,
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
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/reservations/mis-reservas/'),
        headers: headers,
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
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/reservations/reservas/$reservaId/cancelar/'),
        headers: headers,
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
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/reservations/reservas/$reservaId/pagar/'),
        headers: headers,
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

  // Obtener horarios disponibles para un área y fecha específica
  Future<Map<String, dynamic>> getHorariosDisponibles(
    int areaId,
    String fecha,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/reservations/horarios-disponibles/$areaId/$fecha/',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al obtener horarios: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
}
