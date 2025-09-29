import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/ai_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void _performNavigation(String userType) {
    print('🚀 Ejecutando navegación para tipo: $userType');
    String route;
    if (userType == 'admin') {
      route = '/admin';
    } else if (userType == 'resident') {
      route = '/resident';
    } else if (userType == 'security') {
      route = '/security';
    } else {
      route = '/resident'; // Default fallback
    }
    print('📍 Navegando a ruta: $route');
    try {
      Navigator.pushReplacementNamed(context, route);
      print('✅ Navegación completada exitosamente');
    } catch (e) {
      print('❌ Error en navegación: $e');
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _aiService = AIService();
  final ImagePicker _picker = ImagePicker();

  String? _error;
  bool _isLoading = false;
  bool _isCheckingSession = true; // Nuevo estado para verificar sesión
  bool _isNavigating = false; // Nuevo estado para navegación
  bool _rememberMe = false;
  bool _showPassword = false;
  bool _isFacialLogin = false; // Nuevo estado para modo facial

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    print('�� Verificando sesión existente...');

    try {
      final token = await _authService.storage.read(key: 'access_token');

      if (token == null) {
        print('🔐 No hay token - mostrando login');
        setState(() {
          _isCheckingSession = false;
        });
        return;
      }

      print('🔑 Token encontrado - intentando validación rápida...');

      final isLoggedIn = await _authService.isLoggedIn().timeout(
        const Duration(seconds: 1),
        onTimeout: () {
          print('⏰ Timeout 1s - mostrando login');
          return false;
        },
      );

      if (!mounted) return;

      if (isLoggedIn) {
        print('✅ Sesión válida - navegando al dashboard');
        _navigateToDashboard();
      } else {
        print('❌ Sesión inválida - mostrando login');
        setState(() {
          _isCheckingSession = false;
        });
      }
    } catch (e) {
      print('❌ Error en verificación:  - mostrando login');
      if (mounted) {
        setState(() {
          _isCheckingSession = false;
        });
      }
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔐 Intentando login con: ${_usernameController.text}');

      final result = await _authService
          .login(_usernameController.text, _passwordController.text)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => {'success': false, 'error': 'Timeout de conexión'},
          );

      if (!mounted) return;

      print('📊 Resultado del login: ${result['success']}');

      if (result['success']) {
        print('✅ Login exitoso - iniciando navegación al dashboard');
        setState(() {
          _isLoading = false;
          _isNavigating = true;
        });
        await _navigateToDashboard();
      } else {
        print('❌ Error de login: ${result['error']}');
        setState(() {
          _isLoading = false;
          _error = _parseError(result['error']);
        });
      }
    } catch (e) {
      print('❌ Excepción de login: $e');
      setState(() {
        _isLoading = false;
        _error = 'Error de conexión: $e';
      });
    }
  }

  Future<void> _navigateToDashboard() async {
    try {
      String? userType = await _authService.storage.read(key: 'user_type');
      if (userType == null) {
        final profileResult = await _authService.getProfile();
        print('📊 Resultado del perfil: ${profileResult['success']}');
        if (profileResult['success']) {
          final userData = profileResult['data'];
          userType = userData['role'] ?? 'resident';
          print('🔄 Rol obtenido del perfil: $userType');
          await _authService.storage.write(key: 'user_type', value: userType);
        } else {
          print('❌ Error al obtener perfil: ${profileResult['error']}');
          setState(() {
            _error =
                'No se pudo obtener el perfil del usuario. Verifica tu conexión o credenciales.';
            _isNavigating = false;
          });
          userType = 'resident';
        }
      }
      if (!mounted) return;
      print('✅ Navegando con userType: $userType');
      _performNavigation(userType ?? 'resident');
    } catch (e) {
      print('❌ Error en _navigateToDashboard: $e');
      if (mounted) {
        setState(() {
          _error = 'Error de conexión al navegar: $e';
          _isNavigating = false;
        });
        _performNavigation('resident');
      }
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

  // Método para login facial
  Future<void> _facialLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🤖 Iniciando login facial...');

      // Capturar imagen desde la cámara
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
      );

      if (image == null) {
        setState(() {
          _isLoading = false;
          _error = 'No se capturó ninguna imagen';
        });
        return;
      }

      print('📸 Imagen capturada: ${image.path}');

      // Convertir imagen a base64
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      print('🔄 Imagen convertida a base64 (${base64Image.length} caracteres)');

      // Enviar a backend para reconocimiento facial
      final result = await _aiService
          .loginFacial(base64Image)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => {'success': false, 'error': 'Timeout de conexión'},
          );

      if (!mounted) return;

      print('📊 Resultado login facial: ${result['success']}');

      if (result['success']) {
        print('✅ Login facial exitoso - iniciando navegación al dashboard');
        setState(() {
          _isLoading = false;
          _isNavigating = true;
        });
        await _navigateToDashboard();
      } else {
        print('❌ Error en login facial: ${result['error']}');
        setState(() {
          _isLoading = false;
          _error = result['error'] ?? 'Error en reconocimiento facial';
        });
      }
    } catch (e) {
      print('❌ Excepción en login facial: $e');
      setState(() {
        _isLoading = false;
        _error = 'Error de conexión: $e';
      });
    }
  }

  // Método para alternar entre modos de login
  void _toggleLoginMode() {
    setState(() {
      _isFacialLogin = !_isFacialLogin;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFEF7ED), Color(0xFFFED7AA), Color(0xFFFECACA)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Verificando sesión...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      print('⏭️ Usuario saltó la verificación de sesión');
                      setState(() {
                        _isCheckingSession = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Continuar sin verificar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFEF7ED), Color(0xFFFED7AA), Color(0xFFFECACA)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_rounded, size: 80, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Smart Condominium',
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

                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Color(0xFFFED7AA), width: 1),
                    ),
                    color: Colors.white,
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
                                  color: Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border(
                                    left: BorderSide(
                                      color: Color(0xFFF87171),
                                      width: 4,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Color(0xFFDC2626),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: TextStyle(
                                          color: Color(0xFFDC2626),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Botón para alternar entre modos de login
                            Container(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _toggleLoginMode,
                                icon: Icon(
                                  _isFacialLogin ? Icons.person : Icons.face,
                                  color: Color(0xFFF97316),
                                ),
                                label: Text(
                                  _isFacialLogin
                                      ? 'Cambiar a Login Tradicional'
                                      : 'Cambiar a Login Facial',
                                  style: TextStyle(
                                    color: Color(0xFFF97316),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Color(0xFFF97316),
                                    width: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Mostrar campos de usuario/contraseña solo si no es login facial
                            if (!_isFacialLogin) ...[
                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Usuario',
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Color(0xFFF97316),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Color(0xFFFED7AA),
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Color(0xFFFED7AA),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Color(0xFFF97316),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Color(0xFFFEF7ED),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 12,
                                  ),
                                ),
                                style: TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontWeight: FontWeight.w500,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese su usuario';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_showPassword,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Color(0xFFF97316),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Color(0xFFF97316),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Color(0xFFFED7AA),
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Color(0xFFFED7AA),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Color(0xFFF97316),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Color(0xFFFEF7ED),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 12,
                                  ),
                                ),
                                style: TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontWeight: FontWeight.w500,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese su contraseña';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                        activeColor: Color(0xFFF97316),
                                      ),
                                      Text(
                                        'Recordarme',
                                        style: TextStyle(
                                          color: Color(0xFF374151),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Funcionalidad próximamente',
                                          ),
                                          backgroundColor: Color(0xFFF97316),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      '¿Olvidaste tu contraseña?',
                                      style: TextStyle(
                                        color: Color(0xFFF97316),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),
                            ],

                            // Mostrar instrucciones para login facial
                            if (_isFacialLogin) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFEF7ED),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(0xFFFED7AA),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.face,
                                      size: 48,
                                      color: Color(0xFFF97316),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Login Facial con IA',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Coloque su rostro frente a la cámara y presione el botón para iniciar sesión.',
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFD97706),
                                    Color(0xFFEA580C),
                                    Color(0xFFDC2626),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: (_isLoading || _isNavigating)
                                    ? null
                                    : (_isFacialLogin ? _facialLogin : _login),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading || _isNavigating
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    Colors.white,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            _isNavigating
                                                ? 'Navegando...'
                                                : (_isFacialLogin
                                                      ? 'Procesando rostro...'
                                                      : 'Iniciando sesión...'),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _isFacialLogin
                                                ? Icons.face
                                                : Icons.login,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _isFacialLogin
                                                ? 'Iniciar Sesión Facial'
                                                : 'Iniciar Sesión',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFFED7AA), width: 1),
                      ),
                    ),
                    child: Text(
                      '© 2025 Smart Condominium - Sistema de Gestión Inteligente by DarkWinD',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                      textAlign: TextAlign.center,
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
