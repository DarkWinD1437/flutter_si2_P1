import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';

class ComunicacionesService {
  static const String baseUrl = Config.baseUrl;
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

  // Obtener avisos y comunicados de la administración
  Future<Map<String, dynamic>> getAvisos({Map<String, String>? filtros}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '$baseUrl/api/communications/avisos/',
      ).replace(queryParameters: filtros);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Error al obtener avisos: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener dashboard de avisos
  Future<Map<String, dynamic>> getDashboardAvisos() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/communications/avisos/dashboard/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Error al obtener dashboard: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener avisos no leídos
  Future<Map<String, dynamic>> getAvisosNoLeidos() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/communications/avisos/no-leidos/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Error al obtener avisos no leídos: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Crear nuevo aviso (solo administradores)
  Future<Map<String, dynamic>> crearAviso(
    Map<String, dynamic> avisoData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/communications/avisos/'),
        headers: headers,
        body: json.encode(avisoData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error':
              errorData['detail'] ??
              'Error al crear aviso: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Actualizar aviso
  Future<Map<String, dynamic>> actualizarAviso(
    int avisoId,
    Map<String, dynamic> avisoData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/api/communications/avisos/$avisoId/'),
        headers: headers,
        body: json.encode(avisoData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error':
              errorData['detail'] ??
              'Error al actualizar aviso: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Publicar aviso
  Future<Map<String, dynamic>> publicarAviso(int avisoId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/communications/avisos/$avisoId/publicar/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error':
              errorData['detail'] ??
              'Error al publicar aviso: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Archivar aviso
  Future<Map<String, dynamic>> archivarAviso(int avisoId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/communications/avisos/$avisoId/archivar/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error':
              errorData['detail'] ??
              'Error al archivar aviso: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Eliminar aviso
  Future<Map<String, dynamic>> eliminarAviso(int avisoId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/communications/avisos/$avisoId/'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        return {'success': true, 'message': 'Aviso eliminado exitosamente'};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error':
              errorData['detail'] ??
              'Error al eliminar aviso: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener detalle de un aviso específico (automáticamente marca como leído)
  Future<Map<String, dynamic>> getDetalleAviso(int avisoId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/communications/aviso/$avisoId/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Error al obtener detalle del aviso: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Marcar aviso como leído
  Future<Map<String, dynamic>> marcarComoLeido(int avisoId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/communications/avisos/$avisoId/marcar_leido/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Error al marcar como leído: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener comentarios de un aviso
  Future<Map<String, dynamic>> getComentariosAviso(int avisoId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/communications/avisos/$avisoId/comentarios/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Error al obtener comentarios: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Agregar comentario a un aviso
  Future<Map<String, dynamic>> agregarComentario(
    int avisoId,
    String contenido, {
    int? respuestaA,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'contenido': contenido,
        if (respuestaA != null) 'es_respuesta': respuestaA,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/communications/avisos/$avisoId/comentarios/'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error':
              errorData['detail'] ??
              'Error al agregar comentario: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener estadísticas de avisos (solo admin)
  Future<Map<String, dynamic>> getEstadisticasAvisos() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/communications/avisos/estadisticas/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Error al obtener estadísticas: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
}
