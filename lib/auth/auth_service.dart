import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_social_media_clone/auth/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Sign up with email and password
  Future<User?> signUpWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
      return null;
    }
  }

// Save user data
  Future<void> saveUserData(String uid, String email, String username,
      {String? profilePictureUrl}) async {
    try {
      final userData = UserModel(
        uid: uid,
        email: email,
        username: username,
        profilePictureUrl: profilePictureUrl,
        followers: [],
        following: [],
      );

      await _firestore.collection('users').doc(uid).set(userData.toMap());
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

//Upload profile picture to Firebase Storage
  Future<String?> uploadProfilePicture(String uid, String filePath) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$uid.jpg');

      await storageRef.putFile(File(filePath));
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }
}
