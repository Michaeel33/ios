import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moja_kniznica/main.dart';
import 'package:moja_kniznica/models/book.dart';
import 'package:moja_kniznica/providers/library_provider.dart';
import 'package:moja_kniznica/services/library_storage.dart';

class MemoryStorage implements LibraryStorage {
  List<Book> books = [];
  bool fail = false;
  @override
  Future<List<Book>> read() async => List.of(books);
  @override
  Future<void> write(List<Book> value) async {
    if (fail) throw const FileSystemException('Test failure');
    books = List.of(value);
  }
}

void main() {
  test('JSON survives a new storage instance and preserves Slovak text', () async {
    final directory = await Directory.systemTemp.createTemp('library-test-');
    addTearDown(() => directory.delete(recursive: true));
    final storage = JsonLibraryStorage(directory: directory);
    expect(await storage.read(), isEmpty);
    const book = Book(id: '1', title: 'Knižka', author: 'Žofia',
      status: ReadingStatus.finished, rating: 4, notes: 'Čítanie');
    await storage.write([book]);
    final restored = await JsonLibraryStorage(directory: directory).read();
    expect(restored.single.toJson(), book.toJson());
    await storage.write([book.copyWith(title: 'Nový názov')]);
    expect((await storage.read()).single.title, 'Nový názov');
    await storage.write([]);
    expect(await storage.read(), isEmpty);
  });

  test('Corrupt JSON is reported instead of overwritten', () async {
    final directory = await Directory.systemTemp.createTemp('library-corrupt-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/library.json');
    await file.writeAsString('corrupt data');
    final provider = LibraryProvider(JsonLibraryStorage(directory: directory));
    addTearDown(provider.dispose);
    await provider.load();
    expect(provider.loadError, isNotNull);
    expect(await provider.saveBook(title: 'Book', author: 'Author',
      status: ReadingStatus.planned, rating: 0, notes: ''), isFalse);
    expect(await file.readAsString(), 'corrupt data');
  });

  test('Provider saves, filters, edits and rolls back failed changes', () async {
    final storage = MemoryStorage();
    final provider = LibraryProvider(storage);
    addTearDown(provider.dispose);
    await provider.load();
    expect(await provider.saveBook(title: '  Duna  ', author: 'Frank Herbert',
      status: ReadingStatus.reading, rating: 3, notes: ''), isTrue);
    final id = provider.books.single.id;
    provider.setQuery('herbert');
    expect(provider.visibleBooks.length, 1);
    provider.setFilter(ReadingStatus.finished);
    expect(provider.visibleBooks, isEmpty);
    expect(await provider.saveBook(id: id, title: 'Duna', author: 'Frank Herbert',
      status: ReadingStatus.finished, rating: 5, notes: 'Skvelá'), isTrue);
    expect(provider.visibleBooks.length, 1);
    expect(provider.finishedCount, 1);
    final fresh = LibraryProvider(storage);
    addTearDown(fresh.dispose);
    await fresh.load();
    expect(fresh.books.single.rating, 5);
    storage.fail = true;
    expect(await provider.removeBook(id), isFalse);
    expect(provider.books.length, 1);
    expect(provider.saveError, isNotNull);
    storage.fail = false;
    expect(await provider.removeBook(id), isTrue);
    expect(provider.books, isEmpty);
  });

  testWidgets('Three screens, validation, edit and back navigation work', (tester) async {
    await tester.pumpWidget(LibraryApp(storage: MemoryStorage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pridať knihu'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Uložiť knihu'));
    await tester.tap(find.text('Uložiť knihu'));
    await tester.pumpAndSettle();
    expect(find.text('Zadaj názov knihy.'), findsOneWidget);
    expect(find.text('Zadaj autora.'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Názov knihy'), 'Malý princ');
    await tester.enterText(find.widgetWithText(TextFormField, 'Autor'), 'Antoine de Saint-Exupéry');
    await tester.ensureVisible(find.text('Uložiť knihu'));
    await tester.tap(find.text('Uložiť knihu'));
    await tester.pumpAndSettle();
    expect(find.text('Moja knižnica'), findsOneWidget);
    await tester.tap(find.text('Malý princ'));
    await tester.pumpAndSettle();
    expect(find.text('Detail knihy'), findsOneWidget);
    await tester.tap(find.byTooltip('Upraviť knihu'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Názov knihy'), 'Malý princ – moja kniha');
    await tester.ensureVisible(find.text('Uložiť knihu'));
    await tester.tap(find.text('Uložiť knihu'));
    await tester.pumpAndSettle();
    expect(find.text('Detail knihy'), findsOneWidget);
    expect(find.text('Malý princ – moja kniha'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Moja knižnica'), findsOneWidget);
    expect(find.text('Malý princ – moja kniha'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Small display supports list and scrollable form', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final storage = MemoryStorage();
    storage.books = [const Book(id: '1', title: 'Dlhší názov knihy na malej obrazovke',
      author: 'Spisovateľ s dlhým menom')];
    await tester.pumpWidget(LibraryApp(storage: storage));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(storage.books.single.title));
    await tester.tap(find.text(storage.books.single.title));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Upraviť knihu'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Uložiť knihu'));
    expect(tester.takeException(), isNull);
  });
}
