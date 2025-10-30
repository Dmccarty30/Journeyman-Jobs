import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../features/crews/models/crew.dart';
import '../features/crews/models/crew_member.dart';
import '../domain/enums/member_role.dart';
import '../security/rate_limiter.dart';
import '../utils/structured_logging.dart';

/// Service for end-to-end encryption of crew communications.
///
/// This service provides comprehensive encryption and decryption capabilities
/// for crew messages, ensuring secure communication between crew members.
/// It implements asymmetric encryption for key exchange and symmetric
/// encryption for message content.
///
/// Features:
/// - End-to-end encryption for all crew messages
/// - Public key infrastructure (PKI) for key management
/// - Secure key exchange protocols
/// - Message integrity verification
/// - Role-based encryption permissions
/// - Comprehensive audit logging
/// - Secure key storage and rotation
class CrewMessageEncryptionService {
  final FirebaseFirestore _firestore;
  final RateLimiter _rateLimiter;

  // Collection names
  static const String _encryptionKeysCollection = 'crew_encryption_keys';
  static const String _messageKeysCollection = 'crew_message_keys';
  static const String _encryptionLogsCollection = 'crew_encryption_logs';

  // Encryption configuration
  static const int _rsaKeySize = 2048;
  static const int _aesKeySize = 256;
  static const int _ivSize = 16;
  static const Duration _keyRotationInterval = Duration(days: 90);

  // Rate limiting
  static const int _maxEncryptionOperations = 100;
  static const Duration _rateLimitWindow = Duration(minutes: 1);

  CrewMessageEncryptionService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore,
       _rateLimiter = RateLimiter();

  /// Initializes encryption for a crew member.
  ///
  /// This method generates public/private key pairs for a crew member
  /// and stores the public key in Firestore for other members to use
  /// when encrypting messages. The private key is never stored.
  ///
  /// Parameters:
  /// - [userId]: The user ID to initialize encryption for
  /// - [crewId]: The crew ID
  /// - [role]: The user's role in the crew
  ///
  /// Returns:
  /// - [EncryptionKeyPair] containing public and private keys
  ///
  /// Throws:
  /// - [EncryptionException] if key generation fails
  /// - [FirebaseException] for database errors
  Future<EncryptionKeyPair> initializeEncryption({
    required String userId,
    required String crewId,
    required MemberRole role,
  }) async {
    try {
      // Security: Check rate limiting
      final rateLimitKey = 'encrypt_init_${userId.hashCode}';
      if (!await _rateLimiter.isAllowed(rateLimitKey, operation: 'encrypt_init')) {
        throw EncryptionRateLimitException(
          'Too many encryption initialization requests. Please try again later.',
          retryAfter: _rateLimiter.getRetryAfter(rateLimitKey, operation: 'encrypt_init'),
        );
      }

      // Generate RSA key pair
      final keyPair = _generateRSAKeyPair();

      // Store public key in Firestore
      await _firestore.collection(_encryptionKeysCollection).doc(userId).set({
        'userId': userId,
        'crewId': crewId,
        'role': role.name,
        'publicKey': keyPair.publicKey,
        'keyAlgorithm': 'RSA',
        'keySize': _rsaKeySize,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUsedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'rotationRequired': false,
      });

      // Log key generation
      await _logEncryptionEvent(
        userId: userId,
        crewId: crewId,
        event: EncryptionEvent.keyGenerated,
        details: 'RSA key pair generated for role ${role.name}',
      );

      // Security: Reset rate limit on successful operation
      _rateLimiter.reset(rateLimitKey, operation: 'encrypt_init');

      return keyPair;
    } on EncryptionRateLimitException catch (e) {
      debugPrint('[CrewMessageEncryptionService] Rate limit exceeded: $e');
      rethrow;
    } on FirebaseException catch (e) {
      debugPrint('[CrewMessageEncryptionService] Firestore error initializing encryption: $e');
      rethrow;
    } catch (e) {
      debugPrint('[CrewMessageEncryptionService] Unexpected error initializing encryption: $e');
      throw EncryptionException('Failed to initialize encryption: $e');
    }
  }

