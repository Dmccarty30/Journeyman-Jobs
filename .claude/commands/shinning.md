# Run these 4 sub agent tasks simultaneously in parallel

***instructions:***
 Analyze the Journeyman Jobs v3 Flutter app and create comprehensive documentation for the new Transformer Bank feature

*docs-architect*: Analyze the existing Flutter app architecture at M:\Claude's Workspace\v3 and document the current state including navigation patterns, Firebase integration, and component structure. Then create detailed technical specifications for the new Transformer Bank feature based on the x-former-feature.md requirements.

*ui-ux-designer*: Design the complete user flow and interface specifications for both Reference and Training modes of the Transformer Bank feature. Create wireframes showing:

- Settings screen integration for "Transformer Bank" option
- Reference mode with interactive transformer diagrams
- Training mode with drag-and-drop interfaces
- Difficulty level selection screens
- Animation states for correct/incorrect wiring
- Visual differentiation between difficulty levels (consider color schemes, animations, complexity indicators)

*flutter-expert*: Review the existing Flutter app structure and define the technical architecture for integrating the Transformer Bank feature including:

- Widget hierarchy for both modes
- State management approach (Provider pattern integration)
- Animation controllers for electrical fire/success animations
- Drag-and-drop implementation strategy
- Data models for transformer configurations

*Context Manager*: Ensure context is captured and distributed effectively for maintaining coherent state across multiple agent interactions and sessions.

- Extract key decisions and rationale from agent outputs
- Identify reusable patterns and solutions
- Document integration points between components
- Track unresolved issues and TODOs
