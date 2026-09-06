import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';

class StaticInfoScreen extends StatelessWidget {
  final String pageTitle;
  
  const StaticInfoScreen({super.key, required this.pageTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: Text(pageTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _getContent(pageTitle),
      ),
    );
  }

  // Yahan har page ka content decide hoga
  Widget _getContent(String title) {
    switch (title) {
      case 'Privacy Policy':
        return _buildTextContent([
          'Last updated: April 2026',
          'Prompt MB respects your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
          '1. Information We Collect: We collect account information (Email/Name) and usage data (liked prompts, search queries).',
          '2. Device Data & Advertising: We use Google AdMob which may collect device identifiers. We do not collect precise location data.',
          '3. How We Use Your Information: To manage your account, improve the app, display ads, and send push notifications.',
          '4. Data Deletion: You can delete your account and associated data at any time via Account Management > Delete Account.',
          'Contact us at: support@appbees.in',
        ]);
      case 'Terms of Service':
        return _buildTextContent([
          'Last updated: April 2026',
          'By downloading or using the Prompt MB app, you agree to these terms.',
          '1. User Accounts: You are responsible for maintaining the confidentiality of your account credentials.',
          '2. User-Generated Content (UGC): Objectionable content (hate speech, explicit material, illegal content) is strictly prohibited.',
          '3. Advertisements: The app may contain advertisements served by third parties.',
          'Contact us at: support@appbees.in',
        ]);
      case 'About Us':
        return _buildTextContent([
          'About Prompt MB',
          'Prompt MB is your premium curated collection of AI prompts designed to help you get the most out of tools like ChatGPT, Gemini, and Midjourney.',
          'Mission: We aim to democratize AI mastery by helping users discover, save, and organize high-quality prompts.',
          'Version 1.0.0',
          '© 2026 Prompt MB Team',
          'Contact: support@appbees.in',
        ]);
      case 'Contact Us':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Get in Touch', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("We'd love to hear from you. Choose your preferred method of contact below.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => _launchEmail(),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.email, color: AppTheme.neonPurple),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('support@appbees.in', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      default:
        return const Text('Content not found', style: TextStyle(color: Colors.white));
    }
  }

  Widget _buildTextContent(List<String> paragraphs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(p, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
      )).toList(),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(scheme: 'mailto', path: 'support@appbees.in');
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
}
