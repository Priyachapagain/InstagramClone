import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  final String username;
  final String imageUrl;
  const EditProfileScreen(
      {super.key, required this.username, required this.imageUrl});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _updatedUsername;
  File? _pickedImageFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _updatedUsername = widget.username;
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImageFile = File(pickedFile.path);
      });
    }
  }

  // update user profile
  Future<void> _updateProfile() async {
    setState(() {
      isLoading = true;
    });

    String uid = _auth.currentUser!.uid;
    String? imageUrl = widget.imageUrl;

    // If user selects a new image, upload it to Firebase Storage
    if (_pickedImageFile != null) {
      final storageRef =
          FirebaseStorage.instance.ref().child('user_profiles/$uid.jpg');
      await storageRef.putFile(_pickedImageFile!);
      imageUrl = await storageRef.getDownloadURL();
    }

    //Update Firestore user document
    await _firestore.collection('users').doc(uid).update({
      'username': _updatedUsername,
      'profilePictureUrl': imageUrl,
    }).then((_) {
      Navigator.pop(
          context, {'username': _updatedUsername, 'imageUrl': imageUrl});
    }).catchError((error) {
      print("Error updating profile: $error");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error updating profile.Please try again.")));
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
            const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: _pickedImageFile != null
                  ? FileImage(_pickedImageFile!)
                  : NetworkImage(widget.imageUrl) as ImageProvider,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextButton(
              onPressed: _pickImage,
              child: const Text(
                "Change Profile Picture",
                style: TextStyle(color: Colors.blue),
              )),
          const SizedBox(
            height: 20,
          ),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                labelText: "Username",
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                )),
            onChanged: (value) {
              _updatedUsername = value;
            },
            controller: TextEditingController(text: widget.username),
          ),
          const SizedBox(
            height: 20,
          ),
          isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ))
        ]),
      ),
    );
  }
}
