import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../cotizaciones/presentation/screens/cotizaciones_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../pedidos/presentation/screens/pedidos_screen.dart';
import '../../../produccion/presentation/screens/produccion_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  static const _screens = [
    DashboardScreen(),
    CotizacionesScreen(),
    PedidosScreen(),
    ProduccionScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        height: 72,
        elevation: 8,
        shadowColor: const Color(0x1A000000),
        surfaceTintColor: AppColors.surface,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.request_quote_outlined),
            label: 'Cotizaciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.precision_manufacturing_outlined),
            label: 'Producción',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
