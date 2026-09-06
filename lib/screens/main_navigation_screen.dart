import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Abhi ke liye sirf Home Screen active hai, baaki screens baad mein banayenge
  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('Explore Screen (Coming Soon)', style: TextStyle(color: Colors.white, fontSize: 18))),
    const Center(child: Text('Become a Creator (Coming Soon)', style: TextStyle(color: Colors.white, fontSize: 18))),
    const Center(child: Text('Profile Screen (Coming Soon)', style: TextStyle(color: Colors.white, fontSize: 18))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          border: Border(top: BorderSide(color: AppTheme.neonPurple.withOpacity(0.3), width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: AppTheme.neonPurple,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 38, color: AppTheme.neonPink), 
              label: 'Creator'
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
