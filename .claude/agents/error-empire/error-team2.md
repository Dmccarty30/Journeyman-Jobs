---
name: error-team
description: "Spawns a team of error correcting agents to analyze the codebase and create a plan to fix identified issues."
category: analysis
---

# /error-team - Spawn Error Correcting Agents

## Usage

```bash
/error-team [--queen-type tactical] [--max-workers 6] [--claude]
```

## Behavioral Flow

1. **Spawn Agents:**  The command spawns a team of specialized error correcting agents using `npx claude-flow@alpha hive-mind spawn`.
2. **Analyze Codebase:** The agents analyze the codebase for errors, bugs, problems, broken code, dead code, and dependency inconsistencies.
3. **Compose Solution Plan:** The agents brainstorm and compose a detailed, actionable code correction and solution implementation plan/guide.
4. **Breakdown into Tasks:** The plan is broken down into a comprehensive set of well-defined tasks with proposed solutions.
5. **Output Tasks:** The tasks are outputted, including the root cause, proposed solution, recommended agent, difficulty, severity, importance, and a completion checkbox.

## Arguments

* `--queen-type tactical`:  Specifies the queen type for the hive-mind deployment (default: tactical).
* `--max-workers 6`:  Specifies the maximum number of worker agents (default: 6).
* `--claude`:  Specifies the use of Claude as the language model.

## Example

To run the error team:

```bash
npx claude-flow@alpha hive-mind spawn "I need for you to create a squad of error correcting agents. These agents specialize in their own domain and have their own unique set of skills that make them world-class by themselves, but together as a team, they are unrivaled. From a  laser focused Root-cause-analysis expert, to to a genius level error identifier and relationtional expert.  A world renowned codebase refactorer to a comprehensive codebase composer who is unparalleled in the ability to reimplement code corrections in one shot. and many more top of thier field experts.  Your assignment is to lead this all-star team to target and identify all of the errors, bugs, problems, broken code, dead code, dependency inconsistancies, etc... This team is looking for the entire gambet of possible codebase flaws and once the team feels confident that they have identified everything they can, then they are to brainstorm and compose  a flawless and actionable code correction and solution implenentation plan/guide. Then finally, this crew of codebase wizards will breakdown thier plan into a comprehensive set of well defined with proposed solutions, tasks that will upon completion, eliminate every possible error and inconsistancy in this entire codebase. Each task must include: the root/main condition or cause of the error including the flawed code snippet, at least one proposed solution, the recommended agent  that is most qualified to implement the corrections, the level of difficulty, the severity and importance of the issue, and finaly a checkbox so the task can be indicated as such upon completion to reduce the possiblity of agents double working themselves. The tasks must be organized in groups or sections of domain related functions, also the order in which the task should be corrected. --queen-type tactical --max-workers 6 --claude"
```

/error-team --queen-type tactical --max-workers 6 --claude
