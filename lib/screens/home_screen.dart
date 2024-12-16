import 'package:channels/components/bottom_nav_bar.dart';
import 'package:channels/components/channels.dart';
import 'package:channels/components/subscribed_channels.dart';
import 'package:channels/constants.dart';
import 'package:channels/main.dart';
import 'package:channels/network/firebase_auth_services.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> bodies = [
    const Channels(),
    const SubscribedChannels(),
  ];

  void logout() {
    FirebaseAuthServices.logout();
    navigationKey.currentState!.pushReplacementNamed('/');
  }

  void onTap(int ind) {
    currentIndex = ind;
    setState(() {});
  }

  Future<void> initializeData() async {
    while (!initialized) {
      await Future.delayed(const Duration(milliseconds: 100));
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
          currentIndex == 0 ? 'Channels' : 'Subscribed Channels',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
            fontSize: 30,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              logout();
            },
            icon: const Icon(
              Icons.logout_outlined,
              size: 30,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: FutureBuilder<void>(
            future: initializeData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text("Error: ${snapshot.error}"),
                );
              }
              return bodies[currentIndex];
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: onTap,
      ),
    );
  }
}
