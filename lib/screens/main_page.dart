import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_social_media_clone/screens/search_screen.dart';

import '../profile/profile_screen.dart';
import '../profile/profile_shimmer_screen.dart';
import '../reel/reel_screen/reel_feed_screen.dart';
import 'add_content_page.dart';
import 'home_screen.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  String? currentUserId;
  String? profileImageUrl;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      _fetchProfileImageFromFirestore(user.uid);
    }
  }

  Future<void> _fetchProfileImageFromFirestore(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        setState(() {
          profileImageUrl = doc.data()?['profilePictureUrl'];
        });
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error fetching profile image from Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const PostAndStoryPage(),
      const SearchUserScreen(),
      const AddInstagramContentPage(),
      const VideoFeedScreen(),

      if (currentUserId != null)
        ProfileScreen(
          userId: currentUserId!,
          currentUserId: currentUserId!,
        )
      else
        const Center(
          child: ShimmerProfileScreen(),
        ),

    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[300],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
          _pageController.jumpToPage(index);
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              size: 28,
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 28,
            ),
            label: 'Search',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle_outline,
              size: 28,
            ),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/Images/reels.png',
              color: Colors.white,
              width: 27,
            ),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: profileImageUrl != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(profileImageUrl!),
                    radius: 18,
                  )
                : const Icon(
                    Icons.person,
                    size: 28,
                  ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
