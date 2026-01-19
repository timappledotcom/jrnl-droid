# jrnl-droid

**jrnl-droid** is a minimal, open-source Android companion app for [jrnl.sh](https://jrnl.sh). It allows you to read, search, and append to your plain-text journal file directly from your Android device, with support for seamless syncing via tools like Syncthing.

## Features

*   **Plain Text Only**: Works directly with your `journal.txt` file. No databases, no proprietary formats.
*   **Full Parsing**: Correctly parses `jrnl` entries, including timestamps and multi-line bodies.
*   **Search**: Instantly filter entries by keyword.
*   **Append Support**: Quickly add new entries with the correct timestamp format.
*   **Sync Friendly**: Designed to work with Syncthing, Nextcloud, or Dropbox. Changes made on Android are written directly to the file for immediate sync back to your desktop.
*   **Permissions Handling**: Properly requests permissions to edit files in shared storage (Documents, etc.) on modern Android versions.
*   **Dark Mode**: Respects system theme settings.

## Installation

1.  Go to the [Releases](https://github.com/timappledotcom/jrnl-droid/releases) page.
2.  Download the latest `app-release.apk`.
3.  Install the APK on your Android device (you may need to allow installation from unknown sources).

## How to Use

1.  **Sync your Journal**: Use a tool like [Syncthing](https://syncthing.net/) (recommended) to sync your `journal.txt` from your PC to a folder on your Android device (e.g., `/Documents` or a dedicated Journal folder).
2.  **Select File**: Open jrnl-droid and tap "Select journal.txt".
3.  **Grant Permissions**: Accept the "All files access" permission request. This is required to allow the app to write directly to the file on disk so Syncing works correctly.
4.  **Browse & Write**: View your past entries or tap the `+` button to write a new one.

## Timestamp Format

The app currently uses the following timestamp format for new entries, which is compatible with standard `jrnl` configurations:

```text
[yyyy-MM-dd HH:mm:ss a] Entry text...
```

Example:
`[2026-01-19 12:05:00 PM] Went to the store.`

## Development

This is a standard Flutter project.

### Prerequisites
*   Flutter SDK
*   Android Studio / Android SDK

### Build
```bash
flutter pub get
flutter run
```

### Build Release APK
```bash
flutter build apk --release
```

## License

MIT
