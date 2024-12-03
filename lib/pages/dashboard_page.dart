import 'package:flutter/material.dart';
import 'package:google_sign_up/pages/eventAdmin_page.dart';
import 'package:google_sign_up/pages/home_page.dart';
import './Announcements_page.dart';
import './dashboard_page.dart';
import './feedback_page.dart';
import './events_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // Mock user data (replace with real authentication logic)
  // final _user = User(
  //   email: "user@example.com",
  //   displayName: "John Doe",
  //   photoURL: "https://example.com/photo.jpg", // Replace with a valid URL if necessary
  // );

  // Variable to track the notification icon state (active or inactive)
  bool _isNotificationActive = false;

  // Variable to control the notification drawer visibility
  bool _isNotificationDrawerOpen = false;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _signOutAndShowAlert() {
    // Add sign-out logic here
    print("User signed out");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signed out")));
  }

  void _toggleNotification() {
    setState(() {
      _isNotificationActive = !_isNotificationActive;
      // Toggle the visibility of the notification drawer when the icon is tapped
      _isNotificationDrawerOpen = !_isNotificationDrawerOpen;
    });
    print("Notification icon tapped. Active state: $_isNotificationActive");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 50, // Adjust the height of the AppBar
            floating: false,
            pinned: true,
            backgroundColor: Colors.red, // Set the background color of the AppBar
            title: Row(
              children: [
                Text(
                  widget.title,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isNotificationActive ? Icons.notifications_active : Icons.notifications,
                  color: Colors.white,
                ),
                onPressed: _toggleNotification, // Toggle the notification state on tap
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Image below the app bar
                Image.asset(
                  'assets/8.jpg', // Replace with your actual image URL
                  width: double.infinity,
                  height: 200, // Adjust height of the image
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20), // Add some space below the image

                // Text below the image aligned to the left
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Fri, November 22, 2024',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 20),

                      // Horizontal scrollable container
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal, // Make the content scrollable horizontally
                        child: Row(
                          children: List.generate(
                            3, // Number of items in the horizontal scrollable container
                                (index) => Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 300, // Set the width of each container
                              height: 200, // Set the height of each container
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black, // Border color for the top side
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(10), // Rounded corners
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start, // Align all content to the start
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'February 14, 2025',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        'AREA 143',
                                        style: TextStyle(fontSize: 30),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Upcoming Event.',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Add a SizedBox for vertical space before the Divider
                      const SizedBox(height: 20),

                      // Add a horizontal line (Divider) after the container
                      const Divider(
                        color: Colors.grey, // Line color
                        thickness: 1, // Line thickness
                      ),

                      // Add the small container below the Divider
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 0),
                        width: double.infinity,
                        height: 30, // Small container height
                        color: Colors.red, // Container color
                        child: Center(
                          child: Text(
                            'LATEST ANNOUNCEMENTS',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),

                      // Row to align two containers at the bottom
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns the containers to the left and right
                        children: [
                          // Left container
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            width: 200, // Set the width of the left container
                            height: 200, // Height of the container
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20), // Apply border radius here
                              color: Colors.white, // Container color
                            ),
                            child: const Center(
                              child: Text(
                                '𝗦𝘂𝗽𝗽𝗼𝗿𝘁 𝗕𝗮𝘁𝗦𝘁𝗮𝘁𝗲𝗨 𝗶𝗻 𝘁𝗵𝗲 𝗠𝗜𝗗𝗔𝗦 𝗧𝗼𝗽 𝗦𝘁𝗿𝘂𝗰𝘁𝘂𝗿𝗲 𝗔𝘄𝗮𝗿𝗱𝘀',
                                style: TextStyle(color: Colors.black, fontSize: 14),
                              ),
                            ),
                          ),
                          // Right container
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            width: 200, // Set the width of the right container
                            height: 200, // Height of the container
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20), // Apply border radius here
                              color: Colors.white, // Container color
                            ),
                            child: const Center(
                              child: Text(
                                '𝗕𝗮𝘁𝗦𝘁𝗮𝘁𝗲𝗨 𝘁𝗲𝗮𝗺 𝗿𝗲𝗱𝗲𝗳𝗶𝗻𝗲𝘀 𝘁𝗵𝗲 𝗡𝗮𝘁𝗶𝗼𝗻𝗮𝗹 𝗜𝗻𝗻𝗼𝘃𝗮𝘁𝗶𝗼𝗻 𝗖𝗼𝘂𝗻𝗰𝗶𝗹’𝘀 𝘃𝗶𝘀𝘂𝗮𝗹 𝗯𝗿𝗮𝗻𝗱 𝗶𝗱𝗲𝗻𝗧𝗶𝘁𝘆 𝘄𝗶𝘁𝗵 𝗮 𝗽𝗿𝗼𝗨𝗱𝗟𝗬 𝗳𝗶𝗹𝗜𝗽𝗶𝗻𝗢 𝗩𝗶𝗦𝗜𝗢𝗡',
                                style: TextStyle(color: Colors.black, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Combined drawer for both navigation and notifications
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Text("Hello world"),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyHomePage(title: "Dashboard")
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Announcement'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AnnouncementsPage()
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Feedback'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FeedbackPage()
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Events'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminEvent(title: "Event Title")
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Sign Out'),
              onTap: _signOutAndShowAlert, // Sign out logic here
            ),
          ],
        ),
      ),
    );
  }

  // Widget _userInfo() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       CircleAvatar(
  //         backgroundImage: NetworkImage(_user.photoURL ?? ''),
  //         radius: 40,
  //       ),
  //       const SizedBox(height: 10),
  //       Text(_user.displayName ?? ''),
  //       const SizedBox(height: 5),
  //       Text(_user.email ?? ''),
  //     ],
  //   );
  // }
}

// Mock user class for demonstration
// class User {
//   final String email;
//   final String displayName;
//   final String photoURL;
//
//   User({required this.email, required this.displayName, required this.photoURL});
// }