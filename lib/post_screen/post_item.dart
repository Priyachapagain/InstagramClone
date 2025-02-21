import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../comment/comment_screen.dart';
import '../provider/post_like_provider.dart';

class PostItem extends StatefulWidget {
  final Map<String, dynamic> post;
  final String postId;
  final User? currentUser;

  const PostItem(
      {super.key,
      required this.postId,
      required this.currentUser,
      required this.post});

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  String username = "Unknown";
  String profilePicture = '';
  List<dynamic> likesList = [];

  @override
  void initState() {
    super.initState();
    likesList = widget.post['likes'] ?? [];
    fetchUserData(); // fetch username and profile picture only once
  }

  Future<void> fetchUserData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.post['userId'])
        .get();
    if (userDoc.exists) {
      setState(() {
        username = userDoc['username'] ?? 'unknown';
        profilePicture = userDoc['profilePictureUrl'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(profilePicture),
            ),
            title: Text(
              username,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.post['mediaUrl'],
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              children: [
                Consumer<LikeProvider>(
                  builder: (context, provider, child) {
                    bool isLiked = widget.currentUser != null &&
                        likesList.contains(widget.currentUser!.uid);
                    return IconButton(
                      icon: Icon(
                        size: 25,
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        if (widget.currentUser != null) {
                          provider.toggleLike(widget.postId, likesList,
                              widget.currentUser!.uid);
                        }
                      },
                    );
                  },
                ),
                Consumer<LikeProvider>(
                  builder: (context, provider, child) {
                    return Text(
                      '${likesList.length} likes',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentScreen(postId: widget.postId),
                      ),
                    );

                  },
                  child: Image.asset(
                    'assets/Images/comment.png',
                    color: Colors.white,
                    width: 23,
                  ),
                )
              ],
            ),
          ),
          if (widget.post['caption'] != null)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: '$username',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                      text: widget.post['caption'],
                      style: const TextStyle(color: Colors.white))
                ]),
              ),
            )
        ],
      ),
    );
  }
}
