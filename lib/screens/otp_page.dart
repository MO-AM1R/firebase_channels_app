import 'dart:developer';
import 'package:channels/components/black_button.dart';
import 'package:channels/network/fire_store_services.dart';
import 'package:channels/network/firebase_auth_services.dart';
import 'package:flutter/material.dart';
import 'package:channels/main.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OtpPage extends StatefulWidget {
  final String verificationId;
  final String userName;
  final Function onVerificationSuccess;

  const OtpPage({
    super.key,
    required this.verificationId,
    required this.onVerificationSuccess,
    this.userName = "",
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String userCode = "";
  bool isLoading = false;
  String error = '';

  Future<void> verifyOtp() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      await FirebaseAuthServices().verifyOTP(widget.verificationId, userCode);

      if (widget.userName.isNotEmpty) {
        await FireStoreServices.addUser(
          widget.userName
        );
      }

      navigationKey.currentState!.pop();
      widget.onVerificationSuccess();
    } catch (e) {
      log(e.toString());
      setState(() {
        error = 'Invalid OTP. Please try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        scrolledUnderElevation: 0,
        title: Text(
          'Verify OTP',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
            fontSize: 30,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            OtpTextField(
              textStyle: const TextStyle(fontSize: 20),
              showCursor: false,
              numberOfFields: 6,
              showFieldAsBox: false,
              borderWidth: 2.0,
              autoFocus: true,
              enabledBorderColor: Colors.grey,
              onSubmit: (String verificationCode) {
                userCode = verificationCode;
              },
            ),
            const SizedBox(height: 10),
            if (error.isNotEmpty)
              Text(
                error,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 60),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: BlackButton(
                      onTap: verifyOtp,
                      text: 'Verify OTP',
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}