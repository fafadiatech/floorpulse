import 'package:flutter/material.dart';
import '../../../data/sales_mock_data.dart';
import '../../../theme/app_theme.dart';
import '../../auth/login_screen.dart';
import 'quotations_screen.dart';
import 'leads_screen.dart';

class SalesMoreScreen extends StatelessWidget {
  const SalesMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SalesMockData.salesUser;

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

            _SectionHeader('Sales Tools'),
            _MenuItem(
              icon: Icons.request_quote_outlined,
              label: 'Quotations',
              sublabel: '${SalesMockData.quotations.length} active quotes',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuotationsScreen()),
              ),
            ),
            _MenuItem(
              icon: Icons.person_search_outlined,
              label: 'Leads',
              sublabel: '${SalesMockData.leads.length} open leads',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeadsScreen()),
              ),
            ),
            _MenuItem(
              icon: Icons.bar_chart_outlined,
              label: 'Reports',
              sublabel: 'Sales performance, collection',
              comingSoon: true,
            ),
            _MenuItem(
              icon: Icons.feedback_outlined,
              label: 'Complaints',
              sublabel: 'Customer complaints & resolution',
              comingSoon: true,
            ),

            _SectionHeader('Account'),
            _MenuItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              sublabel: 'Notifications, preferences',
              comingSoon: true,
            ),

            const Divider(height: 1, color: AppTheme.divider),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  ),
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
  final String label, sublabel;
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
        ? () => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$label – coming soon')))
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
