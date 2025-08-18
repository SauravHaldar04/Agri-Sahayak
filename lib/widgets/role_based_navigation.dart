import 'package:flutter/material.dart';
import '../services/routing_service.dart';

class RoleBasedNavigation extends StatelessWidget {
  final String userRole;
  final String userName;
  final VoidCallback? onLogout;

  const RoleBasedNavigation({
    super.key,
    required this.userRole,
    required this.userName,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final routingService = RoutingService();
    final roleDisplayName = routingService.getRoleDisplayName(userRole);
    final roleIcon = routingService.getRoleIcon(userRole);
    final availableFeatures = routingService.getAvailableFeatures(userRole);

    return Drawer(
      child: Column(
        children: [
          // User info header
          UserAccountsDrawerHeader(
            accountName: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(roleDisplayName),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(roleIcon, size: 40, color: Colors.green.shade600),
            ),
            decoration: BoxDecoration(color: Colors.green.shade600),
          ),

          // Navigation items based on role
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Role-specific navigation items
                if (routingService.hasAdvisorPermissions(userRole)) ...[
                  _buildNavigationItem(
                    context,
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    subtitle: 'View all issues',
                    onTap: () {
                      Navigator.pop(context);
                      // Already on dashboard, just close drawer
                    },
                  ),
                  _buildNavigationItem(
                    context,
                    icon: Icons.assignment,
                    title: 'Issues',
                    subtitle: 'Manage agricultural issues',
                    onTap: () {
                      Navigator.pop(context);
                      // Already on issues view, just close drawer
                    },
                  ),
                  _buildNavigationItem(
                    context,
                    icon: Icons.people,
                    title: 'Farmers',
                    subtitle: 'View farmer profiles',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to farmers list
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Farmers list coming soon!'),
                        ),
                      );
                    },
                  ),
                  _buildNavigationItem(
                    context,
                    icon: Icons.analytics,
                    title: 'Analytics',
                    subtitle: 'View reports and statistics',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to analytics
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Analytics dashboard coming soon!'),
                        ),
                      );
                    },
                  ),
                ] else if (routingService.hasFarmerPermissions(userRole)) ...[
                  _buildNavigationItem(
                    context,
                    icon: Icons.chat_bubble,
                    title: 'Chat with AI',
                    subtitle: 'Get instant agricultural advice',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to chat screen
                    },
                  ),
                  _buildNavigationItem(
                    context,
                    icon: Icons.support_agent,
                    title: 'Ask Expert',
                    subtitle: 'Submit issues to advisors',
                    onTap: () {
                      Navigator.pop(context);
                      RoutingService().navigateToAskExpert(context);
                    },
                  ),
                  _buildNavigationItem(
                    context,
                    icon: Icons.groups,
                    title: 'Community',
                    subtitle: 'Connect with other farmers',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to community screen
                    },
                  ),
                  _buildNavigationItem(
                    context,
                    icon: Icons.history,
                    title: 'My Issues',
                    subtitle: 'View your submitted issues',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to my issues
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('My Issues coming soon!')),
                      );
                    },
                  ),
                ],

                const Divider(),

                // Common navigation items
                _buildNavigationItem(
                  context,
                  icon: Icons.person,
                  title: 'Profile',
                  subtitle: 'View and edit your profile',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to profile
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile page coming soon!'),
                      ),
                    );
                  },
                ),
                _buildNavigationItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'App preferences and configuration',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings
                  },
                ),
                _buildNavigationItem(
                  context,
                  icon: Icons.help,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to help
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help & Support coming soon!'),
                      ),
                    );
                  },
                ),

                const Divider(),

                // Logout
                _buildNavigationItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  onTap: () {
                    Navigator.pop(context);
                    onLogout?.call();
                  },
                ),
              ],
            ),
          ),

          // Footer with app info
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Agri Sahayak',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Agricultural Support Platform',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade600),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      onTap: onTap,
    );
  }
}
