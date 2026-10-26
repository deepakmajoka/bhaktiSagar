class Aarti {
  final String title;
  final String category;
  final String lyrics;
  bool isFavorite; // Favorite state track karne ke liye

  Aarti({
    required this.title,
    required this.category,
    required this.lyrics,
    this.isFavorite = false,
  });
}