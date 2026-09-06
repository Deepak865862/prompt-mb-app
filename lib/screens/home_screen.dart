import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../config/theme.dart';
import '../widgets/neon_background.dart';
import '../widgets/prompt_card.dart';
import '../models/prompt_model.dart';
import '../services/wordpress_service.dart';
import 'prompt_detail_screen.dart';
import 'search_screen.dart'; // Search screen import kiya

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WordPressService _wpService = WordPressService();
  List<PromptModel> _prompts = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _hasMore = true;

  final List<String> _categories = ['All', 'Boy', 'Girl', 'Kids', 'Couple', 'Nature', 'Anime', '3D Art'];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadPrompts();
  }

  Future<void> _loadPrompts() async {
    if (!_hasMore || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      final newPrompts = await _wpService.fetchPrompts(page: _currentPage);
      setState(() {
        _prompts.addAll(newPrompts);
        _currentPage++;
        if (newPrompts.isEmpty) _hasMore = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeonBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Prompt MB', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                // Search Screen par navigate karna
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
              },
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (bool selected) { setState(() => _selectedCategory = category); },
                      selectedColor: AppTheme.neonPurple,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) _loadPrompts();
                  return true;
                },
                child: _prompts.isEmpty && _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.neonBlue))
                    : MasonryGridView.count(
                        crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, padding: const EdgeInsets.all(8),
                        itemCount: _prompts.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _prompts.length) {
                            return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: AppTheme.neonPurple)));
                          }
                          return PromptCard(
                            prompt: _prompts[index],
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => PromptDetailScreen(prompt: _prompts[index])));
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
