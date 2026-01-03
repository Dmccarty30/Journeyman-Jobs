# Agentic Jujutsu

Quantum-ready, self-learning version control designed for multiple AI agents working simultaneously without conflicts.

## Core Capabilities
- **Lock-free Version Control**: 23x faster than Git, enabling concurrent modifications.
- **Self-Learning**: Tracks operations and outcomes to provide intelligent suggestions for future tasks using ReasoningBank.
- **Quantum-Resistant Security**: Uses SHA3-512 fingerprints and HQC-128 encryption.
- **Multi-Agent Coordination**: Allows multiple agents to work on the same codebase without blocking each other.

## Key Concepts
- **Trajectory**: A sequence of operations performed to complete a task.
- **ReasoningBank**: The intelligence engine that learns from finalized trajectories.
- **Pattern Discovery**: Automatically identifies successful sequences of operations.

## Basic Usage
```javascript
// Start a trajectory
jj.startTrajectory('Implement feature X');

// Perform operations
await jj.newCommit('Add feature X');

// Finalize to learn
jj.finalizeTrajectory(0.9, 'Success');

// Get suggestions for next time
const suggestion = jj.getSuggestion('Implement feature Y');
```

## Best Practices
- ** meaningful descriptions**: Use clear descriptions for trajectories to improve learning.
- **Honest scoring**: Rate trajectories accurately (0.0 - 1.0) so the AI learns what works and what doesn't.
- **Record failures**: Finalize failed trajectories with low scores and critiques to prevent repeating mistakes.
