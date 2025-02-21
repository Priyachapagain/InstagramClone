import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FollowerFollowingScreen extends StatefulWidget {
  final String userId;
  final bool isFollowers;
  const FollowerFollowingScreen(
      {super.key, required this.userId, required this.isFollowers});

  @override
  State<FollowerFollowingScreen> createState() =>
      _FollowerFollowingScreenState();
}

class _FollowerFollowingScreenState extends State<FollowerFollowingScreen> {
  late Future<List<Map<String, dynamic>>> usersListFuture;

  @override
  void initState() {
    super.initState();
    usersListFuture = _fetchUsers();
  }

  /// Fetch followers or following list from Firestore
  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    String field = widget.isFollowers ? 'followers' : 'following';

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    List<String> userIds = List<String>.from(userDoc[field] ?? []);

    List<Map<String, dynamic>> usersList = [];

    for (String uid in userIds) {
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
        userSnapshot.data() as Map<String, dynamic>;
        usersList.add({
          'username': userData['username'] ?? 'Unknown',
          'profilePictureUrl': userData['profilePictureUrl'] ??
              'https://via.placeholder.com/150', // Default image if null
        });
      }
    }
    return usersList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.isFollowers ? "Followers" : "Following",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: usersListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text(
                  "No data found",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            List<Map<String, dynamic>> users = snapshot.data!;

            if (users.isEmpty) {
              return Center(
                child: Text(
                  widget.isFollowers
                      ? "No followers yet."
                      : "Not following anyone yet.",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  var user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['profilePictureUrl']),
                    ),
                    title: Text(
                      user['username'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                });
          }),
    );
  }
}
