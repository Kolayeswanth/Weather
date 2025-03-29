# Flutter Weather App

A simple and elegant weather application built with Flutter that shows real-time weather data based on your current location. The app fetches data from the OpenWeatherMap API and displays it with beautiful animations.

## Features

- Real-time weather data based on your current location
- Beautiful Lottie animations that change based on weather conditions
- Displays current temperature and weather conditions
- Clean and minimalist UI
- Responsive design that works across different devices


## Getting Started

### Prerequisites

- Flutter SDK (version 2.0.0 or higher)
- Dart SDK (version 2.12.0 or higher)
- Android Studio / VS Code
- An OpenWeatherMap API key

### Installation

1. Clone this repository
```bash
git clone https://github.com/yourname/weather-app.git
```

2. Navigate to the project directory
```bash
cd weather-app
```

3. Install dependencies
```bash
flutter pub get
```

4. Update the API key in `lib/pages/weather_page.dart` with your OpenWeatherMap API key
```dart
final _weatherServices = WeatherServices('YOUR_API_KEY_HERE');
```

5. Run the app
```bash
flutter run
```

### Dependencies

- [http](https://pub.dev/packages/http) - For making API calls
- [geolocator](https://pub.dev/packages/geolocator) - For getting device location
- [geocoding](https://pub.dev/packages/geocoding) - For converting coordinates to address
- [lottie](https://pub.dev/packages/lottie) - For loading and displaying animations
- [url_launcher](https://pub.dev/packages/url_launcher) - For launching URLs

## Project Structure

```
lib/
├── main.dart               # Entry point of the application
├── models/
│   └── weather_models.dart # Data models for weather information
├── pages/
│   └── weather_page.dart   # Main weather display page
├── services/
│   └── weather_services.dart # API and location services
└── widgets/
    └── footer_widget.dart  # Footer widget with contact information
```

## How It Works

1. When the app starts, it requests permission to access the device's location
2. Once permission is granted, it gets the current coordinates
3. The coordinates are sent to the OpenWeatherMap API to fetch weather data
4. Weather data is parsed and displayed with appropriate animations
5. The UI updates to show the current weather conditions

## Adding Your Own Animations

The app uses Lottie animations to represent different weather conditions. To add or modify animations:

1. Place your .json animation files in the `assets/` directory
2. Update the `getWeatherAnimation` method in `weather_page.dart` to use your new animations

```dart
String getWeatherAnimation(String mainCondition) {
  switch (mainCondition) {
    case 'YourNewCondition':
      return 'assets/your_new_animation.json';
    // other cases...
    default:
      return 'assets/default.json';
  }
}
```

## API Reference

This app uses the [OpenWeatherMap API](https://openweathermap.org/api) to fetch weather data. You'll need to sign up for a free API key to use this application.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [OpenWeatherMap](https://openweathermap.org/) for providing the weather data API
- [Lottie](https://airbnb.design/lottie/) for the beautiful animations
- [Flutter](https://flutter.dev/) for the amazing framework

## Contact

Your Name - [@yourtwitter](https://twitter.com/yourtwitter) - your.email@example.com

Project Link: [https://github.com/yourname/weather-app](https://github.com/yourname/weather-app)
