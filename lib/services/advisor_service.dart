import '../models/farmer_issue.dart';

class AdvisorService {
  AdvisorService._internal();
  static final AdvisorService instance = AdvisorService._internal();

  Future<List<FarmerIssue>> getFarmerIssues() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return <FarmerIssue>[
      FarmerIssue(
        issueId: 'ISSUE-1001',
        farmerName: 'Ramesh Kumar',
        farmerId: 'F-001',
        query: 'Wheat leaves turning yellow. What should I do? ',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isResolved: false,
      ),
      FarmerIssue(
        issueId: 'ISSUE-1002',
        farmerName: 'Sita Devi',
        farmerId: 'F-002',
        query: 'What is the current MSP for paddy in my district?',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        isResolved: true,
      ),
      FarmerIssue(
        issueId: 'ISSUE-1003',
        farmerName: 'Mahesh Patil',
        farmerId: 'F-003',
        query: 'Drip irrigation setup cost and subsidy details?',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        isResolved: false,
      ),
    ];
  }
}
