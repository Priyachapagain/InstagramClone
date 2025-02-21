import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> navigateToChat(
  {required BuildContext context,
    required String currentUserId,
    required String otherUserId
  }) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(otherUserId).get();

      if(!userSnapshot.exists){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found.")),
        );
        return;
      }

      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;
      String otherUserName = userData?['username'] ?? 'unknown';
      String otherUserProfile =
          userData?['profilePictureUrl'] ?? '';

      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ChatScreen(
              currentUserId: currentUserId,
              otherUserId: otherUserId,
              otherUserName: otherUserName,
              otherUserProfile: otherUserProfile)));
    } catch(e){
      print("Error navigating to chat: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to open chat."))
      );
    }
  }
}