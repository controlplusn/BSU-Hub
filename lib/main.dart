import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for formatting the date


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyEvent(title: 'Event List'),
    );
  }
}

class MyEvent extends StatefulWidget {
  final String title;
  MyEvent({required this.title});

  @override
  _MyEventState createState() => _MyEventState();
}

class _MyEventState extends State<MyEvent> {
  bool _isSearchVisible = false;
  bool _isNotificationActive = false;
  TextEditingController _searchController = TextEditingController();
  List<Event> _events = [
    Event(
      title: 'Concert',
      description: 'A great concert event.',
      eventDate: '12 January, 2024',
      imageURL: 'assets/BB2-Main-Campus-II.jpg.webp', // Make sure you have a valid image path
    ),
    Event(
      title: 'Seminar',
      description: 'Learn about Flutter at the seminar.',
      eventDate: '12 January, 2024',
      imageURL: 'assets/BB2-Main-Campus-II.jpg.webp', // Make sure you have a valid image path
    ),
    Event(
      title: 'Seminar',
      description: 'Learn about Flutter at the seminar.',
      eventDate: '12 January, 2024',
      imageURL: 'assets/BB2-Main-Campus-II.jpg.webp', // Make sure you have a valid image path
    ),
    Event(
      title: 'Seminar',
      description: 'Learn about Flutter at the seminar.',
      eventDate: '12 January, 2024',
      imageURL: 'assets/BB2-Main-Campus-II.jpg.webp', // Make sure you have a valid image path
    ),
  ];

  Map<String, String> countdownMap = {};

  // Toggle search bar visibility
  void _toggleSearchBar() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });
  }

  // Toggle notification status
  void _toggleNotification() {
    setState(() {
      _isNotificationActive = !_isNotificationActive;
    });
  }

  // Sign-out logic
  void _signOutAndShowAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                // Sign out logic here
              },
            ),
          ],
        );
      },
    );
  }

  Widget _userInfo() {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage('assets/user_avatar.jpg'), // Make sure you have a valid image path
        ),
        SizedBox(height: 10),
        Text(
          'John Doe',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          'johndoe@example.com',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchVisible ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: _toggleSearchBar,
          ),
          IconButton(
            icon: Icon(
              _isNotificationActive ? Icons.notifications_active : Icons.notifications,
              color: Colors.white,
            ),
            onPressed: _toggleNotification,
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Center(child: _userInfo()),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Announcement'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Feedback'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Events'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Sign Out'),
              onTap: _signOutAndShowAlert,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _events.map((event) {
                  return Container(
                    margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              child: Image.asset(
                                event.imageURL,
                                width: double.infinity,
                                height: 116,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              left: 10,
                              bottom: 10,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                color: Colors.black.withOpacity(0.6),
                                child: Text(
                                  event.eventDate,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                event.title,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                event.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                countdownMap[event.title] ?? 'Loading...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: FloatingActionButton.extended(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDescriptionPage(event: event),
                                ),
                              );
                            },
                            label: const Text(
                              'More Details',
                              style: TextStyle(color: Colors.white),
                            ),
                            icon: const Icon(
                              Icons.info,
                              color: Colors.white,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEventPage(),
            ),
          );
        },
        label: Text(
          'Add Event',
          style: TextStyle(color: Colors.white),
        ),
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.red[900],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class Event {
  final String title;
  final String description;
  final String eventDate;
  final String imageURL;

  Event({
    required this.title,
    required this.description,
    required this.eventDate,
    required this.imageURL,
  });

  get place => null;
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
            SnackBar(content: Text('Redirecting to edit post for ${event.title}')),
          );
        },
        label: Text('Edit Post', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Position it at the bottom right
    );
  }
}

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Function to pick date
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Function to pick time
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Event',
          style: TextStyle(
            color: Colors.white, // Set the text color to white
          ),
        ),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(
          color: Colors.white, // This sets the back button (and any other icons) color to white
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Title Input Field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Description Input Field
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Event Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Date Picker
            ListTile(
              title: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : DateFormat('yyyy-MM-dd').format(_selectedDate!),
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _pickDate(context),
            ),
            SizedBox(height: 16),

            // Time Picker
            ListTile(
              title: Text(
                _selectedTime == null
                    ? 'Select Time'
                    : _selectedTime!.format(context),
              ),
              trailing: Icon(Icons.access_time),
              onTap: () => _pickTime(context),
            ),
            SizedBox(height: 16),

            // Save Button
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty &&
                    _descriptionController.text.isNotEmpty &&
                    _selectedDate != null &&
                    _selectedTime != null) {
                  // Use the input data for creating a new event
                  final newEvent = Event(
                    title: _titleController.text,
                    description: _descriptionController.text,
                    eventDate: '${DateFormat('yyyy-MM-dd').format(_selectedDate!)} ${_selectedTime!.format(context)}',
                    imageURL: 'assets/default_event_image.jpg', // Default or placeholder image
                  );

                  // Here you could pass the `newEvent` object to the event list or back to the previous page
                  Navigator.pop(context, newEvent); // Pass the new event back to the previous page
                } else {
                  // Show alert if any field is empty
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Missing Information'),
                      content: Text('Please fill in all the fields.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text(
                'Save Event',
                style: TextStyle(
                  color: Colors.white, // Set the text color
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Set the button background color
                padding: EdgeInsets.symmetric(vertical: 15), // Set vertical padding
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventAdmin {
  final String title;
  final String description;
  final String eventDate;
  final String imageURL;

  EventAdmin({
    required this.title,
    required this.description,
    required this.eventDate,
    required this.imageURL,
  });
}