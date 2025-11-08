import 'package:flutter/material.dart';

/// Represents different transformer bank configurations
enum TransformerBankType {
  wyeToWye,
  deltaToDelta,
  wyeToDelta,
  deltaToWye,
  openDelta,
}

/// Training mode - guided learning vs quiz testing
enum TrainingMode {
  guided,  // Step-by-step with hints
  quiz,    // Test knowledge without guidance
}

/// Difficulty levels with different voltage scenarios
enum DifficultyLevel {
  beginner,     // 120V/240V basic residential
  intermediate, // 240V/480V light commercial  
  advanced,     // 480V+ industrial scenarios
}

/// Connection mode for the workbench
enum ConnectionMode {
  stickyKeys,  // Tap to connect
  dragAndDrop, // Drag to connect
}

/// Represents a connection point on the transformer diagram
class ConnectionPoint {
  
  const ConnectionPoint({
    required this.id,
    required this.position,
    required this.label,
    required this.type,
    required this.isInput,
  });

  factory ConnectionPoint.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> pos = json['position'] as Map<String, dynamic>;
    return ConnectionPoint(
      id: json['id'] as String,
      position: Offset((pos['dx'] as num).toDouble(), (pos['dy'] as num).toDouble()),
      label: json['label'] as String,
      type: ConnectionType.values.firstWhere((ConnectionType e) => e.name == (json['type'] as String), orElse: () => ConnectionType.primary),
      isInput: json['isInput'] as bool? ?? false,
    );
  }
  final String id;
  final Offset position;
  final String label;
  final ConnectionType type;
  final bool isInput;

  Map<String, dynamic> toJson() => <String, dynamic>{
      'id': id,
      'position': <String, double>{'dx': position.dx, 'dy': position.dy},
      'label': label,
      'type': type.name,
      'isInput': isInput,
    };
}

/// Types of electrical connections
enum ConnectionType {
  primary,    // High voltage side (H1, H2)
  secondary,  // Low voltage side (X1, X2, X3)
  neutral,    // Neutral connections
  ground,     // Ground connections
}

/// Represents a wire connection between two points
class WireConnection {
  
  const WireConnection({
    required this.fromPointId,
    required this.toPointId,
    required this.isCorrect,
    this.errorReason,
    this.color = Colors.red,
    this.phase = 'A',
  });

  factory WireConnection.fromJson(Map<String, dynamic> json) => WireConnection(
      fromPointId: json['fromPointId'] as String,
      toPointId: json['toPointId'] as String,
      isCorrect: json['isCorrect'] as bool? ?? false,
      errorReason: json['errorReason'] as String?,
      color: json['color'] != null ? Color(json['color'] as int) : Colors.red,
      phase: json['phase'] as String? ?? 'A',
    );
  final String fromPointId;
  final String toPointId;
  final bool isCorrect;
  final String? errorReason;
  final Color color;
  final String phase;

  Map<String, dynamic> toJson() => <String, dynamic>{
      'fromPointId': fromPointId,
      'toPointId': toPointId,
      'isCorrect': isCorrect,
      'errorReason': errorReason,
      'color': color.toARGB32(),
      'phase': phase,
    };
}

/// Represents the current state of the training session
class TrainingState {
  
  const TrainingState({
    required this.bankType,
    required this.mode,
    required this.difficulty,
    this.connections = const <WireConnection>[],
    this.currentStep = 0,
    this.isComplete = false,
    this.completedSteps = const <String>[],
  });

  factory TrainingState.fromJson(Map<String, dynamic> json) => TrainingState(
      bankType: TransformerBankType.values.firstWhere((TransformerBankType e) => e.name == (json['bankType'] as String), orElse: () => TransformerBankType.wyeToWye),
      mode: TrainingMode.values.firstWhere((TrainingMode e) => e.name == (json['mode'] as String), orElse: () => TrainingMode.guided),
      difficulty: DifficultyLevel.values.firstWhere((DifficultyLevel e) => e.name == (json['difficulty'] as String), orElse: () => DifficultyLevel.beginner),
      connections: (json['connections'] as List<dynamic>?)
          ?.map((c) => WireConnection.fromJson(c as Map<String, dynamic>))
          .toList() ??
          const <WireConnection>[],
      currentStep: json['currentStep'] as int? ?? 0,
      isComplete: json['isComplete'] as bool? ?? false,
      completedSteps: (json['completedSteps'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
    );
  final TransformerBankType bankType;
  final TrainingMode mode;
  final DifficultyLevel difficulty;
  final List<WireConnection> connections;
  final int currentStep;
  final bool isComplete;
  final List<String> completedSteps;
  
  TrainingState copyWith({
    TransformerBankType? bankType,
    TrainingMode? mode,
    DifficultyLevel? difficulty,
    List<WireConnection>? connections,
    int? currentStep,
    bool? isComplete,
    List<String>? completedSteps,
  }) => TrainingState(
      bankType: bankType ?? this.bankType,
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
      connections: connections ?? this.connections,
      currentStep: currentStep ?? this.currentStep,
      isComplete: isComplete ?? this.isComplete,
      completedSteps: completedSteps ?? this.completedSteps,
    );

  Map<String, dynamic> toJson() => <String, dynamic>{
      'bankType': bankType.name,
      'mode': mode.name,
      'difficulty': difficulty.name,
      'connections': connections.map((WireConnection c) => c.toJson()).toList(),
      'currentStep': currentStep,
      'isComplete': isComplete,
      'completedSteps': completedSteps,
    };
}

/// Voltage scenario for different difficulty levels
class VoltageScenario {
  
  const VoltageScenario({
    required this.name,
    required this.voltages,
    required this.description,
  });
  final String name;
  final Map<String, int> voltages;
  final String description;
}

/// Step in the guided training mode
class TrainingStep {
  
  const TrainingStep({
    required this.stepNumber,
    required this.instruction,
    required this.explanation,
    required this.requiredConnections,
    this.safetyNote,
    this.commonMistake,
  });

  factory TrainingStep.fromJson(Map<String, dynamic> json) => TrainingStep(
      stepNumber: json['stepNumber'] as int,
      instruction: json['instruction'] as String,
      explanation: json['explanation'] as String,
      requiredConnections: List<String>.from(json['requiredConnections'] as List),
      safetyNote: json['safetyNote'] as String?,
      commonMistake: json['commonMistake'] as String?,
    );
  final int stepNumber;
  final String instruction;
  final String explanation;
  final List<String> requiredConnections;
  final String? safetyNote;
  final String? commonMistake;

  Map<String, dynamic> toJson() => <String, dynamic>{
      'stepNumber': stepNumber,
      'instruction': instruction,
      'explanation': explanation,
      'requiredConnections': requiredConnections,
      'safetyNote': safetyNote,
      'commonMistake': commonMistake,
    };
}
