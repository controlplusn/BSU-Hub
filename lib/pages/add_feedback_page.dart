import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFeedbackPage extends StatefulWidget {
  @override
  _AddFeedbackPageState createState() => _AddFeedbackPageState();
}

class _AddFeedbackPageState extends State<AddFeedbackPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final List<String> tags = ['General Usability', 'Navigation', 'Payments']; // Example tags
  String selectedTag = 'General Usability';

  // Function to add feedback to Firestore
  Future<void> addFeedback() async {
    try {
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'title': titleController.text,
        'description': descriptionController.text,
        'tags': [selectedTag],
        'user': 'Anonymous',  // Add logic to get real user info if needed
        'created_at': Timestamp.now(),  // Add current timestamp
      });

      // After adding feedback, clear the text fields and go back
      titleController.clear();
      descriptionController.clear();
      Navigator.pop(context);
    } catch (e) {
      print("Error adding feedback: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
        'Feedback System',
        style: TextStyle(color: Colors.white),
      ),
        backgroundColor: Colors.red, // Set the background color to red
        iconTheme: IconThemeData(color: Colors.white), // Set the icon color to white
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedTag,
              onChanged: (newTag) {
                setState(() {
                  selectedTag = newTag!;
                });
              },
              items: tags.map((tag) {
                return DropdownMenuItem<String>(
                  value: tag,
                  child: Text(tag),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: addFeedback,
              child: Text(
                'Submit Feedback',
                style: TextStyle(color: Colors.white), // Set the text color
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.red, // Set the text color (foreground color)
              ),
            )

          ],
        ),
      ),
    );
  }
}
