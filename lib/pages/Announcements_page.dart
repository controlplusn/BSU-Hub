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

  // admin email
  final String adminEmail = "22-06230@g.batstate-u.edu.ph";

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  void _checkAdminStatus() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _isAdmin = user.email == adminEmail;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text(
            'Announcements',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
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
            indicatorColor: Colors.blue,
            labelColor: Colors.black,
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

  Future<void> _deleteAnnouncement(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Announcement deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting announcement: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
    final isAdmin = _auth.currentUser?.email == "22-06230@g.batstate-u.edu.ph";

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
            final docId = announcement.id;
            final title = announcement['title'];
            final description = announcement['description'];
            final category = announcement['category'];
            final date = (announcement['date_time'] as Timestamp).toDate();
            final formattedDate = DateFormat('dd-MM-yyyy h:mm a').format(date);

            Color categoryColor = getTagColor(category);

            return Card(
              margin: EdgeInsets.only(bottom: 16, left: 12, right: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (isAdmin)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddAnnouncementPage(
                                          isEditing: true,
                                          announcementId: docId,
                                          initialTitle: title,
                                          initialDescription: description,
                                          initialCategory: category,
                                        ),
                                      ),
                                    );
                                  } else if (value == 'delete') {
                                    final shouldDelete = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Delete Announcement'),
                                        content: Text('Are you sure you want to delete this announcement?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: Text(
                                              'Delete',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ) ?? false;

                                    if (shouldDelete) {
                                      await _deleteAnnouncement(context, docId);
                                    }
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formattedDate),
                            Chip(
                              label: Text(category),
                              backgroundColor: categoryColor,
                              labelStyle: TextStyle(color: Colors.white),
                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ],
                        ),
                      ],
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
  final bool isEditing;
  final String? announcementId;
  final String? initialTitle;
  final String? initialDescription;
  final String? initialCategory;

  const AddAnnouncementPage({
    super.key,
    this.isEditing = false,
    this.announcementId,
    this.initialTitle,
    this.initialDescription,
    this.initialCategory,
  });

  @override
  State<AddAnnouncementPage> createState() => _AddAnnouncementPageState();
}

class _AddAnnouncementPageState extends State<AddAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedCategory; // Variable to hold the selected category

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List of categories for the dropdown
  final List<String> _categories = ['General', 'Sports', 'Classes', 'Events'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      try {
        final data = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'category': _selectedCategory,
        };

        if (widget.isEditing && widget.announcementId != null) {
          // Update existing announcement without modifying the timestamp
          await _firestore
              .collection('announcements')
              .doc(widget.announcementId)
              .update(data);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Announcement updated successfully!')),
          );
        } else {
          // Add new announcement with current timestamp
          await _firestore.collection('announcements').add({
            ...data,
            'date_time': Timestamp.now(), // Add timestamp only for new announcements
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Announcement added successfully!')),
          );
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error ${widget.isEditing ? 'updating' : 'adding'} announcement: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Announcement' : 'Add Announcement'),
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
                child: Text(widget.isEditing ? 'Update' : 'Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
