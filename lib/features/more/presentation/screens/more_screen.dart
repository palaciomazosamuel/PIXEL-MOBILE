import 'package:flutter/material.dart';

import '../../../../core/widgets/module_tile.dart';
import '../../../../core/widgets/section_header.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Más')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(
            title: 'Módulos de consulta',
            subtitle: 'Accesos read-only para administración.',
          ),
          const SizedBox(height: 12),
          const ModuleTile(
            icon: Icons.point_of_sale_outlined,
            title: 'Ventas',
            subtitle: 'Consulta de ventas y estados de pago.',
          ),
          const ModuleTile(
            icon: Icons.people_outline,
            title: 'Clientes',
            subtitle: 'Consulta administrativa de clientes.',
          ),
          const ModuleTile(
            icon: Icons.payments_outlined,
            title: 'Abonos',
            subtitle: 'Consulta de pagos relacionados con pedidos.',
          ),
          const ModuleTile(
            icon: Icons.brush_outlined,
            title: 'Diseños',
            subtitle: 'Consulta de diseños asociados a pedidos.',
          ),
          const ModuleTile(
            icon: Icons.inventory_2_outlined,
            title: 'Productos',
            subtitle: 'Productos cotizables desde la API.',
          ),
          const ModuleTile(
            icon: Icons.category_outlined,
            title: 'Técnicas',
            subtitle: 'Gestión de técnicas en modo consulta.',
          ),
          const ModuleTile(
            icon: Icons.local_shipping_outlined,
            title: 'Proveedores',
            subtitle: 'Consulta de proveedores.',
          ),
          const ModuleTile(
            icon: Icons.shopping_cart_outlined,
            title: 'Compras',
            subtitle: 'Consulta de compras sin confirmar ni anular.',
          ),
          const ModuleTile(
            icon: Icons.manage_accounts_outlined,
            title: 'Usuarios',
            subtitle: 'Consulta de usuarios internos.',
          ),
          const ModuleTile(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Roles y permisos',
            subtitle: 'Consulta de roles y permisos dinámicos.',
          ),
        ],
      ),
    );
  }
}
