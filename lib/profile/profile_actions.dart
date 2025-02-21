import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileActions {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ///Toggle Follow/Unfollow User
  Future<void> toggleFollowUser(
      {required String currentUserId, required String otherUserId}) async {
    DocumentReference currentUserRef =
        _firestore.collection('users').doc(currentUserId);

    DocumentReference otherUserRef =
        _firestore.collection('users').doc(otherUserId);

    DocumentSnapshot currentUserSnapshot = await currentUserRef.get();
    List<dynamic> followingList = currentUserSnapshot['following'];

    if (followingList.contains(otherUserId)) {
      await currentUserRef.update({
        'following': FieldValue.arrayRemove([otherUserId])
      });
      await otherUserRef.update({
        'followers': FieldValue.arrayRemove([currentUserId])
      });
    } else {
      await currentUserRef.update({
        'following': FieldValue.arrayUnion([otherUserId])
      });
      await otherUserRef.update({
        'followers': FieldValue.arrayUnion([currentUserId])
      });
    }
  }
}
