import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_up/pages/Announcements_page.dart';
import 'package:google_sign_up/pages/feedback_page.dart';
import 'package:google_sign_up/pages/home_page.dart';
import 'package:google_sign_up/pages/user_dashboard_page.dart';
import 'package:google_sign_up/services/database_services.dart';
import 'package:google_sign_up/models/events.dart';

class UserEventsPage extends StatefulWidget {
  const UserEventsPage({super.key, required this.title, required this.user});

  final String title;
  final auth.User user;

  @override
  State<UserEventsPage> createState() => _UserEventsPage();
}

class _UserEventsPage extends State<UserEventsPage> {
  bool _isAdmin = false; // Variable to store admin status
  final DatabaseService _databaseService = DatabaseService();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _counter = 0;

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


  // Variable to track the notification icon state (active or inactive)
  bool _isNotificationActive = false;

  // Controller for the search bar text
  final TextEditingController _searchController = TextEditingController();

  // Variable to track if search bar is visible
  bool _isSearchVisible = false;

  // Timer for countdown
  late Timer _timer;
  Map<String, String> countdownMap = {};




  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
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

  void _toggleNotification() {
    setState(() {
      _isNotificationActive = !_isNotificationActive;
    });
    print("Notification icon tapped. Active state: $_isNotificationActive");
  }

  void _toggleSearchBar() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red, // Set the background color of the AppBar
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // Search Icon
          IconButton(
            icon: Icon(
              _isSearchVisible ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: _toggleSearchBar, // Toggle the search bar visibility
          ),
          // Notification Icon
          IconButton(
            icon: Icon(
              _isNotificationActive ? Icons.notifications_active : Icons.notifications,
              color: Colors.white,
            ),
            onPressed: _toggleNotification, // Toggle the notification state on tap
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white), // Set the color of the hamburger icon
      ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedbackPage(),
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
                    builder: (context) => UserEventsPage(title: "Events", user: widget.user,),
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

      body: Column(
        children: [
          // Show search bar if it's visible
          if (_isSearchVisible)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  fillColor: Colors.white,
                  filled: true,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          // Scrollable Container
          Expanded(
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

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    var event = events[index].data();
                    String eventId = events[index].id;

                    // Build the container here using the event data
                    return Container(
                      margin: const EdgeInsets.only(top: 30, left: 30, right: 30), // Adding margin
                      width: 350, // Set the width of each container
                      height: 350, // Set the height of each container
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black, // Border color for the top side
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(20), // Rounded corners
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image and event date on top of it
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20), // Apply border radius only to top-left corner
                                  topRight: Radius.circular(20),
                                ),
                                child: Image.asset(
                                  'assets/8.jpg',
                                  width: double.infinity, // Takes up full width
                                  height: 116, // Height for the image
                                  fit: BoxFit.cover, // Ensure the image covers the space without distortion
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Time',//(event.eventDate.toDate().toString(), // Display event date
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Event title and description
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  event.title, // Display event title
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  event.description, // Display event description
                                  style: TextStyle(
                                    fontSize: 14, // Slightly smaller font size
                                    color: Colors.black54, // Lighter text color for description
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Floating Action Button on the right side
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: FloatingActionButton.extended(
                              onPressed: () {
                                // Navigate to EventDescriptionPage
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EventDescriptionPage(eventId: eventId, event: event),
                                  ),
                                );
                              },
                              label: const Text(
                                'More Details',
                                style: TextStyle(color: Colors.white), // Set text color here
                              ),
                              icon: const Icon(
                                Icons.info,
                                color: Colors.white, // Set icon color here
                              ),
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _userInfo(auth.User user) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(
        backgroundImage: NetworkImage(user.photoURL ?? ''),
        radius: 40,
      ),
      const SizedBox(height: 10),
      Text(user.displayName ?? 'No Display Name'),
      const SizedBox(height: 5),
      Text(user.email ?? 'No Email'),
    ],
  );
}


class EventDescriptionPage extends StatelessWidget {
  final String eventId;
  final Event event;

  const EventDescriptionPage({super.key, required this.event, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0, // Adjust the height as needed
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                'assets/8.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        event.eventDate.toString(),
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      Text(
                        event.description,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Location: ${event.place}',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // FloatingActionButton to Buy Ticket
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Logic to handle ticket purchase (you can navigate to another page or show a dialog)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Redirecting to Buy Tickets for ${event.title}')),
          );
        },
        label: Text('Buy Ticket', style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.confirmation_num, color: Colors.white),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Position it at the bottom right
    );
  }
}


class User {
  final String email;
  final String displayName;
  final String photoURL;

  User({
    required this.email,
    required this.displayName,
    required this.photoURL,
  });
}