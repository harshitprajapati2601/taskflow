//AuthEvent tells the BLoC what the user wants to do.
part of 'auth_bloc.dart';


sealed class AuthEvent extends Equatable{
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// App launched: check for an existing session.
class AuthStarted extends AuthEvent{
  const AuthStarted();
}

class AuthLoginRequested extends AuthEvent{
  final String email;
  final String password;

  AuthLoginRequested({required this.email,required this.password});

  @override
  // TODO: implement props
  List<Object> get props => [email,password];
}

class AuthSignUpRequested extends AuthEvent{
  final String name;
  final String email;
  final String password;

  AuthSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [name,email,password];
}

class AuthGoogleRequested extends AuthEvent{
  const AuthGoogleRequested();
}

class AuthPasswordResetRequested extends AuthEvent{
  final String email;
  const AuthPasswordResetRequested(this.email);

  @override
  // TODO: implement props
  List<Object> get props => [email];
}

class AuthLogoutRequested extends AuthEvent{
  const AuthLogoutRequested();
}