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

// --- LOGIN SCREEN ---
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
            const Text('AI Prompt Gallery', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 15),
            TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))),
            const SizedBox(height: 20),
            _isLoading ? const CircularProgressIndicator() : SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _auth, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)), child: Text(_isLogin ? 'LOGIN' : 'SIGN UP'))),
            TextButton(onPressed: () => setState(() => _isLogin = !_isLogin), child: Text(_isLogin ? "Don't have account? Sign Up" : "Already have account? Login")),
          ],
        ),
      ),
    );
  }
}

// --- HOME SCREEN ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  final String websiteUrl = 'https://prompttmbai.com';

  // --- IMAGE COMPRESSION ---
  Future<Uint8List?> compressImageTo1MB(Uint8List imageBytes) async {
    int quality = 90;
    Uint8List? result = await FlutterImageCompress.compressWithList(imageBytes, quality: quality, minWidth: 1024, minHeight: 1024);
    while (result != null && result.length > 1048576 && quality > 10) {
      quality -= 10;
      result = await FlutterImageCompress.compressWithList(imageBytes, quality: quality, minWidth: 1024, minHeight: 1024);
    }
    return result;
  }

  // --- UPLOAD TO WORDPRESS ---
  Future<String?> uploadImageToServer(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final compressedBytes = await compressImageTo1MB(bytes);
      if (compressedBytes == null) return null;

      final uploadUrl = '$websiteUrl/upload.php';
      
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
        ..files.add(http.MultipartFile.fromBytes('image', compressedBytes, filename: 'prompt_${DateTime.now().millisecondsSinceEpoch}.jpg'));

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      
      print('Response: $responseData');
      
      if (response.statusCode == 200) {
        var jsonData = json.decode(responseData.body);
        if (jsonData['success'] == true) {
          // Tumhare PHP code mein 'url' field hai
          return jsonData['url'];
        }
      }
      return null;
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }

  // --- UPLOAD PROMPT ---
  Future<void> uploadPrompt() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      final promptController = TextEditingController();
      final promptText = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enter Prompt'),
          content: TextField(controller: promptController, decoration: const InputDecoration(hintText: 'AI Prompt yahan likho...'), maxLines: 3),
          actions: [TextButton(onPressed: () => Navigator.pop(context, promptController.text), child: const Text('Upload'))],
        ),
      );

      if (promptText == null || promptText.isEmpty) { Navigator.pop(context); return; }

      final imageUrl = await uploadImageToServer(File(pickedFile.path));

      if (imageUrl == null) {
        Navigator.pop(context);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image upload failed. Check upload.php')));
        return;
      }

      await FirebaseFirestore.instance.collection('prompts').add({
        'imageUrl': imageUrl,
        'promptText': promptText,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Prompt uploaded successfully!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      Navigator.pop(context);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Prompt Gallery'), backgroundColor: Theme.of(context).colorScheme.inversePrimary, actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut())]),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('prompts').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No prompts yet. Upload one!'));

          return MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            itemCount: docs.length,
            padding: const EdgeInsets.all(4),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                clipBehavior: Clip.antiAlias,
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: CachedNetworkImage(imageUrl: data['imageUrl'] ?? '', fit: BoxFit.cover, width: double.infinity, placeholder: (context, url) => Container(color: Colors.grey[300], child: const Center(child: CircularProgressIndicator(strokeWidth: 2))), errorWidget: (context, url, error) => Container(color: Colors.grey[300], child: const Icon(Icons.error)))),
                    Container(padding: const EdgeInsets.all(8), color: Colors.white, child: Text(data['promptText'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: uploadPrompt, icon: const Icon(Icons.add_a_photo), label: const Text('Upload')),
    );
  }
}
