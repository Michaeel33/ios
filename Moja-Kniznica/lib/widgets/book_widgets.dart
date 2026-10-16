import 'package:flutter/material.dart';
import '../models/book.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final ReadingStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ReadingStatus.planned => const Color(0xFF82602D),
      ReadingStatus.reading => const Color(0xFF365B97),
      ReadingStatus.finished => const Color(0xFF275C4D),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status.label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class BookCover extends StatelessWidget {
  const BookCover({super.key, required this.book, this.size = 72});
  final Book book;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = switch (book.status) {
      ReadingStatus.planned => const Color(0xFF82602D),
      ReadingStatus.reading => const Color(0xFF365B97),
      ReadingStatus.finished => const Color(0xFF275C4D),
    };
    return Container(
      width: size, height: size * 1.35,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Icon(Icons.menu_book_rounded, color: Colors.white, size: size * 0.5),
    );
  }
}

class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.book, required this.onTap});
  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            BookCover(book: book),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(book.author),
                const SizedBox(height: 10),
                StatusBadge(status: book.status),
                if (book.rating > 0) ...[
                  const SizedBox(height: 8),
                  Text('★ ${book.rating}/5', style: const TextStyle(color: Color(0xFF82602D))),
                ],
              ],
            )),
            const Icon(Icons.chevron_right),
          ]),
        ),
      ),
    );
  }
}
