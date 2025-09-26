import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system/app_theme.dart';
import 'models/transformer_models_export.dart';
import 'modes/guided_mode.dart';
import 'modes/quiz_mode.dart';
import 'state/transformer_state.dart';

/// Journeyman Jobs themed transformer trainer widget for interactive electrical training.
///
/// This widget provides an educational interface for learning transformer bank
/// connections used in electrical power systems. It supports multiple training
/// modes, difficulty levels, and transformer bank configurations.
///
/// ## Features
/// - Interactive connection training with visual feedback
/// - Multiple transformer bank types (Wye-Wye, Wye-Delta, Delta-Wye, Delta-Delta, Open Delta)
/// - Guided learning mode with step-by-step instructions
/// - Quiz mode for assessment and testing
/// - Progressive difficulty levels (Beginner, Intermediate, Advanced)
/// - Real-time validation and error feedback
/// - Electrical industry standard terminology and practices
///
/// ## Usage
/// ```dart
/// JJTransformerTrainer(
///   initialBankType: TransformerBankType.wyeToWye,
///   initialMode: TrainingMode.guided,
///   initialDifficulty: DifficultyLevel.beginner,
///   onStepComplete: (step) => print('Step completed: ${step.id}'),
///   onBankComplete: (bankType) => print('Bank completed: $bankType'),
///   onError: (error) => print('Training error: $error'),
/// )
/// ```
///
/// ## Electrical Safety
/// This training tool is for educational purposes only. Always follow proper
/// electrical safety procedures and local electrical codes when working with
/// actual transformer installations.
///
/// ## See Also
/// - [TransformerBankType] for available bank configurations
/// - [TrainingMode] for different learning modes
/// - [DifficultyLevel] for skill level progression
class JJTransformerTrainer extends StatelessWidget {
  /// Creates a new transformer trainer widget.
  ///
  /// All parameters are optional and will use sensible defaults for beginners.
  ///
  /// ## Parameters
  /// - [key]: Widget key for identification in the widget tree
  /// - [initialBankType]: Starting transformer configuration
  /// - [initialMode]: Training approach (guided vs quiz)
  /// - [initialDifficulty]: Skill level for content complexity
  /// - [onStepComplete]: Callback for step completion tracking
  /// - [onBankComplete]: Callback for bank completion events
  /// - [onError]: Callback for error handling and user feedback
  ///
  /// ## Example
  /// ```dart
  /// // Basic usage with defaults
  /// JJTransformerTrainer()
  ///
  /// // Advanced configuration
  /// JJTransformerTrainer(
  ///   initialBankType: TransformerBankType.deltaToWye,
  ///   initialMode: TrainingMode.quiz,
  ///   initialDifficulty: DifficultyLevel.advanced,
  ///   onError: (error) => showSnackBar(context, error),
  /// )
  /// ```
  const JJTransformerTrainer({
    super.key,
    this.initialBankType = TransformerBankType.wyeToWye,
    this.initialMode = TrainingMode.guided,
    this.initialDifficulty = DifficultyLevel.beginner,
    this.onStepComplete,
    this.onBankComplete,
    this.onError,
  });

  /// Initial transformer bank type to display when the trainer starts.
  ///
  /// Defaults to [TransformerBankType.wyeToWye] which is the most common
  /// distribution transformer configuration.
  final TransformerBankType initialBankType;

  /// Initial training mode (guided learning or quiz assessment).
  ///
  /// - [TrainingMode.guided]: Step-by-step instructions with hints
  /// - [TrainingMode.quiz]: Self-assessment without guidance
  ///
  /// Defaults to [TrainingMode.guided] for beginners.
  final TrainingMode initialMode;

  /// Initial difficulty level for the training session.
  ///
  /// - [DifficultyLevel.beginner]: Basic connections with detailed guidance
  /// - [DifficultyLevel.intermediate]: Standard connections with moderate help
  /// - [DifficultyLevel.advanced]: Complex scenarios with minimal guidance
  ///
  /// Defaults to [DifficultyLevel.beginner].
  final DifficultyLevel initialDifficulty;

