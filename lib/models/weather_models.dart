class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final List<HourlyForecast>? hourlyForecast;
  final List<DailyForecast>? dailyForecast;
  final List<WeatherAlert>? alerts;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    this.hourlyForecast,
    this.dailyForecast,
    this.alerts,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? 'Unknown Location',
      temperature: (json['main']['temp'] ?? 0.0).toDouble(),
      mainCondition: json['weather'][0]['main'] ?? 'Unknown',
    );
  }

  // For loading from local storage
  factory Weather.fromStoredJson(Map<String, dynamic> json) {
    List<HourlyForecast>? hourlyList;
    if (json.containsKey('hourlyForecast') && json['hourlyForecast'] != null) {
      hourlyList = (json['hourlyForecast'] as List)
          .map((item) => HourlyForecast.fromJson(item))
          .toList();
    }

    List<DailyForecast>? dailyList;
    if (json.containsKey('dailyForecast') && json['dailyForecast'] != null) {
      dailyList = (json['dailyForecast'] as List)
          .map((item) => DailyForecast.fromJson(item))
          .toList();
    }

    List<WeatherAlert>? alertsList;
    if (json.containsKey('alerts') && json['alerts'] != null) {
      alertsList = (json['alerts'] as List)
          .map((item) => WeatherAlert.fromJson(item))
          .toList();
    }

    return Weather(
      cityName: json['cityName'] ?? 'Unknown Location',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      mainCondition: json['mainCondition'] ?? 'Unknown',
      hourlyForecast: hourlyList,
      dailyForecast: dailyList,
      alerts: alertsList,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'mainCondition': mainCondition,
      'hourlyForecast': hourlyForecast?.map((h) => h.toJson()).toList(),
      'dailyForecast': dailyForecast?.map((d) => d.toJson()).toList(),
      'alerts': alerts?.map((a) => a.toJson()).toList(),
    };
  }
}

class HourlyForecast {
  final int timestamp;
  final double temperature;
  final String condition;
  final String icon;
  final double precipitation;

  HourlyForecast({
    required this.timestamp,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.precipitation,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      timestamp: json['dt'] ?? 0,
      temperature: (json['temp'] ?? 0.0).toDouble(),
      condition: json['weather'][0]['main'] ?? 'Unknown',
      icon: json['weather'][0]['icon'] ?? '01d',
      precipitation: json['pop'] != null ? (json['pop'] * 100).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': timestamp,
      'temp': temperature,
      'weather': [
        {'main': condition, 'icon': icon}
      ],
      'pop': precipitation / 100,
    };
  }
}

class DailyForecast {
  final int timestamp;
  final double tempMax;
  final double tempMin;
  final String condition;
  final String icon;
  final double precipitation;

  DailyForecast({
    required this.timestamp,
    required this.tempMax,
    required this.tempMin,
    required this.condition,
    required this.icon,
    required this.precipitation,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      timestamp: json['dt'] ?? 0,
      tempMax: (json['temp']['max'] ?? 0.0).toDouble(),
      tempMin: (json['temp']['min'] ?? 0.0).toDouble(),
      condition: json['weather'][0]['main'] ?? 'Unknown',
      icon: json['weather'][0]['icon'] ?? '01d',
      precipitation: json['pop'] != null ? (json['pop'] * 100).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': timestamp,
      'temp': {
        'max': tempMax,
        'min': tempMin,
      },
      'weather': [
        {'main': condition, 'icon': icon}
      ],
      'pop': precipitation / 100,
    };
  }
}

class WeatherAlert {
  final String event;
  final String description;
  final int start;
  final int end;
  
  String get title => event;  // Use 'event' as the title

  WeatherAlert({
    required this.event,
    required this.description,
    required this.start,
    required this.end,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      event: json['event'] ?? 'Weather Alert',
      description: json['description'] ?? '',
      start: json['start'] ?? 0,
      end: json['end'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'description': description,
      'start': start,
      'end': end,
    };
  }
}