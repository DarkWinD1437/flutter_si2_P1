import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/sidebar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AuthService _authService = AuthService();
  String _userName = '';
  String _userRole = 'Administrador';
  bool _isLoading = true;
  String _selectedSidebar = 'admin';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Primero intentar obtener datos del storage
      final username = await _authService.storage.read(key: 'username');
      final userType = await _authService.storage.read(key: 'user_type');

      if (username != null) {
        setState(() {
          _userName = username;
          _userRole = _getRoleDisplayName(userType ?? 'admin');
          _isLoading = false;
        });
        return;
      }

      // Si no hay datos en storage, obtener del servidor
      final profileResult = await _authService.getProfile();
      if (profileResult['success'] && mounted) {
        final userData = profileResult['data'];
        setState(() {
          _userName =
              userData['first_name'] ?? userData['username'] ?? 'Usuario';
          _userRole = _getRoleDisplayName(userData['role'] ?? 'admin');
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _userName = 'Usuario';
          _userRole = 'Administrador';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando perfil: $e');
      if (mounted) {
        setState(() {
          _userName = 'Usuario';
          _userRole = 'Administrador';
          _isLoading = false;
        });
      }
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrador';
      case 'security':
        return 'Seguridad';
      case 'resident':
      default:
        return 'Residente';
    }
  }

  void _onSidebarSelect(String key) {
    setState(() {
      _selectedSidebar = key;
    });
    if (key == 'profile') {
      Navigator.pushNamed(context, '/profile');
    } else if (key == 'estado_cuenta') {
      Navigator.pushNamed(context, '/estado_cuenta');
    } else if (key == 'notificaciones') {
      Navigator.pushNamed(context, '/notificaciones');
    } else if (key == 'logout') {
      _handleLogout(context);
    } else if (key != 'admin') {
      Navigator.pushReplacementNamed(context, '/$key');
    }
  }

  void _handleLogout(BuildContext context) async {
    await _authService.logout();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [],
      ),
      drawer: Drawer(
        child: AppSidebar(
          userRole: 'admin',
          selected: _selectedSidebar,
          onSelect: (key) {
            Navigator.pop(context);
            _onSidebarSelect(key);
          },
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, $_userName!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Usuario: $_userRole',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildFeatureCard(
                          context,
                          'Gestionar Residentes',
                          Icons.people,
                          Colors.blue,
                          () {},
                        ),
                        _buildFeatureCard(
                          context,
                          'Configuraciones',
                          Icons.settings,
                          Colors.green,
                          () {},
                        ),
                        _buildFeatureCard(
                          context,
                          'Anuncios',
                          Icons.announcement,
                          Colors.orange,
                          () {},
                        ),
                        _buildFeatureCard(
                          context,
                          'Reportes',
                          Icons.bar_chart,
                          Colors.purple,
                          () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
