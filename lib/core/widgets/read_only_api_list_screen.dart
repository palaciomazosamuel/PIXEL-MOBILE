import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../network/api_client.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

typedef ItemTextBuilder = String Function(Map<String, dynamic> item);

class ReadOnlyApiListScreen extends StatefulWidget {
  const ReadOnlyApiListScreen({
    required this.title,
    required this.eyebrow,
    required this.description,
    required this.endpoint,
    required this.icon,
    required this.itemTitle,
    required this.itemSubtitle,
    this.queryParameters = const {},
    this.itemMeta,
    super.key,
  });

  final String title;
  final String eyebrow;
  final String description;
  final String endpoint;
  final Map<String, dynamic> queryParameters;
  final IconData icon;
  final ItemTextBuilder itemTitle;
  final ItemTextBuilder itemSubtitle;
  final ItemTextBuilder? itemMeta;

  @override
  State<ReadOnlyApiListScreen> createState() => _ReadOnlyApiListScreenState();
}

class _ReadOnlyApiListScreenState extends State<ReadOnlyApiListScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.dio.get<Map<String, dynamic>>(
        widget.endpoint,
        queryParameters: widget.queryParameters,
      );
      return _extractItems(response.data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return const [];
      final payload = error.response?.data;
      if (payload is Map && payload['message'] != null) {
        throw Exception(payload['message']);
      }
      throw Exception('No se pudo consultar ${widget.endpoint}.');
    }
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  List<Map<String, dynamic>> _extractItems(Map<String, dynamic>? payload) {
    final data = payload?['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => item.map((key, value) => MapEntry('$key', value)))
          .toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <Map<String, dynamic>>[];
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              children: [
                _ModuleHero(
                  title: widget.title,
                  eyebrow: widget.eyebrow,
                  description: widget.description,
                  icon: widget.icon,
                ),
                const SizedBox(height: 18),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const _StateCard(
                    icon: Icons.sync,
                    title: 'Cargando datos',
                    message: 'Consultando la API de PIXEL...',
                  )
                else if (snapshot.hasError)
                  _StateCard(
                    icon: Icons.warning_amber_outlined,
                    title: 'No se pudo cargar',
                    message: snapshot.error.toString(),
                  )
                else if (items.isEmpty)
                  const _StateCard(
                    icon: Icons.inbox_outlined,
                    title: 'Sin registros',
                    message: 'No hay informacion para mostrar por ahora.',
                  )
                else
                  for (final item in items) ...[
                    _ApiItemCard(
                      icon: widget.icon,
                      title: widget.itemTitle(item),
                      subtitle: widget.itemSubtitle(item),
                      meta: widget.itemMeta?.call(item),
                    ),
                    const SizedBox(height: 10),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ModuleHero extends StatelessWidget {
  const _ModuleHero({
    required this.title,
    required this.eyebrow,
    required this.description,
    required this.icon,
  });

  final String title;
  final String eyebrow;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.violet, AppColors.info],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.violet,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 4),
                Text(description, style: AppTextStyles.bodyMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiItemCard extends StatelessWidget {
  const _ApiItemCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.meta,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? meta;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.violet, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyStrong),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodyMuted),
                  if (meta != null && meta!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      meta!,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, color: AppColors.violet, size: 34),
            const SizedBox(height: 10),
            Text(title, style: AppTextStyles.titleMedium),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
