
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import '../models/weather_models.dart';

class WeeklyForecastWidget extends StatelessWidget {
  final List<DailyForecast> dailyForecast;
  final String Function(String) getWeatherAnimation;

  const WeeklyForecastWidget({
    super.key,
    required this.dailyForecast,
    required this.getWeatherAnimation,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyForecast.isEmpty) {
      return Center(child: Text('No weekly forecast available'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '7-Day Forecast',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: dailyForecast.length,
            itemBuilder: (context, index) {
              final daily = dailyForecast[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: Lottie.asset(
                      getWeatherAnimation(daily.condition),
                      fit: BoxFit.contain,
                    ),
                  ),
                  title: Text(
                    index == 0 
                        ? 'Today' 
                        : index == 1 
                            ? 'Tomorrow' 
                            : DateFormat('EEEE').format(daily.date),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    daily.condition,
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_upward, 
                               color: Colors.red[300], size: 14),
                          Text(
                            '${daily.maxTemp.round()}°',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_downward, 
                               color: Colors.blue[300], size: 14),
                          Text(
                            '${daily.minTemp.round()}°',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.water_drop, 
                               color: Colors.blue, size: 14),
                          Text(
                            '${(daily.precipitationProbability * 100).round()}%',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}