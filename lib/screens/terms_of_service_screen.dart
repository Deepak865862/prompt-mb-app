import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Terms of Service', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('1. Acceptance of Terms', 'By downloading or using the Prompt MB app, you agree to these terms. If you do not agree, do not use the app.'),
            _buildSection('2. Usage License', 'We grant you a revocable, non-exclusive, non-transferable, limited license to download, install, and use the app strictly in accordance with these terms.'),
            _buildSection('3. User Accounts', 'You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately of any unauthorized use. You are responsible for all activities that occur under your account.'),
            _buildSection('4. Content and User-Generated Content (UGC)', 'All prompts and content provided in the app are for informational and educational purposes. We do not guarantee the accuracy, efficacy, or safety of any AI prompts generated or displayed.\n\nWhen submitting User-Generated Content (UGC), you agree to the following rules:\n• Objectionable content - including but not limited to hate speech, bullying, explicit material, sexual content, and illegal content - is strictly prohibited.\n• Abusive behavior toward other users is not tolerated.\n• We reserve the right to review, remove, or modify any UGC that violates these terms at any time without notice.\n• We may suspend or permanently ban the accounts of users who violate these guidelines.\n• By submitting UGC, you also grant us the right to use high-performing posts to promote the app across our platforms.'),
            _buildSection('5. Advertisements & Notifications', 'The app may contain advertisements served by third parties. We are not responsible for the content of these advertisements or any products/services offered therein.\n\nBy using the app, you consent to receive push notifications. You can opt-out of these notifications at any time through your device settings.'),
            _buildSection('6. Limitation of Liability', 'In no event shall Prompt MB be liable for any indirect, incidental, special, consequential, or punitive damages arising out of your use of the app.'),
            _buildSection('7. Changes to Terms', 'We reserve the right to modify these terms at any time. We will notify users of any changes by updating the "Last updated" date of these Terms. Continued use of the app constitutes acceptance of new terms.'),
            _buildSection('8. Contact', 'support@promptmb.com'),
            const SizedBox(height: 20),
            Text(
              'Last updated: September 2026',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(color: Colors.grey[400], height: 1.6),
          ),
        ],
      ),
    );
  }
}