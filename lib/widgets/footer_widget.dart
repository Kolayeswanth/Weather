import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
  padding: const EdgeInsets.all(16.0),
  color: Colors.blueGrey,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 16.0,
        children: [
          ClipOval(
            child: Material(
              color: Colors.transparent, // Button color
              child: InkWell(
                splashColor: Colors.blueGrey, // Splash color
                onTap: () {
                  // Add your GitHub URL here
                  launchURL('https://github.com/yourprofile');
                },
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.asset('assets/github_logo.png'),
                ),
              ),
            ),
          ),
          ClipOval(
            child: Material(
              color: Colors.transparent, // Button color
              child: InkWell(
                splashColor: Colors.blueGrey, // Splash color
                onTap: () {
                  // Add your LinkedIn URL here
                  launchURL('https://linkedin.com/in/yourprofile');
                },
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.asset('assets/linkedin_logo.png'),
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Text(
        'Contact: contact@myweatherapp.com',
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      const Text(
        '© 2024 My Weather App',
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    ],
  ),
);
  }

  Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}