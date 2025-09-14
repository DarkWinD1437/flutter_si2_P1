import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';

class ProfileService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'No hay token disponible'};
      }

      final Map<String, dynamic> data = {};
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;

      if (data.isEmpty) {
        return {'success': false, 'error': 'No hay datos para actualizar'};
      }

      print('📤 Actualizando perfil con datos: $data');

      final response = await http
          .put(
            Uri.parse(Config.updateProfileUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 10));

      print('📊 Respuesta actualización perfil: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Perfil actualizado exitosamente');
        return {
          'success': true,
          'message': 'Perfil actualizado exitosamente',
          'user': responseData['user'],
        };
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ??
            errorData['error'] ??
            'Error al actualizar perfil';
        print('❌ Error al actualizar perfil: $errorMessage');
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      print('❌ Excepción al actualizar perfil: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'No hay token disponible'};
      }

      final data = {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };

      print('🔐 Cambiando contraseña...');

      final response = await http
          .post(
            Uri.parse(Config.changePasswordUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 10));

      print('📊 Respuesta cambio contraseña: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Contraseña cambiada exitosamente');
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Contraseña cambiada exitosamente',
        };
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ??
            errorData['error'] ??
            'Error al cambiar contraseña';
        print('❌ Error al cambiar contraseña: $errorMessage');
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      print('❌ Excepción al cambiar contraseña: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  Future<String?> _getToken() async {
    try {
      return await _storage.read(key: 'access_token');
    } catch (e) {
      print('❌ Error al obtener token: $e');
      return null;
    }
  }

  // Métodos para estado de cuenta
  Future<Map<String, dynamic>> getEstadoCuenta() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'No hay token disponible'};
      }

      print('📊 Consultando estado de cuenta propio...');

      final response = await http
          .get(
            Uri.parse('${Config.baseUrl}/api/finances/cargos/estado_cuenta/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('📊 Respuesta estado de cuenta: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Estado de cuenta obtenido exitosamente');
        return {'success': true, 'data': responseData};
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ??
            errorData['error'] ??
            'Error al consultar estado de cuenta';
        print('❌ Error al consultar estado de cuenta: $errorMessage');
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      print('❌ Excepción al consultar estado de cuenta: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> getEstadosCuentaUsuarios({
    String? search,
    String? estado,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'No hay token disponible'};
      }

      print('📊 Consultando estados de cuenta de usuarios...');

      // Construir URL con parámetros de búsqueda
      String url =
          '${Config.baseUrl}/api/finances/cargos/estados_cuenta_usuarios/';
      final queryParams = <String, String>{};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (estado != null && estado != 'todos') {
        queryParams['estado'] = estado;
      }

      if (queryParams.isNotEmpty) {
        url +=
            '?' +
            queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      }

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('📊 Respuesta estados de cuenta usuarios: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Estados de cuenta de usuarios obtenidos exitosamente');
        return {'success': true, 'data': responseData};
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ??
            errorData['error'] ??
            'Error al consultar estados de cuenta de usuarios';
        print(
          '❌ Error al consultar estados de cuenta de usuarios: $errorMessage',
        );
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      print('❌ Excepción al consultar estados de cuenta de usuarios: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> getEstadoCuentaUsuario(int userId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'No hay token disponible'};
      }

      print('📊 Consultando estado de cuenta de usuario $userId...');

      final response = await http
          .get(
            Uri.parse(
              '${Config.baseUrl}/api/finances/cargos/estado_cuenta/$userId/',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('📊 Respuesta estado de cuenta usuario: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Estado de cuenta de usuario obtenido exitosamente');
        return {'success': true, 'data': responseData};
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ??
            errorData['error'] ??
            'Error al consultar estado de cuenta de usuario';
        print(
          '❌ Error al consultar estado de cuenta de usuario: $errorMessage',
        );
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      print('❌ Excepción al consultar estado de cuenta de usuario: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
}
