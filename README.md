****Flutter Weather App
****
A simple and elegant weather application built with Flutter that shows real-time weather data based on your current location. The app fetches data from the OpenWeatherMap API and displays it with beautiful animations.

**Features
**
Real-time weather data based on your current location
Beautiful Lottie animations that change based on weather conditions
Displays current temperature and weather conditions
Clean and minimalist UI
Responsive design that works across different devices

**Getting Started
**
Prerequisites

Flutter SDK (version 2.0.0 or higher)
Dart SDK (version 2.12.0 or higher)
Android Studio / VS Code
An OpenWeatherMap API key

**Installation
**
Clone this repository

bashCopygit clone https://github.com/yourname/weather-app.git

Navigate to the project directory

bashCopycd weather-app

Install dependencies

bashCopyflutter pub get

Update the API key in lib/pages/weather_page.dart with your OpenWeatherMap API key

dartCopyfinal _weatherServices = WeatherServices('YOUR_API_KEY_HERE');

Run the app

bashCopyflutter run
Dependencies

http - For making API calls
geolocator - For getting device location
geocoding - For converting coordinates to address
lottie - For loading and displaying animations
url_launcher - For launching URLs

**Project Structure
**
Copylib/
├── main.dart               # Entry point of the application
├── models/
│   └── weather_models.dart # Data models for weather information
├── pages/
│   └── weather_page.dart   # Main weather display page
├── services/
│   └── weather_services.dart # API and location services
└── widgets/
    └── footer_widget.dart  # Footer widget with contact information
How It Works

When the app starts, it requests permission to access the device's location
Once permission is granted, it gets the current coordinates
The coordinates are sent to the OpenWeatherMap API to fetch weather data
Weather data is parsed and displayed with appropriate animations
The UI updates to show the current weather conditions

Adding Your Own Animations
The app uses Lottie animations to represent different weather conditions. To add or modify animations:

Place your .json animation files in the assets/ directory
Update the getWeatherAnimation method in weather_page.dart to use your new animations

dartCopyString getWeatherAnimation(String mainCondition) {
  switch (mainCondition) {
    case 'YourNewCondition':
      return 'assets/your_new_animation.json';
    // other cases...
    default:
      return 'assets/default.json';
  }
}
API Reference
This app uses the OpenWeatherMap API to fetch weather data. You'll need to sign up for a free API key to use this application.
License
This project is licensed under the MIT License - see the LICENSE file for details.
Acknowledgements

OpenWeatherMap for providing the weather data API
Lottie for the beautiful animations
Flutter for the amazing framework

Contact
Your Name - kolayeswanth2005@gmail.com
Project Link: https://github.com/Kolayeswanth/weather-app
