import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/library_service.dart';
import 'player_screen.dart';
import 'playlists_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _loading = true;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await LibraryService.instance.load();
    setState(() => _loading = false);
  }

  Future<void> _import() async {
    setState(() => _importing = true);
    try {
      await LibraryService.instance.importFromFiles();
    } finally {
      setState(() => _importing = false);
    }
  }

  Future<void> _confirmDelete(MediaItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text('Supprimer "${item.title}" de la bibliothèque ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirm == true) {
      await LibraryService.instance.removeItem(item.id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = LibraryService.instance.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma bibliothèque'),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music),
            tooltip: 'Playlists',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlaylistsScreen()),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      "Aucun fichier importé.\nAppuie sur + pour ajouter de la musique ou des vidéos.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: Icon(
                        item.kind == MediaKind.video ? Icons.movie : Icons.music_note,
                      ),
                      title: Text(item.title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(item),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayerScreen(queue: items, startIndex: index),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _importing ? null : _import,
        child: _importing
            ? const SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.add),
      ),
    );
  }
}
