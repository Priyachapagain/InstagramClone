import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LikeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> toggleLike(String postId, List<dynamic> likes, String userId) async {
    bool isLiked = likes.contains(userId);

    if(isLiked){
      likes.remove(userId);
      await _firestore.collection('Post').doc(postId).update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } else {
      likes.add(userId);
      await _firestore.collection('Post').doc(postId).update({
        'likes': FieldValue.arrayUnion([userId])
      });

    }
    notifyListeners();
  }

}