import 'dart:convert';
import 'dart:developer';
import 'package:channels/models/channel.dart';
import 'package:channels/network/firebase_analytics_services.dart';
import 'package:channels/network/fire_store_services.dart';
import 'package:channels/network/notification_services.dart';
import 'package:channels/screens/chat_screen.dart';
import 'package:channels/screens/home_screen.dart';
import 'package:channels/auth_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

// function to listen to background changes
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    log('Background Notification received');
  }
}

Future<void> _notificationInit() async {
  // on background notification tapped
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      navigationKey.currentState!.pushNamed("/subscribed", arguments: message);
    }
  });

  NotificationServices.init();

  // Listen to background or terminated notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // to show foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);

    if (message.notification != null) {
      NotificationServices.showSimpleNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: payloadData);
    }
  });
}

GlobalKey<NavigatorState> navigationKey = GlobalKey();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _notificationInit();
  await FireStoreServices.getAllChannels();

  FirebaseAnalyticsServices.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const AuthHandler());
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          case '/chat':
            final channel = settings.arguments as Channel;
            return MaterialPageRoute(
              builder: (context) => ChatScreen(channel: channel),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const AuthHandler(),
            );
        }
      },
      initialRoute: '/',
      navigatorKey: navigationKey,
    );
  }
}