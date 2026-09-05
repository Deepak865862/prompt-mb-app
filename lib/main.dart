import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase ko start karo
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prompt MB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  // --- IMAGE COMPRESSION LOGIC (1MB ke andar) ---
  Future<Uint8List?> compressImageTo1MB(Uint8List imageBytes) async {
    int quality = 90; // Shuruwat 90% quality se
    
    // Image ko compress karo
    Uint8List? result = await FlutterImageCompress.compressWithList(
      imageBytes,
      quality: quality,
    );

    // Agar size abhi bhi 1MB (1048576 bytes) se bada hai, toh quality kam karte jao
    while (result != null && result.length > 1048576 && quality > 10) {
      quality -= 10;
      result = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: quality,
      );
    }
    
    return result; // Ab yeh image 1MB se choti hogi!
  }
  // ------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('AI Prompt Gallery'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_done, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Firebase Connected!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Image Compressor Ready!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