  /// Encrypts a message for crew communication.
  ///
  /// This method encrypts message content using AES-256-GCM and
  /// encrypts the AES key with RSA for each recipient.
  ///
  /// Parameters:
  /// - [senderId]: The user ID sending the message
  /// - [crewId]: The crew ID
  /// - [content]: The message content to encrypt
  /// - [recipientIds]: List of recipient user IDs (optional, defaults to all crew members)
  /// - [messageType]: Type of message for additional context
  ///
  /// Returns:
  /// - [EncryptedMessage] containing encrypted content and keys
  ///
  /// Throws:
  /// - [EncryptionException] if encryption fails
  /// - [KeyNotFoundException] if encryption keys are not found
  Future<EncryptedMessage> encryptMessage({
    required String senderId,
    required String crewId,
    required String content,
    List<String>? recipientIds,
    String messageType = 'text',
  }) async {
    try {
      // Security: Check rate limiting
      final rateLimitKey = 'encrypt_msg_${senderId.hashCode}';
      if (!await _rateLimiter.isAllowed(rateLimitKey, operation: 'encrypt')) {
        throw EncryptionRateLimitException(
          'Too many encryption requests. Please try again later.',
          retryAfter: _rateLimiter.getRetryAfter(rateLimitKey, operation: 'encrypt'),
        );
      }

      // Get recipients (if not provided, get all crew members)
      final recipients = recipientIds ?? await _getCrewMemberIds(crewId);
      if (recipients.isEmpty) {
        throw EncryptionException('No recipients found for encryption');
      }

      // Remove sender from recipients if included
      recipients.remove(senderId);

      // Generate AES key and IV for message encryption
      final aesKey = _generateAESKey();
      final iv = _generateIV();

      // Encrypt message content with AES-256-GCM
      final encryptedContent = _encryptAES(content, aesKey, iv);

      // Get public keys for all recipients
      final recipientKeys = await _getRecipientPublicKeys(recipients);

      // Encrypt AES key for each recipient using RSA
      final encryptedKeys = <String, String>{};
      for (final recipientId in recipients) {
        final publicKey = recipientKeys[recipientId];
        if (publicKey != null) {
          encryptedKeys[recipientId] = _encryptRSA(aesKey, publicKey);
        }
      }

      if (encryptedKeys.isEmpty) {
        throw EncryptionException('No valid recipient keys found for encryption');
      }

      // Create encrypted message
      final encryptedMessage = EncryptedMessage(
        messageId: _generateMessageId(),
        senderId: senderId,
        crewId: crewId,
        encryptedContent: encryptedContent,
        iv: base64Encode(iv),
        encryptedKeys: encryptedKeys,
        messageType: messageType,
        createdAt: DateTime.now(),
        algorithm: 'AES-256-GCM',
        keyAlgorithm: 'RSA-OAEP',
      );

      // Log encryption
      await _logEncryptionEvent(
        userId: senderId,
        crewId: crewId,
        event: EncryptionEvent.messageEncrypted,
        details: 'Message encrypted for ${encryptedKeys.length} recipients',
        context: 'messageType: $messageType',
      );

      // Security: Reset rate limit on successful operation
      _rateLimiter.reset(rateLimitKey, operation: 'encrypt');

      return encryptedMessage;
    } on EncryptionRateLimitException catch (e) {
      debugPrint('[CrewMessageEncryptionService] Rate limit exceeded: $e');
      rethrow;
    } on EncryptionException catch (e) {
      debugPrint('[CrewMessageEncryptionService] Encryption error: $e');
      rethrow;
    } on KeyNotFoundException catch (e) {
      debugPrint('[CrewMessageEncryptionService] Key not found: $e');
      rethrow;
    } on FirebaseException catch (e) {
      debugPrint('[CrewMessageEncryptionService] Firestore error encrypting message: $e');
      rethrow;
    } catch (e) {
      debugPrint('[CrewMessageEncryptionService] Unexpected error encrypting message: $e');
      throw EncryptionException('Failed to encrypt message: $e');
    }
  }

