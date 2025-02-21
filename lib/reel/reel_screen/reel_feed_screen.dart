import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_social_media_clone/reel/reel_screen/reel_feed_list.dart';

class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: VideoFeedList(pageController: _pageController,
          firestore: _firestore),
    );
  }

  AppBar _buildAppBar(){
    return AppBar(
      title: const Text('Reels',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      centerTitle: true,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }
}
