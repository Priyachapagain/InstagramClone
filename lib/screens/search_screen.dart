import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../profile/profile_screen.dart';


class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  SearchUserScreenState createState() => SearchUserScreenState();
}

class SearchUserScreenState extends State<SearchUserScreen> {
  final String currentId = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchUsers() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      String searchText = _searchController.text.trim();
      QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: searchText)
          .where('username', isLessThanOrEqualTo: searchText + '\uf8ff')
          .get();

      setState(() {
        _searchResults = querySnapshot.docs;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while searching: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: const BackButton(
            color: Colors.white,
          ),
          title: TextField(
            style: TextStyle(color: Colors.white),
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search users...',
              hintStyle: TextStyle(
                  fontFamily: 'Poppins', fontSize: 16, color: Colors.white),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              _searchUsers();
            },
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(_errorMessage),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      var userData =
                          _searchResults[index].data() as Map<String, dynamic>;
                      String userId = _searchResults[index].id;
                      String username = userData['username'] ?? 'unknown';
                      String imageUrl = userData['profilePictureUrl'] ?? '';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null,
                          child: imageUrl.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          username,
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                userId: userId,
                                currentUserId: currentId,
                              ),
                            ),
                          );


                          //Navigation to profile screen
                        },
                      );
                    }));
  }
}
