import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:taskflow/core/constants/app_constants.dart';
import 'package:taskflow/core/router/app_router.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/core/theme/theme_provider.dart';
import 'package:taskflow/presentation/bloc/auth_bloc.dart';
import 'package:taskflow/presentation/screens/home_screen.dart';
import 'package:taskflow/presentation/screens/login_screen.dart';
import 'package:taskflow/presentation/screens/splash_screen.dart';

import 'core/di/service_locator.dart';

/// Root widget.
/// - Provider  -> theme (simple UI state)
/// - Bloc      -> authentication (event-driven logic)
class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>.value(
      value: sl<ThemeProvider>(),
      child: BlocProvider<AuthBloc>(
        create: (_) => sl<AuthBloc>()..add(const AuthStarted()),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeProvider.mode,
              onGenerateRoute: AppRouter.onGenerateRoute,
              home: const AuthGate(),
            );
          },
        ),
      ),
    );
  }
}

/// Decides which screen to show from the current auth state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) return const HomeScreen();
        if (state is AuthInitial) return const SplashScreen();
        return const LoginScreen();
      },
    );
  }
}