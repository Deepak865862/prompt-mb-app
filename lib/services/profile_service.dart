import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update User Profile
  Future<void> updateProfile({
    required String uid,
    String? username,
    String? bio,
    String? profilePic,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      
      if (username != null) updates['username'] = username;
      if (bio != null) updates['bio'] = bio;
      if (profilePic != null) updates['profilePic'] = profilePic;
      
      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Get User Posts Count
  Future<int> getUserPostsCount(String uid) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('prompts')
          .where('userId', isEqualTo: uid)
          .get();
      return snapshot.size;
    } catch (e) {
      return 0;
    }
  }

  // Get User's Posts
  Stream<QuerySnapshot> getUserPosts(String uid) {
    return _firestore
        .collection('prompts')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Delete Post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('prompts').doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }
}