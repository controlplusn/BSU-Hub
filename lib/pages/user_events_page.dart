import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_up/pages/Announcements_page.dart';
import 'package:google_sign_up/pages/home_page.dart';
import 'package:google_sign_up/pages/user_dashboard_page.dart';

class UserEventsPage extends StatefulWidget {
  const UserEventsPage({super.key, required this.title, required this.user});

  final String title;
  final auth.User user;

  @override
  State<UserEventsPage> createState() => _UserEventsPage();
}

class _UserEventsPage extends State<UserEventsPage> {
  bool _isAdmin = false; // Variable to store admin status
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

  // List of event data
  final List<Event> _events = [
    Event(
      title: 'SINAGTALA 2024',
      description: 'A grand celebration of BatstateU TNEU - Alangilan Campus.',
      eventDate: 'December 1, 2024',
      imageURL: 'assets/main-1-entrance.jpg', // Make sure the image path is correct
      place: 'BatstateU TNEU - Alangilan Campus',
    ),
    Event(
      title: 'Tech Conference 2024',
      description: 'An event for all tech enthusiasts.',
      eventDate: 'January 15, 2025',
      imageURL: 'assets/main-1-entrance.jpg', // Replace with your actual event image URL
      place: 'BatstateU Main Campus',
    ),
    Event(
      title: 'Music Fest 2024',
      description: 'A music festival to kickstart the new year.',
      eventDate: 'February 14, 2025',
      imageURL: 'assets/main-1-entrance.jpg', // Replace with your actual event image URL
      place: 'BatstateU TNEU - Alangilan Campus',
    ),
    Event(
      title: 'Sports Festival 2024',
      description: 'A celebration of sports and wellness.',
      eventDate: 'March 20, 2025',
      imageURL: 'assets/main-1-entrance.jpg', // Replace with your actual event image URL
      place: 'BatstateU Main Campus',
    ),
  ];

  // Variable to track the notification icon state (active or inactive)
  bool _isNotificationActive = false;

  // Controller for the search bar text
  final TextEditingController _searchController = TextEditingController();

  // Variable to track if search bar is visible
  bool _isSearchVisible = false;

  // Timer for countdown
  late Timer _timer;
  Map<String, String> countdownMap = {};

  // @override
  // void initState() {
  //   super.initState();
  //   _startCountdown();
  // }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentTime = DateTime.now();
      final updatedCountdownMap = <String, String>{};  // Explicitly define the type

      for (var event in _events) {
        final eventDate = DateTime.parse(event.eventDate); // Event date as DateTime
        final difference = eventDate.difference(currentTime);

        if (difference.isNegative) {
          updatedCountdownMap[event.title] = 'Event Started';
        } else {
          final days = difference.inDays;
          final hours = (difference.inHours % 60);
          final minutes = (difference.inMinutes % 60);

          updatedCountdownMap[event.title] =
          '$days days ${hours.toString().padLeft(2, '0')} hr ${minutes.toString().padLeft(2, '0')} mins';
        }
      }

      setState(() {
        countdownMap = updatedCountdownMap;  // Update the map with the new countdown
      });
    });
  }


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
                Navigator.pop(context); // Close the drawer
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
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, // Make the content scrollable vertically
              child: Column(
                children: _events.map((event) {
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
                    child: Stack( // Use Stack to position elements within the container
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Align all content to the start
                          children: [
                            // Image and event date on top of it
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20), // Apply border radius only to top-left corner
                                topRight: Radius.circular(20),
                              ),
                              child: Image.asset(
                                event.imageURL, // Use event image URL
                                width: double.infinity, // Takes up full width
                                height: 116, // Height for the image
                                fit: BoxFit.cover, // Ensure the image covers the space without distortion
                              ),
                            ),
                            Positioned(
                              left: 10,
                              bottom: 10,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                color: Colors.black.withOpacity(0.6),
                                child: Text(
                                  event.eventDate, // Display event date
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Event title and description
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                event.title, // Display event title
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
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
                            // Display countdown timer
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                countdownMap[event.title] ?? 'Loading...',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold
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
                                  builder: (context) => EventDescriptionPage(event: event),
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
                }).toList(),
              ),
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

class Event {
  final String title;
  final String description;
  final String eventDate;
  final String imageURL;
  final String place;

  Event({
    required this.title,
    required this.description,
    required this.eventDate,
    required this.imageURL,
    required this.place,
  });
}

class EventDescriptionPage extends StatelessWidget {
  final Event event;

  const EventDescriptionPage({super.key, required this.event});

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
                event.imageURL,
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
                        event.eventDate,
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