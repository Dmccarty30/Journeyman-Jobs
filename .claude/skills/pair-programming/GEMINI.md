# Pair Programming

Collaborative AI pair programming with intelligent role management, real-time quality monitoring, and integrated testing.

## Collaboration Modes

- **Driver Mode**: You write the code; the AI provides guidance, spots issues, and suggests improvements (Navigator).
- **Navigator Mode**: The AI writes the code based on your high-level direction and architectural decisions (Driver).
- **Switch Mode**: Automatically alternates roles at set intervals (e.g., every 10 minutes) for balanced collaboration.
- **Specialized Modes**:
    - **TDD Mode**: Focus on the Test-Driven Development cycle.
    - **Review Mode**: Real-time feedback, security scanning, and performance analysis.
    - **Mentor Mode**: Detailed explanations and step-by-step guidance for learning.
    - **Debug Mode**: Issue identification and root cause analysis.

## Core Capabilities

- **Real-Time Verification**: Automatic quality scoring and feedback.
- **Integrated Testing**: Run tests, track coverage, and generate test cases.
- **Code Review**: Security scanning, performance analysis, and best practice enforcement.
- **Git Integration**: Commit with verification and manage branches.

## Best Practices

1. **Clear Goals**: Define session objectives before starting.
2. **Appropriate Mode**: Choose a mode based on the task (e.g., Navigator for rapid prototyping).
3. **Regular Testing**: Run tests after each significant change.
4. **Frequent Communication**: Ask for explanations or alternatives often.
5. **Role Switching**: Use Switch mode to prevent fatigue and ensure both partners stay engaged.

## Common Commands
- `/suggest`: Get improvement suggestions.
- `/explain`: Ask for a detailed explanation of the code.
- `/refactor`: Request a refactor of the selected code.
- `/test`: Run the test suite.
- `/review`: Perform a real-time code review.
