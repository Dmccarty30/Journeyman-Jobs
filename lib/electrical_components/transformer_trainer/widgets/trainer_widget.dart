
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../design_system/app_theme.dart';
import '../../../design_system/popup_theme.dart';
import '../models/transformer_models_export.dart';
import '../modes/guided_mode.dart';
import '../modes/quiz_mode.dart';
import '../state/transformer_state.dart';

/// Main transformer trainer widget - entry point for the component
class TransformerTrainer extends StatelessWidget {

  const TransformerTrainer({
    super.key,
    this.initialBankType = TransformerBankType.wyeToWye,
    this.initialMode = TrainingMode.guided,
    this.initialDifficulty = DifficultyLevel.beginner,
    this.onStepComplete,
    this.onBankComplete,
    this.onError,
  });
  final TransformerBankType initialBankType;
  final TrainingMode initialMode;
  final DifficultyLevel initialDifficulty;
  final Function(TrainingStep)? onStepComplete;
  final Function(TransformerBankType)? onBankComplete;
  final Function(String)? onError;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (BuildContext context) => TransformerTrainerState()
        ..updateState(TrainingState(
          bankType: initialBankType,
          mode: initialMode,
          difficulty: initialDifficulty,
        ),),
      child: Consumer<TransformerTrainerState>(
        builder: (BuildContext context, TransformerTrainerState state, Widget? child) => Scaffold(
            appBar: _buildAppBar(context, state),
            body: Column(
              children: <Widget>[
                _buildModeToggle(context, state),
                _buildBankTypeSelector(context, state),
                _buildDifficultySelector(context, state),
                Expanded(
                  child: _buildMainContent(context, state),
                ),
              ],
            ),
          ),
      ),
    );

  /// Build app bar with title and reset button
  PreferredSizeWidget _buildAppBar(BuildContext context, TransformerTrainerState state) => AppBar(
      title: const Text('Transformer Bank Trainer'),
      backgroundColor: AppTheme.primaryNavy,
      foregroundColor: AppTheme.white,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => state.clearConnections(),
          tooltip: 'Reset Training',
        ),
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () => _showHelpDialog(context),
          tooltip: 'Help',
        ),
      ],
    );

  /// Build mode toggle buttons (Guided vs Quiz)
  Widget _buildModeToggle(BuildContext context, TransformerTrainerState state) => Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _buildToggleButton(
              context,
              'Guided Mode',
              TrainingMode.guided,
              state.currentState.mode,
              (TrainingMode mode) => state.setMode(mode),
              Icons.school,
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              context,
              'Quiz Mode',
              TrainingMode.quiz,
              state.currentState.mode,
              (TrainingMode mode) => state.setMode(mode),
              Icons.quiz,
            ),
          ),
        ],
      ),
    );

  /// Build bank type selector dropdown
  Widget _buildBankTypeSelector(BuildContext context, TransformerTrainerState state) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.mediumGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<TransformerBankType>(
        value: state.currentState.bankType,
        isExpanded: true,
        underline: const SizedBox(),
        items: TransformerBankType.values.map((TransformerBankType type) => DropdownMenuItem(
            value: type,
            child: Text(_getBankTypeDisplayName(type)),
          ),).toList(),
        onChanged: (TransformerBankType? type) {
          if (type != null) {
            state.setBankType(type);
          }
        },
      ),
    );

  /// Build difficulty level selector
  Widget _buildDifficultySelector(BuildContext context, TransformerTrainerState state) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          const Text('Difficulty: ', style: TextStyle(fontWeight: FontWeight.bold)),
          ...DifficultyLevel.values.map((DifficultyLevel level) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildToggleButton(
                context,
                _getDifficultyDisplayName(level),
                level,
                state.currentState.difficulty,
                (DifficultyLevel diff) => state.setDifficulty(diff),
                _getDifficultyIcon(level),
              ),
            ),
          ),),
        ],
      ),
    );

  /// Build main content based on current mode
  Widget _buildMainContent(BuildContext context, TransformerTrainerState state) {
    switch (state.currentState.mode) {
      case TrainingMode.guided:
        return GuidedModeWidget(
          onStepComplete: onStepComplete,
          onBankComplete: onBankComplete,
          onError: onError,
        );
      case TrainingMode.quiz:
        return QuizModeWidget(
          onBankComplete: onBankComplete,
          onError: onError,
        );
    }
  }

  /// Build toggle button helper
  Widget _buildToggleButton<T>(
    BuildContext context,
    String label,
    T value,
    T currentValue,
    Function(T) onChanged,
    IconData icon,
  ) {
    final bool isSelected = value == currentValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: isSelected ? AppTheme.white : AppTheme.mediumGray,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.white : AppTheme.darkGray,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show help dialog
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: PopupThemeData.alertDialog().barrierColor,
      builder: (BuildContext context) => PopupTheme(
        data: PopupThemeData.alertDialog(),
        child: AlertDialog(
          backgroundColor: PopupThemeData.alertDialog().backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: PopupThemeData.alertDialog().borderRadius,
            side: BorderSide(
              color: PopupThemeData.alertDialog().borderColor,
              width: PopupThemeData.alertDialog().borderWidth,
            ),
          ),
          elevation: PopupThemeData.alertDialog().elevation,
          contentPadding: PopupThemeData.alertDialog().padding,
          title: Text(
            'Transformer Bank Trainer Help',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Guided Mode:',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '• Follow step-by-step instructions\n• Get hints and explanations\n• Learn proper connection procedures\n',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  'Quiz Mode:',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '• Test your knowledge\n• Make connections without guidance\n• Receive feedback on completion\n',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  'Making Connections:',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '• Tap connection points to make wires\n• Drag to connect two points\n• Incorrect connections will flash red\n• Correct connections glow green',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
              ),
              child: const Text('Got it!'),
            ),
          ],
        ),
      ),
    );
  }

  /// Get display name for bank type
  String _getBankTypeDisplayName(TransformerBankType type) {
    switch (type) {
      case TransformerBankType.wyeToWye:
        return 'Wye-Wye';
      case TransformerBankType.deltaToDelta:
        return 'Delta-Delta';
      case TransformerBankType.wyeToDelta:
        return 'Wye-Delta';
      case TransformerBankType.deltaToWye:
        return 'Delta-Wye';
      case TransformerBankType.openDelta:
        return 'Open Delta';
    }
  }

  /// Get display name for difficulty level
  String _getDifficultyDisplayName(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
    }
  }

  /// Get icon for difficulty level
  IconData _getDifficultyIcon(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return Icons.looks_one;
      case DifficultyLevel.intermediate:
        return Icons.looks_two;
      case DifficultyLevel.advanced:
        return Icons.looks_3;
    }
  }
}
