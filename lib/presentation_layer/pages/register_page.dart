import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_chat/core/constants.dart';
import 'package:lets_chat/presentation_layer/cubits/auth_cubit/auth_cubit.dart';
import 'package:lets_chat/presentation_layer/cubits/auth_cubit/auth_state.dart';
import 'package:lets_chat/presentation_layer/widgets/custom_button.dart';
import 'package:lets_chat/presentation_layer/widgets/custom_text_form_field.dart';
import 'package:lets_chat/presentation_layer/widgets/show_snackbar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  static const String id = '/register';

  @override
  State<RegisterPage> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleRegister() async {
    if (context.read<AuthCubit>().state.status == AuthStatus.loading) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    await context.read<AuthCubit>().register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    // Clear fields only on successful registration (mirrors LoginPage's
    // behavior). If mounted-check is skipped, a `setState after dispose`
    // error could occur if the user navigates away while awaiting.
    if (mounted &&
        context.read<AuthCubit>().state.status == AuthStatus.authenticated) {
      _emailController.clear();
      _passwordController.clear();
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'This field is required';
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        return current.status == AuthStatus.authenticated ||
            current.status == AuthStatus.failure;
      },
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        } else if (state.status == AuthStatus.failure) {
          showSnackbar(
            context,
            state.errorMessage ?? 'Registration failed. Please try again.',
          );
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;

          return Scaffold(
            backgroundColor: kPrimaryColor,
            body: Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _formKey,
                      child: Center(
                        child: ListView(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          children: [
                            Image.asset(
                              kLogo,
                              height: 60,
                            ),
                            const SizedBox(height: 15),
                            const Center(
                              child: Text(
                                appName,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'Lobster',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                            const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            CustomTextFormField(
                              hint: 'Email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 12),
                            CustomTextFormField(
                              hint: 'Password',
                              isPassword: true,
                              controller: _passwordController,
                              validator: _validatePassword,
                              onFieldSubmitted: (_) {
                                if (!isLoading) _handleRegister();
                              },
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: 'Register',
                              onTap: isLoading ? null : _handleRegister,
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Already have an account?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _emailController.clear();
                                    _passwordController.clear();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (state.status == AuthStatus.loading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: LoadingAnimationWidget.hexagonDots(
                          size: 50,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