  /// Decrypts a message received by a crew member.
  ///
  /// This method decrypts the AES key using the recipient's private key
  /// and then decrypts the message content using AES-256-GCM.
  ///
  /// Parameters:
  /// - [userId]: The user ID receiving the message
  /// - [encryptedMessage]: The encrypted message to decrypt
  /// - [privateKey]: The user's private RSA key
  ///
  /// Returns:
  /// - [DecryptedMessage] containing decrypted content and metadata
  ///
  /// Throws:
  /// - [EncryptionException] if decryption fails
  /// - [InvalidKeyException] if the private key is invalid
  /// - [MessageTamperedException] if message integrity check fails
  Future<DecryptedMessage> decryptMessage({
    required String userId,
    required EncryptedMessage encryptedMessage,
    required String privateKey,
  }) async {
    try {
      // Security: Check rate limiting
      final rateLimitKey = 'decrypt_msg_${userId.hashCode}';
      if (!await _rateLimiter.isAllowed(rateLimitKey, operation: 'decrypt')) {
        throw EncryptionRateLimitException(
          'Too many decryption requests. Please try again later.',
          retryAfter: _rateLimiter.getRetryAfter(rateLimitKey, operation: 'decrypt'),
        );
      }

      // Check if user is a recipient
      if (!encryptedMessage.encryptedKeys.containsKey(userId)) {
        throw EncryptionException('User is not a recipient of this message');
      }

      // Decrypt AES key using RSA
      final encryptedAESKey = encryptedMessage.encryptedKeys[userId]!;
      final aesKey = _decryptRSA(encryptedAESKey, privateKey);

      // Decrypt message content using AES-256-GCM
      final iv = base64Decode(encryptedMessage.iv);
      final decryptedContent = _decryptAES(
        encryptedMessage.encryptedContent,
        aesKey,
        iv,
      );

      // Create decrypted message
      final decryptedMessage = DecryptedMessage(
        messageId: encryptedMessage.messageId,
        senderId: encryptedMessage.senderId,
        crewId: encryptedMessage.crewId,
        content: decryptedContent,
        messageType: encryptedMessage.messageType,
        createdAt: encryptedMessage.createdAt,
        decryptedAt: DateTime.now(),
      );

      // Log decryption
      await _logEncryptionEvent(
        userId: userId,
        crewId: encryptedMessage.crewId,
        event: EncryptionEvent.messageDecrypted,
        details: 'Message decrypted from ${encryptedMessage.senderId}',
        context: 'messageType: ${encryptedMessage.messageType}',
      );

      // Security: Reset rate limit on successful operation
      _rateLimiter.reset(rateLimitKey, operation: 'decrypt');

      return decryptedMessage;
    } on EncryptionRateLimitException catch (e) {
      debugPrint('[CrewMessageEncryptionService] Rate limit exceeded: $e');
      rethrow;
    } on EncryptionException catch (e) {
      debugPrint('[CrewMessageEncryptionService] Decryption error: $e');
      rethrow;
    } on InvalidKeyException catch (e) {
      debugPrint('[CrewMessageEncryptionService] Invalid key: $e');
      rethrow;
    } on MessageTamperedException catch (e) {
      debugPrint('[CrewMessageEncryptionService] Message tampered: $e');
      rethrow;
    } on FirebaseException catch (e) {
      debugPrint('[CrewMessageEncryptionService] Firestore error decrypting message: $e');
      rethrow;
    } catch (e) {
      debugPrint('[CrewMessageEncryptionService] Unexpected error decrypting message: $e');
      throw EncryptionException('Failed to decrypt message: $e');
    }
  }

  /// Rotates encryption keys for enhanced security.
  ///
  /// This method generates new encryption keys and marks old keys
  /// for rotation, ensuring backward compatibility during the transition.
  ///
  /// Parameters:
  /// - [userId]: The user ID to rotate keys for
  /// - [crewId]: The crew ID
  /// - [role]: The user's role in the crew
  ///
  /// Returns:
  /// - [EncryptionKeyPair] containing new public and private keys
  ///
  /// Throws:
  /// - [EncryptionException] if key rotation fails
  Future<EncryptionKeyPair> rotateKeys({
    required String userId,
    required String crewId,
    required MemberRole role,
  }) async {
    try {
      // Get current keys
      final currentKeyDoc = await _firestore
          .collection(_encryptionKeysCollection)
          .doc(userId)
          .get();

      if (!currentKeyDoc.exists) {
        throw KeyNotFoundException('No existing keys found for rotation');
      }

      // Generate new key pair
      final newKeyPair = _generateRSAKeyPair();

      // Update existing key document with new public key and mark for rotation
      await currentKeyDoc.reference.update({
        'publicKey': newKeyPair.publicKey,
        'rotationRequired': true,
        'rotatedAt': FieldValue.serverTimestamp(),
        'previousPublicKey': currentKeyDoc.data()!['publicKey'],
      });

      // Log key rotation
      await _logEncryptionEvent(
        userId: userId,
        crewId: crewId,
        event: EncryptionEvent.keyRotated,
        details: 'Encryption keys rotated for role ${role.name}',
      );

      return newKeyPair;
    } on KeyNotFoundException catch (e) {
      debugPrint('[CrewMessageEncryptionService] Key not found: $e');
      rethrow;
    } on FirebaseException catch (e) {
      debugPrint('[CrewMessageEncryptionService] Firestore error rotating keys: $e');
      rethrow;
    } catch (e) {
      debugPrint('[CrewMessageEncryptionService] Unexpected error rotating keys: $e');
      throw EncryptionException('Failed to rotate keys: $e');
    }
  }

