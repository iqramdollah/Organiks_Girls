import 'package:cloud_firestore/cloud_firestore.dart';

class Match {
  final String id;
  final DateTime date;
  final String title;
  final int goals;
  final int assists;
  final int yellowCards;
  final int redCards;

  Match({
    required this.id,
    required this.date,
    required this.title,
    required this.goals,
    required this.assists,
    required this.yellowCards,
    required this.redCards,
  });

  // Deserialize from Firestore (for storing in Performance collection)
  factory Match.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Match(
      id: doc.id, // Use the document ID for the match
      date:
          (data['datetime'] as Timestamp)
              .toDate(), // Correctly convert to DateTime
      title:
          data['title'] ?? 'Unknown Opponent', // Default if no title is found
      goals: data['goals'] ?? 0,
      assists: data['assists'] ?? 0,
      yellowCards:
          data['yellow_cards'] ??
          0, // Ensure this matches the Firestore field name
      redCards:
          data['red_cards'] ??
          0, // Ensure this matches the Firestore field name
    );
  }

  // Serialize to Firestore
  Map<String, dynamic> toMap() {
    return {
      'datetime': Timestamp.fromDate(date),
      'title': title,
      'goals': goals,
      'assists': assists,
      'yellow_cards':
          yellowCards, // Ensure this matches the Firestore field name
      'red_cards': redCards, // Ensure this matches the Firestore field name
    };
  }
}
