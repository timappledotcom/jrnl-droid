import 'package:intl/intl.dart';

class JournalEntry {
  final DateTime timestamp;
  final String title;
  final String body;

  JournalEntry({
    required this.timestamp,
    required this.title,
    required this.body,
  });

  String get fullText => '$title$body';

  // Helper to format for display
  String get formattedDate => DateFormat('yyyy-MM-dd HH:mm').format(timestamp);
  
  // Helper to format for display (Friendly)
  String get friendlyDate => DateFormat.yMMMd().add_jm().format(timestamp);

  @override
  String toString() {
    return 'JournalEntry(timestamp: $timestamp, title: $title, body: $body)';
  }
}
