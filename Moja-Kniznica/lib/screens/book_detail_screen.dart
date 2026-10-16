import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/library_provider.dart';
import '../widgets/book_widgets.dart';
import 'book_form_screen.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.bookId});
  final String bookId;

  Future<void> _delete(BuildContext context, Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Odstrániť knihu?'),
        content: Text('Kniha „${book.title}“ sa odstráni z tvojej knižnice.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Zrušiť')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Odstrániť')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final library = context.read<LibraryProvider>();
    final removed = await library.removeBook(book.id);
    if (!context.mounted) return;
    if (removed) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(library.saveError ?? 'Odstránenie zlyhalo.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(builder: (context, library, child) {
      final book = library.findById(bookId);
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail knihy'),
          actions: book == null ? null : [
            IconButton(
              tooltip: 'Upraviť knihu',
              onPressed: library.saving ? null : () => Navigator.push<bool>(
                context, MaterialPageRoute(builder: (_) => BookFormScreen(book: book)),
              ),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        body: book == null
            ? const Center(child: Text('Kniha už nie je v knižnici.'))
            : Center(child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Center(child: BookCover(book: book, size: 140)),
                    const SizedBox(height: 28),
                    Text(book.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(book.author, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 20),
                    Center(child: StatusBadge(status: book.status)),
                    const SizedBox(height: 16),
                    Text(book.rating == 0 ? 'Zatiaľ bez hodnotenia' : '★ ${book.rating} / 5',
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, color: Color(0xFF82602D))),
                    const SizedBox(height: 32),
                    const Text('Moje poznámky', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(book.notes.isEmpty ? 'Ku knihe ešte nemáš poznámky.' : book.notes,
                      style: const TextStyle(fontSize: 17, height: 1.5)),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: library.saving ? null : () => Navigator.push<bool>(
                        context, MaterialPageRoute(builder: (_) => BookFormScreen(book: book)),
                      ),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Upraviť knihu'),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: library.saving ? null : () => _delete(context, book),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Odstrániť z knižnice'),
                    ),
                  ]),
                ),
              )),
      );
    });
  }
}
