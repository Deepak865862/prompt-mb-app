import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/prompt.dart';

class PromptDetailScreen extends StatefulWidget {
  final Prompt prompt;
  const PromptDetailScreen({super.key, required this.prompt});

  @override
  State<PromptDetailScreen> createState() => _PromptDetailScreenState();
}

class _PromptDetailScreenState extends State<PromptDetailScreen> {
  bool _showFullText = false;

  void _copyPrompt() {
    String cleanText = widget.prompt.promptText.replaceAll(RegExp(r'<[^>]*>'), '');
    Clipboard.setData(ClipboardData(text: cleanText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prompt copied to clipboard!')),
    );
  }

  Future<void> _openChatGPT() async {
    String cleanText = widget.prompt.promptText.replaceAll(RegExp(r'<[^>]*>'), '');
    await Clipboard.setData(ClipboardData(text: cleanText));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prompt copied! Now paste in ChatGPT'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    
    await Future.delayed(const Duration(milliseconds: 500));
    final Uri url = Uri.parse('https://chat.openai.com/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, webOnlyWindowName: '_blank');
    }
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Instructions', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Jitna clean aur high resolution ka image aap denge, utna hi face milne ka chances hai.\n\nRecommended Apps: ChatGPT aur Gemini.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: Color(0xFF00E5FF)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String cleanText = widget.prompt.promptText.replaceAll(RegExp(r'<[^>]*>'), '');

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Prompt Details', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFF00E5FF)),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                widget.prompt.imageUrl,
                width: double.infinity,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))));
                },
                errorBuilder: (context, error, stackTrace) => const SizedBox(height: 300, child: Center(child: Icon(Icons.broken_image, color: Colors.grey))),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _copyPrompt,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Prompt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openChatGPT,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open in ChatGPT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prompt Details:',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cleanText,
                    style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                    maxLines: _showFullText ? null : 4,
                    overflow: _showFullText ? null : TextOverflow.ellipsis,
                  ),
                  TextButton(
                    onPressed: () => setState(() => _showFullText = !_showFullText),
                    child: Text(
                      _showFullText ? 'View Less' : 'View More',
                      style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}