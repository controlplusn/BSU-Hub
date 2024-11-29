import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BSU HUB',
      theme: ThemeData(
        cardColor: Colors.red, // Set the card color to red
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyEvent(title: 'BSU HUB'),
    );
  }
}

class MyEvent extends StatefulWidget {
  const MyEvent({super.key, required this.title});

  final String title;

  @override
  State<MyEvent> createState() => _MyEvent();
}

class _MyEvent extends State<MyEvent> {
  int _counter = 0;

  // Mock user data (replace with real authentication logic)
  final _user = User(
    email: "user@example.com",
    displayName: "John Doe",
    photoURL: "https://example.com/photo.jpg", // Replace with a valid URL if necessary
  );

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
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Center( // Center the user info
                child: _userInfo(),
              ),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              title: const Text('Announcement'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
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
                Navigator.pop(context); // Close the drawer
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
                                color: Colors.black54,
                                child: Text(
                                  event.eventDate, // Display the event date
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Event title, place, and description below the image
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18, // Increase font size
                                      color: Colors.black, // Ensure dark text color
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    event.place,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16, // Slightly smaller font size
                                      color: Colors.black, // Ensure dark text color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                event.description,
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
                              // Action on button press
                            },
                            label: Text('Interested'),
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

  Widget _userInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
      crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(_user.photoURL), // Ensure the URL is valid
          radius: 40,
        ),
        const SizedBox(height: 20),
        Text(_user.displayName),
        const SizedBox(height: 5),
        Text(_user.email),
      ],
    );
  }
}

// Event class to represent each event
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

// Mock user class for demonstration
class User {
  final String email;
  final String displayName;
  final String photoURL;

  User({required this.email, required this.displayName, required this.photoURL});
}
