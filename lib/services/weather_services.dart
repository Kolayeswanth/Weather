import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather/models/weather_models.dart';

class WeatherServices {
  static const Base_Url = 'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherServices(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    final url = '$Base_Url?q=$cityName&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return Weather.fromJson(json);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<String> getCurrentCity() async {
  try {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: Duration(seconds: 10),
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude
    );

    String? city = placemarks[0].locality;
    return city ?? 'Unknown';
  } catch (e) {
    print('Error getting location: $e');
    rethrow;
  }
}

Future<Weather> getWeatherByLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: Duration(seconds: 10),
    );
    
    final url = '$Base_Url?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return Weather.fromJson(json);
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error getting weather by location: $e');
    rethrow;
  }
}
}