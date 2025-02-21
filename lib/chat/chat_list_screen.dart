import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final String currentUserId;
  const ChatListScreen({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Messages"), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: currentUserId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(
              child: CircularProgressIndicator(),
            );
          var chats = snapshot.data!.docs;
          if (chats.isEmpty) {
            return const Center(
              child: Text(
                "No messages yet",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                var chat = chats[index].data() as Map<String, dynamic>;
                // Get the other user's ID from the chat
                List<dynamic> userIds = chat['users'] ?? [];
                String? otherUserId = userIds.firstWhere(
                    (id) => id != currentUserId,
                    orElse: () => null);

                if (otherUserId == null) return const SizedBox.shrink();
                return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(otherUserId)
                        .get(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return const SizedBox.shrink();
                      }

                      var userData =
                          userSnapshot.data!.data() as Map<String, dynamic>;
                      String otherUserName = userData['username'] ?? 'unknown';
                      String otherUserProfile =
                          userData['profilePictureUrl'] ?? "";
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(otherUserProfile),
                        ),
                        title: Text(
                          otherUserName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          chat['lastMessage'] ?? "No messages yet",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                      currentUserId: currentUserId,
                                      otherUserId: otherUserId,
                                      otherUserName: otherUserName,
                                      otherUserProfile: otherUserProfile)));
                        },
                      );
                    });
              });
        },
      ),
    );
  }
}
