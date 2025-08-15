import 'package:flutter/material.dart';
import '../widgets/components/weather_card.dart';
import '../widgets/components/soil_analysis_card.dart';
import '../widgets/components/crop_report_card.dart';
import '../widgets/components/visual_diagnosis_card.dart';
import '../widgets/components/policy_card.dart';
import '../widgets/components/contact_advisor_card.dart';
import '../widgets/components/time_series_chart_card.dart';
import '../widgets/components/comparison_table_card.dart';
import '../widgets/components/step_by_step_guide_card.dart';
import '../widgets/components/interactive_checklist_card.dart';

class ComponentPreviewScreen extends StatefulWidget {
  const ComponentPreviewScreen({super.key});

  @override
  State<ComponentPreviewScreen> createState() => _ComponentPreviewScreenState();
}

class _ComponentPreviewScreenState extends State<ComponentPreviewScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _dummyData = [
    // Weather Card
    {
      'temperature': 28,
      'description': 'Partly Cloudy',
      'highTemp': 32,
      'lowTemp': 22,
      'humidity': 65,
      'rainProbability': 20,
      'condition': 'partly_cloudy',
    },
    // Soil Analysis Card
    {
      'location': 'Amravati District',
      'nitrogen': 'Medium',
      'phosphorus': 'Low',
      'potassium': 'High',
      'ph': '6.8',
      'organicCarbon': '1.2',
    },
    // Crop Report Card
    {
      'cropName': 'Wheat',
      'location': 'Your Farm',
      'growthStage': 'Tillering',
      'health': 'Good',
      'pestRisk': 'Low Risk',
      'marketTrend': 'Stable',
      'nextAction': 'Top Dressing (in ~3 days)',
      'recommendations': 'Apply nitrogen fertilizer and ensure proper irrigation.',
    },
    // Visual Diagnosis Card
    {
      'issue': 'Late Blight Fungus',
      'severity': 'high',
      'confidence': 0.92,
      'solution': 'Apply fungicide and improve air circulation around plants.',
    },
    // Policy Card
    {
      'scheme': 'PM-KISAN',
      'ministry': 'Ministry of Agriculture',
      'benefits': ['₹6,000 per year', 'Direct bank transfer', 'No middlemen'],
      'eligibility': ['Small and marginal farmers', 'Landholding up to 2 hectares'],
      'documents': ['Aadhaar card', 'Land records', 'Bank account details'],
      'amount': '6,000',
    },
    // Contact Advisor Card
    {
      'expertName': 'Dr. Rajesh Kumar',
      'contact': '+91 98765 43210',
    },
    // Time Series Chart Card
    {
      'title': 'Market Price Trends',
      'metric': 'Soybean prices over 30 days',
    },
    // Comparison Table Card
    {
      'title': 'Seed Varieties Comparison',
      'items': 'Drought-resistant maize varieties',
    },
    // Step-by-Step Guide Card
    {
      'title': 'Soil Sampling Process',
      'steps': [
        'Choose representative locations in your field',
        'Use a soil auger to collect samples from 0-15 cm depth',
        'Mix samples thoroughly in a clean container',
        'Send to laboratory for analysis',
        'Follow recommendations based on results',
      ],
    },
    // Interactive Checklist Card
    {
      'title': 'Land Preparation Checklist',
      'tasks': [
        'Clear existing vegetation',
        'Plow the soil to 20-25 cm depth',
        'Level the field properly',
        'Apply organic manure',
        'Prepare seedbeds if needed',
      ],
    },
  ];

  final List<String> _componentNames = [
    'Weather Card',
    'Soil Analysis Card',
    'Crop Report Card',
    'Visual Diagnosis Card',
    'Policy Card',
    'Contact Advisor Card',
    'Time Series Chart Card',
    'Comparison Table Card',
    'Step-by-Step Guide Card',
    'Interactive Checklist Card',
  ];

  Widget _buildComponent(int index) {
    switch (index) {
      case 0:
        return WeatherCard(data: _dummyData[0]);
      case 1:
        return SoilAnalysisCard(data: _dummyData[1]);
      case 2:
        return CropReportCard(data: _dummyData[2]);
      case 3:
        return VisualDiagnosisCard(data: _dummyData[3]);
      case 4:
        return PolicyCard(data: _dummyData[4]);
      case 5:
        return ContactAdvisorCard(data: _dummyData[5]);
      case 6:
        return TimeSeriesChartCard(data: _dummyData[6]);
      case 7:
        return ComparisonTableCard(data: _dummyData[7]);
      case 8:
        return StepByStepGuideCard(data: _dummyData[8]);
      case 9:
        return InteractiveChecklistCard(data: _dummyData[9]);
      default:
        return const Center(child: Text('Component not found'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Preview'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isSmallScreen)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                _showComponentSelector(context);
              },
            ),
        ],
      ),
      body: isSmallScreen 
          ? _buildMobileLayout() 
          : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _componentNames[_selectedIndex],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Preview with dummy data',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Component preview
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: _buildComponent(_selectedIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar navigation
        Container(
          width: 250,
          color: Colors.grey.shade100,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade600,
                child: const Text(
                  'Dynamic UI Components',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _componentNames.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      selected: _selectedIndex == index,
                      selectedTileColor: Colors.green.shade100,
                      leading: Icon(
                        _getComponentIcon(index),
                        color: _selectedIndex == index 
                            ? Colors.green.shade600 
                            : Colors.grey.shade600,
                      ),
                      title: Text(
                        _componentNames[index],
                        style: TextStyle(
                          fontWeight: _selectedIndex == index 
                              ? FontWeight.w600 
                              : FontWeight.normal,
                          color: _selectedIndex == index 
                              ? Colors.green.shade800 
                              : Colors.grey.shade800,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Component preview area
        Expanded(
          child: Container(
            color: Colors.grey.shade50,
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _componentNames[_selectedIndex],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Preview with dummy data',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Component preview
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _buildComponent(_selectedIndex),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showComponentSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Select Component',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _componentNames.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    selected: _selectedIndex == index,
                    selectedTileColor: Colors.green.shade100,
                    leading: Icon(
                      _getComponentIcon(index),
                      color: _selectedIndex == index 
                          ? Colors.green.shade600 
                          : Colors.grey.shade600,
                    ),
                    title: Text(
                      _componentNames[index],
                      style: TextStyle(
                        fontWeight: _selectedIndex == index 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                        color: _selectedIndex == index 
                            ? Colors.green.shade800 
                            : Colors.grey.shade800,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getComponentIcon(int index) {
    switch (index) {
      case 0:
        return Icons.wb_sunny;
      case 1:
        return Icons.science;
      case 2:
        return Icons.agriculture;
      case 3:
        return Icons.medical_services;
      case 4:
        return Icons.policy;
      case 5:
        return Icons.support_agent;
      case 6:
        return Icons.show_chart;
      case 7:
        return Icons.table_chart;
      case 8:
        return Icons.format_list_numbered;
      case 9:
        return Icons.checklist;
      default:
        return Icons.widgets;
    }
  }
}