import 'package:flutter/material.dart';

import '../../features/splash/presentation/splash_screen.dart';

// Authentication Screens
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';

// Home
import '../../screens/home/home_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case "/login":
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case "/register":
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );

      case "/forgot-password":
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );

      case "/feed":
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
    }
  }
}