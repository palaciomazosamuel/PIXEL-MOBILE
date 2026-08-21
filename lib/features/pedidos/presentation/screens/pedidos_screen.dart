import 'package:flutter/material.dart';

import '../../../../core/widgets/read_only_api_list_screen.dart';

class PedidosScreen extends StatelessWidget {
  const PedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ReadOnlyApiListScreen(
      title: 'Pedidos',
      eyebrow: 'Operacion',
      description: 'Pedidos recientes sin acciones de cambio de estado.',
      endpoint: '/api/pedidos',
      queryParameters: const {
        'page': 1,
        'limit': 10,
        'sortBy': 'fechaCreacion',
        'order': 'desc',
      },
      icon: Icons.assignment_outlined,
      itemTitle: (item) => 'PX-${item['idPedido'] ?? '--'}',
      itemSubtitle: (item) {
        final cliente = item['cliente'];
        final nombre = cliente is Map
            ? cliente['nombre']?.toString()
            : 'Cliente no especificado';
        return '${nombre ?? 'Cliente no especificado'} · ${item['estadoPedido'] ?? 'Sin estado'}';
      },
      itemMeta: (item) => 'Saldo: \$${item['saldoPendiente'] ?? 0}',
    );
  }
}
