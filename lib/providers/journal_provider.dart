import 'package:flutter/foundation.dart';
import '../models/entry.dart';
import '../services/file_service.dart';
import '../services/journal_parser.dart';

import 'package:flutter/widgets.dart'; // Add for BuildContext

class JournalProvider with ChangeNotifier {
  final FileService _fileService = FileService();
  
  List<JournalEntry> _allEntries = [];
  List<JournalEntry> _filteredEntries = [];
  String? _currentFilePath;
  bool _isLoading = false;
  String? _error;

  List<JournalEntry> get entries => _filteredEntries;
  String? get currentFilePath => _currentFilePath;
  bool get isLoading => _isLoading;
  String? get error => _error;

  JournalProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    
    _currentFilePath = await _fileService.getSavedPath();
    if (_currentFilePath != null) {
      await loadJournal();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickJournalFile(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final path = await _fileService.pickJournalFile(context);
      if (path != null) {
        _currentFilePath = path;
        await loadJournal();
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadJournal() async {
    if (_currentFilePath == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Ensure permissions
      await _fileService.requestPermissions();

      final content = await _fileService.readFile(_currentFilePath!);
      print('DEBUG: Read file at $_currentFilePath, length: ${content.length}');
      if (content.length > 500) {
        print('DEBUG: First 500 chars: ${content.substring(0, 500)}');
      } else {
        print('DEBUG: Content: $content');
      }
      _allEntries = JournalParser.parse(content);
      _filteredEntries = List.from(_allEntries);
    } catch (e) {
      print('DEBUG: Error loading journal: $e');
      _error = "Failed to load journal: $e";
      // If file not found, maybe clear path?
      if (e.toString().contains("File not found")) {
        // await _fileService.clearSavedPath();
        // _currentFilePath = null;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEntry(String text) async {
    if (_currentFilePath == null) return;

    try {
      final now = DateTime.now();
      final entryText = JournalParser.formatEntry(now, text);
      await _fileService.appendToFile(_currentFilePath!, entryText);
      
      // Optimistic update or reload?
      // Reload is safer to ensure sync with file state
      await loadJournal();
    } catch (e) {
      _error = "Failed to save entry: $e";
      notifyListeners();
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      _filteredEntries = List.from(_allEntries);
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredEntries = _allEntries.where((entry) {
        return entry.title.toLowerCase().contains(lowerQuery) ||
               entry.body.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }
  
  void resetError() {
    _error = null;
    notifyListeners();
  }
  
  Future<void> disconnectFile() async {
    await _fileService.clearSavedPath();
    _currentFilePath = null;
    _allEntries = [];
    _filteredEntries = [];
    notifyListeners();
  }
}
