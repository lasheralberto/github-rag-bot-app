import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:githubrag/components/screens/chatscreen.dart';
import 'package:githubrag/components/screens/login.dart';
import 'package:githubrag/firebase_options.dart';
import 'package:githubrag/models/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Ejecuta la aplicación dentro de un runZonedGuarded para capturar errores
  runZonedGuarded(
    () {
      runApp(MyApp());
    },
    (error, stackTrace) {
      print('Runzone error: $error');
      print('Stacktrace: $stackTrace');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat con Firebase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        primaryColor: AppColors.accent,
        scaffoldBackgroundColor: AppColors.background,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: kDebugMode == true ? ChatScreen() : const LoginScreen(),
    );
  }
}
