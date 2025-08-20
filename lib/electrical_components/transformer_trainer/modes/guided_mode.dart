
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../design_system/app_theme.dart';
import '../../../design_system/popup_theme.dart';
import '../models/educational_content.dart';
import '../models/transformer_models_export.dart';
import '../state/transformer_state.dart';
import '../widgets/transformer_diagram.dart';

/// Guided training mode with step-by-step instructions
class GuidedModeWidget extends StatelessWidget {

  const GuidedModeWidget({
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
      builder: (BuildContext context, TransformerTrainerState state, Widget? child) {
        final TrainingStep? currentStep = state.currentStep;
        
        return Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    // Progress indicator
                    _buildProgressIndicator(state),
                    
                    // Current step instructions (if available)
                    if (currentStep != null) _buildStepInstructions(currentStep),
                    
                    // Bank information panel
                    _buildBankInfoPanel(state),
                    
                    // Main transformer diagram with fixed height
                    SizedBox(
                      height: 450,
                      child: TransformerDiagram(
                        onConnectionMade: (String fromId, String toId) {
                          state.addConnection(fromId, toId);
                          
                          // Check if step was completed
                          final TrainingStep? updatedStep = state.currentStep;
                          if (updatedStep != currentStep && onStepComplete != null && currentStep != null) {
                            onStepComplete!(currentStep);
                          }
                          
                          // Check if bank was completed
                          if (state.currentState.isComplete && onBankComplete != null) {
                            onBankComplete!(state.currentState.bankType);
                          }
                        },
                        onConnectionError: (String error) {
                          if (onError != null) {
                            onError!(error);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Step navigation buttons - keep at bottom
            _buildNavigationButtons(context, state),
          ],
        );
      },
    );

  /// Build progress indicator showing current step
  Widget _buildProgressIndicator(TransformerTrainerState state) {
    final List<TrainingStep> steps = state.trainingSteps;
    if (steps.isEmpty) return const SizedBox();
    
    final int currentStepIndex = state.currentState.currentStep;
    final double progress = currentStepIndex / steps.length;
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Text(
            'Step ${currentStepIndex + 1} of ${steps.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
          ),
        ],
      ),
    );
  }

  /// Build current step instructions
  Widget _buildStepInstructions(TrainingStep step) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.lightbulb_outline, color: Colors.blue[600]),
              const SizedBox(width: 8),
              const Text(
                'Current Step',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            step.instruction,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            step.explanation,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          
          // Safety note if present
          if (step.safetyNote != null) ...<Widget>[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.warning_amber, color: Colors.orange[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Safety Note:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(step.safetyNote!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Common mistake warning if present
          if (step.commonMistake != null) ...<Widget>[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Common Mistake:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(step.commonMistake!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

  /// Build bank information panel
  Widget _buildBankInfoPanel(TransformerTrainerState state) {
    final TransformerBankType bankType = state.currentState.bankType;
    final String title = EducationalContent.getBankTitle(bankType);
    final String description = EducationalContent.getBankDescription(bankType);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(description),
                const SizedBox(height: 12),
                
                // Safety notes
                const Text(
                  'Safety Considerations:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...EducationalContent.getSafetyNotes(bankType).map(
                  (String note) => Padding(
                    padding: const EdgeInsets.only(top: 4, left: 16),
                    child: Text('• $note'),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Common mistakes
                const Text(
                  'Common Mistakes to Avoid:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...EducationalContent.getCommonMistakes(bankType).map(
                  (String mistake) => Padding(
                    padding: const EdgeInsets.only(top: 4, left: 16),
                    child: Text('• $mistake'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build navigation buttons for step control
  Widget _buildNavigationButtons(BuildContext context, TransformerTrainerState state) {
    final List<TrainingStep> steps = state.trainingSteps;
    final int currentStepIndex = state.currentState.currentStep;
    final bool isComplete = state.currentState.isComplete;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          // Previous step button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: currentStepIndex > 0
                  ? () {
                      final TrainingState newState = state.currentState.copyWith(
                        currentStep: currentStepIndex - 1,
                      );
                      state.updateState(newState);
                    }
                  : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.grey[700],
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Next step / Complete button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isComplete
                  ? () {
                      _showCompletionDialog(context, state.currentState.bankType);
                    }
                  : (currentStepIndex < steps.length - 1)
                      ? () {
                          final TrainingState newState = state.currentState.copyWith(
                            currentStep: currentStepIndex + 1,
                          );
                          state.updateState(newState);
                        }
                      : null,
              icon: Icon(isComplete ? Icons.check_circle : Icons.arrow_forward),
              label: Text(isComplete ? 'Complete!' : 'Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isComplete ? Colors.green : Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show completion dialog
  void _showCompletionDialog(BuildContext context, TransformerBankType bankType) {
    showDialog(
      context: context,
      barrierColor: PopupThemeData.alertDialog().barrierColor,
      builder: (BuildContext context) => PopupTheme(
        data: PopupThemeData.alertDialog(),
        child: AlertDialog(
          backgroundColor: PopupThemeData.alertDialog().backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PopupThemeData.alertDialog().borderRadius),
            side: BorderSide(
              color: PopupThemeData.alertDialog().borderColor,
              width: PopupThemeData.alertDialog().borderWidth,
            ),
          ),
          elevation: PopupThemeData.alertDialog().elevation,
          contentPadding: PopupThemeData.alertDialog().padding,
          title: Row(
            children: <Widget>[
              const Icon(Icons.celebration, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Congratulations!',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.primaryNavy,
                ),
              ),
            ],
          ),
          content: Text(
            'You have successfully completed the ${EducationalContent.getBankTitle(bankType)} training!',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Clear connections to start fresh
                Provider.of<TransformerTrainerState>(context, listen: false)
                    .clearConnections();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
              ),
              child: const Text('Start Over'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: AppTheme.white,
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
