import 'package:flutter/material.dart';
import '../config/theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = ['Anime Girl', 'Cinematic Portrait', 'Cyberpunk City', '3D Character'];
  final List<String> _suggestions = ['Anime Boy', 'Watercolor', 'Oil Painting', 'Fantasy', 'Sci-Fi', 'Realistic'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search AI Prompts...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              // Yahan baad mein real-time search logic aayega
            },
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Recent Searches
          const Text('Recent Searches', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((search) {
              return Chip(
                label: Text(search, style: const TextStyle(color: Colors.white)),
                backgroundColor: AppTheme.cardBg,
                deleteIcon: const Icon(Icons.close, color: Colors.grey, size: 18),
                onDeleted: () {
                  setState(() {
                    _recentSearches.remove(search);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Trending Suggestions
          const Text('Trending Prompts', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._suggestions.map((suggestion) {
            return ListTile(
              leading: const Icon(Icons.trending_up, color: AppTheme.neonBlue),
              title: Text(suggestion, style: const TextStyle(color: Colors.white)),
              onTap: () {
                _searchController.text = suggestion;
                // Yahan search results dikhayenge
              },
            );
          }),
        ],
      ),
    );
  }
}
