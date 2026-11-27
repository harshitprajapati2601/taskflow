class AppConstants {
  //A Private Named constructor
  AppConstants._();

  static const appName = "TaskFlow";

  //Firestore collections
static const userCollection = "users";
static const projectsCollection = "projects";
static const tasksCollection = 'tasks';

//SharedPreferences keys
static const prefIsLoggedIn = "is_logged_in";
static const prefUserId = "user_id";
static const prefDarkMode = "dark_mode";
}