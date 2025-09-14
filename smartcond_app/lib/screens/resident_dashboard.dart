import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/sidebar.dart';
import 'profile_screen.dart';

class ResidentDashboard extends StatefulWidget {
  const ResidentDashboard({super.key});

  @override
  State<ResidentDashboard> createState() => _ResidentDashboardState();
}

class _ResidentDashboardState extends State<ResidentDashboard> {
  final AuthService _authService = AuthService();
  String _userName = '';
  String _userRole = 'Residente';
  bool _isLoading = true;
  String _greeting = '';
  bool _animateCards = false;
  String _selectedSidebar = 'finanzas';

  @override
  void initState() {
    super.initState();
    _setGreeting();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _animateCards = true;
      });
    });
    _loadUserProfile();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Buenos días';
    } else if (hour < 18) {
      _greeting = 'Buenas tardes';
    } else {
      _greeting = 'Buenas noches';
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'resident':
        return 'Residente';
      case 'admin':
        return 'Administrador';
      case 'security':
        return 'Seguridad';
      default:
        return 'Residente';
    }
  }

  void _handleLogout(BuildContext context) async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final username = await _authService.storage.read(key: 'username');
      final userType = await _authService.storage.read(key: 'user_type');
      if (username != null) {
        setState(() {
          _userName = username;
          _userRole = _getRoleDisplayName(userType ?? 'resident');
          _isLoading = false;
        });
        return;
      }
      final profileResult = await _authService.getProfile();
      if (profileResult['success'] && mounted) {
        final userData = profileResult['data'];
        setState(() {
          _userName =
              userData['first_name'] ?? userData['username'] ?? 'Usuario';
          _userRole = _getRoleDisplayName(userData['role'] ?? 'resident');
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _userName = 'Usuario';
          _userRole = 'Residente';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando perfil: $e');
      if (mounted) {
        setState(() {
          _userName = 'Usuario';
          _userRole = 'Residente';
          _isLoading = false;
        });
      }
    }
  }

  void _onSidebarSelect(String key) {
    setState(() {
      _selectedSidebar = key;
    });
    if (key == 'profile') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else if (key == 'estado_cuenta') {
      Navigator.pushNamed(context, '/estado_cuenta');
    } else if (key == 'logout') {
      _handleLogout(context);
    } else if (key == 'finanzas') {
      Navigator.pushNamed(context, '/finanzas');
    } else if (key == 'comunicados') {
      Navigator.pushNamed(context, '/comunicados');
    }
    // Aquí puedes agregar navegación para otras vistas
  }

  Widget _quickStatCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF232336),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Card(
      color: const Color(0xFF232336),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title próximamente'),
              backgroundColor: color,
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.white70),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18181B),
      appBar: AppBar(
        title: const Text('Mi Portal'),
        backgroundColor: const Color(0xFF312E81),
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadUserProfile();
            },
          ),
        ],
        elevation: 0,
      ),
      drawer: Drawer(
        child: AppSidebar(
          userRole: 'resident',
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
                    // Header con gradiente y datos
                    AnimatedOpacity(
                      opacity: _animateCards ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 700),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF312E81)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                color: Color(0xFF6366F1),
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$_greeting, $_userName!',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Tipo de usuario: $_userRole',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Tarjetas de estadísticas rápidas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _quickStatCard(
                          Icons.event,
                          'Reservas',
                          '2',
                          Colors.indigo,
                        ),
                        _quickStatCard(
                          Icons.payment,
                          'Pagos Pendientes',
                          '2',
                          Colors.amber,
                        ),
                        _quickStatCard(
                          Icons.notifications,
                          'Notificaciones',
                          '2',
                          Colors.pink,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Grid de funcionalidades
                    Text(
                      'Funcionalidades',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.92),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      children: [
                        _featureCard(
                          context,
                          Icons.payment,
                          'Mis Pagos',
                          'Revisa tus cuotas y pagos pendientes',
                          Colors.green,
                        ),
                        _featureCard(
                          context,
                          Icons.account_balance_wallet,
                          'Estado de Cuenta',
                          'Consulta tu estado financiero',
                          Colors.blue,
                        ),
                        _featureCard(
                          context,
                          Icons.announcement,
                          'Anuncios',
                          'Lee las comunicaciones del condominio',
                          Colors.orange,
                        ),
                        _featureCard(
                          context,
                          Icons.person,
                          'Mi Perfil',
                          'Gestiona tu información personal',
                          Colors.purple,
                        ),
                        _featureCard(
                          context,
                          Icons.description,
                          'Solicitudes',
                          'Envía solicitudes al administrador',
                          Colors.teal,
                        ),
                        _featureCard(
                          context,
                          Icons.help,
                          'Ayuda',
                          'Centro de ayuda y soporte',
                          Colors.indigo,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Información adicional
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27272A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF44444C)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white70,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Información del Sistema',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• Consulta tus pagos y estado de cuenta\n'
                            '• Envía solicitudes al administrador\n'
                            '• Recibe notificaciones importantes\n'
                            '• Gestiona tu perfil personal',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
