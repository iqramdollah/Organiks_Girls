import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CommentSheet extends StatefulWidget {
  final String postId;

  const CommentSheet({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentSheetState createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _commentController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  // Cache to store user data by userId to avoid multiple fetches
  final Map<String, Map<String, dynamic>> _userCache = {};

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    } else {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _userCache[userId] = data;
        return data;
      }
      return null;
    }
  }

  Future<void> _addComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    final commentData = {
      'userId': currentUserId,
      'text': commentText,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add(commentData);

    _commentController.clear();

    // Scroll to bottom after adding comment
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 70,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF2E2F55),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        _firestore
                            .collection('posts')
                            .doc(widget.postId)
                            .collection('comments')
                            .orderBy('timestamp', descending: false)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No comments yet. Be the first!',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      final comments = snapshot.data!.docs;

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final data =
                              comments[index].data() as Map<String, dynamic>;
                          final text = data['text'] ?? '';
                          final userId = data['userId'] ?? '';
                          final timestamp = data['timestamp'] as Timestamp?;
                          final timeString =
                              timestamp != null
                                  ? DateFormat.jm().format(timestamp.toDate())
                                  : '';

                          return FutureBuilder<Map<String, dynamic>?>(
                            future: _getUserData(userId),
                            builder: (context, userSnapshot) {
                              String profilePicUrl = '';
                              String username = userId; // fallback username

                              if (userSnapshot.connectionState ==
                                      ConnectionState.done &&
                                  userSnapshot.hasData) {
                                profilePicUrl =
                                    userSnapshot.data?['profilePicUrl'] ?? '';
                                username =
                                    userSnapshot.data?['username'] ?? userId;
                              }

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                leading: CircleAvatar(
                                  backgroundImage:
                                      profilePicUrl.isNotEmpty
                                          ? NetworkImage(profilePicUrl)
                                          : null,
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                  child:
                                      profilePicUrl.isEmpty
                                          ? const Icon(Icons.person)
                                          : null,
                                ),
                                title: Text(
                                  text,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  '$username • $timeString',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                // Input for new comment
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 8,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                    top: 8,
                  ),
                  color: const Color(0xFF1E1F3F),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 8, 8, 8),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: TextStyle(
                              color: Color.fromARGB(137, 7, 7, 7),
                            ),
                            border: InputBorder.none,
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _addComment(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white70),
                        onPressed: _addComment,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
