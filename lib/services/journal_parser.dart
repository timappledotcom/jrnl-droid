import 'package:intl/intl.dart';
import '../models/entry.dart';

class JournalParser {
  static final RegExp _timestampRegex = RegExp(r'^\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}(?: [AP]M)?)\]\s+|^(\d{4}-\d{2}-\d{2} \d{2}:\d{2})\s+');
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  /// Parses the entire journal file content into a list of [JournalEntry].
  static List<JournalEntry> parse(String content) {
    print('DEBUG: Parsing content of length: ${content.length}');
    final List<JournalEntry> entries = [];
    final List<String> lines = content.split('\n');
    print('DEBUG: Split into ${lines.length} lines');
    
    DateTime? currentTimestamp;
    StringBuffer currentBuffer = StringBuffer();

    void flushEntry() {
      if (currentTimestamp != null) {
        final fullText = currentBuffer.toString().trim();
        if (fullText.isNotEmpty) {
          final (title, body) = _splitTitleAndBody(fullText);
          entries.add(JournalEntry(
            timestamp: currentTimestamp,
            title: title,
            body: body,
          ));
        }
      }
    }

    for (var line in lines) {
      final match = _timestampRegex.firstMatch(line);
      if (match != null) {
        print('DEBUG: Found timestamp match: ${match.group(0)}');
        // Start of a new entry, flush the previous one
        flushEntry();

        // Reset for new entry
        try {
          String dateString = match.group(1) ?? match.group(2)!;
          // Try parsing with flexible formats since jrnl can vary
          currentTimestamp = _tryParseDate(dateString);
          
          // Add the rest of the line (after timestamp) to the buffer
          currentBuffer = StringBuffer();
          currentBuffer.writeln(line.substring(match.end));
        } catch (e) {
          print('DEBUG: Date parse error: $e');
          // If date parsing fails, treat it as part of previous body? 
          // For now, let's assume strict format or ignore.
          // Fallback: just append to previous if exists
           if (currentTimestamp != null) {
             currentBuffer.writeln(line);
           }
        }
      } else {
        // Continuation of previous entry
        if (currentTimestamp != null) {
          currentBuffer.writeln(line);
        }
      }
    }
    // Flush the last entry
    flushEntry();

    // Sort entries descending (newest first)
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return entries;
  }

  /// Helper to split title and body based on the first sentence ending.
  static (String, String) _splitTitleAndBody(String text) {
    // Naive implementation: find first ., ?, or !
    // We need to be careful not to split on abbreviations if possible, but for minimal reqs:
    final match = RegExp(r'[\.\?\!](?=\s|$)').firstMatch(text);
    
    if (match != null) {
      final end = match.end;
      final title = text.substring(0, end);
      final body = text.substring(end);
      return (title, body);
    }
    
    // If no punctuation found, check if there are newlines.
    // If so, treat the first line as the title (common jrnl behavior for non-sentence titles).
    final newlineIndex = text.indexOf('\n');
    if (newlineIndex != -1) {
      final title = text.substring(0, newlineIndex);
      final body = text.substring(newlineIndex); // Includes the newline
      return (title, body);
    }

    // If no sentence end found and no keyline, treat whole text as title.
    return (text, '');
  }

  /// Formats a new entry string to be appended to the file.
  static String formatEntry(DateTime timestamp, String text) {
    // Match the user's existing format: [yyyy-MM-dd HH:mm:ss a]
    final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss a').format(timestamp);
    
    // Prepend a newline to ensure visual separation from the previous entry.
    // This handles cases where the previous entry only ends with a single newline.
    // We end with a single newline so that the next entry's leading newline creates the blank line.
    return '\n[$dateStr] $text\n';
  }

  static DateTime _tryParseDate(String dateString) {
    final formats = [
      DateFormat('yyyy-MM-dd HH:mm'),
      DateFormat('yyyy-MM-dd HH:mm:ss a'), // Matches [2026-01-18 08:11:44 PM]
      DateFormat('yyyy-MM-dd HH:mm:ss'),
    ];

    for (var format in formats) {
      try {
        return format.parse(dateString);
      } catch (_) {}
    }
    // If all fail, throw the last error or a generic one
    throw FormatException("Could not parse date: $dateString");
  }
}
