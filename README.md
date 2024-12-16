# Flutter Notification Services

A Flutter project that integrates **Firebase Cloud Messaging** (FCM) and **local notifications** to provide a seamless notification experience. This project includes requesting permissions, receiving push notifications, and displaying them locally using the Flutter Local Notifications plugin.

---

## Features
- **Firebase Cloud Messaging (FCM)**: Receive and handle push notifications.
- **Local Notifications**: Display notifications when the app is in the foreground or background.
- **Payload Handling**: Navigate to specific screens or perform actions based on custom data.
- **Device Token Retrieval**: Fetch the unique device FCM token for messaging.

---

## Technologies Used
- **Flutter** (Dart)
- **Firebase Cloud Messaging**
- **flutter_local_notifications**
- **Android & iOS Integration**

---

## Setup Instructions

### Prerequisites
1. Install **Flutter SDK**: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
2. Install **Firebase CLI**: [Firebase Setup](https://firebase.google.com/docs/cli)
3. Add your **Firebase Project** to the app.

---

### Steps to Run the Project
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/your-repo-name.git
   cd your-repo-name
   ```

2. **Set Up Firebase**:
   - Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to your project.
   - Enable Firebase Cloud Messaging in the Firebase Console.

3. **Add Dependencies**:
   Add the following dependencies in your `pubspec.yaml` file:
   ```yaml
   dependencies:
     firebase_core: ^2.0.0
     firebase_messaging: ^14.0.0
     flutter_local_notifications: ^16.0.0
   ```
   Run:
   ```bash
   flutter pub get
   ```

4. **Configure Local Notifications**:
   - Add the required platform-specific permissions:
     - **Android**: Update `AndroidManifest.xml`
       ```xml
       <uses-permission android:name="android.permission.INTERNET"/>
       <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
       ```
     - **iOS**: Add the permissions in `Info.plist`:
       ```xml
       <key>UIBackgroundModes</key>
       <array>
         <string>fetch</string>
         <string>remote-notification</string>
       </array>
       ```

5. **Run the App**:
   ```bash
   flutter run
   ```

---

## Project Structure
```
/lib
 |-- main.dart                # App entry point
 |-- notification_services.dart  # Notification logic
 |-- utils/                   # Helper functions
 |-- firebase_options.dart    # Firebase configurations
```

---

## Usage

### Initialize Notification Services
Ensure to initialize the notification services when the app starts:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationServices.init();
  runApp(MyApp());
}
```

### Show a Local Notification
Use the `showSimpleNotification` method to display a notification:
```dart
NotificationServices.showSimpleNotification(
  title: 'Hello!',
  body: 'This is a test notification',
  payload: 'custom-data-id',
);
```

### Handle Notification Tap
Handle user interactions with notifications and navigate accordingly:
```dart
static void onNotificationTap(NotificationResponse response) {
  String? payload = response.payload;
  if (payload != null) {
    // Perform navigation or actions
    print('Payload received: $payload');
  }
}
```

---

## Firebase Token Logging
The Firebase token is logged to the console:
```dart
String? token = await FirebaseMessaging.instance.getToken();
print('Device Token: $token');
```

---

## Troubleshooting
1. **Notifications not showing?**
   - Check if permissions are granted.
   - Ensure `flutter_local_notifications` is configured correctly for your platform.
2. **FCM Token is null?**
   - Verify Firebase is properly set up and `google-services.json` or `GoogleService-Info.plist` is added.

---

## Contributing
Contributions are welcome! If you find any bugs or want to enhance this project, feel free to open an issue or submit a pull request.

---