import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';

class AuthService {
  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String username, String password) async {
  try {
    print('🌐 Conectando a: ${Config.tokenUrl}');
    
    final response = await http.post(
      Uri.parse(Config.tokenUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Guardar tokens JWT
      await storage.write(key: 'access_token', value: data['access']);
      await storage.write(key: 'refresh_token', value: data['refresh']);
      
      print('✅ Login exitoso, obteniendo perfil de usuario...');
      
      // Obtener perfil del usuario para saber el tipo
      final profileResponse = await getProfile();
      if (profileResponse['success']) {
        final userData = profileResponse['data'];
        await storage.write(key: 'user_type', value: userData['role'] ?? 'resident');
        await storage.write(key: 'user_id', value: userData['id'].toString());
        await storage.write(key: 'username', value: userData['username']);
        
        print('👤 Usuario: ${userData['username']}, Rol: ${userData['role']}');
        return {'success': true, 'data': userData};
      }
      
      return {'success': true, 'data': data};
    } else {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['detail'] ?? 'Error de autenticación';
      print('❌ Error de login: $errorMessage');
      return {'success': false, 'error': errorMessage};
    }
  } catch (e) {
    print('❌ Excepción de login: $e');
    return {'success': false, 'error': 'Error de conexión: $e'};
  }
}

Future<Map<String, dynamic>> getProfile() async {
  try {
    final token = await storage.read(key: 'access_token');
    
    if (token == null) {
      return {'success': false, 'error': 'No hay token disponible'};
    }

    final response = await http.get(
      Uri.parse(Config.userProfileUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'error': 'Error al obtener perfil: ${response.statusCode}'};
    }
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}

  Future<void> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    await storage.delete(key: 'user_type');
  }

  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'access_token');
    return token != null;
  }

  Future<String?> getUserType() async {
    return await storage.read(key: 'user_type');
  }

  Future<bool> isAdmin() async {
    final userType = await getUserType();
    return userType == 'admin';
  }

  Future<bool> isResident() async {
    final userType = await getUserType();
    return userType == 'resident';
  }

  Future<bool> isSecurity() async {
    final userType = await getUserType();
    return userType == 'security';
  }
}