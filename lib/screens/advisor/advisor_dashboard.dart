import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../services/routing_service.dart';
import '../../widgets/issue_priority_card.dart';
import '../../widgets/issue_list_item.dart';
import '../../widgets/role_based_navigation.dart';

class AdvisorDashboard extends StatefulWidget {
  const AdvisorDashboard({super.key});

  @override
  State<AdvisorDashboard> createState() => _AdvisorDashboardState();
}

class _AdvisorDashboardState extends State<AdvisorDashboard>
    with TickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  late TabController _tabController;

  List<Map<String, dynamic>> _allIssues = [];
  List<Map<String, dynamic>> _criticalIssues = [];
  List<Map<String, dynamic>> _highIssues = [];
  List<Map<String, dynamic>> _mediumIssues = [];
  List<Map<String, dynamic>> _lowIssues = [];
  List<Map<String, dynamic>> _openIssues = [];
  List<Map<String, dynamic>> _inProgressIssues = [];
  List<Map<String, dynamic>> _resolvedIssues = [];

  bool _isLoading = true;
  String _userRole = 'advisor';
  String _userName = 'Advisor';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadIssues();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadIssues() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final issues = await _supabaseService.getAllIssues();

      setState(() {
        _allIssues = issues;
        _categorizeIssues(issues);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading issues: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _categorizeIssues(List<Map<String, dynamic>> issues) {
    _criticalIssues = issues
        .where((issue) => issue['severity'] == 'critical')
        .toList();
    _highIssues = issues.where((issue) => issue['severity'] == 'high').toList();
    _mediumIssues = issues
        .where((issue) => issue['severity'] == 'medium')
        .toList();
    _lowIssues = issues.where((issue) => issue['severity'] == 'low').toList();

    _openIssues = issues.where((issue) => issue['status'] == 'open').toList();
    _inProgressIssues = issues
        .where((issue) => issue['status'] == 'in_progress')
        .toList();
    _resolvedIssues = issues
        .where((issue) => issue['status'] == 'resolved')
        .toList();
  }

  Future<void> _loadUserInfo() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;
      if (user != null) {
        final userProfile = await authProvider.getUserProfile(user.id);
        if (userProfile != null) {
          setState(() {
            _userRole = userProfile['role'] ?? 'advisor';
            _userName = userProfile['full_name'] ?? user.email ?? 'Advisor';
          });
        }
      }
    } catch (e) {
      // Use default values if loading fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      drawer: RoleBasedNavigation(
        userRole: _userRole,
        userName: _userName,
        onLogout: () async {
          final authProvider = context.read<AuthProvider>();
          await authProvider.signOut();
        },
      ),
      appBar: AppBar(
        title: const Text('Advisor Dashboard'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadIssues,
            tooltip: 'Refresh Issues',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Priority', icon: Icon(Icons.priority_high)),
            Tab(text: 'Status', icon: Icon(Icons.assignment)),
            Tab(text: 'Type', icon: Icon(Icons.category)),
            Tab(text: 'All', icon: Icon(Icons.list)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPriorityView(),
                _buildStatusView(),
                _buildTypeView(),
                _buildAllIssuesView(),
              ],
            ),
    );
  }

  Widget _buildPriorityView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Critical Issues
          if (_criticalIssues.isNotEmpty) ...[
            IssuePriorityCard(
              title: 'Critical Issues',
              count: _criticalIssues.length,
              color: Colors.red,
              icon: Icons.warning,
              issues: _criticalIssues,
              onIssueTap: (issue) => _showIssueDetails(issue),
            ),
            const SizedBox(height: 16),
          ],

          // High Priority Issues
          if (_highIssues.isNotEmpty) ...[
            IssuePriorityCard(
              title: 'High Priority',
              count: _highIssues.length,
              color: Colors.orange,
              icon: Icons.error,
              issues: _highIssues,
              onIssueTap: (issue) => _showIssueDetails(issue),
            ),
            const SizedBox(height: 16),
          ],

          // Medium Priority Issues
          if (_mediumIssues.isNotEmpty) ...[
            IssuePriorityCard(
              title: 'Medium Priority',
              count: _mediumIssues.length,
              color: Colors.yellow.shade700,
              icon: Icons.info,
              issues: _mediumIssues,
              onIssueTap: (issue) => _showIssueDetails(issue),
            ),
            const SizedBox(height: 16),
          ],

          // Low Priority Issues
          if (_lowIssues.isNotEmpty) ...[
            IssuePriorityCard(
              title: 'Low Priority',
              count: _lowIssues.length,
              color: Colors.green,
              icon: Icons.check_circle,
              issues: _lowIssues,
              onIssueTap: (issue) => _showIssueDetails(issue),
            ),
          ],

          // Empty state
          if (_allIssues.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No issues found',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All agricultural issues have been resolved!',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Open Issues
          if (_openIssues.isNotEmpty) ...[
            IssuePriorityCard(
              title: 'Open Issues',
              count: _openIssues.length,
              color: Colors.red,
              icon: Icons.radio_button_unchecked,
              issues: _openIssues,
              onIssueTap: (issue) => _showIssueDetails(issue),
            ),
            const SizedBox(height: 16),
          ],

          // In Progress Issues
          if (_inProgressIssues.isNotEmpty) ...[
            IssuePriorityCard(
              title: 'In Progress',
              count: _inProgressIssues.length,
              color: Colors.blue,
              icon: Icons.pending,
              issues: _inProgressIssues,
              onIssueTap: (issue) => _showIssueDetails(issue),
            ),
            const SizedBox(height: 16),
          ],

          // Resolved Issues
          if (_resolvedIssues.isNotEmpty) ...[
            IssuePriorityCard(
              title: 'Resolved',
              count: _resolvedIssues.length,
              color: Colors.green,
              icon: Icons.check_circle,
              issues: _resolvedIssues,
              onIssueTap: (issue) => _showIssueDetails(issue),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeView() {
    final pestIssues = _allIssues
        .where((issue) => issue['issue_type'] == 'pest')
        .toList();
    final diseaseIssues = _allIssues
        .where((issue) => issue['issue_type'] == 'disease')
        .toList();
    final nutrientIssues = _allIssues
        .where((issue) => issue['issue_type'] == 'nutrient')
        .toList();
    final weatherIssues = _allIssues
        .where((issue) => issue['issue_type'] == 'weather')
        .toList();
    final irrigationIssues = _allIssues
        .where((issue) => issue['issue_type'] == 'irrigation')
        .toList();
    final soilIssues = _allIssues
        .where((issue) => issue['issue_type'] == 'soil')
        .toList();
    final otherIssues = _allIssues
        .where((issue) => issue['issue_type'] == 'other')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pestIssues.isNotEmpty) ...[
            IssuePriorityCard(
              title: 'Pest Issues',
              count: pestIssues.length,
              color: Colors.red.shade600,
              icon: Icons.bug_report,
              issues: pestIssues,
              onIssueTap: (issue) => _showIssueDetails(issue),
            ),
            const SizedBox(height: 16),
          ],

          if (diseaseIssues.isNotEmpty) ...[
            IssuePriorityCard(
              title: 'Disease Issues',
              count: diseaseIssues.length,
              color: Colors.purple,
              icon: Icons.healing,
              issues: diseaseIssues,
              onIssueTap: (issue) => _showIssueDetails(issue),
            ),
            const SizedBox(height: 16),
          ],

          if (nutrientIssues.isNotEmpty) ...[
            IssuePriorityCard(
              title: 'Nutrient Issues',
              count: nutrientIssues.length,
              color: Colors.orange,
              icon: Icons.grass,
              issues: nutrientIssues,
              onIssueTap: (issue) => _showIssueDetails(issue),
            ),
            const SizedBox(height: 16),
          ],

          if (weatherIssues.isNotEmpty) ...[
            IssuePriorityCard(
              title: 'Weather Issues',
              count: weatherIssues.length,
              color: Colors.blue,
              icon: Icons.cloud,
              issues: weatherIssues,
              onIssueTap: (issue) => _showIssueDetails(issue),
            ),
            const SizedBox(height: 16),
          ],

          if (irrigationIssues.isNotEmpty) ...[
            IssuePriorityCard(
              title: 'Irrigation Issues',
              count: irrigationIssues.length,
              color: Colors.cyan,
              icon: Icons.water_drop,
              issues: irrigationIssues,
              onIssueTap: (issue) => _showIssueDetails(issue),
            ),
            const SizedBox(height: 16),
          ],

          if (soilIssues.isNotEmpty) ...[
            IssuePriorityCard(
              title: 'Soil Issues',
              count: soilIssues.length,
              color: Colors.brown,
              icon: Icons.landscape,
              issues: soilIssues,
              onIssueTap: (issue) => _showIssueDetails(issue),
            ),
            const SizedBox(height: 16),
          ],

          if (otherIssues.isNotEmpty) ...[
            IssuePriorityCard(
              title: 'Other Issues',
              count: otherIssues.length,
              color: Colors.grey,
              icon: Icons.more_horiz,
              issues: otherIssues,
              onIssueTap: (issue) => _showIssueDetails(issue),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllIssuesView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allIssues.length,
      itemBuilder: (context, index) {
        final issue = _allIssues[index];
        return IssueListItem(
          issue: issue,
          onTap: () => _showIssueDetails(issue),
        );
      },
    );
  }

  void _showIssueDetails(Map<String, dynamic> issue) {
    RoutingService().navigateToIssueDetails(context, issue);
  }
}
