import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/events.dart';

const String EVENT_COLLECTION_REF = "events"; // collection name

class DatabaseService{
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _eventsRef;

  DatabaseService(){
    _eventsRef = _firestore.collection(EVENT_COLLECTION_REF).withConverter<Event>(
        fromFirestore: (snapshots,_) => Event.fromJson(snapshots.data()!),
        toFirestore: (event,_) => event.toJson());
  }

  Stream<QuerySnapshot> getEvents(){
    return _eventsRef.snapshots();
  }

  void addEvent(Event event) async {
    _eventsRef.add(event);
  }

  void updateEvent(String eventId, Event event){
    _eventsRef.doc(eventId).update(event.toJson());
  }
}