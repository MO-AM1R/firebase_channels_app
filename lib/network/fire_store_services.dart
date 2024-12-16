import 'dart:developer';
import 'package:channels/constants.dart';
import 'package:channels/models/channel.dart';
import 'package:channels/models/chat.dart';
import 'package:channels/network/firebase_analytics_services.dart';
import 'package:channels/models/message.dart';
import 'package:channels/models/user.dart';
import 'package:channels/network/firebase_auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreServices {
  static final FirebaseFirestore _fStore = FirebaseFirestore.instance;


  static Future<void> getUserInfo(String userId) async {
    final userDoc = await _fStore.collection('users').doc(userId).get();

    List<Channel> subscribedChannels = [];
    List channelRefs = userDoc.get('subscribedChannels');

    for (DocumentReference channelRef in channelRefs) {
      String id = (await channelRef.get()).get('id');
      subscribedChannels.add(channels.firstWhere((channel) => channel.id == id));
    }

    user = User(
        userName: userDoc.get('userName'),
        id: userDoc.get('id'),
        subscribedChannels: subscribedChannels);

    initialized = true;
  }

  static Future<Chat> extractChat(DocumentReference chatRef) async {
    String chatId = (await chatRef.get()).get('id');

    List messagesRefs = (await chatRef.get()).get('messages');
    List<Message> messages = [];

    for (DocumentReference messageRef in messagesRefs) {
      messages.add(await extractMessage(messageRef));
    }

    return Chat(chatId, messages);
  }

  static Future<Message> extractMessage(DocumentReference messageRef) async {
    String body = (await messageRef.get()).get('body');
    String userName = (await messageRef.get()).get('userName');
    Timestamp time = (await messageRef.get()).get('date');

    return Message(body, userName, time);
  }

  static Future<void> getAllChannels() async {
    List<Channel> temp = [];

    await _fStore.collection('channels').get().then(
          (value) async {
        for (var doc in value.docs) {
          Map<String, dynamic> channelData = doc.data();

          temp.add(Channel(
              id: channelData['id'],
              name: channelData['name'],
              description: channelData['description'],
              imageUrl: channelData['imageUrl'],
              chat: await extractChat(channelData['chat'])));
        }
      },
    );

    channels = temp;
  }

  static addMessagesToFireStore(List<Message> messages, String chatId) async {
    CollectionReference messagesRef = _fStore.collection('messages');
    DocumentReference chatDocRef = _fStore.collection('chats').doc(chatId);

    try {
      List<DocumentReference> chatMessageRefs = [];

      for (var message in messages) {
        DocumentReference messageRef = await messagesRef.add({
          'body': message.body,
          'date': message.time,
          'userName': message.userName,
        });

        chatMessageRefs.add(messageRef);
      }

      await chatDocRef.update({
        'messages': FieldValue.arrayUnion(chatMessageRefs),
      });
    } catch (e) {
      //
    }
  }

  static void updateSubscribedChannels() async {
    try {
      // Reference to the users collection and the specific user document
      DocumentReference userRef = _fStore.collection('users').doc(user.id);

      // Create a list of references to the subscribed channels
      List<DocumentReference> channelRefs = [];
      for(Channel channel in user.subscribedChannels){
        channelRefs.add(_fStore.collection('channels').doc(channel.id));
      }

      // Replace the old list with the new one
      await userRef.update({
        'subscribedChannels': channelRefs,
        // Replace the list of subscribed channels
      });
    } catch (e) {
      //
    }
  }

  static void addChannel(Channel channel) async {
    try {
      DocumentReference chatRef =
        _fStore.collection('chats').doc(channel.chat.id);

      await chatRef.set({
        'id': channel.chat.id.toString(),
        'messages': [],
      });

      await _fStore.collection('channels').doc(channel.id).set({
        'name': channel.name,
        'imageUrl': channel.imageUrl,
        'description': channel.description,
        'chat': chatRef,
        'id': channel.id.toString(),
      });
    } catch (e) {
      log('Error adding channel and chat: $e');
    }
  }

  static void removeChannel(Channel channel) async {
    DocumentReference channelRef = _fStore.collection('/channels').doc(
        channel.id);

    DocumentReference chatRef = _fStore.collection('/chats').doc(
        channel.chat.id);

    final usersRef = await _fStore.collection('/users').get();
    for (var userDoc in usersRef.docs) {
      List channelsRef = userDoc.get('subscribedChannels');

      if (channelsRef.any((ref) => ref.id == channel.id)) {
        await userDoc.reference.update({
          'subscribedChannels': FieldValue.arrayRemove([channelRef])
        });
      }
    }

    List messagesRefs = (await chatRef.get()).get('messages');
    for (DocumentReference messageRef in messagesRefs) {
      await messageRef.delete();
    }

    await channelRef.delete();
    await chatRef.delete();
  }

  static addUser(String userName) async {
    try {
      String userId = FirebaseAuthServices.getUserId;
      DocumentReference userDoc = _fStore.collection('/users').doc(userId);

      // Data to add
      Map<String, dynamic> userData = {
        'userName': userName,
        'id': userId,
        'subscribedChannels': []
      };

      await userDoc.set(userData);

      user = User(
          userName: userName,
          id: FirebaseAuthServices.getUserId,
          subscribedChannels: []);

      initialized = true;

      await FirebaseAnalyticsServices.logFirstTimeLoginEvent(userId);
    } catch (e) {
      log("Error adding document: $e");
    }
  }
}