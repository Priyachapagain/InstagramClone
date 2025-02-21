import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';

class FullStoryView extends StatefulWidget {
  final List<DocumentSnapshot> stories;
  final int initialIndex;

  const FullStoryView(
      {super.key, required this.stories, required this.initialIndex});

  @override
  State<FullStoryView> createState() => _FullStoryViewState();
}

class _FullStoryViewState extends State<FullStoryView> {
  late PageController _pageController;
  int _currentIndex = 0;
  VideoPlayerController? _videoController;
  bool _isVideo = false;
  bool _isLoading = true;
  String _username = "Unknown";
  String _profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
    _loadStory();
  }

  //Load Story & Fetch User Data
  Future<void> _loadStory() async {
    final story = widget.stories[_currentIndex].data() as Map<String, dynamic>;
    String mediaUrl = story['mediaUrl'];

    //Fetch user details using userId
    _fetchUserData(story['userId']);

    // Get media type dynamically from Firebase Storage metadata
    _checkMediaType(mediaUrl);
  }

  // Determine whether the media is a video or image
  Future<void> _checkMediaType(String url) async {
    setState(() {
      _isLoading = true;
    });

    try {
      Uri uri = Uri.parse(url);
      String path = uri.pathSegments.last.split('?').first;
      // Fetch metadata
      FullMetadata metadata =
          await FirebaseStorage.instance.ref(path).getMetadata();

      String contentType = metadata.contentType ?? '';

      if (contentType.startsWith('video/')) {
        _isVideo = true;
        _videoController?.dispose();
        _videoController = VideoPlayerController.network(url)
          ..initialize().then((_) {
            setState(() {
              _isLoading = false;
              _videoController?.play();
            });
          });
      } else {
        _isVideo = false;
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error checking media type: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch username & profile image
  Future<void> _fetchUserData(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _username = userData['username'] ?? 'Unknown';
          _profileImageUrl = userData['profilePictureUrl'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
        _isLoading = true;
      });

      // Ensure PageController is attached before calling nextPage()
      if (_pageController.hasClients) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }

      _loadStory();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isLoading = true;
      });

      // Ensure PageController is attached before calling previousPage()
      if (_pageController.hasClients) {
        _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
      _loadStory();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex].data() as Map<String, dynamic>;
    return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTapUp: (details) {
            if (details.globalPosition.dx <
                MediaQuery.of(context).size.width / 3) {
              _previousStory();
            } else {
              _nextStory();
            }
          },
          child: Stack(
            children: [
              //Story Content(Image/Video)
              Positioned.fill(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                          color: Colors.white,
                        ))
                      : _isVideo
                          ? VideoPlayer(_videoController!)
                          : Image.network(story['mediaUrl'],
                              fit: BoxFit.cover)),
              // Gradient Overlay (For Better Visibilty of UI Elements)

              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [
                    Colors.black54,
                    Colors.transparent,
                    Colors.black26
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                ),
              ),
              //Story Progress Indicators
              Positioned(
                top: 40,
                left: 10,
                right: 10,
                child: Row(
                    children: List.generate(widget.stories.length, (index) {
                  return Expanded(
                      child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 4,
                    decoration: BoxDecoration(
                        color: index <= _currentIndex
                            ? Colors.white
                            : Colors.white54,
                        borderRadius: BorderRadius.circular(5)),
                  ));
                })),
              ),

              //User Info(Avatar and Username)
              Positioned(
                top: 50,
                left: 15,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(_profileImageUrl),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      _username,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              //CloseButton
              Positioned(
                top: 50,
                right: 20,
                child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    )),
              )
            ],
          ),
        ));
  }
}
