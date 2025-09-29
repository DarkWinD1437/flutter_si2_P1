import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  final String userRole;
  final Function(String) onSelect;
  final String selected;

  const AppSidebar({
    Key? key,
    required this.userRole,
    required this.onSelect,
    required this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFF7C2D12); // Amber/Orange dark
    final Color accent = const Color(0xFFF59E42); // Orange accent
    final Color iconColor = Colors.white;
    final List<_SidebarItem> items = _getSidebarItems(userRole);

    return Container(
      width: 260,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C2D12), Color(0xFFB45309), Color(0xFFBE123C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 32.0,
              horizontal: 16.0,
            ),
            child: Row(
              children: [
                Icon(Icons.home_rounded, color: accent, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Condominium',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Sistema de Gestión',
                      style: TextStyle(color: accent, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: items.map((item) {
                final bool isActive = item.key == selected;
                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: isActive ? accent : iconColor,
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      color: isActive ? accent : Colors.white,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  tileColor: isActive
                      ? Colors.white.withOpacity(0.08)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () => onSelect(item.key),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Text(
                  'Smart Condominium v1.0',
                  style: TextStyle(color: accent, fontSize: 12),
                ),
                Text(
                  '© 2025 - Sistema Integral de Gestión by DarkWinD',
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Sistema Activo',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem {
  final String key;
  final String label;
  final IconData icon;
  _SidebarItem(this.key, this.label, this.icon);
}

List<_SidebarItem> _getSidebarItems(String role) {
  if (role == 'resident') {
    return [
      _SidebarItem('resident', 'Dashboard', Icons.dashboard),
      _SidebarItem('profile', 'Mi Perfil', Icons.person),
      _SidebarItem(
        'estado_cuenta',
        'Estado de Cuenta',
        Icons.account_balance_wallet,
      ),
      _SidebarItem('finanzas', 'Finanzas', Icons.payment),
      _SidebarItem('comunicados', 'Avisos y comunicados', Icons.announcement),
      _SidebarItem('reservas', 'Reservas de Áreas', Icons.event_available),
      _SidebarItem('seguridad', 'Seguridad', Icons.security),
      _SidebarItem('notificaciones', 'Notificaciones IA', Icons.notifications),
      _SidebarItem('ayuda', 'Ayuda', Icons.help_outline),
      _SidebarItem('logout', 'Cerrar Sesión', Icons.logout),
    ];
  } else if (role == 'security') {
    return [
      _SidebarItem('dashboard', 'Puesto de Guardia', Icons.security),
      _SidebarItem('profile', 'Mi Perfil', Icons.person),
      _SidebarItem(
        'estado_cuenta',
        'Estado de Cuenta',
        Icons.account_balance_wallet,
      ),
      _SidebarItem('control_acceso', 'Control de Acceso', Icons.verified_user),
      _SidebarItem('ia_vision', 'IA y Visión', Icons.remove_red_eye),
      _SidebarItem('incidentes', 'Incidentes', Icons.report_problem),
      _SidebarItem('rondas', 'Rondas', Icons.directions_walk),
      _SidebarItem('comunicados', 'Avisos y comunicados', Icons.announcement),
      _SidebarItem(
        'reservas',
        'Consultar Disponibilidad',
        Icons.event_available,
      ),
      _SidebarItem('reportes', 'Reportes', Icons.analytics),
      _SidebarItem('logout', 'Cerrar Sesión', Icons.logout),
    ];
  } else if (role == 'admin') {
    return [
      _SidebarItem('admin', 'Dashboard Admin', Icons.admin_panel_settings),
      _SidebarItem('profile', 'Mi Perfil', Icons.person),
      _SidebarItem(
        'estado_cuenta',
        'Estado de Cuenta',
        Icons.account_balance_wallet,
      ),
      _SidebarItem('usuarios', 'Gestión Usuarios', Icons.people),
      _SidebarItem('finanzas', 'Módulo Financiero', Icons.payment),
      _SidebarItem('comunicados', 'Avisos y comunicados', Icons.announcement),
      _SidebarItem('reservas', 'Gestión Reservas', Icons.event_available),
      _SidebarItem('seguridad', 'Sistema Seguridad', Icons.security),
      _SidebarItem('reportes', 'Reportes y Analytics', Icons.analytics),
      _SidebarItem('configuracion', 'Configuración', Icons.settings),
      _SidebarItem('logout', 'Cerrar Sesión', Icons.logout),
    ];
  } else {
    return [
      _SidebarItem('dashboard', 'Dashboard', Icons.dashboard),
      _SidebarItem('logout', 'Cerrar Sesión', Icons.logout),
    ];
  }
}
