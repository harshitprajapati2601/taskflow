import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/data/models/user_model.dart';
import 'package:taskflow/data/repositories/auth_repository.dart';
import 'package:taskflow/presentation/bloc/auth_bloc.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  const user = UserModel(
    uid: 'u1',
    name: 'Rahul Kumar',
    email: 'rahul@test.com',
  );

  setUp(() {
    repository = MockAuthRepository();
  });

  group('AuthStarted', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] when nothing is saved locally',
      build: () {
        when(() => repository.hasSavedSession).thenReturn(false);
        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [const Unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Authenticated] when a saved session is still valid',
      build: () {
        when(() => repository.hasSavedSession).thenReturn(true);
        when(() => repository.restoreSession()).thenAnswer((_) async => user);
        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [const Authenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] when the saved session has expired',
      build: () {
        when(() => repository.hasSavedSession).thenReturn(true);
        when(() => repository.restoreSession()).thenAnswer((_) async => null);
        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [const Unauthenticated()],
    );
  });

  group('AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] on success',
      build: () {
        when(
              () => repository.login(email: 'rahul@test.com', password: '123456'),
        ).thenAnswer((_) async => user);
        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: 'rahul@test.com', password: '123456'),
      ),
      expect: () => [const AuthLoading(), const Authenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] with the message on failure',
      build: () {
        when(
              () => repository.login(email: 'rahul@test.com', password: 'wrong'),
        ).thenThrow(const AuthFailure('Wrong email or password.'));
        return AuthBloc(repository);
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: 'rahul@test.com', password: 'wrong'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError('Wrong email or password.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
        'shows a generic message for unexpected errors',
        build: () {
          when(