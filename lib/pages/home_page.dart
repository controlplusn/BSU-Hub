import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:animate_do/animate_do.dart';

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

      body:
      //for user info
      _user != null ? _userInfo() :
      //for front page
      Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.red.shade900,
                Colors.black,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 80),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    FadeInUp(
                      duration: Duration(milliseconds: 1000),
                      child: Text(
                        "BSU HUB",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              SizedBox(height: 250),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 30),
                        FadeInUp(
                          duration: Duration(milliseconds: 1400),
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        SizedBox(height: 100),
                        FadeInUp(
                          duration: Duration(milliseconds: 1400),
                          child: _googleSignInButton(), // Directly using the button here
                        ),
                        SizedBox(height: 50),
                        _user != null ? _userInfo() : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )

    );
  }

  Widget _googleSignInButton() {
    return Center(
      child: SizedBox(
        height: 50,
        child: SignInButton(
          Buttons.google,
          text: "Sign in to Google",
          onPressed: _handleGoogleSignIn,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded edges
          ),
          padding: EdgeInsets.all(10), // Internal button padding
        ),
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
