import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/models/weather_models.dart';

class WeatherServices {
  static const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';
  static const FORECAST_URL = 'https://api.openweathermap.org/data/2.5/onecall';
  final String apiKey;

  WeatherServices(this.apiKey);

  // Simple method to test API key validity
  Future<bool> testApiKey() async {
    try {
      final testUrl = '$BASE_URL?q=London&appid=$apiKey&units=metric';
      print('Testing API key with URL: $testUrl');
      
      final response = await http.get(Uri.parse(testUrl));
      print('Test response status: ${response.statusCode}');
      print('Test response body: ${response.body.substring(0, 100)}...');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error testing API key: $e');
      return false;
    }
  }

  Future<Weather> getWeather(String cityName) async {
    final url = '$BASE_URL?q=$cityName&appid=$apiKey&units=metric';
    print('Requesting city weather: $url');
    
    final response = await http.get(Uri.parse(url));
    print('Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Weather.fromJson(json);
    } else {
      print('Error response: ${response.body}');
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }

  Future<String> getCurrentCity() async {
    try {
      // Check location services status
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      } 

      // Get device position
      print('Getting current position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
      print('Position obtained: Lat: ${position.latitude}, Lon: ${position.longitude}');

      // Get city name from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude
      );

      String? city = placemarks[0].locality;
      print('City detected: ${city ?? "Unknown"}');
      return city ?? 'Unknown';
    } catch (e) {
      print('Error getting location: $e');
      rethrow;
    }
  }

  Future<Weather> getWeatherByLocation() async {
    try {
      // Check if we're online
      final isOnline = await _hasInternetConnection();
      print('Internet connection: ${isOnline ? "Online" : "Offline"}');
      
      // Try to get data from local storage for offline mode
      final prefs = await SharedPreferences.getInstance();
      final hasStoredData = prefs.containsKey('last_weather_data');
      
      // If offline and we have stored data, use it
      if (!isOnline && hasStoredData) {
        print('Using cached weather data (offline mode)');
        final storedData = prefs.getString('last_weather_data');
        final decodedData = jsonDecode(storedData!);
        return Weather.fromStoredJson(decodedData);
      }
      
      // Get the current position
      print('Getting current position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
      print('Position obtained: Lat: ${position.latitude}, Lon: ${position.longitude}');
      
      // First try to get current weather (simpler request)
      final weatherUrl = '$BASE_URL?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric';
      print('Requesting current weather: $weatherUrl');
      
      final weatherResponse = await http.get(Uri.parse(weatherUrl));
      print('Current weather response status: ${weatherResponse.statusCode}');
      
      if (weatherResponse.statusCode == 200) {
        final weatherJson = jsonDecode(weatherResponse.body);
        final currentWeather = Weather.fromJson(weatherJson);
        
        // Now try to get forecast data (if current weather was successful)
        try {
          // The 'onecall' endpoint is for paid API plans
          // Check if your plan supports this
          final forecastUrl = '$FORECAST_URL?lat=${position.latitude}&lon=${position.longitude}&exclude=minutely&appid=$apiKey&units=metric';
          print('Requesting forecast: $forecastUrl');
          
          final forecastResponse = await http.get(Uri.parse(forecastUrl));
          print('Forecast response status: ${forecastResponse.statusCode}');
          
          if (forecastResponse.statusCode == 200) {
            final forecastJson = jsonDecode(forecastResponse.body);
            
            // Add the hourly forecast data (next 24 hours)
            final List<HourlyForecast> hourlyList = [];
            if (forecastJson.containsKey('hourly')) {
              for (var i = 0; i < 24 && i < forecastJson['hourly'].length; i++) {
                hourlyList.add(HourlyForecast.fromJson(forecastJson['hourly'][i]));
              }
            }
            
            // Add the daily forecast data (7 days)
            final List<DailyForecast> dailyList = [];
            if (forecastJson.containsKey('daily')) {
              for (var i = 0; i < 7 && i < forecastJson['daily'].length; i++) {
                dailyList.add(DailyForecast.fromJson(forecastJson['daily'][i]));
              }
            }
            
            // Add weather alerts if available
            final List<WeatherAlert> alertsList = [];
            if (forecastJson.containsKey('alerts')) {
              for (var alertJson in forecastJson['alerts']) {
                alertsList.add(WeatherAlert.fromJson(alertJson));
              }
            }
            
            // Create complete weather object with forecast data
            final completeWeather = Weather(
              cityName: currentWeather.cityName,
              temperature: currentWeather.temperature,
              mainCondition: currentWeather.mainCondition,
              hourlyForecast: hourlyList,
              dailyForecast: dailyList,
              alerts: alertsList,
            );
            
            // Save to local storage for offline mode
            final jsonData = jsonEncode(completeWeather.toJson());
            await prefs.setString('last_weather_data', jsonData);
            
            return completeWeather;
          } else {
            print('Forecast error response: ${forecastResponse.body}');
            // If forecast fails but current weather succeeded, return basic weather
            print('Using basic weather data (forecast failed)');
            
            // Save basic weather to cache
            final jsonData = jsonEncode(currentWeather.toJson());
            await prefs.setString('last_weather_data', jsonData);
            
            return currentWeather;
          }
        } catch (forecastError) {
          print('Error getting forecast: $forecastError');
          // Return basic weather if forecast fails
          return currentWeather;
        }
      } else {
        print('Weather error response: ${weatherResponse.body}');
        throw Exception('Failed to load current weather data: ${weatherResponse.statusCode}');
      }
    } catch (e) {
      print('Error getting weather by location: $e');
      
      // Try to use cached data if available
      try {
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('last_weather_data')) {
          print('Using cached weather data after error');
          final storedData = prefs.getString('last_weather_data');
          final decodedData = jsonDecode(storedData!);
          return Weather.fromStoredJson(decodedData);
        }
      } catch (offlineError) {
        print('Error getting offline data: $offlineError');
      }
      
      rethrow;
    }
  }
  
  // Check for internet connectivity
  Future<bool> _hasInternetConnection() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      print('Internet check failed: $e');
      return false;
    }
  }
}