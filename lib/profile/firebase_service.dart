import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ///Fetch user profile data from firestore
  Future<DocumentSnapshot> fetchUserProfile(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  /// Check if the current user is following another user
  Future<bool> isFollowingUser(String currentUserId, String otherUserId) async {
    DocumentSnapshot userProfile =
        await _firestore.collection('users').doc(currentUserId).get();
    List<String> followings = List<String>.from(userProfile['following']);
    return followings.contains(otherUserId);
  }

  /// sign out user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
