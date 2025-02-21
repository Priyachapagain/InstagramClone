import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'follow_unfollow_service.dart';

class UserProfileService {
  static final Map<String, ValueNotifier<bool>> _isFollowingMap = {};

  static ValueNotifier<bool> getFollowStatus(String userId) {
    if (!_isFollowingMap.containsKey(userId)) {
      _isFollowingMap[userId] = ValueNotifier(false);
      _checkIfFollowing(userId);
    }
    return _isFollowingMap[userId]!;
  }

  static Future<void> _checkIfFollowing(String userId) async {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    var isFollowing =
        (userDoc.data()?['followers'] ?? []).contains(currentUserUid);
    _isFollowingMap[userId]?.value = isFollowing;
  }

  static Widget buildUserInfo(String userId, String description) {
    return Positioned(
        bottom: 20,
        left: 10,
        child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();

              var userProfile =
                  snapshot.data!.data() as Map<String, dynamic> ?? {};
              var profileImageUrl = userProfile['profilePictureUrl'] ?? '';
              var username = userProfile['username'] ?? 'User';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(profileImageUrl),
                        radius: 20,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        username,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      ValueListenableBuilder<bool>(
                          valueListenable: getFollowStatus(userId),
                          builder: (context, isFollowing, child) {
                            return GestureDetector(
                              onTap: () =>
                                  FollowUnfollowService.followUnfollowUser(
                                          userId)
                                      .then((_) => _checkIfFollowing(userId)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isFollowing ? 'Following' : 'Follow',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            );
                          })
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              );
            }));
  }
}
