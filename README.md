# TaskFlow: Phase 3 (base setup) + Phase 5 (authentication)

These files assume your Flutter project is named `taskflow`
(created with `flutter create taskflow`). If you used another name,
replace `package:taskflow/` in every import with `package:<your_name>/`.

## 1. Add packages (run inside your project)

```bash
flutter pub add firebase_core firebase_auth cloud_firestore
flutter pub add flutter_bloc provider equatable get_it shared_preferences
flutter pub add google_fonts intl fl_chart
flutter pub add --dev bloc_test mocktail
```

## 2. Connect Firebase

1. Create a project in the Firebase console (free Spark plan).
2. Authentication > Sign-in method: enable **Email/Password** and **Google**
   (Google needs a support email).
3. Firestore Database > Create database > start in **test mode** for now
   (you will add real security rules in Phase 12).
4. In your project folder run:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This creates `lib/firebase_options.dart`.
5. Android: open `android/app/build.gradle` (or `build.gradle.kts`) and set
   `minSdk = 23` (Firebase needs 23 or higher).
6. Google Sign-In on Android needs your SHA-1 and SHA-256 keys:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Copy the SHA-1 and SHA-256 of the `debug` variant into
   Firebase console > Project settings > your Android app > Add fingerprint.
   Then run `flutterfire configure` again.

## 3. Copy the code

Copy the `lib/` and `test/` folders from this zip into your project
(replace the default `lib/main.dart`).

## 4. Run and test

```bash
flutter run
flutter test
```

Try this checklist:
- Sign up with a new email, then close and reopen the app (you stay logged in).
- Log out, then log in with a wrong password (you see an error snackbar).
- Tap "Forgot password?" with your email typed in (check your inbox).
- Toggle dark mode on the home screen, restart the app (the choice is remembered).
- Check Firestore: a document should exist in `users/{uid}`.

## Folder map

```
lib/
 ├─ main.dart, app.dart
 ├─ core/
 │   ├─ constants/app_constants.dart
 │   ├─ di/service_locator.dart
 │   ├─ router/app_router.dart
 │   ├─ theme/app_theme.dart, theme_provider.dart
 │   ├─ utils/validators.dart, snackbar.dart
 │   └─ widgets/custom_button.dart, custom_text_field.dart, state_views.dart
 ├─ data/
 │   ├─ models/user_model.dart
 │   └─ repositories/auth_repository.dart
 └─ presentation/
     ├─ auth/bloc/ (auth_bloc, auth_event, auth_state)
     ├─ auth/ login_screen, signup_screen, splash_screen
     └─ home/home_screen.dart
test/auth_bloc_test.dart
```

## How it works (be ready to explain this in interviews)

- `AuthBloc` is the single source of truth for login state.
  `AuthGate` (in `app.dart`) listens to it and shows Splash, Login or Home.
- `AuthRepository` is the only class that talks to Firebase, so the Bloc
  can be unit tested with a mock repository.
- `ThemeProvider` uses Provider + SharedPreferences for the dark mode flag.
# TaskFlow Phase 6: Projects

No new packages are needed.

## Copy into your project

Copy the `lib/` and `test/` folders from this zip into your project.

Three files REPLACE your existing ones:
- `lib/core/constants/app_constants.dart`  (adds `projectsCollection`)
- `lib/core/di/service_locator.dart`       (registers the project repository and cubit)
- `lib/presentation/home/home_screen.dart` (now a bottom navigation screen)

Everything else is new. `app.dart` does not change.

## Firestore structure created by this phase

```
projects/{projectId}
   name, description, ownerId, inviteCode, createdAt
   memberIds: [uid, uid]
   roles: { uid: "admin" | "member" }
```

Collections are created automatically on the first save. No index is needed.

## Test it

```bash
flutter analyze
flutter test
flutter run
```

1. Create a project. It appears instantly with you as Admin and a 6-character code.
2. Check the Firestore console: a document exists under `projects`.
3. Log in on a second device or emulator with another account, tap the join icon and enter the code. The project appears there, and the member count goes to 2 on both devices without a refresh.
4. As the member, use the menu on the card to leave. As the admin, delete the project.
5. Try a wrong code. You should see "No project found for that code."

## Notes

- Deleting a project does not delete its tasks (Firestore never deletes sub-collections automatically). Phase 7 adds that cleanup in `deleteProject`.
- Joining works because Firestore is in test mode. In Phase 12 the security rules must allow reading a project by invite code and adding yourself to `memberIds`.
