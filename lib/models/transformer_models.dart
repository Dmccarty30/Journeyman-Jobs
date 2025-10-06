import 'package:flutter/material.dart';

/// An enumeration of different transformer bank configurations for the training simulator.
enum TransformerBankType {
  /// A wye-connected primary to a wye-connected secondary.
  wyeToWye,
  /// A delta-connected primary to a delta-connected secondary.
  deltaToDelta,
  /// A wye-connected primary to a delta-connected secondary.
  wyeToDelta,
  /// A delta-connected primary to a wye-connected secondary.
  deltaToWye,
  /// An open delta configuration, using two transformers.
  openDelta,
}

/// An enumeration for the training mode in the simulator.
enum TrainingMode {
  /// A step-by-step learning mode with instructions and feedback.
  guided,
  /// A test mode where the user's knowledge is evaluated without guidance.
  quiz,
}

/// An enumeration for the difficulty level of the training scenario.
enum DifficultyLevel {
  /// Basic residential scenarios, typically 120V/240V.
  beginner,
  /// Light commercial scenarios, typically 240V/480V.
  intermediate,
  /// Complex industrial scenarios, typically 480V and above.
  advanced,
}

/// An enumeration for the user interaction mode on the connection workbench.
enum ConnectionMode {
  /// A mode where the user taps two connection points to create a wire.
  stickyKeys,
  /// A mode where the user drags a wire from one point to another.
  dragAndDrop,
}

/// Represents a single connection point (terminal) on a transformer diagram.
class ConnectionPoint {
  
  /// Creates an instance of [ConnectionPoint].
  const ConnectionPoint({
    required this.id,
    required this.position,
    required this.label,
    required this.type,
    required this.isInput,
  });

  /// Creates a [ConnectionPoint] instance from a JSON map.
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
  /// The unique identifier for this connection point (e.g., "H1_A").
  final String id;
  /// The x/y coordinates of the point on the diagram canvas.
  final Offset position;
  /// The label displayed next to the point (e.g., "H1").
  final String label;
  /// The type of electrical connection (e.g., primary, secondary).
  final ConnectionType type;
  /// A flag indicating if this is an input (source) or output terminal.
  final bool isInput;

  /// Serializes the [ConnectionPoint] to a JSON map.
  Map<String, dynamic> toJson() => <String, dynamic>{
      'id': id,
      'position': <String, double>{'dx': position.dx, 'dy': position.dy},
      'label': label,
      'type': type.name,
      'isInput': isInput,
    };
}

/// An enumeration of the types of electrical connection points.
enum ConnectionType {
  /// A high-voltage side terminal (e.g., H1, H2).
  primary,
  /// A low-voltage side terminal (e.g., X1, X2, X3).
  secondary,
  /// A neutral terminal.
  neutral,
  /// A ground terminal.
  ground,
}

/// Represents a wire connection between two [ConnectionPoint]s on the diagram.
class WireConnection {
  
  /// Creates an instance of [WireConnection].
  const WireConnection({
    required this.fromPointId,
    required this.toPointId,
    required this.isCorrect,
    this.errorReason,
    this.color = Colors.red,
    this.phase = 'A',
  });

  /// Creates a [WireConnection] instance from a JSON map.
  factory WireConnection.fromJson(Map<String, dynamic> json) => WireConnection(
      fromPointId: json['fromPointId'] as String,
      toPointId: json['toPointId'] as String,
      isCorrect: json['isCorrect'] as bool? ?? false,
      errorReason: json['errorReason'] as String?,
      color: json['color'] != null ? Color(json['color'] as int) : Colors.red,
      phase: json['phase'] as String? ?? 'A',
    );
  /// The ID of the starting [ConnectionPoint].
  final String fromPointId;
  /// The ID of the ending [ConnectionPoint].
  final String toPointId;
  /// A flag indicating if this specific connection is correct according to the solution.
  final bool isCorrect;
  /// An optional explanation if the connection is incorrect.
  final String? errorReason;
  /// The color of the wire, often used to indicate the phase.
  final Color color;
  /// The electrical phase associated with this connection (e.g., 'A', 'B', 'C').
  final String phase;

  /// Serializes the [WireConnection] to a JSON map.
  Map<String, dynamic> toJson() => <String, dynamic>{
      'fromPointId': fromPointId,
      'toPointId': toPointId,
      'isCorrect': isCorrect,
      'errorReason': errorReason,
      'color': color.value,
      'phase': phase,
    };
}

/// Represents the complete state of a transformer connection training session.
class TrainingState {
  
  /// Creates an instance of [TrainingState].
  const TrainingState({
    required this.bankType,
    required this.mode,
    required this.difficulty,
    this.connections = const <WireConnection>[],
    this.currentStep = 0,
    this.isComplete = false,
    this.completedSteps = const <String>[],
  });

  /// Creates a [TrainingState] instance from a JSON map.
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
  /// The type of transformer bank being configured.
  final TransformerBankType bankType;
  /// The current training mode (guided or quiz).
  final TrainingMode mode;
  /// The difficulty level of the scenario.
  final DifficultyLevel difficulty;
  /// A list of all wire connections made by the user.
  final List<WireConnection> connections;
  /// The current step number in guided mode.
  final int currentStep;
  /// A flag indicating if the training session is complete.
  final bool isComplete;
  /// A list of step IDs that have been successfully completed.
  final List<String> completedSteps;
  
  /// Creates a new [TrainingState] instance with updated field values.
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

  /// Serializes the [TrainingState] to a JSON map.
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

/// Defines a voltage scenario for a training exercise.
class VoltageScenario {
  
  /// Creates an instance of [VoltageScenario].
  const VoltageScenario({
    required this.name,
    required this.voltages,
    required this.description,
  });
  /// The name of the scenario (e.g., "Standard Residential").
  final String name;
  /// A map of voltages for different parts of the circuit (e.g., "primary": 4160).
  final Map<String, int> voltages;
  /// A description of the scenario.
  final String description;
}

/// Represents a single step in the guided training mode.
class TrainingStep {
  
  /// Creates an instance of [TrainingStep].
  const TrainingStep({
    required this.stepNumber,
    required this.instruction,
    required this.explanation,
    required this.requiredConnections,
    this.safetyNote,
    this.commonMistake,
  });

  /// Creates a [TrainingStep] instance from a JSON map.
  factory TrainingStep.fromJson(Map<String, dynamic> json) => TrainingStep(
      stepNumber: json['stepNumber'] as int,
      instruction: json['instruction'] as String,
      explanation: json['explanation'] as String,
      requiredConnections: List<String>.from(json['requiredConnections'] as List),
      safetyNote: json['safetyNote'] as String?,
      commonMistake: json['commonMistake'] as String?,
    );
  /// The sequential number of this step.
  final int stepNumber;
  /// The instruction text telling the user what to do.
  final String instruction;
  /// An explanation of why this step is performed.
  final String explanation;
  /// A list of connection IDs that must be completed for this step.
  final List<String> requiredConnections;
  /// An optional safety note related to this step.
  final String? safetyNote;
  /// An optional note about common mistakes made during this step.
  final String? commonMistake;

  /// Serializes the [TrainingStep] to a JSON map.
  Map<String, dynamic> toJson() => <String, dynamic>{
      'stepNumber': stepNumber,
      'instruction': instruction,
      'explanation': explanation,
      'requiredConnections': requiredConnections,
      'safetyNote': safetyNote,
      'commonMistake': commonMistake,
    };
}
