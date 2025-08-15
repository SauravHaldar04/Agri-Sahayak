class FarmerIssue {
  final String issueId;
  final String farmerName;
  final String farmerId;
  final String query;
  final DateTime timestamp;
  final bool isResolved;

  const FarmerIssue({
    required this.issueId,
    required this.farmerName,
    required this.farmerId,
    required this.query,
    required this.timestamp,
    required this.isResolved,
  });
}
