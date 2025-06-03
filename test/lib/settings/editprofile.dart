import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Custom model to hold upload result
class UploadResult {
  final String url;
  final String path;

  UploadResult({required this.url, required this.path});
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  File? _imageFile;
  String? _imageUrl;
  String? _imagePath;
  final picker = ImagePicker();
  final user = FirebaseAuth.instance.currentUser!;

  final Color primaryColor = const Color(0xFF2A2B60);
  final Color accentColor = const Color(0xFFB06B9F);
  final Color cardColor = const Color(0xFF3B3D75);

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    if (doc.exists) {
      _nameController.text = doc['name'] ?? '';
      _imageUrl = doc['photoUrl'];
      _imagePath = doc['photoPath'];
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<UploadResult> _uploadImageToStorage(File file, String? oldPath) async {
    // Delete old image if it exists
    if (oldPath != null && oldPath.isNotEmpty) {
      try {
        await FirebaseStorage.instance.ref(oldPath).delete();
      } catch (e) {
        debugPrint('Failed to delete old image: $e');
      }
    }

    // Upload new image
    final filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'profile_pics/${user.uid}/$filename';
    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    return UploadResult(url: url, path: path);
  }

  Future<void> _saveProfile() async {
    String? newImageUrl = _imageUrl;
    String? newImagePath = _imagePath;

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final doc = await userDocRef.get();
    final oldPhotoPath = doc.exists ? doc['photoPath'] as String? : null;

    if (_imageFile != null) {
      final result = await _uploadImageToStorage(_imageFile!, oldPhotoPath);
      newImageUrl = result.url;
      newImagePath = result.path;
    }

    await userDocRef.update({
      'name': _nameController.text.trim(),
      'photoUrl': newImageUrl,
      'photoPath': newImagePath,
    });

    await user.updateDisplayName(_nameController.text.trim());
    if (newImageUrl != null) {
      await user.updatePhotoURL(newImageUrl);
    }

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _imageFile != null
                        ? FileImage(_imageFile!)
                        : _imageUrl != null
                        ? NetworkImage(_imageUrl!) as ImageProvider
                        : const AssetImage('assets/logo.jpg'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Username",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Save"),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
              ),
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}
