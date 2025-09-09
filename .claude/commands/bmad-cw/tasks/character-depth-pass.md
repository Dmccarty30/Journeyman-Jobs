# /character-depth-pass Task

When this command is used, execute the following task:

<!-- Powered by BMAD™ Core -->

# ------------------------------------------------------------

# 9. Character Depth Pass

# ------------------------------------------------------------

---

task:
id: character-depth-pass
name: Character Depth Pass
description: Enrich character profiles with backstory and arc details.
persona_default: character-psychologist
inputs:

- character-summaries.md
  steps:
- For each character, add formative events, internal conflicts, arc milestones.
  output: characters.md
  ...
