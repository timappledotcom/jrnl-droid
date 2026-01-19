import 'dart:io';
import 'package:flutter/widgets.dart'; // Add for BuildContext
import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart'; // Import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class FileService {
  static const String _prefKey = 'journal_file_path';
  
  Future<String?> getSavedPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey);
  }

  Future<void> clearSavedPath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
       // Android 11+ (API 30+) requires MANAGE_EXTERNAL_STORAGE for All Files Access.
       // Without this, we can only read/write to MediaStore managed files, 
       // but User selected files via existing path might be restricted if not in scoped storage.
       // Since the goal is syncing a "journal.txt" in an arbitrary folder (Documents, Syncthing folder),
       // Manage External Storage is the most reliable way to ensure we can WRITE to that specific file path.
       
       if (await Permission.manageExternalStorage.isGranted) {
         return true;
       }
       
       if (await Permission.manageExternalStorage.request().isGranted) {
         return true;
       }

       // Fallback for older Android versions
       var status = await Permission.storage.status;
       if (!status.isGranted) {
         status = await Permission.storage.request();
       }
       return status.isGranted;
    }
    return true;
  }

  Future<String?> pickJournalFile(BuildContext context) async {
    if (Platform.isAndroid) {
       // Check permissions again just in case
       if (!await requestPermissions()) return null;

       Directory rootPath = Directory('/storage/emulated/0');
       
       String? path = await FilesystemPicker.open(
        title: 'Select Journal File',
        context: context,
        rootDirectory: rootPath,
        fsType: FilesystemType.file,
        allowedExtensions: ['.txt', '.md', '.journal'],
        fileTileSelectMode: FileTileSelectMode.wholeTile,
      );
      
      if (path != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefKey, path);
        return path;
      }
      return null;
    }
    
    // Fallback for non-Android logic (unlikely to be hit given context)
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, path);
      return path;
    }
    return null;
  }

  Future<String> readFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.readAsString();
    }
    throw Exception("File not found");
  }

  Future<void> appendToFile(String path, String text) async {
    final file = File(path);
    if (await file.exists()) {
      // Append mode
      await file.writeAsString(text, mode: FileMode.append, flush: true);
    } else {
      throw Exception("File not found");
    }
  }
}
