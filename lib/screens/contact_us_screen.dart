import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Contact Us', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Get in Touch',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We'd love to hear from you. Choose your preferred method of contact below.",
              style: TextStyle(color: Colors.grey[400], height: 1.6),
            ),
            const SizedBox(height: 32),
            _buildContactOption(
              icon: Icons.email,
              title: 'Email Support',
              subtitle: 'support@promptmb.com',
              onTap: () => _launchEmail(),
            ),
            const SizedBox(height: 16),
            _buildContactOption(
              icon: Icons.message,
              title: 'Rate Us',
              subtitle: 'Share your experience on Play Store',
              onTap: () => _openPlayStore(),
            ),
            const SizedBox(height: 16),
            _buildContactOption(
              icon: Icons.bug_report,
              title: 'Report an Issue',
              subtitle: 'Help us improve by reporting bugs',
              onTap: () => _launchEmail(subject: 'Bug Report'),
            ),
            const Spacer(),
            Center(
              child: Text(
                'We typically respond within 24-48 hours',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00E5FF), size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail({String subject = ''}) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@promptmb.com',
      query: 'subject=${Uri.encodeComponent(subject)}',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _openPlayStore() async {
    // Yeh link baad mein tumhare asli Play Store link se replace ho jayega
    final Uri playStoreUri = Uri.parse('https://play.google.com/store/apps/details?id=com.promptmb.app');
    if (await canLaunchUrl(playStoreUri)) {
      await launchUrl(playStoreUri);
    }
  }
}