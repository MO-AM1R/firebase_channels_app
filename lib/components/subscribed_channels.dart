import 'package:channels/components/channel_list_tile.dart';
import 'package:channels/constants.dart';
import 'package:flutter/material.dart';

class SubscribedChannels extends StatelessWidget {
  const SubscribedChannels({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: user.subscribedChannels.length,
            itemBuilder: (context, index) {
              return ChannelListTile(channel: user.subscribedChannels[index]);
            },
          ),
        ),
      ],
    );
  }
}

