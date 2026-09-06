import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'creator_landing_screen.dart';
import 'subscription_screen.dart';
import 'static_info_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 40, backgroundColor: AppTheme.neonPurple, child: Icon(Icons.person, size: 40, color: Colors.white)),
          const SizedBox(height: 12),
          const Center(child: Text('Guest User 1393', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
          const Center(child: Text('guest_user@promptmb.app', style: TextStyle(color: Colors.grey, fontSize: 14))),
          const SizedBox(height: 20),

          Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.neonPurple, AppTheme.neonPink]), borderRadius: BorderRadius.circular(12)),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionScreen())),
              child: const Center(child: Text('Go Premium - Remove Ads', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
            ),
          ),
          const SizedBox(height: 24),

          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatorLandingScreen())),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.neonBlue.withOpacity(0.3))),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.neonBlue.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.monetization_on, color: AppTheme.neonBlue)),
                  const SizedBox(width: 16),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Become a Creator', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4), Text('Start earning from your prompts!', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ])),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          _buildListTile(context, 'My Orders', Icons.shopping_bag),
          _buildListTile(context, 'Account Management', Icons.manage_accounts),
          _buildListTile(context, 'Privacy Policy', Icons.privacy_tip, 'Privacy Policy'),
          _buildListTile(context, 'Terms of Service', Icons.description, 'Terms of Service'),
          _buildListTile(context, 'About Us', Icons.info_outline, 'About Us'),
          _buildListTile(context, 'Contact Us', Icons.contact_mail, 'Contact Us'),
          _buildListTile(context, 'Rate Us', Icons.star_outline),
          
          const Divider(color: Colors.grey, height: 30),
          const Center(child: Text('Version 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12))),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon, [String? screenName]) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: () {
        if (screenName != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => StaticInfoScreen(pageTitle: screenName)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title clicked')));
        }
      },
    );
  }
}