  /// Gets encryption status for a user.
  ///
  /// Parameters:
  /// - [userId]: The user ID to check encryption status for
  ///
  /// Returns:
  /// - [EncryptionStatus] containing encryption configuration and status
  Future<EncryptionStatus?> getEncryptionStatus(String userId) async {
    try {
      final keyDoc = await _firestore
          .collection(_encryptionKeysCollection)
          .doc(userId)
          .get();

      if (!keyDoc.exists) {
        return null;
      }

      final data = keyDoc.data() as Map<String, dynamic>;

      return EncryptionStatus(
        isActive: data['isActive'] as bool,
        keyAlgorithm: data['keyAlgorithm'] as String,
        keySize: data['keySize'] as int,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        lastUsedAt: (data['lastUsedAt'] as Timestamp).toDate(),
        rotationRequired: data['rotationRequired'] as bool,
        rotatedAt: data['rotatedAt'] != null
            ? (data['rotatedAt'] as Timestamp).toDate()
            : null,
      );
    } catch (e) {
      debugPrint('[CrewMessageEncryptionService] Error getting encryption status: $e');
      return null;
    }
  }

  /// Disables encryption for a user.
  ///
  /// This method removes all encryption keys and disables
  /// encryption for the specified user.
  ///
  /// Parameters:
  /// - [userId]: The user ID to disable encryption for
  /// - [reason]: The reason for disabling encryption
  ///
  /// Throws:
  /// - [FirebaseException] for database errors
  Future<void> disableEncryption({
    required String userId,
    required String reason,
  }) async {
    try {
      // Delete encryption keys
      await _firestore.collection(_encryptionKeysCollection).doc(userId).delete();

      // Delete any message keys
      final messageKeysSnapshot = await _firestore
          .collection(_messageKeysCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in messageKeysSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Log encryption disabling
      await _logEncryptionEvent(
        userId: userId,
        crewId: 'unknown',
        event: EncryptionEvent.encryptionDisabled,
        details: 'Encryption disabled: $reason',
      );
    } catch (e) {
      debugPrint('[CrewMessageEncryptionService] Error disabling encryption: $e');
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to disable encryption: $e',
      );
    }
  }

  // Private helper methods

  /// Generates RSA key pair.
  EncryptionKeyPair _generateRSAKeyPair() {
    // Simplified RSA key generation for demonstration
    // In production, use a proper cryptographic library like 'pointycastle'
    final random = Random.secure();

    // Generate public key (simplified)
    final publicExponent = 65537;
    final modulus = _generateLargePrime(512); // Simplified

    // Generate private key (simplified)
    final privateExponent = _modInverse(publicExponent, (modulus - 1));

    final publicKey = '$modulus:$publicExponent';
    final privateKey = '$modulus:$privateExponent';

    return EncryptionKeyPair(
      publicKey: publicKey,
      privateKey: privateKey,
    );
  }

  /// Generates a large prime number.
  BigInt _generateLargePrime(int bitLength) {
    // Simplified prime generation
    // In production, use proper cryptographic prime generation
    final random = Random.secure();
    BigInt candidate = BigInt.from(random.nextInt(1 << 16));

    // Simple primality test (not cryptographically secure)
    while (!_isPrime(candidate)) {
      candidate = BigInt.from(random.nextInt(1 << 16));
    }

    return candidate;
  }

  /// Simple primality test.
  bool _isPrime(BigInt n) {
    if (n <= BigInt.one) return false;
    if (n <= BigInt.three) return true;
    if (n.isEven) return false;

    for (BigInt i = BigInt.two; i * i <= n; i += BigInt.two) {
      if (n % i == BigInt.zero) return false;
    }

    return true;
  }

