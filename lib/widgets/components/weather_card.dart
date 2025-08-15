import 'package:flutter/material.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  @override
  Widget build(BuildContext context) {
    final weatherData = widget.data;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getWeatherGradient(weatherData['condition'] ?? 'sunny'),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main weather info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Animated weather icon
                    TweenAnimationBuilder<double>(
                      duration: const Duration(seconds: 2),
                      tween: Tween(begin: 0.8, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: _buildWeatherIcon(
                            weatherData['condition'] ?? 'sunny',
                            size: 48,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${weatherData['temperature'] ?? '25'}°C',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            weatherData['description'] ?? 'Partly Cloudy',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white30, height: 1),
                const SizedBox(height: 16),
                // Secondary weather info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeatherMetric(
                      Icons.thermostat,
                      'High/Low',
                      '${weatherData['highTemp'] ?? '28'}° / ${weatherData['lowTemp'] ?? '18'}°',
                    ),
                    _buildWeatherMetric(
                      Icons.water_drop,
                      'Humidity',
                      '${weatherData['humidity'] ?? '65'}%',
                    ),
                    _buildWeatherMetric(
                      Icons.cloud,
                      'Rain',
                      '${weatherData['rainProbability'] ?? '20'}%',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Expandable forecast section
          _buildExpandableForecast(weatherData),
        ],
      ),
    );
  }

  List<Color> _getWeatherGradient(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return [Colors.blue.shade400, Colors.blue.shade600];
      case 'cloudy':
      case 'partly_cloudy':
        return [Colors.grey.shade400, Colors.grey.shade600];
      case 'rainy':
      case 'rain':
        return [Colors.blue.shade600, Colors.blue.shade800];
      case 'stormy':
      case 'thunderstorm':
        return [Colors.grey.shade600, Colors.grey.shade800];
      default:
        return [Colors.blue.shade400, Colors.blue.shade600];
    }
  }

  Widget _buildWeatherIcon(String condition, {double size = 24}) {
    IconData iconData;
    Color iconColor;

    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        iconData = Icons.wb_sunny;
        iconColor = Colors.orange;
        break;
      case 'cloudy':
      case 'partly_cloudy':
        iconData = Icons.cloud;
        iconColor = Colors.white;
        break;
      case 'rainy':
      case 'rain':
        iconData = Icons.grain;
        iconColor = Colors.blue.shade200;
        break;
      case 'stormy':
      case 'thunderstorm':
        iconData = Icons.flash_on;
        iconColor = Colors.yellow;
        break;
      default:
        iconData = Icons.wb_sunny;
        iconColor = Colors.orange;
    }

    return Icon(iconData, size: size, color: iconColor);
  }

  Widget _buildWeatherMetric(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableForecast(Map<String, dynamic> weatherData) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isExpanded = weatherData['isExpanded'] ?? false;

        return Column(
          children: [
            // Expandable indicator
            GestureDetector(
              onTap: () {
                setState(() {
                  weatherData['isExpanded'] = !isExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isExpanded ? 'Hide Forecast' : '5-Day Forecast',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Forecast content
            if (isExpanded)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 130,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _buildForecastDays(weatherData),
                ),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _buildForecastDays(Map<String, dynamic> weatherData) {
    final forecast = weatherData['forecast'] as List<dynamic>? ?? [];
    if (forecast.isEmpty) {
      // Generate dummy forecast data
      return List.generate(5, (index) {
        final day = DateTime.now().add(Duration(days: index + 1));
        return _buildForecastDay(
          day: day,
          condition: [
            'sunny',
            'cloudy',
            'rainy',
            'partly_cloudy',
            'sunny',
          ][index],
          highTemp: [28, 26, 24, 27, 29][index],
          lowTemp: [18, 16, 14, 17, 19][index],
        );
      });
    }

    return forecast.map((dayData) {
      return _buildForecastDay(
        day: DateTime.parse(dayData['date'] ?? DateTime.now().toString()),
        condition: dayData['condition'] ?? 'sunny',
        highTemp: dayData['highTemp'] ?? 25,
        lowTemp: dayData['lowTemp'] ?? 15,
      );
    }).toList();
  }

  Widget _buildForecastDay({
    required DateTime day,
    required String condition,
    required int highTemp,
    required int lowTemp,
  }) {
    return Column(
      children: [
        Text(
          _getDayName(day.weekday),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildWeatherIcon(condition, size: 24),
        const SizedBox(height: 8),
        Text(
          '$highTemp°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '$lowTemp°',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return 'Mon';
    }
  }
}
