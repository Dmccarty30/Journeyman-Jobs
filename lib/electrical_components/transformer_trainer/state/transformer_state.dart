
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../models/educational_content.dart';
import '../models/transformer_models_export.dart';

/// State management for the transformer trainer using ChangeNotifier
class TransformerTrainerState extends ChangeNotifier {
  TrainingState _currentState = const TrainingState(
    bankType: TransformerBankType.wyeToWye,
    mode: TrainingMode.guided,
    difficulty: DifficultyLevel.beginner,
  );

  /// Selected wire/connection point for two-step connection
  String? _selectedWireId;
  
  /// Drag preview state
  Offset? _dragPreviewPosition;
  String? _dragSourceId;
  
  /// Connection mode (drag-drop or sticky keys)
  ConnectionMode _connectionMode = ConnectionMode.stickyKeys;
  
  /// Compatible connection points for the currently selected wire
  final Set<String> _compatiblePoints = <String>{};
  
  /// Energization state
  bool _isEnergized = false;
  EnergizationResult? _lastEnergizationResult;

  /// Current training state
  TrainingState get currentState => _currentState;
  
  /// Available connection points for the current bank type
  List<ConnectionPoint> get connectionPoints => _getConnectionPoints();
  
  /// Required connections for the current bank type and step
  List<WireConnection> get requiredConnections => _getRequiredConnections();
  
  /// Selected wire ID for sticky keys mode
  String? get selectedWireId => _selectedWireId;
  
  /// Drag preview position for drag-drop mode
  Offset? get dragPreviewPosition => _dragPreviewPosition;
  
  /// Drag source ID
  String? get dragSourceId => _dragSourceId;
  
  /// Current connection mode
  ConnectionMode get connectionMode => _connectionMode;
  
  /// Compatible connection points for selected wire
  Set<String> get compatiblePoints => _compatiblePoints;
  
  /// Whether the transformer is currently energized
  bool get isEnergized => _isEnergized;
  
  /// Last energization result
  EnergizationResult? get lastEnergizationResult => _lastEnergizationResult;
  
  /// Current training steps (for guided mode)
  List<TrainingStep> get trainingSteps =>
      EducationalContent.getTrainingSteps(_currentState.bankType);
  
  /// Current step in guided mode
  TrainingStep? get currentStep {
    if (_currentState.mode != TrainingMode.guided) return null;
    final List<TrainingStep> steps = trainingSteps;
    if (_currentState.currentStep < steps.length) {
      return steps[_currentState.currentStep];
    }
    return null;
  }

  /// Update the current training state
  void updateState(TrainingState newState) {
    _currentState = newState;
    notifyListeners();
  }

  /// Change bank type
  void setBankType(TransformerBankType bankType) {
    _currentState = _currentState.copyWith(
      bankType: bankType,
      connections: <WireConnection>[],
      currentStep: 0,
      isComplete: false,
      completedSteps: <String>[],
    );
    notifyListeners();
  }

  /// Change training mode
  void setMode(TrainingMode mode) {
    _currentState = _currentState.copyWith(
      mode: mode,
      connections: <WireConnection>[],
      currentStep: 0,
      isComplete: false,
      completedSteps: <String>[],
    );
    notifyListeners();
  }

  /// Change difficulty level
  void setDifficulty(DifficultyLevel difficulty) {
    _currentState = _currentState.copyWith(
      difficulty: difficulty,
    );
    notifyListeners();
  }

  /// Add a new connection
  void addConnection(String fromPointId, String toPointId) {
    final bool isCorrect = _validateConnection(fromPointId, toPointId);
    final String? errorReason = isCorrect ? null : _getConnectionError(fromPointId, toPointId);
    
    final WireConnection newConnection = WireConnection(
      fromPointId: fromPointId,
      toPointId: toPointId,
      isCorrect: isCorrect,
      errorReason: errorReason,
    );

    final List<WireConnection> updatedConnections = <WireConnection>[..._currentState.connections, newConnection];
    
    _currentState = _currentState.copyWith(
      connections: updatedConnections,
    );

    // Check if step is complete (guided mode)
    if (_currentState.mode == TrainingMode.guided && isCorrect) {
      _checkStepCompletion();
    }
    
    // Check if entire bank is complete
    _checkBankCompletion();
    
    notifyListeners();
  }

  /// Remove a connection
  void removeConnection(String fromPointId, String toPointId) {
    final List<WireConnection> updatedConnections = _currentState.connections
        .where((WireConnection conn) => !(conn.fromPointId == fromPointId && conn.toPointId == toPointId))
        .toList();
    
    _currentState = _currentState.copyWith(
      connections: updatedConnections,
    );
    notifyListeners();
  }

