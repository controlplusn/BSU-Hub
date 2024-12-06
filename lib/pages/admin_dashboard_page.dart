import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_up/pages/admin_events_page.dart';
import 'package:google_sign_up/pages/feedback_page.dart';
import 'package:google_sign_up/pages/home_page.dart';
import 'package:intl/intl.dart';
import './Announcements_page.dart';
import '../models/feedbacks.dart';
import 'feedback_details_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Define getTagColor here so it can be reused
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

  // fetch announcement data
  Future<List<Map<String, dynamic>>> _fetchRecentAnnouncements() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('announcements')
          .orderBy('date_time', descending: true)
          .limit(5)
          .get();

      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching announcements: $e');
      return [];
    }
  }

  // fetch events
  Stream<List<Map<String, dynamic>>> _fetchUpcomingEvents() {
    final now = DateTime.now();
    return _firestore
        .collection('events')
        .orderBy('date_time', descending: false)  // Show earliest events first
        .where('date_time', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .limit(10)  // Increased limit to show more events
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

  final FeedbackService feedbackService = FeedbackService();

  String _selectedStatus = 'Pending';

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
    );
  }

  void _onStatusSelected(String status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("BSU HUB"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Announcements'),
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
                    builder: (context) => AdminEventsPage(title: "Events for Admin"),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Sign Out'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello Admin",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),

              // Active Announcements Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Active Announcements",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddAnnouncementPage()),
                            );
                          },
                          icon: const Icon(Icons.add),
                          tooltip: 'Add Announcement',
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchRecentAnnouncements(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No announcements available.'),
                          );
                        }

                        List<Map<String, dynamic>> announcements = snapshot.data!;

                        return SizedBox(
                          height: 200, // Adjust the height to fit the design
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: announcements.length,

                            itemBuilder: (context, index) {
                              final announcement = announcements[index];
                              final title = announcement['title'];
                              final description = announcement['description'];
                              final category = announcement['category']; // Fetch the category field
                              final date = (announcement['date_time'] as Timestamp).toDate();
                              final formattedDate = DateFormat('MMM d, yyyy').format(date);

                              // Use a function to get the tag color
                              Color categoryColor = getTagColor(category);

                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Container(
                                  width: 300,
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      const SizedBox(height: 8),
                                      Text(
                                        description,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14),
                                      ),

                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Chip(
                                            label: Text(category),
                                            backgroundColor: categoryColor,
                                            labelStyle: const TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            formattedDate,
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Feedback Summary Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Feedback Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // "Pending" Button
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedStatus == 'Pending'
                                    ? Colors.red
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: TextButton(
                            style: ButtonStyle(
                              splashFactory: NoSplash.splashFactory, // Disable splash effect
                            ),
                            onPressed: () => _onStatusSelected('Pending'),
                            child: Text(
                              'Pending',
                              style: TextStyle(
                                color: _selectedStatus == 'Pending'
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        // "Resolved" Button
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedStatus == 'Resolved'
                                    ? Colors.red
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: TextButton(
                            style: ButtonStyle(
                              splashFactory: NoSplash.splashFactory, // Disable splash effect
                            ),
                            onPressed: () => _onStatusSelected('Resolved'),
                            child: Text(
                              'Resolved',
                              style: TextStyle(
                                color: _selectedStatus == 'Resolved'
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),
                    // Feedback Summary Table with Scrollable Rows
                    SizedBox(
                      height: 200, // Adjust height as needed
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: feedbackService.getFeedbacksByStatus(_selectedStatus),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _selectedStatus == 'Pending'
                                        ? Icons.pending_actions
                                        : Icons.check_circle_outline,
                                    size: 48,
                                    color: _selectedStatus == 'Pending'
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'No ${_selectedStatus.toLowerCase()} feedback available',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final feedbacks = snapshot.data!;

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: feedbacks.length,
                            itemBuilder: (context, index) {
                              final feedback = feedbacks[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FeedbackDetailsPage(
                                        feedbackId: feedback['id'],
                                        isAdmin: true,
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Container(
                                    width: 300,
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                feedback['title'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: feedback['status'] == 'Pending'
                                                    ? Colors.orange.withOpacity(0.2)
                                                    : Colors.green.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                feedback['status'] ?? 'Pending',
                                                style: TextStyle(
                                                  color: feedback['status'] == 'Pending'
                                                      ? Colors.orange
                                                      : Colors.green,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'From: ${feedback['user'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Wrap(
                                          spacing: 4,
                                          children: (feedback['tags'] as List<dynamic>)
                                              .map((tag) => Chip(
                                            label: Text(
                                              tag.toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                            backgroundColor: Colors.red,
                                            padding: EdgeInsets.zero,
                                            materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                          ))
                                              .toList(),
                                        ),
                                        Spacer(),
                                        if (feedback['status'] == 'Resolved' &&
                                            feedback['resolved_by'] != null) ...[
                                          Text(
                                            'Resolved by: ${feedback['resolved_by']}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                        ],
                                        Text(
                                          _formatDate(feedback['created_at']),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),


                  ],
                ),
              ),


              SizedBox(height: 20),

              // Upcoming Events Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Upcoming Events",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminEventsPage(title: "Events"),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          tooltip: 'Add Event',
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 200,  // Increased height to show more events
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _fetchUpcomingEvents(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }

                          final events = snapshot.data ?? [];

                          if (events.isEmpty) {
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
                            scrollDirection: Axis.horizontal,
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              final description = event['description'] as String? ?? '';

                              return Container(
                                margin: const EdgeInsets.only(right: 10),
                                width: 250,  // Slightly wider cards
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event['title'] ?? '',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            description,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black.withOpacity(0.6),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Spacer(),
                                          Text(
                                            DateFormat('MMM d, yyyy').format(
                                                (event['date_time'] as Timestamp).toDate()
                                            ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
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
                                                await _firestore
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
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm'); // Customize the format as needed
    if (date is Timestamp) {
      // Convert Timestamp to DateTime and format
      return dateFormat.format(date.toDate());
    } else if (date is DateTime) {
      // Already a DateTime object
      return dateFormat.format(date);
    } else {
      // If the date is null or unknown
      return 'Unknown Date';
    }
  }


  // Mock Dialogs for Edit and Delete
  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Item $index'),
          content: Text('Are you sure you want to delete item $index?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle delete action here
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
