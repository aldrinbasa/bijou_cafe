import 'package:bijou_cafe/constants/colors.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import '../config/firebase_options.dart';

import 'package:bijou_cafe/init/login/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginScreen(),
      theme: ThemeData(
        primaryColor: primaryColor,
        secondaryHeaderColor: secondaryColor,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
