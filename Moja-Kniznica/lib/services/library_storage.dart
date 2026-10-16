import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import '../models/book.dart';

abstract class LibraryStorage {
  Future<List<Book>> read();
  Future<void> write(List<Book> books);
}

/// Stores a JSON file in the application's private documents directory.
class JsonLibraryStorage implements LibraryStorage {
  JsonLibraryStorage({this.directory});
  final Directory? directory;

  Future<File> _file() async {
    final folder = directory ?? await getApplicationDocumentsDirectory();
    await folder.create(recursive: true);
    return File('${folder.path}/library.json');
  }

  @override
  Future<List<Book>> read() async {
    final file = await _file();
    if (!await file.exists()) return [];
    final json = jsonDecode(await file.readAsString());
    if (json is! Map<String, dynamic> ||
        json['version'] != 1 || json['books'] is! List) {
      throw const FormatException('Neplatný súbor knižnice.');
    }
    final books = (json['books'] as List).map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Neplatná kniha v súbore.');
      }
      return Book.fromJson(item);
    }).toList();
    if (books.map((book) => book.id).toSet().length != books.length) {
      throw const FormatException('Duplicitné ID knihy.');
    }
    return books;
  }

  @override
  Future<void> write(List<Book> books) async {
    final file = await _file();
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'version': 1,
        'books': books.map((book) => book.toJson()).toList(),
      }),
      flush: true,
    );
    // Commit only after the complete new JSON was written.
    await temporary.rename(file.path);
  }
}
