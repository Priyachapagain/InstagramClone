import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_social_media_clone/profile/profile_actions.dart';
import 'package:instagram_social_media_clone/profile/profile_shimmer_screen.dart';

import '../auth/login_page.dart';
import '../chat/chat_service.dart';
import 'edit_profile_screen.dart';
import 'firebase_service.dart';
import 'follower_following_list.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  final String currentUserId;
  const ProfileScreen({super.key, this.userId, required this.currentUserId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  final ChatService _chatService = ChatService();
  final ProfileActions _profileActions = ProfileActions();

  late Future<DocumentSnapshot> userProfileFuture;
  bool isFollowing = false;
  int followers = 0;
  int followings = 0;

  @override
  void initState() {
    super.initState();
    userProfileFuture = _fetchUserProfile();
  }

  Future<DocumentSnapshot> _fetchUserProfile() async {
    String uid = widget.userId ?? _auth.currentUser!.uid;
    DocumentSnapshot userProfile = await _firebaseService.fetchUserProfile(uid);

    if (widget.userId != null) {
      bool followingStatus = await _firebaseService.isFollowingUser(
        _auth.currentUser!.uid,
        widget.userId!,
      );
      setState(() {
        isFollowing = followingStatus;
      });
    }

    setState(() {
      followers = (userProfile['followers'] as List<dynamic>).length;
      followings = (userProfile['following'] as List<dynamic>).length;
    });
    return userProfile;
  }

  Future<void> _navigateToChat() async {
    if (widget.userId == null) return;
    await _chatService.navigateToChat(
        context: context,
        currentUserId: widget.currentUserId,
        otherUserId: widget.userId!);
  }

  Future<void> _signOut() async {
    await _firebaseService.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  Future<void> _toggleFollow() async {
    await _profileActions.toggleFollowUser(
        currentUserId: widget.currentUserId, otherUserId: widget.userId!);
    setState(() {
      isFollowing = !isFollowing;
      userProfileFuture = _fetchUserProfile();
    });
  }

  Future<void> _confirmSignOut() async {
    bool? signOutConfirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Sign Out'),
              content: const Text('Are you sure you want to sign out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Sign Out'))
              ],
            ));
    if (signOutConfirmed == true) {
      _signOut();
    }
  }

  Widget buildColumn(int count, String label, bool isFollowers) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FollowerFollowingScreen(
                    userId: widget.userId ?? _auth.currentUser!.uid,
                    isFollowers: isFollowers)));
      },
      child: Column(
        children: [
          Text(
            "$count",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "User Profile",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          if (widget.userId != null && widget.userId != _auth.currentUser!.uid)
            IconButton(
                onPressed: _navigateToChat,
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                )),
          PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onSelected: (String result) {
                if (result == 'Sign Out') {
                  _confirmSignOut();
                }
              },
              itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Sign Out',
                      child: Text('Sign Out'),
                    )
                  ])
        ],
      ),
      body: FutureBuilder(
          future: userProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ShimmerProfileScreen();
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text('User profile not found'),
              );
            }
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            var username = userData['username'] ?? 'Unknown';
            var imageUrl = userData['profilePictureUrl'] ?? '';
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                            radius: 46,
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : const AssetImage(
                                    'assets/default_avatar.png')),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Text(
                            username,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        )
                      ],
                    ),
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildColumn(followings, 'Following', false),
                        buildColumn(followers, 'Followers', true)
                      ],
                    ))
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                      child: widget.userId == null ||
                              widget.userId == widget.currentUserId
                          ? TextButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditProfileScreen(
                                            username: username,
                                            imageUrl: imageUrl)));
                                if (result != null && mounted) {
                                  setState(() {
                                    username = result['username'];
                                    imageUrl = result['imageUrl'];
                                  });
                                }
                              },
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ))
                          : TextButton(
                              onPressed: _toggleFollow,
                              child: Text(
                                isFollowing ? 'Unfollow' : 'Follow',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ))),
                )
              ],
            );
          }),
    );
  }
}
