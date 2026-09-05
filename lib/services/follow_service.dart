import 'package:cloud_firestore/cloud_firestore.dart';

class FollowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Follow karna
  Future<void> followUser(String currentUid, String targetUid) async {
    try {
      // Yahan ${currentUid} use kiya hai
      await _firestore.collection('follows').doc('${currentUid}_$targetUid').set({
        'followerId': currentUid,
        'followingId': targetUid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(targetUid).update({
        'followersCount': FieldValue.increment(1),
      });

      await _firestore.collection('users').doc(currentUid).update({
        'followingCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error following user: $e');
    }
  }

  // Unfollow karna
  Future<void> unfollowUser(String currentUid, String targetUid) async {
    try {
      // Yahan bhi ${currentUid} use kiya hai
      await _firestore.collection('follows').doc('${currentUid}_$targetUid').delete();

      await _firestore.collection('users').doc(targetUid).update({
        'followersCount': FieldValue.increment(-1),
      });

      await _firestore.collection('users').doc(currentUid).update({
        'followingCount': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error unfollowing user: $e');
    }
  }

  // Check karo ki follow kiya hai ya nahi
  Stream<bool> isFollowing(String currentUid, String targetUid) {
    // Yahan bhi ${currentUid} use kiya hai
    return _firestore
        .collection('follows')
        .doc('${currentUid}_$targetUid')
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  // Get All Users
  Stream<QuerySnapshot> getAllUsers(String currentUid) {
    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: currentUid) 
        .limit(10) 
        .snapshots();
  }
}