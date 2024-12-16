import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String error;

  const ErrorMessage({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return error.isNotEmpty
        ? Align(
      alignment: Alignment.centerLeft,
      child: Text(
        error,
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
    )
        : const SizedBox();
  }
}
