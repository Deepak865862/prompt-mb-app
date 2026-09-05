import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import '../models/prompt.dart';

class CustomizationScreen extends StatefulWidget {
  final Prompt prompt;
  const CustomizationScreen({super.key, required this.prompt});

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _bdayController = TextEditingController();
  final _anniController = TextEditingController();
  final _otherController = TextEditingController();

  bool _isCustomized = false;
  String _finalPromptText = "";
  bool _showFullPrompt = false;

  @override
  void initState() {
    super.initState();
    _finalPromptText = widget.prompt.promptText.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  String _getCustomizedPrompt() {
    String base = widget.prompt.promptText.replaceAll(RegExp(r'<[^>]*>'), '');
    List<String> extras = [];
    
    if (_nameController.text.isNotEmpty) extras.add('Name: "${_nameController.text}"');
    if (_dateController.text.isNotEmpty) extras.add('Date: "${_dateController.text}"');
    if (_bdayController.text.isNotEmpty) extras.add('Birthday Wish For: "${_bdayController.text}"');
    if (_anniController.text.isNotEmpty) extras.add('Anniversary Couple: "${_anniController.text}"');
    if (_otherController.text.isNotEmpty) extras.add('Details: "${_otherController.text}"');
    
    if (extras.isNotEmpty) {
      return "$base\n\n[User Customization]\n${extras.join(', ')}";
    }
    return base;
  }

  void _copyPrompt() {
    String textToCopy = _isCustomized ? _getCustomizedPrompt() : _finalPromptText;
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isCustomized ? 'Customized Prompt Copied!' : 'Prompt Copied!'),
        backgroundColor: const Color(0xFF00E5FF),
      )
    );
  }

  Future<void> _openChatGPT() async {
    String textToCopy = _isCustomized ? _getCustomizedPrompt() : _finalPromptText;
    await Clipboard.setData(ClipboardData(text: textToCopy));
    final Uri url = Uri.parse('https://chat.openai.com/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, webOnlyWindowName: '_blank');
    }
  }

  void _showAdvancedModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: const Color(0xFF121212).withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
            boxShadow: [BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.2), blurRadius: 20)],
          ),
          child: Column(
            children: [
              Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Advanced Customization', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildField(_nameController, 'Your Name', Icons.person),
                      const SizedBox(height: 12),
                      _buildField(_dateController, 'Date', Icons.calendar_today),
                      const SizedBox(height: 12),
                      _buildField(_bdayController, 'Birthday Wish For', Icons.cake),
                      const SizedBox(height: 12),
                      _buildField(_anniController, 'Anniversary Couple', Icons.favorite),
                      const SizedBox(height: 12),
                      _buildField(_otherController, 'Other Details', Icons.note, maxLines: 3),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isCustomized = true;
                                  _finalPromptText = _getCustomizedPrompt();
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Customization Applied!'), backgroundColor: Color(0xFF00E5FF))
                                );
                              },
                              icon: const Icon(Icons.check_circle, size: 18),
                              label: const Text('Apply'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E5FF),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Cancel'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFF00E5FF), size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Apply karne ke baad Copy/Open buttons se customized prompt use karo',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1))
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: const Color(0xFF00E5FF)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String promptTextToShow = _isCustomized ? _getCustomizedPrompt() : _finalPromptText;
    List<String> promptLines = promptTextToShow.split('\n');
    bool isLongPrompt = promptLines.length > 3;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Prompt Details', style: TextStyle(color: Colors.white)),
        actions: [
          if (_isCustomized) 
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF00E5FF).withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF00E5FF))),
              child: const Text('Customized', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold))
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                minScale: 0.5, maxScale: 3.0,
                child: CachedNetworkImage(
                  imageUrl: widget.prompt.imageUrl, width: double.infinity, fit: BoxFit.cover,
                  placeholder: (context, url) => Container(height: 250, color: Colors.grey[900], child: const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))),
                  errorWidget: (context, url, error) => Container(height: 250, color: Colors.grey[900], child: const Icon(Icons.broken_image)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Main Action Buttons (Copy & Open)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _copyPrompt,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Prompt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openChatGPT,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open ChatGPT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Advanced Customization Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showAdvancedModal,
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Advanced Customization'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF00E5FF)),
                  foregroundColor: const Color(0xFF00E5FF),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Prompt Section (MOVED HERE)
            const Text('Prompt:', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            // Clickable Card with Fade Effect
            GestureDetector(
              onTap: () {
                if (isLongPrompt) {
                  setState(() {
                    _showFullPrompt = !_showFullPrompt;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Truncated or Full Text
                    Text(
                      _showFullPrompt ? promptTextToShow : promptLines.take(3).join('\n'),
                      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                    ),
                    
                    // Fade Effect (agar prompt lamba hai aur full nahi dikh raha)
                    if (isLongPrompt && !_showFullPrompt) ...[
                      const SizedBox(height: 4),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xFF1E1E1E)],
                          stops: [0.3, 1.0],
                        ).createShader(bounds),
                        child: Text(
                          '...',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.keyboard_arrow_down, color: const Color(0xFF00E5FF), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Tap to view full prompt',
                            style: TextStyle(color: const Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                    
                    // Show Less Button (agar full prompt dikh raha hai)
                    if (_showFullPrompt) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.keyboard_arrow_up, color: Colors.grey[400], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Show Less',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}