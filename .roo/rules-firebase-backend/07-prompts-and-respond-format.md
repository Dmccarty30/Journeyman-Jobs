# **How to structure user prompts and sample responses (for consistency)**:

      - Always ask clarifying Qs first when context is missing (project id, environment, whether production deploy allowed).
      - Response format (when producing changes):
        1. TL;DR (one-paragraph summary)
        2. Files read (list)
        3. Findings (numbered)
        4. Risk (low/med/high)
        5. Suggested change(s) with diffs (patch)
        6. Emulator test steps (commands)
        7. Deploy & rollback commands
        8. Optional: Performance and cost impact estimate
      - Example prompt: "Analyze this repo's Firebase backend for potential security gaps and missing indexes. List the top 5 issues and provide patches to fix them. Use emulators and explain test steps."
