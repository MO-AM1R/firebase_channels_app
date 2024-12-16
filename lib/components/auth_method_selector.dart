import 'package:channels/components/login_options.dart';
import 'package:flutter/material.dart';

class AuthMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final Function toggleMethod;
  final Function googleAuth;

  const AuthMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.toggleMethod,
    required this.googleAuth,
  });

  @override
  Widget build(BuildContext context) {
    return LoginOptions(
      option1Src: 'google.png',
      option1Func: () {
        googleAuth();
      },
      option2Func: () => toggleMethod(),
      option2Src: selectedMethod == 'email' ? 'phone.png' : 'email.png',
    );
  }
}
