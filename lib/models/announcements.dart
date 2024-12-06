import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime dateTime;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dateTime,
  });

  factory Announcement.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Announcement(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      dateTime: (data['date_time'] as Timestamp).toDate(),
    );
  }
}