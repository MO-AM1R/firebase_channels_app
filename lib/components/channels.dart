import 'package:channels/components/add_channel_button.dart';
import 'package:channels/components/channel_card.dart';
import 'package:channels/constants.dart';
import 'package:channels/models/channel.dart';
import 'package:channels/models/chat.dart';
import 'package:channels/network/firebase_analytics_services.dart';
import 'package:channels/network/fire_store_services.dart';
import 'package:channels/network/notification_services.dart';
import 'package:channels/network/real_time_data_base_services.dart';
import 'package:flutter/material.dart';

class Channels extends StatefulWidget {
  const Channels({super.key});

  @override
  State<Channels> createState() => _ChannelsState();
}

class _ChannelsState extends State<Channels> {
  bool changed = false;

  void onSubscriptionChanged(bool value, int ind) {
    if (value) {
      user.subscribedChannels.add(channels[ind]);
      FirebaseAnalyticsServices.channelSubscription(user.id, channels[ind].id);
      NotificationServices.subscribeToChannel(channels[ind].id);
    } else {
      user.subscribedChannels.remove(channels[ind]);
      FirebaseAnalyticsServices.channelUnSubscription(user.id, channels[ind].id);
      NotificationServices.unSubscribeToChannel(channels[ind].id);
    }

    changed = true;
    setState(() {});
  }

  void removeChannel(int index) {
    Channel channel = channels.removeAt(index);
    FireStoreServices.removeChannel(channel);
    RealTimeDataBaseServices.removeChat(channel.chat);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
        ),
        Expanded(
          flex: 9,
          child: ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              return ChannelCard(
                channel: channels[index],
                subscribed: user.subscribedChannels.contains(channels[index]),
                onSubscriptionChanged: onSubscriptionChanged,
                removeChannel: removeChannel,
                index: index,
              );
            },
          ),
        ),
        const Spacer(
          flex: 1,
        ),
        Center(
          child: AddChannelButton(onTap: addChannelDialog),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (changed) {
      FireStoreServices.updateSubscribedChannels();
    }
  }

  void addChannel(String name, String imageUrl, String description) {
    String id = (channels.length + 1).toString();

    Chat chat = Chat(id, []);
    Channel channel = Channel(
        id: id,
        name: name,
        description: description,
        imageUrl: imageUrl,
        chat: chat);

    FireStoreServices.addChannel(channel);
    channels.add(channel);
    setState(() {});
  }

  void addChannelDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController imageUrlController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Channel'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Channel Name',
                    hintText: 'Enter the name of the channel',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    hintText: 'Enter the image URL for the channel',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter a description for the channel',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                String name = nameController.text;
                String imageUrl = imageUrlController.text;
                String description = descriptionController.text;

                addChannel(name, imageUrl, description);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}