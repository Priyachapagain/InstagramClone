import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentCard extends StatefulWidget {
  final String commentId;
  final String postId;
  final String username;
  final String comment;
  final String profileImageUrl;
  final List<String> likes;
  final bool isOwnerOrCommenter;
  final VoidCallback onDelete;
  final Timestamp timestamp;

  const CommentCard(
      {super.key,
      required this.comment,
      required this.commentId,
      required this.timestamp,
      required this.username,
      required this.postId,
      required this.likes,
      required this.profileImageUrl,
      required this.isOwnerOrCommenter,
      required this.onDelete});
  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(FirebaseAuth.instance.currentUser?.uid);
    likeCount = widget.likes.length;
  }

  Future<void> _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final commentRef = FirebaseFirestore.instance
        .collection('Post')
        .doc(widget.postId)
        .collection('comments')
        .doc(widget.commentId);

    setState(() {
      if (isLiked) {
        isLiked = false;
        likeCount--;
      } else {
        isLiked = true;
        likeCount++;
      }
    });

    if (isLiked) {
      await commentRef.update({
        'likes': FieldValue.arrayUnion([user.uid])
      });
    } else {
      await commentRef.update({
        'likes': FieldValue.arrayRemove([user.uid])
      });
    }
  }

  void _showDeleteDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Delete Comment',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content:
                const Text('Are you sure you want to delete this comment?'),
            actions: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text(
                  'Delete',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  widget.onDelete();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = widget.timestamp.toDate();
    final timeAgo = timeago.format(timestamp);

    return GestureDetector(
      onLongPress: widget.isOwnerOrCommenter ? _showDeleteDialog : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.profileImageUrl),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                        children: [
                          TextSpan(
                              text: "${widget.username}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: widget.comment)
                        ]),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    '$timeAgo ago',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  )
                ],
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey<bool>(isLiked),
                      color: isLiked ? Colors.red : Colors.grey,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  likeCount.toString(),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
