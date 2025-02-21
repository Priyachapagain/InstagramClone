import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_social_media_clone/post_screen/post_item.dart';
import 'package:rxdart/rxdart.dart';

class PostSection extends StatefulWidget {
  const PostSection({super.key});

  @override
  _PostSectionState createState() => _PostSectionState();
}

class _PostSectionState extends State<PostSection> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Future to store the list of users the current user follows
  late Future<List<String>> followingUsersFuture;

  @override
  void initState() {
    super.initState();
    followingUsersFuture = _getFollowingUsers();
  }

  /// Fetches the list of users the current user follows, including themselves
  Future<List<String>> _getFollowingUsers() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(uid).get();

    if (userDoc.exists && userDoc.data() != null) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<String> following = List<String>.from(userData['following'] ?? []);
      following.add(uid); //include the current user's own posts
      return following;
    }
    return [uid]; // if no following list, return only the users's own uid
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: FutureBuilder<List<String>>(
            future: followingUsersFuture,
            builder: (context, followingSnapshot) {
              if (followingSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (!followingSnapshot.hasData ||
                  followingSnapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "Follow users to see posts",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final followingUserIds = followingSnapshot.data!;
              final currentUser = _auth.currentUser;

              //Firestore has a limit of 10 items for 'whereIn', so we check the list size
              if (followingUserIds.length > 10) {
                //use multiple queries and merge them
                return StreamBuilder<List<QuerySnapshot>>(
                  stream: _getPostStream(followingUserIds),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData ||
                        snapshot.data!.every((query) => query.docs.isEmpty)) {
                      return const Center(
                        child: Text(
                          "No posts yet",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    //Merge all the posts from multiple queried into one list
                    final posts =
                        snapshot.data!.expand((query) => query.docs).toList();
                    return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post =
                              posts[index].data() as Map<String, dynamic>;
                          final postId = posts[index].id;
                          return PostItem(
                              post: post,
                              postId: postId,
                              currentUser: currentUser);
                        });
                  },
                );
              } else {
                //if 10 or fewer users are followed, use a single firestore query
                return StreamBuilder(
                  stream: _firestore
                      .collection('Post')
                      .where('userId', whereIn: followingUserIds)
                      .snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> postSnapshot) {
                    if (postSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!postSnapshot.hasData ||
                        postSnapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No posts yet",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    final posts = postSnapshot.data!.docs;
                    return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post =
                              posts[index].data() as Map<String, dynamic>;
                          final postId = posts[index].id;
                          return PostItem(
                            post: post,
                            postId: postId,
                            currentUser: currentUser,
                          );
                        });
                  },
                );
              }
            }));
  }

  /// Handle firestore's 10 item whereIn limit by merging multiple queries
  Stream<List<QuerySnapshot>> _getPostStream(List<String> userIds) {
    List<Stream<QuerySnapshot>> streams = [];
    // firestore allows only 10 items in wherein so we split init chunks
    for (var i = 0; i < userIds.length; i += 10) {
      var sublist =
          userIds.sublist(i, i + 10 > userIds.length ? userIds.length : i + 10);
      streams.add(_firestore
          .collection('Post')
          .where('userId', whereIn: sublist)
          .snapshots());
    }

    //Merge multiple Firestore streams inot single stream using RxDart
    return CombineLatestStream.list(streams);
  }
}
