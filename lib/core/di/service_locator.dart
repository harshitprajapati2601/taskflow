import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/core/theme/theme_provider.dart';
import 'package:taskflow/data/repositories/auth_repository.dart';

import '../../presentation/bloc/auth_bloc.dart';


/// Global service locator (dependency injection).
final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  final prefs = await SharedPreferences.getInstance();

  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<AuthRepository>(
          () => AuthRepository(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
        prefs: sl<SharedPreferences>(),
      ),
    )
    ..registerLazySingleton<ThemeProvider>(
          () => ThemeProvider(sl<SharedPreferences>()),
    )
  // A new bloc per request; the widget tree owns and closes it.
    ..registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepository>()));
}