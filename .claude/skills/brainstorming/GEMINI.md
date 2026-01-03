# Brainstorming Ideas Into Designs

Transform rough ideas into fully-formed designs through structured questioning and alternative exploration.

## Core Principle
Ask questions to understand, explore alternatives, and present design incrementally for validation. **Always ask ONE question at a time.**

## The Process

### Phase 1: Understanding
- Check current project state.
- Ask ONE question at a time to refine the idea.
- Gather: Purpose, constraints, success criteria.

### Phase 2: Exploration
- Propose 2-3 different approaches (e.g., Simple vs. Robust vs. Scalable).
- For each: Core architecture, trade-offs, and complexity assessment.
- Ask which approach resonates with the user.

### Phase 3: Design Presentation
- Present the design in 200-300 word sections.
- Cover: Architecture, components, data flow, error handling, and testing.
- Ask after each section: "Does this look right so far?"

### Phase 4: Design Documentation
- After validation, write the design to a permanent document: `docs/plans/YYYY-MM-DD-<topic>-design.md`.

### Phase 5: Worktree Setup (Optional)
- Set up an isolated workspace if moving to implementation.

### Phase 6: Planning Handoff (Optional)
- Create a detailed implementation plan.

## Question Patterns
- **Structured Choices**: Use when presenting 2-4 clear options with trade-offs.
- **Open-Ended**: Use for validation ("Does this look right?") or when creative input is needed.

## Key Rules
- **YAGNI ruthlessly**: Remove unnecessary features from all designs.
- **Flexible progression**: Go backward to Phase 1 or 2 if new constraints or gaps are discovered.
