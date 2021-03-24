import 'package:appfacedetector/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 5,
      navigateAfterSeconds: HomePage(),
      title: Text(
        '\n DETECCION DE ROSTRO',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      image: Image.asset("assets/splash.png"),
      photoSize: 130,
      backgroundColor: Colors.white,
      loaderColor: Colors.black,
      loadingText: Text(
        'by Wanna Code',
        style: TextStyle(color: Colors.black, fontSize: 16.00),
      ),
    );
  }
}
