import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:instagram_social_media_clone/provider/post_like_provider.dart';
import 'package:instagram_social_media_clone/reel/reel_screen/reel_like_provider.dart';
import 'package:provider/provider.dart';

import 'auth/login_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LikeProvider()),
          ChangeNotifierProvider(create: (_) => ReelLikeProvider()), // Make sure LikeProvider is correctly imported

        ],
        child: const MyApp(),
      )

  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
