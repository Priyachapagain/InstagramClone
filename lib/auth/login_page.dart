import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_social_media_clone/auth/signup_page.dart';

import '../screens/main_page.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if(email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter both email and password')));
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if(userCredential.user != null) {
        setState(() {
          _isLoading = false;
        });

        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
            const MainPage(),
            )
        );

        ScaffoldMessenger.of(context).showSnackBar(const
            SnackBar(content: Text('Login Successful!'),
          backgroundColor: Colors.green,


        )
        );

      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
        'Sign in failed: ${e.message}'
      ),
        backgroundColor: Colors.red,
      ));
    } catch(e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'),));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFFfeda75),
                    Color(0xFFfa7e1e),
                    Color(0xFFd62976),
                    Color(0xFF962fbf),
                    Color(0xFF4f5bd5)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
              )
          ),
        child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/Images/insta_logo.png',
                  height: 120,
                ),
                const SizedBox(height: 10,),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Username or Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      )
                  ),
                ),
                const SizedBox(height: 15,),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      )
                  ),
                ),
                const SizedBox(height: 15,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                  ),
                  onPressed: () => _login(context),
                  child: _isLoading
                  ?const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                      strokeWidth: 2,
                    ),
                  )

                      : const Text(
                    'Log In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  )

                ),
                const SizedBox(height: 10,),
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey,)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('OR', style: TextStyle(color: Colors.grey),),
                    ),
                    Expanded(child: Divider(color: Colors.grey,),)
                  ],
                ),
                const SizedBox(height: 10,),
                TextButton(
                  onPressed: (){
                    /*Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                        const ForgotPasswordPage(),
                        )
                    );*/
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 18,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30,),
                const Divider(color: Colors.grey,),
                const SizedBox(height: 10,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?", style: TextStyle(fontSize: 16),

                    ),
                    SizedBox(width: 4,),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                            MaterialPageRoute(builder: (context) => const SignUpPage())
                        );
                      },
                      child: const Text(
                        'Sign up.',
                        style: TextStyle(
                          fontSize: 18,
                            color: Colors.white),
                      ),
                    )
                  ],
                )

              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}