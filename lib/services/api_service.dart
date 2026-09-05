import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prompt.dart';

class ApiService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Prompt>> fetchPrompts({int page = 1}) async {
    try {
      // Firebase se 'prompts' collection ka data lao
      QuerySnapshot snapshot = await _db.collection('prompts').get();
      
      List<Prompt> prompts = [];
      
      // Har document ko Prompt model mein badlo
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        
        // Tags ko array se List<String> mein badlo
        List<String> tags = [];
        if (data['tags'] != null) {
          tags = List<String>.from(data['tags']);
        }

        prompts.add(Prompt(
          id: doc.id.hashCode, 
          title: data['title'] ?? 'No Title',
          promptText: data['promptText'] ?? 'No Prompt',
          imageUrl: data['imageUrl'] ?? '',
          tags: tags,
        ));
      }
      
      return prompts;
    } catch (e) {
      throw Exception('Firebase se data nahi aaya: $e');
    }
  }
}