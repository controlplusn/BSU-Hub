import 'package:flutter/material.dart';
import './feedback_detail_page.dart';
import './add_feedback_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  // Fetching data from Firestore
  Stream<List<Map<String, dynamic>>> getFeedbacks() {
    return FirebaseFirestore.instance
        .collection('feedbacks')
        .orderBy('created_at', descending: true)  // Order by time, newest first
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,  // Add the document ID here
          'title': doc['title'],
          'description': doc['description'],
          'tags': List<String>.from(doc['tags']),
          'user': doc['user'],
          'created_at': (doc['created_at'] as Timestamp).toDate(),
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feedback System',
          style: TextStyle(color: Colors.white), // Set the text color to white
        ),
        backgroundColor: Colors.red, // Set the background color to red
        iconTheme: IconThemeData(color: Colors.white), // Set the icon color to white
      ),

  body: StreamBuilder<List<Map<String, dynamic>>>(  // Updated to handle list of feedbacks
        stream: getFeedbacks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No feedback available.'));
          }

          final feedbacks = snapshot.data!;

          return ListView.builder(
            itemCount: feedbacks.length,
            itemBuilder: (context, index) {
              final feedback = feedbacks[index];
              final feedbackId = feedback['id'];  // Get the feedback ID

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.white, // Set the background color of the Card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // Optional: Rounded corners
                  side: BorderSide(
                    color: Colors.black, // Set the border color
                    width: 1.0, // Set the border width
                  ),
                ),
                child: ListTile(
                  title: Text(feedback['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(feedback['user']),
                      SizedBox(height: 4),
                      Text(feedback['created_at'].toString()),
                      Wrap(
                        spacing: 8,
                        children: feedback['tags']
                            .map<Widget>((tag) => Chip(
                          label: Text(
                            tag,
                            style: TextStyle(
                              color: Colors.white, // Set the text color of the chip
                            ),
                          ),
                          backgroundColor: Colors.red, // Set the background color of the chip
                        ))
                            .toList(),
                      ),

                    ],
                  ),
                  onTap: () {
                    final feedbackId = feedback['id'];
                    // Handle feedback click (navigate to feedback details page)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FeedbackDetailsPage(feedbackId: feedbackId), // Pass feedbackId here
                      ),
                    );
                  },
                ),
              );

            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the "Add Feedback" page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFeedbackPage(),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white, // Set the icon color (foreground color)
        ),
        tooltip: 'Add Feedback',
        backgroundColor: Colors.red, // Set the background color of the FAB
      ),

    );
  }
}
