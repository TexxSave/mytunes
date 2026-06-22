import 'dart:convert';

enum MediaKind { audio, video }

class MediaItem {
  final String id;
  final String title;
  final String path; // chemin local (après copie dans le dossier de l'app)
  final MediaKind kind;
  final DateTime addedAt;

  MediaItem({
    required this.id,
    required this.title,
    required this.path,
    required this.kind,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'path': path,
        'kind': kind.name,
        'addedAt': addedAt.toIso8601String(),
      };

  factory MediaItem.fromMap(Map<String, dynamic> map) => MediaItem(
        id: map['id'],
        title: map['title'],
        path: map['path'],
        kind: MediaKind.values.firstWhere((k) => k.name == map['kind']),
        addedAt: DateTime.parse(map['addedAt']),
      );

  static String encodeList(List<MediaItem> items) =>
      jsonEncode(items.map((e) => e.toMap()).toList());

  static List<MediaItem> decodeList(String raw) {
    if (raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => MediaItem.fromMap(e)).toList();
  }
}

class Playlist {
  final String id;
  String name;
  List<String> itemIds;

  Playlist({required this.id, required this.name, required this.itemIds});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'itemIds': itemIds,
      };

  factory Playlist.fromMap(Map<String, dynamic> map) => Playlist(
        id: map['id'],
        name: map['name'],
        itemIds: List<String>.from(map['itemIds']),
      );

  static String encodeList(List<Playlist> items) =>
      jsonEncode(items.map((e) => e.toMap()).toList());

  static List<Playlist> decodeList(String raw) {
    if (raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Playlist.fromMap(e)).toList();
  }
}
