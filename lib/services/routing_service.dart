import 'package:flutter/material.dart';
import '../screens/farmer/farmer_home_screen.dart';
import '../screens/advisor/advisor_dashboard.dart';
import '../screens/auth/login_screen.dart';
import '../screens/farmer/ask_expert_screen.dart';
import '../screens/advisor/issue_details_screen.dart';

class RoutingService {
  static final RoutingService _instance = RoutingService._internal();
  factory RoutingService() => _instance;
  RoutingService._internal();

  /// Get the appropriate home screen based on user role
  Widget getHomeScreenByRole(String role) {
    switch (role.toLowerCase()) {
      case 'advisor':
      case 'agricultural_advisor':
      case 'expert':
        return const AdvisorDashboard();
      case 'farmer':
      case 'agricultural_farmer':
      case 'policymaker':
      default:
        return const FarmerHomeScreen();
    }
  }

  /// Navigate to Ask Expert screen (for farmers)
  void navigateToAskExpert(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AskExpertScreen()),
    );
  }

  /// Navigate to Issue Details screen (for advisors)
  void navigateToIssueDetails(
    BuildContext context,
    Map<String, dynamic> issue,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IssueDetailsScreen(issue: issue)),
    );
  }

  /// Navigate to Login screen
  void navigateToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false, // Remove all previous routes
    );
  }

  /// Get role display name
  String getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'advisor':
      case 'agricultural_advisor':
        return 'Agricultural Advisor';
      case 'expert':
        return 'Agricultural Expert';
      case 'farmer':
      case 'agricultural_farmer':
        return 'Farmer';
      case 'policymaker':
        return 'Policy Maker';
      default:
        return 'Farmer';
    }
  }

  /// Get role icon
  IconData getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'advisor':
      case 'agricultural_advisor':
      case 'expert':
        return Icons.support_agent;
      case 'farmer':
      case 'agricultural_farmer':
        return Icons.agriculture;
      case 'policymaker':
        return Icons.policy;
      default:
        return Icons.agriculture;
    }
  }

  /// Check if user has advisor permissions
  bool hasAdvisorPermissions(String role) {
    switch (role.toLowerCase()) {
      case 'advisor':
      case 'agricultural_advisor':
      case 'expert':
        return true;
      default:
        return false;
    }
  }

  /// Check if user has farmer permissions
  bool hasFarmerPermissions(String role) {
    switch (role.toLowerCase()) {
      case 'farmer':
      case 'agricultural_farmer':
        return true;
      default:
        return false;
    }
  }

  /// Get available features for a role
  List<String> getAvailableFeatures(String role) {
    switch (role.toLowerCase()) {
      case 'advisor':
      case 'agricultural_advisor':
      case 'expert':
        return [
          'View Issues',
          'Update Issue Status',
          'Manage Farmers',
          'Analytics Dashboard',
        ];
      case 'farmer':
      case 'agricultural_farmer':
        return ['Chat with AI', 'Ask Expert', 'Community', 'Settings'];
      case 'policymaker':
        return ['View Analytics', 'Policy Management', 'Reports'];
      default:
        return ['Chat with AI', 'Ask Expert', 'Community', 'Settings'];
    }
  }
}
