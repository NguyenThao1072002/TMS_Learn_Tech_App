class Roles {
  final int roleId;
  final String roleName;

  Roles({
    required this.roleId,
    required this.roleName,
  });

  factory Roles.fromJson(Map<String, dynamic> json) {
    return Roles(
      roleId: json['role_id'],
      roleName: json['role_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'role_name': roleName,
    };
  }
}