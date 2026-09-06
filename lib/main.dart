import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Prompt Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

// Check authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}

// --- LOGIN/SIGNUP SCREEN ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _auth() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library, size: 100, color: Colors.deepPurple),
            const SizedBox(height: 20),
            const Text(
              'AI Prompt Gallery',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _auth,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(_isLogin ? 'LOGIN' : 'SIGN UP'),
                    ),
                  ),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin
                    ? "Don't have account? Sign Up"
                    : "Already have account? Login",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HOME SCREEN (GALLERY) ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  
  // ⚠️ YAHAN APNA WORDPRESS URL DAALO
  final String wordpressUrl = 'https://yourwebsite.com';
  
  // ⚠️ YAHAN APNA WORDPRESS USERNAME DAALO
  final String wpUsername = 'your_username';
  
  // ⚠️ YAHAN APPLICATION PASSWORD DAALO (bina spaces ke)
  final String wpAppPassword = 'your_app_password';

  // --- IMAGE COMPRESSION (1MB ke andar) ---
  Future<Uint8List?> compressImageTo1MB(Uint8List imageBytes) async {
    int quality = 90;
    
    Uint8List? result = await FlutterImageCompress.compressWithList(
      imageBytes,
      quality: quality,
      minWidth: 1024,
      minHeight: 1024,
    );

    // Agar 1MB se bada hai, toh quality kam karo
    while (result != null && result.length > 1048576 && quality > 10) {
      quality -= 10;
      result = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: quality,
        minWidth: 1024,
        minHeight: 1024,
      );
    }
    
    return result;
  }

  // --- WORDPRESS ME IMAGE UPLOAD KARO ---
  Future<String?> uploadImageToWordPress(File imageFile, String promptText) async {
    try {
      // Pehle image ko compress karo
      final bytes = await imageFile.readAsBytes();
      final compressedBytes = await compressImageTo1MB(bytes);
      
      if (compressedBytes == null) return null;

      // WordPress Media API call
      final url = Uri.parse('$wordpressUrl/wp-json/wp/v2/media');
      
      // Basic Authentication (username:app_password)
      final credentials = base64Encode(utf8.encode('$wpUsername:$wpAppPassword'));
      
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Basic $credentials'
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          compressedBytes,
          filename: 'prompt_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ))
        ..fields['title'] = promptText;

      var response = await request.send();
      
      if (response.statusCode == 201) {
        var responseData = await http.Response.fromStream(response);
        var jsonData = json.decode(responseData.body);
        return jsonData['source_url']; // WordPress image URL
      } else {
        print('Upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading to WordPress: $e');
      return null;
    }
  }

  // --- PROMPT UPLOAD (Image + Text) ---
  Future<void> uploadPrompt() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // Dialog dikhao
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // User se prompt text maango
      final promptController = TextEditingController();
      final promptText = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enter Prompt'),
          content: TextField(
            controller: promptController,
            decoration: const InputDecoration(hintText: 'AI Prompt yahan likho...'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, promptController.text),
              child: const Text('Upload'),
            ),
          ],
        ),
      );

      if (promptText == null || promptText.isEmpty) {
        Navigator.pop(context);
        return;
      }

      // WordPress par image upload karo
      final imageUrl = await uploadImageToWordPress(
        File(pickedFile.path),
        promptText,
      );

      if (imageUrl == null) {
        Navigator.pop(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image upload failed. Check WordPress credentials.')),
          );
        }
        return;
      }

      // Firestore mein save karo (Text data + WordPress Image URL)
      await FirebaseFirestore.instance.collection('prompts').add({
        'imageUrl': imageUrl,
        'promptText': promptText,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'userEmail': FirebaseAuth.instance.currentUser!.email,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
      });

      // Navigator.pop(context); // Loading band karo
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Prompt uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // --- LOGOUT ---
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Prompt Gallery'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prompts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('No prompts yet. Upload one!'),
                ],
              ),
            );
          }

          return MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            itemCount: docs.length,
            padding: const EdgeInsets.all(4),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final imageUrl = data['imageUrl'] ?? '';
              final promptText = data['promptText'] ?? 'No text';

              return Card(
                clipBehavior: Clip.antiAlias,
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error, color: Colors.red),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.white,
                      child: Text(
                        promptText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: uploadPrompt,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Upload'),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
