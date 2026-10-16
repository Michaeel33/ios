import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/library_provider.dart';
import '../widgets/book_widgets.dart';
import 'book_detail_screen.dart';
import 'book_form_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  Future<void> _addBook(BuildContext context) async {
    final saved = await Navigator.push<bool>(
      context, MaterialPageRoute(builder: (_) => const BookFormScreen()),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kniha bola pridaná do knižnice.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, library, child) => Scaffold(
        appBar: AppBar(title: const Text('Moja knižnica')),
        floatingActionButton: library.loading || library.loadError != null
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _addBook(context),
                icon: const Icon(Icons.add),
                label: const Text('Pridať knihu'),
              ),
        body: library.loading
            ? const Center(child: CircularProgressIndicator())
            : library.loadError != null
                ? Center(child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.folder_off_outlined, size: 52),
                      const SizedBox(height: 16),
                      Text(library.loadError!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: library.load, child: const Text('Skúsiť znova')),
                    ]),
                  ))
                : Center(child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 780),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                      children: [
                        const Text('Tvoj ďalší príbeh\nzačína tu.', style: TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF213B32),
                        )),
                        const SizedBox(height: 12),
                        Text('Knihy: ${library.books.length}  •  Prečítané: ${library.finishedCount}',
                          style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 24),
                        TextField(
                          onChanged: library.setQuery,
                          decoration: const InputDecoration(
                            hintText: 'Hľadať názov alebo autora',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          ChoiceChip(
                            label: const Text('Všetky'),
                            selected: library.filter == null,
                            onSelected: (_) => library.setFilter(null),
                          ),
                          ...ReadingStatus.values.map((status) => ChoiceChip(
                            label: Text(status.label),
                            selected: library.filter == status,
                            onSelected: (_) => library.setFilter(status),
                          )),
                        ]),
                        const SizedBox(height: 24),
                        if (library.visibleBooks.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(children: [
                              const Icon(Icons.menu_book_outlined, size: 60, color: Color(0xFF275C4D)),
                              const SizedBox(height: 16),
                              Text(
                                library.books.isEmpty ? 'Zatiaľ tu nie sú žiadne knihy.' : 'Žiadna kniha nezodpovedá filtru.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18),
                              ),
                              if (library.books.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text('Začni tlačidlom Pridať knihu.'),
                                ),
                            ]),
                          ),
                        ...library.visibleBooks.map((book) => BookCard(
                          book: book,
                          onTap: () => Navigator.push<void>(
                            context,
                            MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: book.id)),
                          ),
                        )),
                      ],
                    ),
                  )),
      ),
    );
  }
}
