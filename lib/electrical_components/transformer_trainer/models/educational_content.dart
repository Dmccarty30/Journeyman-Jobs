
import 'transformer_models_export.dart';

/// Contains all educational content for the transformer trainer
class EducationalContent {
  
  /// Voltage scenarios for different difficulty levels
  static const Map<DifficultyLevel, List<VoltageScenario>> voltageScenarios = <DifficultyLevel, List<VoltageScenario>>{
    DifficultyLevel.beginner: <VoltageScenario>[
      VoltageScenario(
        name: 'Residential 120/240V',
        voltages: <String, int>{'primary': 7200, 'secondary_line': 240, 'secondary_neutral': 120},
        description: 'Standard residential transformer bank configuration',
      ),
    ],
    DifficultyLevel.intermediate: <VoltageScenario>[
      VoltageScenario(
        name: 'Light Commercial 240/480V',
        voltages: <String, int>{'primary': 12470, 'secondary_line': 480, 'secondary_neutral': 277},
        description: 'Common light commercial and small industrial setup',
      ),
    ],
    DifficultyLevel.advanced: <VoltageScenario>[
      VoltageScenario(
        name: 'Industrial 480V/4160V',
        voltages: <String, int>{'primary': 13800, 'secondary_line': 4160, 'secondary_neutral': 2400},
        description: 'High voltage industrial transformer bank',
      ),
    ],
  };

  /// Bank type descriptions and applications
  static const Map<TransformerBankType, Map<String, String>> bankDescriptions = <TransformerBankType, Map<String, String>>{
    TransformerBankType.wyeToWye: <String, String>{
      'title': 'Wye-Wye Connection',
      'description': 'Both primary and secondary windings connected in wye (star) configuration. Provides a neutral on both sides.',
      'applications': 'Residential distribution, balanced loads, systems requiring neutral',
      'advantages': 'Neutral available, balanced voltages, good for single-phase loads',
      'disadvantages': 'Third harmonic issues, requires careful neutral handling',
    },
    TransformerBankType.deltaToDelta: <String, String>{
      'title': 'Delta-Delta Connection',
      'description': 'Both primary and secondary in delta configuration. No neutral point naturally available.',
      'applications': 'Industrial motor loads, three-phase power without neutral',
      'advantages': 'No third harmonic circulation, can operate with one transformer out',
      'disadvantages': 'No neutral point, unbalanced loading issues',
    },
    TransformerBankType.wyeToDelta: <String, String>{
      'title': 'Wye-Delta Connection',
      'description': 'Primary in wye, secondary in delta. Common utility distribution setup.',
      'applications': 'Utility distribution, stepping down transmission voltages',
      'advantages': 'Primary neutral for lightning protection, stable secondary voltages',
      'disadvantages': 'Phase shift, requires careful paralleling',
    },
    TransformerBankType.deltaToWye: <String, String>{
      'title': 'Delta-Wye Connection',
      'description': 'Primary in delta, secondary in wye. Often used for generation step-up.',
      'applications': 'Power generation, creating neutral on secondary side',
      'advantages': 'Secondary neutral available, good for mixed loads',
      'disadvantages': 'Primary has no neutral, phase shift considerations',
    },
    TransformerBankType.openDelta: <String, String>{
      'title': 'Open Delta (V-V) Connection',
      'description': 'Two transformers connected to provide three-phase service. Emergency configuration.',
      'applications': 'Emergency operation, cost-effective three-phase from two transformers',
      'advantages': 'Lower cost, maintains service with failed transformer',
      'disadvantages': 'Only 86.6% capacity, voltage unbalance with unbalanced loads',
    },
  };

