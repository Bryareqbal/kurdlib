import 'package:flutter/material.dart';
import 'package:kurdlib/main.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutTheAppView extends StatefulWidget {
  const AboutTheAppView({super.key});

  @override
  State<AboutTheAppView> createState() => _AboutTheAppViewState();
}

class _AboutTheAppViewState extends State<AboutTheAppView> {
  final Uri _url = Uri.parse('https://facebook.com');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Change this to your desired color
        ),
        title: Text(
          'دەربارەی بەرنامە',
          style: TextStyle(
              fontFamily: myCustomFont,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal, // Change the color to match your branding
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/imgs/KurdLib_Icon.jpg',
                height: 250,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              Text(
                'وەشانی بەرنامە: 1.0',
                style: TextStyle(
                    fontFamily: myCustomFont,
                    fontSize: 18,
                    color: Colors.black),
              ),
              SizedBox(height: 20),
              Text(
                'گەشەپێدەران:\nهونەر عەبدولواحید\nبڕیار ئیقبال\nڕۆژ هۆشمەند\n پەرۆش بەرهەم',
                style: TextStyle(
                    fontFamily: myCustomFont,
                    fontSize: 16,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _launchUrl,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.teal, // Change button color to match the theme
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'فەیسبووکی ئێمە',
                  style: TextStyle(
                    fontFamily: myCustomFont,
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
