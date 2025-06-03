import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'comment_screen.dart';

class PostItem extends StatefulWidget {
  final String postId;
  final String mediaUrl;
  final String caption;
  final Timestamp timestamp;
  final Map<String, dynamic> likes;

  const PostItem({
    required this.postId,
    required this.mediaUrl,
    required this.caption,
    required this.timestamp,
    required this.likes,
    Key? key,
  }) : super(key: key);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  late Map<String, dynamic> _likes;
  late bool _isLiked;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _likes = Map<String, dynamic>.from(widget.likes);
    _isLiked = _likes.containsKey(currentUserId);
  }

  void _toggleLike() async {
    final postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId);

    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likes[currentUserId] = true;
      } else {
        _likes.remove(currentUserId);
      }
    });

    await postRef.update({'likes': _likes});
  }

  @override
  Widget build(BuildContext context) {
    final likeCount = _likes.length;
    final formattedDate = DateFormat.yMMMd().add_jm().format(
      widget.timestamp.toDate(),
    );

    return Card(
      margin: const EdgeInsets.all(10),
      color: const Color(0xFF3B3D75),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            imageUrl: widget.mediaUrl,
            placeholder: (context, url) => Container(
              height: 200,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: 200,
              color: Colors.black12,
              child: const Icon(Icons.broken_image, color: Colors.white),
            ),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              widget.caption,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              formattedDate,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.pink : Colors.white70,
                ),
                onPressed: _toggleLike,
              ),
              Text('$likeCount', style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.postId)
                    .collection('comments')
                    .snapshots(),
                builder: (context, snapshot) {
                  int commentCount = snapshot.data?.docs.length ?? 0;

                  return Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.comment_outlined,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) =>
                                CommentSheet(postId: widget.postId),
                          );
                        },
                      ),
                      Text(
                        '$commentCount',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
