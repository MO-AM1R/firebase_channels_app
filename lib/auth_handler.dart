import 'package:channels/constants.dart';
import 'package:channels/network/fire_store_services.dart';
import 'package:channels/screens/home_screen.dart';
import 'package:channels/screens/login_page.dart';
import 'package:channels/screens/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthHandler extends StatefulWidget {
  const AuthHandler({super.key});

  @override
  State<AuthHandler> createState() => _AuthHandlerState();
}

class _AuthHandlerState extends State<AuthHandler> {
  String currentPage = 'Login';

  void toggle(String page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      initialized = false;
      FireStoreServices.getUserInfo(user.uid);
      return const HomeScreen();
    } else {
      return currentPage == 'Login'
          ? LoginPage(
              loggedIn: () => setState(() {}),
              togglePage: toggle,
            )
          : RegisterPage(
        loggedIn: () => setState(() {}),
        togglePage: toggle,
      );
    }
  }
}
