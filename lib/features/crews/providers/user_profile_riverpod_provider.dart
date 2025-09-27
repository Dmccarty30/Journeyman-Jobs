import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/user_profile_service.dart';

/// UserProfileService provider
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService(
    firestore: FirebaseFirestore.instance,
  );
});