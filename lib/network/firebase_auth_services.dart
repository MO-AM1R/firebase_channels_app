import 'dart:developer';
import 'package:channels/main.dart';
import 'package:channels/network/firebase_analytics_services.dart';
import 'package:channels/network/fire_store_services.dart';
import 'package:channels/screens/otp_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthServices {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get getUserId => _auth.currentUser!.uid;

  static Future<void> loginWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    FirebaseAnalyticsServices.loginEvent(_auth.currentUser!.uid);
  }

  static Future<void> registerWithEmail(
      String email, String password, String userName) async {

    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    await FireStoreServices.addUser(userName);
  }

  static Future<void> signInWithPhone(String phone,
      Function onVerificationFailed, Function onVerificationSuccess,
      {String userName = ""}) async {

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {},
      verificationFailed: (FirebaseAuthException error) {
        log("Verification failed: ${error.message}");
        onVerificationFailed();
      },
      codeSent: (String verificationId, int? forceResendingToken) {
        navigationKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => OtpPage(
              verificationId: verificationId,
              userName: userName,
              onVerificationSuccess: onVerificationSuccess,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        log('Timed out');
      },
    );
  }

  Future<void> verifyOTP(String verificationId, String userOTP) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: userOTP,
    );

    await _auth.signInWithCredential(credential);
    FirebaseAnalyticsServices.loginEvent(_auth.currentUser!.uid);
  }

  static Future<void> registerWithGoogle() async {
    try {
      await signInWithGoogle();

      await FireStoreServices.addUser(_auth.currentUser!.displayName!);
    } catch (exception) {
      log(exception.toString());
      rethrow;
    }
  }

  static Future<void> signInWithGoogle() async {
    if (await GoogleSignIn().isSignedIn()) {
      await GoogleSignIn().signOut();
    }

    final googleUser = await GoogleSignIn().signIn();
    final googleAuth = await googleUser?.authentication;

    final cred = GoogleAuthProvider.credential(
      idToken: googleAuth?.idToken,
      accessToken: googleAuth?.accessToken,
    );

    await _auth.signInWithCredential(cred);
    FirebaseAnalyticsServices.loginEvent(_auth.currentUser!.uid);
  }

  static void logout() async {
    await _auth.signOut();
  }
}