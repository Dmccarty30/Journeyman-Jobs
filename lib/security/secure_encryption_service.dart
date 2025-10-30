import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';
import 'package:cryptography/cryptography.dart';

/// Secure cryptographic service implementing industry-standard encryption
///
/// This service provides cryptographically secure encryption capabilities
/// using AES-256-GCM for symmetric encryption and RSA for asymmetric operations.
/// All implementations follow NIST and FIPS-140-2 guidelines.
///
/// Features:
/// - AES-256-GCM encryption with authenticated encryption
/// - Secure RSA key generation with proper randomness
/// - Key derivation functions (PBKDF2) for secure key management
/// - Cryptographically secure random number generation
/// - Constant-time operations to prevent timing attacks
class SecureEncryptionService {
  static const int _aesKeySize = 32; // 256 bits
  static const int _ivSize = 12; // 96 bits (recommended for GCM)
  static const int _saltSize = 32; // 256 bits
  static const int _pbkdf2Iterations = 100000;
  static const int _rsaKeySize = 2048;

  /// Secure random number generator
  static final SecureRandom _secureRandom = _getSecureRandom();

  /// Generates a cryptographically secure random key
  static Uint8List generateSecureKey({int size = _aesKeySize}) {
    final key = Uint8List(size);
    for (int i = 0; i < size; i++) {
      key[i] = _secureRandom.nextUint8();
    }
    return key;
  }

  /// Generates a cryptographically secure random IV/nonce
  static Uint8List generateIV({int size = _ivSize}) {
    final iv = Uint8List(size);
    for (int i = 0; i < size; i++) {
      iv[i] = _secureRandom.nextUint8();
    }
    return iv;
  }

  /// Generates a secure random salt for key derivation
  static Uint8List generateSalt({int size = _saltSize}) {
    final salt = Uint8List(size);
    for (int i = 0; i < size; i++) {
      salt[i] = _secureRandom.nextUint8();
    }
    return salt;
  }

  /// Derives a key from password using PBKDF2
  static Uint8List deriveKey(String password, Uint8List salt, {int iterations = _pbkdf2Iterations}) {
    final passwordBytes = utf8.encode(password);
    final keyDerivator = PBKDF2KeyDerivator(
      HMac(SHA256Digest(), _aesKeySize),
    );
    keyDerivator.init(Pbkdf2Parameters(salt, iterations, _aesKeySize));
    return keyDerivator.process(passwordBytes);
  }

