import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentCard extends StatelessWidget {
  final String commentId;
  final String postId;
  final String username;
  final String comment;
  final String profileImageUrl;
  final List<String> likes;
  final bool isOwnerOrCommenter;
  final VoidCallback onDelete;
  final Timestamp timestamp;
  const CommentCard({
    super.key,
    required this.commentId,
    required this.postId,
    required this.username,
    required this.comment,
    required this.profileImageUrl,
    required this.likes,
    required this.isOwnerOrCommenter,
    required this.onDelete,
    required this.timestamp,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(profileImageUrl),
      ),
      title: Text(
        username,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        comment,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: isOwnerOrCommenter
          ? IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ))
          : null,
    );
  }
}
