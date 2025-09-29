import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/resident_dashboard.dart';
import 'screens/security_dashboard.dart';
import 'screens/finanzas_screen.dart';
import 'screens/comunicaciones_screen.dart';
import 'screens/reservas_screen.dart';
import 'screens/seguridad_residente_screen.dart';
import 'screens/seguridad_guard_screen.dart';
import 'screens/estado_cuenta_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notificaciones_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Condominium',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/admin': (context) => AdminDashboard(),
        '/resident': (context) => ResidentDashboard(),
        '/security': (context) => SecurityDashboard(),
        '/finanzas': (context) => FinanzasScreen(),
        '/comunicados': (context) => ComunicacionesScreen(),
        '/reservas': (context) => ReservasScreen(),
        '/seguridad': (context) => SeguridadResidenteScreen(),
        '/seguridad_guard': (context) => SeguridadGuardScreen(),
        '/estado_cuenta': (context) => EstadoCuentaScreen(),
        '/profile': (context) => ProfileScreen(),
        '/notificaciones': (context) => NotificacionesScreen(),
        // Rutas adicionales para el dashboard de seguridad
        '/dashboard': (context) => SecurityDashboard(),
      },
    );
  }
}
