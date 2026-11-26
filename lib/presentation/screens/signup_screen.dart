import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/core/utils/snackbar.dart';
import 'package:taskflow/core/utils/validators.dart';
import 'package:taskflow/core/widgets/custom_button.dart';

import '../../core/widgets/custom_textfield.dart';
import '../bloc/auth_bloc.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _signUp() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ShowSnack(context, state.message, isError: true);
                  } else if (state is Authenticated) {
                    // AuthGate now shows Home; remove this screen from the stack.
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Create your account',
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start organizing your team in minutes',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          controller: _nameController,
                          label: 'Full name',
                          icon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                          validator: Validators.name,
                        ),
                        const SizedBox(height: 16),
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
                          textInputAction: TextInputAction.next,
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _confirmController,
                          label: 'Confirm password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _signUp(),
                          validator: (v) => Validators.confirmPassword(
                            v,
                            _passwordController.text,
                          ),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: 'Create account',
                          isLoading: isLoading,
                          onPressed: _signUp,
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
