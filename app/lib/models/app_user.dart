enum UserRole { production, qc, warehouse, sales, maintenance }

class AppUser {
  final String username;
  final String name;
  final UserRole userRole;
  final String roleLabel;
  final String employeeId;
  final String department;
  final String initials;

  const AppUser({
    required this.username,
    required this.name,
    required this.userRole,
    required this.roleLabel,
    required this.employeeId,
    required this.department,
    required this.initials,
  });

  factory AppUser.fromSession(Map<String, dynamic> json) {
    final roleName = json['primary_role'] as String?;
    final role = UserRole.values.asNameMap()[roleName];
    if (role == null) {
      throw const FormatException('No FloorPulse role assigned');
    }

    final employee = json['employee'];
    String employeeId = '';
    String department = '';
    if (employee is Map) {
      employeeId = (employee['name'] ?? '').toString();
      department = (employee['department'] ?? '').toString();
    }

    final name = (json['full_name'] ?? json['user'] ?? '').toString();
    return AppUser(
      username: (json['user'] ?? '').toString(),
      name: name,
      userRole: role,
      roleLabel: _labelFor(role),
      employeeId: employeeId,
      department: department,
      initials: initialsFromName(name),
    );
  }

  static String _labelFor(UserRole role) => switch (role) {
    UserRole.production => 'Production Operator',
    UserRole.qc => 'QC Inspector',
    UserRole.warehouse => 'Warehouse Operator',
    UserRole.sales => 'Sales Executive',
    UserRole.maintenance => 'Maintenance Tech',
  };

  static String initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? name : parts.first;
  }
}
