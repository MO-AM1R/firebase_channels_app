import 'package:channels/network/notification_services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsServices {
  static late final FirebaseAnalytics _analytics;
  static late final FirebaseAnalyticsObserver _analyticsObserver;

  FirebaseAnalyticsServices.init() {
    _analytics = FirebaseAnalytics.instance;
    _analyticsObserver = FirebaseAnalyticsObserver(analytics: _analytics);
  }

  static Future<void> logFirstTimeLoginEvent(String userId) async {
    await _analytics.logEvent(
      name: 'first_time_login',
      parameters: {
        'user_id': userId,
        'login_time': DateTime.now().toIso8601String(),
      },
    );

    await NotificationServices.showSimpleNotification(
      title: 'Welcome!',
      body: 'Thank you for logging in for the first time. Enjoy your experience!',
      payload: 'first_time_login',
    );
  }

  static Future<void> loginEvent(String userId) async {
    await _analytics.logLogin(
      parameters: {
        'user_id': userId,
        'login_time': DateTime.now().toIso8601String(),
      },
    );

    await NotificationServices.showSimpleNotification(
      title: 'Welcome Back!',
      body: 'It’s great to see you again. Explore more channels!',
      payload: 'login_event',
    );
  }

  static Future<void> channelSubscription(String userId, String channelId) async {
    await _analytics.logEvent(
      name: 'subscribe_channel',
      parameters: {
        'user_id': userId,
        'channel_id': channelId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    await NotificationServices.showSimpleNotification(
      title: 'Subscribed Successfully',
      body: 'You’ve subscribed to the channel: $channelId. Enjoy the content!',
      payload: 'subscribe_channel',
    );
  }

  static Future<void> channelUnSubscription(String userId, String channelId) async {
    await _analytics.logEvent(
      name: 'un_subscribe_channel',
      parameters: {
        'user_id': userId,
        'channel_id': channelId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    await NotificationServices.showSimpleNotification(
      title: 'Unsubscribed',
      body: 'You’ve unsubscribed from the channel: $channelId. We hope to see you back!',
      payload: 'un_subscribe_channel',
    );
  }
}