import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_up/pages/admin_dashboard_page.dart';
import 'package:intl/intl.dart'; // Import for formatting the date
import 'descriptionevent.dart';

class AdminEventsPage extends StatefulWidget {
  final String title;
  AdminEventsPage({required this.title});

  @override
  _AdminEventsState createState() => _AdminEventsState();
}

class _AdminEventsState extends State<AdminEventsPage> {
  bool _isSearchVisible = false;
  bool _isNotificationActive = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // fetch events from firestore
  Stream<List<Map<String, dynamic>>> _fetchEvents() {
    return _firestore
        .collection('events')
        .orderBy('date_time', descending: false)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            ...data,
            'id': doc.id,
          };
        }).toList();
      } catch (e) {
        print('Error processing events: $e');
        return [];
      }
    });
  }


  @override
  void initState() {
    super.initState();
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

      body: Column(
        children: [
          // search bar
          if (_isSearchVisible)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  fillColor: Colors.white,
                  filled: true,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = "";
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

          // Event List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _fetchEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final events = snapshot.data ?? [];
                // Apply search query filter
                final filteredEvents = events.where((event) {
                  return event['title'].toLowerCase().contains(_searchQuery) ||
                      event['description'].toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredEvents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'No upcoming events',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = filteredEvents[index];
                    DateTime eventDate = (event['date_time'] as Timestamp).toDate();  // Convert Timestamp to DateTime

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDescriptionPage(event: event), // Pass Event object
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 3,
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['title'] ?? 'No Title',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    DateFormat('yyyy-MM-dd HH:mm').format(eventDate), // Use the converted DateTime
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    event['description'] ?? 'No Description',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Location: ${event['place'] ?? 'Unknown'}',
                                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_horiz),
                                onSelected: (value) async {
                                  if (value == 'Delete') {
                                    final shouldDelete = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Delete Event'),
                                        content: Text('Are you sure you want to delete this event?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: Text('Delete'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ) ?? false;

                                    if (shouldDelete) {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('events')
                                            .doc(event['id'])
                                            .delete();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Event deleted successfully')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to delete event: $e')),
                                        );
                                      }
                                    }
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem<String>(
                                    value: 'Delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
            ,
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


class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _placeController = TextEditingController();
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

  // Function to add event to Firebase with error handling
  void _addEventToFirebase() async {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _selectedDate != null &&
        _selectedTime != null) {
      try {
        // Combine date and time
        final DateTime combinedDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        // Create event data
        final eventData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'date_time': Timestamp.fromDate(combinedDateTime),  // Changed from 'eventDate' to 'date_time'
          'place': _placeController.text,
        };

        // Add to Firestore
        await FirebaseFirestore.instance.collection('events').add(eventData);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Pop back to previous screen
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Missing Information'),
          content: Text('Please fill in all the fields.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
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

            // Place Input Field
            TextField(
              controller: _placeController,
              decoration: InputDecoration(
                labelText: 'Event Location',
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
                _addEventToFirebase(); // Call the function to add the event to Firebase
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
