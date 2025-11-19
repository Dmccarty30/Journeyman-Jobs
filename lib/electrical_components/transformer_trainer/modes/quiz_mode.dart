
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../design_system/app_theme.dart';
import '../../../design_system/popup_theme.dart';
import '../models/educational_content.dart';
import '../models/transformer_models_export.dart';
import '../state/transformer_state.dart';
import '../widgets/transformer_diagram.dart';

/// Quiz mode for testing knowledge without guidance
class QuizModeWidget extends StatelessWidget {

  const QuizModeWidget({
    super.key,
    this.onStepComplete,
    this.onBankComplete,
    this.onError,
  });
  final Function(TrainingStep)? onStepComplete;
  final Function(TransformerBankType)? onBankComplete;
  final Function(String)? onError;

  @override
  Widget build(BuildContext context) => Consumer<TransformerTrainerState>(
      builder: (BuildContext context, TransformerTrainerState state, Widget? child) => Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    // Quiz header with bank info
                    _buildQuizHeader(state),
                    
                    // Connection status
                    _buildConnectionStatus(state),
                    
                    // Main transformer diagram with fixed height
                    SizedBox(
                      height: 450,
                      child: TransformerDiagram(
                        onConnectionMade: (String fromId, String toId) {
                          state.addConnection(fromId, toId);
                          
                          // Check if bank was completed
                          if (state.currentState.isComplete && onBankComplete != null) {
                            onBankComplete!(state.currentState.bankType);
                            _showCompletionDialog(context, state);
                          }
                        },
                        onConnectionError: (String error) {
                          if (onError != null) {
                            onError!(error);
                          }
                          _showErrorFeedback(context, error);
                        },
                        showGuidance: false, // No guidance in quiz mode
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Quiz control buttons - keep at bottom
            _buildControlButtons(context, state),
          ],
        ),
    );

  /// Build quiz header with bank information
  Widget _buildQuizHeader(TransformerTrainerState state) {
    final TransformerBankType bankType = state.currentState.bankType;
    final String title = EducationalContent.getBankTitle(bankType);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Colors.purple[100]!, Colors.purple[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.quiz, color: Colors.purple[700], size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Quiz Mode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.purple[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple[200]!),
            ),
            child: const Row(
              children: <Widget>[
                Icon(Icons.info_outline, color: Colors.purple),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Make all the correct connections to complete this transformer bank configuration. No guidance will be provided.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build connection status indicator
  Widget _buildConnectionStatus(TransformerTrainerState state) {
    final int totalConnections = state.requiredConnections.length;
    final int correctConnections = state.currentState.connections
        .where((WireConnection conn) => conn.isCorrect)
        .length;
    final int incorrectConnections = state.currentState.connections
        .where((WireConnection conn) => !conn.isCorrect)
        .length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _buildStatusItem(
                  'Correct',
                  correctConnections,
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildStatusItem(
                  'Incorrect',
                  incorrectConnections,
                  Colors.red,
                  Icons.cancel,
                ),
              ),
              Expanded(
                child: _buildStatusItem(
                  'Remaining',
                  totalConnections - correctConnections,
                  Colors.orange,
                  Icons.radio_button_unchecked,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: totalConnections > 0 ? correctConnections / totalConnections : 0,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          const SizedBox(height: 4),
          Text(
            '$correctConnections of $totalConnections connections completed',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual status item
  Widget _buildStatusItem(String label, int count, Color color, IconData icon) => Column(
      children: <Widget>[
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );

  /// Build control buttons for quiz mode
  Widget _buildControlButtons(BuildContext context, TransformerTrainerState state) {
    final bool hasConnections = state.currentState.connections.isNotEmpty;
    final bool isComplete = state.currentState.isComplete;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          // Clear all button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: hasConnections
                  ? () {
                      _showClearConfirmation(context, state);
                    }
                  : null,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red[300]!),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Check answers button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: hasConnections
                  ? () {
                      _showAnswerCheck(context, state);
                    }
                  : null,
              icon: const Icon(Icons.fact_check),
              label: const Text('Check Answers'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Submit/Complete button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isComplete
                  ? () {
                      _showCompletionDialog(context, state);
                    }
                  : null,
              icon: const Icon(Icons.check),
              label: const Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isComplete ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show clear confirmation dialog
  void _showClearConfirmation(BuildContext context, TransformerTrainerState state) {
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
            'Clear All Connections?',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          content: Text(
            'This will remove all current connections. Are you sure you want to continue?',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                state.clearConnections();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: AppTheme.white,
              ),
              child: const Text('Clear All'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show answer check dialog
  void _showAnswerCheck(BuildContext context, TransformerTrainerState state) {
    final int correctConnections = state.currentState.connections
        .where((WireConnection conn) => conn.isCorrect)
        .length;
    final int totalRequired = state.requiredConnections.length;
    final List<WireConnection> incorrectConnections = state.currentState.connections
        .where((WireConnection conn) => !conn.isCorrect)
        .toList();
    
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
            'Answer Check',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Correct connections: $correctConnections / $totalRequired',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (incorrectConnections.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    'Incorrect connections:',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.errorRed,
                    ),
                  ),
                  ...incorrectConnections.map(
                    (WireConnection conn) => Padding(
                      padding: const EdgeInsets.only(top: 4, left: 8),
                      child: Text(
                        '• ${conn.fromPointId} → ${conn.toPointId}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.errorRed,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (incorrectConnections.first.errorReason != null)
                    Text(
                      'Tip: ${incorrectConnections.first.errorReason}',
                      style: AppTheme.bodyMedium.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show error feedback as snackbar
  void _showErrorFeedback(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(error)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show completion dialog
  void _showCompletionDialog(BuildContext context, TransformerTrainerState state) {
    final TransformerBankType bankType = state.currentState.bankType;
    final String title = EducationalContent.getBankTitle(bankType);
    final int correctConnections = state.currentState.connections
        .where((WireConnection conn) => conn.isCorrect)
        .length;
    final int totalConnections = state.requiredConnections.length;
    
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
          title: Row(
            children: <Widget>[
              const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text(
                'Quiz Complete!',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.primaryNavy,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Congratulations! You have successfully completed the $title quiz.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Final Score',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$correctConnections / $totalConnections',
                      style: AppTheme.headlineLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successGreen,
                      ),
                    ),
                    Text(
                      'Correct Connections',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                state.clearConnections();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
              ),
              child: const Text('Try Again'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                foregroundColor: AppTheme.white,
              ),
              child: const Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }
}