  /// Encrypts data using AES-256-GCM (Authenticated Encryption)
  static EncryptedData encryptAESGCM(Uint8List plaintext, Uint8List key) {
    if (key.length != _aesKeySize) {
      throw ArgumentError('Key must be $_aesKeySize bytes for AES-256');
    }

    final iv = generateIV();
    final keyParam = KeyParameter(key);
    final params = AEADParameters(keyParam, 128, iv); // 128-bit auth tag

    final cipher = GCMBlockCipher(AESEngine();
    cipher.init(true, params);

    final ciphertext = cipher.process(plaintext);
    final authTag = cipher.mac;

    return EncryptedData(
      ciphertext: ciphertext,
      iv: iv,
      authTag: authTag,
    );
  }

  /// Decrypts data using AES-256-GCM (Authenticated Encryption)
  static Uint8List decryptAESGCM(EncryptedData encryptedData, Uint8List key) {
    if (key.length != _aesKeySize) {
      throw ArgumentError('Key must be $_aesKeySize bytes for AES-256');
    }

    final keyParam = KeyParameter(key);
    final params = AEADParameters(keyParam, 128, encryptedData.iv);

    final cipher = GCMBlockCipher(AESEngine();
    cipher.init(false, params);

    // Set the MAC tag before processing
    final expectedTag = encryptedData.authTag;
    if (expectedTag.length != 16) {
      throw ArgumentError('Authentication tag must be 16 bytes');
    }

    try {
      final plaintext = cipher.process(encryptedData.ciphertext);

      // Verify authentication tag
      final computedTag = cipher.mac;
      if (!_constantTimeEquals(expectedTag, computedTag)) {
        throw StateError('Authentication failed - data may have been tampered with');
      }

      return plaintext;
    } catch (e) {
      if (e is StateError) rethrow;
      throw StateError('Decryption failed: $e');
    }
  }

  /// Encrypts a string using AES-256-GCM
  static String encryptStringAESGCM(String plaintext, String password) {
    final salt = generateSalt();
    final key = deriveKey(password, salt);

    final plaintextBytes = utf8.encode(plaintext);
    final encryptedData = encryptAESGCM(Uint8List.fromList(plaintextBytes), key);

    // Combine salt + iv + authTag + ciphertext
    final combined = [
      ...salt,
      ...encryptedData.iv,
      ...encryptedData.authTag,
      ...encryptedData.ciphertext,
    ];

    return base64Encode(combined);
  }

  /// Decrypts a string using AES-256-GCM
  static String decryptStringAESGCM(String encryptedBase64, String password) {
    try {
      final combined = base64Decode(encryptedBase64);

      // Extract components
      final salt = combined.sublist(0, _saltSize);
      final iv = combined.sublist(_saltSize, _saltSize + _ivSize);
      final authTag = combined.sublist(_saltSize + _ivSize, _saltSize + _ivSize + 16);
      final ciphertext = combined.sublist(_saltSize + _ivSize + 16);

      final key = deriveKey(password, salt);
      final encryptedData = EncryptedData(
        ciphertext: ciphertext,
        iv: iv,
        authTag: authTag,
      );

      final decryptedBytes = decryptAESGCM(encryptedData, key);
      return utf8.decode(decryptedBytes);
    } catch (e) {
      throw StateError('Failed to decrypt string: $e');
    }
  }

  /// Generates a secure RSA key pair
  static Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>> generateRSAKeyPair() async {
    final keyGenerator = RSAKeyGenerator();
    final params = RSAKeyGeneratorParameters(
      BigInt.parse('65537'), // Public exponent
      _rsaKeySize,
      64, // Certainty
    );
    final secureRandom = _getSecureRandom();
    keyGenerator.init(ParametersWithRandom(params, secureRandom);

    return keyGenerator.generateKeyPair();
  }

  /// Encrypts data using RSA-OAEP
  static Uint8List encryptRSA(Uint8List data, RSAPublicKey publicKey) {
    final encryptor = OAEPEncoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey);
    return _processInBlocks(encryptor, data);
  }

  /// Decrypts data using RSA-OAEP
  static Uint8List decryptRSA(Uint8List encryptedData, RSAPrivateKey privateKey) {
    final decryptor = OAEPEncoding(RSAEngine())
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey);
    return _processInBlocks(decryptor, encryptedData);
  }

  /// Constant-time comparison to prevent timing attacks
  static bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  /// Process data in blocks for RSA operations
  static Uint8List _processInBlocks(AsymmetricBlockCipher cipher, Uint8List data) {
    final blockSize = cipher.inputBlockSize;
    final output = <int>[];

    for (int i = 0; i < data.length; i += blockSize) {
      final end = (i + blockSize > data.length) ? data.length : i + blockSize;
      final block = data.sublist(i, end);
      output.addAll(cipher.process(block);
    }

    return Uint8List.fromList(output);
  }

  /// Get cryptographically secure random number generator
  static SecureRandom _getSecureRandom() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(256);
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds));
    return secureRandom;
  }
}

/// Container for encrypted data with metadata
class EncryptedData {
  final Uint8List ciphertext;
  final Uint8List iv;
  final Uint8List authTag;

  EncryptedData({
    required this.ciphertext,
    required this.iv,
    required this.authTag,
  });

  /// Converts encrypted data to base64 string
  String toBase64() {
    final combined = [...iv, ...authTag, ...ciphertext];
    return base64Encode(combined);
  }

  /// Creates encrypted data from base64 string
  static EncryptedData fromBase64(String base64) {
    final combined = base64Decode(base64);

    if (combined.length < 28) { // 12 bytes IV + 16 bytes auth tag minimum
      throw ArgumentError('Invalid encrypted data format');
    }

    final iv = combined.sublist(0, 12);
    final authTag = combined.sublist(12, 28);
    final ciphertext = combined.sublist(28);

    return EncryptedData(
      ciphertext: ciphertext,
      iv: iv,
      authTag: authTag,
    );
  }
}

/// Custom exception for encryption operations
class EncryptionException implements Exception {
  final String message;
  final dynamic cause;

  const EncryptionException(this.message, [this.cause]);

  @override
  String toString() => 'EncryptionException: $message${cause != null ? ' (Caused by: $cause)' : ''}';
}