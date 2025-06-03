import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';

class ChatHub extends StatefulWidget {
  const ChatHub({super.key});

  @override
  State<ChatHub> createState() => _ChatHubState();
}

class _ChatHubState extends State<ChatHub> {
  final TextEditingController _controller = TextEditingController();
  bool _showEmojiPicker = false;
  File? _selectedImage;
  User? currentUser;
  String? _username;
  String? _profileImageUrl;
  String chatId = "team_group_chat";

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _username = data['name'];
        _profileImageUrl = data['profileImage'];
      });
    }
  }

  Future<void> _sendMessage({String? text, String? imageUrl}) async {
    if ((text == null || text.trim().isEmpty) && imageUrl == null) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'text': text,
          'imageUrl': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'Sent',
          'senderId': currentUser!.uid,
          'senderName': _username ?? 'Anonymous',
          'senderAvatar': _profileImageUrl ?? '',
          'readBy': [currentUser!.uid],
          'deleted': false,
        });

    _controller.clear();
    setState(() {
      _selectedImage = null;
    });
  }

  Stream<QuerySnapshot> getMessageStream() {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
    final ref = FirebaseStorage.instance
        .ref()
        .child('chat_images')
        .child(fileName);

    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<void> _updateReadReceipts(String messageId, List readBy) async {
    if (!readBy.contains(currentUser!.uid)) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
            'readBy': FieldValue.arrayUnion([currentUser!.uid]),
          });
    }
  }

  String formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final time = timestamp.toDate();
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget buildMessageBubble(DocumentSnapshot doc) {
    final msg = doc.data() as Map<String, dynamic>;
    if (msg['deleted'] == true) return const SizedBox.shrink();

    final isCurrentUser = msg['senderId'] == currentUser!.uid;

    _updateReadReceipts(doc.id, msg['readBy'] ?? []);

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(msg['senderAvatar'] ?? ''),
              ),
            ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color:
                    isCurrentUser
                        ? const Color(0xFF075E54)
                        : const Color(0xFF3B3D75),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isCurrentUser ? 12 : 0),
                  bottomRight: Radius.circular(isCurrentUser ? 0 : 12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser && msg['senderName'] != null)
                    Text(
                      msg['senderName'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (msg['text'] != null && msg['text'].toString().isNotEmpty)
                    Text(
                      msg['text'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  if (msg['imageUrl'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Image.network(
                        msg['imageUrl'],
                        height: 150,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatTime(msg['timestamp']),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        msg['readBy'].length > 1 ? Icons.done_all : Icons.check,
                        size: 16,
                        color:
                            msg['readBy'].length > 1
                                ? Colors.blue[300]
                                : Colors.white70,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleEmojiPicker() {
    setState(() => _showEmojiPicker = !_showEmojiPicker);
  }

  void copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2B60),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2B60),
        title: const Text('Team Chat', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getMessageStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder:
                      (context, index) => buildMessageBubble(docs[index]),
                );
              },
            ),
          ),
          if (_showEmojiPicker)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected:
                    (category, emoji) => _controller.text += emoji.emoji,
              ),
            ),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Image.file(
                _selectedImage!,
                height: 150,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
          Container(
            color: const Color(0xFF2A2B60),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions, color: Colors.white),
                  onPressed: _toggleEmojiPicker,
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.white),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B3D75),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        fillColor:
                            Colors.transparent, // Explicit transparent fill
                        filled: true,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () async {
                    String? imageUrl;
                    if (_selectedImage != null) {
                      imageUrl = await _uploadImage(_selectedImage!);
                    }
                    await _sendMessage(
                      text: _controller.text,
                      imageUrl: imageUrl,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
