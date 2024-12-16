import 'package:channels/models/chat.dart';
import 'package:firebase_database/firebase_database.dart';

class RealTimeDataBaseServices{
  static final FirebaseDatabase _realTimeDB = FirebaseDatabase.instance;

  static FirebaseDatabase get realTimeDB => _realTimeDB;

  static Future<void> addMessage(String body, String userName, String chatId) async {
    final messagesRef = RealTimeDataBaseServices.realTimeDB
        .ref()
        .child('chats/$chatId/messages');

    final messageId = messagesRef.push().key;

    final message = {
      'body': body,
      'userName': userName,
      'date': DateTime.now().millisecondsSinceEpoch,
    };

    await messagesRef.child(messageId!).set(message);
  }

  static void removeChat(Chat chat) async {
    final realtimeDBRef = _realTimeDB.ref('chats/${chat.id}');
    realtimeDBRef.remove();
  }
}