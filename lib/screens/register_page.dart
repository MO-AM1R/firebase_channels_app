import 'dart:async';
import 'package:channels/components/auth_form.dart';
import 'package:channels/components/auth_method_selector.dart';
import 'package:channels/components/black_button.dart';
import 'package:channels/components/custom_text_field.dart';
import 'package:channels/components/error_message.dart';
import 'package:channels/network/firebase_auth_services.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final Function loggedIn;
  final Function togglePage;

  const RegisterPage({
    super.key,
    required this.loggedIn,
    required this.togglePage,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController email = TextEditingController(),
      password = TextEditingController(),
      phone = TextEditingController(),
      userName = TextEditingController();

  String selectedMethod = 'email';
  bool isLoading = false;
  String error = '';

  Future<void> registerProcess() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (selectedMethod == 'email') {
        if (email.text.isNotEmpty &&
            password.text.isNotEmpty &&
            userName.text.isNotEmpty) {
          await FirebaseAuthServices.registerWithEmail(
              email.text, password.text, userName.text);
          widget.loggedIn();
        } else {
          error = 'Please fill all fields';
        }
      } else {
        if (phone.text.isNotEmpty && userName.text.isNotEmpty) {
          await FirebaseAuthServices.signInWithPhone(phone.text, () {
            setState(() {
              error = "Verification failed. Please try again.";
            });
          },
          userName: userName.text,
            widget.loggedIn,
          );
        } else {
          error = 'Please fill all fields';
        }
      }
    } catch (e) {
      error = 'Registration failed. Please try again.';
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> registerWithGoogle() async {
    try {
      await FirebaseAuthServices.registerWithGoogle();
      widget.loggedIn();
    } catch (_) {
      setState(() {
        error = 'Error have been occurred';
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
                const Icon(Icons.person_add, size: 180, color: Colors.black),
                const SizedBox(height: 50),

                // Auth Form (Username + Email/Phone + Password)
                Column(
                  children: [
                    CustomTextField(
                      controller: userName,
                      icon: Icons.person,
                      label: 'userName',
                    ),
                    const SizedBox(height: 30),
                    AuthForm(
                      selectedMethod: selectedMethod,
                      emailController: email,
                      passwordController: password,
                      phoneController: phone,
                    ),
                  ],
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
                  googleAuth: registerWithGoogle,
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    widget.togglePage('Login');
                  },
                  overlayColor:
                  const WidgetStatePropertyAll(Colors.transparent),
                  child: const Text(
                    'I already have an account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Register Button
                isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : BlackButton(
                  onTap: registerProcess,
                  text: 'Register',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}