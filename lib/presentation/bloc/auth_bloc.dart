import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/data/models/user_model.dart';
import 'package:taskflow/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthGoogleRequested>(_onGoogle);
    on<AuthPasswordResetRequested>(_onPasswordReset);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    // Fast path: nothing saved locally, so go straight to login.
    if (!_repository.hasSavedSession) {
      emit(const Unauthenticated());
      return;
    }
    try {
      final user = await _repository.restoreSession();
      emit(user == null ? const Unauthenticated() : Authenticated(user));
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) {
    return _run(emit, () async {
      final user = await _repository.login(
        email: event.email,
        password: event.password,
      );
      return Authenticated(user);
    });
  }

  Future<void> _onSignUp(AuthSignUpRequested event, Emitter<AuthState> emit) {
    return _run(emit, () async {
      final user = await _repository.signUp(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      return Authenticated(user);
    });
  }

  Future<void> _onGoogle(AuthGoogleRequested event, Emitter<AuthState> emit) {
    return _run(emit, () async {
      final user = await _repository.signInWithGoogle();
      return Authenticated(user);
    });
  }

  Future<void> _onPasswordReset(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) {
    return _run(emit, () async {
      await _repository.sendPasswordReset(event.email);
      return AuthPasswordResetSent(event.email);
    });
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    emit(const Unauthenticated());
  }

  /// Shared flow: Loading -> result (or error).
  /// Emitting Loading first also guarantees the same error twice in a row
  /// still reaches the UI, because Loading sits between the two errors.
  Future<void> _run(
    Emitter<AuthState> emit,
    Future<AuthState> Function() action,
  ) async {
    emit(const AuthLoading());
    try {
      emit(await action());
    } on AuthFailure catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Something went wrong. Try again.'));
    }
  }
}
