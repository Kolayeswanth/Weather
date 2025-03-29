import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../services/weather_services.dart';
import '../models/weather_models.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // API key
  final _weatherServices = WeatherServices('9bb365ddbb4d1d78cf24064f98059fe5');
  Weather? _weather;
  String _errorMessage = '';
  bool _isLoading = true;
  bool _isApiKeyValid = false;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  // Test API key before attempting to fetch weather
  Future<void> _checkApiKey() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      bool isValid = await _weatherServices.testApiKey();
      setState(() {
        _isApiKeyValid = isValid;
      });

      if (isValid) {
        _fetchWeather();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid API key. Please check your OpenWeatherMap API key.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error validating API key: $e';
      });
      print('API key validation error: $e');
    }
  }

  Future<void> _fetchWeather() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final weather = await _weatherServices.getWeatherByLocation();
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching weather data: $e';
      });
      print('Error fetching weather: $e');
    }
  }

  // Weather animation
  String getWeatherAnimation(String mainCondition) {
    switch (mainCondition.toLowerCase()) {
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'clouds':
      case 'mist':
      case 'fog':
      case 'haze':
        return 'assets/cloudy.json';
      case 'clear':
        return 'assets/sunny.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'snow':
        return 'assets/snow.json';
      default:
        return 'assets/cloudy.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isApiKeyValid ? _fetchWeather : _checkApiKey,
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingView();
    } else if (_errorMessage.isNotEmpty) {
      return _buildErrorView();
    } else if (_weather != null) {
      return _buildWeatherView();
    } else {
      return _buildNoDataView();
    }
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading weather data...'),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            if (_errorMessage.contains('API key')) ...[
              Text(
                'Your API key may not be activated yet or may be invalid. If you just created it, please wait up to 2 hours for activation.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: _isApiKeyValid ? _fetchWeather : _checkApiKey,
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No weather data available.'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchWeather,
            child: Text('Get Weather'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherView() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // City name
              Text(
                _weather!.cityName,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              
              // Weather animation
              Lottie.asset(
                getWeatherAnimation(_weather!.mainCondition),
                height: 200,
                width: 200,
              ),
              SizedBox(height: 16),
              
              // Temperature and condition
              Text(
                '${_weather!.temperature.toStringAsFixed(1)}°C',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _weather!.mainCondition,
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 32),
              
              // Display hourly forecast if available
              if (_weather!.hourlyForecast != null && _weather!.hourlyForecast!.isNotEmpty)
                _buildHourlyForecast(),
              
              SizedBox(height: 32),
              
              // Display daily forecast if available
              if (_weather!.dailyForecast != null && _weather!.dailyForecast!.isNotEmpty)
                _buildDailyForecast(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyForecast() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hourly Forecast',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _weather!.hourlyForecast!.length,
            itemBuilder: (context, index) {
              final hourly = _weather!.hourlyForecast![index];
              final time = DateTime.fromMillisecondsSinceEpoch(hourly.timestamp * 1000);
              return Container(
                width: 80,
                margin: EdgeInsets.symmetric(horizontal: 4),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('${time.hour}:00'),
                    Icon(_getWeatherIcon(hourly.condition)),
                    Text('${hourly.temperature.toStringAsFixed(1)}°C'),
                    if (hourly.precipitation > 0)
                      Text('${hourly.precipitation.toStringAsFixed(0)}%'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecast() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '7-Day Forecast',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _weather!.dailyForecast!.length,
            itemBuilder: (context, index) {
              final daily = _weather!.dailyForecast![index];
              final date = DateTime.fromMillisecondsSinceEpoch(daily.timestamp * 1000);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        _getDayName(date),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(_getWeatherIcon(daily.condition)),
                    if (daily.precipitation > 0)
                      Text('${daily.precipitation.toStringAsFixed(0)}%'),
                    Row(
                      children: [
                        Text('${daily.tempMin.toStringAsFixed(0)}°'),
                        SizedBox(width: 8),
                        Text('${daily.tempMax.toStringAsFixed(0)}°'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getDayName(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day) return 'Today';
    if (date.day == now.day + 1) return 'Tomorrow';
    
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return Icons.water_drop;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.cloud;
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      default:
        return Icons.cloud;
    }
  }
}