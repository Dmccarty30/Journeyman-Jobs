/build --feature "Transformer Bank" --tdd --flutter

## Context

Read this file: @x-former-feature.md for more details about the feature.

## *Implamentation*

Step 1. Build these two screens. Be sure to follow the apps design theme.

``` wireframe
┌─────────────────────────────────────────────────────────┐
│ ◀ Transformer Bank                              ⋮       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │            HERO SECTION                             │ │
│ │ ╔═══════════════════════════════════════════════════╗ │ │
│ │ ║  ⚡ Circuit Pattern Background ⚡               ║ │ │
│ │ ║                                                 ║ │ │
│ │ ║     Master Transformer Banks                    ║ │ │
│ │ ║     Professional Training & Reference           ║ │ │
│ │ ║                                                 ║ │ │
│ │ ║        [Animated Lightning Icon]                ║ │ │
│ │ ╚═══════════════════════════════════════════════════╝ │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ MODE SELECTION                                          │
│                                                         │
│ ┌─────────────────────┐   ┌─────────────────────────┐   │
│ │    REFERENCE        │   │       TRAINING          │   │
│ │    📚 [Book Icon]   │   │    🎯 [Target Icon]     │   │
│ │                     │   │                         │   │
│ │ Study & Learn       │   │  Test Your Knowledge    │   │
│ │ Configurations      │   │  Interactive Practice   │   │
│ │                     │   │                         │   │
│ │ • View all banks    │   │ • 3 Difficulty levels   │   │
│ │ • Component info    │   │ • Real-time feedback    │   │
│ │ • Technical specs   │   │ • Progress tracking     │   │
│ │                     │   │                         │   │
│ │   [Explore] ──────► │   │   [Start Training] ───► │   │
│ └─────────────────────┘   └─────────────────────────┘   │
│                                                         │
│ QUICK ACCESS (Optional)                                 │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 📈 Recent Activity                                  │ │
│ │ • Delta-Delta Training (85% Complete)              │ │
│ │ • Wye-Wye Reference (Last viewed)                  │ │
│ │                                                     │ │
│ │ ⭐ Bookmarks                                        │ │
│ │ • Open-Delta Configuration                          │ │
│ │ • Single Pot Setup                                 │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 2. Reference Mode - Configuration Selection

``` wireframe
┌─────────────────────────────────────────────────────────┐
│ ◀ Reference Mode                                🔍 ⚙    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ ℹ️  SELECT A CONFIGURATION TO EXPLORE               │ │
│ │ Tap any transformer bank to view detailed diagrams  │ │
│ │ and learn about each component.                     │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ SINGLE POT TRANSFORMERS                                 │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ ┌─────────────────┐                                 │ │
│ │ │  SINGLE POT     │  120V/240V Residential          │ │
│ │ │                 │  • Common household setup       │ │
│ │ │    ╔══════╗     │  • Split-phase secondary        │ │
│ │ │    ║  T   ║     │  • Center-tapped transformer    │ │
│ │ │    ║  1   ║     │                                 │ │
│ │ │    ╚══════╝     │  [View Details] ──────────────► │ │
│ │ └─────────────────┘                                 │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ TWO POT BANKS                                           │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ ┌─────────────────┐                                 │ │
│ │ │   OPEN DELTA    │  240V Three-Phase (2 Pots)      │ │
│ │ │                 │  • V-V Connection                │ │
│ │ │  ╔══════╗       │  • 86.6% of full capacity       │ │
│ │ │  ║  T1  ║ ╔═══╗ │  • Emergency configuration       │ │
│ │ │  ╚══════╝ ║ T2║ │                                 │ │
│ │ │           ╚═══╝ │  [View Details] ──────────────► │ │
│ │ └─────────────────┘                                 │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ THREE POT BANKS                                         │
│ ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐ │
│ │   WYE-WYE    │ │ DELTA-DELTA  │ │    WYE-DELTA     │ │
│ │              │ │              │ │                  │ │
│ │   ╔═══╗      │ │  ╔═══╗       │ │    ╔═══╗         │ │
│ │  ╱║T1 ║╲     │ │ ╱║T1 ║╲      │ │   ╱║T1 ║╲        │ │
│ │ ╱ ╚═══╝ ╲    │ │╱ ╚═══╝ ╲     │ │  ╱ ╚═══╝ ╲       │ │
│ │╱   ╔═══╗  ╲  │ │   ╔═══╗   ╲  │ │ ╱   ╔═══╗   ╲    │ │
│ │    ║T3 ║     │ │   ║T3 ║      │ │     ║T3 ║        │ │
│ │ ╲  ╚═══╝  ╱  │ │ ╲ ╚═══╝   ╱  │ │  ╲  ╚═══╝   ╱    │ │
│ │  ╲ ╔═══╗ ╱   │ │  ╲╔═══╗  ╱   │ │   ╲ ╔═══╗  ╱     │ │
│ │   ╲║T2 ║╱    │ │   ║T2 ║╱     │ │    ╲║T2 ║╱      │ │
│ │    ╚═══╝     │ │   ╚═══╝      │ │     ╚═══╝       │ │
│ │              │ │              │ │                  │ │
│ │ [View] ────► │ │ [View] ────► │ │ [View] ────────► │ │
│ └──────────────┘ └──────────────┘ └──────────────────┘ │
│                                                         │
│ ┌──────────────────┐                                   │
│ │   DELTA-WYE      │                                   │
│ │                  │                                   │
│ │    ╔═══╗         │                                   │
│ │   ╱║T1 ║╲        │                                   │
│ │  ╱ ╚═══╝ ╲       │                                   │
│ │ ╱   ╔═══╗   ╲    │                                   │
│ │     ║T3 ║        │                                   │
│ │  ╲  ╚═══╝   ╱    │                                   │
│ │   ╲ ╔═══╗  ╱     │                                   │
│ │    ╲║T2 ║╱      │                                   │
│ │     ╚═══╝       │                                   │
│ │                  │                                   │
│ │ [View] ────────► │                                   │
│ └──────────────────┘                                   │
└─────────────────────────────────────────────────────────┘
```

Step 2. Build the interactive screen. This screen will be the screen that displays the transformer banks. Either two transformers or three transformers. Of those two selections they will be displayed one of two ways. Either just the transformers themselves, without any connections, or the transformers with the connections. This all depends on whether the user selects`Reference` or `Training`.

`Reference` - The connections will be displayed
`Training` - The connections will not be displayed.

This will be the image that will be used for the background on the interactive screen @Journeyman-Jobsv3\assets\images\blank-three-bank.png and @assets\images\empty-bank.png

## Creating a Tasks.md file

Given what is provided above, take in these two documents @docs\transformer_trainer\transformer-bank-component-specifications.md and @docs\transformer_trainer\transformer-bank-integration-requirements-2025-08-16.md. From these two files and this file, create a comprehensive tasks.md file in order to better keep track of our progress.

*flutter-expert*: Implement the complete Transformer Bank feature with:

- TransformerBankScreen with navigation to Reference/Training modes
- ReferenceMode widget with configuration selector and interactive transformer visualization
- TrainingMode widget with drag-and-drop wire connections
- Custom painters for transformer diagrams and wire paths
- Animation controllers for electrical fire and success animations
- Configuration data models for all transformer types
- Difficulty level management system

*frontend-developer*: Create the responsive UI components:

- Interactive tap zones on transformer parts with tooltips
- Drag-and-drop wire system with visual feedback
- Animated transitions between configurations
- Progress tracking UI for training mode
- Visual differentiation system for difficulty levels

*mobile-developer*: Ensure cross-platform compatibility:

- Touch gesture handling for drag-and-drop
- Performance optimization for animations
- Offline capability for training mode
- Screen size adaptations for tablets/phones

*performance-engineer*: Optimize the feature for smooth performance:

- Efficient rendering of complex electrical diagrams
- Animation frame rate optimization
- Memory management for multiple transformer configurations
- Lazy loading of configuration assets

*ui-ux-designer*: Design the complete user flow and interface specifications for both Reference and Training modes of the Transformer Bank feature. Create wireframes showing:

- Settings screen integration for "Transformer Bank" option
- Reference mode with interactive transformer diagrams
- Training mode with drag-and-drop interfaces
- Difficulty level selection screens
- Animation states for correct/incorrect wiring
- Visual differentiation between difficulty levels (consider color schemes, animations, complexity indicators)
