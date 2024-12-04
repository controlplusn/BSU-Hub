import 'package:flutter/material.dart';

class EventDescriptionPage extends StatelessWidget {
  final Event event;

  const EventDescriptionPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar for the flexible app bar with an image
          SliverAppBar(
            expandedHeight: 250.0, // Height of the app bar when expanded
            floating: false,
            pinned: true, // Makes the app bar stay at the top when scrolling
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                event.imageURL, // Event image
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              event.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // SliverList to contain the body content that scrolls
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Text(
                        event.eventDate,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      Text(
                        event.description,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Location: ${event.place}',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
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

class Event {
  final String title;
  final String description;
  final String eventDate;
  final String imageURL;
  final String place;

  Event({
    required this.title,
    required this.description,
    required this.eventDate,
    required this.imageURL,
    required this.place,
  });
}