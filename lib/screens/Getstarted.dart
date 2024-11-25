import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:bhub/screens/authenticate/LogIn.dart';  // Ensure this is the correct import path

class GetStarted extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.red.shade900,
              Colors.red.shade900,
              Colors.red.shade900,
              Colors.red.shade900,
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
                  SizedBox(height: 500),
                ],
              ),
            ),
            FadeInUp(
              duration: Duration(milliseconds: 1600),
              child: MaterialButton(
                onPressed: () {
                  // When the button is pressed, navigate to the SignUp page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LogIn()), // Navigate to SignUp screen
                  );
                },
                height: 70,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    "GET STARTED",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
