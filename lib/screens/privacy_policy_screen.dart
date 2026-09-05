import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('1. Introduction', 'Prompt MB ("we", "our", or "us") respects your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.'),
            _buildSection('2. Information We Collect', 'We collect information that identifies, relates to, describes, or could reasonably be linked with a particular consumer or device.\n\nA. Personal Data:\n• Account Information: Email address and name (if provided).\n• Usage Data: Information about how you use the app, such as liked prompts and search queries.\n\nB. Device Data & Advertising:\n• Device Identifiers: We use third-party advertising partners (Google AdMob) that may collect device identifiers and usage data to show personalized advertisements.\n• Location Data: We do not collect precise location data.\n• Push Notifications: We may request permission to send you push notifications. You can opt-out in device settings.\n\nC. User-Generated Content:\n• Any prompts, comments, images, or other content you submit to the application may be stored and displayed publicly.'),
            _buildSection('3. How We Use Your Information', '• To provide and manage your account.\n• To improve our application and user experience.\n• To display advertisements through Google AdMob.\n• To send you push notifications about new prompts and updates.\n• To review and moderate user-generated content.\n• To respond to user inquiries and support.'),
            _buildSection('4. Third-Party Services', '• Google AdMob: For displaying advertisements.\n• Firebase/Google Auth: For authentication and hosting.\n• Firebase Cloud Messaging (FCM): For sending push notifications.'),
            _buildSection('5. Data Deletion', 'You can delete your account and associated data at any time via the specific setting in "Account Management > Delete Account". Upon deletion, your personal data is permanently removed from our servers.'),
            _buildSection('6. Contact Us', 'If you have questions about this Privacy Policy, please contact us at:\nEmail: support@promptmb.com'),
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