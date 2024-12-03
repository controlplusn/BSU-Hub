import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text("Admin dashboard"),
      backgroundColor: Colors.red,
      ),
      body: Center(
        child: Text(
          "Welcome to the Admin Dashboard!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
