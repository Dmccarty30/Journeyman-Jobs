# JOURNEYMAN JOBS Constitution

## Core Principles

### I. Library-First

Every feature must be developed as a standalone, self-contained library. Each library must be independently testable, fully documented, and serve a clear, singular purpose. Organizational-only libraries are prohibited.

### II. CLI Interface

Every library must expose its core functionality through a Command-Line Interface (CLI). The CLI will adhere to a strict text-in/text-out protocol: input via stdin/args, output to stdout, and errors to stderr. Both JSON and human-readable formats must be supported.

### III. Test-First (NON-NEGOTIABLE)

A strict Test-Driven Development (TDD) methodology is mandatory for all new features and bug fixes. The development cycle is as follows: tests are written first, approved by the user, confirmed to fail, and only then is the implementation code written. The Red-Green-Refactor cycle is to be strictly enforced.

### IV. Integration Testing

Integration tests are required for specific areas of development, including: new library contract tests, any changes to existing contracts, inter-service communication, and modifications to shared schemas.

### V. Observability, VI. Versioning & Breaking Changes, VII. Simplicity

Structured logging is required for all services to ensure debuggability. All versioning will follow the MAJOR.MINOR.BUILD format, with strict adherence to semantic versioning rules for breaking changes. All development should start simple, following YAGNI ("You Ain't Gonna Need It") principles.

## Technical Standards and Stack

The following technical standards are mandatory for all development within the Journeyman Jobs project:

- **Primary Stack**: All application code will be written in Flutter/Dart.
- **Backend Services**: The project will exclusively use Firebase for backend services, including Firestore, Cloud Functions, and Storage.
- **Design System**: All UI components must strictly adhere to the "Prime Design System" as documented in `.clinerules/1-prime.md`. No exceptions are permitted.

## Development Workflow and Quality Assurance

All code contributions must follow this workflow:

- **Version Control**: A feature-branch-based workflow is required. All work must be done in a branch and merged via a pull request.
- **Quality Gates**: Before any code is merged, it must pass a pull request review, receive approval from at least one other developer, and pass all automated tests and quality checks.

## Governance

This Constitution supersedes all other practices and documents. All pull requests and code reviews must verify compliance with these principles. Any increase in complexity must be explicitly justified. For runtime development guidance, refer to `CLAUDE.md`.

**Version**: 1.0.0 | **Ratified**: 2025-09-14 | **Last Amended**: 2025-09-14
