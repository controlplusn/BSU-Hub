import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:google_sign_up/models/events.dart';
import 'package:google_sign_up/pages/admin_dashboard_page.dart';
import 'package:google_sign_up/pages/user_dashboard_page.dart';
import 'package:google_sign_up/services/database_services.dart';
import 'package:intl/intl.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:animate_do/animate_do.dart';
import 'Announcements_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  auth.User? _user;

  // admin email
  final String adminEmail = "22-06230@g.batstate-u.edu.ph";

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });

      // After the user is signed in, check the email domain
      if (_user != null) {
        if (!_user!.email!.contains('g.batstate-u.edu.ph')) {
          _signOutAndShowAlert(); // logout if email domain is invalid
        } else {
          // redirect to dashboard
          _redirectUser();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _user != null
          ? const Center(child: CircularProgressIndicator(),) // loading
          : _frontpage(),
    );
  }

  Widget _frontpage() {
    return Container(
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
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 250),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 30),
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
                    const SizedBox(height: 100),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1400),
                      child: _googleSignInButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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

  void _handleGoogleSignIn() async {
    try {
      auth.GoogleAuthProvider _googleAuthProvider = auth.GoogleAuthProvider();
      await _auth.signInWithProvider(_googleAuthProvider);

      if (_user != null && !_user!.email!.contains('@g.batstate-u.edu.ph')) {
        _signOutAndShowAlert();
      }
    } catch (error) {
      print("Google sign-in failed: $error");
    }
  }

  void _redirectUser() {
    if (_user == null) return;

    // Navigate to Admin Dashboard if the user is an admin, else User Dashboard
    bool isAdmin = _user!.email == adminEmail;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isAdmin
            ? const AdminDashboardPage()
            : UserDashboardPage(
              title: "Dashboard",
              user: _user!,
            ),
      ),
    );
  }

  // Show alert dialog if email domain is invalid
  void _signOutAndShowAlert() async {
    await _auth.signOut();
    _showSignOutAlert();
  }

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
