import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/core/router/app_router.dart';
import 'package:taskflow/core/utils/snackbar.dart';
import 'package:taskflow/core/utils/validators.dart';
import 'package:taskflow/core/widgets/app_logo.dart';
import 'package:taskflow/core/widgets/custom_button.dart';

import '../../core/widgets/custom_textfield.dart';
import '../bloc/auth_bloc.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //Button Click → Keyboard Close → Form Validation → Event → AuthBloc → Repository
  void _login() {
    //FocusScope manages keyboard focus in the widget tree.
    //.unfocus() removes the current focus.
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  void _forgotPassword() {
    final email = _emailController.text.trim();
    if (Validators.email(email) != null) {
      ShowSnack(context, 'Enter your email above first.', isError: true);
      return;
    }
    context.read<AuthBloc>().add(AuthPasswordResetRequested(email));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: BlocConsumer<AuthBloc, AuthState>(
                //This line checks whether the Login screen is currently visible before allowing its listener to execute.
                listenWhen: (_, __) => ModalRoute.of(context)?.isCurrent ?? true,

                listener: (context, state) {
                  if (state is AuthError) {
                    ShowSnack(context, state.message, isError: true);
                  } else if (state is AuthPasswordResetSent) {
                    ShowSnack(context, 'Reset link sent to ${state.email}');
                  }
                },

                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(child: AppLogo()),
                        const SizedBox(height: 24),
                        Text(
                          'Welcome back',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Log in to manage your team tasks',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _login(),
                          validator: Validators.password,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading ? null : _forgotPassword,
                            child: const Text('Forgot password?'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        PrimaryButton(
                          label: 'Login',
                          isLoading: isLoading,
                          onPressed: _login,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('or', style: theme.textTheme.bodySmall),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: 'Continue with Google',
                          icon: Icons.login,
                          outlined: true,
                          onPressed: () => context
                              .read<AuthBloc>()
                              .add(const AuthGoogleRequested()),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.of(context)
                                  .pushNamed(AppRouter.signup),
                              child: const Text('Sign up'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
