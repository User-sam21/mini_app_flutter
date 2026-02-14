import 'package:flutter/material.dart';
import 'package:mini_app/presentation/Account.dart';

import 'package:mini_app/presentation/login_ui.dart';
import 'package:mini_app/presentation/onbordingScreen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Mini app',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/account': (context) => const Account(),
          
        });
  }
}
