import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../services/weather_services.dart';
import '../models/weather_models.dart';
import '../widgets/footer_widget.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // API key
  final _weatherServices = WeatherServices('9bb365ddbb4d1d78cf24064f98059fe5');
  Weather? _weather;
  // ignore: unused_field
  String _errorMessage = '';

  _fetchWeather() async {
    try {
      final weather = await _weatherServices.getWeatherByLocation();
      setState(() {
        _weather = weather;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching weather data. Please try again.';
      });
      print(e);
    }
  }

  // Weather animation
  String getWeatherAnimation(String mainCondition) {
    switch (mainCondition) {
      case 'Rain':
        return 'assets/rainy.json';
      case 'Clouds':
        return 'assets/cloudy.json';
      case 'Clear':
        return 'assets/sunny.json';
      case 'thunder':
        return 'assets/thunder.json';
      case 'Clouds and sun':
        return 'assets/sun.json';
      default:
        return 'assets/cloudy.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_weather?.cityName ?? 'Loading City...'),
            Lottie.asset(
              getWeatherAnimation(_weather?.mainCondition ?? ''),
            ),
            Text(_weather?.temperature.toString() ?? ''),
            Text(_weather?.mainCondition ?? ''),
          ],
        ),
      ),
    );
  }
}
