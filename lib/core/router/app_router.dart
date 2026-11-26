import 'package:flutter/material.dart';

import '../../presentation/screens/signup_screen.dart';


/// Named routes. The first screen (splash / login / home) is chosen by
/// AuthGate in app.dart, so only secondary screens are listed here.
/// Add new screens (project board, task detail...) in later phases.
class AppRouter {
  AppRouter._();

  static const signup = '/signup';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case signup:
        return MaterialPageRoute<void>(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );
    }
    return null;
  }
}