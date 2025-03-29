import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../services/weather_services.dart';
import '../models/weather_models.dart';
import '../providers/theme_provider.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // API key
  final _weatherServices = WeatherServices('7b16079c3b4c0d3cb36de59ca8b4e1c0');
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

  // Get background color based on weather conditions
  Color getBackgroundColor(String mainCondition) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    
    if (isDarkMode) {
      return Colors.grey[900]!;
    }
    
    switch (mainCondition.toLowerCase()) {
      case 'clear':
        return Colors.blue[400]!;
      case 'clouds':
      case 'mist':
      case 'fog':
      case 'haze':
        return Colors.blueGrey[300]!;
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return Colors.blueGrey[400]!;
      case 'thunderstorm':
        return Colors.blueGrey[700]!;
      case 'snow':
        return Colors.lightBlue[100]!;
      default:
        return Colors.blue[400]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _weather != null 
      ? getBackgroundColor(_weather!.mainCondition) 
      : Colors.blue[700];
      
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isApiKeyValid ? _fetchWeather : _checkApiKey,
          ),
        ],
        backgroundColor: backgroundColor,
        elevation: 0, // Remove shadow
      ),
      body: Container(
        decoration: BoxDecoration(
          // Use gradient for better visuals
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor!,
              backgroundColor.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: _buildBody(),
        ),
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
          CircularProgressIndicator(
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Loading weather data...',
            style: TextStyle(color: Colors.white),
          ),
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
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 24),
            if (_errorMessage.contains('API key')) ...[
              Text(
                'Your API key may not be activated yet or may be invalid. If you just created it, please wait up to 2 hours for activation.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: _isApiKeyValid ? _fetchWeather : _checkApiKey,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue[700],
              ),
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
          Icon(Icons.cloud_off, size: 64, color: Colors.white70),
          SizedBox(height: 16),
          Text(
            'No weather data available.',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchWeather,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue[700],
            ),
            child: Text('Get Weather'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherView() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // City name and current weather
            _buildCurrentWeather(),
            SizedBox(height: 24),
            
            // Display hourly forecast if available
            if (_weather!.hourlyForecast != null && _weather!.hourlyForecast!.isNotEmpty)
              _buildHourlyForecast(),
            
            SizedBox(height: 24),
            
            // Display daily forecast if available
            if (_weather!.dailyForecast != null && _weather!.dailyForecast!.isNotEmpty)
              _buildDailyForecast(),
              
            // Weather alerts
            if (_weather!.alerts != null && _weather!.alerts!.isNotEmpty)
              ..._weather!.alerts!.map((alert) => _buildAlert(alert)),
              
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCurrentWeather() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // City name
          Text(
            _weather!.cityName,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(2.0, 2.0),
                ),
              ],
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
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
          ),
          Text(
            _weather!.mainCondition,
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 6.0,
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(1.0, 1.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    return Container(
      height: 160,
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Hourly Forecast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 6.0,
                    color: Colors.black.withOpacity(0.3),
                    offset: Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _weather!.hourlyForecast!.length,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final hourly = _weather!.hourlyForecast![index];
                final time = DateTime.fromMillisecondsSinceEpoch(hourly.timestamp * 1000);
                return Container(
                  width: 80,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        index == 0 ? 'Now' : '${time.hour}:00',
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(
                        _getWeatherIcon(hourly.condition),
                        color: Colors.white,
                      ),
                      Text(
                        '${hourly.temperature.toStringAsFixed(1)}°C',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.water_drop, color: Colors.blue[100], size: 12),
                          SizedBox(width: 2),
                          Text(
                            '${hourly.precipitation.toStringAsFixed(0)}%',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecast() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '7-Day Forecast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 6.0,
                    color: Colors.black.withOpacity(0.3),
                    offset: Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
          ),
          ListView.builder(
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(
                      _getWeatherIcon(daily.condition),
                      color: Colors.white,
                    ),
                    if (daily.precipitation > 0)
                      Row(
                        children: [
                          Icon(Icons.water_drop, color: Colors.blue[100], size: 14),
                          Text(
                            '${daily.precipitation.toStringAsFixed(0)}%',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    Row(
                      children: [
                        Text(
                          '${daily.tempMin.toStringAsFixed(0)}°',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${daily.tempMax.toStringAsFixed(0)}°',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildAlert(WeatherAlert alert) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            alert.description,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
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