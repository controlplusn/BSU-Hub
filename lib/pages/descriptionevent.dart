import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDescriptionPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDescriptionPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert eventDate from Timestamp to DateTime
    final eventDate = (event['date_time'] as Timestamp?)?.toDate(); // Change to 'date_time' key

    // Print the event data for debugging purposes
    print('Event: $event');
    print('Event Date: $eventDate'); // Check if the date is being properly parsed

    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 200,
              color: Colors.red.withOpacity(0.1),
              child: Center(
                child: event['image_url'] != null
                    ? Image.network(event['image_url'])
                    : Icon(Icons.event, size: 80, color: Colors.red),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Title
                      Text(
                        event['title'] ?? 'Event Title',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),

                      // Event Date
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              eventDate != null
                                  ? DateFormat('EEEE, MMMM d, yyyy').format(eventDate)
                                  : 'No Date Available',
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),

                      // Event Time
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              eventDate != null
                                  ? DateFormat('h:mm a').format(eventDate)
                                  : 'No Time Available',
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Event Description
                      Text('Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                        event['description'] ?? 'No description available',
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      SizedBox(height: 24),

                      // Event Location
                      Text('Location', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.red),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                event['place'] ?? 'Location not provided',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
