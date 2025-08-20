import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system/app_theme.dart';
import '../../models/transformer_models.dart';
import '../../widgets/generic_connection_point.dart';

/// Interactive transformer workbench screen for hands-on training
class TransformerWorkbenchScreen extends StatefulWidget {

  const TransformerWorkbenchScreen({
    required this.bankType, required this.mode, required this.difficulty, super.key,
    this.isReferenceMode = false,
  });
  final TransformerBankType bankType;
  final TrainingMode mode;
  final DifficultyLevel difficulty;
  final bool isReferenceMode;

  @override
  State<TransformerWorkbenchScreen> createState() => _TransformerWorkbenchScreenState();
}

class _TransformerWorkbenchScreenState extends State<TransformerWorkbenchScreen>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _successAnimationController;
  late AnimationController _hintAnimationController;
  late Animation<double> _successAnimation;
  late Animation<double> _hintAnimation;

  // Training state

  // Connection state
  final List<WireConnection> _connections = <WireConnection>[];
  final List<ConnectionPoint> _connectionPoints = <ConnectionPoint>[];
  String? _selectedConnectionPointId;
  ConnectionMode _connectionMode = ConnectionMode.stickyKeys;
  
  // UI state
  bool _showHints = false;
  bool _showValidation = false;
  String? _currentHint;
  String? _validationMessage;
  Color _selectedWireColor = Colors.red;
  String _selectedPhase = 'A';
  
  // Wire colors for different phases
  final Map<String, Color> _wireColors = <String, Color>{
    'A': Colors.red,
    'B': Colors.blue,
    'C': Colors.yellow,
    'N': Colors.grey,
    'G': Colors.green,
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTrainingState();
    _generateConnectionPoints();
  }

  void _initializeAnimations() {
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _hintAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _successAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _successAnimationController, curve: Curves.elasticOut),
    );
    _hintAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _hintAnimationController, curve: Curves.easeInOut),
    );
  }

  void _initializeTrainingState() {
  }

  void _generateConnectionPoints() {
    _connectionPoints.clear();
    
    // Generate connection points based on transformer bank type
    switch (widget.bankType) {
      case TransformerBankType.wyeToWye:
        _generateWyeWyeConnectionPoints();
        break;
      case TransformerBankType.deltaToDelta:
        _generateDeltaDeltaConnectionPoints();
        break;
      case TransformerBankType.wyeToDelta:
        _generateWyeDeltaConnectionPoints();
        break;
      case TransformerBankType.deltaToWye:
        _generateDeltaWyeConnectionPoints();
        break;
      case TransformerBankType.openDelta:
        _generateOpenDeltaConnectionPoints();
        break;
    }
  }

  void _generateWyeWyeConnectionPoints() {
    // Primary side connection points (H1, H2 for each transformer)
    _connectionPoints.addAll(<ConnectionPoint>[
      // Transformer 1
      const ConnectionPoint(
        id: 'T1_H1',
        position: Offset(100, 150),
        label: 'T1-H1',
        type: ConnectionType.primary,
        isInput: true,
      ),
      const ConnectionPoint(
        id: 'T1_H2',
        position: Offset(100, 200),
        label: 'T1-H2',
        type: ConnectionType.primary,
        isInput: true,
      ),
      // Transformer 2
      const ConnectionPoint(
        id: 'T2_H1',
        position: Offset(200, 150),
        label: 'T2-H1',
        type: ConnectionType.primary,
        isInput: true,
      ),
      const ConnectionPoint(
        id: 'T2_H2',
        position: Offset(200, 200),
        label: 'T2-H2',
        type: ConnectionType.primary,
        isInput: true,
      ),
      // Transformer 3
      const ConnectionPoint(
        id: 'T3_H1',
        position: Offset(300, 150),
        label: 'T3-H1',
        type: ConnectionType.primary,
        isInput: true,
      ),
      const ConnectionPoint(
        id: 'T3_H2',
        position: Offset(300, 200),
        label: 'T3-H2',
        type: ConnectionType.primary,
        isInput: true,
      ),
      // Secondary side connection points (X1, X2, X3 for each transformer)
      // Transformer 1 Secondary
      const ConnectionPoint(
        id: 'T1_X1',
        position: Offset(100, 300),
        label: 'T1-X1',
        type: ConnectionType.secondary,
        isInput: false,
      ),
      const ConnectionPoint(
        id: 'T1_X2',
        position: Offset(100, 350),
        label: 'T1-X2',
        type: ConnectionType.secondary,
        isInput: false,
      ),
      // Transformer 2 Secondary
      const ConnectionPoint(
        id: 'T2_X1',
        position: Offset(200, 300),
        label: 'T2-X1',
        type: ConnectionType.secondary,
        isInput: false,
      ),
      const ConnectionPoint(
        id: 'T2_X2',
        position: Offset(200, 350),
        label: 'T2-X2',
        type: ConnectionType.secondary,
        isInput: false,
      ),
      // Transformer 3 Secondary
      const ConnectionPoint(
        id: 'T3_X1',
        position: Offset(300, 300),
        label: 'T3-X1',
        type: ConnectionType.secondary,
        isInput: false,
      ),
      const ConnectionPoint(
        id: 'T3_X2',
        position: Offset(300, 350),
        label: 'T3-X2',
        type: ConnectionType.secondary,
        isInput: false,
      ),
      // Neutral points
      const ConnectionPoint(
        id: 'PRIMARY_NEUTRAL',
        position: Offset(200, 100),
        label: 'Primary Neutral',
        type: ConnectionType.neutral,
        isInput: true,
      ),
      const ConnectionPoint(
        id: 'SECONDARY_NEUTRAL',
        position: Offset(200, 400),
        label: 'Secondary Neutral',
        type: ConnectionType.neutral,
        isInput: false,
      ),
    ]);
  }

  void _generateDeltaDeltaConnectionPoints() {
    // Similar structure but for Delta-Delta configuration
    _connectionPoints.addAll(<ConnectionPoint>[
      // Primary Delta connections
      const ConnectionPoint(
        id: 'T1_H1',
        position: Offset(100, 150),
        label: 'T1-H1',
        type: ConnectionType.primary,
        isInput: true,
      ),
      const ConnectionPoint(
        id: 'T1_H2',
        position: Offset(150, 120),
        label: 'T1-H2',
        type: ConnectionType.primary,
        isInput: true,
      ),
      // Add more connection points for Delta configuration...
    ]);
  }

  void _generateWyeDeltaConnectionPoints() {
    // Wye primary, Delta secondary
    // Implementation similar to above but with mixed configuration
  }

  void _generateDeltaWyeConnectionPoints() {
    // Delta primary, Wye secondary
    // Implementation similar to above but with mixed configuration
  }

  void _generateOpenDeltaConnectionPoints() {
    // Only two transformers for Open Delta
    _connectionPoints.addAll(<ConnectionPoint>[
      // Transformer 1
      const ConnectionPoint(
        id: 'T1_H1',
        position: Offset(100, 150),
        label: 'T1-H1',
        type: ConnectionType.primary,
        isInput: true,
      ),
      const ConnectionPoint(
        id: 'T1_H2',
        position: Offset(100, 200),
        label: 'T1-H2',
        type: ConnectionType.primary,
        isInput: true,
      ),
      // Transformer 2
      const ConnectionPoint(
        id: 'T2_H1',
        position: Offset(250, 150),
        label: 'T2-H1',
        type: ConnectionType.primary,
        isInput: true,
      ),
      const ConnectionPoint(
        id: 'T2_H2',
        position: Offset(250, 200),
        label: 'T2-H2',
        type: ConnectionType.primary,
        isInput: true,
      ),
    ]);
  }

  @override
  void dispose() {
    _successAnimationController.dispose();
    _hintAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: _buildAppBar(),
      body: Column(
        children: <Widget>[
          // Top half - Transformer diagram
          Expanded(
            flex: 3,
            child: _buildTransformerDiagramSection(),
          ),
          // Bottom half - Interactive workbench
          Expanded(
            flex: 2,
            child: _buildWorkbenchSection(),
          ),
        ],
      ),
    );

  PreferredSizeWidget _buildAppBar() => AppBar(
      backgroundColor: AppTheme.primaryNavy,
      foregroundColor: AppTheme.white,
      title: Text(
        widget.isReferenceMode ? 'Reference Mode' : 'Training Mode',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        if (!widget.isReferenceMode) ...<Widget>[
          IconButton(
            icon: Icon(_showHints ? Icons.lightbulb : Icons.lightbulb_outline),
            onPressed: _toggleHints,
            tooltip: 'Toggle Hints',
          ),
        ],
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _resetWorkbench,
          tooltip: 'Reset',
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: _showOptionsMenu,
        ),
      ],
    );

  Widget _buildTransformerDiagramSection() => Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: const <BoxShadow>[AppTheme.shadowSm],
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Stack(
        children: <Widget>[
          // Background image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: Image.asset(
                'assets/images/blank-three-bank.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Connection points overlay
          Positioned.fill(
            child: CustomPaint(
              painter: WireConnectionPainter(
                connections: _connections,
                connectionPoints: _connectionPoints,
                wireColors: _wireColors,
                showConnections: widget.isReferenceMode,
              ),
            ),
          ),
          // Interactive connection points
          ..._buildConnectionPointWidgets(),
          // Validation feedback overlay
          if (_showValidation) _buildValidationOverlay(),
          // Hint overlay
          if (_showHints && _currentHint != null) _buildHintOverlay(),
        ],
      ),
    );

  List<Widget> _buildConnectionPointWidgets() => _connectionPoints.map((ConnectionPoint point) {
      final bool isSelected = _selectedConnectionPointId == point.id;
      final bool isConnected = _connections.any(
        (WireConnection conn) => conn.fromPointId == point.id || conn.toPointId == point.id,
      );
      final bool isCompatible = _isCompatibleConnection(point.id);

      return Positioned(
        left: point.position.dx - 22, // Center the touch target
        top: point.position.dy - 22,
        child: ConnectionPointTooltip(
          connectionPoint: point,
          child: GenericConnectionPointWidget(
            connectionPoint: point,
            isSelected: isSelected,
            isConnected: isConnected,
            showGuidance: _showHints,
            isCompatible: isCompatible,
            isDragSource: isSelected,
            connectionMode: _connectionMode,
            onTap: () => _handleConnectionPointTap(point.id),
            onDragStart: () => _handleDragStart(point.id),
            onDragEnd: _handleDragEnd,
            onAcceptDrop: (details) => _handleConnectionDrop(details.data, point.id),
          ),
        ),
      );
    }).toList();

  Widget _buildWorkbenchSection() => Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLg),
          topRight: Radius.circular(AppTheme.radiusLg),
        ),
        boxShadow: <BoxShadow>[AppTheme.shadowMd],
      ),
      child: Column(
        children: <Widget>[
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Workbench content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                children: <Widget>[
                  _buildToolsRow(),
                  const SizedBox(height: AppTheme.spacingMd),
                  _buildConfigurationOptions(),
                  const SizedBox(height: AppTheme.spacingMd),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  Widget _buildToolsRow() => Row(
      children: <Widget>[
        // Connection mode toggle
        Expanded(
          child: _buildToolCard(
            title: 'Connection Mode',
            child: SegmentedButton<ConnectionMode>(
              segments: const <ButtonSegment<ConnectionMode>>[
                ButtonSegment(
                  value: ConnectionMode.stickyKeys,
                  label: Text('Tap'),
                  icon: Icon(Icons.touch_app, size: 16),
                ),
                ButtonSegment(
                  value: ConnectionMode.dragAndDrop,
                  label: Text('Drag'),
                  icon: Icon(Icons.drag_indicator, size: 16),
                ),
              ],
              selected: <ConnectionMode>{_connectionMode},
              onSelectionChanged: (Set<ConnectionMode> selection) {
                setState(() {
                  _connectionMode = selection.first;
                });
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppTheme.accentCopper.withOpacity(0.2),
                selectedForegroundColor: AppTheme.accentCopper,
              ),
            ),
          ),
        ),
      ],
    );

  Widget _buildConfigurationOptions() => Row(
      children: <Widget>[
        // Phase selection
        Expanded(
          child: _buildToolCard(
            title: 'Phase',
            child: Wrap(
              spacing: AppTheme.spacingSm,
              children: _wireColors.keys.map((String phase) {
                final bool isSelected = _selectedPhase == phase;
                return FilterChip(
                  label: Text(phase),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedPhase = phase;
                      _selectedWireColor = _wireColors[phase]!;
                    });
                  },
                  selectedColor: _wireColors[phase]!.withOpacity(0.3),
                  checkmarkColor: _wireColors[phase],
                  side: BorderSide(color: _wireColors[phase]!),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        // Wire color preview
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _selectedWireColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: AppTheme.borderLight, width: 2),
          ),
          child: const Icon(
            Icons.cable,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );

  Widget _buildActionButtons() => Row(
      children: <Widget>[
        // Reset button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _resetWorkbench,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.borderLight,
              foregroundColor: AppTheme.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        // Validation button
        if (!widget.isReferenceMode) ...<Widget>[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _validateConnections,
              icon: const Icon(Icons.check_circle),
              label: const Text('Check'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
        ],
        // Help button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showHelp,
            icon: const Icon(Icons.help_outline),
            label: const Text('Help'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.infoBlue,
              foregroundColor: AppTheme.white,
            ),
          ),
        ),
      ],
    );

  Widget _buildToolCard({required String title, required Widget child}) => Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          child,
        ],
      ),
    );

  Widget _buildValidationOverlay() => AnimatedBuilder(
      animation: _successAnimation,
      builder: (BuildContext context, Widget? child) => Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1 * _successAnimation.value),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Center(
              child: Transform.scale(
                scale: _successAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        _validationMessage ?? 'Correct!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    );

  Widget _buildHintOverlay() => AnimatedBuilder(
      animation: _hintAnimation,
      builder: (BuildContext context, Widget? child) => Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Transform.translate(
            offset: Offset(0, -50 * (1 - _hintAnimation.value)),
            child: Opacity(
              opacity: _hintAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.infoBlue,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: const <BoxShadow>[AppTheme.shadowMd],
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: Text(
                        _currentHint!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentHint = null;
                        });
                        _hintAnimationController.reverse();
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );

  // Event handlers
  void _handleConnectionPointTap(String pointId) {
    setState(() {
      if (_selectedConnectionPointId == null) {
        _selectedConnectionPointId = pointId;
        HapticFeedback.selectionClick();
      } else if (_selectedConnectionPointId == pointId) {
        _selectedConnectionPointId = null;
        HapticFeedback.lightImpact();
      } else {
        // Create connection
        _createConnection(_selectedConnectionPointId!, pointId);
        _selectedConnectionPointId = null;
      }
    });
  }

  void _handleDragStart(String pointId) {
    setState(() {
      _selectedConnectionPointId = pointId;
    });
  }

  void _handleDragEnd() {
    setState(() {
      _selectedConnectionPointId = null;
    });
  }

  void _handleConnectionDrop(String fromPointId, String toPointId) {
    _createConnection(fromPointId, toPointId);
  }

  void _createConnection(String fromPointId, String toPointId) {
    if (fromPointId == toPointId) return;

    // Check if connection already exists
    final bool existingConnection = _connections.any(
      (WireConnection conn) => 
        (conn.fromPointId == fromPointId && conn.toPointId == toPointId) ||
        (conn.fromPointId == toPointId && conn.toPointId == fromPointId),
    );

    if (existingConnection) {
      _showErrorMessage('Connection already exists');
      return;
    }

    // Validate connection
    final bool isValid = _validateConnection(fromPointId, toPointId);
    
    setState(() {
      _connections.add(WireConnection(
        fromPointId: fromPointId,
        toPointId: toPointId,
        isCorrect: isValid,
        errorReason: isValid ? null : 'Invalid connection type',
      ),);
    });

    if (isValid) {
      HapticFeedback.heavyImpact();
      _showSuccessMessage('Connection added successfully');
    } else {
      HapticFeedback.mediumImpact();
      _showErrorMessage('Invalid connection');
    }
  }

  bool _validateConnection(String fromPointId, String toPointId) {
    final ConnectionPoint fromPoint = _connectionPoints.firstWhere((ConnectionPoint p) => p.id == fromPointId);
    final ConnectionPoint toPoint = _connectionPoints.firstWhere((ConnectionPoint p) => p.id == toPointId);

    // Basic validation rules
    if (fromPoint.type == toPoint.type && fromPoint.isInput == toPoint.isInput) {
      return false; // Can't connect same type inputs/outputs
    }

    // Add more sophisticated validation based on transformer configuration
    return true;
  }

  bool _isCompatibleConnection(String pointId) {
    if (_selectedConnectionPointId == null) return false;
    if (_selectedConnectionPointId == pointId) return false;

    return _validateConnection(_selectedConnectionPointId!, pointId);
  }

  void _validateConnections() {
    // Implement validation logic based on transformer configuration
    final int correctConnections = _connections.where((WireConnection conn) => conn.isCorrect).length;
    final int totalConnections = _connections.length;

    if (totalConnections == 0) {
      _showErrorMessage('No connections made yet');
      return;
    }

    final double accuracy = correctConnections / totalConnections;
    
    if (accuracy >= 0.8) {
      _showValidationSuccess('Excellent work! ${(accuracy * 100).round()}% correct');
    } else if (accuracy >= 0.6) {
      _showValidationWarning('Good progress! ${(accuracy * 100).round()}% correct');
    } else {
      _showValidationError('Keep trying! ${(accuracy * 100).round()}% correct');
    }
  }

  void _showValidationSuccess(String message) {
    setState(() {
      _validationMessage = message;
      _showValidation = true;
    });
    _successAnimationController.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        _successAnimationController.reverse();
        setState(() {
          _showValidation = false;
        });
      });
    });
  }

  void _showValidationWarning(String message) {
    _showSnackBar(message, Colors.orange);
  }

  void _showValidationError(String message) {
    _showSnackBar(message, Colors.red);
  }

  void _showSuccessMessage(String message) {
    _showSnackBar(message, Colors.green);
  }

  void _showErrorMessage(String message) {
    _showSnackBar(message, Colors.red);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleHints() {
    setState(() {
      _showHints = !_showHints;
      if (_showHints) {
        _currentHint = _getNextHint();
        _hintAnimationController.forward();
      } else {
        _hintAnimationController.reverse();
      }
    });
  }

  String _getNextHint() {
    // Provide contextual hints based on current state
    if (_connections.isEmpty) {
      return 'Start by connecting the primary side (H1, H2) terminals';
    } else if (_connections.length < 3) {
      return 'Connect the secondary side (X1, X2) terminals next';
    } else {
      return "Don't forget to connect the neutral points for safety";
    }
  }

  void _resetWorkbench() {
    setState(() {
      _connections.clear();
      _selectedConnectionPointId = null;
      _showValidation = false;
      _currentHint = null;
    });
    HapticFeedback.mediumImpact();
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Transformer Workbench Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Connection Modes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Tap Mode: Tap first point, then tap second point to connect'),
              Text('• Drag Mode: Long press and drag from one point to another'),
              SizedBox(height: 16),
              Text(
                'Connection Points:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Red: Primary side (high voltage)'),
              Text('• Blue: Secondary side (low voltage)'),
              Text('• Gray: Neutral connections'),
              Text('• Green: Ground connections'),
              SizedBox(height: 16),
              Text(
                'Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Use hints for guidance'),
              Text('• Check your work with the validation button'),
              Text('• Reset to start over'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About this Configuration'),
              onTap: () {
                Navigator.pop(context);
                _showConfigurationInfo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Progress'),
              onTap: () {
                Navigator.pop(context);
                // Implement sharing
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showConfigurationInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('${widget.bankType.name} Configuration'),
        content: Text(_getConfigurationDescription()),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getConfigurationDescription() {
    switch (widget.bankType) {
      case TransformerBankType.wyeToWye:
        return 'Wye-Wye configuration provides a neutral point on both primary and secondary sides. Commonly used for 120V/208V systems.';
      case TransformerBankType.deltaToDelta:
        return 'Delta-Delta configuration provides maximum power transfer efficiency. No neutral point available.';
      case TransformerBankType.wyeToDelta:
        return 'Wye-Delta configuration steps down voltage while providing phase shift. Primary has neutral point.';
      case TransformerBankType.deltaToWye:
        return 'Delta-Wye configuration steps up voltage and provides neutral point on secondary side.';
      case TransformerBankType.openDelta:
        return 'Open Delta uses only two transformers to provide three-phase power at 86.6% capacity. Emergency configuration.';
    }
  }
}

/// Custom painter for drawing wire connections
class WireConnectionPainter extends CustomPainter {

  WireConnectionPainter({
    required this.connections,
    required this.connectionPoints,
    required this.wireColors,
    required this.showConnections,
  });
  final List<WireConnection> connections;
  final List<ConnectionPoint> connectionPoints;
  final Map<String, Color> wireColors;
  final bool showConnections;

  @override
  void paint(Canvas canvas, Size size) {
    if (!showConnections && connections.isEmpty) return;

    final Paint paint = Paint()
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final WireConnection connection in connections) {
      final ConnectionPoint fromPoint = connectionPoints.firstWhere(
        (ConnectionPoint p) => p.id == connection.fromPointId,
      );
      final ConnectionPoint toPoint = connectionPoints.firstWhere(
        (ConnectionPoint p) => p.id == connection.toPointId,
      );

      // Set wire color based on connection validity
      paint.color = connection.isCorrect 
        ? Colors.green 
        : Colors.red.withOpacity(0.7);

      // Draw curved wire
      final Path path = Path();
      path.moveTo(fromPoint.position.dx, fromPoint.position.dy);
      
      // Create a curved path for more realistic wire appearance
      final Offset controlPoint1 = Offset(
        fromPoint.position.dx + (toPoint.position.dx - fromPoint.position.dx) * 0.3,
        fromPoint.position.dy - 20,
      );
      final Offset controlPoint2 = Offset(
        fromPoint.position.dx + (toPoint.position.dx - fromPoint.position.dx) * 0.7,
        toPoint.position.dy - 20,
      );
      
      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        toPoint.position.dx, toPoint.position.dy,
      );

      canvas.drawPath(path, paint);

      // Draw connection indicators at endpoints
      final Paint indicatorPaint = Paint()
        ..color = paint.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(fromPoint.position, 4, indicatorPaint);
      canvas.drawCircle(toPoint.position, 4, indicatorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WireConnectionPainter oldDelegate) => connections != oldDelegate.connections ||
           showConnections != oldDelegate.showConnections;
}
