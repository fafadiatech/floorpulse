import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AssetStatus { running, down, maintenance, idle }

class MaintenanceAsset {
  final String id;
  final String name;
  final String tag;
  final String location;
  final String category;
  final AssetStatus status;
  final DateTime lastPM;
  final DateTime nextPM;
  final Map<String, double> meters;
  final String technician;

  const MaintenanceAsset({
    required this.id,
    required this.name,
    required this.tag,
    required this.location,
    required this.category,
    required this.status,
    required this.lastPM,
    required this.nextPM,
    required this.meters,
    required this.technician,
  });

  Color get statusColor {
    switch (status) {
      case AssetStatus.running:
        return AppTheme.success;
      case AssetStatus.down:
        return AppTheme.danger;
      case AssetStatus.maintenance:
        return AppTheme.warning;
      case AssetStatus.idle:
        return AppTheme.textSecondary;
    }
  }

  String get statusLabel {
    switch (status) {
      case AssetStatus.running:
        return 'Running';
      case AssetStatus.down:
        return 'Down';
      case AssetStatus.maintenance:
        return 'In Maintenance';
      case AssetStatus.idle:
        return 'Idle';
    }
  }
}
