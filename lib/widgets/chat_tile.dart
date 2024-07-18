import 'package:chat/models/user_profile.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final UserProfile userProfile;
  final Function onTap;
  final String lastMessage;
  // final DateTime timestamp;
  final String sender;
  const ChatTile({
    super.key,
    required this.userProfile,
    required this.onTap,
    required this.lastMessage,
    required this.sender,
    // required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTap();
      },
      dense: false,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userProfile.pfpURL!),
      ),
      title: Text(userProfile.name!),
      subtitle: lastMessage == ""
          ? const Text(
              "Start a conversation",
              style: TextStyle(
                overflow: TextOverflow.ellipsis,
              ),
            )
          : Text(
              "$sender: $lastMessage",
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
              ),
            ),
    );
  }
}
