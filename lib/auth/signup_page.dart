import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'auth_service.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();

}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  XFile? _imageFile;
  bool _isLoading = false;

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if(pickedFile != null){
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  void _signUp(BuildContext context) async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if(email.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authService = AuthService();

    try{
      final user = await authService.signUpWithEmailAndPassword(email, password, context);

      if(user != null){
        String? profilePictureUrl;

        if(_imageFile != null) {
          profilePictureUrl = await authService.uploadProfilePicture(user.uid, _imageFile!.path);
        }

        await authService.saveUserData(
            user.uid,
            user.email!,
          username,
          profilePictureUrl: profilePictureUrl
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign up successful!'),
          backgroundColor: Colors.green,));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));


      }
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally{
      setState(() {
        _isLoading = false;
      });
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
                  const SizedBox(height: 15,),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _imageFile != null
                        ? FileImage(File(_imageFile!.path))
                          : null,
                      child: _imageFile == null
                        ? Icon(Icons.camera_alt, color: Colors.grey[800],)
                          : null,

                    ),
                  ),
                  const SizedBox(height: 15,),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      )
                    ),
                  ),
                  const SizedBox(height: 10,),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Username',
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)
                      )
                    ),
                  ),
                  const SizedBox(height: 15,),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Password',
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10)
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
                    onPressed: _isLoading ? null : () => _signUp(context),
                    child: _isLoading
                    ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    )
                  ),
                  const SizedBox(height: 20,),
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey,)
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10
                        ),
                        child: Text('OR', style: TextStyle(color: Colors.grey),),
                      ),
                      Expanded(child: Divider(color: Colors.grey,))
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?',
                        style: TextStyle(fontSize: 16),

                      ),
                      SizedBox(width: 4,),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen())
                          );
                        },
                        child: const Text(
                          'Log in.',
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