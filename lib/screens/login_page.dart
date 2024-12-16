import 'dart:async';
import 'package:channels/components/auth_form.dart';
import 'package:channels/components/auth_method_selector.dart';
import 'package:channels/components/error_message.dart';
import 'package:channels/network/firebase_auth_services.dart';
import 'package:channels/components/black_button.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final Function loggedIn;
  final Function togglePage;

  const LoginPage({
    super.key,
    required this.loggedIn,
    required this.togglePage,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController(),
      password = TextEditingController(),
      phone = TextEditingController();

  String selectedMethod = 'email';
  bool isLoading = false;
  String error = '';

  Future<void> loginProcess() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (selectedMethod == 'email') {
        if (email.text.isNotEmpty && password.text.isNotEmpty) {
          await FirebaseAuthServices.loginWithEmail(email.text, password.text);
          widget.loggedIn();
        } else {
          error = 'Please fill all fields';
        }
      } else {
        if (phone.text.isNotEmpty) {
          await FirebaseAuthServices.signInWithPhone(
            phone.text,
            () {
              setState(() {
                error = "Verification failed. Please try again.";
              });
            },
            widget.loggedIn
          );
        } else {
          error = 'Please fill all fields';
        }
      }
    } catch (e) {
      error = 'Login failed. Please try again.';
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loginInWithGoogle() async {
    try {
      await FirebaseAuthServices.signInWithGoogle();
      widget.loggedIn();
    } catch (_) {
      setState(() {
        error = 'Error hav been occurred';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),
                const Icon(Icons.login, size: 180, color: Colors.black),
                const SizedBox(height: 50),
                AuthForm(
                  selectedMethod: selectedMethod,
                  emailController: email,
                  passwordController: password,
                  phoneController: phone,
                ),
                const SizedBox(height: 20),
                ErrorMessage(error: error),
                const SizedBox(height: 20),
                AuthMethodSelector(
                  selectedMethod: selectedMethod,
                  toggleMethod: () => setState(() {
                    selectedMethod =
                        selectedMethod == 'email' ? 'phone' : 'email';
                  }),
                  googleAuth: loginInWithGoogle,
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    widget.togglePage('Register');
                  },
                  overlayColor:
                      const WidgetStatePropertyAll(Colors.transparent),
                  child: const Text(
                    'I don\'t have an account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : BlackButton(
                        onTap: loginProcess,
                        text: 'Login',
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
