import 'package:flutter/material.dart';

class SoilAnalysisCard extends StatelessWidget {
  const SoilAnalysisCard({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final soilData = data;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.shade200.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with location
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.brown.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Soil Health Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
                ),
              ),
            ],
          ),
          Text(
            soilData['location'] ?? 'Amravati District',
            style: TextStyle(color: Colors.brown.shade600, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Nutrient gauges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientGauge(
                'N',
                'Nitrogen',
                soilData['nitrogen'] ?? 'Medium',
                Colors.blue,
                soilData,
                context,
              ),
              _buildNutrientGauge(
                'P',
                'Phosphorus',
                soilData['phosphorus'] ?? 'Low',
                Colors.orange,
                soilData,
                context,
              ),
              _buildNutrientGauge(
                'K',
                'Potassium',
                soilData['potassium'] ?? 'High',
                Colors.green,
                soilData,
                context,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Other metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSoilMetric(
                Icons.science,
                'pH Level',
                soilData['ph'] ?? '6.5',
                Colors.purple.shade600,
              ),
              _buildSoilMetric(
                Icons.eco,
                'Organic Carbon',
                '${soilData['organicCarbon'] ?? '0.8'}%',
                Colors.teal.shade600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientGauge(
    String symbol,
    String name,
    String level,
    Color color,
    Map<String, dynamic> soilData,
    BuildContext context,
  ) {
    final gaugeValue = _getNutrientValue(level);
    final gaugeColor = _getNutrientColor(level);

    return GestureDetector(
      onTap: () => _showNutrientInfo(context, name, level, soilData),
      child: Column(
        children: [
          // Gauge meter
          SizedBox(
            height: 80,
            width: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                  ),
                ),
                // Gauge arc
                CustomPaint(
                  size: const Size(80, 80),
                  painter: GaugePainter(
                    value: gaugeValue,
                    color: gaugeColor,
                    strokeWidth: 8,
                  ),
                ),
                // Center text
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      symbol,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: gaugeColor,
                      ),
                    ),
                    Text(
                      level,
                      style: TextStyle(
                        fontSize: 10,
                        color: gaugeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.brown.shade700,
            ),
          ),
        ],
      ),
    );
  }

  double _getNutrientValue(String level) {
    switch (level.toLowerCase()) {
      case 'deficient':
      case 'low':
        return 0.3;
      case 'medium':
      case 'moderate':
        return 0.6;
      case 'high':
      case 'optimal':
        return 0.9;
      case 'surplus':
      case 'excess':
        return 1.0;
      default:
        return 0.6;
    }
  }

  Color _getNutrientColor(String level) {
    switch (level.toLowerCase()) {
      case 'deficient':
      case 'low':
        return Colors.red;
      case 'medium':
      case 'moderate':
        return Colors.orange;
      case 'high':
      case 'optimal':
        return Colors.green;
      case 'surplus':
      case 'excess':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  void _showNutrientInfo(
    BuildContext context,
    String nutrientName,
    String level,
    Map<String, dynamic> soilData,
  ) {
    final recommendations = {
      'Nitrogen':
          'Nitrogen helps leaf growth. Consider a top dressing of Urea.',
      'Phosphorus':
          'Phosphorus promotes root development. Apply DAP fertilizer.',
      'Potassium': 'Potassium improves disease resistance. Use MOP if needed.',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$nutrientName Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Level: $level'),
            const SizedBox(height: 16),
            Text(
              recommendations[nutrientName] ??
                  'No specific recommendation available.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilMetric(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.brown.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Custom painter for gauge meters
class GaugePainter extends CustomPainter {
  final double value;
  final Color color;
  final double strokeWidth;

  GaugePainter({
    required this.value,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background arc
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57, // Start from top (-90 degrees)
      3.14, // 180 degrees (semi-circle)
      false,
      backgroundPaint,
    );

    // Value arc
    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57, // Start from top
      3.14 * value, // Value percentage of 180 degrees
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
