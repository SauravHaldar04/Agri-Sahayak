import 'dart:math';

import 'package:flutter/foundation.dart';
import '../models/app_user.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);

  Future<AppUser> signIn({
    required String username,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final String lower = username.toLowerCase();
    UserRole role = UserRole.farmer;
    String name = 'Demo Farmer';

    if (lower.contains('advisor')) {
      role = UserRole.advisor;
      name = 'Demo Advisor';
    } else if (lower.contains('policy') || lower.contains('policymaker')) {
      role = UserRole.policymaker;
      name = 'Demo Policymaker';
    }

    final AppUser user = AppUser(
      uid: _generateId(),
      name: name,
      role: role,
      district: 'Pune',
    );

    currentUser.value = user;
    return user;
  }

  void signOut() {
    currentUser.value = null;
  }

  String _generateId() {
    final int randomPart = Random().nextInt(999999);
    return '${DateTime.now().millisecondsSinceEpoch}_$randomPart';
  }
}
