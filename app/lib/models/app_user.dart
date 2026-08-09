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
}
