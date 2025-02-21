import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_social_media_clone/comment/comment_card.dart';
import 'package:instagram_social_media_clone/comment/comment_text_input.dart';




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
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists && mounted) {
        setState(() {
          currentUser = user;
          profileImageUrl = userDoc['profilePictureUrl'] ?? '';
          username = userDoc['username'] ?? '';
          userid = user.uid;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _deleteComment(String commentId) async {
    await FirebaseFirestore.instance
        .collection('Post')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Post')
                        .doc(widget.postId)
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text(
                          'Error loading comments',
                          style: TextStyle(color: Colors.white),
                        ));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No comments yet',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var commentData = snapshot.data!.docs[index];

                          String commentId = commentData['commentId'] ?? '';
                          String commentText = commentData['text'] ?? '';
                          String commentUsername =
                              commentData['username'] ?? 'unknown';
                          String commentImageUrl =
                              commentData['imageUrl'] ?? '';
                          List<String> commentLikes =
                              List<String>.from(commentData['likes'] ?? []);

                          bool isOwnerorCommenter =
                              currentUser?.uid == commentData['userid'];
                          Timestamp? timestamp =
                              (commentData.data() as Map<String, dynamic>)['timestamp'] ??
                                  Timestamp.now();

                          return CommentCard(
                              comment: commentText,
                              commentId: commentId,
                              timestamp: timestamp!,
                              username: commentUsername,
                              postId: widget.postId,
                              likes: commentLikes,
                              profileImageUrl: commentImageUrl,
                              isOwnerOrCommenter: isOwnerorCommenter,
                              onDelete: () => _deleteComment(commentId));
                        },
                      );
                    })),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: CommentInputField(
                  username: username ?? 'unknown',
                  profileImageUrl: profileImageUrl ?? '',
                  postId: widget.postId,
                  onCommentSubmitted: _scrollToBottom,
                  userid: userid ?? ''),
            )
          ],
        ),
      ),
    );
  }
}
