import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'full_view_story.dart';

class StorySection extends StatefulWidget {
  const StorySection({super.key});

  @override
  State<StorySection> createState() => _StorySectionState();
}

class _StorySectionState extends State<StorySection> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<List<String>> usersWithStoriesFuture;

  @override
  void initState() {
    super.initState();
    usersWithStoriesFuture = _getUsersWithStories();
  }

  ///Fetch users who have stories within the last 24 hours
  /// and are followed by the current user
  Future<List<String>> _getUsersWithStories() async {
    String uid = _auth.currentUser!.uid;

    //Get the list of users that the current user follows
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(uid).get();

    if (!userSnapshot.exists) return [];

    List<String> followingList =
        List<String>.from(userSnapshot['following'] ?? []);

    //Fetch users who have stories in the last 24 hours
    QuerySnapshot storySnapshot = await _firestore.collection('Story').get();

    Set<String> usersWithStories = {};

    DateTime now = DateTime.now();

    for (var story in storySnapshot.docs) {
      Timestamp storyTimestamp = story['timestamp'];
      DateTime storyTime = storyTimestamp.toDate();
      String userId = story['userId'];

      if (now.difference(storyTime).inHours < 24) {
        if (followingList.contains(userId)) {
          usersWithStories.add(userId);
        }
      }
    }

    return usersWithStories.toList();
  }

  /// Check if a specific user has a story in the last 24 hours
  Future<bool> _hasStory(String userId) async {
    QuerySnapshot storySnapshot = await _firestore
        .collection('Story')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    DateTime now = DateTime.now();

    for (var doc in storySnapshot.docs) {
      Timestamp storyTimestamp = doc['timestamp'];
      DateTime storyTime = storyTimestamp.toDate();
      if (now.difference(storyTime).inHours < 24) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<List<String>>(
        future: usersWithStoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          final userIdsWithStories = snapshot.data ?? [];
          return SizedBox(
            height: 100,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: userIdsWithStories.length + 1, // +1 for current user
                itemBuilder: (context, index) {
                  // First item is always the current user's profile
                  String userId = (index == 0)
                      ? currentUser.uid
                      : userIdsWithStories[index - 1];

                  return FutureBuilder<DocumentSnapshot>(
                    future: _firestore.collection('users').doc(userId).get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox(
                          width: 60,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return const SizedBox();
                      }
                      final user =
                          userSnapshot.data!.data() as Map<String, dynamic>;
                      final username = (userId == currentUser.uid)
                          ? "Your Story"
                          : user['username'] ?? 'Unknown';
                      final profilePicture = user['profilePictureUrl'] ?? '';
                      return FutureBuilder<bool>(
                        future: _hasStory(userId),
                        builder: (context, hasStorySnapshot) {
                          bool hasStory = hasStorySnapshot.data ?? false;
                          return GestureDetector(
                            onTap: () async {
                              List<QueryDocumentSnapshot> userStories =
                                  await _fetchUserStories(userId);

                              if (userStories.isNotEmpty) {
                                Navigator.push(context, MaterialPageRoute(builder:
                                    (context) => FullStoryView(
                                      stories: userStories, // ✅ Correct Firestore documents
                                      initialIndex: 0,
                                    ),


                                ));
                                //navigate to story full view screen
                              } else if (userId == currentUser.uid) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Create a Story")));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("No stories available")));
                              }
                            },
                            child: _buildStoryItem(profilePicture, username,
                                hasStory: hasStory),
                          );
                        },
                      );
                    },
                  );
                }),
          );
        },
      ),
    );
  }

  /// Fetch stories of a specific user(only from the last 24 hours)
  Future<List<QueryDocumentSnapshot>> _fetchUserStories(String userId) async {
    QuerySnapshot storySnapshot = await _firestore
        .collection('Story')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    List<QueryDocumentSnapshot> stories = [];

    for (var doc in storySnapshot.docs) {
      Timestamp storyTimestamp = doc['timestamp'];
      DateTime storyTime = storyTimestamp.toDate();
      DateTime now = DateTime.now();

      if (now.difference(storyTime).inHours < 24) {
        stories.add(doc);
      }
    }

    return stories;
  }

  /// Builds each story Item(with Instagram like gradient for active stories)
  Widget _buildStoryItem(String profilePicture, String username,
      {bool hasStory = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            decoration: hasStory
                ? const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.pink,
                        Colors.yellow,
                        Colors.red,
                        Colors.purple
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ))
                : const BoxDecoration(shape: BoxShape.circle),
            padding: hasStory ? const EdgeInsets.all(2.0) : null,
            child: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(profilePicture),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            username,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
