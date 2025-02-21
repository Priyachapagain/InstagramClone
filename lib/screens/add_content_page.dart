import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddInstagramContentPage extends StatefulWidget {
  const AddInstagramContentPage({super.key});

  @override
  State<AddInstagramContentPage> createState() =>
      _AddInstagramContentPageState();
}

class _AddInstagramContentPageState extends State<AddInstagramContentPage> {
  final TextEditingController _captionController = TextEditingController();
  File? _selectedFile;
  VideoPlayerController? _videoPlayerController;

  int _currentIndex = 0;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isVideo = false;
  final List<String> _types = ['Post', 'Story', 'Reel'];

  //Pick image or video based on type

  Future<void> _pickMedia() async {
    XFile? pickedFile;

    if (_types[_currentIndex] == 'Reel') {
      pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    } else if (_types[_currentIndex] == 'Story') {
      pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
      pickedFile ??= await _picker.pickImage(source: ImageSource.gallery);
    } else {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    }

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _selectedFile = file;
        _isVideo = pickedFile!.path.endsWith('.mp4') ||
            pickedFile!.path.endsWith('.mov');
      });

      //PLay video preview if selected
      if (_isVideo) {
        _videoPlayerController = VideoPlayerController.file(file)
          ..initialize().then((_) {
            setState(() {});
            _videoPlayerController!.play();
          });
      }
    }
  }

  //Reset selected file
  void _resetSelection() {
    setState(() {
      _selectedFile = null;
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
    });
  }

  //upload media to Firebase storage and save details to Firestore
  Future<void> _uploadContent() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not logged in");
      }

      final storagePath =
          '${_types[_currentIndex]}/${DateTime.now().millisecondsSinceEpoch}';

      //Upload to Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      await ref.putFile(_selectedFile!);

      //Get download URL
      final downloadUrl = await ref.getDownloadURL();
      String postId = const Uuid().v1();

      //Save to Firestore
      final collection = _types[_currentIndex]; // 'post, story, or reel'
      await FirebaseFirestore.instance.collection(collection).doc(postId).set({
        'postId': postId,
        'userId': userId,
        'mediaUrl': downloadUrl,
        'caption': _captionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [],
      });
      setState(() {
        _selectedFile = null;
        _captionController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${_types[_currentIndex]} uploaded successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          _types[_currentIndex],
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                _selectedFile != null
                    ? (_isVideo)
                        ? (_videoPlayerController != null &&
                                _videoPlayerController!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio:
                                    _videoPlayerController!.value.aspectRatio,
                                child: VideoPlayer(_videoPlayerController!),
                              )
                            : const Center(
                                child: CircularProgressIndicator(),
                              ))
                        : Center(
                            child: Image.file(
                              _selectedFile!,
                              height: 400,
                              fit: BoxFit.cover,
                            ),
                          )
                    : GestureDetector(
                        onTap: _pickMedia,
                        child: Container(
                          height: 400,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                                width: 2,
                              )),
                          child: const Center(
                            child: Text(
                              'Tap to select media',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                const SizedBox(
                  height: 20,
                ),
                //Caption input(only for Post and Reel)
                if (_types[_currentIndex] != 'Story')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _captionController,
                      decoration: const InputDecoration(
                          hintText: 'Write a caption...',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white))),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                //Upload button

                ElevatedButton(
                  onPressed: _isUploading ? null : _uploadContent,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[900],
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 60)),
                  child: Text(
                    _isUploading
                        ? 'Uploading....'
                        : 'Upload ${_types[_currentIndex]}',
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ))
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                    _resetSelection();
                  });
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.grey,
                items: const [
                  BottomNavigationBarItem(
                    label: 'Post',
                    icon: SizedBox.shrink(),
                  ),
                  BottomNavigationBarItem(
                    label: 'Story',
                    icon: SizedBox.shrink(),
                  ),
                  BottomNavigationBarItem(
                    label: 'Reel',
                    icon: SizedBox.shrink(),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
