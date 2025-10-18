import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvatarService {
  static final AvatarService _instance = AvatarService._internal();
  factory AvatarService() => _instance;
  AvatarService._internal();

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> pickAndUploadAvatar(BuildContext context) async {
    try {
      // Show source selection dialog
      final ImageSource? source = await _showImageSourceDialog(context);
      if (source == null) return null;

      // Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      // Crop image
      final CroppedFile? croppedFile = await _cropImage(pickedFile.path);
      if (croppedFile == null) return null;

      // Upload to Firebase Storage
      final String? downloadUrl = await _uploadToFirebase(croppedFile.path);
      if (downloadUrl == null) return null;

      // Update user profile
      await _updateUserProfile(downloadUrl);

      return downloadUrl;
    } catch (e) {
      debugPrint('Error picking/uploading avatar: $e');
      return null;
    }
  }

  // Upload avatar from specified source
  Future<String?> uploadAvatar(ImageSource source) async {
    try {
      // Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      // Crop image
      final CroppedFile? croppedFile = await _cropImage(pickedFile.path);
      if (croppedFile == null) return null;

      // Upload to Firebase Storage
      final String? downloadUrl = await _uploadToFirebase(croppedFile.path);
      if (downloadUrl == null) return null;

      // Update user profile
      await _updateUserProfile(downloadUrl);

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      return null;
    }
  }

  Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<CroppedFile?> _cropImage(String sourcePath) async {
    return await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 85,
      maxWidth: 500,
      maxHeight: 500,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Avatar',
          toolbarColor: const Color(0xFF1A202C), // AppTheme.primaryNavy
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: false,
          dimmedLayerColor: Colors.black.withValues(alpha: 0.8),
          activeControlsWidgetColor: const Color(0xFFB45309), // AppTheme.accentCopper
        ),
        IOSUiSettings(
          title: 'Crop Avatar',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
          rotateButtonsHidden: true,
          rotateClockwiseButtonHidden: true,
        ),
      ],
    );
  }

  Future<String?> _uploadToFirebase(String filePath) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final File file = File(filePath);
      final String fileName = 'avatars/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Create reference to Firebase Storage
      final Reference ref = _storage.ref().child(fileName);
      
      // Upload file
      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': user.uid,
            'uploadTime': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading to Firebase: $e');
      return null;
    }
  }

  Future<void> _updateUserProfile(String avatarUrl) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Update Firebase Auth profile
      await user.updatePhotoURL(avatarUrl);

      // Update Firestore user document
      await _firestore.collection('users').doc(user.uid).set({
        'avatarUrl': avatarUrl,
        'avatar_updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<void> deleteOldAvatar(String? oldAvatarUrl) async {
    if (oldAvatarUrl == null || !oldAvatarUrl.contains('firebase')) return;

    try {
      // Extract the file path from the URL
      final Uri uri = Uri.parse(oldAvatarUrl);
      final String encodedPath = uri.pathSegments.last;
      final String path = Uri.decodeComponent(encodedPath);
      
      // Delete from Firebase Storage
      await _storage.ref(path).delete();
    } catch (e) {
      // Silently fail - old avatar might not exist
      debugPrint('Error deleting old avatar: $e');
    }
  }
}