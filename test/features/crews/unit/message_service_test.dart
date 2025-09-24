import 'package:test/test.dart';
import 'package:journeyman_jobs/features/crews/models/message.dart';

void main() {
  group('Message Model Tests', () {
    test('Attachment should be created with correct properties', () {
      // Arrange
      final attachment = _createTestAttachment();

      // Act & Assert
      expect(attachment.url, equals('https://example.com/image.jpg'));
      expect(attachment.filename, equals('image.jpg'));
      expect(attachment.type, equals(AttachmentType.image));
      expect(attachment.sizeBytes, equals(1024));
      expect(attachment.thumbnailUrl, isNull);
    });

    test('Attachment formattedSize should return correct format', () {
      // Arrange
      final smallAttachment = Attachment(
        url: 'test.jpg',
        filename: 'test.jpg',
        type: AttachmentType.image,
        sizeBytes: 512,
      );

      final mediumAttachment = Attachment(
        url: 'test.jpg',
        filename: 'test.jpg',
        type: AttachmentType.image,
        sizeBytes: 1024 * 512, // 512KB
      );

      final largeAttachment = Attachment(
        url: 'test.jpg',
        filename: 'test.jpg',
        type: AttachmentType.image,
        sizeBytes: 1024 * 1024 * 2, // 2MB
      );

      // Act & Assert
      expect(smallAttachment.formattedSize, equals('512B'));
      expect(mediumAttachment.formattedSize, equals('512.0KB'));
      expect(largeAttachment.formattedSize, equals('2.0MB'));
    });

    test('Attachment type checks should work correctly', () {
      // Arrange
      final imageAttachment = Attachment(
        url: 'image.jpg',
        filename: 'image.jpg',
        type: AttachmentType.image,
        sizeBytes: 1024,
      );

      final videoAttachment = Attachment(
        url: 'video.mp4',
        filename: 'video.mp4',
        type: AttachmentType.video,
        sizeBytes: 1024,
      );

      final voiceAttachment = Attachment(
        url: 'voice.mp3',
        filename: 'voice.mp3',
        type: AttachmentType.voiceNote,
        sizeBytes: 1024,
      );

      // Act & Assert
      expect(imageAttachment.isImage, isTrue);
      expect(imageAttachment.isVideo, isFalse);
      expect(imageAttachment.isVoiceNote, isFalse);

      expect(videoAttachment.isImage, isFalse);
      expect(videoAttachment.isVideo, isTrue);
      expect(videoAttachment.isVoiceNote, isFalse);

      expect(voiceAttachment.isImage, isFalse);
      expect(voiceAttachment.isVideo, isFalse);
      expect(voiceAttachment.isVoiceNote, isTrue);
    });

    test('Message should be created with correct properties', () {
      // Arrange
      final message = _createTestMessage();

      // Act & Assert
      expect(message.id, equals('msg-123'));
      expect(message.senderId, equals('sender-123'));
      expect(message.recipientId, isNull);
      expect(message.crewId, equals('crew-123'));
      expect(message.content, equals('Test message content'));
      expect(message.type, equals(MessageType.text));
      expect(message.attachments, isNull);
      expect(message.sentAt, isA<DateTime>());
      expect(message.readBy, isEmpty);
      expect(message.isEdited, isFalse);
      expect(message.editedAt, isNull);
    });

    test('Message should identify message type correctly', () {
      // Arrange
      final crewMessage = Message(
        id: 'msg-1',
        senderId: 'sender-1',
        crewId: 'crew-1',
        content: 'Crew message',
        type: MessageType.text,
        sentAt: DateTime.now(),
        readBy: {},
        isEdited: false,
      );

      final directMessage = Message(
        id: 'msg-2',
        senderId: 'sender-1',
        recipientId: 'recipient-1',
        content: 'Direct message',
        type: MessageType.text,
        sentAt: DateTime.now(),
        readBy: {},
        isEdited: false,
      );

      // Act & Assert
      expect(crewMessage.isCrewMessage, isTrue);
      expect(crewMessage.isDirectMessage, isFalse);

      expect(directMessage.isCrewMessage, isFalse);
      expect(directMessage.isDirectMessage, isTrue);
    });

    test('Message should check for attachments correctly', () {
      // Arrange
      final messageWithoutAttachments = Message(
        id: 'msg-1',
        senderId: 'sender-1',
        content: 'Text message',
        type: MessageType.text,
        sentAt: DateTime.now(),
        readBy: {},
        isEdited: false,
      );

      final messageWithAttachments = Message(
        id: 'msg-2',
        senderId: 'sender-1',
        content: 'Message with attachment',
        type: MessageType.text,
        attachments: [_createTestAttachment()],
        sentAt: DateTime.now(),
        readBy: {},
        isEdited: false,
      );

      // Act & Assert
      expect(messageWithoutAttachments.hasAttachments, isFalse);
      expect(messageWithAttachments.hasAttachments, isTrue);
    });

    test('Message should handle read receipts correctly', () {
      // Arrange
      final message = _createTestMessage();
      const readerId = 'reader-123';

      // Act
      final updatedMessage = message.markAsRead(readerId);

      // Assert
      expect(updatedMessage.isReadBy(readerId), isTrue);
      expect(updatedMessage.readReceiptCount, equals(1));
      expect(updatedMessage.isUnread, isFalse);
    });

    test('Message should not duplicate read receipts', () {
      // Arrange
      final message = _createTestMessage();
      const readerId = 'reader-123';

      // Act - Mark as read twice
      final updatedMessage1 = message.markAsRead(readerId);
      final updatedMessage2 = updatedMessage1.markAsRead(readerId);

      // Assert
      expect(updatedMessage2.readReceiptCount, equals(1));
      expect(updatedMessage2.isReadBy(readerId), isTrue);
    });

    test('Message should get last read time correctly', () {
      // Arrange
      final message = _createTestMessage();
      final now = DateTime.now();

      // Act
      final updatedMessage = message
          .markAsRead('reader-1')
          .markAsRead('reader-2');

      // Assert
      expect(updatedMessage.lastReadTime, isNotNull);
      expect(updatedMessage.lastReadTime!.isAfter(now), isTrue);
    });

    test('Message should edit content correctly', () {
      // Arrange
      final message = _createTestMessage();
      const newContent = 'Updated message content';

      // Act
      final editedMessage = message.editContent(newContent);

      // Assert
      expect(editedMessage.content, equals(newContent));
      expect(editedMessage.isEdited, isTrue);
      expect(editedMessage.editedAt, isA<DateTime>());
    });

    test('Message should add attachment correctly', () {
      // Arrange
      final message = _createTestMessage();
      final newAttachment = Attachment(
        url: 'https://example.com/new.jpg',
        filename: 'new.jpg',
        type: AttachmentType.image,
        sizeBytes: 2048,
      );

      // Act
      final updatedMessage = message.addAttachment(newAttachment);

      // Assert
      expect(updatedMessage.attachments, isNotNull);
      expect(updatedMessage.attachments!.length, equals(1));
      expect(updatedMessage.attachments!.first, equals(newAttachment));
    });

    test('Message should remove attachment correctly', () {
      // Arrange
      final attachment = _createTestAttachment();
      final message = Message(
        id: 'msg-123',
        senderId: 'sender-123',
        content: 'Message with attachment',
        type: MessageType.text,
        attachments: [attachment],
        sentAt: DateTime.now(),
        readBy: {},
        isEdited: false,
      );

      // Act
      final updatedMessage = message.removeAttachment(attachment.url);

      // Assert
      expect(updatedMessage.attachments, isNull);
    });

    test('Message should handle different message types', () {
      // Test all message types
      expect(MessageType.text, isA<MessageType>());
      expect(MessageType.image, isA<MessageType>());
      expect(MessageType.voice, isA<MessageType>());
      expect(MessageType.document, isA<MessageType>());
      expect(MessageType.jobShare, isA<MessageType>());
      expect(MessageType.systemNotification, isA<MessageType>());
    });

    test('Message should handle different attachment types', () {
      // Test all attachment types
      expect(AttachmentType.image, isA<AttachmentType>());
      expect(AttachmentType.document, isA<AttachmentType>());
      expect(AttachmentType.voiceNote, isA<AttachmentType>());
      expect(AttachmentType.video, isA<AttachmentType>());
      expect(AttachmentType.certification, isA<AttachmentType>());
    });
  });

  group('Message Data Integrity Tests', () {
    test('Should maintain data consistency when marking as read', () {
      // Arrange
      final message = _createTestMessage();
      const readerId = 'reader-123';

      // Act
      final updatedMessage = message.markAsRead(readerId);

      // Assert
      expect(updatedMessage.isReadBy(readerId), isTrue);
      expect(updatedMessage.readReceiptCount, equals(1));
      expect(updatedMessage.isUnread, isFalse);
      expect(updatedMessage.lastReadTime, isNotNull);
    });

    test('Should handle empty data gracefully', () {
      // Arrange
      final emptyMessage = Message(
        id: '',
        senderId: '',
        content: '',
        type: MessageType.text,
        sentAt: DateTime.now(),
        readBy: {},
        isEdited: false,
      );

      // Act & Assert
      expect(emptyMessage.id, equals(''));
      expect(emptyMessage.senderId, equals(''));
      expect(emptyMessage.content, equals(''));
      expect(emptyMessage.readBy, isEmpty);
      expect(emptyMessage.isUnread, isTrue);
      expect(emptyMessage.lastReadTime, isNull);
    });

    test('Should handle message with multiple attachments', () {
      // Arrange
      final attachments = [
        Attachment(
          url: 'image1.jpg',
          filename: 'image1.jpg',
          type: AttachmentType.image,
          sizeBytes: 1024,
        ),
        Attachment(
          url: 'image2.jpg',
          filename: 'image2.jpg',
          type: AttachmentType.image,
          sizeBytes: 2048,
        ),
      ];

      final message = Message(
        id: 'msg-123',
        senderId: 'sender-123',
        content: 'Message with multiple attachments',
        type: MessageType.text,
        attachments: attachments,
        sentAt: DateTime.now(),
        readBy: {},
        isEdited: false,
      );

      // Act & Assert
      expect(message.attachments, isNotNull);
      expect(message.attachments!.length, equals(2));
      expect(message.hasAttachments, isTrue);
    });

    test('Should handle crew vs direct message scenarios', () {
      // Arrange
      final crewMessage = Message(
        id: 'crew-msg',
        senderId: 'sender-1',
        crewId: 'crew-123',
        content: 'Crew message',
        type: MessageType.text,
        sentAt: DateTime.now(),
        readBy: {'member-1': DateTime.now(), 'member-2': DateTime.now()},
        isEdited: false,
      );

      final directMessage = Message(
        id: 'dm-msg',
        senderId: 'sender-1',
        recipientId: 'recipient-1',
        content: 'Direct message',
        type: MessageType.text,
        sentAt: DateTime.now(),
        readBy: {'recipient-1': DateTime.now()},
        isEdited: false,
      );

      // Act & Assert
      expect(crewMessage.isCrewMessage, isTrue);
      expect(crewMessage.isDirectMessage, isFalse);
      expect(crewMessage.readReceiptCount, equals(2));

      expect(directMessage.isCrewMessage, isFalse);
      expect(directMessage.isDirectMessage, isTrue);
      expect(directMessage.readReceiptCount, equals(1));
    });
  });
}

// Helper functions for creating test data
Message _createTestMessage() {
  return Message(
    id: 'msg-123',
    senderId: 'sender-123',
    crewId: 'crew-123',
    content: 'Test message content',
    type: MessageType.text,
    sentAt: DateTime.now(),
    readBy: {},
    isEdited: false,
  );
}

Attachment _createTestAttachment() {
  return Attachment(
    url: 'https://example.com/image.jpg',
    filename: 'image.jpg',
    type: AttachmentType.image,
    sizeBytes: 1024,
  );
}