import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../advisor/advisor_dashboard_screen.dart';
import '../farmer/farmer_home_screen.dart';
import '../policy/policy_dashboard_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: AuthService.instance.currentUser,
      builder: (BuildContext context, AppUser? user, Widget? _) {
        if (user == null) {
          return const LoginScreen();
        }

        // Initialize chat service when user is authenticated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ChatService.instance.initializeGemini();
        });

        switch (user.role) {
          case UserRole.farmer:
            return const FarmerHomeScreen();
          case UserRole.advisor:
            return const AdvisorDashboardScreen();
          case UserRole.policymaker:
            return const PolicyDashboardScreen();
        }
      },
    );
  }
}
