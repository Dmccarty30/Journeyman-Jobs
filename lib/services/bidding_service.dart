import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service for managing job bids and applications
///
/// Handles bid submissions, tracking, and status management
/// for both regular jobs and storm work opportunities
class BiddingService {
  static final BiddingService _instance = BiddingService._internal();
  factory BiddingService() => _instance;
  BiddingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Submit a bid for a job
  Future<BidResult> submitJobBid({
    required String jobId,
    required String jobTitle,
    required String company,
    String? coverMessage,
    bool isUrgent = false,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return BidResult.failure('Please sign in to submit bids');
      }

      final bidId = _generateBidId();
      final now = DateTime.now();

      // Create bid document
      final bidData = {
        'bidId': bidId,
        'jobId': jobId,
        'jobTitle': jobTitle,
        'company': company,
        'userId': user.uid,
        'userEmail': user.email,
        'userName': user.displayName ?? 'IBEW Member',
        'coverMessage': coverMessage,
        'isUrgent': isUrgent,
        'status': BidStatus.pending.name,
        'submittedAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      // Add user profile data if available
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        bidData.addAll({
          'ticketNumber': userData['ticket_number'],
          'classification': userData['classification'],
          'localUnion': userData['local_union'],
          'experience': userData['years_experience'],
          'certifications': userData['certifications'] ?? [],
        });
      }

      // Submit bid to Firestore
      await _firestore.collection('bids').doc(bidId).set(bidData);

      // Update job statistics
      await _updateJobBidCount(jobId);

      if (kDebugMode) {
        print('Bid submitted successfully: $bidId for job: $jobId');
      }

      return BidResult.success(
        bidId: bidId,
        message: 'Bid submitted successfully! You will be contacted if selected.',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting bid: $e');
      }
      return BidResult.failure('Failed to submit bid. Please try again.');
    }
  }

  /// Submit a bid for storm work
  Future<BidResult> submitStormBid({
    required String stormId,
    required String stormName,
    required String contractor,
    String? specialRequirements,
    bool immediateAvailability = false,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return BidResult.failure('Please sign in to submit storm work bids');
      }

      final bidId = _generateBidId();
      final now = DateTime.now();

      // Create storm bid document
      final bidData = {
        'bidId': bidId,
        'stormId': stormId,
        'stormName': stormName,
        'contractor': contractor,
        'userId': user.uid,
        'userEmail': user.email,
        'userName': user.displayName ?? 'IBEW Member',
        'specialRequirements': specialRequirements,
        'immediateAvailability': immediateAvailability,
        'status': BidStatus.pending.name,
        'submittedAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'isStormWork': true,
      };

      // Add user profile data
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        bidData.addAll({
          'ticketNumber': userData['ticket_number'],
          'classification': userData['classification'],
          'localUnion': userData['local_union'],
          'experience': userData['years_experience'],
          'stormExperience': userData['storm_experience'] ?? false,
          'travelWilling': userData['travel_willing'] ?? false,
        });
      }

      // Submit storm bid
      await _firestore.collection('storm_bids').doc(bidId).set(bidData);

      return BidResult.success(
        bidId: bidId,
        message: 'Storm work application submitted! Contractor will contact you directly.',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting storm bid: $e');
      }
      return BidResult.failure('Failed to submit storm application. Please try again.');
    }
  }

  /// Get user's bids
  Future<List<UserBid>> getUserBids({int limit = 50}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final querySnapshot = await _firestore
          .collection('bids')
          .where('userId', isEqualTo: user.uid)
          .orderBy('submittedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => UserBid.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user bids: $e');
      }
      return [];
    }
  }

  /// Check if user has already bid on a job
  Future<bool> hasUserBidOnJob(String jobId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final querySnapshot = await _firestore
          .collection('bids')
          .where('userId', isEqualTo: user.uid)
          .where('jobId', isEqualTo: jobId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking existing bid: $e');
      }
      return false;
    }
  }

  /// Update job bid count
  Future<void> _updateJobBidCount(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'bidCount': FieldValue.increment(1),
        'lastBidAt': Timestamp.now(),
      });
    } catch (e) {
      // Non-critical, don't fail the whole operation
      if (kDebugMode) {
        print('Warning: Could not update job bid count: $e');
      }
    }
  }

  /// Generate unique bid ID
  String _generateBidId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final user = _auth.currentUser;
    final userSuffix = user?.uid.substring(0, 8) ?? 'guest';
    return 'bid_${timestamp}_$userSuffix';
  }
}

/// Result of a bid submission
class BidResult {
  final bool success;
  final String message;
  final String? bidId;
  final String? error;

  BidResult._({
    required this.success,
    required this.message,
    this.bidId,
    this.error,
  });

  factory BidResult.success({required String bidId, required String message}) {
    return BidResult._(
      success: true,
      message: message,
      bidId: bidId,
    );
  }

  factory BidResult.failure(String error) {
    return BidResult._(
      success: false,
      message: error,
      error: error,
    );
  }
}

/// User's bid information
class UserBid {
  final String bidId;
  final String jobId;
  final String jobTitle;
  final String company;
  final BidStatus status;
  final DateTime submittedAt;
  final String? coverMessage;
  final bool isStormWork;

  UserBid({
    required this.bidId,
    required this.jobId,
    required this.jobTitle,
    required this.company,
    required this.status,
    required this.submittedAt,
    this.coverMessage,
    this.isStormWork = false,
  });

  factory UserBid.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserBid(
      bidId: data['bidId'] ?? doc.id,
      jobId: data['jobId'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      company: data['company'] ?? data['contractor'] ?? '',
      status: BidStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => BidStatus.pending,
      ),
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      coverMessage: data['coverMessage'],
      isStormWork: data['isStormWork'] ?? false,
    );
  }
}

/// Bid status enum
enum BidStatus {
  pending,    // Bid submitted, waiting for review
  reviewing,  // Employer is reviewing the bid
  accepted,   // Bid accepted, job offered
  rejected,   // Bid rejected
  withdrawn,  // User withdrew the bid
  expired,    // Bid expired
}

/// Extensions for bid status
extension BidStatusExtension on BidStatus {
  String get displayName {
    switch (this) {
      case BidStatus.pending:
        return 'Pending Review';
      case BidStatus.reviewing:
        return 'Under Review';
      case BidStatus.accepted:
        return 'Accepted';
      case BidStatus.rejected:
        return 'Not Selected';
      case BidStatus.withdrawn:
        return 'Withdrawn';
      case BidStatus.expired:
        return 'Expired';
    }
  }

  bool get isActive => this == BidStatus.pending || this == BidStatus.reviewing;
  bool get isFinal => this == BidStatus.accepted || this == BidStatus.rejected;
}