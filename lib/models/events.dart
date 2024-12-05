import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final DateTime eventDate;
  final String title;
  final String description;
  final String place;


  Event({
    required this.eventDate,
    required this.title,
    required this.description,
    required this.place,
  });

  // Convert Firestore Document to Event Object
  factory Event.fromJson(Map<String, dynamic> json, {String id = ''}) {
    return Event(
      eventDate: _parseTimestamp(json['eventDate']), // Adjusted to 'date_time'
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      place: json['place'] ?? '',
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      // If the timestamp is stored as a string, parse it
      return DateTime.parse(value);
    } else {
      return DateTime.now(); // Fallback if the value is invalid
    }
  }

  // CopyWith function
  Event copyWith({
    DateTime? eventDate,
    String? title,
    String? description,
    String? place,
  }) {
    return Event(
      eventDate: eventDate ?? this.eventDate,
      title: title ?? this.title,
      description: description ?? this.description,
      place: place ?? this.place,
    );
  }

  // Convert Event Object to Firestore Document
  Map<String, dynamic> toJson() {
    return {
      'date_time': Timestamp.fromDate(eventDate), // Store as 'date_time'
      'title': title,
      'description': description,
      'place': place,
    };
  }
}
