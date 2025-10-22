import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String username;
  final String imageUrl;
  final String locationText;
  final DateTime createdAt;
  final int likesCount;

  Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.imageUrl,
    required this.locationText,
    required this.createdAt,
    required this.likesCount,
  });

  factory Post.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Post(
      id: doc.id,
      userId: d['userId'] as String,
      username: d['username'] as String,
      imageUrl: d['imageUrl'] as String,
      locationText: (d['locationText'] ?? '') as String,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      likesCount: (d['likesCount'] ?? 0) as int,
    );
  }
}
