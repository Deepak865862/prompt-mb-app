import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

class AddPromptScreen extends StatefulWidget {
  const AddPromptScreen({super.key});

  @override
  State<AddPromptScreen> createState() => _AddPromptScreenState();
}

class _AddPromptScreenState extends State<AddPromptScreen> {
  bool _isAuthenticated = false;
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _promptController = TextEditingController();
  final _tagTextController = TextEditingController();
  
  Uint8List? _imageBytes;
  String? _imageName;
  bool _isLoading = false;
  List<String> _tags = [];
  
  final String _adminPassword = "deepak2026";
  final String _uploadURL = "https://promptmbai.com/upload.php";
  final ImagePicker _picker = ImagePicker();

  void _checkPassword() {
    if (_passwordController.text == _adminPassword) {
      setState(() => _isAuthenticated = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Password!'), backgroundColor: Colors.red),
      );
    }
  }

  // Image Pick Karo (Web aur Mobile dono par kaam karega)
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // Mobile ke liye file read karo
        final bytes = await io.File(pickedFile.path).readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageName = pickedFile.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _processTags() {
    String text = _tagTextController.text.trim();
    if (text.isNotEmpty) {
      List<String> newTags = text.split(RegExp(r'\s+')).where((tag) => tag.isNotEmpty).toList();
      setState(() {
        _tags.addAll(newTags);
        _tagTextController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tags added successfully!'), backgroundColor: Color(0xFF00E5FF), duration: Duration(seconds: 1)),
      );
    }
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
  }

  // Image Compress Karo (Size kam karne ke liye)
  Future<Uint8List?> _compressImage(Uint8List imageBytes) async {
    try {
      var result = await FlutterImageCompress.compressWithList(
        imageBytes,
        minWidth: 1080,
        minHeight: 1080,
        quality: 85,
        format: CompressFormat.jpeg,
      );
      
      if (result.length > 1000000) {
        result = await FlutterImageCompress.compressWithList(
          result,
          minWidth: 720,
          minHeight: 720,
          quality: 75,
          format: CompressFormat.jpeg,
        );
      }
      
      print('Original: ${imageBytes.length}, Compressed: ${result.length}');
      return result;
    } catch (e) {
      print('Compression error: $e');
      return imageBytes;
    }
  }

  Future<String?> _uploadImageToHosting() async {
    if (_imageBytes == null) return null;
    
    setState(() => _isLoading = true);
    
    try {
      final compressedBytes = await _compressImage(_imageBytes!);
      if (compressedBytes == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image compression failed'), backgroundColor: Colors.red),
        );
        return null;
      }
      
      String base64Image = base64Encode(compressedBytes);
      String mimeType = 'image/jpeg';
      
      var url = Uri.parse(_uploadURL);
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': 'data:$mimeType;base64,$base64Image',
          'filename': _imageName ?? 'image.png'
        }),
      );
      
      var jsonData = jsonDecode(response.body);
      
      if (jsonData['success'] == true) {
        final originalSizeMB = (_imageBytes!.length / 1024 / 1024).toStringAsFixed(2);
        final compressedSizeMB = (compressedBytes.length / 1024 / 1024).toStringAsFixed(2);
        
        setState(() => _isLoading = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Compressed: ${originalSizeMB}MB → ${compressedSizeMB}MB'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
        return jsonData['url'];
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${jsonData['message']}'), backgroundColor: Colors.red),
        );
        return null;
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
      return null;
    }
  }

  Future<void> _savePrompt() async {
    if (_formKey.currentState!.validate()) {
      if (_imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image!'), backgroundColor: Colors.red),
        );
        return;
      }
      
      setState(() => _isLoading = true);
      String? imageUrl = await _uploadImageToHosting();
      
      if (imageUrl != null) {
        try {
          await FirebaseFirestore.instance.collection('prompts').add({
            'title': _titleController.text.trim(),
            'imageUrl': imageUrl,
            'promptText': _promptController.text.trim(),
            'tags': _tags,
            'createdAt': Timestamp.now(),
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Prompt successfully uploaded!'), backgroundColor: Colors.green),
            );
            _titleController.clear();
            _promptController.clear();
            _tagTextController.clear();
            setState(() {
              _imageBytes = null;
              _imageName = null;
              _tags = [];
            });
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
            );
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _titleController.dispose();
    _promptController.dispose();
    _tagTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Admin Panel - Add Prompt', style: TextStyle(color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: !_isAuthenticated 
        ? _buildLoginScreen()
        : _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))) 
          : _buildForm(),
    );
  }

  Widget _buildLoginScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, color: Color(0xFF00E5FF), size: 60),
            const SizedBox(height: 20),
            const Text('Admin Access Only', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter Password',
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF00E5FF)),
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => _checkPassword(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Login', style: TextStyle(color: Colors.black, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_titleController, 'Title', 'e.g., Cinematic Boy Portrait', Icons.title),
            const SizedBox(height: 20),
            
            const Text('Upload Image', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Tap to select from gallery', style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 12),
            
            if (_imageBytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _imageBytes!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.change_circle),
                      label: const Text('Change Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => setState(() {
                      _imageBytes = null;
                      _imageName = null;
                    }),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ] else ...[
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library, size: 40, color: Color(0xFF00E5FF)),
                      SizedBox(height: 8),
                      Text('Upload Image', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Tap to browse', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            
            const Text('Tags (Auto-Split by Space)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Example: "aivideo video promptmb" → creates 3 tags', style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagTextController,
                    decoration: InputDecoration(
                      hintText: 'Type tags separated by space...',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.tag, color: Color(0xFF00E5FF)),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => _processTags(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _processTags,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (_tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.asMap().entries.map((entry) {
                  int index = entry.key;
                  String tag = entry.value;
                  return Chip(
                    label: Text(tag, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                    backgroundColor: const Color(0xFF00E5FF),
                    deleteIcon: const Icon(Icons.close, size: 16, color: Colors.black),
                    onDeleted: () => _removeTag(index),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 20),
            
            _buildTextField(_promptController, 'Prompt Text', 'Enter the full AI prompt here...', Icons.description, maxLines: 8),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _savePrompt,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload to Firebase', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: const Color(0xFF00E5FF)),
              labelStyle: const TextStyle(color: Colors.grey),
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00E5FF))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
          ),
        ),
      ],
    );
  }
}