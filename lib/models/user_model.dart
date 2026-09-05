import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String bio;
  final String profilePic;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.bio = '',
    this.profilePic = '',
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    required this.createdAt,
  });

  // Firestore se data lena
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      bio: map['bio'] ?? '',
      profilePic: map['profilePic'] ?? '',
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      postsCount: map['postsCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Firestore mein data bhejna
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'bio': bio,
      'profilePic': profilePic,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Copy with method (update karne ke liye)
  UserModel copyWith({
    String? username,
    String? bio,
    String? profilePic,
    int? followersCount,
    int? followingCount,
    int? postsCount,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profilePic: profilePic ?? this.profilePic,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      createdAt: createdAt,
    );
  }
}