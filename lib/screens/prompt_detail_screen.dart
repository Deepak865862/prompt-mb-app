import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../models/prompt_model.dart';

class PromptDetailScreen extends StatefulWidget {
  final PromptModel prompt;

  const PromptDetailScreen({super.key, required this.prompt});

  @override
  State<PromptDetailScreen> createState() => _PromptDetailScreenState();
}

class _PromptDetailScreenState extends State<PromptDetailScreen> {
  // Customize Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String _selectedRatio = '1:1';
  bool _isCustomizeOpen = false;

  // Ratios list
  final List<String> _ratios = ['1:1', '3:4', '4:5', '9:16', '16:9'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Prompt Copy karne ka function
  void _copyPrompt(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prompt Copied Successfully!'),
        backgroundColor: AppTheme.neonPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ChatGPT Open karne ka function
  Future<void> _openChatGPT(String text) async {
    final Uri url = Uri.parse('https://chat.openai.com/?q=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open ChatGPT'), backgroundColor: Colors.red),
      );
    }
  }

  // Final Customized Prompt banana
  String _getCustomizedPrompt() {
    String basePrompt = widget.prompt.content;
    String customized = basePrompt;

    if (_nameController.text.isNotEmpty) customized += "\nName: ${_nameController.text}";
    if (_ageController.text.isNotEmpty) customized += "\nAge: ${_ageController.text}";
    if (_dateController.text.isNotEmpty) customized += "\nDate: ${_dateController.text}";
    customized += "\nAspect Ratio: $_selectedRatio";

    return customized;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Full Screen Zoomable Image
          PhotoView(
            imageProvider: NetworkImage(widget.prompt.imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.0,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),

          // 2. Top Back Button
          Positioned(
            top: 40,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
            ),
          ),

          // 3. Bottom Prompt & Actions Section
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppTheme.neonPurple.withOpacity(0.5), width: 1)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Prompt Title
                    Text(
                      widget.prompt.title,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Prompt Text Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.neonBlue.withOpacity(0.3)),
                      ),
                      child: Text(
                        widget.prompt.content,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Main Buttons (Copy, Open, Customize)
                    Row(
                      children: [
                        Expanded(
                          child: _buildNeonButton('Copy', Icons.copy, AppTheme.neonPurple, () {
                            _copyPrompt(widget.prompt.content);
                          }),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildNeonButton('Open', Icons.open_in_new, AppTheme.neonBlue, () {
                            _openChatGPT(widget.prompt.content);
                          }),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildNeonButton('Customize', Icons.tune, AppTheme.neonPink, () {
                            setState(() {
                              _isCustomizeOpen = !_isCustomizeOpen;
                            });
                          }),
                        ),
                      ],
                    ),

                    // Customize Form (Hidden by default)
                    if (_isCustomizeOpen) ...[
                      const SizedBox(height: 20),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 10),
                      const Text('Customize Prompt', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      
                      _buildTextField('Name (Optional)', _nameController),
                      const SizedBox(height: 10),
                      _buildTextField('Age (Optional)', _ageController, isNumber: true),
                      const SizedBox(height: 10),
                      _buildTextField('Birthday/Anniversary (Optional)', _dateController),
                      const SizedBox(height: 15),
                      
                      // Ratio Dropdown
                      const Text('Photo Ratio:', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.neonPurple.withOpacity(0.3)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRatio,
                            dropdownColor: AppTheme.cardBg,
                            style: const TextStyle(color: Colors.white),
                            items: _ratios.map((String ratio) {
                              return DropdownMenuItem<String>(
                                value: ratio,
                                child: Text(ratio),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedRatio = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Customized Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildNeonButton('Copy Custom', Icons.copy, AppTheme.neonPurple, () {
                              _copyPrompt(_getCustomizedPrompt());
                            }),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildNeonButton('Open Custom', Icons.open_in_new, AppTheme.neonBlue, () {
                              _openChatGPT(_getCustomizedPrompt());
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Neon Buttons
  Widget _buildNeonButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Text Fields
  Widget _buildTextField(String hint, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: AppTheme.cardBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.neonPurple)),
      ),
    );
  }
}
