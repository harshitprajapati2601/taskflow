import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/core/constants/app_constants.dart';
import 'package:taskflow/data/models/user_model.dart';

/// A readable error that the UI can show directly.
class AuthFailure implements Exception {
  String message;
  AuthFailure(this.message);
  @override
  String toString() => message;
}

// /// The only class that talks to Firebase Auth / Firestore for authentication.
// /// The Bloc depends on this class, so the Bloc can be tested with a mock.

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;

  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required SharedPreferences prefs,
  }) : _auth = auth,
       _firestore = firestore,
       _prefs = prefs;

  //CollectionReference
  // Represents a reference to a Firestore collection.
  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(AppConstants.userCollection);

  //This getter checks whether a login flag is saved locally.
  //Important: This is only a locally saved indicator.
  // It does not independently prove that the Firebase user is still authenticated.
  bool get hasSavedSession =>
      _prefs.getBool(AppConstants.prefIsLoggedIn) ?? false;

  //firebase keeps the real session; this checks it is still valid.
  Future<UserModel?> restoreSession() async {
    //authStateChanges() provides a stream of Firebase authentication state changes.
    // .first takes the first available authentication state.
    final user = await _auth.authStateChanges().first;
    if (user == null) {
      await clearSession();
      return null;
    }
    try {
      return await _getOrCreateProfile(user);
    } catch (_) {
      // Offline or Firestore unavailable: still let the user in.
      return _profileFromAuth(user);
    }
  }

  Future<void> clearSession() async {
    await _prefs.remove(AppConstants.prefIsLoggedIn);
    await _prefs.remove(AppConstants.prefUserId);
  }

  Future<void> _saveSession(String uid) async {
    await _prefs.setBool(AppConstants.prefIsLoggedIn, true);
    await _prefs.setString(AppConstants.prefUserId, uid);
  }

  //actions
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      await user.updateDisplayName(name.trim());
      await user.sendEmailVerification();

      final model = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: user.email ?? email.trim(),
      );
      await _users.doc(user.uid).set(model.toFirestore());
      await _saveSession(user.uid);
      return model;
    });
  }

  Future<UserModel> login({required String email, required String password}) {
    return _guard(() async {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user!;
      final model = await _getOrCreateProfile(user);
      await _saveSession(user.uid);
      return model;
    });
  }

  /// Google sign-in through Firebase's own flow (no extra package needed).
  /// Enable the Google provider in Firebase console > Authentication first.
  Future<UserModel> signInWithGoogle() {
    return _guard(() async {
      final cred = await _auth.signInWithProvider(GoogleAuthProvider());
      //! is the null assertion operator.\
      // It tells Dart that we expect this value not to be null.
      final user = cred.user!;
      final model = await _getOrCreateProfile(user);
      await _saveSession(user.uid);
      return model;
    });
  }

  Future<void> sendPasswordReset(String email) {
    return _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));
  }

  Future<void> logout() async {
    await _auth.signOut();
    await clearSession();
  }

  // ---------------------------------------------------------------- helpers

  Future<UserModel> _getOrCreateProfile(User user) async {
    final doc = await _users.doc(user.uid).get();
    final data = doc.data();
    if (doc.exists && data != null) return UserModel.fromMap(data);

    final model = _profileFromAuth(user);
    await _users.doc(user.uid).set(model.toFirestore());
    return model;
  }

  UserModel _profileFromAuth(User user) {
    final email = user.email ?? '';
    return UserModel(
      uid: user.uid,
      name:
          user.displayName ?? (email.isEmpty ? 'User' : email.split('@').first),
      email: email,
      photoUrl: user.photoURL,
    );
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageFor(e.code));
    } on FirebaseException catch (e) {
      throw AuthFailure(e.message ?? 'Something went wrong. Try again.');
    }
  }

  String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address looks wrong.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Wrong email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Choose a stronger password (6+ characters).';
      case 'too-many-requests':
        return 'Too many attempts. Try again in a few minutes.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'operation-not-allowed':
        return "This sign-in method isn't enabled in Firebase yet.";
      case 'canceled':
      case 'web-context-canceled':
      case 'popup-closed-by-user':
        return 'Sign-in was cancelled.';
      default:
        return 'Authentication failed ($code).';
    }
  }
}
