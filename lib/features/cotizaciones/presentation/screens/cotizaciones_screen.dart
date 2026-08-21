import 'package:flutter/material.dart';

import '../../../../core/widgets/read_only_api_list_screen.dart';

class CotizacionesScreen extends StatelessWidget {
  const CotizacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ReadOnlyApiListScreen(
      title: 'Cotizaciones',
      eyebrow: 'Solo lectura',
      description: 'Solicitudes recientes con paginacion del backend.',
      endpoint: '/api/cotizaciones',
      queryParameters: const {
        'page': 1,
        'limit': 10,
        'sortBy': 'fechaCreacion',
        'order': 'desc',
      },
      icon: Icons.request_quote_outlined,
      itemTitle: (item) => 'CT-${item['idCotizacion'] ?? '--'}',
      itemSubtitle: (item) {
        final cliente = item['cliente'];
        final nombre = cliente is Map
            ? cliente['nombre']?.toString()
            : 'Cliente no especificado';
        return '${nombre ?? 'Cliente no especificado'} · ${item['estado'] ?? 'Sin estado'}';
      },
      itemMeta: (item) => 'Total: \$${item['total'] ?? 0}',
    );
  }
}
