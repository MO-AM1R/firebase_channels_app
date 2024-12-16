import 'package:channels/components/custom_text_field.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatelessWidget {
  final String selectedMethod;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController phoneController;

  const AuthForm({
    super.key,
    required this.selectedMethod,
    required this.emailController,
    required this.passwordController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return selectedMethod == 'email'
        ? Column(
      children: [
        CustomTextField(
          controller: emailController,
          icon: Icons.email,
          label: 'Email',
        ),
        const SizedBox(height: 30),
        CustomTextField(
          controller: passwordController,
          icon: Icons.password,
          obscureText: true,
          label: 'Password',
        ),
      ],
    )
        : CustomTextField(
      controller: phoneController,
      icon: Icons.phone,
      textInputType: TextInputType.phone,
      label: 'Phone Number',
    );
  }
}