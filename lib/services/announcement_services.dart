import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcements.dart';

class AnnouncementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get latest announcements stream
  Stream<List<Announcement>> getLatestAnnouncements({int limit = 2}) {
    return _firestore
        .collection('announcements')
        .orderBy('date_time', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Announcement.fromFirestore(doc))
        .toList());
  }

  // Get announcements by category
  Stream<List<Announcement>> getAnnouncementsByCategory(String category) {
    return _firestore
        .collection('announcements')
        .where('category', isEqualTo: category)
        .orderBy('date_time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Announcement.fromFirestore(doc))
        .toList());
  }
}