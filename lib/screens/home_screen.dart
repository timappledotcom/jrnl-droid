import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';
import 'compose_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search entries...',
                  border: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
                onChanged: (value) {
                  Provider.of<JournalProvider>(context, listen: false)
                      .search(value);
                },
              )
            : const Text('jrnl'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  Provider.of<JournalProvider>(context, listen: false).search('');
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Journal',
            onPressed: () {
              Provider.of<JournalProvider>(context, listen: false).loadJournal();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'disconnect') {
                Provider.of<JournalProvider>(context, listen: false).disconnectFile();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'disconnect',
                child: Text('Disconnect File'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<JournalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.loadJournal,
                    child: const Text('Retry'),
                  ),
                   const SizedBox(height: 8),
                   TextButton(onPressed: provider.disconnectFile, child: const Text("Select Different File"))
                ],
              ),
            );
          }

          if (provider.currentFilePath == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No Journal File Selected'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.pickJournalFile(context),
                    child: const Text('Select journal.txt'),
                  ),
                ],
              ),
            );
          }

          if (provider.entries.isEmpty) {
            return const Center(child: Text('No entries found.'));
          }

          return ListView.separated(
            itemCount: provider.entries.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = provider.entries[index];
              return ListTile(
                title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  entry.body.trim().split('\n').first, // Preview first line of body
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(entry.friendlyDate, style: Theme.of(context).textTheme.bodySmall),
                onTap: () {
                  // Show full entry detail?
                  // For now, just a dialog or maybe expand
                  showDialog(context: context, builder: (context) => AlertDialog(
                    title: Text(entry.formattedDate),
                    content: SingleChildScrollView(
                      child: SelectableText(entry.fullText),
                    ),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
                  ));
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<JournalProvider>(
        builder: (context, provider, child) {
           if (provider.currentFilePath != null) {
             return FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ComposeScreen()),
                  );
                },
                child: const Icon(Icons.edit),
              );
           }
           return const SizedBox.shrink();
        },
      ),
    );
  }
}