  /// Safety notes for each configuration
  static const Map<TransformerBankType, List<String>> safetyNotes = <TransformerBankType, List<String>>{
    TransformerBankType.wyeToWye: <String>[
      'Ensure proper neutral grounding on primary side',
      'Check phase rotation before energizing',
      'Verify neutral isolation between primary and secondary',
      'Test insulation before connection',
    ],
    TransformerBankType.deltaToDelta: <String>[
      'No neutral point - ensure proper grounding scheme',
      'Check all three phases before closing',
      'Verify correct polarity markings',
      'Test for opens in delta connections',
    ],
    TransformerBankType.wyeToDelta: <String>[
      'Primary neutral must be properly grounded',
      '30-degree phase shift - check rotation',
      'Verify voltage ratios match system requirements',
      'Check for proper isolation between primary and secondary neutrals',
    ],
    TransformerBankType.deltaToWye: <String>[
      'Secondary neutral must be properly grounded',
      'Check for 30-degree phase shift',
      'Verify proper connection sequence',
      'Test secondary neutral for proper grounding',
    ],
    TransformerBankType.openDelta: <String>[
      'Only 86.6% of normal capacity available',
      'Monitor for voltage unbalance under load',
      'Check both transformers are properly connected',
      'Plan for full bank restoration as soon as possible',
    ],
  };

  /// Common mistakes for each bank type
  static const Map<TransformerBankType, List<String>> commonMistakes = <TransformerBankType, List<String>>{
    TransformerBankType.wyeToWye: <String>[
      'Connecting primary and secondary neutrals together',
      'Incorrect polarity on one phase',
      'Not grounding primary neutral properly',
      'Missing neutral connection on secondary',
    ],
    TransformerBankType.deltaToDelta: <String>[
      'Incorrect polarity causing circulating currents',
      'Not checking for opens in delta loop',
      'Forgetting to verify phase rotation',
      'Improper grounding scheme',
    ],
    TransformerBankType.wyeToDelta: <String>[
      'Not accounting for 30-degree phase shift',
      'Incorrect primary neutral grounding',
      'Wrong secondary voltage measurements',
      'Polarity reversal on secondary connections',
    ],
    TransformerBankType.deltaToWye: <String>[
      'Secondary neutral not properly grounded',
      'Phase shift causing incorrect rotation',
      'Primary connections not properly closed',
      'Voltage ratio miscalculations',
    ],
    TransformerBankType.openDelta: <String>[
      'Not removing failed transformer from circuit',
      'Overloading remaining transformers',
      'Incorrect voltage measurements',
      'Not monitoring for unbalanced conditions',
    ],
  };

  /// Training steps for guided mode
  static List<TrainingStep> getTrainingSteps(TransformerBankType bankType) {
    switch (bankType) {
      case TransformerBankType.wyeToWye:
        return wyeToWyeSteps;
      case TransformerBankType.deltaToDelta:
        return deltaToDeltaSteps;
      case TransformerBankType.wyeToDelta:
        return wyeToDeltaSteps;
      case TransformerBankType.deltaToWye:
        return deltaToWyeSteps;
      case TransformerBankType.openDelta:
        return openDeltaSteps;
    }
  }

  /// Wye-to-Wye training steps
  static const List<TrainingStep> wyeToWyeSteps = <TrainingStep>[
    TrainingStep(
      stepNumber: 1,
      instruction: 'Connect primary phase A to transformer 1 H1 terminal',
      explanation: 'Start with phase A connection to establish reference point',
      requiredConnections: <String>['phase_a_to_t1_h1'],
      safetyNote: 'Ensure power is off and locked out before making connections',
    ),
    TrainingStep(
      stepNumber: 2,
      instruction: 'Connect primary phase B to transformer 2 H1 terminal',
      explanation: 'Continue with phase B to second transformer',
      requiredConnections: <String>['phase_b_to_t2_h1'],
    ),
    TrainingStep(
      stepNumber: 3,
      instruction: 'Connect primary phase C to transformer 3 H1 terminal',
      explanation: 'Complete primary phase connections',
      requiredConnections: <String>['phase_c_to_t3_h1'],
    ),
    TrainingStep(
      stepNumber: 4,
      instruction: 'Connect all H2 terminals together for primary neutral',
      explanation: 'This forms the wye point on the primary side',
      requiredConnections: <String>['t1_h2_to_t2_h2', 't2_h2_to_t3_h2'],
      safetyNote: 'Primary neutral must be properly grounded per NEC requirements',
    ),
    TrainingStep(
      stepNumber: 5,
      instruction: 'Connect secondary X1 terminals to output phases',
      explanation: 'X1 terminals provide the secondary phase outputs',
      requiredConnections: <String>['t1_x1_to_out_a', 't2_x1_to_out_b', 't3_x1_to_out_c'],
    ),
    TrainingStep(
      stepNumber: 6,
      instruction: 'Connect all X2 terminals together for secondary neutral',
      explanation: 'This creates the secondary neutral point',
      requiredConnections: <String>['t1_x2_to_t2_x2', 't2_x2_to_t3_x2'],
      safetyNote: 'Secondary neutral must be bonded and grounded at service entrance',
    ),
  ];

