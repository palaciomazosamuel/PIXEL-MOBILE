import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../../core/widgets/metric_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, _) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: dashboardProvider.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              children: [
                const _DashboardHeader(),
                const SizedBox(height: 20),
                SectionHeader(
                  title: 'Resumen administrativo',
                  subtitle: dashboardProvider.data == null
                      ? 'Cargando datos reales desde PIXEL.'
                      : 'Informacion cargada desde /api/dashboard/admin',
                  action: dashboardProvider.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          onPressed: dashboardProvider.load,
                          icon: const Icon(Icons.refresh),
                        ),
                ),
                if (dashboardProvider.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _DashboardError(message: dashboardProvider.errorMessage!),
                ],
                const SizedBox(height: 12),
                GridView.builder(
                  itemCount: dashboardProvider.metrics().length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.92,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final metric = dashboardProvider.metrics()[index];
                    return MetricCard(
                      title: metric.title,
                      value: metric.value,
                      icon: _iconForMetric(metric),
                      accentColor: _colorForTone(metric.tone),
                      backgroundColor: _softColorForTone(metric.tone),
                      helper: metric.detail,
                    );
                  },
                ),
                const SizedBox(height: 24),
                _StatusStrip(provider: dashboardProvider),
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'Ultimos pedidos',
                  subtitle: 'Lectura compacta para movil, sin acciones CRUD.',
                ),
                const SizedBox(height: 12),
                _OrderList(items: dashboardProvider.latestOrders()),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Cotizaciones pendientes',
                  subtitle:
                      '${dashboardProvider.pendingQuotesCount} antes de pasar a pedido',
                ),
                const SizedBox(height: 12),
                _OrderList(
                  items: dashboardProvider.pendingQuotes(),
                  emptyText: 'No hay cotizaciones pendientes para mostrar.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE4B2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.label.copyWith(color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;
    final name = profile?['nombre']?.toString() ?? 'Administrador';
    final email = profile?['correo']?.toString() ?? 'Sesion PIXEL';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260F172A),
            blurRadius: 34,
            offset: Offset(0, 18),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF581C87), Color(0xFF831843), Color(0xFF1E40AF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandMark(compact: true, onDark: true),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.32)),
            ),
            child: const Text(
              'PANEL ADMINISTRADOR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Vision general del negocio en tiempo real.',
            style: TextStyle(
              color: Color(0xFFEDEBFF),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(
                          color: Color(0xFFDDE6FF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.provider});

  final DashboardProvider provider;

  @override
  Widget build(BuildContext context) {
    final items = provider.orderDistribution();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distribucion de pedidos', style: AppTextStyles.titleMedium),
            const SizedBox(height: 14),
            for (final item in items) ...[
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _statusColor(item.key),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item.key, style: AppTextStyles.bodyStrong),
                  ),
                  Text(item.value.toString(), style: AppTextStyles.bodyStrong),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 7,
                  value: item.value == 0 ? 0 : item.value / _maxStatus(items),
                  color: _statusColor(item.key),
                  backgroundColor: AppColors.line,
                ),
              ),
              if (item.key != items.last.key) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({
    required this.items,
    this.emptyText = 'No hay pedidos para mostrar.',
  });

  final List<DashboardOrder> items;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(emptyText, style: AppTextStyles.bodyMuted),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _OrderTile(item: items[i]),
            if (i != items.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.item});

  final DashboardOrder item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line),
        ),
        child: const Icon(Icons.receipt_long_outlined, color: AppColors.violet),
      ),
      title: Text(item.number, style: AppTextStyles.bodyStrong),
      subtitle: Text(
        '${item.customer}\n${item.date}',
        style: AppTextStyles.bodyMuted,
      ),
      trailing: _StatusBadge(status: item.status),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      constraints: const BoxConstraints(maxWidth: 108),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: AppTextStyles.label.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

IconData _iconForMetric(DashboardMetric metric) {
  return switch (metric.tone) {
    DashboardTone.warning => Icons.schedule_outlined,
    DashboardTone.info => Icons.people_outline,
    DashboardTone.success => Icons.payments_outlined,
    DashboardTone.violet => Icons.auto_graph_outlined,
  };
}

Color _colorForTone(DashboardTone tone) {
  return switch (tone) {
    DashboardTone.warning => AppColors.warning,
    DashboardTone.info => AppColors.info,
    DashboardTone.success => AppColors.accent,
    DashboardTone.violet => AppColors.violet,
  };
}

Color _softColorForTone(DashboardTone tone) {
  return switch (tone) {
    DashboardTone.warning => AppColors.warningSoft,
    DashboardTone.info => AppColors.infoSoft,
    DashboardTone.success => AppColors.accentSoft,
    DashboardTone.violet => AppColors.primarySoft,
  };
}

Color _statusColor(String status) {
  final key = status.toUpperCase();
  if (key.contains('PRODUCCION') || key.contains('PROCESO')) {
    return AppColors.info;
  }
  if (key.contains('ENTREGADO') || key.contains('TERMINADO')) {
    return AppColors.accent;
  }
  if (key.contains('ANULADO')) return AppColors.danger;
  return AppColors.warning;
}

double _maxStatus(List<MapEntry<String, int>> items) {
  final maxValue = items.fold<int>(0, (max, item) {
    return item.value > max ? item.value : max;
  });
  return maxValue == 0 ? 1 : maxValue.toDouble();
}