  /// Callback invoked when a training step is successfully completed.
  ///
  /// The [TrainingStep] parameter contains details about the completed step
  /// including connections made, time taken, and any errors encountered.
  ///
  /// Use this callback to track learning progress or trigger achievements.
  final Function(TrainingStep)? onStepComplete;

  /// Callback invoked when an entire transformer bank training is completed.
  ///
  /// The [TransformerBankType] parameter indicates which bank configuration
  /// was successfully completed. This can be used to unlock new bank types
  /// or award certificates.
  final Function(TransformerBankType)? onBankComplete;

  /// Callback invoked when a training error occurs.
  ///
  /// The [String] parameter contains a human-readable error message.
  /// Common errors include:
  /// - Invalid connection attempts
  /// - Safety violation warnings
  /// - Timeout errors in quiz mode
  /// - State management failures
  ///
  /// Use this callback to display error messages to users or log issues.
  final Function(String)? onError;

  /// Builds the transformer trainer widget with error handling and state management.
  ///
  /// Creates a [ChangeNotifierProvider] to manage training state and wraps
  /// the main content in error boundaries for robust operation.
  ///
  /// ## Error Handling
  /// - State initialization failures are caught and reported via [onError]
  /// - Widget building errors are handled gracefully with fallback UI
  /// - Training errors are propagated to the error callback
  ///
  /// ## Returns
  /// A widget tree containing the training interface, or an error widget
  /// if initialization fails.
  @override
  Widget build(BuildContext context) {
    try {
      return ChangeNotifierProvider(
        create: (BuildContext context) {
          try {
            return TransformerTrainerState()
              ..updateState(
                TrainingState(
                  bankType: initialBankType,
                  mode: initialMode,
                  difficulty: initialDifficulty,
                ),
              );
          } catch (e) {
            // Report state initialization error
            onError
                ?.call('Failed to initialize training state: ${e.toString()}');
            rethrow;
          }
        },
        child: Consumer<TransformerTrainerState>(
          builder: (BuildContext context, TransformerTrainerState state,
              Widget? child,) {
            try {
              // Check for error state derived from connections with error reasons
              final List<String> connectionErrors = state.currentState.connections
                  .where((WireConnection c) =>
                      !c.isCorrect && c.errorReason != null,)
                  .map((WireConnection c) => c.errorReason!)
                  .toList();
              if (connectionErrors.isNotEmpty) {
                for (final String error in connectionErrors) {
                  onError?.call(error);
                }
              }

              return Column(
                children: <Widget>[
                  _buildControlPanel(context, state),
                  Expanded(
                    child: _buildMainContent(context, state),
                  ),
                ],
              );
            } catch (e) {
              // Report widget building error
              onError?.call('Training interface error: ${e.toString()}');
              return _buildErrorWidget(e.toString());
            }
          },
        ),
      );
    } catch (e) {
      // Report critical initialization error
      onError?.call('Critical training error: ${e.toString()}');
      return _buildErrorWidget(e.toString());
    }
  }

