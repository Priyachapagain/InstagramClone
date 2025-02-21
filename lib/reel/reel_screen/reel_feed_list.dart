import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chewie/chewie.dart';
import 'package:instagram_social_media_clone/reel/reel_screen/profile_service.dart';
import 'package:instagram_social_media_clone/reel/reel_screen/reel_controller.dart';
import 'package:instagram_social_media_clone/reel/reel_screen/reel_like_provider.dart';

import 'package:provider/provider.dart';

import '../../comment/comment_screen.dart';

class VideoFeedList extends StatefulWidget {
  final PageController pageController;
  final FirebaseFirestore firestore;
  const VideoFeedList(
      {super.key, required this.pageController, required this.firestore});

  @override
  State<VideoFeedList> createState() => _VideoFeedListState();
}

class _VideoFeedListState extends State<VideoFeedList> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool showHeartAnimation = false;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.firestore
            .collection('Reel')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return const Center(
              child: CircularProgressIndicator(),
            );

          var videoDocs = snapshot.data!.docs;
          return PageView.builder(
              controller: widget.pageController,
              scrollDirection: Axis.vertical,
              itemCount: videoDocs.length,
              itemBuilder: (context, index) {
                var videoDoc = videoDocs[index];
                var videoUrl = videoDoc['mediaUrl'];
                var userId = videoDoc['userId'];
                var description = videoDoc['caption'] ?? '';
                var reelId = videoDoc.id;
                List<dynamic> likesList = videoDoc['likes'] ?? [];
                return FutureBuilder<ChewieController>(
                    future: VideoControllerService.initializeChewieController(
                        videoUrl),
                    builder: (context, chewieSnapshot) {
                      if (!chewieSnapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Stack(
                        children: [
                          GestureDetector(
                            onDoubleTap: () {
                              if (currentUser != null &&
                                  !likesList.contains(currentUser!.uid)) {
                                Provider.of<ReelLikeProvider>(context,
                                        listen: false)
                                    .toggleLike(
                                        reelId, likesList, currentUser!.uid);
                                setState(() => showHeartAnimation = true);
                                Future.delayed(
                                    const Duration(milliseconds: 800),
                                    () => setState(
                                        () => showHeartAnimation = false));
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                  child: Chewie(
                                    controller: chewieSnapshot.data!,
                                  ),
                                ),
                                if (showHeartAnimation)
                                  const Icon(
                                    Icons.favorite,
                                    size: 100,
                                    color: Colors.red,
                                  )
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 80,
                            right: 10,
                            child: Column(
                              children: [
                                Consumer<ReelLikeProvider>(
                                  builder: (context, provider, child) {
                                    bool isLiked = currentUser != null &&
                                        likesList.contains(currentUser!.uid);
                                    return Column(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              if (currentUser != null) {
                                                provider.toggleLike(
                                                    reelId,
                                                    likesList,
                                                    currentUser!.uid);
                                              }
                                            },
                                            icon: Icon(
                                              isLiked
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isLiked
                                                  ? Colors.red
                                                  : Colors.white,
                                              size: 30,
                                            )),
                                        Text(
                                          '${likesList.length}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        )
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CommentScreen(postId: reelId)));
                                  },
                                  child: Image.asset(
                                    'assets/Images/comment.png',
                                    color: Colors.white,
                                    width: 25,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: UserProfileService.buildUserInfo(
                                userId, description),
                          )
                        ],
                      );
                    });
              });
        });
  }
}