  /// Clear all connections
  void clearConnections() {
    _currentState = _currentState.copyWith(
      connections: <WireConnection>[],
      currentStep: 0,
      isComplete: false,
      completedSteps: <String>[],
    );
    _selectedWireId = null;
    _dragPreviewPosition = null;
    _dragSourceId = null;
    _compatiblePoints.clear();
    _isEnergized = false;
    _lastEnergizationResult = null;
    notifyListeners();
  }
  
  /// Energize the transformer and validate connections
  EnergizationResult energizeTransformer() {
    // Check if there are any connections
    if (_currentState.connections.isEmpty) {
      _lastEnergizationResult = const EnergizationResult(
        isCorrect: false,
        errorMessage: 'No connections have been made. Please connect the transformer before energizing.',
        incorrectConnections: <WireConnection>[],
      );
      return _lastEnergizationResult!;
    }
    
    // Get required connections for current configuration
    final List<WireConnection> requiredConns = _getRequiredConnections();
    
    // Check if all required connections are made
    final Set<String> madeConnections = <String>{};
    final List<WireConnection> incorrectConnections = <WireConnection>[];
    
    for (final WireConnection conn in _currentState.connections) {
      final String connectionId = '${conn.fromPointId}_to_${conn.toPointId}';
      final String reverseConnectionId = '${conn.toPointId}_to_${conn.fromPointId}';
      
      // Check if this connection is required
      final bool isRequired = requiredConns.any((WireConnection req) =>
        (req.fromPointId == conn.fromPointId && req.toPointId == conn.toPointId) ||
        (req.fromPointId == conn.toPointId && req.toPointId == conn.fromPointId),
      );
      
      if (isRequired) {
        madeConnections.add(connectionId);
        madeConnections.add(reverseConnectionId);
      } else {
        incorrectConnections.add(conn);
      }
    }
    
    // Check if all required connections are made
    final bool allRequiredMade = requiredConns.every((WireConnection req) {
      final String connectionId = '${req.fromPointId}_to_${req.toPointId}';
      final String reverseConnectionId = '${req.toPointId}_to_${req.fromPointId}';
      return madeConnections.contains(connectionId) || madeConnections.contains(reverseConnectionId);
    });
    
    // Determine result
    if (incorrectConnections.isNotEmpty) {
      // Incorrect connections will cause electrical fire
      _isEnergized = true;
      _lastEnergizationResult = EnergizationResult(
        isCorrect: false,
        errorMessage: 'DANGER: Incorrect connections detected! This would cause an electrical fault.',
        incorrectConnections: incorrectConnections,
      );
    } else if (!allRequiredMade) {
      // Missing connections
      _isEnergized = false;
      _lastEnergizationResult = const EnergizationResult(
        isCorrect: false,
        errorMessage: 'Some required connections are missing. Complete all connections before energizing.',
        incorrectConnections: <WireConnection>[],
      );
    } else {
      // All connections are correct
      _isEnergized = true;
      _currentState = _currentState.copyWith(isComplete: true);
      _lastEnergizationResult = const EnergizationResult(
        isCorrect: true,
        incorrectConnections: <WireConnection>[],
      );
    }
    
    notifyListeners();
    return _lastEnergizationResult!;
  }
  
  /// De-energize the transformer
  void deEnergizeTransformer() {
    _isEnergized = false;
    notifyListeners();
  }

  /// Set connection mode (drag-drop or sticky keys)
  void setConnectionMode(ConnectionMode mode) {
    _connectionMode = mode;
    _selectedWireId = null;
    _dragPreviewPosition = null;
    _dragSourceId = null;
    notifyListeners();
  }

  /// Select a wire for sticky keys mode
  void selectWire(String wireId) {
    if (_selectedWireId == wireId) {
      // Deselect if clicking the same wire
      _selectedWireId = null;
      _compatiblePoints.clear();
    } else {
      _selectedWireId = wireId;
      _updateCompatiblePoints(wireId);
    }
    notifyListeners();
  }

  /// Clear wire selection
  void clearWireSelection() {
    _selectedWireId = null;
    _compatiblePoints.clear();
    notifyListeners();
  }

  /// Start dragging a connection
  void startDrag(String sourceId) {
    _dragSourceId = sourceId;
    _updateCompatiblePoints(sourceId);
    notifyListeners();
  }

