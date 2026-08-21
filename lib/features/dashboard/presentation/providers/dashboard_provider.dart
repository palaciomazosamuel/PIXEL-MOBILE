import 'package:flutter/foundation.dart';

import '../../data/dashboard_repository.dart';

class DashboardMetric {
  const DashboardMetric({
    required this.title,
    required this.value,
    required this.detail,
    required this.tone,
  });

  final String title;
  final String value;
  final String detail;
  final DashboardTone tone;
}

class DashboardOrder {
  const DashboardOrder({
    required this.number,
    required this.customer,
    required this.date,
    required this.status,
  });

  final String number;
  final String customer;
  final String date;
  final String status;
}

enum DashboardTone { warning, info, success, violet }

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({required this.repository});

  final DashboardRepository repository;

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? data;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      data = await repository.getAdminDashboard();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<DashboardMetric> metrics() {
    final kpis = _map(data?['kpis']);
    final ingresos = _map(data?['ingresos']);
    final year = DateTime.now().year;

    return [
      DashboardMetric(
        title: 'Pedidos pendientes',
        value: _number(kpis['pedidosPendientes']),
        detail: '${_number(kpis['pedidosEnProceso'])} en produccion',
        tone: DashboardTone.warning,
      ),
      DashboardMetric(
        title: 'Total clientes',
        value: _number(kpis['totalClientes']),
        detail: 'Clientes activos registrados',
        tone: DashboardTone.info,
      ),
      DashboardMetric(
        title: 'Ingresos mensual',
        value: _compactCurrency(ingresos['mensual']),
        detail: 'Ingresos confirmados este mes',
        tone: DashboardTone.success,
      ),
      DashboardMetric(
        title: 'Ingresos anual',
        value: _compactCurrency(ingresos['anual']),
        detail: 'Ingresos confirmados $year',
        tone: DashboardTone.violet,
      ),
    ];
  }

  List<DashboardOrder> latestOrders() {
    final orders = data?['ultimosPedidos'];
    if (orders is! List) return const [];

    return orders.take(5).map((raw) {
      final order = _map(raw);
      final customer = _map(order['cliente']);
      return DashboardOrder(
        number: 'PX-${order['idPedido'] ?? '--'}',
        customer: customer['nombre']?.toString() ?? 'Cliente no especificado',
        date: _shortDate(order['fechaCreacion']),
        status: _readableStatus(order['estadoPedido']),
      );
    }).toList();
  }

  List<DashboardOrder> pendingQuotes() {
    final quotes = data?['cotizacionesPendientes'];
    if (quotes is! List) return const [];

    return quotes.take(5).map((raw) {
      final quote = _map(raw);
      final customer = _map(quote['cliente']);
      return DashboardOrder(
        number: 'CT-${quote['idCotizacion'] ?? '--'}',
        customer: customer['nombre']?.toString() ?? 'Cliente no especificado',
        date: _shortDate(quote['fechaCreacion']),
        status: _readableStatus(quote['estado']),
      );
    }).toList();
  }

  List<MapEntry<String, int>> orderDistribution() {
    final distribution = _map(data?['distribucionPedidos']);
    final labels = {
      'PENDIENTE': 'Pendiente',
      'EN_PROCESO': 'En produccion',
      'FINALIZADO': 'Terminado',
      'ENTREGADO': 'Entregado',
    };

    return labels.entries
        .map((entry) => MapEntry(entry.value, _toInt(distribution[entry.key])))
        .toList();
  }

  int get pendingQuotesCount {
    final kpis = _map(data?['kpis']);
    return _toInt(kpis['cotizacionesPendientes']);
  }

  Map<String, dynamic> _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  String _number(Object? value) => _toInt(value).toString();

  int _toInt(Object? value) {
    if (value is num) return value.round();
    return num.tryParse(value?.toString() ?? '')?.round() ?? 0;
  }

  String _compactCurrency(Object? value) {
    final amount = _toInt(value);
    if (amount.abs() >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount.abs() >= 1000) {
      return '\$${(amount / 1000).round()}k';
    }
    return '\$${amount.toString()}';
  }

  String _shortDate(Object? value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return 'Por definir';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _readableStatus(Object? value) {
    final status = value?.toString() ?? 'PENDIENTE';
    const labels = {
      'PENDIENTE': 'Pendiente',
      'EN_PROCESO': 'En produccion',
      'PENDIENTE_SALDO_FINAL': 'Pendiente saldo final',
      'FINALIZADO': 'Terminado',
      'ENTREGADO': 'Entregado',
      'ANULADO': 'Anulado',
      'POR_APROBAR': 'Por aprobar',
    };
    return labels[status] ?? status;
  }
}
