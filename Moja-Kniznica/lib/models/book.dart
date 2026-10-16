enum ReadingStatus {
  planned('Chcem čítať'),
  reading('Čítam'),
  finished('Prečítané');

  const ReadingStatus(this.label);
  final String label;
}

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.status = ReadingStatus.planned,
    this.rating = 0,
    this.notes = '',
  });

  final String id;
  final String title;
  final String author;
  final ReadingStatus status;
  final int rating;
  final String notes;

  Book copyWith({
    String? title,
    String? author,
    ReadingStatus? status,
    int? rating,
    String? notes,
  }) => Book(
    id: id,
    title: title ?? this.title,
    author: author ?? this.author,
    status: status ?? this.status,
    rating: rating ?? this.rating,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'status': status.name,
    'rating': rating,
    'notes': notes,
  };

  factory Book.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final author = json['author'];
    final rating = json['rating'];
    final notes = json['notes'];
    if (id is! String || id.isEmpty ||
        title is! String || title.trim().isEmpty ||
        author is! String || author.trim().isEmpty ||
        rating is! int || rating < 0 || rating > 5 ||
        notes is! String) {
      throw const FormatException('Neplatné údaje knihy.');
    }
    final status = ReadingStatus.values.where((s) => s.name == json['status']);
    if (status.isEmpty) throw const FormatException('Neplatný stav čítania.');
    return Book(id: id, title: title, author: author,
      status: status.single, rating: rating, notes: notes);
  }
}
