enum UserRole { farmer, advisor, policymaker }

class AppUser {
  final String uid;
  final String name;
  final UserRole role;
  final String district;

  const AppUser({
    required this.uid,
    required this.name,
    required this.role,
    required this.district,
  });

  AppUser copyWith({
    String? uid,
    String? name,
    UserRole? role,
    String? district,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      role: role ?? this.role,
      district: district ?? this.district,
    );
  }

  @override
  String toString() {
    return 'AppUser(uid: $uid, name: $name, role: ${role.name}, district: $district)';
  }
}
