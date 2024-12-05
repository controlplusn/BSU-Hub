import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting date
import './home_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({Key? key}) : super(key: key);

  @override
  _AnnouncementsPageState createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  bool _isAdmin = false; // Variable to store admin status
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          elevation: 1,
          title: Text(
            'Announcements',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              // Navigate to the home page (replace 'HomePage' with your actual home widget)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()), // Replace with actual home page
              );
            },
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.black,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'All Items'),
              Tab(text: 'General'),
              Tab(text: 'Sports'),
              Tab(text: 'Classes'),
              Tab(text: 'Events'),
            ],
          ),
          actions: [
            // Conditionally render the "Add Announcement" button for admins
            if (_isAdmin)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddAnnouncementPage()),
                    );
                  },
                  icon: Icon(Icons.add),
                  label: Text("Add Announcement"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: TabBarView(
          children: [
            AnnouncementsList(category: 'All Items'),
            AnnouncementsList(category: 'General'),
            AnnouncementsList(category: 'Sports'),
            AnnouncementsList(category: 'Classes'),
            AnnouncementsList(category: 'Events'),
          ],
        ),
      ),
    );
  }
}


class AnnouncementsList extends StatelessWidget {
  final String category;

  const AnnouncementsList({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Query for 'All Items'
    Query query;
    if (category == 'All Items') {
      query = FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('date_time', descending: true); // No filter for 'All Items'
    } else {
      query = FirebaseFirestore.instance
          .collection('announcements')
          .where('category', isEqualTo: category) // Filter by category
          .orderBy('date_time', descending: true); // Order by date
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final announcements = snapshot.data!.docs;

        if (announcements.isEmpty) {
          return Center(child: Text('No announcements found.'));
        }

        return ListView.builder(
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            final title = announcement['title'];
            final description = announcement['description'];
            final category = announcement['category'];
            final date = (announcement['date_time'] as Timestamp).toDate();
            final formattedDate = DateFormat('dd-MM-yyyy h:mm a').format(date);

            Color categoryColor = getTagColor(category);

            return Card(
              margin: EdgeInsets.only(bottom: 16, left: 12, right: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              elevation: 4, // Shadow for the card
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    // Padding inside the card
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(formattedDate),
                        ],
                      ),
                      onTap: () {
                        // Show full announcement when tapped
                        showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                title: Text(title),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Category: $category'),
                                    SizedBox(height: 8),
                                    Text('Description: $description'),
                                    SizedBox(height: 8),
                                    Text('Date: $formattedDate'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Close'),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  ),
                  // Positioned widget to place the tag at the top right
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Chip(
                      label: Text(category),
                      backgroundColor: categoryColor,
                      // Set the background color of the chip
                      labelStyle: TextStyle(color: Colors.white),
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            16), // Rounded pill shape
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}


// Get tag-specific color
Color getTagColor(String? tag) {
  switch (tag) {
    case 'Exams':
      return Colors.blue;
    case 'General':
      return Colors.red;
    case 'Sports':
      return Colors.indigo;
    case 'Classes':
      return Colors.orange;
    case 'Events':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

// Placeholder for Add Announcement Page
class AddAnnouncementPage extends StatefulWidget {
  const AddAnnouncementPage({super.key});

  @override
  State<AddAnnouncementPage> createState() => _AddAnnouncementPageState();
}

class _AddAnnouncementPageState extends State<AddAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory; // Variable to hold the selected category

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List of categories for the dropdown
  final List<String> _categories = ['General', 'Sports', 'Classes', 'Events'];

  Future<void> _submitAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Add the announcement to Firestore
        await _firestore.collection('announcements').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'category': _selectedCategory,
          'date_time': Timestamp.now(), // Store current date and time
        });

        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Announcement added successfully!'),
        ));

        // Clear the form fields
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedCategory = null; // Reset selected category
        });

        // Navigate back to the previous screen
        Navigator.pop(context);
      } catch (e) {
        // Show error message if there's an issue adding the announcement
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error adding announcement: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Dropdown for category selection
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Category'),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitAnnouncement,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
