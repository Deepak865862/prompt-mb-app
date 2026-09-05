import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('About Us', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About Prompt MB',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Prompt MB is your premium curated collection of AI prompts designed to help you get the most out of tools like ChatGPT, Gemini, Claude, and Midjourney.',
              style: TextStyle(color: Colors.grey[400], height: 1.6, fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Our Mission',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We aim to democratize AI mastery by helping users discover, save, and organize high-quality prompts that enhance productivity and creativity.',
              style: TextStyle(color: Colors.grey[400], height: 1.6, fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Key Features',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeature('Browse expert-curated AI prompts'),
            _buildFeature('Save your favorite prompts for quick access'),
            _buildFeature('Organize prompts by platform and category'),
            _buildFeature('Clean, distraction-free interface'),
            _buildFeature('Regular updates with trending prompts'),
            _buildFeature('One-tap copy to clipboard'),
            _buildFeature('Direct integration with ChatGPT & Gemini'),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Version',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Text(
                    '1.0.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Contact',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Text(
                    'support@promptmb.com',
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                '© 2026 Prompt MB Team',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF00E5FF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[400], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}