  /// Update drag preview position
  void updateDragPosition(Offset position) {
    _dragPreviewPosition = position;
    notifyListeners();
  }

  /// End drag operation
  void endDrag() {
    _dragSourceId = null;
    _dragPreviewPosition = null;
    _compatiblePoints.clear();
    notifyListeners();
  }

  /// Check if a connection point is compatible with selected wire
  bool isCompatibleConnection(String targetId) => _compatiblePoints.contains(targetId);

  /// Update compatible connection points based on selected wire
  void _updateCompatiblePoints(String sourceId) {
    _compatiblePoints.clear();
    
    // Find the source connection point
    final ConnectionPoint sourcePoint = connectionPoints.firstWhere(
      (ConnectionPoint point) => point.id == sourceId,
      orElse: () => throw StateError('Source point not found: $sourceId'),
    );
    
    // Determine compatible points based on connection rules
    for (final ConnectionPoint targetPoint in connectionPoints) {
      if (targetPoint.id == sourceId) continue;
      
      // Check if already connected
      final bool alreadyConnected = _currentState.connections.any((WireConnection conn) =>
        (conn.fromPointId == sourceId && conn.toPointId == targetPoint.id) ||
        (conn.fromPointId == targetPoint.id && conn.toPointId == sourceId),
      );
      
      if (alreadyConnected) continue;
      
      // Apply connection rules
      if (_canConnect(sourcePoint, targetPoint)) {
        _compatiblePoints.add(targetPoint.id);
      }
    }
  }

  /// Check if two points can be connected based on rules
  bool _canConnect(ConnectionPoint source, ConnectionPoint target) {
    // Don't allow connecting to the same type in most cases
    if (source.type == target.type) {
      // Exception: neutral to neutral connections are sometimes valid
      if (source.type != ConnectionType.neutral) {
        return false;
      }
    }
    
    // Primary to secondary connections are valid
    if ((source.type == ConnectionType.primary && target.type == ConnectionType.secondary) ||
        (source.type == ConnectionType.secondary && target.type == ConnectionType.primary)) {
      return true;
    }
    
    // Neutral connections
    if (source.type == ConnectionType.neutral || target.type == ConnectionType.neutral) {
      return true;
    }
    
    // Ground connections
    if (source.type == ConnectionType.ground || target.type == ConnectionType.ground) {
      return true;
    }
    
    // Check against required connections for more specific validation
    return requiredConnections.any((WireConnection conn) =>
      (conn.fromPointId == source.id && conn.toPointId == target.id) ||
      (conn.fromPointId == target.id && conn.toPointId == source.id),
    );
  }

  /// Get connection points for current bank type
  List<ConnectionPoint> _getConnectionPoints() {
    // Return connection points based on current bank type
    // This would be dynamically generated based on the transformer configuration
    switch (_currentState.bankType) {
      case TransformerBankType.wyeToWye:
        return _getWyeToWyeConnectionPoints();
      case TransformerBankType.deltaToDelta:
        return _getDeltaToDeltaConnectionPoints();
      case TransformerBankType.wyeToDelta:
        return _getWyeToDeltaConnectionPoints();
      case TransformerBankType.deltaToWye:
        return _getDeltaToWyeConnectionPoints();
      case TransformerBankType.openDelta:
        return _getOpenDeltaConnectionPoints();
    }
  }

  /// Validate if a connection is correct
  bool _validateConnection(String fromPointId, String toPointId) {
    // Implementation depends on current bank type and training rules
    // This is a simplified validation - real implementation would be more complex
    final List<WireConnection> requiredConns = _getRequiredConnections();
    return requiredConns.any((WireConnection conn) => 
        (conn.fromPointId == fromPointId && conn.toPointId == toPointId) ||
        (conn.fromPointId == toPointId && conn.toPointId == fromPointId),);
  }

  /// Get error message for incorrect connection
  String _getConnectionError(String fromPointId, String toPointId) {
    // Return specific error message based on the incorrect connection attempt
    return 'This connection is not correct for the current transformer bank configuration.';
  }

  /// Check if current step is complete (guided mode)
  void _checkStepCompletion() {
    if (_currentState.mode != TrainingMode.guided) return;
    
    final TrainingStep? step = currentStep;
    if (step == null) return;
    
    // Check if all required connections for this step are made
    final List<String> requiredForStep = step.requiredConnections;
    final Set<String> madeConnections = _currentState.connections
        .where((WireConnection conn) => conn.isCorrect)
        .map((WireConnection conn) => '${conn.fromPointId}_to_${conn.toPointId}')
        .toSet();
    
    final bool allStepConnectionsMade = requiredForStep.every(
        madeConnections.contains,);
    
    if (allStepConnectionsMade) {
      final List<String> updatedCompletedSteps = <String>[..._currentState.completedSteps, step.stepNumber.toString()];
      _currentState = _currentState.copyWith(
        currentStep: _currentState.currentStep + 1,
        completedSteps: updatedCompletedSteps,
      );
    }
  }

