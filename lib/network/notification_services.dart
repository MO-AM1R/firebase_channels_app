import 'dart:developer';
import 'package:channels/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  // Firebase Messaging instance to interact with FCM
  static final _firebaseMessaging = FirebaseMessaging.instance;

  // Flutter Local Notifications Plugin instance for showing local notifications
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize Notification Services: FCM permissions and local notifications
  static Future init() async {
    // Request permissions for Firebase Messaging
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Fetch device token
    getToken();

    // Initialize local notifications
    localNotificationInit();
  }

  // Fetch the FCM device token with retry logic in case of failure
  static Future<void> getToken({int maxRetires = 3}) async {
    try {
      String? token = await _firebaseMessaging.getToken();
      log('Token is $token'); // Log the token
    } catch (e) {
      log('Error in token'); // Log failure after max retries
    }
  }

  // Initialize local notifications for Android, iOS, and Linux platforms
  static Future localNotificationInit() async {
    // Android-specific initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS-specific initialization settings with a callback for local notifications
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );

    // Linux-specific initialization settings
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    // Combine initialization settings for all platforms
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);

    // Initialize the plugin with callbacks for notification taps
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
  }

  // Callback when a local notification is tapped
  static void onNotificationTap(NotificationResponse notificationResponse) {
    // Navigate to the home screen when a notification is tapped
    navigationKey.currentState!.pushNamed("/home");
  }

  // Display a simple local notification
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    // Android-specific notification settings
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
    );

    // Combine platform-specific notification details
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    // Show the notification with the provided details
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }

  static void subscribeToChannel(String id) async {
    _firebaseMessaging.subscribeToTopic(id);
  }

  static void unSubscribeToChannel(String id) async {
    _firebaseMessaging.unsubscribeFromTopic(id);
  }
}