  /// Delta-to-Delta training steps  
  static const List<TrainingStep> deltaToDeltaSteps = <TrainingStep>[
    TrainingStep(
      stepNumber: 1,
      instruction: 'Connect primary phase A to transformer 1 H1 terminal',
      explanation: 'Begin primary delta connections',
      requiredConnections: <String>['phase_a_to_t1_h1'],
      safetyNote: 'Verify transformer polarity markings before proceeding',
    ),
    TrainingStep(
      stepNumber: 2,
      instruction: 'Connect transformer 1 H2 to transformer 2 H1',
      explanation: 'Form first leg of primary delta',
      requiredConnections: <String>['t1_h2_to_t2_h1'],
    ),
    TrainingStep(
      stepNumber: 3,
      instruction: 'Connect primary phase B to transformer 2 H2',
      explanation: 'Continue primary delta formation',
      requiredConnections: <String>['phase_b_to_t2_h2'],
    ),
    TrainingStep(
      stepNumber: 4,
      instruction: 'Connect transformer 2 H2 to transformer 3 H1',
      explanation: 'Second leg of primary delta',
      requiredConnections: <String>['t2_h2_to_t3_h1'],
    ),
    TrainingStep(
      stepNumber: 5,
      instruction: 'Connect primary phase C to transformer 3 H2',
      explanation: 'Continue primary connections',
      requiredConnections: <String>['phase_c_to_t3_h2'],
    ),
    TrainingStep(
      stepNumber: 6,
      instruction: 'Complete primary delta by connecting transformer 3 H2 to transformer 1 H1',
      explanation: 'Close the primary delta loop',
      requiredConnections: <String>['t3_h2_to_t1_h1'],
      commonMistake: 'Wrong polarity here will cause circulating currents',
    ),
    TrainingStep(
      stepNumber: 7,
      instruction: 'Form secondary delta following same pattern',
      explanation: 'Mirror the primary connections on secondary side',
      requiredConnections: <String>['t1_x1_to_out_a', 't1_x2_to_t2_x1', 't2_x2_to_out_b', 't2_x2_to_t3_x1', 't3_x2_to_out_c', 't3_x2_to_t1_x1'],
      safetyNote: 'Test continuity before energizing to ensure proper delta closure',
    ),
  ];

  /// Additional training steps would be defined for other bank types...
  /// For brevity, showing structure for remaining types
  
  static const List<TrainingStep> wyeToDeltaSteps = <TrainingStep>[
    // TODO: Complete wye-to-delta training steps
  ];
  
  static const List<TrainingStep> deltaToWyeSteps = <TrainingStep>[
    // TODO: Complete delta-to-wye training steps  
  ];
  
  static const List<TrainingStep> openDeltaSteps = <TrainingStep>[
    // TODO: Complete open delta training steps
  ];

  /// Helper methods for content retrieval
  static String getBankTitle(TransformerBankType type) => bankDescriptions[type]?['title'] ?? 'Unknown Bank Type';
  
  static String getBankDescription(TransformerBankType type) => bankDescriptions[type]?['description'] ?? 'No description available';
  
  static List<String> getSafetyNotes(TransformerBankType type) => safetyNotes[type] ?? <String>[];
  
  static List<String> getCommonMistakes(TransformerBankType type) => commonMistakes[type] ?? <String>[];
}
