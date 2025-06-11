import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/store_screen.dart';
import '../presentation/screens/profile_screen.dart';
import '../presentation/screens/account_overview_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      AppConstants.splashRoute: (context) => const SplashScreen(),
      AppConstants.homeRoute: (context) => const HomeScreen(),
      AppConstants.storeRoute: (context) => const StoreScreen(),
      AppConstants.profileRoute: (context) => const ProfileScreen(),
      AppConstants.accountOverviewRoute: (context) => const AccountOverviewScreen(),
    };
  }
} 