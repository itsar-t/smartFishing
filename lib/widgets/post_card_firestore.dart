import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/post.dart';
import 'post_card.dart';

class PostCardFirestore extends StatelessWidget {
  final String postId;
  const PostCardFirestore({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final likeDocRef = postRef.collection('likes').doc(uid);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: postRef.snapshots(),
      builder: (context, postSnap) {
        if (!postSnap.hasData || !postSnap.data!.exists) {
          return const SizedBox.shrink();
        }
        final post = Post.fromDoc(postSnap.data!);

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: likeDocRef.snapshots(),
          builder: (context, likeSnap) {
            final liked = likeSnap.hasData && likeSnap.data!.exists;

            return PostCard(
              username: post.username,
              meta: _meta(post.createdAt, post.locationText),
              image: NetworkImage(post.imageUrl),
              liked: liked,
              onLike: () => _toggleLike(postRef, likeDocRef, liked),
              onComment: () {}, // TODO
              onShare: () {}, // TODO
              onFollow: () => _followUser(post.userId),
              onOverflow: () {},
            );
          },
        );
      },
    );
  }

  String _meta(DateTime createdAt, String locationText) {
    final now = DateTime.now();
    final mins = now.difference(createdAt).inMinutes;
    final time = mins < 60
        ? '${mins}m'
        : mins < 1440
        ? '${mins ~/ 60}h'
        : '${mins ~/ 1440}d';
    return locationText.isEmpty ? time : '$time • $locationText';
  }

  Future<void> _toggleLike(
    DocumentReference<Map<String, dynamic>> postRef,
    DocumentReference<Map<String, dynamic>> likeDocRef,
    bool liked,
  ) async {
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(postRef);
      final current = (snap.data()?['likesCount'] ?? 0) as int;
      if (liked) {
        tx.delete(likeDocRef);
        tx.update(postRef, {'likesCount': current > 0 ? current - 1 : 0});
      } else {
        tx.set(likeDocRef, {'createdAt': FieldValue.serverTimestamp()});
        tx.update(postRef, {'likesCount': current + 1});
      }
    });
  }

  Future<void> _followUser(String targetUserId) async {
    final me = FirebaseAuth.instance.currentUser!.uid;
    if (me == targetUserId) return;
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(me)
        .collection('following')
        .doc(targetUserId);

    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({'createdAt': FieldValue.serverTimestamp()});
    }
  }
}
