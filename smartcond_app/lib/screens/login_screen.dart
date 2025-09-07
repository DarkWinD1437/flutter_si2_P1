import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../config.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  String? _error;
  bool _isLoading = false;
  bool _debugMode = true; // Cambiar a false en producción

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn && mounted) {
      _navigateToDashboard();
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        print('🔐 Intentando login con: ${_usernameController.text}');
        
        final result = await _authService.login(
          _usernameController.text,
          _passwordController.text,
        );

        if (!mounted) return;

        if (result['success']) {
          print('✅ Login exitoso');
          _navigateToDashboard();
        } else {
          print('❌ Error de login: ${result['error']}');
          setState(() {
            _error = _parseError(result['error']);
          });
        }
      } catch (e) {
        print('❌ Excepción: $e');
        setState(() {
          _error = 'Error de conexión. Verifica la configuración.';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _navigateToDashboard() async {
    final userType = await _authService.getUserType();
    
    if (userType == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin');
    } else if (userType == 'resident') {
      Navigator.pushReplacementNamed(context, '/resident');
    } else if (userType == 'security') {
      Navigator.pushReplacementNamed(context, '/security');
    } else {
      Navigator.pushReplacementNamed(context, '/resident');
    }
  }

  String _parseError(dynamic error) {
    if (error is Map) {
      if (error.containsKey('detail')) {
        return error['detail'].toString();
      } else if (error.containsKey('non_field_errors')) {
        return error['non_field_errors'][0].toString();
      } else if (error is Map<String, dynamic>) {
        final firstError = error.values.first;
        if (firstError is List) return firstError.first.toString();
        return firstError.toString();
      }
    }
    return error.toString();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔗 Probando conexión con: ${Config.tokenUrl}');
      
      final response = await http.get(
        Uri.parse(Config.tokenUrl.replaceAll('/token/', '/')),
        headers: {'Accept': 'application/json'},
      );

      print('📊 Status code: ${response.statusCode}');
      print('📄 Response: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');

      if (response.statusCode == 200 || response.statusCode == 401) {
        setState(() {
          _error = 'Conexión exitosa. Endpoint encontrado.';
        });
      } else if (response.body.contains('<!DOCTYPE') || response.body.contains('<html>')) {
        setState(() {
          _error = 'Error: El servidor devuelve HTML. ¿URL correcta?';
        });
      } else {
        setState(() {
          _error = 'Error inesperado: Código ${response.statusCode}';
        });
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      setState(() {
        _error = 'Error de conexión: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade300],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icono de la app
                  Icon(
                    Icons.security_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Smart Cond',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sistema de Condominio Inteligente',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Tarjeta de login
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_error != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, 
                                        color: Colors.red.shade700, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: TextStyle(
                                          color: Colors.red.shade800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Campo de usuario
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Usuario',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 12,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese su usuario';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Campo de contraseña
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 12,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese su contraseña';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Botón de login
                            ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),

                            // Información de debug
                            if (_debugMode) ...[
                              const SizedBox(height: 20),
                              Divider(),
                              const SizedBox(height: 8),
                              Text(
                                'Información de Depuración',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Endpoint: ${Config.tokenUrl}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: _testConnection,
                                child: Text('Probar Conexión'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Información adicional
                  const SizedBox(height: 24),
                  Text(
                    '¿Necesitas ayuda? Contacta al administrador',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}