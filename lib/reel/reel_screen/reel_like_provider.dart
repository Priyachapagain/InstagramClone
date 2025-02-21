import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReelLikeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> toggleLike(
      String postId, List<dynamic> likes, String userId) async {
    try {
      DocumentReference postRef = _firestore.collection('Reel').doc(postId);
      if (likes.contains(userId)) {
        await postRef.update({
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([userId])
        });
      }
      notifyListeners();
    } catch (error) {
      print("Error liking post: $error");
    }
  }
}
