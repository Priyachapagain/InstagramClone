import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowUnfollowService {
  static Future<void> followUnfollowUser(String followeeUid) async {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    var firestore = FirebaseFirestore.instance;
    try {
      await firestore.runTransaction((transaction) async {
        var currentUserRef = firestore.collection('users').doc(currentUserUid);
        var followeeRef = firestore.collection('users').doc(followeeUid);
        var currentUserSnapshot = await transaction.get(currentUserRef);
        var followeeSnapshot = await transaction.get(followeeRef);

        if (!currentUserSnapshot.exists || !followeeSnapshot.exists) {
          throw Exception('User data not found');
        }

        List<String> currentFollowings =
            List<String>.from(currentUserSnapshot['following'] ?? []);

        List<String> followeeFollowers =
            List<String>.from(followeeSnapshot['followers'] ?? []);

        if (currentFollowings.contains(followeeUid)) {
          currentFollowings.remove(followeeUid);
          followeeFollowers.remove(currentUserUid);
        } else {
          currentFollowings.add(followeeUid);
          followeeFollowers.add(currentUserUid);
        }

        transaction.update(currentUserRef, {'following': currentFollowings});
        transaction.update(followeeRef, {'followers': followeeFollowers});
      });
    } catch (e) {
      print('Error: $e');
    }
  }
}
