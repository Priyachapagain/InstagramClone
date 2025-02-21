import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentInputField extends StatefulWidget {
  final String profileImageUrl;
  final String postId;
  final String username;
  final VoidCallback onCommentSubmitted;
  final String userId;
  const CommentInputField(
      {super.key,
      required this.profileImageUrl,
      required this.postId,
      required this.username,
      required this.onCommentSubmitted,
      required this.userId});

  @override
  State<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  final TextEditingController _controller = TextEditingController();

  void _postComment() async {
    if (_controller.text.trim().isEmpty) return;
    await FirebaseFirestore.instance
        .collection('Reel')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'text': _controller.text,
      'username': widget.username,
      'userId': widget.userId,
      'imageUrl': widget.profileImageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': []
    });

    _controller.clear();
    widget.onCommentSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.profileImageUrl),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                  hintText: "Add a comment...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white54)),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
              onPressed: _postComment,
              icon: const Icon(
                Icons.send,
                color: Colors.blue,
              ))
        ],
      ),
    );
  }
}
