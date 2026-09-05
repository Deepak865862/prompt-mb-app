class Prompt {
  final int id;
  final String title;
  final String promptText;
  final String imageUrl;
  final List<String> tags; // Naya field tags ke liye

  Prompt({
    required this.id,
    required this.title,
    required this.promptText,
    required this.imageUrl,
    required this.tags,
  });
}