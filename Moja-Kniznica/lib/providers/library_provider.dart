import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../services/library_storage.dart';

class LibraryProvider extends ChangeNotifier {
  LibraryProvider(this._storage);
  final LibraryStorage _storage;
  List<Book> _books = [];
  bool _loading = true;
  bool _saving = false;
  bool _disposed = false;
  bool _loadRunning = false;
  String? _loadError;
  String? _saveError;
  String _query = '';
  ReadingStatus? _filter;
  int _sequence = 0;

  UnmodifiableListView<Book> get books => UnmodifiableListView(_books);
  bool get loading => _loading;
  bool get saving => _saving;
  String? get loadError => _loadError;
  String? get saveError => _saveError;
  ReadingStatus? get filter => _filter;
  int get finishedCount => _books.where((b) => b.status == ReadingStatus.finished).length;
  List<Book> get visibleBooks => _books.where((book) {
    final text = '${book.title} ${book.author}'.toLowerCase();
    return (_filter == null || book.status == _filter) && text.contains(_query);
  }).toList();

  Book? findById(String id) {
    for (final book in _books) {
      if (book.id == id) return book;
    }
    return null;
  }

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    if (_loadRunning) return;
    _loadRunning = true;
    _loading = true;
    _loadError = null;
    _changed();
    try {
      _books = await _storage.read();
    } catch (_) {
      _loadError = 'Knižnicu sa nepodarilo načítať. Tvoje súbory zostali nezmenené.';
    }
    _loading = false;
    _loadRunning = false;
    _changed();
  }

  void setQuery(String value) {
    _query = value.trim().toLowerCase();
    _changed();
  }

  void setFilter(ReadingStatus? value) {
    _filter = value;
    _changed();
  }

  Future<bool> _commit(List<Book> next) async {
    if (_loading || _saving || _loadError != null) return false;
    _saving = true;
    _saveError = null;
    _changed();
    try {
      await _storage.write(next);
      _books = next;
      return true;
    } catch (_) {
      _saveError = 'Uloženie zlyhalo. Zmena nebola potvrdená, skús to znova.';
      return false;
    } finally {
      _saving = false;
      _changed();
    }
  }

  Future<bool> saveBook({
    String? id,
    required String title,
    required String author,
    required ReadingStatus status,
    required int rating,
    required String notes,
  }) async {
    if (title.trim().isEmpty || author.trim().isEmpty || rating < 0 || rating > 5) {
      return false;
    }
    final book = Book(
      id: id ?? '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}',
      title: title.trim(), author: author.trim(),
      status: status, rating: rating, notes: notes.trim(),
    );
    final next = List<Book>.of(_books);
    if (id == null) {
      next.insert(0, book);
    } else {
      final index = next.indexWhere((item) => item.id == id);
      if (index == -1) return false;
      next[index] = book;
    }
    return _commit(next);
  }

  Future<bool> removeBook(String id) {
    return _commit(_books.where((book) => book.id != id).toList());
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
