import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard ke liye
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
  runApp(const PromptMBApp());
}

class PromptMBApp extends StatelessWidget {
  const PromptMBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prompt MB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// --- AUTHENTICATION GATE ---
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

// --- LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;

  Future<void> _submit() async {
    setState(() => isLoading = true);
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim());
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 20),
              const Text('AI Prompt Gallery', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 40),
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 15),
              TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isLogin ? 'LOGIN' : 'SIGN UP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin ? "Naya account banayein (Sign Up)" : "Pehle se account hai? Login karein", style: const TextStyle(color: Colors.deepPurple)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- HOME SCREEN (MASONRY GRID + SEARCH) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  final String websiteUrl = 'https://prompttmbai.com';

  Future<void> _uploadPrompt() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // 1. Image Compress karo (1MB se choti)
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    
    try {
      final bytes = await File(pickedFile.path).readAsBytes();
      Uint8List? compressed = await FlutterImageCompress.compressWithList(bytes, quality: 85, minWidth: 1024, minHeight: 1024);
      
      // Agar phir bhi 1MB se badi hai toh quality kam karo
      while (compressed != null && compressed.length > 1048576) {
         compressed = await FlutterImageCompress.compressWithList(bytes, quality: 70, minWidth: 1024, minHeight: 1024);
      }

      if (compressed == null) throw Exception("Compression failed");

      // 2. MilesWeb par upload karo
      var request = http.MultipartRequest('POST', Uri.parse('$websiteUrl/upload.php'));
      request.files.add(http.MultipartFile.fromBytes('image', compressed, filename: 'prompt_${DateTime.now().millisecondsSinceEpoch}.jpg'));
      
      var response = await request.send();
      var resBody = await http.Response.fromStream(response);
      var jsonData = json.decode(resBody.body);

      if (jsonData['success'] != true) throw Exception("Upload failed");
      
      String imageUrl = jsonData['url'];

      // 3. Prompt text maango
      Navigator.pop(context); // Loading hatao
      final promptController = TextEditingController();
      final promptText = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Prompt Likhein'),
          content: TextField(controller: promptController, decoration: const InputDecoration(hintText: 'Yahan apna AI prompt likhein...'), maxLines: 4),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx, promptController.text), child: const Text('Save'))],
        ),
      );

      if (promptText == null || promptText.isEmpty) return;

      // 4. Firestore mein save karo
      await FirebaseFirestore.instance.collection('prompts').add({
        'imageUrl': imageUrl,
        'promptText': promptText,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully Uploaded!'), backgroundColor: Colors.green));

    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompt MB'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut()),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search prompts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
            ),
          ),
          // Masonry Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('prompts').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                var docs = snapshot.data!.docs.where((doc) {
                  final text = (doc['promptText'] ?? '').toString().toLowerCase();
                  return text.contains(searchQuery);
                }).toList();

                if (docs.isEmpty) return const Center(child: Text('Koi prompts nahi mile.'));

                return MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FullScreenView(data: data))),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: data['imageUrl'] ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[300], height: 200),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadPrompt,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Upload Prompt'),
      ),
    );
  }
}

// --- FULL SCREEN VIEW (COPY PROMPT FEATURE) ---
class FullScreenView extends StatelessWidget {
  final Map<String, dynamic> data;
  const FullScreenView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              child: CachedNetworkImage(imageUrl: data['imageUrl'] ?? '', fit: BoxFit.contain),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['promptText'] ?? '', style: const TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: data['promptText'] ?? ''));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prompt Copied!'), backgroundColor: Colors.deepPurple));
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Prompt'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
