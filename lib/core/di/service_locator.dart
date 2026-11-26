import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/core/theme/theme_provider.dart';

//Global Service Locator
final GetIt s1 = GetIt.instance;

Future<void> setupServiceLocator() async{

  final prefs = await SharedPreferences.getInstance();

  s1
  ..registerSingleton<SharedPreferences>(prefs)
  ..registerLazySingleton<ThemeProvider>(() => ThemeProvider(s1<SharedPreferences>()));

}