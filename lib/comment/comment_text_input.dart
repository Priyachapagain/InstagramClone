import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentInputField extends StatefulWidget{
  final String? profileImageUrl;
  final String postId;
  final String? username;
  final String? userid;
  final VoidCallback onCommentSubmitted;

  const CommentInputField({
    super.key,
    required this.username,
    required this.profileImageUrl,
    required this.postId,
    required this.onCommentSubmitted,
    required this.userid
});

  @override
  _CommentInputFieldState createState() =>
      _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField>{
  final TextEditingController _commentController =
      TextEditingController();

  Future<void> _submitComment() async {
    if(_commentController.text.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if(user == null) return;

    String commentId = FirebaseFirestore.instance.collection('Post')
    .doc(widget.postId)
    .collection('comments')
    .doc()
    .id;

    await FirebaseFirestore.instance.collection('Post')
    .doc(widget.postId)
    .collection('comments')
    .doc(commentId)
    .set({
      'text':_commentController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'userid': widget.userid,
      'username':widget.username,
      'imageUrl': widget.profileImageUrl,
      'likes':[],
      'commentId': commentId
    });

    _commentController.clear();
    widget.onCommentSubmitted();
  }

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: widget.profileImageUrl != null
              ? NetworkImage(widget.profileImageUrl!)
                : const NetworkImage(''),
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Write a comment...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: null,
            ),
          ),
          IconButton(onPressed: _submitComment,
              icon: Icon(Icons.send, color: Colors.white,))
        ],
      ),
    );
  }
}