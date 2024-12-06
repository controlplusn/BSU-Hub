import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to initialize status for existing feedbacks
  Future<void> initializeExistingFeedbacks() async {
    QuerySnapshot feedbacks = await _firestore.collection('feedbacks').get();

    for (var doc in feedbacks.docs) {
      if (!(doc.data() as Map<String, dynamic>).containsKey('status')) {
        await doc.reference.update({
          'status': 'Pending',
          'resolved_at': null,
          'resolved_by': null,
        });
      }
    }
  }

  // Get feedbacks filtered by status
  Stream<List<Map<String, dynamic>>> getFeedbacksByStatus(String status) {
    return _firestore
        .collection('feedbacks')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'description': data['description'] ?? '',
          'tags': List<String>.from(data['tags'] ?? []),
          'user': data['user'] ?? '',
          'created_at': data['created_at'],
          'status': data['status'] ?? 'Pending',
          'resolved_at': data['resolved_at'],
          'resolved_by': 'admin',  // Always show as 'admin' regardless of stored value
        };
      }).toList();
    });
  }

  // Method to update feedback status
  Future<void> updateFeedbackStatus(String feedbackId, String status) async {
    await _firestore.collection('feedbacks').doc(feedbackId).update({
      'status': status,
      'resolved_at': status == 'Resolved' ? Timestamp.now() : null,
      'resolved_by': status == 'Resolved' ? 'admin' : null,
    });
  }
}