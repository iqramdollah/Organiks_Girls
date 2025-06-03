import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post.dart';
import 'upload.dart';

class SocialFeedPage extends StatefulWidget {
  @override
  _SocialFeedPageState createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends State<SocialFeedPage> {
  bool _isUploading = false;

  final Color primaryColor = const Color(0xFF2A2B60);
  final Color accentColor = const Color(0xFFB06B9F);
  final Color cardColor = const Color(0xFF3B3D75);
  final Color whiteColor = Colors.white;

  void _setUploading(bool uploading) {
    setState(() => _isUploading = uploading);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: primaryColor,
          // appBar: AppBar(backgroundColor: primaryColor, elevation: 0),
          body: StreamBuilder(
            stream:
                FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final posts = snapshot.data!.docs;
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Card(
                    color: cardColor,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: PostItem(
                      postId: post.id,
                      mediaUrl: post['mediaUrl'],
                      caption: post['caption'],
                      timestamp: post['timestamp'] ?? Timestamp.now(),
                      likes: post['likes'] ?? 0,
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showUploadDialog(context, _setUploading),
            backgroundColor: accentColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        if (_isUploading)
          Container(
            color: Colors.black45,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
