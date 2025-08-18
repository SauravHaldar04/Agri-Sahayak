import 'package:flutter/material.dart';
import 'issue_list_item.dart';

class IssuePriorityCard extends StatefulWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final List<Map<String, dynamic>> issues;
  final Function(Map<String, dynamic>) onIssueTap;

  const IssuePriorityCard({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    required this.issues,
    required this.onIssueTap,
  });

  @override
  State<IssuePriorityCard> createState() => _IssuePriorityCardState();
}

class _IssuePriorityCardState extends State<IssuePriorityCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: widget.color,
                          ),
                        ),
                        Text(
                          '${widget.count} issue${widget.count != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.color,
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (_isExpanded) ...[
            const Divider(height: 1),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.issues.length,
                itemBuilder: (context, index) {
                  final issue = widget.issues[index];
                  return IssueListItem(
                    issue: issue,
                    onTap: () => widget.onIssueTap(issue),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