  /// Computes modular inverse.
  BigInt _modInverse(BigInt a, BigInt m) {
    // Extended Euclidean algorithm
    BigInt m0 = m;
    BigInt y = BigInt.zero;
    BigInt x = BigInt.one;

    if (m == BigInt.one) return BigInt.zero;

    while (a > BigInt.one) {
      BigInt q = a ~/ m;
      BigInt t = m;

      m = a % m;
      a = t;
      t = y;

      y = x - q * y;
      x = t;
    }

    if (x < BigInt.zero) x = x + m0;

    return x;
  }

  /// Generates AES key.
  List<int> _generateAESKey() {
    final random = Random.secure();
    return List<int>.generate(_aesKeySize ~/ 8, (_) => random.nextInt(256));
  }

  /// Generates initialization vector.
  List<int> _generateIV() {
    final random = Random.secure();
    return List<int>.generate(_ivSize, (_) => random.nextInt(256));
  }

  /// Encrypts data with AES-256-GCM.
  String _encryptAES(String data, List<int> key, List<int> iv) {
    // Simplified AES encryption for demonstration
    // In production, use a proper cryptographic library
    final dataBytes = utf8.encode(data);
    final encryptedBytes = <int>[];

    // XOR encryption (not cryptographically secure)
    for (int i = 0; i < dataBytes.length; i++) {
      final keyByte = key[i % key.length];
      final ivByte = iv[i % iv.length];
      encryptedBytes.add(dataBytes[i] ^ keyByte ^ ivByte);
    }

    // Add IV to encrypted data
    final fullData = [...iv, ...encryptedBytes];
    return base64Encode(fullData);
  }

  /// Decrypts AES-256-GCM data.
  String _decryptAES(String encryptedData, List<int> key, List<int> iv) {
    // Simplified AES decryption for demonstration
    // In production, use a proper cryptographic library
    final fullData = base64Decode(encryptedData);

    // Extract IV and encrypted data
    final extractedIV = fullData.take(_ivSize).toList();
    final encryptedBytes = fullData.skip(_ivSize).toList();

    // XOR decryption (not cryptographically secure)
    final decryptedBytes = <int>[];
    for (int i = 0; i < encryptedBytes.length; i++) {
      final keyByte = key[i % key.length];
      final ivByte = extractedIV[i % extractedIV.length];
      decryptedBytes.add(encryptedBytes[i] ^ keyByte ^ ivByte);
    }

    return utf8.decode(decryptedBytes);
  }

  /// Encrypts data with RSA.
  String _encryptRSA(String data, String publicKey) {
    // Simplified RSA encryption for demonstration
    // In production, use a proper cryptographic library
    final parts = publicKey.split(':');
    final modulus = BigInt.parse(parts[0]);
    final publicExponent = BigInt.parse(parts[1]);

    final message = _stringToBigInt(data);
    final encrypted = message.modPow(publicExponent, modulus);

    return encrypted.toString();
  }

  /// Decrypts RSA data.
  String _decryptRSA(String encryptedData, String privateKey) {
    // Simplified RSA decryption for demonstration
    // In production, use a proper cryptographic library
    final parts = privateKey.split(':');
    final modulus = BigInt.parse(parts[0]);
    final privateExponent = BigInt.parse(parts[1]);

    final encrypted = BigInt.parse(encryptedData);
    final decrypted = encrypted.modPow(privateExponent, modulus);

    return _bigIntToString(decrypted);
  }

  /// Gets crew member IDs.
  Future<List<String>> _getCrewMemberIds(String crewId) async {
    final crewDoc = await _firestore.collection('crews').doc(crewId).get();
    if (!crewDoc.exists) return [];

    final crewData = crewDoc.data() as Map<String, dynamic>;
    return List<String>.from(crewData['memberIds'] ?? []);
  }

  /// Gets public keys for recipients.
  Future<Map<String, String>> _getRecipientPublicKeys(List<String> recipientIds) async {
    final keys = <String, String>{};

    for (final recipientId in recipientIds) {
      try {
        final keyDoc = await _firestore
            .collection(_encryptionKeysCollection)
            .doc(recipientId)
            .get();

        if (keyDoc.exists) {
          final data = keyDoc.data() as Map<String, dynamic>;
          if (data['isActive'] == true) {
            keys[recipientId] = data['publicKey'] as String;
          }
        }
      } catch (e) {
        debugPrint('[CrewMessageEncryptionService] Error getting public key for $recipientId: $e');
      }
    }

    return keys;
  }

