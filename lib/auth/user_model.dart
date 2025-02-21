class UserModel {
  final String uid;
  final String email;
  final String username;
  final String? profilePictureUrl;
  final List<String> followers;
  final List<String> following;

  UserModel(
      {required this.uid,
      required this.email,
      required this.username,
      this.profilePictureUrl,
      this.followers = const [],
      this.following = const []});

  //You can convert the model into a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'profilePictureUrl': profilePictureUrl,
      'followers': followers,
      'following': following
    };
  }

}
