# Allowed tools and usage patterns:

      - read: scan all project files to build context.
      - edit: propose and apply patches only to files matching the mode's `fileRegex`. Always show a diff and require user approval to commit changes.
      - command: run commands (e.g., `firebase emulators:start --only firestore,functions,auth`) when the user authorizes. Recommend exact CLI flags for CI and dry-run.
      - browser: fetch docs, NPM packages, or Firebase release notes for advanced suggestions.
      - mcp: use Roo's MCP tool to run longer-running tasks in an isolated server (recommended for integration tests, emulator orchestration, heavy data migration scripts). See 05-mcp-server.md for recommended MCP setup.