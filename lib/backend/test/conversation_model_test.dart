import 'package:test/test.dart';
import '../schema/conversation_model.dart';

void main() {
  group('ConversationModel', () {
    group('toJson', () {
      test('should convert model to JSON correctly', () {
        // Arrange
        final model = ConversationModel(
          id: 'conv123',
          name: 'Test Conversation',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], equals('conv123'));
        expect(json['name'], equals('Test Conversation'));
      });

      test('should include all fields in JSON', () {
        // Arrange
        final model = ConversationModel(
          id: 'uniqueId',
          name: 'My Chat',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json.keys.length, equals(2));
        expect(json.containsKey('id'), isTrue);
        expect(json.containsKey('name'), isTrue);
      });
    });

    group('fromJson', () {
      test('should create model from JSON correctly', () {
        // Arrange
        final json = {
          'id': 'conv456',
          'name': 'Another Conversation',
        };

        // Act
        final model = ConversationModel.fromJson(json);

        // Assert
        expect(model.id, equals('conv456'));
        expect(model.name, equals('Another Conversation'));
      });

      test('should handle empty strings', () {
        // Arrange
        final json = {
          'id': '',
          'name': '',
        };

        // Act
        final model = ConversationModel.fromJson(json);

        // Assert
        expect(model.id, equals(''));
        expect(model.name, equals(''));
      });

      test('should round-trip correctly', () {
        // Arrange
        final original = ConversationModel(
          id: 'roundTrip123',
          name: 'Round Trip Test',
        );

        // Act
        final json = original.toJson();
        final restored = ConversationModel.fromJson(json);

        // Assert
        expect(restored.id, equals(original.id));
        expect(restored.name, equals(original.name));
      });
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        // Arrange
        final model1 = ConversationModel(
          id: 'same123',
          name: 'Same Name',
        );
        final model2 = ConversationModel(
          id: 'same123',
          name: 'Same Name',
        );

        // Act & Assert
        expect(model1, equals(model2));
        expect(model1 == model2, isTrue);
      });

      test('should not be equal when id differs', () {
        // Arrange
        final model1 = ConversationModel(
          id: 'id1',
          name: 'Same Name',
        );
        final model2 = ConversationModel(
          id: 'id2',
          name: 'Same Name',
        );

        // Act & Assert
        expect(model1, isNot(equals(model2)));
        expect(model1 == model2, isFalse);
      });

      test('should not be equal when name differs', () {
        // Arrange
        final model1 = ConversationModel(
          id: 'sameId',
          name: 'Name 1',
        );
        final model2 = ConversationModel(
          id: 'sameId',
          name: 'Name 2',
        );

        // Act & Assert
        expect(model1, isNot(equals(model2)));
        expect(model1 == model2, isFalse);
      });

      test('should be equal to itself', () {
        // Arrange
        final model = ConversationModel(
          id: 'self123',
          name: 'Self Test',
        );

        // Act & Assert
        expect(model, equals(model));
        expect(model == model, isTrue);
      });

      test('should not be equal to null', () {
        // Arrange
        final model = ConversationModel(
          id: 'notNull',
          name: 'Not Null',
        );

        // Act & Assert
        expect(model == null, isFalse);
      });

      test('should not be equal to different type', () {
        // Arrange
        final model = ConversationModel(
          id: 'type123',
          name: 'Type Test',
        );
        final notAModel = 'Not a ConversationModel';

        // Act & Assert
        expect(model == notAModel, isFalse);
      });
    });

    group('hashCode', () {
      test('should have same hashCode for equal objects', () {
        // Arrange
        final model1 = ConversationModel(
          id: 'hash123',
          name: 'Hash Test',
        );
        final model2 = ConversationModel(
          id: 'hash123',
          name: 'Hash Test',
        );

        // Act & Assert
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should have different hashCode for different ids', () {
        // Arrange
        final model1 = ConversationModel(
          id: 'hash1',
          name: 'Same Name',
        );
        final model2 = ConversationModel(
          id: 'hash2',
          name: 'Same Name',
        );

        // Act & Assert
        // Note: Different objects CAN have the same hashCode (collision),
        // but it's very unlikely with different data
        expect(model1.hashCode == model2.hashCode, isFalse);
      });

      test('should have different hashCode for different names', () {
        // Arrange
        final model1 = ConversationModel(
          id: 'sameId',
          name: 'Name 1',
        );
        final model2 = ConversationModel(
          id: 'sameId',
          name: 'Name 2',
        );

        // Act & Assert
        expect(model1.hashCode == model2.hashCode, isFalse);
      });

      test('should be consistent across multiple calls', () {
        // Arrange
        final model = ConversationModel(
          id: 'consistent123',
          name: 'Consistent Hash',
        );

        // Act
        final hash1 = model.hashCode;
        final hash2 = model.hashCode;
        final hash3 = model.hashCode;

        // Assert
        expect(hash1, equals(hash2));
        expect(hash2, equals(hash3));
      });
    });

    group('edge cases', () {
      test('should handle special characters in strings', () {
        // Arrange
        final model = ConversationModel(
          id: 'special!@#\$%^&*()',
          name: 'Test with "quotes" and \'apostrophes\'',
        );

        // Act
        final json = model.toJson();
        final restored = ConversationModel.fromJson(json);

        // Assert
        expect(restored.id, equals(model.id));
        expect(restored.name, equals(model.name));
        expect(restored, equals(model));
      });

      test('should handle Unicode characters', () {
        // Arrange
        final model = ConversationModel(
          id: 'unicode123',
          name: 'Test 🚀 with 日本語 and émojis 🎉',
        );

        // Act
        final json = model.toJson();
        final restored = ConversationModel.fromJson(json);

        // Assert
        expect(restored.id, equals(model.id));
        expect(restored.name, equals(model.name));
        expect(restored, equals(model));
      });

      test('should handle very long strings', () {
        // Arrange
        final longString = 'a' * 1000;
        final model = ConversationModel(
          id: longString,
          name: longString + 'b',
        );

        // Act
        final json = model.toJson();
        final restored = ConversationModel.fromJson(json);

        // Assert
        expect(restored.id, equals(model.id));
        expect(restored.name, equals(model.name));
        expect(restored, equals(model));
      });
    });
  });
}
