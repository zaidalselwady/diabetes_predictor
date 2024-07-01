import 'package:diabetes_predictor/SplashScreen/splash_view.dart';
import 'package:diabetes_predictor/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor:
            Color.fromARGB(255, 216, 216, 216), // Set your desired color here
        statusBarBrightness:
            Brightness.dark, // You can also set Brightness.light
      ),
    );
    return MaterialApp(
      
      theme: ThemeData(
        
          scaffoldBackgroundColor: const Color.fromARGB(255, 216, 216, 216),
          appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromARGB(255, 216, 216, 216),
              elevation: 0)),
      debugShowCheckedModeBanner: false,
      home: SplashView(),
    );
  }
}
