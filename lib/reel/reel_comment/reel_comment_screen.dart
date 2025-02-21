import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../reel/reel_comment/reel_comment_card.dart';
import '../../reel/reel_comment/reel_comment_input_textfield.dart';

class CommentScreen extends StatefulWidget {
  final String postId;
  const CommentScreen({super.key, required this.postId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  User? currentUser;
  String? profileImageUrl;
  String? username;
  String? userid;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState(){
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if(user != null){
      DocumentSnapshot userDoc = await
          FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if(userDoc.exists){
        setState(() {
          currentUser = user;
          profileImageUrl = userDoc['profilePictureUrl'] ?? '';
          username = userDoc['username'] ?? 'Unknown';
          userid = user.uid;
        });
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    await FirebaseFirestore.instance.collection('Reel')
        .doc(widget.postId).collection('comments').doc(commentId).delete();
  }

  void _scrollToBottom(){
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(_scrollController.hasClients){
        _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comments"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('Reel')
                .doc(widget.postId).collection('comments').orderBy('timestamp',
                  descending: true
                ).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if(!snapshot.hasData) return
                      const Center(child: CircularProgressIndicator(),);
                  var comments = snapshot.data!.docs;
                  return ListView.builder(
                      controller: _scrollController,
                      itemCount: comments.length,
                      itemBuilder: (context, index){
                        var commentData = comments[index];
                        return CommentCard(
                            comment: commentData['text'] ?? '',
                            commentId: commentData.id,
                            timestamp: commentData['timestamp'] as Timestamp? ?? Timestamp.now(),
                            username: commentData['username'] ?? 'Unknown',
                            postId: widget.postId,
                            likes: List<String>.from(commentData['likes'] ?? []),
                            profileImageUrl: commentData['imageUrl'] ?? '',
                            isOwnerOrCommenter: currentUser?.uid == commentData['userId'],
                            onDelete: () => _deleteComment(commentData.id));
                      }
                  );
                }
            ),

          ),
          CommentInputField(
              profileImageUrl: profileImageUrl ?? '',
              postId: widget.postId,
              username: username ?? 'Unknown',
              onCommentSubmitted: _scrollToBottom,
              userId: userid ?? '')
        ],
      ),
    );
  }
}
