import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = "YOUR_OPENWEATHER_API_KEY";

  static Future<Map<String, dynamic>> fetchWeather(String city) async {
    try {
      // Logic: Strip "[CITY] " prefix and extract city for API
      String cityName = city.split(']')[0].replaceAll('[', '').trim();
      if (cityName.isEmpty) cityName = "Pune";
      
      final url = "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric";
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'temp': (data['main']['temp'] as num).toDouble(),
          'humidity': (data['main']['humidity'] as num).toDouble(),
          'desc': data['weather'][0]['description'] as String,
        };
      } else {
        return {'temp': 28.5, 'humidity': 72.0, 'desc': 'Cloudy (Fallback)'};
      }
    } catch (e) {
      return {'temp': 28.5, 'humidity': 72.0, 'desc': 'Offline (Fallback)'};
    }
  }
}
