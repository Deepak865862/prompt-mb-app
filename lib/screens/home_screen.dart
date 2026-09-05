import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import '../models/prompt.dart';
import '../services/api_service.dart';
import 'customization_screen.dart';
import 'profile_screen.dart';
import 'premium_screen.dart';
import 'add_prompt_screen.dart';
import '../services/ad_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Prompt> _allPrompts = [];
  List<Prompt> _filteredPrompts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMoreData = true;
  String _selectedCategory = 'All';
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadPrompts();
    _scrollController.addListener(_onScroll);
    
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animController);
  }

  Future<void> _loadPrompts({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
        _allPrompts = [];
      });
    }

    if (_isLoadingMore || !_hasMoreData) return;
    setState(() => _isLoadingMore = true);

    try {
      final newPrompts = await _apiService.fetchPrompts(page: _currentPage);
      if (mounted) {
        setState(() {
          if (isRefresh) { _allPrompts = newPrompts; } 
          else { _allPrompts.addAll(newPrompts); }
          _filteredPrompts = _allPrompts;
          _currentPage++;
          _isLoading = false;
          _isLoadingMore = false;
          if (newPrompts.length < 20) { _hasMoreData = false; }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; _isLoadingMore = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoading && _hasMoreData) { _loadPrompts(); }
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredPrompts = List.from(_allPrompts);
      } else {
        _filteredPrompts = _allPrompts.where((prompt) {
          return prompt.tags.any((tag) => tag.toLowerCase() == category.toLowerCase());
        }).toList();
      }
    });
  }

  void _searchPrompts(String query) {
    setState(() {
      if (query.isEmpty) { _filterByCategory(_selectedCategory); } 
      else {
        _filteredPrompts = _allPrompts.where((prompt) {
          return prompt.title.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void dispose() { 
    _scrollController.dispose(); 
    _animController.dispose();
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(children: [
          Icon(Icons.auto_awesome, color: Color(0xFF00E5FF), shadows: [Shadow(color: Color(0xFF00E5FF), blurRadius: 10)]),
          SizedBox(width: 8),
          Text('Prompt MB', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ]),
        actions: [
          GestureDetector(onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumScreen())); }, 
            child: Container(margin: const EdgeInsets.only(right: 16), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
              decoration: BoxDecoration(color: const Color(0xFF00E5FF).withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF00E5FF))), 
              child: const Text('₹19/mo', style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 12)))),
          IconButton(icon: const Icon(Icons.person_outline, color: Colors.white), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())); }),
        ],
      ),
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00E5FF),
        onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPromptScreen())); },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            children: [
              // Animated Gradient Background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0A0A0A),
                        Color.lerp(const Color(0xFF001F3F), const Color(0xFF003366), _animation.value)!,
                        const Color(0xFF0A0A0A),
                      ],
                    ),
                  ),
                ),
              ),
              // Glowing Orbs
              Positioned(
                top: -50 + (_animation.value * 100),
                left: -50,
                child: Container(
                  width: 200, height: 200, 
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, 
                    color: const Color(0xFF00E5FF).withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withOpacity(0.5),
                        blurRadius: 80,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -50 + (_animation.value * 100),
                right: -50,
                child: Container(
                  width: 200, height: 200, 
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, 
                    color: const Color(0xFF00E5FF).withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withOpacity(0.5),
                        blurRadius: 80,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Main Content
              Column(
                children: [
                  const SizedBox(height: 90), 
                  
                  // Categories (Glassmorphism & Neon)
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: ['All', 'Couple', 'Kids', 'Boy', 'Girl'].map((cat) {
                        final isSelected = cat == _selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => _filterByCategory(cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF00E5FF) : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? const Color(0xFF00E5FF) : Colors.white.withOpacity(0.1)),
                                boxShadow: isSelected ? [const BoxShadow(color: Color(0xFF00E5FF), blurRadius: 15, spreadRadius: 2)] : [],
                              ),
                              child: Text(cat, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Search Bar (Glassmorphism)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: TextField(
                            onChanged: _searchPrompts,
                            decoration: InputDecoration(
                              hintText: 'Search AI Prompts...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                              filled: false,
                              border: InputBorder.none,
                              prefixIcon: const Icon(Icons.search, color: Colors.white54),
                              contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Grid
                  Expanded(
                    child: _isLoading && _allPrompts.isEmpty 
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))) 
                      : _filteredPrompts.isEmpty 
                        ? const Center(child: Text('No prompts found', style: TextStyle(color: Colors.white54))) 
                        : NotificationListener<OverscrollIndicatorNotification>(
                            onNotification: (overScroll) { overScroll.disallowIndicator(); return true; },
                            child: MasonryGridView.count(
                              controller: _scrollController, crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, padding: const EdgeInsets.all(16),
                              itemCount: _filteredPrompts.length + (_hasMoreData ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _filteredPrompts.length) { return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))); }
                                final prompt = _filteredPrompts[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => CustomizationScreen(prompt: prompt)));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white.withOpacity(0.05),
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                      boxShadow: [BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.1), blurRadius: 10, spreadRadius: 1)],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: prompt.imageUrl, width: double.infinity, fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(height: 200, color: Colors.grey[900], child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00E5FF)))),
                                            errorWidget: (context, url, error) => Container(height: 200, color: Colors.grey[900], child: const Icon(Icons.broken_image, color: Colors.grey)),
                                          ),
                                          Padding(padding: const EdgeInsets.all(10.0), child: Text(prompt.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  
                  // Banner Ad Section (Sabse Neeche)
                  if (!kIsWeb && AdService.bannerAdUnitId.isNotEmpty)
                    Container(
                      color: Colors.black,
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AdService.getBannerAdWidget(),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}