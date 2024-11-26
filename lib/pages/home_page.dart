import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });

      // After the user is signed in, check the email domain
      if (_user != null && !_user!.email!.contains('@g.batstate-u.edu.ph')) {
        _signOutAndShowAlert();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google SignIn"),
      ),
      body: _user != null ? _userInfo() : _googleSignInButton(),
    );
  }

  Widget _googleSignInButton() {
    return Center(
      child: SizedBox(
        height: 50,
        child: SignInButton(Buttons.google, text: "Sign in to Google", onPressed: _handleGoogleSignIn),
      ),
    );
  }

  Widget _userInfo() {
    // Ensure _user is not null before accessing its properties
    if (_user == null) {
      return const Center(child: Text('User is not signed in.'));
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (_user!.photoURL != null)
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(_user!.photoURL!)),
              ),
            ),
          Text(_user!.email!),
          Text(_user!.displayName ?? "No display name"),
          MaterialButton(
            color: Colors.red,
            child: const Text("Sign Out"),
            onPressed: _signOutAndShowAlert,
          ),
        ],
      ),
    );
  }

  void _handleGoogleSignIn() async {
    try {
      // Trigger Google Sign-In and get credentials
      GoogleAuthProvider _googleAuthProvider = GoogleAuthProvider();
      await _auth.signInWithProvider(_googleAuthProvider);

      // After successful sign-in, check the email domain
      if (_user != null && !_user!.email!.contains('@g.batstate-u.edu.ph')) {
        _signOutAndShowAlert();
      }
    } catch (error) {
      print("Google sign-in failed: $error");
    }
  }

  // Function to sign out and show an alert dialog
  void _signOutAndShowAlert() async {
    await _auth.signOut();
    _showSignOutAlert();
  }

  // Show alert dialog if email domain is invalid
  void _showSignOutAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign In Error'),
          content: const Text('Only BSU account/student can sign in.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
