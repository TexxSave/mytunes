import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/media_item.dart';

class LibraryService {
  static final LibraryService instance = LibraryService._();
  LibraryService._();

  static const _itemsKey = 'mytunes_items';
  static const _playlistsKey = 'mytunes_playlists';

  List<MediaItem> items = [];
  List<Playlist> playlists = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    items = MediaItem.decodeList(prefs.getString(_itemsKey) ?? '');
    playlists = Playlist.decodeList(prefs.getString(_playlistsKey) ?? '');
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_itemsKey, MediaItem.encodeList(items));
  }

  Future<void> _savePlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playlistsKey, Playlist.encodeList(playlists));
  }

  /// Ouvre le picker de fichiers et importe audio/vidéo dans le dossier de l'app.
  Future<List<MediaItem>> importFromFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'mp3', 'm4a', 'wav', 'aac', 'flac', // audio
        'mp4', 'mov', 'm4v', // vidéo
      ],
    );
    if (result == null) return [];

    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDir.path}/media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final newItems = <MediaItem>[];
    for (final file in result.files) {
      if (file.path == null) continue;
      final ext = (file.extension ?? '').toLowerCase();
      final kind = ['mp4', 'mov', 'm4v'].contains(ext)
          ? MediaKind.video
          : MediaKind.audio;

      final id = const Uuid().v4();
      final destPath = '${mediaDir.path}/$id.$ext';
      await File(file.path!).copy(destPath);

      newItems.add(MediaItem(
        id: id,
        title: file.name.replaceAll('.$ext', ''),
        path: destPath,
        kind: kind,
        addedAt: DateTime.now(),
      ));
    }

    items.addAll(newItems);
    await _saveItems();
    return newItems;
  }

  Future<void> removeItem(String id) async {
    final item = items.firstWhere((e) => e.id == id);
    final file = File(item.path);
    if (await file.exists()) {
      await file.delete();
    }
    items.removeWhere((e) => e.id == id);
    for (final p in playlists) {
      p.itemIds.remove(id);
    }
    await _saveItems();
    await _savePlaylists();
  }

  Future<Playlist> createPlaylist(String name) async {
    final playlist = Playlist(id: const Uuid().v4(), name: name, itemIds: []);
    playlists.add(playlist);
    await _savePlaylists();
    return playlist;
  }

  Future<void> addToPlaylist(String playlistId, String itemId) async {
    final playlist = playlists.firstWhere((p) => p.id == playlistId);
    if (!playlist.itemIds.contains(itemId)) {
      playlist.itemIds.add(itemId);
      await _savePlaylists();
    }
  }

  Future<void> removeFromPlaylist(String playlistId, String itemId) async {
    final playlist = playlists.firstWhere((p) => p.id == playlistId);
    playlist.itemIds.remove(itemId);
    await _savePlaylists();
  }

  Future<void> deletePlaylist(String playlistId) async {
    playlists.removeWhere((p) => p.id == playlistId);
    await _savePlaylists();
  }

  MediaItem? findItem(String id) {
    try {
      return items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
