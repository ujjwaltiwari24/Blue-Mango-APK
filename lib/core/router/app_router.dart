import 'package:flutter/material.dart';

import '../../features/splash/presentation/splash_screen.dart';

// Authentication Screens
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';

// Home
import '../../home/home_screen.dart';

// Create / Edit Post
import '../../create_post/create_post_screen.dart';

// Profile & Account Info
import '../../profile/profile_screen.dart';
import '../../screens/account_info_screen.dart'; // Import Account Info Screen

// Models
import '../../models/post_model.dart';

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
      case "/home": // Added alias in case pushNamed('/home') is called
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case "/create-post":
        return MaterialPageRoute(
          builder: (_) => const CreatePostScreen(),
          fullscreenDialog: true,
        );

      case "/edit-post":
        final post = settings.arguments as PostModel;
        return MaterialPageRoute(
          builder: (_) => CreatePostScreen(editingPost: post),
          fullscreenDialog: true,
        );

      case "/profile":
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      case "/account-info": // Registered Account Info Route
        return MaterialPageRoute(
          builder: (_) => const AccountInfoScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
    }
  }
}