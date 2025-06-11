import 'package:flutter/material.dart';
import 'package:app_selldrinks/core/theme/highland_theme.dart';
import 'routes/app_routes.dart';
import 'core/constants/app_constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: highlandsTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppConstants.splashRoute,
      routes: AppRoutes.getRoutes(),
    );
  }
}
