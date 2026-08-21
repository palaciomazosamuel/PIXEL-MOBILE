import 'package:flutter/material.dart';

import '../../../../core/widgets/read_only_api_list_screen.dart';

class ProduccionScreen extends StatelessWidget {
  const ProduccionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ReadOnlyApiListScreen(
      title: 'Produccion',
      eyebrow: 'Disenos aprobados',
      description: 'Cola pendiente conectada a produccion sin drag & drop.',
      endpoint: '/api/disenos/produccion/pendientes',
      icon: Icons.precision_manufacturing_outlined,
      itemTitle: (item) => 'Diseno #${item['idDiseno'] ?? '--'}',
      itemSubtitle: (item) {
        final pedido = item['pedido'];
        final idPedido = pedido is Map ? pedido['idPedido'] : item['idPedido'];
        return 'Pedido PX-${idPedido ?? '--'} · ${item['estado'] ?? 'Sin estado'}';
      },
      itemMeta: (item) => item['descripcion']?.toString() ?? 'Sin descripcion',
    );
  }
}
