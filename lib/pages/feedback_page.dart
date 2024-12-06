import 'package:flutter/material.dart';
import './feedback_details_page.dart';
import './add_feedback_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String adminEmail = "22-06230@g.batstate-u.edu.ph";

  bool get isAdmin => _auth.currentUser?.email == adminEmail;

  // Fetching data from Firestore
  Stream<List<Map<String, dynamic>>> getFeedbacks() {
    return FirebaseFirestore.instance
        .collection('feedbacks')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc['title'],
          'description': doc['description'],
          'tags': List<String>.from(doc['tags']),
          'user': doc['user'],
          'created_at': (doc['created_at'] as Timestamp).toDate(),
          'status': doc['status'] ?? 'Pending',
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
          style: TextStyle(color: Colors.white),
        ),

        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),

      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
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
              final feedbackId = feedback['id'];
              final status = feedback['status'] ?? 'Pending';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(color: Colors.black, width: 1.0),
                ),
                child: ListTile(
                  title: Row(
                    children: [
                      Expanded(child: Text(feedback['title'])),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'Resolved'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: status == 'Resolved' ? Colors.green : Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(feedback['user']),
                      SizedBox(height: 4),
                      Text(feedback['created_at'].toString()),
                      Wrap(
                        spacing: 8,
                        children: (feedback['tags'] as List)
                            .map<Widget>((tag) => Chip(
                          label: Text(tag, style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.red,
                        ))
                            .toList(),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FeedbackDetailsPage(
                          feedbackId: feedbackId,
                          isAdmin: isAdmin,
                        ),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddFeedbackPage()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Feedback',
        backgroundColor: Colors.red,
      ),
    );
  }
}
