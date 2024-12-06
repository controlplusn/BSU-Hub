import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackDetailsPage extends StatefulWidget {
  final String feedbackId;
  final bool isAdmin;

  const FeedbackDetailsPage({
    required this.feedbackId,
    required this.isAdmin,
  });

  @override
  _FeedbackDetailsPageState createState() => _FeedbackDetailsPageState();
}

class _FeedbackDetailsPageState extends State<FeedbackDetailsPage> {
  final TextEditingController commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool  _isResolved = false;

  @override
  void initState() {
    super.initState();
    initializeFeedbackStatus();
  }

  // Function to initialize feedback status
  Future<void> initializeFeedbackStatus() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('feedbacks')
          .doc(widget.feedbackId)
          .get();

      if (!doc.data()!.containsKey('status')) {
        await doc.reference.update({'status': 'Pending'});
      }
    } catch (e) {
      print("Error initializing feedback status: $e");
    }
  }

  // Function to show confirmation dialog
  Future<bool?> showResolutionConfirmation(bool isResolved) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            isResolved ? 'Resolve Feedback?' : 'Mark as Pending?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isResolved ? Colors.green : Colors.orange,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isResolved
                    ? 'Are you sure you want to mark this feedback as resolved? This will:'
                    : 'Are you sure you want to mark this feedback as pending? This will:',
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isResolved) ...[
                      Text('• Disable further comments'),
                      Text('• Mark the issue as completed'),
                      Text('• Record your email as resolver'),
                    ] else ...[
                      Text('• Enable comments again'),
                      Text('• Mark the issue as active'),
                      Text('• Remove resolution status'),
                    ],
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isResolved ? Colors.green : Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isResolved ? 'Resolve' : 'Mark Pending',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }


  // Function to toggle feedback resolution status
  Future<void> toggleFeedbackStatus(bool isResolved) async {
    final bool? confirm = await showResolutionConfirmation(isResolved);

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(widget.feedbackId)
            .update({
          'status': isResolved ? 'Resolved' : 'Pending',
          'resolved_at': isResolved ? Timestamp.now() : null,
          'resolved_by': isResolved ? 'admin' : null,
        });

        setState(() {
          _isResolved = isResolved;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                isResolved
                    ? 'Feedback marked as resolved'
                    : 'Feedback marked as pending'
            ),
            backgroundColor: isResolved ? Colors.green : Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating feedback status: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // Function to delete feedback
  Future<void> deleteFeedback() async {
    try {
      // First, delete all comments
      final commentsSnapshot = await FirebaseFirestore.instance
          .collection('feedbacks')
          .doc(widget.feedbackId)
          .collection('comments')
          .get();

      for (var doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Then delete the feedback document
      await FirebaseFirestore.instance
          .collection('feedbacks')
          .doc(widget.feedbackId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Feedback deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting feedback: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to add a comment
  Future<void> addComment() async {
    if (commentController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(widget.feedbackId)
            .collection('comments')
            .add({
          'comment': commentController.text,
          'user': _auth.currentUser?.email ?? 'Anonymous',
          'created_at': Timestamp.now(),
        });
        commentController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


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
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feedback Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
        actions: widget.isAdmin ? [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Feedback'),
                  content: Text('Are you sure you want to delete this feedback?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        deleteFeedback();
                      },
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ] : null,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: getFeedbackDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Feedback not found'));
          }

          final feedbackData = snapshot.data!.data()!;
          final status = feedbackData['status'] ?? 'Pending';
          _isResolved = status == 'Resolved';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isAdmin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isResolved ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isResolved ? 'Resolved' : 'Pending',
                          style: TextStyle(
                            color: _isResolved ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => toggleFeedbackStatus(!_isResolved),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isResolved ? Colors.orange : Colors.green,
                        ),
                        child: Text(
                          _isResolved ? 'Mark as Pending' : 'Mark as Resolved',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: 16),
                Text(
                  feedbackData['title'] ?? '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'From: ${feedbackData['user'] ?? 'Anonymous'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                if (_isResolved && feedbackData['resolved_by'] != null) ...[
                  Text(
                    'Resolved by admin',
                    style: TextStyle(fontSize: 14, color: Colors.green),
                  ),
                  Text(
                    'Resolved at: ${(feedbackData['resolved_at'] as Timestamp).toDate().toString()}',
                    style: TextStyle(fontSize: 14, color: Colors.green),
                  ),
                ],
                SizedBox(height: 16),
                Text(
                  feedbackData['description'] ?? '',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: (feedbackData['tags'] as List?)
                      ?.map<Widget>((tag) => Chip(
                    label: Text(tag.toString(), style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.red,
                  ))
                      ?.toList() ?? [],
                ),
                SizedBox(height: 16),

                if (_isResolved)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 48,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'This feedback has been resolved',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Text(
                    'Comments:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: getComments(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No comments yet'));
                        }

                        final comments = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index].data();
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(comment['comment'] ?? ''),
                                subtitle: Text(
                                  'By: ${comment['user'] ?? 'Anonymous'}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (commentController.text.isNotEmpty) {
                              FirebaseFirestore.instance
                                  .collection('feedbacks')
                                  .doc(widget.feedbackId)
                                  .collection('comments')
                                  .add({
                                'comment': commentController.text,
                                'user': _auth.currentUser?.email ?? 'Anonymous',
                                'created_at': Timestamp.now(),
                              });
                              commentController.clear();
                            }
                          },
                          child: Text('Send'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
