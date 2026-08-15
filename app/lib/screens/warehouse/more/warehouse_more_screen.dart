import 'package:flutter/material.dart';
import '../../../api/session.dart';
import '../../../data/warehouse_mock_data.dart';
import '../../../theme/app_theme.dart';
import '../../qc/scan/traceability_tree_screen.dart';
import '../../qc/scan/stock_ledger_screen.dart';
import '../stock/warehouse_browser_screen.dart';
import 'gate_entry_screen.dart';
import 'transfer_screen.dart';

class WarehouseMoreScreen extends StatelessWidget {
  const WarehouseMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sessionUser(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('More')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary,
                    AppTheme.primary.withValues(alpha: 0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.roleLabel,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${user.employeeId} · ${user.department}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Operations
            _SectionHeader('Operations'),
            _MenuItem(
              icon: Icons.sensor_door_outlined,
              label: 'Gate Entry',
              sublabel: 'Log vehicle entry/exit',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GateEntryScreen()),
              ),
            ),
            _MenuItem(
              icon: Icons.swap_horiz,
              label: 'Stock Transfer',
              sublabel: 'Move stock between bins',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransferScreen()),
              ),
            ),
            _MenuItem(
              icon: Icons.warehouse_outlined,
              label: 'Warehouse Browser',
              sublabel: 'Browse zones and bins',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WarehouseBrowserScreen(),
                ),
              ),
            ),

            // Reports & Traceability
            _SectionHeader('Reports & Traceability'),
            _MenuItem(
              icon: Icons.account_tree_outlined,
              label: 'Traceability',
              sublabel: 'Track batch/serial lineage',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TraceabilityTreeScreen(),
                ),
              ),
            ),
            _MenuItem(
              icon: Icons.history,
              label: 'Stock Ledger',
              sublabel: 'View stock movements',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StockLedgerScreen(
                    itemCode: 'RM-SS316-25',
                    description: 'SS316 Round Bar 25mm',
                    entries: WarehouseMockData.stockLedger,
                  ),
                ),
              ),
            ),

            // Coming soon
            _SectionHeader('Coming Soon'),
            _MenuItem(
              icon: Icons.assignment_return_outlined,
              label: 'Material Returns',
              sublabel: 'Return to store',
              comingSoon: true,
            ),
            _MenuItem(
              icon: Icons.precision_manufacturing_outlined,
              label: 'Subcontracting',
              sublabel: 'Send / receive subcon',
              comingSoon: true,
            ),
            _MenuItem(
              icon: Icons.approval_outlined,
              label: 'Approvals',
              sublabel: 'Pending authorizations',
              comingSoon: true,
            ),
            _MenuItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              sublabel: 'App preferences',
              comingSoon: true,
            ),

            const Divider(height: 1, color: AppTheme.divider),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => confirmLogout(context),
                  icon: const Icon(Icons.logout, color: AppTheme.danger),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: AppTheme.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppTheme.danger, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
    child: Text(
      title,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback? onTap;
  final bool comingSoon;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.sublabel,
    this.onTap,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: comingSoon
        ? () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('$label – coming soon')));
          }
        : onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: comingSoon
                        ? AppTheme.textSecondary
                        : AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  sublabel,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (comingSoon)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Soon',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
              size: 20,
            ),
        ],
      ),
    ),
  );
}