  /// Builds an error widget when the main training interface fails to load.
  ///
  /// This provides a graceful fallback that informs users of the issue
  /// while maintaining the electrical theme.
  ///
  /// ## Parameters
  /// - [errorMessage]: Human-readable description of the error
  ///
  /// ## Returns
  /// A widget displaying the error with electrical-themed styling.
  Widget _buildErrorWidget(String errorMessage) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        decoration: BoxDecoration(
          color: AppTheme.errorRed.withValues(alpha: 0.1),
          border: Border.all(color: AppTheme.errorRed),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.electrical_services_outlined,
              size: AppTheme.iconXxl,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Transformer Trainer Error',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.errorRed,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'The training interface encountered an issue and cannot load.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Error: $errorMessage',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textLight,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton.icon(
              onPressed: () {
                // Trigger a rebuild attempt
                // In a real app, this might restart the component or navigate away
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
              ),
            ),
          ],
        ),
      );

  Widget _buildControlPanel(
          BuildContext context, TransformerTrainerState state,) =>
      Container(
        color: AppTheme.white,
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Mode Toggle
            Text(
              'Training Mode',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            _buildModeToggle(context, state),

            const SizedBox(height: AppTheme.spacingMd),

            // Bank Type Selector
            Text(
              'Transformer Configuration',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            _buildBankTypeSelector(context, state),

            const SizedBox(height: AppTheme.spacingMd),

            // Difficulty Selector
            Text(
              'Difficulty Level',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            _buildDifficultySelector(context, state),
          ],
        ),
      );

  Widget _buildModeToggle(
          BuildContext context, TransformerTrainerState state,) =>
      DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () => state.setMode(TrainingMode.guided),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingSm,
                    horizontal: AppTheme.spacingMd,
                  ),
                  decoration: BoxDecoration(
                    color: state.currentState.mode == TrainingMode.guided
                        ? AppTheme.primaryNavy
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.school,
                        size: AppTheme.iconSm,
                        color: state.currentState.mode == TrainingMode.guided
                            ? AppTheme.white
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Text(
                        'Guided',
                        style: AppTheme.labelMedium.copyWith(
                          color: state.currentState.mode == TrainingMode.guided
                              ? AppTheme.white
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => state.setMode(TrainingMode.quiz),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingSm,
                    horizontal: AppTheme.spacingMd,
                  ),
                  decoration: BoxDecoration(
                    color: state.currentState.mode == TrainingMode.quiz
                        ? AppTheme.primaryNavy
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.quiz,
                        size: AppTheme.iconSm,
                        color: state.currentState.mode == TrainingMode.quiz
                            ? AppTheme.white
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Text(
                        'Quiz',
                        style: AppTheme.labelMedium.copyWith(
                          color: state.currentState.mode == TrainingMode.quiz
                              ? AppTheme.white
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildBankTypeSelector(
          BuildContext context, TransformerTrainerState state,) =>
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TransformerBankType.values.map((TransformerBankType type) {
            final bool isSelected = state.currentState.bankType == type;
            return Container(
              margin: const EdgeInsets.only(right: AppTheme.spacingSm),
              child: GestureDetector(
                onTap: () => state.setBankType(type),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingSm,
                    horizontal: AppTheme.spacingMd,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accentCopper.withValues(alpha: 0.1)
                        : AppTheme.lightGray,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.accentCopper
                          : AppTheme.mediumGray,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Text(
                    _getBankTypeDisplayName(type),
                    style: AppTheme.labelSmall.copyWith(
                      color: isSelected
                          ? AppTheme.accentCopper
                          : AppTheme.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );

  Widget _buildDifficultySelector(
          BuildContext context, TransformerTrainerState state,) =>
      Row(
        children: DifficultyLevel.values.map((DifficultyLevel level) {
          final bool isSelected = state.currentState.difficulty == level;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: AppTheme.spacingSm),
              child: GestureDetector(
                onTap: () => state.setDifficulty(level),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accentCopper.withValues(alpha: 0.1)
                        : AppTheme.lightGray,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.accentCopper
                          : AppTheme.mediumGray,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Text(
                    _getDifficultyDisplayName(level),
                    textAlign: TextAlign.center,
                    style: AppTheme.labelSmall.copyWith(
                      color: isSelected
                          ? AppTheme.accentCopper
                          : AppTheme.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );

  Widget _buildMainContent(
          BuildContext context, TransformerTrainerState state,) =>
      ColoredBox(
        color: AppTheme.lightGray,
        child: state.currentState.mode == TrainingMode.guided
            ? GuidedModeWidget(
                onStepComplete: onStepComplete,
                onBankComplete: onBankComplete,
                onError: onError,
              )
            : QuizModeWidget(
                onStepComplete: onStepComplete,
                onBankComplete: onBankComplete,
                onError: onError,
              ),
      );

  String _getBankTypeDisplayName(TransformerBankType type) {
    switch (type) {
      case TransformerBankType.wyeToWye:
        return 'Wye-Wye';
      case TransformerBankType.wyeToDelta:
        return 'Wye-Delta';
      case TransformerBankType.deltaToWye:
        return 'Delta-Wye';
      case TransformerBankType.deltaToDelta:
        return 'Delta-Delta';
      case TransformerBankType.openDelta:
        return 'Open-Delta';
    }
  }

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
}
