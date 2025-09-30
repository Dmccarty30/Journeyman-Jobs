import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../domain/exceptions/app_exception.dart';
import '../services/connectivity_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ConnectivityService _connectivityService;

  StorageService({required ConnectivityService connectivityService})
      : _connectivityService = connectivityService;

  Future<String?> uploadMedia(File file, String path) async {
    // Check if offline
    if (!_connectivityService.isOnline) {
      throw OfflineError('No internet connection');
    }

    try {
      final ref = _storage.ref(path);
      final uploadTask = await ref.putFile(file);
      if (uploadTask.state == TaskState.success) {
        return await ref.getDownloadURL();
      } else {
        throw StorageError('Upload failed: ${uploadTask.state}');
      }
    } on FirebaseException catch (e) {
      throw StorageError('Failed to upload media: ${e.message}');
    } catch (e) {
      throw StorageError('Storage error: ${e.toString()}');
    }
  }
}