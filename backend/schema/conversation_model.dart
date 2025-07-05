import 'package:meta/meta.dart';

/// Represents a conversation or chat model in the system.
/// 
/// This immutable class encapsulates the basic information needed
/// to identify and display a conversation.
@immutable
class ConversationModel {
  final String id;
  final String name;

  const ConversationModel({required this.id, required this.name});

  // Convert a ConversationModel into a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Create a ConversationModel from a Map
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('id') || json['id'] == null) {
      throw ArgumentError('Missing required field: id');
    }
    if (!json.containsKey('name') || json['name'] == null) {
      throw ArgumentError('Missing required field: name');
    }
    
    return ConversationModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationModel && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
