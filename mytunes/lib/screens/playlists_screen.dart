import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/library_service.dart';
import 'player_screen.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  Future<void> _createPlaylist() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nom de la playlist'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Créer'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await LibraryService.instance.createPlaylist(name);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlists = LibraryService.instance.playlists;
    return Scaffold(
      appBar: AppBar(title: const Text('Playlists')),
      body: playlists.isEmpty
          ? const Center(child: Text('Aucune playlist. Appuie sur + pour en créer une.'))
          : ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return ListTile(
                  title: Text(playlist.name),
                  subtitle: Text('${playlist.itemIds.length} élément(s)'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaylistDetailScreen(playlistId: playlist.id),
                      ),
                    ).then((_) => setState(() {}));
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await LibraryService.instance.deletePlaylist(playlist.id);
                      setState(() {});
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPlaylist,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  Future<void> _addItems() async {
    final allItems = LibraryService.instance.items;
    final playlist =
        LibraryService.instance.playlists.firstWhere((p) => p.id == widget.playlistId);

    final selected = await showDialog<List<String>>(
      context: context,
      builder: (ctx) {
        final tempSelected = Set<String>.from(playlist.itemIds);
        return StatefulBuilder(
          builder: (ctx, setStateDialog) => AlertDialog(
            title: const Text('Ajouter des morceaux'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: allItems.map((item) {
                  return CheckboxListTile(
                    title: Text(item.title),
                    value: tempSelected.contains(item.id),
                    onChanged: (checked) {
                      setStateDialog(() {
                        if (checked == true) {
                          tempSelected.add(item.id);
                        } else {
                          tempSelected.remove(item.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, tempSelected.toList()),
                child: const Text('Valider'),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      playlist.itemIds = selected;
      for (final id in selected) {
        await LibraryService.instance.addToPlaylist(playlist.id, id);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlist =
        LibraryService.instance.playlists.firstWhere((p) => p.id == widget.playlistId);
    final items = playlist.itemIds
        .map((id) => LibraryService.instance.findItem(id))
        .where((e) => e != null)
        .cast<MediaItem>()
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(playlist.name)),
      body: items.isEmpty
          ? const Center(child: Text('Playlist vide. Appuie sur + pour ajouter des morceaux.'))
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
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () async {
                      await LibraryService.instance.removeFromPlaylist(playlist.id, item.id);
                      setState(() {});
                    },
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
        onPressed: _addItems,
        child: const Icon(Icons.add),
      ),
    );
  }
}
