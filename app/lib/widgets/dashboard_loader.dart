import 'package:flutter/material.dart';

import '../api/floorpulse_api.dart';
import '../api/frappe_exception.dart';
import '../theme/app_theme.dart';

class DashboardLoader extends StatefulWidget {
  final String? role;
  final Widget Function(BuildContext context, Map<String, dynamic> stats)
  builder;

  const DashboardLoader({super.key, this.role, required this.builder});

  @override
  State<DashboardLoader> createState() => _DashboardLoaderState();
}

class _DashboardLoaderState extends State<DashboardLoader> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = FloorPulseApi.instance.getDashboard(role: widget.role);
    _future.then(
      (_) {},
      onError: (error) {
        if (!mounted) return;
        final message = error is FrappeException ? error.message : '$error';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Could not load dashboard',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(_load),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        return widget.builder(context, snapshot.data ?? const {});
      },
    );
  }
}

int kpiInt(Map<String, dynamic> stats, String key) =>
    (stats[key] as num?)?.toInt() ?? 0;

double kpiDouble(Map<String, dynamic> stats, String key) =>
    (stats[key] as num?)?.toDouble() ?? 0;

String kpiText(Map<String, dynamic> stats, String key) {
  final value = stats[key];
  if (value == null) return '—';
  if (value is double) {
    return value == value.roundToDouble()
        ? '${value.round()}'
        : value.toStringAsFixed(1);
  }
  return value.toString();
}
