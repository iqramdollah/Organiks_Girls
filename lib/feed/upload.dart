import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> showUploadDialog(
  BuildContext outerContext, // renamed to clarify this is the parent context
  Function(bool) setUploading,
) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);

  if (picked == null) return;

  final cropped = await ImageCropper().cropImage(
    sourcePath: picked.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    compressFormat: ImageCompressFormat.jpg,
    compressQuality: 85,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: const Color(0xFF2C2F5E),
        toolbarWidgetColor: Colors.white,
        backgroundColor: const Color(0xFF3B3D75),
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
      IOSUiSettings(title: 'Crop Image'),
    ],
  );

  if (cropped == null) return;

  File selectedMedia = File(cropped.path);
  String caption = '';
  bool canPost = true;

  await showModalBottomSheet(
    context: outerContext,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF2C2F5E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (modalContext) {
      return Padding(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(modalContext).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                    const Spacer(),
                    const Text(
                      "New Post",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed:
                          (!canPost || caption.trim().isEmpty)
                              ? null
                              : () async {
                                // Close the modal first
                                Navigator.pop(modalContext);

                                // Then upload post using the outerContext for safe snackbar
                                await _uploadPost(
                                  selectedMedia,
                                  caption,
                                  setUploading,
                                  outerContext,
                                );
                              },
                      child: Text(
                        "Post",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              (!canPost || caption.trim().isEmpty)
                                  ? Colors.white30
                                  : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        selectedMedia,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent, // transparent background
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          maxLines: null,
                          style: const TextStyle(
                            color:
                                Colors.white, // white text for dark background
                          ),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor:
                                Colors
                                    .transparent, // make sure this is transparent
                            hintText: "Write a caption...",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(136, 255, 255, 255),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                          onChanged: (val) {
                            setState(() {
                              caption = val;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

Future<void> _uploadPost(
  File media,
  String caption,
  Function(bool) setUploading,
  BuildContext context, // use the safe outer context here
) async {
  setUploading(true);

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final userId = user.uid;
    final postId = FirebaseFirestore.instance.collection('posts').doc().id;
    final storageRef = FirebaseStorage.instance.ref(
      'posts/$userId/$postId.jpg',
    );

    await storageRef.putFile(media);
    final mediaUrl = await storageRef.getDownloadURL();

    await FirebaseFirestore.instance.collection('posts').doc(postId).set({
      'caption': caption.trim(),
      'mediaUrl': mediaUrl,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': {},
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Post uploaded successfully")));
  } catch (e) {
    debugPrint('Upload failed: $e');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Upload failed. Try again.")));
  } finally {
    setUploading(false);
  }
}