  /// Check if entire bank is complete
  void _checkBankCompletion() {
    final List<WireConnection> requiredConnections = _getRequiredConnections();
    final int correctConnections = _currentState.connections.where((WireConnection conn) => conn.isCorrect).length;
    
    if (correctConnections >= requiredConnections.length) {
      _currentState = _currentState.copyWith(isComplete: true);
    }
  }

  /// Get required connections for current bank type
  List<WireConnection> _getRequiredConnections() {
    // Return all required connections for the current bank type
    // This would be different for each transformer configuration
    switch (_currentState.bankType) {
      case TransformerBankType.wyeToWye:
        return _getWyeToWyeRequiredConnections();
      case TransformerBankType.deltaToDelta:
        return _getDeltaToDeltaRequiredConnections();
      case TransformerBankType.wyeToDelta:
        return _getWyeToDeltaRequiredConnections();
      case TransformerBankType.deltaToWye:
        return _getDeltaToWyeRequiredConnections();
      case TransformerBankType.openDelta:
        return _getOpenDeltaRequiredConnections();
    }
  }

  // Connection point generators for each bank type
  List<ConnectionPoint> _getWyeToWyeConnectionPoints() => <ConnectionPoint>[
      // Primary connections
      const ConnectionPoint(id: 'phase_a', position: Offset(50, 100), label: 'Phase A', type: ConnectionType.primary, isInput: true),
      const ConnectionPoint(id: 'phase_b', position: Offset(50, 200), label: 'Phase B', type: ConnectionType.primary, isInput: true),
      const ConnectionPoint(id: 'phase_c', position: Offset(50, 300), label: 'Phase C', type: ConnectionType.primary, isInput: true),
      
      // Transformer 1 primary
      const ConnectionPoint(id: 't1_h1', position: Offset(150, 100), label: 'T1-H1', type: ConnectionType.primary, isInput: false),
      const ConnectionPoint(id: 't1_h2', position: Offset(200, 100), label: 'T1-H2', type: ConnectionType.primary, isInput: false),
      
      // Additional connection points would be defined here...
    ];

  List<ConnectionPoint> _getDeltaToDeltaConnectionPoints() {
    // TODO: Implement delta-delta connection points
    return <ConnectionPoint>[];
  }

  List<ConnectionPoint> _getWyeToDeltaConnectionPoints() {
    // TODO: Implement wye-delta connection points
    return <ConnectionPoint>[];
  }

  List<ConnectionPoint> _getDeltaToWyeConnectionPoints() {
    // TODO: Implement delta-wye connection points
    return <ConnectionPoint>[];
  }

  List<ConnectionPoint> _getOpenDeltaConnectionPoints() {
    // TODO: Implement open-delta connection points
    return <ConnectionPoint>[];
  }

  // Required connection generators for each bank type
  List<WireConnection> _getWyeToWyeRequiredConnections() => <WireConnection>[
      const WireConnection(fromPointId: 'phase_a', toPointId: 't1_h1', isCorrect: true),
      const WireConnection(fromPointId: 'phase_b', toPointId: 't2_h1', isCorrect: true),
      const WireConnection(fromPointId: 'phase_c', toPointId: 't3_h1', isCorrect: true),
      // Additional required connections...
    ];

  List<WireConnection> _getDeltaToDeltaRequiredConnections() {
    // TODO: Implement delta-delta required connections
    return <WireConnection>[];
  }

  List<WireConnection> _getWyeToDeltaRequiredConnections() {
    // TODO: Implement wye-delta required connections
    return <WireConnection>[];
  }

  List<WireConnection> _getDeltaToWyeRequiredConnections() {
    // TODO: Implement delta-wye required connections
    return <WireConnection>[];
  }

  List<WireConnection> _getOpenDeltaRequiredConnections() {
    // TODO: Implement open-delta required connections
    return <WireConnection>[];
  }
}

/// Result of energization validation
class EnergizationResult {

  const EnergizationResult({
    required this.isCorrect,
    required this.incorrectConnections, this.errorMessage,
  });
  final bool isCorrect;
  final String? errorMessage;
  final List<WireConnection> incorrectConnections;
}
