import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secrets.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static String get _apiKey => Secrets.openWeatherApiKey;

  /// Get current weather for a location
  static Future<Map<String, dynamic>> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseCurrentWeather(data);
      } else {
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather: $e');
      return _getDefaultWeatherData();
    }
  }

  /// Get 5-day forecast for a location
  static Future<Map<String, dynamic>> getForecast({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/forecast?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseForecast(data);
      } else {
        throw Exception('Failed to load forecast: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching forecast: $e');
      return _getDefaultForecastData();
    }
  }

  /// Parse current weather data from OpenWeather API response
  static Map<String, dynamic> _parseCurrentWeather(Map<String, dynamic> data) {
    final weather = data['weather']?[0] ?? {};
    final main = data['main'] ?? {};
    final wind = data['wind'] ?? {};

    return {
      'temperature': main['temp']?.round() ?? 25,
      'highTemp': main['temp_max']?.round() ?? 28,
      'lowTemp': main['temp_min']?.round() ?? 18,
      'humidity': main['humidity']?.round() ?? 65,
      'condition': _mapWeatherCondition(weather['main'] ?? 'Clear'),
      'description': weather['description'] ?? 'Clear sky',
      'rainProbability': _calculateRainProbability(data),
      'windSpeed': wind['speed']?.round() ?? 5,
      'location': data['name'] ?? 'Current Location',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Parse forecast data from OpenWeather API response
  static Map<String, dynamic> _parseForecast(Map<String, dynamic> data) {
    final list = data['list'] as List<dynamic>? ?? [];
    final dailyData = <Map<String, dynamic>>[];

    // Group by day and get daily averages
    final dailyMap = <String, List<Map<String, dynamic>>>{};

    for (final item in list) {
      final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dayKey =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

      if (!dailyMap.containsKey(dayKey)) {
        dailyMap[dayKey] = [];
      }
      dailyMap[dayKey]!.add(item);
    }

    // Calculate daily averages
    dailyMap.forEach((dayKey, items) {
      if (dailyData.length < 5) {
        // Only first 5 days
        final temps = items.map((e) => e['main']['temp'] as double).toList();
        final conditions = items
            .map((e) => e['weather'][0]['main'] as String)
            .toList();

        dailyData.add({
          'date': dayKey,
          'highTemp': temps.reduce((a, b) => a > b ? a : b).round(),
          'lowTemp': temps.reduce((a, b) => a < b ? a : b).round(),
          'condition': _getMostFrequentCondition(conditions),
        });
      }
    });

    return {'forecast': dailyData};
  }

  /// Map OpenWeather condition codes to our condition names
  static String _mapWeatherCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'sunny';
      case 'clouds':
        return 'cloudy';
      case 'rain':
      case 'drizzle':
        return 'rainy';
      case 'thunderstorm':
        return 'stormy';
      case 'snow':
        return 'snowy';
      case 'mist':
      case 'fog':
        return 'foggy';
      default:
        return 'sunny';
    }
  }

  /// Get most frequent weather condition for a day
  static String _getMostFrequentCondition(List<String> conditions) {
    final frequency = <String, int>{};
    for (final condition in conditions) {
      frequency[condition] = (frequency[condition] ?? 0) + 1;
    }

    String mostFrequent = conditions.first;
    int maxCount = 0;

    frequency.forEach((condition, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequent = condition;
      }
    });

    return _mapWeatherCondition(mostFrequent);
  }

  /// Calculate rain probability from OpenWeather data
  static int _calculateRainProbability(Map<String, dynamic> data) {
    final pop = data['pop'] as double? ?? 0.0;
    return (pop * 100).round();
  }

  /// Get default weather data when API fails
  static Map<String, dynamic> _getDefaultWeatherData() {
    return {
      'temperature': 25,
      'highTemp': 28,
      'lowTemp': 18,
      'humidity': 65,
      'condition': 'sunny',
      'description': 'Partly Cloudy',
      'rainProbability': 20,
      'windSpeed': 5,
      'location': 'Current Location',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Get default forecast data when API fails
  static Map<String, dynamic> _getDefaultForecastData() {
    return {
      'forecast': List.generate(5, (index) {
        final day = DateTime.now().add(Duration(days: index + 1));
        return {
          'date':
              '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
          'highTemp': 25 + (index % 3),
          'lowTemp': 15 + (index % 3),
          'condition': [
            'sunny',
            'cloudy',
            'rainy',
            'partly_cloudy',
            'sunny',
          ][index],
        };
      }),
    };
  }

  /// Get weather by city name
  static Future<Map<String, dynamic>> getWeatherByCity(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseCurrentWeather(data);
      } else {
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather by city: $e');
      return _getDefaultWeatherData();
    }
  }
}
