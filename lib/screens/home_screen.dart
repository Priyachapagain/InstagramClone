import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../chat/chat_list_screen.dart';
import '../post_screen/post_section.dart';
import '../post_screen/story_section.dart';


class PostAndStoryPage extends StatelessWidget {
  const PostAndStoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/Images/insta_logo.png',
          height: 100,
          fit: BoxFit.contain,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border,
                color: Colors.white, size: 26),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              final currentUser =
                  FirebaseAuth.instance.currentUser;
              if (currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatListScreen(currentUserId: currentUser.uid),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Image.asset(
                'assets/Images/chatinsta.png',
                height: 23,
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: const SafeArea(
        child: Column(
          children: [
            // STORY SECTION
            StorySection(),
            Divider(color: Colors.grey),
            // POST SECTION (Wrapped in Expanded to avoid overflow)
            Expanded(child: PostSection()),
          ],
        ),
      ),
    );
  }
}
