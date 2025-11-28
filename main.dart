import 'package:flutter/material.dart';
import 'login_or_signup_page.dart';

void main() {
  runApp(const JoviaApp());
}

class JoviaApp extends StatelessWidget {
  const JoviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jovia AI',
      debugShowCheckedModeBanner: false,
      home: const LoginOrSignupPage(), // Uygulama buradan başlıyor
    );
  }
}