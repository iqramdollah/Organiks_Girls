import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post.dart';
import 'upload.dart';

class SocialFeedPage extends StatefulWidget {
  @override
  State<SocialFeedPage> createState() => _PaginatedFeedPageState();
}

class _PaginatedFeedPageState extends State<SocialFeedPage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final List<DocumentSnapshot> _posts = [];
  bool _isLoading = false;
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _isUploading = false;

  final Color primaryColor = const Color(0xFF2A2B60);
  final Color accentColor = const Color(0xFFB06B9F);
  final Color cardColor = const Color(0xFF3B3D75);

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadPosts();
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  void _setUploading(bool uploading) {
    setState(() => _isUploading = uploading);
  }

  Future<void> _loadPosts() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(10);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last;
      _posts.addAll(snapshot.docs);
    } else {
      _hasMore = false;
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for keepAlive
    return Stack(
      children: [
        Scaffold(
          backgroundColor: primaryColor,
          body: _posts.isEmpty && _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _posts.clear();
                      _lastDoc = null;
                      _hasMore = true;
                    });
                    await _loadPosts();
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _posts.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _posts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final post = _posts[index];
                      return Card(
                        color: cardColor,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: PostItem(
                          postId: post.id,
                          mediaUrl: post['mediaUrl'],
                          caption: post['caption'],
                          timestamp: post['timestamp'],
                          likes: post['likes'] ?? 0,
                        ),
                      );
                    },
                  ),
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
