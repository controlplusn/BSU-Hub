import 'package:flutter/material.dart';
import 'package:google_sign_up/pages/Announcements_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_up/pages/home_page.dart';
import 'package:google_sign_up/pages/user_events_page.dart';
import 'package:google_sign_up/services/database_services.dart';
import 'package:intl/intl.dart';
import 'package:google_sign_up/models/events.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key, required this.title, required this.user});

  final String title;
  final auth.User user; // Authenticated user passed from HomePage

  @override
  State<UserDashboardPage> createState() => _UserDashboardPage();
}

class _UserDashboardPage extends State<UserDashboardPage> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isNotificationActive = false;
  bool _isNotificationDrawerOpen = false;
  bool _isAdmin = false; // Variable to store admin status
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // check user role
  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()?['role'] == 'admin') {
          setState(() {
            _isAdmin = true; // User is an admin
          });
        }
      }
    } catch (e) {
      print("Error checking admin status: $e");
    }
  }

  void _toggleNotification() {
    setState(() {
      _isNotificationActive = !_isNotificationActive;
      _isNotificationDrawerOpen = !_isNotificationDrawerOpen;
    });
  }

  void _signOutAndShowAlert() async {
    await auth.FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
    );
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
                  _isNotificationActive
                      ? Icons.notifications_active
                      : Icons.notifications,
                  color: Colors.white,
                ),
                onPressed: _toggleNotification, // Toggle the notification state on tap
              ),
            ],
            iconTheme: IconThemeData(color: Colors.white),
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
                    child: Text(
                      DateFormat('EEE, MMMM dd, yyyy').format(DateTime.now()), // Format the current date
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
                        child: StreamBuilder(
                          stream: _databaseService.getEvents(), // Stream fetching events
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            // Check for errors
                            if (snapshot.hasError) {
                              return Center(child: Text('An error occurred!'));
                            }

                            // Get the list of events from snapshot
                            List events = snapshot.data?.docs ?? [];
                            if (events.isEmpty) {
                              return Center(child: Text('No events found!')); // Handle empty state
                            }

                            // Limit the number of items to 3
                            events = events.take(3).toList();

                            return Row(
                              children: List.generate(
                                events.length, // Generate only up to 3 events
                                    (index) {
                                  var event = events[index].data();
                                  String eventId = events[index].id;
                                  print('Event Date: ${event.eventDate.toString()}');
                                  return Container(
                                    margin: const EdgeInsets.only(right: 10), // Add margin between containers
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
                                            DateFormat('MMM dd, yyyy').format(event.eventDate), // Display event date
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text(
                                              event.title, // Display event title
                                              style: TextStyle(fontSize: 30),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              _getEventStatus(event.eventDate), // Call method to get the event status
                                              style: TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
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
                            width: 170, // Set the width of the left container
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
                            width: 170, // Set the width of the right container
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
              child: _userInfo(widget.user),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDashboardPage(title: "Dashboard", user: widget.user),
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
                    builder: (context) => AnnouncementsPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Feedback'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              title: const Text('Events'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserEventsPage(title: "Events", user: widget.user),
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

  String _getEventStatus(DateTime eventDate) {
    DateTime now = DateTime.now();

    // Normalize times to ignore hours, minutes, and seconds for the comparison
    DateTime eventStartOfDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
    DateTime nowStartOfDay = DateTime(now.year, now.month, now.day);

    if (eventStartOfDay.isAfter(nowStartOfDay)) {
      return 'Upcoming Event'; // Event is in the future
    } else if (eventStartOfDay.isBefore(nowStartOfDay)) {
      return 'Happened Event'; // Event is in the past
    } else {
      return 'Ongoing Event'; // Event is happening today
    }
  }

  Widget _userInfo(auth.User user) {
    return SingleChildScrollView( // Wrap the Column with SingleChildScrollView
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.photoURL ?? ''),
            radius: 40,
          ),
          const SizedBox(height: 10),
          Text(
            user.displayName ?? 'No Display Name',
            style: TextStyle(
              fontSize: 18, // Change the font size here
              fontWeight: FontWeight.bold, // Optional: make the text bold
            ),
          ),
          const SizedBox(height: 5),
          Text(
            user.email ?? 'No Email',
            style: TextStyle(
              fontSize: 10, // Change the font size here
              color: Colors.white, // Optional: change the text color
            ),
          ),
        ],
      ),
    );
  }
}



// Mock user class for demonstration
class User {
  final String email;
  final String displayName;
  final String photoURL;

  User({required this.email, required this.displayName, required this.photoURL});
}

