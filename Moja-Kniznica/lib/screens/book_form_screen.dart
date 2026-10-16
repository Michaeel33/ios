import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/library_provider.dart';

class BookFormScreen extends StatefulWidget {
  const BookFormScreen({super.key, this.book});
  final Book? book;

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _author;
  late final TextEditingController _notes;
  late ReadingStatus _status;
  late int _rating;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.book?.title ?? '');
    _author = TextEditingController(text: widget.book?.author ?? '');
    _notes = TextEditingController(text: widget.book?.notes ?? '');
    _status = widget.book?.status ?? ReadingStatus.planned;
    _rating = widget.book?.rating ?? 0;
  }

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final library = context.read<LibraryProvider>();
    final saved = await library.saveBook(
      id: widget.book?.id, title: _title.text, author: _author.text,
      status: _status, rating: _rating, notes: _notes.text,
    );
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(library.saveError ?? 'Knihu sa nepodarilo uložiť.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<LibraryProvider>().saving;
    return PopScope(
      canPop: !saving,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.book == null ? 'Nová kniha' : 'Upraviť knihu')),
        body: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                TextFormField(
                  controller: _title, enabled: !saving,
                  decoration: const InputDecoration(labelText: 'Názov knihy'),
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 120,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Zadaj názov knihy.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _author, enabled: !saving,
                  decoration: const InputDecoration(labelText: 'Autor'),
                  textCapitalization: TextCapitalization.words,
                  maxLength: 100,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Zadaj autora.' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ReadingStatus>(
                  initialValue: _status,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Stav čítania'),
                  items: ReadingStatus.values.map((status) =>
                    DropdownMenuItem(value: status, child: Text(status.label))).toList(),
                  onChanged: saving ? null : (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  initialValue: _rating,
                  decoration: const InputDecoration(labelText: 'Hodnotenie'),
                  items: List.generate(6, (rating) => DropdownMenuItem(
                    value: rating, child: Text(rating == 0 ? 'Bez hodnotenia' : '$rating / 5 ★'),
                  )),
                  onChanged: saving ? null : (value) {
                    if (value != null) setState(() => _rating = value);
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _notes, enabled: !saving,
                  minLines: 3, maxLines: 6, maxLength: 2000,
                  decoration: const InputDecoration(labelText: 'Moje poznámky (nepovinné)'),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: saving ? null : _save,
                  icon: saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check),
                  label: Text(saving ? 'Ukladám…' : 'Uložiť knihu'),
                ),
                const SizedBox(height: 12),
                const Text('Kniha sa uloží do tohto zariadenia.', textAlign: TextAlign.center),
              ]),
            ),
          ),
        )),
      ),
    );
  }
}
