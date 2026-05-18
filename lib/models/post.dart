// lib/models/post.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String username;
  final String imageUrl;
  final String locationText;
  final String description; // kan vara tom sträng
  final DateTime? createdAt; // kan vara null innan serverTimestamp fyllts
  final int likesCount;

  Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.imageUrl,
    required this.locationText,
    required this.description,
    required this.createdAt,
    required this.likesCount,
  });

  factory Post.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Post(
      id: doc.id,
      userId: (d['userId'] ?? '') as String,
      username: (d['username'] ?? '') as String,
      imageUrl: (d['imageUrl'] ?? '') as String,
      locationText: (d['locationText'] ?? '') as String,
      description: (d['description'] ?? '') as String, //Tom om saknas
      createdAt: (d['createdAt'] is Timestamp)
          ? (d['createdAt'] as Timestamp).toDate()
          : null, // null om inte satt än
      likesCount: (d['likesCount'] ?? 0) as int,
    );
  }
}
