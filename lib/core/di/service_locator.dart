import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/core/theme/theme_provider.dart';
import 'package:taskflow/data/repositories/auth_repository.dart';
import 'package:taskflow/data/repositories/project_repository.dart';
import 'package:taskflow/presentation/projects/cubit/project_cubit.dart';

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
    ..registerLazySingleton<ProjectRepository>(
          () => ProjectRepository(firestore: FirebaseFirestore.instance),
    )
    ..registerLazySingleton<ThemeProvider>(
          () => ThemeProvider(sl<SharedPreferences>()),
    )
  // the widget tree owns and closes it.
    ..registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepository>()))
  // sl<ProjectCubit>(param1: uid)
    ..registerFactoryParam<ProjectCubit, String, void>(
          (uid, _) => ProjectCubit(sl<ProjectRepository>(), uid),
    );
}
