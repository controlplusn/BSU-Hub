import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeedbackDetailsPage extends StatefulWidget {
  final String feedbackId;  // Feedback ID from Firestore

  const FeedbackDetailsPage({required this.feedbackId});

  @override
  _FeedbackDetailsPageState createState() => _FeedbackDetailsPageState();
}

class _FeedbackDetailsPageState extends State<FeedbackDetailsPage> {
  final TextEditingController commentController = TextEditingController();

  // Function to add a comment to Firebase
  Future<void> addComment(String feedbackId) async {
    if (commentController.text.isNotEmpty) {
      try {
        // Add comment to the Firestore subcollection of this feedback
        await FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(feedbackId)
            .collection('comments')
            .add({
          'comment': commentController.text,
          'user': 'Anonymous',  // Add logic to get real user info if needed
          'created_at': Timestamp.now(),  // Add current timestamp
        });

        // Clear the comment input field after submission
        commentController.clear();
      } catch (e) {
        print("Error adding comment: $e");
      }
    }
  }

  // Fetching the feedback details and its comments
  Stream<DocumentSnapshot<Map<String, dynamic>>> getFeedbackDetails() {
    return FirebaseFirestore.instance
        .collection('feedbacks')
        .doc(widget.feedbackId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getComments() {
    return FirebaseFirestore.instance
        .collection('feedbacks')
        .doc(widget.feedbackId)
        .collection('comments')
        .orderBy('created_at', descending: true)  // Order comments by time
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: getFeedbackDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.hasError) {
                  return Center(child: Text('Error loading feedback.'));
                }

                var feedback = snapshot.data!.data()!;
                DateTime postTime = (feedback['created_at'] as Timestamp).toDate();
                String formattedTime = '${postTime.month}/${postTime.day}/${postTime.year} ${postTime.hour}:${postTime.minute}';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Posted on: $formattedTime',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    Text(
                      feedback['title'],
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: (feedback['tags'] as List)
                          .map<Widget>((tag) => Chip(label: Text(tag)))
                          .toList(),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Posted by: ${feedback['user'] == 'anonymous' ? 'Anonymous' : feedback['user']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 16),
                    Text(feedback['description']),
                    SizedBox(height: 16),
                    Text(
                      'Comments:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: getComments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.hasError) {
                    return Center(child: Text('Error loading comments.'));
                  }

                  var comments = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      var comment = comments[index].data();
                      DateTime commentTime = (comment['created_at'] as Timestamp).toDate();
                      String formattedTime = '${commentTime.month}/${commentTime.day}/${commentTime.year} ${commentTime.hour}:${commentTime.minute}';

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(comment['comment']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('By: ${comment['user']}'),
                              Text('Posted at: $formattedTime'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: 'Add a comment...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                addComment(widget.feedbackId); // Add comment to this specific feedback
              },
              child: Text('Add Comment'),
            ),
          ],
        ),
      ),
    );
  }
}
