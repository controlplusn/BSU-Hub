import 'package:cloud_firestore/cloud_firestore.dart';

// model of Events data

class Event {
  final DateTime eventDate;
  final String title;
  final List<String> description; //this is stored in array since it can have multiple values
  final String place;
  final String imageURL; // I'll be using url since it is referencing to a firebase storage

  Event({
    required this.eventDate,
    required this.title,
    required this.description,
    required this.place,
    required this.imageURL,
  });

  // Convert Firestore Document to Event Object
  factory Event.fromJson(Map<String, dynamic> json, {String id = ''}) {
    return Event(
      eventDate: (json['eventDate'] as Timestamp).toDate(),
      title: json['title'] ?? '',
      description: List<String>.from(json['description'] ?? []),
      place: json['place'] ?? '',
      imageURL: json['imageURL'] ?? '',
    );
  }

  // copyWith function
  // this allows you to create a new Event object by copying an existing one while overriding specific fields.
  Event copyWith({
    DateTime? eventDate,
    String? title,
    List<String>? description,
    String? place,
    String? imageURL,
  }) {
    return Event(
      eventDate: eventDate ?? this.eventDate,
      title: title ?? this.title,
      description: description ?? this.description,
      place: place ?? this.place,
      imageURL: imageURL ?? this.imageURL,
    );
  }

  // Convert Event Object to Firestore Document
  Map<String, dynamic> toJson() {
    return {
      'eventDate': eventDate,
      'title': title,
      'description': description,
      'place': place,
      'imageURL': imageURL,
    };
  }

 }