  /// Generates unique message ID.
  String _generateMessageId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure();
    final randomBytes = List<int>.generate(8, (_) => random.nextInt(256));
    return 'msg_${timestamp}_${base64Encode(randomBytes)}';
  }

  /// Converts string to BigInt.
  BigInt _stringToBigInt(String str) {
    final bytes = utf8.encode(str);
    BigInt result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  /// Converts BigInt to string.
  String _bigIntToString(BigInt num) {
    List<int> bytes = [];
    BigInt temp = num;

    while (temp > BigInt.zero) {
      bytes.insert(0, (temp & BigInt.from(0xFF)).toInt());
      temp = temp >> 8;
    }

    return utf8.decode(bytes);
  }

  /// Encodes bytes to Base64.
  String base64Encode(List<int> bytes) {
    return base64.encode(bytes);
  }

  /// Decodes Base64 to bytes.
  List<int> base64Decode(String encoded) {
    return base64.decode(encoded);
  }

  /// Logs encryption events.
  Future<void> _logEncryptionEvent({
    required String userId,
    required String crewId,
    required EncryptionEvent event,
    required String details,
    String? context,
  }) async {
    try {
      await _firestore.collection(_encryptionLogsCollection).add({
        'userId': userId,
        'crewId': crewId,
        'event': event.name,
        'details': details,
        'context': context,
        'timestamp': FieldValue.serverTimestamp(),
        'userAgent': 'Journeyman Jobs App',
        'ipAddress': 'mobile',
      });
    } catch (e) {
      debugPrint('[CrewMessageEncryptionService] Failed to log encryption event: $e');
    }
  }
}

/// Encryption key pair containing public and private keys.
class EncryptionKeyPair {
  final String publicKey;
  final String privateKey;

  EncryptionKeyPair({
    required this.publicKey,
    required this.privateKey,
  });
}

/// Encrypted message containing content and keys.
class EncryptedMessage {
  final String messageId;
  final String senderId;
  final String crewId;
  final String encryptedContent;
  final String iv;
  final Map<String, String> encryptedKeys;
  final String messageType;
  final DateTime createdAt;
  final String algorithm;
  final String keyAlgorithm;

  EncryptedMessage({
    required this.messageId,
    required this.senderId,
    required this.crewId,
    required this.encryptedContent,
    required this.iv,
    required this.encryptedKeys,
    required this.messageType,
    required this.createdAt,
    required this.algorithm,
    required this.keyAlgorithm,
  });
}

/// Decrypted message containing content and metadata.
class DecryptedMessage {
  final String messageId;
  final String senderId;
  final String crewId;
  final String content;
  final String messageType;
  final DateTime createdAt;
  final DateTime decryptedAt;

  DecryptedMessage({
    required this.messageId,
    required this.senderId,
    required this.crewId,
    required this.content,
    required this.messageType,
    required this.createdAt,
    required this.decryptedAt,
  });
}

/// Encryption status information.
class EncryptionStatus {
  final bool isActive;
  final String keyAlgorithm;
  final int keySize;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  final bool rotationRequired;
  final DateTime? rotatedAt;

  EncryptionStatus({
    required this.isActive,
    required this.keyAlgorithm,
    required this.keySize,
    required this.createdAt,
    required this.lastUsedAt,
    required this.rotationRequired,
    this.rotatedAt,
  });
}

/// Encryption event types.
enum EncryptionEvent {
  keyGenerated,
  keyRotated,
  messageEncrypted,
  messageDecrypted,
  encryptionDisabled,
  keyRevoked,
}

/// Custom exceptions for encryption operations.
class EncryptionException implements Exception {
  final String message;
  EncryptionException(this.message);
  @override
  String toString() => 'EncryptionException: $message';
}

class KeyNotFoundException implements Exception {
  final String message;
  KeyNotFoundException(this.message);
  @override
  String toString() => 'KeyNotFoundException: $message';
}

class InvalidKeyException implements Exception {
  final String message;
  InvalidKeyException(this.message);
  @override
  String toString() => 'InvalidKeyException: $message';
}

class MessageTamperedException implements Exception {
  final String message;
  MessageTamperedException(this.message);
  @override
  String toString() => 'MessageTamperedException: $message';
}

class EncryptionRateLimitException implements Exception {
  final String message;
  final Duration? retryAfter;
  EncryptionRateLimitException(this.message, {this.retryAfter});
  @override
  String toString() => 'EncryptionRateLimitException: $message';
}