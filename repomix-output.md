This file is a merged representation of a subset of the codebase, containing specifically included files, combined into a single document by Repomix.
The content has been processed where comments have been removed, empty lines have been removed, content has been formatted for parsing in markdown style, content has been compressed (code blocks are separated by ⋮---- delimiter).

# File Summary

## Purpose
This file contains a packed representation of a subset of the repository's contents that is considered the most important context.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.

## File Format
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Repository files (if enabled)
5. Multiple file entries, each consisting of:
  a. A header with the file path (## File: path/to/file)
  b. The full contents of the file in a code block

## Usage Guidelines
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.

## Notes
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Only files matching these patterns are included: TODO-TASKS.md, TODO.md, scratchpad.md, .repomix/config/G-ROK_JJ-repomix.config.json, .repomix/bundles.json, c:/Users/david/.gemini/extensions/ComputerUse/README.md, c:/Users/david/.gemini/GEMINI.md, .gemini/GEMINI.md, .gemini/config.yaml, lib/electrical_components/jj_electrical_interactive_widgets.dart, lib/electrical_components/electrical_components_showcase.dart, lib/electrical_components/jj_snack_bar.dart, lib/electrical_components/jj_electrical_toast.dart, lib/design_system/app_theme.dart, lib/design_system/design_system.dart
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Code comments have been removed from supported file types
- Empty lines have been removed from all files
- Content has been formatted for parsing in markdown style
- Content has been compressed - code blocks are separated by ⋮---- delimiter
- Files are sorted by Git change count (files with more changes are at the bottom)

# Directory Structure
```
.gemini/config.yaml
.gemini/GEMINI.md
.repomix/bundles.json
.repomix/config/G-ROK_JJ-repomix.config.json
c:/Users/david/.gemini/extensions/ComputerUse/README.md
c:/Users/david/.gemini/GEMINI.md
lib/design_system/app_theme.dart
lib/design_system/design_system.dart
lib/electrical_components/electrical_components_showcase.dart
lib/electrical_components/jj_electrical_interactive_widgets.dart
lib/electrical_components/jj_electrical_toast.dart
lib/electrical_components/jj_snack_bar.dart
scratchpad.md
TODO-TASKS.md
TODO.md
```

# Files

## File: .gemini/config.yaml
````yaml
have_fun: false
code_review:
  disable: false
  comment_severity_threshold: 'HIGH'
  max_review_comments: -1
  pull_request_opened:
    help: false
    summary: true
    code_review: true
ignore_patterns: []
````

## File: .gemini/GEMINI.md
````markdown
# Journeyman Jobs - Gemini AI Assistant Guidelines

## 🚀 Project Overview

Journeyman Jobs is a Flutter mobile application for IBEW electrical professionals (journeymen, linemen, wiremen, operators, tree trimmers). Its primary purpose is to centralize job discovery, facilitate storm work opportunities, and enable crew collaboration.

**Target Users**: Inside Wiremen, Journeyman Linemen, Tree Trimmers, Equipment Operators, Inside Journeyman Electricians.

## 🛠️ Technical Stack & Architecture

* **Frontend**: Flutter 3.6+ with Dart, Riverpod for state management, `go_router` for navigation.
* **Backend**: Firebase (Authentication, Firestore, Storage, Cloud Functions).
* **Data Aggregation**: Backend services for job scraping, normalization, and caching.
* **Mobile Features**: Push Notifications (FCM), Offline Capability (local SQLite), Location Services (GPS), Biometric Authentication.

## 🎨 Design & Theme

* **Electrical Theme**: Incorporate circuit patterns, lightning bolts, and electrical symbols.
* **Primary Colors**: Navy (`#1A202C`) and Copper (`#B45309`).
* **Typography**: Google Fonts Inter.
* **Custom Components**: Use `JJ` prefix (e.g., `JJButton`).
* **Theme Constants**: Always use `AppTheme` from `lib/design_system/app_theme.dart`.

## 📂 Code Structure & Modularity

* **Feature-based architecture**:

    ```dart
    lib/
    ├── screens/
    ├── widgets/
    ├── services/
    ├── providers/
    ├── models/
    ├── design_system/
    ├── electrical_components/
    └── navigation/
    ```

* **Imports**: Prefer relative within feature, absolute for cross-feature.

## 🧪 Testing Guidelines

* **Widget tests**: For all new screens and components in `/test` directory, mirroring `/lib` structure.
* **Coverage**: Widget rendering, user interaction, state management, error handling.

## 🚦 Operational Guidelines for Gemini

1. **Context First**: Always refer to `CLAUDE.md`, `PROJECT_OVERVIEW_REPORT.md`, `plan.md`, `TASK.md`, and `guide/screens.md` for project context, current status, and requirements.
2. **Adhere to Conventions**: Strictly follow Flutter/Dart conventions, project's code style, and architectural patterns.
3. **Firebase Focus**: All backend interactions will be with Firebase. Do not assume other backend services.
4. **Electrical Theme**: Maintain the electrical design theme in all UI/UX considerations.
5. **Error Handling**: Prioritize robust error handling, logging, and user feedback.
6. **Security & Privacy**: Be mindful of PII, location data, and union data sensitivity. Ensure Firebase Security Rules are considered.
7. **Mobile-First**: Design and implement with a mobile-first approach.
8. **Offline Capability**: Consider offline support for critical features.
9. **Performance**: Optimize for performance, especially for large datasets (e.g., 797+ union locals).
10. **Clarification**: Ask for clarification on Firebase schemas, IBEW terminology, or ambiguous requirements.

## 📝 Task Management

* **Update `TASK.md`**: Reflect progress, completion, and any new discoveries.
* **Troubleshoot**: After completing any task run "Flutter Analyze" on the files that you have modified to identify any errors and correct them BEFORE marking that tasks as complete.

This `GEMINI.md` will serve as my primary reference for understanding and contributing to the Journeyman Jobs project.
````

## File: .repomix/bundles.json
````json
{
  "bundles": {
    "G-ROK_JJ-269": {
      "name": "G-ROK_JJ",
      "created": "2025-12-07T10:06:16.348Z",
      "lastUsed": "2025-12-07T10:06:16.348Z",
      "tags": [],
      "files": [],
      "configPath": ".repomix/config/G-ROK_JJ-repomix.config.json"
    }
  }
}
````

## File: .repomix/config/G-ROK_JJ-repomix.config.json
````json
{
  "output": {
    "filePath": "d:\\Journeyman-Jobs\\repomix-output.md",
    "style": "markdown",
    "parsableStyle": true,
    "headerText": "",
    "instructionFilePath": "",
    "fileSummary": true,
    "directoryStructure": true,
    "removeComments": true,
    "removeEmptyLines": true,
    "topFilesLength": 5,
    "showLineNumbers": false,
    "copyToClipboard": true,
    "includeEmptyDirectories": false,
    "compress": true
  },
  "include": [
    "lib/features/crews/**/*.dart",
    "lib/design_system/**/*.dart"
  ],
  "ignore": {
    "useGitignore": true,
    "useDefaultPatterns": true,
    "customPatterns": []
  },
  "security": {
    "enableSecurityCheck": true
  },
  "tokenCount": {
    "encoding": "o200k_base"
  },
  "cwd": "d:\\Journeyman-Jobs"
}
````

## File: c:/Users/david/.gemini/extensions/ComputerUse/README.md
````markdown
# GeminiCLI_ComputerUse_Extension

A Google Gemini-CLI extension than enables Gemini Computer Use from the CLI

## Installation

gemini extensions install <https://github.com/automateyournetwork/GeminiCLI_ComputerUse_Extension.git>

### Example Gemini-CLI prompt to VISIBLY browse a web article and produce a Markdown report

Use ComputerUse MCP headfully to VISIBLY browse like a human and produce a final Markdown report.

Goals:

- Read the article at the given URL.
- Scroll like a human (visible motion), taking a snapshot after EACH scroll step.
- Visit all in-article links (avoid mailto/tel/#). Prefer opening in NEW TABS that do not overtake the main article tab. If tab tools are unavailable, open links sequentially and return to the article each time.
- Conclude with a comprehensive Markdown summary (RAFT, retrieval-augmented fine-tuning, key takeaways), citing the pages you visited.

1) initialize_browser(
     url="<https://www.automateyournetwork.ca/pyats/augmenting-network-engineering-with-raft/>",
     width=1920, height=1080, headless=false)

2) Smoothly scroll the article TOP→BOTTOM with visible pauses. After EACH step, take a snapshot:
   for y in [200, 400, 600, 800, 1000]:
     - execute_action("scroll_to_percent", {"y": y})
     - capture_state(f"scroll_{y}")

3) Return to TOP visibly and snapshot:
   - execute_action("scroll_to_percent", {"y": 0})
   - capture_state("back_to_top")

4) Harvest in-article links (de-dupe, skip mailto/tel/#):
   - execute_action("execute_javascript", {
       "code": "(() => { \
         const scope = document.querySelector('article, main, .post-content, .entry-content') || document.body; \
         const links = Array.from(scope.querySelectorAll('a[href]')); \
         const hrefs = links.map(a => a.href.trim()) \
           .filter(h => h && !h.startsWith('mailto:') && !h.startsWith('tel:') && !h.includes('#')); \
         return Array.from(new Set(hrefs)); \
       })();"
     })

5) Visit each harvested link (limit to 8 to stay readable):
   Preferred (if these tools exist): open_new_tab, list_tabs, switch_to_tab
   - For each <link> (1-based index i):
       - If open_new_tab exists:
           - open_new_tab(url="<link>", focus=true)
           - capture_state(f"link{i}_load")                      # snapshot immediately after load
           - For y in [200, 400, 600, 800, 1000]:
                  execute_action("scroll_to_percent", {"y": y})
                  capture_state(f"link{i}_scroll_{y}")           # snapshot each scroll step
           - switch_to_tab(0)                                   # return to main article tab
       - Else (fallback when tab tools absent):
           - execute_action("open_web_browser", {"url": "<link>"})
           - capture_state(f"link{i}_load")
           - For y in [200, 400, 600, 800, 1000]:
                  execute_action("scroll_to_percent", {"y": y})
                  capture_state(f"link{i}_scroll_{y}")
           - execute_action("open_web_browser", {"url": "<https://www.automateyournetwork.ca/pyats/augmenting-network-engineering-with-raft/"}>)
           - capture_state(f"link{i}_return")                   # confirm we’re back on the main article

6) After links, return to the main article (if not already there) and capture_state("final_overview").

7) Produce a comprehensive Markdown report (no extra screenshots in the report; just text). Structure:

   # RAFT & Retrieval-Augmented Fine-Tuning — Field Notes

   - **Primary article:** title + URL
   - **Other pages visited:** bullet list of titles + URLs
   - **What RAFT is:** 3–6 bullets (your own words)
   - **How RAFT differs from standard fine-tuning:** bullets
   - **Retrieval-Augmented Fine-Tuning pipeline:** concise steps (data prep, retrieval store, adapters/LoRA/full FT, eval)
   - **Cloud vs Local comparison (from the two-part series):** capabilities, privacy, cost, constraints
   - **Implementation notes spotted in pages:** tools, commands, pitfalls
   - **Key takeaways:** 5–8 bullets
   - **References (visited):** list of URLs

Important:

- Keep actions human-visible (no instant jumps).
- If a page won’t load, skip it and continue.
- Take a small pause between scroll steps so motion is obvious.

### Example Searching Wikipedia for "Computer Networking" and producing a Markdown report

#### Wikipedia Exploration: Computer Networks

Headless=false for visible browsing.

You will systematically explore Wikipedia (and optionally Google) articles about computer networks using the ComputerUse MCP tools. Use selectors (not coordinates), add pauses so the typing is obvious, and take screenshots after each major step.

Phase 1: Initialize & Search (Wikipedia)

Initialize headful browser

initialize_browser(url="<https://www.wikipedia.org>", width=1920, height=1080, headless=false)
capture_state("wikipedia_home")
pause(800)

Search for “Computer Network” with visible typing

fill_selector('input[name="search"]', 'Computer Network', true, true)
pause(800)   # let navigation/rendering be seen
capture_state("wiki_search_results_or_article")

Note: Wikipedia may jump straight to the article. Continue from whatever page loads.

Phase 2: Explore the page/results with smooth pacing

Scroll (top → bottom) with pauses

for y in [200, 400, 600, 800, 1000]:
  execute_action("scroll_to_percent", {"y": y})
  pause(700)
  capture_state(f"wiki_scroll_{y}")

Return to top

execute_action("scroll_to_percent", {"y": 0})
pause(500)
capture_state("wiki_top")

Phase 3: Extract & Visit Links (up to 8)

Extract article links on current page

execute_action("execute_javascript", {
  "code": "(() => {\
    const links = Array.from(document.querySelectorAll('a[href*=\"/wiki/\"]'))\
      .map(a => a.href)\
      .filter(h => h.includes('wikipedia.org/wiki/') && !h.includes('#'))\
      .filter((v, i, a) => a.indexOf(v) === i);\
    return links.slice(0, 8);\
  })()"
})
pause(600)

Visit each link in sequence
For each link i:

execute_action("open_web_browser", {"url": "{{link_i}}"})
pause(900)
capture_state(f"article_{i}_loaded")

for y in [0, 250, 500, 750, 1000]:
  execute_action("scroll_to_percent", {"y": y})
  pause(650)
  capture_state(f"article_{i}_scroll_{y}")

# Go back to the search/article hub if desired

# execute_action("open_web_browser", {"url": "<the-page-you-extracted-from>"})

# pause(600)

(Optional) Phase 3b: Also show a Google search (for demo effect)
execute_action("open_web_browser", {"url": "<https://www.google.com"}>)
pause(700)
capture_state("google_home")

fill_selector('textarea[name=\"q\"]', 'Computer Network', true, true)
pause(900)
capture_state("google_results_top")

execute_action("scroll_to_percent", {"y": 600})
pause(700)
capture_state("google_results_mid")

Phase 4: Summary Report (after all visits)

After visiting all targets, produce a Markdown summary:

# Wikipedia Exploration Report: Computer Networks

## Search Query

- **Primary Query:** Computer Network
- **Search URL:** [Insert the URL where the search happened]

## Articles Visited (up to 8)

1. [Title 1](URL) — 1–2 sentence summary
2. [Title 2](URL) — 1–2 sentence summary
...

## Key Learnings

- ...
- ...

## Major Subtopics

- **Protocols & Standards:** ...
- **Topology & Architecture:** ...
- **History & Development:** ...
- **Technologies & Components:** ...
- **Related Disciplines:** ...

## All URLs Visited

1. URL
2. URL
...

## Environment Variables

🧩 Recommended ComputerUse MCP Environment Variables

Variable Purpose Recommended for Demo Example

CU_HEADFUL Launch the browser with a visible window. ✅ Yes export CU_HEADFUL=1

CU_SLOW_MO Milliseconds of delay between Playwright actions (move, click, type). ✅ Yes export CU_SLOW_MO=700

CU_SHOW_CURSOR Display cyan “cursor ring” overlay to visualize movement. ✅ Yes export CU_SHOW_CURSOR=true

CU_NO_SANDBOX Disable Chromium sandbox if Playwright complains (needed in some Docker/macOS setups). optional export CU_NO_SANDBOX=1

CU_BROWSER Force a specific browser (chromium, firefox, webkit) if you installed all. optional export CU_BROWSER=chromium

CU_DEVICE_SCALE Override Retina scaling (use 2 on macOS for pixel-accurate clicks). optional export CU_DEVICE_SCALE=2

🧠 Typical macOS Demo Setup

export CU_HEADFUL=1

export CU_SLOW_MO=800

export CU_SHOW_CURSOR=true

export CU_DEVICE_SCALE=2

export CU_NO_SANDBOX=0
````

## File: c:/Users/david/.gemini/GEMINI.md
````markdown
# Gemini Added Memories

- I am a command-line interface (CLI) tool that interacts with Gemini models. My behavior is configured through `settings.json` files, environment variables, and command-line arguments, with command-line arguments having the highest precedence. I can be extended with custom commands, prompts, and even custom tools through a system of extensions. These extensions are directories containing a `gemini-extension.json` file and can be installed from local paths or Git repositories. I have a variety of built-in tools for interacting with the local environment, such as reading and writing files, and running shell commands. My capabilities can be restricted for security, for example by running tool calls in a sandboxed environment.
- I should ask the user to double-check or peer-review my plan or actions when I am unsure, especially for critical commands or structural changes. Asking for help is a sign of strength and ensures I have the user's best interest in mind.
- Learned from a mistake: When creating custom commands for extensions, the TOML files should be placed in the project's central `.gemini/commands` directory, not in a new `commands` subdirectory within the extension's folder. The `gemini-extension.json` should only contain extension metadata. In the future, I will proactively check for existing directories and ask for user peer review to prevent such errors.
````

## File: lib/design_system/app_theme.dart
````dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../electrical_components/circuit_board_background.dart' show ComponentDensity;
class AppTheme {
````

## File: lib/design_system/design_system.dart
````dart
export 'app_theme.dart';
export 'popup_theme.dart';
export 'tailboard_components.dart';
export 'tailboard_theme.dart';
export 'theme_dark.dart';
export 'theme_light.dart';
export 'theme_variables.dart';
````

## File: lib/electrical_components/electrical_components_showcase.dart
````dart
import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';
import 'jj_electrical_interactive_widgets.dart';
import 'jj_electrical_page_transitions.dart';
void main() {
⋮----
class ElectricalComponentsShowcaseApp extends StatelessWidget {
⋮----
Widget build(BuildContext context) {
⋮----
class ShowcaseHome extends StatefulWidget {
⋮----
State<ShowcaseHome> createState() => _ShowcaseHomeState();
⋮----
class _ShowcaseHomeState extends State<ShowcaseHome> {
⋮----
void dispose() {
⋮----
Widget _buildSectionHeader(String title) {
⋮----
void _navigateToDemo(
⋮----
class TransitionDemoPage extends StatelessWidget {
````

## File: lib/electrical_components/jj_electrical_interactive_widgets.dart
````dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/app_theme.dart';
class JJElectricalButton extends StatefulWidget {
⋮----
State<JJElectricalButton> createState() => _JJElectricalButtonState();
⋮----
class _JJElectricalButtonState extends State<JJElectricalButton>
⋮----
void initState() {
⋮----
void dispose() {
⋮----
void _handleTapDown(TapDownDetails details) {
⋮----
void _handleTapUp(TapUpDetails details) {
⋮----
void _handleTapCancel() {
⋮----
Widget build(BuildContext context) {
⋮----
class JJElectricalTextField extends StatefulWidget {
⋮----
State<JJElectricalTextField> createState() => _JJElectricalTextFieldState();
⋮----
class _JJElectricalTextFieldState extends State<JJElectricalTextField>
⋮----
void _onFocusChange() {
⋮----
class JJElectricalDropdown<T> extends StatefulWidget {
⋮----
State<JJElectricalDropdown<T>> createState() => _JJElectricalDropdownState<T>();
⋮----
class _JJElectricalDropdownState<T> extends State<JJElectricalDropdown<T>>
⋮----
void _handleChanged(T? value) {
⋮----
class _SparkEffectPainter extends CustomPainter {
⋮----
void paint(Canvas canvas, Size size) {
⋮----
bool shouldRepaint(covariant CustomPainter oldDelegate) {
⋮----
class _TextFieldCurrentPainter extends CustomPainter {
⋮----
class _DropdownSparkPainter extends CustomPainter {
````

## File: lib/electrical_components/jj_electrical_toast.dart
````dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system/app_theme.dart';
enum JJToastType {
⋮----
class JJElectricalToast extends StatelessWidget {
⋮----
static void showSuccess({
⋮----
static void showError({
⋮----
static void showWarning({
⋮----
static void showInfo({
⋮----
static void showPower({
⋮----
static void showCustom({
⋮----
static void _showToast({
⋮----
static Duration _getDefaultDuration(JJToastType type) {
⋮----
_ToastTheme _getToastTheme() {
⋮----
Widget build(BuildContext context) {
⋮----
class _ToastTheme {
⋮----
class _ElectricalToastIcon extends StatelessWidget {
⋮----
class _ElectricalProgressIndicator extends StatefulWidget {
⋮----
State<_ElectricalProgressIndicator> createState() =>
⋮----
class _ElectricalProgressIndicatorState
⋮----
void initState() {
⋮----
void dispose() {
⋮----
Widget build(BuildContext context) => SizedBox(
⋮----
class _ElectricalProgressPainter extends CustomPainter {
⋮----
void paint(Canvas canvas, Size size) {
⋮----
bool shouldRepaint(covariant _ElectricalProgressPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.color != color;
⋮----
class _ToastOverlay extends StatefulWidget {
⋮----
State<_ToastOverlay> createState() => _ToastOverlayState();
⋮----
class _ToastOverlayState extends State<_ToastOverlay>
⋮----
Future<void> _dismiss() async {
⋮----
Widget build(BuildContext context) => Positioned(
````

## File: lib/electrical_components/jj_snack_bar.dart
````dart
import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';
class JJSnackBar {
static void _show(
⋮----
static void showSuccess({
⋮----
static void showError({
⋮----
static void showInfo({
⋮----
static void showWarning({
````

## File: scratchpad.md
````markdown
# SCRATCHPAD

## AUTH SCREEN

- look at the image @assets\images\auth-screen-tab-bar.png. This i A screenshot of the tab bar on the auth screen. There is a gap at the bottom of the two tabs and boarder. This is unacceptable. also, the design and layout is subpar. I need for to content, functions, actions, data bindings, navigations, authentications, etc. to remain the same. However i would like to completely make over the UI. While respecting the app theme. Remove the electric curcuit background and replace it with another animated or reactive background.
  
-**NO SOLID COLORS, SIMPLELINES, SIMPLE GRADIENTS, OLD TECNIQUES**

## ONBOARDING STEPS

- **SAMETHING APPLIES AS STATED ABOVE**

---

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/domain/enums/enums.dart';
import 'package:journeyman_jobs/domain/enums/onboarding_status.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../models/user_model.dart';
import '../../navigation/app_router.dart';
import '../../services/onboarding_service.dart';
import '../../services/firestore_service.dart';
import '../../electrical_components/jj_circuit_breaker_switch_list_tile.dart';
import '../../electrical_components/jj_circuit_breaker_switch.dart';
import '../../electrical_components/modern_svg_circuit_background.dart';

class OnboardingStepsScreen extends StatefulWidget {
  const OnboardingStepsScreen({super.key});

  @override
  State<OnboardingStepsScreen> createState() => _OnboardingStepsScreenState();
}

class _OnboardingStepsScreenState extends State<OnboardingStepsScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Step 1: Personal Information
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipcodeController = TextEditingController();
  
  // Focus nodes for keyboard navigation
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _address1Focus = FocusNode();
  final _address2Focus = FocusNode();
  final _cityFocus = FocusNode();
  final _zipcodeFocus = FocusNode();

  // Step 2: Professional Details
  final _step2FormKey = GlobalKey<FormState>(); // New: Form key for Step 2
  final _homeLocalController = TextEditingController();
  final _ticketNumberController = TextEditingController();
  String? _selectedClassification;
  bool _isWorking = false;

  // Step 3: Job Preferences & Goals
  bool _networkWithOthers = false;
  bool _careerAdvancements = false;
  bool _betterBenefits = false;
  bool _higherPayRate = false;
  bool _learnNewSkill = false;
  bool _travelToNewLocation = false;
  bool _findLongTermWork = false;

  // Step 2: Additional Professional Details
  final _booksOnController = TextEditingController();

  // Loading state for save operations
  bool _isSaving = false;

  // Step 3: Preferences and Feedback
  final Set<String> _selectedConstructionTypes = <String>{};
  String? _selectedHoursPerWeek;
  String? _selectedPerDiem;
  final _preferredLocalsController = TextEditingController();
  final _careerGoalsController = TextEditingController();
  final _howHeardAboutUsController = TextEditingController();
  final _lookingToAccomplishController = TextEditingController();
  
  // Step 2 Focus nodes
  final _ticketNumberFocus = FocusNode();
  final _homeLocalFocus = FocusNode();
  final _booksOnFocus = FocusNode();
  
  // Step 3 Focus nodes
  final _preferredLocalsFocus = FocusNode();
  final _careerGoalsFocus = FocusNode();
  final _howHeardAboutUsFocus = FocusNode();
  final _lookingToAccomplishFocus = FocusNode();

  // Data options
  final List<String> _classifications = Classification.all;

  final List<String> _constructionTypes = ConstructionTypes.all;

  final List<String> _usStates = [
    'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
    'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
    'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
    'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
    'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY'
  ];

  final List<String> _hoursPerWeekOptions = [
    '40',
    '40-50',
    '50-60',
    '60-70',
    '>70'
  ];

  final List<String> _perDiemOptions = [
    '100-150',
    '150-200',
    '200+'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipcodeController.dispose();
    _homeLocalController.dispose();
    _ticketNumberController.dispose();
    _booksOnController.dispose();
    _preferredLocalsController.dispose();
    _careerGoalsController.dispose();
    _howHeardAboutUsController.dispose();
    _lookingToAccomplishController.dispose();
    
    // Dispose focus nodes
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _phoneFocus.dispose();
    _address1Focus.dispose();
    _address2Focus.dispose();
    _cityFocus.dispose();
    _zipcodeFocus.dispose();
    _ticketNumberFocus.dispose();
    _homeLocalFocus.dispose();
    _booksOnFocus.dispose();
    _preferredLocalsFocus.dispose();
    _careerGoalsFocus.dispose();
    _howHeardAboutUsFocus.dispose();
    _lookingToAccomplishFocus.dispose();
    
    super.dispose();
  }

  void _nextStep() async {
    if (_isSaving) return;

    try {
      if (_currentStep == 0) {
        // Save Step 1 data before proceeding
        await _saveStep1Data();
      } else if (_currentStep == 1) {
        // Save Step 2 data before proceeding
        await _saveStep2Data();
      }

      if (_currentStep < _totalSteps - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _completeOnboarding();
      }
    } catch (e) {
      // Error already handled in save methods
      debugPrint('Error in _nextStep: $e');
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveStep1Data() async {
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final firestoreService = FirestoreService();
      
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        username: user.email?.split('@')[0] ?? '',
        role: 'electrician',
        lastActive: Timestamp.now(),
        createdTime: DateTime.now(),
        onboardingStatus: OnboardingStatus.incomplete,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address1: _address1Controller.text.trim(),
        address2: _address2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zipcode: int.tryParse(_zipcodeController.text.trim()) ?? 0,
        classification: '',
        homeLocal: 0,
        networkWithOthers: false,
        careerAdvancements: false,
        betterBenefits: false,
        higherPayRate: false,
        learnNewSkill: false,
        travelToNewLocation: false,
        findLongTermWork: false,
      );

      await firestoreService.createUser(
        uid: user.uid,
        userData: userModel.toJson(),
      );

      if (mounted) {
        JJSnackBar.showSuccess(
          context: context,
          message: 'Basic information saved',
        );
      }
    } catch (e) {
      debugPrint('Error saving Step 1 data: $e');
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Error saving data. Please try again.',
        );
      }
      rethrow;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveStep2Data() async {
    setState(() => _isSaving = true);

    // New: Trigger form validation
    if (!_step2FormKey.currentState!.validate()) {
      setState(() => _isSaving = false);
      return; // Return early if validation fails
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final firestoreService = FirestoreService();
      await firestoreService.updateUser(
        uid: user.uid,
        data: {
          'homeLocal': int.parse(_homeLocalController.text.trim()),
          'ticketNumber': _ticketNumberController.text.trim(),
          'classification': _selectedClassification ?? '',
          'isWorking': _isWorking,
          'booksOn': _booksOnController.text.trim().isEmpty ? null : _booksOnController.text.trim(),
        },
      );

      if (mounted) {
        JJSnackBar.showSuccess(
          context: context,
          message: 'Professional details saved',
        );
      }
    } catch (e) {
      debugPrint('Error saving Step 2 data: $e');
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Error saving data. Please try again.',
        );
      }
      rethrow;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _completeOnboarding() async {
    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Prepare Step 3 data for update
      final Map<String, dynamic> step3Data = {
        'constructionTypes': _selectedConstructionTypes.toList(),
        'hoursPerWeek': _selectedHoursPerWeek,
        'perDiemRequirement': _selectedPerDiem,
        'preferredLocals': _preferredLocalsController.text.trim().isEmpty ? null : _preferredLocalsController.text.trim(),
        'networkWithOthers': _networkWithOthers,
        'careerAdvancements': _careerAdvancements,
        'betterBenefits': _betterBenefits,
        'higherPayRate': _higherPayRate,
        'learnNewSkill': _learnNewSkill,
        'travelToNewLocation': _travelToNewLocation,
        'findLongTermWork': _findLongTermWork,
        'careerGoals': _careerGoalsController.text.trim().isEmpty ? null : _careerGoalsController.text.trim(),
        'howHeardAboutUs': _howHeardAboutUsController.text.trim().isEmpty ? null : _howHeardAboutUsController.text.trim(),
        'lookingToAccomplish': _lookingToAccomplishController.text.trim().isEmpty ? null : _lookingToAccomplishController.text.trim(),
        'onboardingStatus': OnboardingStatus.complete.name, // Mark as complete
      };

      // Save to Firestore
      final firestoreService = FirestoreService();
      await firestoreService.updateUser(
        uid: user.uid,
        data: step3Data,
      );

      // Mark onboarding as complete in local storage
      final onboardingService = OnboardingService();
      await onboardingService.markOnboardingComplete();

      if (mounted) {
        JJSnackBar.showSuccess(
          context: context,
          message: 'Profile setup complete! Welcome to Journeyman Jobs.',
        );

        // Navigate to home after successful save
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go(AppRouter.home);
          }
        });
      }
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Error saving profile. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: // Basic Information
        return _firstNameController.text.isNotEmpty &&
               _lastNameController.text.isNotEmpty &&
               _phoneController.text.isNotEmpty &&
               _address1Controller.text.isNotEmpty &&
               _cityController.text.isNotEmpty &&
               _stateController.text.isNotEmpty &&
               _zipcodeController.text.isNotEmpty;
      case 1: // Professional Details
        return _homeLocalController.text.isNotEmpty &&
               _ticketNumberController.text.isNotEmpty &&
               _selectedClassification != null;
      case 2: // Preferences & Feedback
        return _selectedConstructionTypes.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.primaryNavy),
                onPressed: _previousStep,
              )
            : null,
        title: Text(
          'Setup Profile',
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.primaryNavy),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const ModernSvgCircuitBackground(
            opacity: 0.08,
          ),
          Column(
            children: [
              // Progress indicator
              Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              children: [
                JJProgressIndicator(
                  currentStep: _currentStep + 1,
                  totalSteps: _totalSteps,
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          
          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentStep = page;
                });
              },
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),
        ],
      ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          left: AppTheme.spacingMd,
          right: AppTheme.spacingMd,
          top: AppTheme.spacingSm,
          bottom: 0, // Ensure no extra padding at bottom
        ),
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2), // Darker shadcn-like shadow
              blurRadius: 12,
              spreadRadius: -1,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: JJSecondaryButton(
                      text: 'Back',
                      onPressed: _previousStep,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
                
                const SizedBox(width: AppTheme.spacingMd),
                
                Expanded(
                  child: JJPrimaryButton(
                    text: _currentStep == _totalSteps - 1 ? 'Complete' : 'Next',
                    onPressed: (_canProceed() && !_isSaving) ? _nextStep : null,
                    isLoading: _isSaving,
                    icon: _currentStep == _totalSteps - 1
                        ? Icons.check
                        : Icons.arrow_forward,
                    variant: JJButtonVariant.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: _buildStepHeader(
              icon: Icons.person_outline,
              title: 'Basic Information',
              subtitle: 'Let\'s start with your essential details',
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Name fields
          Row(
            children: [
              Expanded(
                child: JJTextField(
                  label: 'First Name',
                  controller: _firstNameController,
                  focusNode: _firstNameFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_lastNameFocus),
                  prefixIcon: Icons.person_outline,
                  hintText: 'Enter first name',
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: JJTextField(
                  label: 'Last Name',
                  controller: _lastNameController,
                  focusNode: _lastNameFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocus),
                  prefixIcon: Icons.person_outline,
                  hintText: 'Enter last name',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Phone number
          JJTextField(
            label: 'Phone Number',
            controller: _phoneController,
            focusNode: _phoneFocus,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_address1Focus),
            prefixIcon: Icons.phone_outlined,
            hintText: 'Enter your phone number',
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Address
          JJTextField(
            label: 'Address Line 1',
            controller: _address1Controller,
            focusNode: _address1Focus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_address2Focus),
            prefixIcon: Icons.home_outlined,
            hintText: 'Enter your street address',
          ),
          
          const SizedBox(height: AppTheme.spacingSm),
          
          JJTextField(
            label: 'Address Line 2 (Optional)',
            controller: _address2Controller,
            focusNode: _address2Focus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_cityFocus),
            prefixIcon: Icons.home_outlined,
            hintText: 'Apartment, suite, etc.',
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // City, State, Zip
          JJTextField(
            label: 'City',
            controller: _cityController,
            focusNode: _cityFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_zipcodeFocus),
            prefixIcon: Icons.location_city_outlined,
            hintText: 'Enter city',
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(
                flex: 7, // 70% of the row for the textfield
                child: JJTextField(
                  label: 'Zip Code',
                  controller: _zipcodeController,
                  focusNode: _zipcodeFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: Icons.mail_outline,
                  hintText: 'Zip',
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                flex: 3, // 30% of the row for the dropdown
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'State',
                      style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.lightGray),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        color: AppTheme.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _stateController.text.isEmpty ? null : _stateController.text,
                          hint: Text(
                            'State',
                            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
                          ),
                          isExpanded: true,
                          items: _usStates.map((state) {
                            return DropdownMenuItem(
                              value: state,
                              child: Text(state, style: AppTheme.bodyMedium),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _stateController.text = value ?? '';
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingXl),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Form( // Wrap with Form
        key: _step2FormKey, // Assign key
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildStepHeader(
              icon: Icons.electrical_services,
              title: 'IBEW Professional Details',
              subtitle: 'Tell us about your electrical career and qualifications',
            ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Ticket Number
          JJTextField(
            label: 'Ticket Number',
            controller: _ticketNumberController,
            focusNode: _ticketNumberFocus,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_homeLocalFocus),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: Icons.badge_outlined,
            hintText: 'Enter your ticket number',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ticket number is required';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Home Local
          JJTextField(
            label: 'Home Local Number',
            controller: _homeLocalController,
            focusNode: _homeLocalFocus,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_booksOnFocus),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: Icons.location_on_outlined,
            hintText: 'Enter your home local number',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Home Local number is required';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Classification selection
          Text(
            'Classification',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Select your current classification',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: _classifications.map((classification) {
              final isSelected = _selectedClassification == classification;
              return JJChip(
                label: classification,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedClassification = classification;
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Currently working status
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.offWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: JJCircuitBreakerSwitchListTile(
              title: Text(
                'Currently Working',
                style: AppTheme.titleMedium,
              ),
              subtitle: Text(
                'Are you currently employed?',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
              ),
              value: _isWorking,
              onChanged: (value) {
                setState(() {
                  _isWorking = value;
                });
              },
              size: JJCircuitBreakerSize.small,
              showElectricalEffects: true,
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Books they're on - CRITICAL FIELD
          JJTextField(
            label: 'Books You\'re Currently On',
            controller: _booksOnController,
            focusNode: _booksOnFocus,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
            prefixIcon: Icons.book_outlined,
            hintText: 'e.g., Book 1, Book 2, Local 456 Book 1',
            maxLines: 2,
          ),
          
          const SizedBox(height: AppTheme.spacingSm),
          
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.accentCopper.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.accentCopper,
                  size: 16,
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Expanded(
                  child: Text(
                    'This helps us manage your monthly resignations and maintain your position',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingXl),
        ],
      ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildStepHeader(
            icon: Icons.tune_outlined,
            title: 'Preferences & Feedback',
            subtitle: 'Help us personalize your experience',
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Construction Types
          Text(
            'Construction Types',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Select all construction types you\'re interested in:',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: _constructionTypes.map((type) {
              final isSelected = _selectedConstructionTypes.contains(type);
              return JJChip(
                label: type,
                isSelected: isSelected,
                icon: _getConstructionTypeIcon(type),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedConstructionTypes.remove(type);
                    } else {
                      _selectedConstructionTypes.add(type);
                    }
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Hours per week
          Text(
            'Hours Per Week',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'How many hours are you willing to work per week?',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lightGray),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              color: AppTheme.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedHoursPerWeek,
                hint: Text(
                  'Select hours per week',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
                ),
                isExpanded: true,
                items: _hoursPerWeekOptions.map((hours) {
                  return DropdownMenuItem(
                    value: hours,
                    child: Text(hours, style: AppTheme.bodyMedium),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedHoursPerWeek = value;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Per diem
          Text(
            'Per Diem Requirements',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'What per diem amount are you looking for?',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lightGray),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              color: AppTheme.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPerDiem,
                hint: Text(
                  'Select per diem preference',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
                ),
                isExpanded: true,
                items: _perDiemOptions.map((perDiem) {
                  return DropdownMenuItem(
                    value: perDiem,
                    child: Text(perDiem, style: AppTheme.bodyMedium),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPerDiem = value;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Preferred locals
          JJTextField(
            label: 'Preferred Locals (Optional)',
            controller: _preferredLocalsController,
            focusNode: _preferredLocalsFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_careerGoalsFocus),
            prefixIcon: Icons.location_on_outlined,
            hintText: 'e.g., Local 26, Local 103, Local 456',
            maxLines: 2,
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Job search goals
          Text(
            'Job Search Goals',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Select all that apply to your job search:',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.offWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  title: Text('Network with Others', style: AppTheme.bodyMedium),
                  subtitle: Text('Connect with other electricians', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _networkWithOthers,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _networkWithOthers = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: Text('Career Advancement', style: AppTheme.bodyMedium),
                  subtitle: Text('Seek leadership roles', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _careerAdvancements,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _careerAdvancements = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: Text('Better Benefits', style: AppTheme.bodyMedium),
                  subtitle: Text('Improved benefit packages', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _betterBenefits,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _betterBenefits = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: Text('Higher Pay Rate', style: AppTheme.bodyMedium),
                  subtitle: Text('Increase compensation', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _higherPayRate,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _higherPayRate = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: Text('Learn New Skills', style: AppTheme.bodyMedium),
                  subtitle: Text('Gain new experience', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _learnNewSkill,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _learnNewSkill = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: Text('Travel to New Locations', style: AppTheme.bodyMedium),
                  subtitle: Text('Work in different areas', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _travelToNewLocation,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _travelToNewLocation = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: Text('Find Long-term Work', style: AppTheme.bodyMedium),
                  subtitle: Text('Secure stable employment', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _findLongTermWork,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _findLongTermWork = value ?? false),
                  dense: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Career goals
          JJTextField(
            label: 'Career Goals (Optional)',
            controller: _careerGoalsController,
            focusNode: _careerGoalsFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_howHeardAboutUsFocus),
            maxLines: 3,
            prefixIcon: Icons.flag_outlined,
            hintText: 'Describe your career goals and where you see yourself in the future...',
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // How did you hear about us
          JJTextField(
            label: 'How did you hear about us?',
            controller: _howHeardAboutUsController,
            focusNode: _howHeardAboutUsFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_lookingToAccomplishFocus),
            maxLines: 2,
            prefixIcon: Icons.info_outline,
            hintText: 'Tell us how you discovered Journeyman Jobs...',
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // What are you looking to accomplish
          JJTextField(
            label: 'What are you looking to accomplish?',
            controller: _lookingToAccomplishController,
            focusNode: _lookingToAccomplishFocus,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
            maxLines: 3,
            prefixIcon: Icons.track_changes_outlined,
            hintText: 'What do you hope to achieve through our platform?',
          ),
          
          const SizedBox(height: AppTheme.spacingXl),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildStepHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppTheme.buttonGradient,
            shape: BoxShape.circle,
            boxShadow: [AppTheme.shadowMd],
          ),
          child: Icon(
            icon,
            size: 28,
            color: AppTheme.white,
          ),
        ),
        
        const SizedBox(height: AppTheme.spacingSm),
        
        Text(
          title,
          style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryNavy),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: AppTheme.spacingXs),
        
        Text(
          subtitle,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  IconData _getConstructionTypeIcon(String type) {
    switch (type) {
      case 'Distribution':
        return Icons.power_outlined;
      case 'Transmission':
        return Icons.electrical_services;
      case 'SubStation':
        return Icons.transform_outlined;
      case 'Residential':
        return Icons.home_outlined;
      case 'Industrial':
        return Icons.factory_outlined;
      case 'Data Center':
        return Icons.storage_outlined;
      case 'Commercial':
        return Icons.business_outlined;
      case 'Underground':
        return Icons.layers_outlined;
      default:
        return Icons.construction_outlined;
    }
  }

}

---

## ELI'S VERSION

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/domain/enums/enums.dart';
import 'package:journeyman_jobs/domain/enums/onboarding_status.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';
import '../../models/user_model.dart';
import '../../navigation/app_router.dart';
import '../../services/onboarding_service.dart';
import '../../services/firestore_service.dart';
import '../../electrical_components/jj_circuit_breaker_switch_list_tile.dart';
import '../../electrical_components/jj_circuit_breaker_switch.dart';
import '../../electrical_components/modern_svg_circuit_background.dart';

class OnboardingStepsScreen extends StatefulWidget {
  const OnboardingStepsScreen({super.key});

  @override
  State<OnboardingStepsScreen> createState() => _OnboardingStepsScreenState();
}

class _OnboardingStepsScreenState extends State<OnboardingStepsScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Step 1: Personal Information
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipcodeController = TextEditingController();
  
  // Focus nodes for keyboard navigation
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _address1Focus = FocusNode();
  final _address2Focus = FocusNode();
  final _cityFocus = FocusNode();
  final _zipcodeFocus = FocusNode();

  // Step 2: Professional Details
  final _step2FormKey = GlobalKey<FormState>(); // New: Form key for Step 2
  final _homeLocalController = TextEditingController();
  final _ticketNumberController = TextEditingController();
  String? _selectedClassification;
  bool _isWorking = false;

  // Step 3: Job Preferences & Goals
  bool _networkWithOthers = false;
  bool _careerAdvancements = false;
  bool _betterBenefits = false;
  bool _higherPayRate = false;
  bool _learnNewSkill = false;
  bool _travelToNewLocation = false;
  bool _findLongTermWork = false;

  // Step 2: Additional Professional Details
  final _booksOnController = TextEditingController();

  // Loading state for save operations
  bool _isSaving = false;

  // Step 3: Preferences and Feedback
  final Set<String> _selectedConstructionTypes = <String>{};
  String? _selectedHoursPerWeek;
  String? _selectedPerDiem;
  final _preferredLocalsController = TextEditingController();
  final _careerGoalsController = TextEditingController();
  final _howHeardAboutUsController = TextEditingController();
  final _lookingToAccomplishController = TextEditingController();
  
  // Step 2 Focus nodes
  final _ticketNumberFocus = FocusNode();
  final _homeLocalFocus = FocusNode();
  final _booksOnFocus = FocusNode();
  
  // Step 3 Focus nodes
  final _preferredLocalsFocus = FocusNode();
  final _careerGoalsFocus = FocusNode();
  final _howHeardAboutUsFocus = FocusNode();
  final _lookingToAccomplishFocus = FocusNode();

  // Data options
  final List<String> _classifications = Classification.all;

  final List<String> _constructionTypes = ConstructionTypes.all;

  final List<String> _usStates = [
    'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
    'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
    'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
    'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
    'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY'
  ];

  final List<String> _hoursPerWeekOptions = [
    '40',
    '40-50',
    '50-60',
    '60-70',
    '>70'
  ];

  final List<String> _perDiemOptions = [
    '100-150',
    '150-200',
    '200+'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipcodeController.dispose();
    _homeLocalController.dispose();
    _ticketNumberController.dispose();
    _booksOnController.dispose();
    _preferredLocalsController.dispose();
    _careerGoalsController.dispose();
    _howHeardAboutUsController.dispose();
    _lookingToAccomplishController.dispose();
    
    // Dispose focus nodes
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _phoneFocus.dispose();
    _address1Focus.dispose();
    _address2Focus.dispose();
    _cityFocus.dispose();
    _zipcodeFocus.dispose();
    _ticketNumberFocus.dispose();
    _homeLocalFocus.dispose();
    _booksOnFocus.dispose();
    _preferredLocalsFocus.dispose();
    _careerGoalsFocus.dispose();
    _howHeardAboutUsFocus.dispose();
    _lookingToAccomplishFocus.dispose();
    
    super.dispose();
  }

  void _nextStep() async {
    if (_isSaving) return;

    try {
      if (_currentStep == 0) {
        // Save Step 1 data before proceeding
        await _saveStep1Data();
      } else if (_currentStep == 1) {
        // Save Step 2 data before proceeding
        await _saveStep2Data();
      }

      if (_currentStep < _totalSteps - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _completeOnboarding();
      }
    } catch (e) {
      // Error already handled in save methods
      debugPrint('Error in _nextStep: $e');
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveStep1Data() async {
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final firestoreService = FirestoreService();
      
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        username: user.email?.split('@')[0] ?? '',
        role: 'electrician',
        lastActive: Timestamp.now(),
        createdTime: DateTime.now(),
        onboardingStatus: OnboardingStatus.incomplete,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address1: _address1Controller.text.trim(),
        address2: _address2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zipcode: int.tryParse(_zipcodeController.text.trim()) ?? 0,
        classification: '',
        homeLocal: 0,
        networkWithOthers: false,
        careerAdvancements: false,
        betterBenefits: false,
        higherPayRate: false,
        learnNewSkill: false,
        travelToNewLocation: false,
        findLongTermWork: false,
      );

      await firestoreService.createUser(
        uid: user.uid,
        userData: userModel.toJson(),
      );

      if (mounted) {
        JJSnackBar.showSuccess(
          context: context,
          message: 'Basic information saved',
        );
      }
    } catch (e) {
      debugPrint('Error saving Step 1 data: $e');
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Error saving data. Please try again.',
        );
      }
      rethrow;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveStep2Data() async {
    setState(() => _isSaving = true);

    // New: Trigger form validation
    if (!_step2FormKey.currentState!.validate()) {
      setState(() => _isSaving = false);
      return; // Return early if validation fails
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final firestoreService = FirestoreService();
      await firestoreService.updateUser(
        uid: user.uid,
        data: {
          'homeLocal': int.parse(_homeLocalController.text.trim()),
          'ticketNumber': _ticketNumberController.text.trim(),
          'classification': _selectedClassification ?? '',
          'isWorking': _isWorking,
          'booksOn': _booksOnController.text.trim().isEmpty ? null : _booksOnController.text.trim(),
        },
      );

      if (mounted) {
        JJSnackBar.showSuccess(
          context: context,
          message: 'Professional details saved',
        );
      }
    } catch (e) {
      debugPrint('Error saving Step 2 data: $e');
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Error saving data. Please try again.',
        );
      }
      rethrow;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _completeOnboarding() async {
    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Prepare Step 3 data for update
      final Map<String, dynamic> step3Data = {
        'constructionTypes': _selectedConstructionTypes.toList(),
        'hoursPerWeek': _selectedHoursPerWeek,
        'perDiemRequirement': _selectedPerDiem,
        'preferredLocals': _preferredLocalsController.text.trim().isEmpty ? null : _preferredLocalsController.text.trim(),
        'networkWithOthers': _networkWithOthers,
        'careerAdvancements': _careerAdvancements,
        'betterBenefits': _betterBenefits,
        'higherPayRate': _higherPayRate,
        'learnNewSkill': _learnNewSkill,
        'travelToNewLocation': _travelToNewLocation,
        'findLongTermWork': _findLongTermWork,
        'careerGoals': _careerGoalsController.text.trim().isEmpty ? null : _careerGoalsController.text.trim(),
        'howHeardAboutUs': _howHeardAboutUsController.text.trim().isEmpty ? null : _howHeardAboutUsController.text.trim(),
        'lookingToAccomplish': _lookingToAccomplishController.text.trim().isEmpty ? null : _lookingToAccomplishController.text.trim(),
        'onboardingStatus': OnboardingStatus.complete.name, // Mark as complete
      };

      // Save to Firestore
      final firestoreService = FirestoreService();
      await firestoreService.updateUser(
        uid: user.uid,
        data: step3Data,
      );

      // Mark onboarding as complete in local storage
      final onboardingService = OnboardingService();
      await onboardingService.markOnboardingComplete();

      if (mounted) {
        JJSnackBar.showSuccess(
          context: context,
          message: 'Profile setup complete! Welcome to Journeyman Jobs.',
        );

        // Navigate to home after successful save
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go(AppRouter.home);
          }
        });
      }
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      if (mounted) {
        JJSnackBar.showError(
          context: context,
          message: 'Error saving profile. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: // Basic Information
        return _firstNameController.text.isNotEmpty &&
               _lastNameController.text.isNotEmpty &&
               _phoneController.text.isNotEmpty &&
               _address1Controller.text.isNotEmpty &&
               _cityController.text.isNotEmpty &&
               _stateController.text.isNotEmpty &&
               _zipcodeController.text.isNotEmpty;
      case 1: // Professional Details
        return _homeLocalController.text.isNotEmpty &&
               _ticketNumberController.text.isNotEmpty &&
               _selectedClassification != null;
      case 2: // Preferences & Feedback
        return _selectedConstructionTypes.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.primaryNavy),
                onPressed: _previousStep,
              )
            : null,
        title: Text(
          'Setup Profile',
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.primaryNavy),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const ModernSvgCircuitBackground(
            opacity: 0.08,
          ),
          Column(
            children: [
              // Progress indicator
              Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              children: [
                JJProgressIndicator(
                  currentStep: _currentStep + 1,
                  totalSteps: _totalSteps,
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          
          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentStep = page;
                });
              },
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),
        ],
      ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          left: AppTheme.spacingMd,
          right: AppTheme.spacingMd,
          top: AppTheme.spacingSm,
          bottom: 0, // Ensure no extra padding at bottom
        ),
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2), // Darker shadcn-like shadow
              blurRadius: 12,
              spreadRadius: -1,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: JJSecondaryButton(
                      text: 'Back',
                      onPressed: _previousStep,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
                
                const SizedBox(width: AppTheme.spacingMd),
                
                Expanded(
                  child: JJPrimaryButton(
                    text: _currentStep == _totalSteps - 1 ? 'Complete' : 'Next',
                    onPressed: (_canProceed() && !_isSaving) ? _nextStep : null,
                    isLoading: _isSaving,
                    icon: _currentStep == _totalSteps - 1
                        ? Icons.check
                        : Icons.arrow_forward,
                    variant: JJButtonVariant.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: _buildStepHeader(
              icon: Icons.person_outline,
              title: 'Basic Information',
              subtitle: 'Let\'s start with how much you want to be like ELI SMITH',
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Name fields
          Row(
            children: [
              Expanded(
                child: JJTextField(
                  label: 'First Name',
                  controller: _firstNameController,
                  focusNode: _firstNameFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_lastNameFocus),
                  prefixIcon: Icons.person_outline,
                  hintText: 'Enter first name',
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: JJTextField(
                  label: 'Last Name',
                  controller: _lastNameController,
                  focusNode: _lastNameFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocus),
                  prefixIcon: Icons.person_outline,
                  hintText: 'Enter last name',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Phone number
          JJTextField(
            label: 'Phone Number',
            controller: _phoneController,
            focusNode: _phoneFocus,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_address1Focus),
            prefixIcon: Icons.phone_outlined,
            hintText: 'Enter your phone number',
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Address
          JJTextField(
            label: 'Address Line 1',
            controller: _address1Controller,
            focusNode: _address1Focus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_address2Focus),
            prefixIcon: Icons.home_outlined,
            hintText: 'Enter your street address',
          ),
          
          const SizedBox(height: AppTheme.spacingSm),
          
          JJTextField(
            label: 'Address Line 2 (Optional)',
            controller: _address2Controller,
            focusNode: _address2Focus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_cityFocus),
            prefixIcon: Icons.home_outlined,
            hintText: 'Apartment, suite, etc.',
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // City, State, Zip
          JJTextField(
            label: 'City',
            controller: _cityController,
            focusNode: _cityFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_zipcodeFocus),
            prefixIcon: Icons.location_city_outlined,
            hintText: 'Enter city',
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(
                flex: 7, // 70% of the row for the textfield
                child: JJTextField(
                  label: 'Zip Code',
                  controller: _zipcodeController,
                  focusNode: _zipcodeFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: Icons.mail_outline,
                  hintText: 'Zip',
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                flex: 3, // 30% of the row for the dropdown
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'State',
                      style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.lightGray),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        color: AppTheme.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _stateController.text.isEmpty ? null : _stateController.text,
                          hint: Text(
                            'State',
                            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
                          ),
                          isExpanded: true,
                          items: _usStates.map((state) {
                            return DropdownMenuItem(
                              value: state,
                              child: Text(state, style: AppTheme.bodyMedium),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _stateController.text = value ?? '';
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingXl),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Form( // Wrap with Form
        key: _step2FormKey, // Assign key
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildStepHeader(
              icon: Icons.electrical_services,
              title: 'IBEW Professional Details',
              subtitle: 'Tell us about how you wish you were ELI SMITH',
            ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Ticket Number
          JJTextField(
            label: 'Ticket Number',
            controller: _ticketNumberController,
            focusNode: _ticketNumberFocus,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_homeLocalFocus),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: Icons.badge_outlined,
            hintText: '#1 has already been taken by ELI SMITH',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ticket number is required';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Home Local
          JJTextField(
            label: 'Home Local Number',
            controller: _homeLocalController,
            focusNode: _homeLocalFocus,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_booksOnFocus),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: Icons.location_on_outlined,
            hintText: '#1 has already been taken by ELI SMITH',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Home Local number is required';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Classification selection
          Text(
            'Classification',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'The classification of ELI SMITH has already been taken. You will never achieve his greatness',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: _classifications.map((classification) {
              final isSelected = _selectedClassification == classification;
              return JJChip(
                label: classification,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedClassification = classification;
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Currently working status
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.offWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: JJCircuitBreakerSwitchListTile(
              title: Text(
                'Currently Working.. on become more like ELI SMITH?',
                style: AppTheme.titleMedium,
              ),
              subtitle: Text(
                'Are you currently employed? By ELI SMITH?',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
              ),
              value: _isWorking,
              onChanged: (value) {
                setState(() {
                  _isWorking = value;
                });
              },
              size: JJCircuitBreakerSize.small,
              showElectricalEffects: true,
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Books they're on - CRITICAL FIELD
          JJTextField(
            label: 'Books You\'re Currently On',
            controller: _booksOnController,
            focusNode: _booksOnFocus,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
            prefixIcon: Icons.book_outlined,
            hintText: 'e.g., Book of ELI',
            maxLines: 2,
          ),
          
          const SizedBox(height: AppTheme.spacingSm),
          
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.accentCopper.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.accentCopper,
                  size: 16,
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Expanded(
                  child: Text(
                    'This helps us help you in becoming more like ELI SMITH',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingXl),
        ],
      ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildStepHeader(
            icon: Icons.tune_outlined,
            title: 'Preferences & Feedback',
            subtitle: 'Help us personalize your experience. Plan created by ELI SMITH',
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Construction Types
          Text(
            'Construction Types',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Select all construction types you\'re interested in:',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Wrap(
            spacing: AppTheme.spacingSm,
            runSpacing: AppTheme.spacingSm,
            children: _constructionTypes.map((type) {
              final isSelected = _selectedConstructionTypes.contains(type);
              return JJChip(
                label: type,
                isSelected: isSelected,
                icon: _getConstructionTypeIcon(type),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedConstructionTypes.remove(type);
                    } else {
                      _selectedConstructionTypes.add(type);
                    }
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Hours per week
          Text(
            'Hours Per Week',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'How many hours are you willing to work with ELI SMITH?',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lightGray),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              color: AppTheme.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedHoursPerWeek,
                hint: Text(
                  'Select hours per week',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
                ),
                isExpanded: true,
                items: _hoursPerWeekOptions.map((hours) {
                  return DropdownMenuItem(
                    value: hours,
                    child: Text(hours, style: AppTheme.bodyMedium),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedHoursPerWeek = value;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Per diem
          Text(
            'Per Diem Requirements',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'What per diem amount will it take to work with ELI SMITH?',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lightGray),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              color: AppTheme.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPerDiem,
                hint: Text(
                  'Select per diem preference',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
                ),
                isExpanded: true,
                items: _perDiemOptions.map((perDiem) {
                  return DropdownMenuItem(
                    value: perDiem,
                    child: Text(perDiem, style: AppTheme.bodyMedium),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPerDiem = value;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Preferred locals
          JJTextField(
            label: 'Preferred Locals (Optional)',
            controller: _preferredLocalsController,
            focusNode: _preferredLocalsFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_careerGoalsFocus),
            prefixIcon: Icons.location_on_outlined,
            hintText: 'If you were as good as ELI SMITH, the locals would prefer you!',
            maxLines: 2,
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Job search goals
          Text(
            'Job Search Goals',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Select all that apply to your job search:',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.offWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  title: Text('Network with ELI SMITH', style: AppTheme.bodyMedium),
                  subtitle: Text('Connect with other electricians', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _networkWithOthers,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _networkWithOthers = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: Text('Career Advancement with ELI SMITH', style: AppTheme.bodyMedium),
                  subtitle: Text('Seek leadership roles', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _careerAdvancements,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _careerAdvancements = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: Text('Better Benefits for ELI SMITH', style: AppTheme.bodyMedium),
                  subtitle: Text('Improved benefit packages', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _betterBenefits,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _betterBenefits = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: Text('Higher Pay Rate to give to ELI SMITH', style: AppTheme.bodyMedium),
                  subtitle: Text('Increase compensation', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _higherPayRate,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _higherPayRate = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: Text('Learn New Skills from ELI SMITH', style: AppTheme.bodyMedium),
                  subtitle: Text('Gain new experience', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _learnNewSkill,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _learnNewSkill = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: Text('Travel to New Locations to get away from ELI SMITH', style: AppTheme.bodyMedium),
                  subtitle: Text('Work in different areas', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _travelToNewLocation,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _travelToNewLocation = value ?? false),
                  dense: true,
                ),
                CheckboxListTile(
                  title: Text('Find Long-term Work as far away from ELI SMITH as possible', style: AppTheme.bodyMedium),
                  subtitle: Text('Secure stable employment', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  value: _findLongTermWork,
                  activeColor: AppTheme.accentCopper,
                  onChanged: (value) => setState(() => _findLongTermWork = value ?? false),
                  dense: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Career goals
          JJTextField(
            label: 'Career Goals (Optional)',
            controller: _careerGoalsController,
            focusNode: _careerGoalsFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_howHeardAboutUsFocus),
            maxLines: 3,
            prefixIcon: Icons.flag_outlined,
            hintText: 'BE MORE LIKE ELI SMITH!',
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // How did you hear about us
          JJTextField(
            label: 'How did you hear about us?',
            controller: _howHeardAboutUsController,
            focusNode: _howHeardAboutUsFocus,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_lookingToAccomplishFocus),
            maxLines: 2,
            prefixIcon: Icons.info_outline,
            hintText: 'Tell us how you discovered ABOUT JOURNYMAN JOBS FROM ELI SMITH',
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // What are you looking to accomplish
          JJTextField(
            label: 'What are you looking to accomplish?',
            controller: _lookingToAccomplishController,
            focusNode: _lookingToAccomplishFocus,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
            maxLines: 3,
            prefixIcon: Icons.track_changes_outlined,
            hintText: 'TO BE MORE LIKE ELI SMITH',
          ),
          
          const SizedBox(height: AppTheme.spacingXl),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildStepHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppTheme.buttonGradient,
            shape: BoxShape.circle,
            boxShadow: [AppTheme.shadowMd],
          ),
          child: Icon(
            icon,
            size: 28,
            color: AppTheme.white,
          ),
        ),
        
        const SizedBox(height: AppTheme.spacingSm),
        
        Text(
          title,
          style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryNavy),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: AppTheme.spacingXs),
        
        Text(
          subtitle,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  IconData _getConstructionTypeIcon(String type) {
    switch (type) {
      case 'Distribution':
        return Icons.power_outlined;
      case 'Transmission':
        return Icons.electrical_services;
      case 'SubStation':
        return Icons.transform_outlined;
      case 'Residential':
        return Icons.home_outlined;
      case 'Industrial':
        return Icons.factory_outlined;
      case 'Data Center':
        return Icons.storage_outlined;
      case 'Commercial':
        return Icons.business_outlined;
      case 'Underground':
        return Icons.layers_outlined;
      default:
        return Icons.construction_outlined;
    }
  }

}
````

## File: TODO-TASKS.md
````markdown
# TODO_TASKS.md - Journeyman Jobs Implementation Guide

Generated on: December 1, 2025

## MANDATORY VERIFICATION PROTOCOL — THIS IS LAW

> **NO SECTION IS EVER CONSIDERED FINISHED UNTIL THIS PROCESS IS FOLLOWED. NO EXCEPTIONS.**

As soon as you (or any developer/agent) finish **any section or group of tasks** in this file, you **MUST** run the following agent validation gauntlet **in this exact order** — **before** marking anything complete, before checking any box as [✓], and before moving on:

1. **@task-completion-validator** → Does it actually work end-to-end? No stubs, no TODOs, no silent failures.
2. **@Jenny** → Does the implementation **exactly** match the PRD and current specifications? Line-by-line audit.
3. **@code-quality-pragmatist** → Is there any over-engineering, unnecessary abstraction, or complexity for complexity’s sake?
4. **@claude-md-compliance-checker** → Are there **any** violations of project rules or CLAUDE.md constraints?
5. **@ui-comprehensive-tester** → (UI sections only) Full cross-platform, gesture, orientation, and edge-case testing.
6. **@karen** → Final no-bullshit reality check: “Does this actually work in the real world, or are we lying to ourselves?”

**Only when ALL relevant agents above return PASS** are you allowed to:

- Change section status to **[Completed]**
- Turn any checkbox from [ ] → [✓]
- Move on to the next section

If **any single agent fails**, the section stays **[In Progress]** (or reverts to **[Not Started]** if critical).  
Fix it. Rerun the gauntlet. Repeat until green.

This is not optional. This is not “later.”  
This is the new religion.

---

## INTRODUCTION

This comprehensive implementation guide breaks down all requirements from TODO.md into actionable, manageable tasks. Each task represents a specific, implementable unit of work that can be completed in 1-4 hours by a developer.

### STRUCTURE

- **Grouped by Screens/Pages**: Tasks are organized following the same structure as TODO.md
- **Status Indicators**: Each section has a progress status to track overall completion
- **Task Breakdown**: requirements broken into 5-15 specific, testable tasks per section
- **Domain Labels**: Each task labeled by technical domain for proper assignment
- **Checkboxes**: Mark completion with [ ] → [✓] **ONLY AFTER FULL AGENT GAUNTLET PASSES**

### STATUS LEGEND

- **[Not Started]** - No work begun
- **[In Progress]** - Development underway
- **[Completed]** - All tasks finished, tested, and **passed full agent validation gauntlet**
- **[Final Testing]** - Awaiting integration testing
- **[Blocked]** - Waiting on dependencies

### DOMAIN LABELS

- **[UI-UX]** - User interface and experience design
- **[Backend]** - Server-side logic and APIs
- **[AI-ML]** - Artificial intelligence and machine learning
- **[Security]** - Authentication, authorization, data protection
- **[Database]** - Data storage and management
- **[Integration]** - External API and service integrations
- **[Platform]** - App-wide infrastructure and setup
- **[QA/QC]** - Quality assurance and testing
- **[Performance]** - Optimization and scalability
- **[Accessibility]** - WCAG and disability compliance

---

## APP WIDE CHANGES

Status: [In Progress]

### Custom Model Integration Tasks

- [x] [AI-ML] Define data model interfaces for job summaries, user feedback, and suggestions structures
- [x] [AI-ML] Create pub.dev/package library structure for custom local AI model integration
- [x] [AI-ML] Implement local model initialization and configuration system
- [x] [Backend] Add job feedback logging system to capture user experiences and opinions
- [x] [AI-ML] Build job summarization algorithm that analyzes job data for key highlights
- [x] [AI-ML] Create user experience matching logic to correlate feedback with user preferences
- [x] [UI-UX] Design UI components for displaying personalized job suggestions
- [x] [Backend] Implement real-time feedback collection during job browsing
- [x] [AI-ML] Develop job recommendation engine using preference matching
- [x] [Backend] Add Firebase query optimization for real-time job filtering by suggestions
- [x] [Security] Implement user data privacy controls for feedback sharing
- [x] [Backend] Create admin interface for model training data management
- [x] [AI-ML] Add model accuracy metrics and improvement tracking
- [x] [UI-UX] Integrate suggestion previews in job card hover states
- [x] [QA/QC] Test suggestion accuracy with user feedback validation

### Custom Model Pro Actions

- [x] [AI-ML] Implement subscription-based feature gating for AI interactions
- [x] [Backend] Create settings update API for preferences and notifications
- [x] [AI-ML] Add real-time job query and notification system for matches
- [x] [Security] Implement premium subscription verification before actions
- [x] [Backend] Build Firebase query automation for user's current preferences
- [x] [UI-UX] Create notification dialog system for AI job recommendations
- [x] [Backend] Add direct message composition from AI suggestions to user chats
- [x] [Security] Implement rate limiting for AI action triggering
- [x] [QA/QC] Create user flow testing for AI action automation
- [ ] [Platform] Add billing integration for subscription verification

---

## ONBOARDING SCREENS

Status: [Not Started]

### Background Implementation

- [ ] [UI-UX] Identify all onboarding screen files and current background usage
- [ ] [UI-UX] Create electrical circuit background component in design_system
- [ ] [UI-UX] Test circuit background compatibility with auth, step screens
- [ ] [UI-UX] Update ElectricalCircuitBackground component for onboarding variations
- [ ] [UI-UX] Ensure text readability over circuit background across all devices

### AUTH SCREEN Changes

- [ ] [UI-UX] Locate current tab bar implementation in auth screen
- [ ] [UI-UX] Enhance tab bar UI to match modern design specifications
- [ ] [UI-UX] Add copper border reinforcement to all text fields
- [ ] [UI-UX] Test enhanced tab bar functionality with existing sigDl functionality
- [ ] [UI-UX] Apply electrical theme consistency throughout auth screen
- [ ] [QA/QC] Cross-platform testing for enhanced auth screen appearance

### ONBOARDING STEPS SCREEN - STEP 1

- [x] [UI-UX] Locate onboarding steps screen file structure
- [x] [UI-UX] Adjust buildStepHeader positioning for centered alignment
- [x] [UI-UX] Add copper border styling to all text fields in step 1
- [ ] [UI-UX] Reduce state dropdown width by half for better layout
- [ ] [UI-UX] Expand zip code field to fill remaining space
- [x] [Backend] Create user document creation logic on Next button press
- [x] [Database] Implement Cloud Firestore user document schema
- [x] [Integration] Add Firebase authentication user ID to new document
- [x] [UI-UX] Add confirmation feedback when user document is created
- [x] [QA/QC] Test user document creation workflow from onboarding

### ONBOARDING STEPS SCREEN - STEP 2

- [ ] [UI-UX] Verify Next button functionality from step 2 screens
- [ ] [UI-UX] Add copper border styling to all step 2 text fields
- [x] [Backend] Implement field data saving to existing user document on step 2 completion
- [x] [UI-UX] Validate all form fields have proper validation feedback
- [x] [Backend] Add document update logic for step 2 navigation
- [x] [UI-UX] Ensure seamless transition between step 1 and step 2
- [x] [QA/QC] Validate step 2 field persistence and navigation flow

### ONBOARDING STEPS SCREEN - STEP 3

- [x] [UI-UX] Verify Next button functionality from step 3 screens
- [x] [UI-UX] Add copper border styling to all step 3 text fields
- [x] [Backend] Implement final field data saving to user document on step 3 completion
- [x] [Backend] Add navigation logic from step 3 to home screen
- [x] [UI-UX] Create completion animation or success state
- [x] [Backend] Validate all user document fields are properly saved
- [x] [Platform] Ensure user authentication state is properly updated

### General Onboarding Theme

- [x] [UI-UX] Ensure theme consistency (light/dark mode) across all onboarding screens to prevent mode switching after authentication.

### AUTH SCREEN Enhancements

- [x] [UI-UX] Replace the existing `tab bar` on the Auth Screen with the enhanced version specified in `guide/tab-bar-enhancement.md`.
- [x] [UI-UX] Ensure all original tab bar functionality is maintained after the UI upgrade.
- [x] [UI-UX] Fix the layout issue causing a gap between the sign-up/sign-in tabs and the surrounding border.

### ONBOARDING STEPS SCREEN - STEP 1 Enhancements

- [x] [UI-UX] Shorten the `state` dropdown field to half its current width.
- [x] [UI-UX] Expand the `zip code` text field to occupy the remaining horizontal space next to the state dropdown.

---

## HOME SCREEN

Status: [Not Started]

### Personalization Updates

- [x] [Backend] Create user profile data retrieval for personalized greeting
- [x] [UI-UX] Update home screen welcome text to use "Welcome Back! {firstName lastName}"
- [x] [Backend] Add Firebase user document query for name field retrieval
- [x] [UI-UX] Handle missing name scenarios with fallback greeting
- [x] [QA/QC] Test name display across different user profile states

### Active Crews Subsection Removal

- [x] [UI-UX] Remove Active Crews section from home screen
- [x] [UI-UX] Adjust home screen layout to fill empty space
- [x] [UI-UX] Update responsive design without active crews section

### Realtime Summary Feed Implementation

- [x] [UI-UX] Design realtime summary feed component replacing active crews
- [ ] [Backend] Create Firebase listener for user's recent posts, messages, jobs
- [ ] [UI-UX] Implement scrolling horizontal/vertical feed layout
- [ ] [Backend] Build basic query logic for posts, messages, jobs aggregation
- [ ] [UI-UX] Add resource icons for post/message/job types
- [ ] [Backend] Implement caching mechanism for performance optimization
- [ ] [UI-UX] Add gesture-based navigation to detailed post/message/job views
- [ ] [QA/QC] Test feed loading performance with large datasets

### Quick Actions Enhancement

- [ ] [UI-UX] Add electrical calculator link to Quick Actions section
- [ ] [UI-UX] Add view crews link to Quick Actions section
- [ ] [UI-UX] Restructure Quick Actions layout for additional items
- [ ] [UI-UX] Ensure calculator and crews links navigate to correct screens
- [ ] [Platform] Validate deep linking functionality to calculator and tailboard
- [ ] [UI-UX] Optimize Quick Actions for mobile dashboard usability

### Suggested Jobs Enhancement

- [ ] [UI-UX] Identify current suggested jobs card structure
- [ ] [UI-UX] Condense job card display to essential data (Per Diem, Hours, Rate, Conditions)
- [ ] [Backend] Enhance job preference filtering logic in backend
- [ ] [UI-UX] Create popup dialog component for detailed job display
- [ ] [UI-UX] Implement tap gesture to trigger detailed job popup
- [ ] [UI-UX] Add smooth popup animation for job detail display
- [ ] [Backend] Optimize job data retrieval for popup display performance
- [ ] [QA/QC] Test suggested jobs filtering accuracy against user preferences

---

## JOB SCREEN

Status: [Not Started]

### Enhanced Job Card Theme

- [ ] [UI-UX] Identify current job card theming and color scheme
- [ ] [UI-UX] Redesign job card theme with money, payroll, overtime visual motifs
- [ ] [UI-UX] Add customized job card component with enhanced styling
- [ ] [UI-UX] Integrate money-themed icons and animations to job cards
- [ ] [UI-UX] Ensure new theme maintains readability and information hierarchy
- [ ] [Platform] Test job card display across different device sizes

### Navigation Badge Fix

- [ ] [UI-UX] Locate current notification badge implementation on app bar
- [ ] [UI-UX] Verify notification badge current navigation destination
- [ ] [UI-UX] Redirect notification badge navigation to notification settings screen
- [ ] [Platform] Test notification badge navigation flow correctly functions
- [ ] [UI-UX] Ensure smooth transition to notification settings screen

### Sort/Filter Enhancement

- [ ] [UI-UX] Locate sort/filter horizontal scroll view underneath app bar
- [ ] [UI-UX] Verify "choice chips" implementation and styling
- [ ] [UI-UX] Identify "journeyman lineman" choice chip and error condition
- [ ] [UI-UX] Fix error handling for journeyman lineman filter selection
- [ ] [Backend] Create backend filtering logic for journeyman lineman jobs
- [ ] [UI-UX] Test all choice chip selections for proper filtering behavior
- [ ] [QA/QC] Validate filter accuracy against job classification data

### Job Dialog Expansion

- [ ] [UI-UX] Identify current job dialog popup implementation
- [ ] [UI-UX] Assess job dialog current information display capacity
- [ ] [UI-UX] Enhance job dialog to display full job posting data
- [ ] [UI-UX] Improve job dialog layout for better information organization
- [ ] [UI-UX] Add scrolling capability for lengthy job descriptions
- [ ] [Backend] Optimize job data retrieval for detailed display
- [ ] [Accessibility] Validate job dialog adheres to accessibility guidelines
- [ ] [QA/QC] Test job dialog display across various job data sizes

---

## STORM SCREEN

Status: [In Progress]

### Energetic Vibe Redesign

- [x] [UI-UX] Analyze current storm screen design and identify key components
- [x] [UI-UX] Create custom energetic visual theme for storm screen
- [x] [UI-UX] Redesign icon set specifically for storm work environment
- [x] [UI-UX] Customize color palette emphasizing storm work energy
- [x] [UI-UX] Add thunderstorm-inspired visual motifs and gradients
- [x] [UI-UX] Implement dynamic background elements for storm atmosphere
- [x] [UI-UX] Add lightning bolt animations and electrical spark effects
- [x] [UI-UX] Enhance typography with storm work theme
- [x] [UI-UX] Create custom storm-themed badge/icon system

### Sound Integration Planning

- [ ] [Integration] Research React Native or Flutter sound integration libraries
- [ ] [Platform] Evaluate platform requirements for sound implementation
- [ ] [UI-UX] Design user preference settings for sound notifications
- [ ] [Backend] Create sound file management system for storm alerts
- [ ] [Security] Implement user consent system for sound playback
- [ ] [QA/QC] Test sound functionality across iOS and Android platforms

### Interactive Elements Enhancement

- [ ] [UI-UX] Add gesture-based interactions to storm event cards (swipe, long press)
- [ ] [UI-UX] Implement micro-animations for event card reveals
- [x] [UI-UX] Add weather radar integration with interactive controls
- [ ] [UI-UX] Create animated weather icons that respond to storm conditions
- [ ] [UI-UX] Add haptic feedback for important storm notifications
- [ ] [UI-UX] Implement pull-to-refresh with storm-themed animations
- [ ] [Performance] Optimize animation performance for low-end devices

### App Bar Navigation Fix

- [x] [UI-UX] Verify current notification badge implementation in app bar
- [x] [UI-UX] Change notification badge destination from storm notifications to notifications settings screen
- [x] [UI-UX] Confirm navigation flow to notification settings screen
- [ ] [Platform] Test navigation works on all screen entry points

### Themed Component Consistency

- [x] [UI-UX] Apply energetic storm theme consistently across all components
- [x] [UI-UX] Update power outage cards with storm theme styling
- [x] [UI-UX] Apply theme to statistics cards with animated counters
- [x] [UI-UX] Enhance dropdown filters with stormy visual design
- [x] [UI-UX] Update tornado event cards with interactive theme elements
- [ ] [Platform] Validate theme consistency across light and dark modes

### Emergency Work Section Removal

- [x] [UI-UX] Locate and remove Emergency Work Available section content
- [x] [UI-UX] Adjust storm screen layout to compensate for removed section
- [x] [UI-UX] Update screen scrolling behavior and padding
- [ ] [QA/QC] Test screen layout integrity after section removal

### Storm Contractors Component Creation

- [x] [UI-UX] Create new JJContractorCard widget component class
- [x] [UI-UX] Design contractor card layout with contact information display
- [x] [Platform] Implement interactive elements for email, phone, website
- [x] [Platform] Add URL launching capability for website links
- [x] [Platform] Integrate dial system for phone number contacts
- [x] [Backend] Update contractors data loading from docs\storm_roster.json
- [x] [UI-UX] Apply storm theme styling to JJContractorCard
- [x] [UI-UX] Add interaction animations for phone/email/website actions
- [ ] [Platform] Test cross-platform URL launching functionality
- [ ] [QA/QC] Validate interaction with various contact method types

### App Bar Color Fix

- [ ] [UI-UX] Change the `app bar` color on the Storm Screen to be solid primary navy blue.

### Storm Statistics Feature

- [ ] [UI-UX] Design and implement the "Storm Stats" section UI.
- [ ] [UI-UX] Build the `StormTrackForm` as a modal or bottom sheet for user input, using the provided code from `TODO.md` as a reference.
- [ ] [Backend] Implement the `StormTrackingService` to handle adding, updating, and deleting storm track records in Firestore.
- [ ] [UI-UX] Develop the UI for displaying comprehensive storm stat summaries based on user-provided data.
- [ ] [UI-UX] Create an interactive tool for users to calculate different values from their storm history.
- [ ] [Backend] Implement a feedback mechanism for users to submit their experience with the storm tracking feature.

---

## TAILBOARD SCREEN

Status: [Not Started]

### Create Crews Screen

- [ ] [UI-UX] Design crew creation interface with form validation
- [ ] [UI-UX] Implement crew name, description, and settings form fields
- [ ] [Backend] Create Firebase collection structure for crews
- [ ] [Backend] Add crew creation API with document validation
- [ ] [Security] Implement crew member invitation system with permissions
- [ ] [UI-UX] Add crew creation success feedback and navigation
- [ ] [QA/QC] Test crew creation workflow end-to-end

### Messages Tab Implementation

- [ ] [Backend] Create Firebase collection for crew messages
- [ ] [UI-UX] Build message display layout with sender information
- [ ] [UI-UX] Implement message input and sending functionality
- [ ] [Realtime] Add Firebase real-time listener for new messages
- [ ] [UI-UX] Add message timestamp and delivery status indicators
- [ ] [UI-UX] Implement message threading or reply functionality
- [ ] [Security] Add message visibility controls by crew membership
- [ ] [Performance] Optimize message loading for large conversation history
- [ ] [Accessibility] Ensure message input accessibility for different users
- [ ] [QA/QC] Test message exchange between multiple crew members

### Feed Tab Implementation

- [ ] [UI-UX] Design feed layout for crew posts and announcements
- [ ] [Backend] Create Firebase collection for crew feed posts
- [ ] [UI-UX] Implement post creation interface with rich text support
- [ ] [Realtime] Add real-time feed updates for new posts
- [ ] [UI-UX] Add post interaction features (like, comment, share)
- [ ] [UI-UX] Implement post attachment support (images, files)
- [ ] [Security] Control post visibility based on crew permissions
- [ ] [UI-UX] Add post filtering and sorting options
- [ ] [Performance] Implement feed pagination for large crews
- [ ] [QA/QC] Test feed interaction features across different user roles

### Chat Tab Implementation

- [ ] [UI-UX] Create chat interface with message bubbles and avatars
- [ ] [Backend] Implement Firebase real-time chat system for crews
- [ ] [UI-UX] Add typing indicators and online status display
- [ ] [UI-UX] Implement file and media sharing in chat
- [ ] [Realtime] Ensure chat synchronization across all crew members
- [ ] [Notification] Add chat notification system within the app
- [ ] [Security] Implement end-to-end encryption for chat messages
- [ ] [Performance] Optimize chat performance for large crews
- [ ] [Accessibility] Ensure chat accessibility for all users
- [ ] [QA/QC] Test chat functionality in multi-user scenarios

### Members Tab Implementation

- [ ] [UI-UX] Build member list interface with profiles and roles
- [ ] [Backend] Implement crew member management APIs
- [ ] [Security] Create role-based permissions (admin, member, moderator)
- [ ] [UI-UX] Add member invitation system with email/QR code options
- [ ] [UI-UX] Implement member role modification interface
- [ ] [UI-UX] Add member removal and ban functionality
- [ ] [Realtime] Update member status in real-time (online/offline)
- [ ] [Backend] Implement crew member audit trails
- [ ] [QA/QC] Test member management across different permission levels

### UI/UX Enhancements

- [ ] [UI-UX] Modify crew selection dropdown to disappear after selection, but remain accessible via a 3-dot menu.
- [ ] [UI-UX] Redesign the screen background to use gradients or patterns (e.g., copper streaks) instead of solid colors.
- [ ] [UI-UX] Implement electrical-themed animations for transitions between the Feed, Jobs, Chat, and Members tabs.
- [ ] [UI-UX] Redefine and improve the layout of all content appearing above the tab bar.

### Permissions & Navigation

- [ ] [Security] Remove the 'Settings' action (the 4th action) from the tab action handlers for users who are not crew foremen.

### Feed Tab Fixes & Features

- [ ] [Backend] Debug and fix the 'Submit' button functionality for creating a new post.
- [ ] [UI-UX] Implement the "My Posts" filter action handler.
- [ ] [UI-UX] Implement the "Sort" (by date, popularity) action handler.
- [ ] [UI-UX] Implement the "History" action handler.

### Jobs Tab Features

- [ ] [UI-UX] Design and implement the UI for the `Jobs Tab`.
- [ ] [Backend] Implement the "Construction Type" filter action handler.
- [ ] [Backend] Implement the "Local" filter action handler.
- [ ] [Backend] Implement the "Classification" filter action handler.

### Chat Tab Features

- [ ] [UI-UX] Implement the "Channels" action handler.
- [ ] [UI-UX] Implement the "DMs" (Direct Messages) action handler.
- [ ] [UI-UX] Implement the "History" action handler.

### Members Tab Features

- [ ] [UI-UX] Implement the "Roster" action handler.
- [ ] [UI-UX] Implement the "Availability" action handler.
- [ ] [UI-UX] Implement the "Roles" action handler.

---

## LOCALS SCREEN

Status: [Not Started]

### State Filter Removal

- [ ] [UI-UX] Locate state filter implementation underneath app bar
- [ ] [UI-UX] Remove all state filter functionality and UI elements
- [ ] [UI-UX] Adjust locals screen layout to accommodate removed filter
- [ ] [UI-UX] Update responsive design without state filtering
- [ ] [Platform] Ensure screen navigation and display consistency
- [ ] [QA/QC] Test locals screen functionality without filter

---

## SETTINGS SCREEN

Status: [Not Started]

### Branch Creation

- [ ] [Platform] Create new Git branch for settings screen modifications
- [ ] [Platform] Ensure branch isolation for safe development practices

### Electrical Background Integration

- [ ] [UI-UX] Apply electrical circuit background to settings screen
- [ ] [UI-UX] Verify background compatibility with all settings content
- [ ] [UI-UX] Test text readability over electrical background
- [ ] [UI-UX] Ensure electrical theme consistency throughout settings

### User Data Enhancement

- [ ] [UI-UX] Identify current settings data display capabilities
- [ ] [UI-UX] Add comprehensive user information display components
- [ ] [UI-UX] Implement data visualization for user activity metrics
- [ ] [UI-UX] Add user engagement statistics and usage patterns
- [ ] [Backend] Create API endpoints for user data aggregation
- [ ] [UI-UX] Design interactive navigational tooltips for complex data

### Themed Component Enhancement

- [ ] [UI-UX] Update all settings screen components with JJ app theme
- [ ] [UI-UX] Implement enhanced interactivity features
- [ ] [UI-UX] Add micro-animations and gesture responses
- [ ] [Platform] Ensure theme consistency across different device types

### Coaching Tooltip Implementation

- [ ] [UI-UX] Design coaching tooltip system for user guidance
- [ ] [UI-UX] Implement contextual help overlays for complex sections
- [ ] [UI-UX] Create tooltip content explaining data meanings
- [ ] [UI-UX] Add progressive disclosure for advanced settings
- [ ] [Platform] Test tooltips accessibility and dismissal behavior

---

## ACCOUNT - PROFILE SCREEN

Status: [Not Started]

### Profile Dismantling

- [ ] [UI-UX] Identify settings tab location in profile screen
- [ ] [UI-UX] Extract functionality to be moved to appropriate locations
- [ ] [UI-UX] Remove settings tab from profile screen completely

### Coaching Tooltip Addition

- [ ] [UI-UX] Locate pencil icon in top right corner of app bar
- [ ] [UI-UX] Implement contextual tooltip explaining pencil icon functionality
- [ ] [UI-UX] Add tooltip animation and dismissal options
- [ ] [UI-UX] Test tooltip behavior across different screen states

### Theme Application

- [ ] [UI-UX] Apply JJ App Theme to entire profile screen
- [ ] [UI-UX] Update all components with themed styling
- [ ] [Backend] Ensure all user data from onboarding populates correctly
- [ ] [UI-UX] Replace all hardcoded user information with dynamic data
- [ ] [QA/QC] Validate user data display accuracy against onboarding inputs

### Personal Tab Implementation

- [ ] [UI-UX] Create personal information editing interface
- [ ] [Backend] Implement user data save functionality on form submission
- [ ] [UI-UX] Add confirmation toast/snack bar for data saving
- [ ] [UI-UX] Implement real-time validation feedback
- [ ] [Database] Ensure data persistence to Firebase user document
- [ ] [QA/QC] Test personal tab data saving and retrieval

### Professional Tab Implementation

- [ ] [UI-UX] Create professional information editing interface
- [ ] [UI-UX] Convert ticketNumber field to numeric keypad only
- [ ] [Backend] Implement user data save functionality for professional tab
- [ ] [UI-UX] Add confirmation toast/snack bar for data saving
- [ ] [Database] Ensure professional data persistence to Firebase
- [ ] [QA/QC] Test professional tab data saving and numeric input validation

### Settings Tab Redirection

- [ ] [UI-UX] Redirect settings tab to notifications settings screen (preferred among duplicates)
- [ ] [Platform] Ensure consistent navigation to single notifications settings location

### Account Actions Implementation

- [ ] [Security] Implement the end-to-end process for a user to change their password securely.
- [ ] [Backend] Develop a service to gather all of a user's data from Firestore and Storage for download.
- [ ] [UI-UX] Implement the "Download my Data" feature, allowing the user to trigger the data export.
- [ ] [Security] Implement a secure, multi-step process for a user to permanently delete their account and associated data.

### Support and About Implementation

- [ ] [Platform] Wire up the "Help and Support" link to navigate to the `Help and Support Screen`.
- [ ] [Content] Compose the official `Journeyman Jobs Terms of Service` document and create a view to display it.
- [ ] [Content] Compose the official `Journeyman Jobs Privacy Policy` document and create a view to display it.

---

## ACCOUNT - TRAINING CERTIFICATIONS SCREEN

Status: [Not Started]

### Certificates Tab Implementation

- [ ] [UI-UX] Design certificates display grid/list layout
- [ ] [UI-UX] Create certificate detail expansion view
- [ ] [Backend] Implement certificate data retrieval from Firebase
- [ ] [UI-UX] Add certificate validation status indicators
- [ ] [UI-UX] Implement certificate search and filtering
- [ ] [Backend] Add certificate upload functionality
- [ ] [Security] Validate certificate authenticity processes
- [ ] [QA/QC] Test certificate display and management workflow

### Courses Tab Implementation

- [ ] [UI-UX] Design courses catalog interface with progress tracking
- [ ] [UI-UX] Implement course enrollment and completion components
- [ ] [Backend] Create course data management system
- [ ] [UI-UX] Add course progress visualization (progress bars, completion status)
- [ ] [Backend] Implement learning management APIs
- [ ] [UI-UX] Create course content viewing interface
- [ ] [Platform] Add offline course access capabilities
- [ ] [QA/QC] Test course enrollment and progress tracking

### History Tab Implementation

- [ ] [UI-UX] Build training history timeline interface
- [ ] [UI-UX] Implement filtering and search within history
- [ ] [Backend] Create certificate and course completion tracking
- [ ] [UI-UX] Add certificate expiration warnings and renewal requests
- [ ] [UI-UX] Implement history export functionality
- [ ] [Backend] Add audit trail for credential management
- [ ] [Security] Implement data verification for historical records
- [ ] [QA/QC] Test history display and export capabilities

---

## SUPPORT - CALCULATORS

Status: [Not Started]

### Calculation Helper Screen

- [ ] [UI-UX] Design calculation helper interface with step-by-step guidance
- [ ] [UI-UX] Implement calculation history and saved formulas
- [ ] [Backend] Create calculation engine with formula validation
- [ ] [Platform] Add unit conversion utilities
- [ ] [QA/QC] Test calculation accuracy and helper guidance

### Conduit Fill Calculator Screen

- [ ] [UI-UX] Design conduit fill interface with wire specification inputs
- [ ] [Backend] Implement NEC conduit fill calculation algorithms
- [ ] [Platform] Add wire gauge and conduit size reference data
- [ ] [UI-UX] Create visual conduit fill visualization
- [ ] [QA/QC] Validate calculations against NEC standards

### Electrical Constants Screen

- [ ] [UI-UX] Design electrical constants reference interface
- [ ] [Backend] Implement searchable constants database
- [ ] [UI-UX] Add categorization and unit conversion features
- [ ] [Platform] Ensure offline accessibility
- [ ] [QA/QC] Verify constant accuracy and completeness

### Load Calculator Screen

- [ ] [UI-UX] Design load calculation workflow interface
- [ ] [Backend] Implement electrical load calculation algorithms
- [ ] [UI-UX] Add circuit breaker and conductor sizing recommendations
- [ ] [Platform] Integrate with other calculation tools
- [ ] [QA/QC] Test calculation accuracy against electrical codes

### Wire Size Chart Screen

- [ ] [UI-UX] Design wire size chart reference interface
- [ ] [Backend] Implement wire sizing calculation based on length and current
- [ ] [UI-UX] Add conductor material and insulation type selection
- [ ] [Platform] Add voltage drop calculation integration
- [ ] [QA/QC] Validate wire size recommendations

---

## SUPPORT - FEEDBACK SCREEN

Status: [Not Started]

### Feedback Form Implementation

- [ ] [UI-UX] Design comprehensive feedback collection interface
- [ ] [UI-UX] Implement rating, category, and description form fields
- [ ] [Backend] Create Firebase feedback submission API
- [ ] [Platform] Add attachment/photo support for issues
- [ ] [UI-UX] Implement submission confirmation and tracking
- [ ] [Backend] Add feedback categorization and priority routing
- [ ] [Security] Implement user data protection for feedback submission
- [ ] [QA/QC] Test feedback submission and confirmation flow

---

## SUPPORT - HELP AND SUPPORT SCREEN

Status: [Not Started]

### FAQ Tab Implementation

- [ ] [UI-UX] Design FAQ interface with search and category filtering
- [ ] [Backend] Create FAQ database with search functionality
- [ ] [UI-UX] Implement collapsible FAQ sections
- [ ] [Platform] Ensure offline FAQ accessibility
- [ ] [QA/QC] Test FAQ search and user satisfaction

### Contact Tab Implementation

- [ ] [UI-UX] Design contact form with subject line and priority options
- [ ] [Backend] Implement support ticket creation system
- [ ] [UI-UX] Add contact method preferences (chat, email, phone)
- [ ] [Backend] Integrate with support CRM if applicable
- [ ] [Security] Add data protection for user contact information
- [ ] [QA/QC] Test support ticket creation and routing

### Guides Tab Implementation

- [ ] [UI-UX] Design guides library with categories and search
- [ ] [Backend] Create guide content management system
- [ ] [UI-UX] Implement guide viewing and bookmarking features
- [ ] [Platform] Add offline guide download capabilities
- [ ] [QA/QC] Test guide accessibility and content accuracy

---

## SUPPORT - RESOURCES SCREEN

Status: [Not Started]

### Documents Tab - IBEW Documents

- [ ] [UI-UX] Design document library interface with categories
- [ ] [Backend] Create document management and search system
- [ ] [UI-UX] Implement document viewing and bookmarking
- [ ] [Platform] Add offline document access
- [ ] [Security] Implement document access control

### Documents Tab - Safety

- [ ] [UI-UX] Design safety document organization by hazard type
- [ ] [Backend] Implement safety document database with version control
- [ ] [UI-UX] Add emergency reference quick-access features
- [ ] [Platform] Ensure offline safety document availability
- [ ] [QA/QC] Validate safety information accuracy

### Documents Tab - Technical

- [ ] [UI-UX] Design technical reference library interface
- [ ] [Backend] Create technical document tagging and search
- [ ] [UI-UX] Implement code/technical reference viewer
- [ ] [Platform] Add download and sharing capabilities
- [ ] [QA/QC] Test technical information accessibility

### Tools Tab - Calculators (Redirected)

- [ ] [Integration] Redirect calculator links to main calculator screens
- [ ] [UI-UX] Ensure tools tab provides clear navigation to calculator screens
- [ ] [Platform] Validate calculator deep linking

### Tools Tab - Reference

- [ ] [UI-UX] Design reference material browser interface
- [ ] [Backend] Create reference material organization system
- [ ] [UI-UX] Implement search and filtering capabilities
- [ ] [Platform] Ensure offline reference availability
- [ ] [QA/QC] Test reference material accessibility

### Links Tab - Training

- [ ] [UI-UX] Design training resource link collection interface
- [ ] [Integration] Add links to IBEW training centers
- [ ] [Integration] Add links to NECA education centers
- [ ] [UI-UX] Implement link verification and status checking
- [ ] [Platform] Test external link opening across platforms

### Links Tab - Safety

- [ ] [UI-UX] Design safety resource link collection
- [ ] [Integration] Add NFPA fire safety links
- [ ] [UI-UX] Implement resource categorization
- [ ] [Platform] Add link validation scripts
- [ ] [QA/QC] Verify safety resource link accuracy

### Links Tab - Government

- [ ] [UI-UX] Design government resource interface
- [ ] [Integration] Add Department of Labor links
- [ ] [UI-UX] Implement compliance resource organization
- [ ] [Platform] Ensure secure opening of government links
- [ ] [QA/QC] Validate government resource accuracy

---

## APP SETTINGS REDESIGN

Status: [Not Started]

### Settings Screen Theme Consistency

- [ ] [UI-UX] Apply electrical circuit background to app settings screen
- [ ] [UI-UX] Ensure background compatibility with all setting categories
- [ ] [UI-UX] Test readability over electrical background theme
- [ ] [Platform] Validate theme consistency with app's electrical motif

### Settings Screen Structural Redesign

- [ ] [UI-UX] Remove duplicate notification settings from wherever they appear
- [ ] [UI-UX] Consolidate single notification settings screen location
- [ ] [UI-UX] Merge app settings, privacy, and account actions into unified interface
- [ ] [Platform] Ensure consistent navigation to merged settings sections

### Appearance & Display Settings

- [ ] [UI-UX] Implement the `Dark Mode` toggle switch (`JJBreaker_switch`) to change the app's theme.
- [ ] [UI-UX] Implement the `High Contrast` toggle switch to apply a high-contrast theme.
- [ ] [UI-UX] Implement the `Electrical Effects` toggle switch to enable/disable visual effects.
- [ ] [UI-UX] Implement the `Font Size` control for accessibility.

### Data & Storage Settings

- [ ] [Performance] Implement a basic `Offline Mode`.
- [ ] [Backend] Implement the `Auto-Download` feature.
- [ ] [Backend] Implement the `WIFI-Only Downloads` setting.
- [ ] [Performance] Create and implement a `Clear Cache` function.

---

## NOTIFICATION SETTINGS SCREEN

Status: [Not Started]

### Electrical Background Application

- [ ] [UI-UX] Apply electrical circuit background to notification settings
- [ ] [UI-UX] Verify text readability with electrical background
- [ ] [UI-UX] Test visual consistency with other thematically designed screens

### Component and Theme Enhancements

- [ ] [UI-UX] Replace generic toggle switches with the custom `JJBreaker_switch` component.
- [ ] [UI-UX] Ensure the electrical background correctly adapts to the user's selected theme (light or dark mode).

---

## PRIVACY AND SECURITY SCREEN

Status: [Not Started]

### Content Migration Implementation

- [ ] [UI-UX] Identify content in app settings screen under settings tab
- [ ] [UI-UX] Transfer all applicable content to privacy and security screen
- [ ] [UI-UX] Organize transferred content logically within privacy screen
- [ ] [UI-UX] Update navigation references to point to privacy screen
- [ ] [QA/QC] Validate all content successfully migrated without loss

---

## ABOUT SCREEN

Status: [Not Started]

### About Screen Implementation

- [ ] [UI-UX] Design about screen with app information and branding
- [ ] [Platform] Add version information and build details
- [ ] [UI-UX] Implement appropriate electrical background theming
- [ ] [UI-UX] Add company attribution and legal compliance information
- [ ] [QA/QC] Test about screen information accuracy and display

---

## IMPLEMENTATION NOTES

- **Each checkbox represents a specific, achievable task**
- **Status indicators help track overall section progress**
- **Domain labeling ensures proper developer assignment**
- **Tasks are designed for 1-4 hour completion windows**
- **Interdependencies are noted within major feature groups**
- **QA/QC tasks ensure quality throughout development**

## UPDATED GITHUB WORKFLOW FILE CONTENT

### Next Steps for Final Bug Squashing

Visit your updated project for the finalized round-robin builder that includes fixes for hanging imports, project builder improvements, and the implementation of ignore files for `/ios` and `/android`.

### Local Application Startup Instructions

To start the Flutter application locally, open your terminal and navigate to the journeyman-jobs directory, then run:

```bash
flutter run
```

### Firebase Setup Instructions

Ensure Firebase plugins are configured appropriately for Android and iOS builds, and that your Firebase project is associated with your GitHub repository for cloud deployments.

This completes the comprehensive implementation guide for all TODO.md requirements. The TODO-TASKS.md file has been successfully created in the root directory.
````

## File: TODO.md
````markdown
---
---

# APP WIDE CHANGES

- Integrate a custom model(Local of course) that will summarize the job data for each job, provide suggestions or feedback in real-time to the user about other users experiences, opinions, successes with the same job or related(this is where the suggestions come in). If one user is communicating to the custom model about their experience with a certain company, local, region, etc. then the custom model can provide that as feedback or suggestive to either take the job, or not, then provide either a better fitting job for that specific user or a closely related job to the original inquiry

- I want this custom model to be able to take action for the user such as change settings, update preferences, send messages or notifications to the user. For example, if a user wants to change their job preferences to reflect $200 a day in per diem jobs, then the custom model needs to be able to update the preferences, query firestore for matching jobs, then provide the new jobs to that user via notification or direct message. These capabilities are reserved for paying customers only. non-subscribers can only chat with the custom model.

---

# ONBOARDING SCREENS

- The app open and starts in `dark mode` for onboarding but is light mode once authed. need to double check for consistency. it needs to be either light or dark for every screen throughout the app.

## AUTH SCREEN

- Be sure to add the copper boarder to every `text field` for both the `signup` and the `signin` tabs.

- I want to change the `tab bar` on the [[auth_screen]] with this upgraded and enhanced `tab bar` in this file "guide\tab-bar-enhancement.md". Be sure to maintain all of the original functionality of the existing `tab bar` simply change the UI to this enhanced version.
- The border around the `signup`/`signin` `tab bar` is bigger than the `tab bar`. Or something like that. there is a small gap between the bottom of the two `signup`/`signin` tabs and the border around the entire `tab bar`

### ONBOARDING STEPS SCREEN

#### STEP 1: BASIC INFORMATION

- On step 1 of SETUP PROFILE on this section, the `buildStepHeader` needs to be aligned in the center of the screen. Right now the alignment is to the left everything is centered as far as the icon the title and the subtitle All of that is centered It's just the entire `Header` needs to be moved to the right or centered to the screen. I have a screenshot it shows you what the screen looks like and so hopefully this will better help you understand what I'm talking about This is the path to the screenshot "assets\basic-info.png"

```dart

Widget _buildStep1() {

return SingleChildScrollView(

  padding: const EdgeInsets.all(AppTheme.spacingMd),

  child: Column(

 crossAxisAlignment: CrossAxisAlignment.start,

 children: [

   // Header

   _buildStepHeader(

  icon: Icons.person_outline,

  title: 'Basic Information',

  subtitle: 'Let\'s start with your essential details',

   ),

```

- `ADD` the copper border around all of the `text fields` in the entire file
- `Shorten` the `state dropdown` by half and expand the `zip code` text field to take up the remaining space.
- The `Next Button` Does not have any action associated with it. When the user presses the next button this is when the user document is created.

#### STEP 2

- Because the `next button` has no functionality or navigation, i cannot get to this screen to identify any changes that need to be made. That being said, what i do know that needs to be done is the same as the first step. When the user presses the `next button` all of the input data provided by the user needs to be written to that user document and then navigate to step 3

#### STEP 3

- Because the `next button` has no functionality or navigation, i cannot get to this screen to identify any changes that need to be made. That being said, what i do know that needs to be done is the same as the two previous steps. When the user presses the `next button` all of the input data provided by the user needs to be written to that user document and then navigate to the `home screen`

---

# HOME SCREEN

- Underneath the `app bar` it says "Welcome Back! /n 'User' "... I need for it to say, "Welcome Back! /n {firstName, LastName}". This way it feels more personable, and unique to the user.  Not so generic.

- *Active Crews*
This is a navigational link to the `crews screen` ....  ***INSTEAD OF HAVING A LINK TO THE `CREWS OR TAILBOARD SCREEN` THERE NEEDS TO BE A REALTIME SUMMARY OF THE  TOP `POSTS`, `MESSAGAGES`, AND `JOBS`. FOR THIS USER ALL IN A SINGLE PLACE.***
- *Quick Actions*
In the `Quick Action` section this is where we need to have the link to the `electrical calculator` as well as the view crews All of this should be under the `Quick Action` section There need not be independent active crew section nor independent electrical calculations for calculators. Both of them comment more or less are all best suited to fall under the `Quick Actions` section.
- *Suggested Jobs*
This section displays the best fitting and criteria fitting jobs set by the user during onboarding. The `job Cards` are a condensed version, only showing the top relevant job data, like the `Per Diem`, `hours`, `Rate`, and `conditions`. Once the user presses on one of the cards, then a detailed popup will appear containing all of the job posting data.

---

# JOB SCREEN

- The `job cards` need to be enhanced with it's own unique theme. Like money, paychecks, ovetime, doing work, dragging, travelling, 'Per Diem' "Book 2"
- To the job screen When I click on the `notification badge` or icon in the app bar I navigate to the correct correct page which is the [[notifications settings screen]] where there are two tabs one are for notifications and one are for settings that is the correct and only notification and or [[settings screen]] or page that this app will have.
- Underneath the `app bar` above the `scrollable list view` there is a sort or filter function horizontal scroll with multiple `choice chips` is what it looks like to me with all jobs set as the default.
- Whenever I press or select on the next choice chip which is journeyman lineman then I get this error.
- Other than the sort and filter function underneath the `app bar` whenever I press on the details button for any given jobs card the jobs dialog pop up that appears seems to be in order and functionable however there is room or opportunity

---

# STORM SCREEN

- ***I WANT FOR THE STORM SCREEN TO HAVE ITS OWN UNIQUE VIBE, FLOW, FEELING. IT'S OWN ANIMATIONS, SOUNDS, ICONS, INTERACTIONS. I WANT IT TO FEEL ENERGETIC AND ATTENTION GETTING.***

- `**App Bar**`: On the `app bar` the `notification badge` needs to navigate to the [[notifications settings screen]], not activate storm notifications. There is a setting for that in the [[notifications settings screen]].
  - The color of the `app bar` is off. it needs to be a solid primary navy blue color

- The entire screen needs to follow the apps design theme and use the apps custom themed components

- *Fix* the `Storm Contractors section`. The contractors data is located here: "docs\storm_roster.json" and a new "JJ" component needs to be created to display the data. It needs to be interactive so the users can click on the website, phone, email and have their devices react.

**Storm Contractors**

- In this section there will be a `list view`, or page view of all of the storm contractors and there basic contact information. Just like the rest of the app, once you click not eh `contractor's card` a popup or overlay will appear with more detail. From here you can click on a hyperlink, maps icon, or phone icon to have the users native device open the appropriate app to contact them.

**Storm Stats**

- This is where the user keeps track of the storms that they have been on that year. Using the `storm track form`user can keep track of the
  - contractor
  - utility,
  - the local
  - location
  - duration
  - storm type
  - pay
  - hours
  - travel/completion compensation
- User can quickly see their storm stats using an interactive tool to help then calculate different values based off of the user's wants/needs.

**HOW IT WORKS**

The user will be prompted to complete a simple form:

### Storm Track Form

```dart

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';
import '../../../models/storm_track.dart';
import '../../../services/storm_tracking_service.dart';

class StormTrackForm extends StatefulWidget {
  final StormTrack? track;
  final ScrollController scrollController;

  const StormTrackForm({
    super.key,
    this.track,
    required this.scrollController,
  });

  @override
  State<StormTrackForm> createState() => _StormTrackFormState();
}

class _StormTrackFormState extends State<StormTrackForm> {
  final _formKey = GlobalKey<FormState>();
  final _trackingService = StormTrackingService();

  late TextEditingController _contractorController;
  late TextEditingController _utilityController;
  late TextEditingController _stormTypeController;
  late TextEditingController _payRateController;
  late TextEditingController _perDiemController;
  late TextEditingController _workingHoursController;
  late TextEditingController _hoursWorkedController;
  late TextEditingController _mobilizationHoursController;
  late TextEditingController _demobilizationHoursController;
  late TextEditingController _travelReimbursementController;
  late TextEditingController _completionBonusController;
  late TextEditingController _conditionsController;
  late TextEditingController _notesController;

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final track = widget.track;
    _contractorController = TextEditingController(text: track?.contractor);
    _utilityController = TextEditingController(text: track?.utility);
    _stormTypeController = TextEditingController(text: track?.stormType);
    _payRateController =
        TextEditingController(text: track?.payRate.toString() ?? '');
    _perDiemController =
        TextEditingController(text: track?.perDiem.toString() ?? '');
    _workingHoursController =
        TextEditingController(text: track?.workingHours.toString() ?? '');
    _hoursWorkedController =
        TextEditingController(text: track?.hoursWorked.toString() ?? '');
    _mobilizationHoursController =
        TextEditingController(text: track?.mobilizationHours.toString() ?? '');
    _demobilizationHoursController = TextEditingController(
        text: track?.demobilizationHours.toString() ?? '');
    _travelReimbursementController = TextEditingController(
        text: track?.travelReimbursement.toString() ?? '');
    _completionBonusController =
        TextEditingController(text: track?.completionBonus.toString() ?? '');
    _conditionsController = TextEditingController(text: track?.conditions);
    _notesController = TextEditingController(text: track?.notes);

    if (track != null) {
      _startDate = track.startDate;
      _endDate = track.endDate;
    }
  }

  @override
  void dispose() {
    _contractorController.dispose();
    _utilityController.dispose();
    _stormTypeController.dispose();
    _payRateController.dispose();
    _perDiemController.dispose();
    _workingHoursController.dispose();
    _hoursWorkedController.dispose();
    _mobilizationHoursController.dispose();
    _demobilizationHoursController.dispose();
    _travelReimbursementController.dispose();
    _completionBonusController.dispose();
    _conditionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveTrack() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final track = StormTrack(
        id: widget.track?.id ?? '',
        userId: '', // Service handles this
        startDate: _startDate,
        endDate: _endDate,
        contractor: _contractorController.text,
        utility: _utilityController.text,
        stormType: _stormTypeController.text,
        payRate: double.tryParse(_payRateController.text) ?? 0.0,
        perDiem: double.tryParse(_perDiemController.text) ?? 0.0,
        workingHours: double.tryParse(_workingHoursController.text) ?? 0.0,
        hoursWorked: double.tryParse(_hoursWorkedController.text) ?? 0.0,
        mobilizationHours:
            double.tryParse(_mobilizationHoursController.text) ?? 0.0,
        demobilizationHours:
            double.tryParse(_demobilizationHoursController.text) ?? 0.0,
        travelReimbursement:
            double.tryParse(_travelReimbursementController.text) ?? 0.0,
        completionBonus:
            double.tryParse(_completionBonusController.text) ?? 0.0,
        conditions: _conditionsController.text,
        notes: _notesController.text,
      );

      if (widget.track == null) {
        await _trackingService.addStormTrack(track);
      } else {
        await _trackingService.updateStormTrack(track);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving track: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: AppTheme.spacingMd),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.track == null ? 'Add Storm Track' : 'Edit Storm Track',
                style: AppTheme.headlineSmall,
              ),
              if (widget.track != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppTheme.errorRed),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Track'),
                        content: const Text(
                            'Are you sure you want to delete this storm track?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete',
                                style: TextStyle(color: AppTheme.errorRed)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && mounted) {
                      await _trackingService.deleteStormTrack(widget.track!.id);
                      if (mounted) Navigator.pop(context);
                    }
                  },
                ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(
                          'Start Date',
                          _startDate,
                          () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: _buildDatePicker(
                          'End Date',
                          _endDate,
                          () => _selectDate(context, false),
                          placeholder: 'Ongoing',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Contractor & Utility
                  JJTextField(
                    controller: _contractorController,
                    label: 'Contractor',
                    hintText: 'e.g. Pike, Quanta',
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  JJTextField(
                    controller: _utilityController,
                    label: 'Utility',
                    hintText: 'e.g. FPL, Duke',
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  JJTextField(
                    controller: _stormTypeController,
                    label: 'Storm Type',
                    hintText: 'e.g. Hurricane, Ice Storm',
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Financials
                  _buildSectionHeader('Financials'),
                  Row(
                    children: [
                      Expanded(
                        child: JJTextField(
                          controller: _payRateController,
                          label: 'Base Pay Rate (\$/hr)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: JJTextField(
                          controller: _perDiemController,
                          label: 'Per Diem (\$/day)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Hours Breakdown
                  _buildSectionHeader('Hours Breakdown'),
                  JJTextField(
                    controller: _mobilizationHoursController,
                    label: 'Mobilization Hours (2x)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  JJTextField(
                    controller: _workingHoursController,
                    label: 'Working Hours (2x)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  JJTextField(
                    controller: _demobilizationHoursController,
                    label: 'De-mobilization Hours (1.5x)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Bonuses & Reimbursements
                  _buildSectionHeader('Bonuses & Reimbursements'),
                  JJTextField(
                    controller: _travelReimbursementController,
                    label: 'Travel Reimbursement',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  JJTextField(
                    controller: _completionBonusController,
                    label: 'Storm Completion Bonus',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Details
                  _buildSectionHeader('Details'),
                  JJTextField(
                    controller: _conditionsController,
                    label: 'Conditions',
                    hintText: 'e.g. Flooded, Icy',
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  JJTextField(
                    controller: _notesController,
                    label: 'Notes',
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppTheme.spacingXl),

                  JJPrimaryButton(
                    text: 'Save Track',
                    onPressed: _isSaving ? null : _saveTrack,
                    isLoading: _isSaving,
                    isFullWidth: true,
                    variant: JJButtonVariant.primary,
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Text(
        title,
        style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryNavy),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap,
      {String? placeholder}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXs),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.borderLight),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  date != null
                      ? DateFormat('MMM d, y').format(date)
                      : (placeholder ?? 'Select Date'),
                  style: AppTheme.bodyMedium.copyWith(
                    color: date != null
                        ? AppTheme.textPrimary
                        : AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


```

---

---

Then during the storm they can either keep track of their time, hours, locations, etc. or they can set up constants which will allow them to simply select the utility, the local start date, completion date, and if there travel or completion compensation, and based off of the data that we have stored we will be able to calculate their potential earnings.

**STATS SUMMARIES**

We will provide comprehensive storm stat summaries with all o fthe data provided by the user

**FEEDBACK**

After each storm the user will be able to provide feedback about their experience wit this feature. what they liked, didn't like. This give us the opportunity to hear what are users are saying and make adjustments accordingly.

# CREATE CREWS SCREEN

# TAILBOARD SCREEN

- So, when a user has selected the crew that they want to interact with, the dropdown needs to disappear when the user still has access to it through the three dot menu in the top right corner of the screen
- In the `action handler` of every tab, the fourth action is 'settings' yet this activates a popup with what looks like all of the settings for the crews feature. The only one who should have access to these type settings are the foreman of the crews. We need to remove the fourth `tab action` from each tab and replace it with something else or only have three `tab actions`
- The UI looks very basic. I want to enhance it, modernize it, make it more animated, reactive, engaging. There are no more solid colors os backgrounds or large components. Use gradients, some type of pattern, something. Something to break up the color. like for example. the background for the tailboard screen is the primary navy blue but solid. this looks horrible, there is no contrast, shading, shadows, contrast, gradient, nothing.
- I want to add electrical animations when the user navigates between tabs
- We need to better define the layout for everything above the `tab bar`
- I have provided screenshots of another version and it's UI. I want to do something similar. Where the copper looks like its shining, the dropdown in the middle of the screen is gone.
- Below the `tab bar` look at the background, how there are copper lines or streaks throughout. This is what i mean/ want to do to break up the solid color backgrounds.

### FEED TAB

![[feed-tab.png]]

- When I attempted to post something when i pressed 'submit' nothing happened. It became st-

#### FEED TAB ACTION HANDLERS

- **My Posts**

This is a filter to filter and display only the posts that you have submitted

- **Sort**

You can sort between dates, most populat, most liked, etc.

- **History**

### JOBS TAB

![[jobs-tab 1.png]]

#### JOBS TAB ACTION HANDLERS

- **Construction**

You can set the `Construction Type` to filter the displayed jobs from

- **Local**

You can filter any `local` from the displayed jobs from

- **Classification**

### CHAT TAB

![[chat-tab.png]]

#### CHAT TAB ACTION HANDLERS

- **Channels**

This is where the user can set the channel or chat to partici

- **DM's**

This is where the user can send direct messages to other crew members or user's

- **History**

### MEMBERS TAB

![[members-tab.png]]

#### MEMBERS TAB ACTION HANDLERS

- **Roster**

- **Availability**

- **Roles**

---

# LOCALS SCREEN

- **State Filter Function**: The state filter function just underneath the app bar on the locals screen is none functional. *Remove* it.

---

# SETTINGS SCREEN

****BEFORE STARTING WORK ON THE SETTINGS SCREEN. CREATE A NEW BRANCH OR WORKTREE****

- [[settings screen]]: On the [[settings screen]], the `electrical circuit background`needs to be applied.

- The screen needs to be enhanced with more user data, themed enhanced components, better interactivity.

- run tooltips or coaching.. things to help the user navigate and understand all of the emence data, knowledge, and customization accessible through the [[settings screen]]

## ACCOUNT

### PROFILE SCREEN

- **The [[app settings screen]] located under the `settings tab` needs to dismantled and the contents applied to the proper screen/tab**
- Be sure to initiate a coaching tooltip thing to help guide and explain to users to press on the `pencil icon` in the top right corner of the `app bar`
- This screen needs to be made over to fit the `JJ App Theme`
- Everything in the [[profile screen]] needs to store the user's data provided during onboarding. Looking at the code, there are multiple values, hardcoded
-

#### PERSONAL TAB

- When finished editing your personal information, there needs to be a `toast` or `snack bar` confirming that the changes have been saved.
-

#### PROFESSIONAL TAB

- The `ticketNumber text field` needs to only display the number pad like when you are inputting your phone number.
- When finished editing your personal information, there needs to be a `toast` or `snack bar` confirming that the changes have been saved.
-

#### SETTINGS TAB

- **The [[app settings screen]] located under the `settings tab` needs to dismantled and the contents applied to the proper screen/tab**
- We will replace the `settings tab` with a `preference tab` where the user will  be able to set or change any job preferences

##### SETTINGS AND PREFERENCES

app routing will change for all three of these sections

- *app settings*
This will no longer exist once moved to its own link
- *notification settings*
This will take over the 'notifications link' on the [[settings screen]]in the 'app' section.
- *Privacy and Security*
I need to work on drafting this

##### ACCOUNT ACTIONS

- *Change my Password*
I need to implement a processes to change your password. This doesn't do anything when pressed
- *Download my Data*
I need to implement a processes to download the user's data. This doesn't do anything when pressed
- **Delete My Account**
I need to implement a processes to delete the users account. This doesn't do anything when pressed

##### SUPPORT AND ABOUT

- *Help and Support*
When finalized, this will navigate the user to the [[help support screen]]
- *Terms of service*
I need to compose the `Journeyman Jobs` terms of service. This doesn't do anything when pressed
- *Privacy policy*
I need to compose the `Journeyman Jobs` privacy policy. This doesn't do anything when pressed

### TRAINING CERTIFICATIONS SCREEN

#### CERTIFICATES TAB

#### COURSES TAB

#### HISTORY TAB

---

## SUPPORT

### CALCULATORS

#### CALCULATION HELPER SCREEN

#### CONDUIT FILL CALCULATOR SCREEN

#### ELECTRICAL CONSTANTS SCREEN

#### LOAD CALCULATOR SCREEN

#### WIRE SIZE CHART SCREEN

### FEEDBACK SCREEN

### HELP AND SUPPORT SCREEN

#### FAQ TAB

#### CONTACT TAB

#### GUIDES TAB

### RESOURCES SCREEN

#### DOCUMENTS TAB

##### IBEW DOCUMENTS

##### SAFETY

##### TECHNICAL

#### TOOLS TAB

##### CALCULATORS

###### CONDUIT FILL CALCULATOR SCREEN

###### LOAD CALCULATOR SCREEN

###### VOLTAGE DROP CALCULATOR SCREEN

##### REFERENCE

#### LINKS TAB

##### TRAINING

###### IBEW TRAINING CENTERS

###### NECA EDUCATION CENTERS

##### SAFETY

###### NFPA - FIRE SAFETY

##### GOVERNMENT

###### DEPARTMENT OF LABOR

## APP

- **Be sure to remove the other `notification screen` from the app entirely**
- **For some reason a screen was created for each of the topics in the `apps section`. THIS IS WRONG. I DO `*NOT*` WANT THIS.. THAT IS OVERKILL. THIS SHOULD ONLY BE A SINGLE SCREEN WITH EACH SECTION BEING A SCREEN OVERLAY SIMILAR TO A TAB BAR BUT HORIZONTAL.. MAYBE. REGARDLESS, I DO NOT WANT 47 SCREENS LIKE I DO NOW, WHEN MULTIPLE SCREENS CAN BE COMBINED USING AN OVERLAY. IN FACT, THAT IS HOW I WANT ALL OF THE SECTIONS IN THE [[SETTINGS SCREEN]]. MOST ARE ALREADY FORMATTED THIS WAY BUT I KNOW THAT THERE ARE A FEW THAT ARE NOT AND HAVE A SEPERATE SCREEN FOR EACH.**
-

### SETTINGS SCREEN

#### APPEARANCE AND DISPLAY

- **Dark Mode**

This `toggle switch` allows the user to switch between `light mode` and `dark mode`

- **High Contrast**

This `toggle switch` allows the user to switch between `high contrast mode` and `normal mode`

<span style="background:#d3f8b6">- **Electrical Effects**</span>

This `toggle switch` allows the user activate all of the `electrical effects` or deactivate the effects for a simplistic and normal experienced.

- **Font Size**

This `toggle switch` allows the user to switch between `light mode` and `dark mode`

#### DATA AND STORAGE

- **Offline Mode**

Implement an offline mode with minimal activity

- **Auto-Download**

Create and implement this `auto-download` feature

- **WIFI-Only Downloads**

Create and implement this `WIFI-only download` feature

- **Clear Cache**

Create a `ClearCache` function

#### LANGAUGE AND REGION

#### STORM WORK SETTINGS

#### ABOUT

### NOTIFICATION SETTINGS SCREEN

- `notification tab`: On the [[notifications settings screen]], the `electrical circuit background` needs to be applied.

- **[[notifications settings screen]]**: On the `notification settings screen`, the electrical circuit background needs to be applied.
- We need to integrate the JJBreaker_switch or another "JJ" themed boolean/switch to replace the generic toggle switches
- The `electrical background` that you have integrated into this screen is the dark mode version. I need for you to change it as whatever the user has set because as of right now some screens are dark mode and some are light mode
-

### PRIVACY AND SECURITY SCREEN

- Most of the content for this screen is in the [[app settings screen]], found in the `Account Screen` under the `settings tab`. Be sure to transfer all of the relatable content from that file to this file

### ABOUT SCREEN

---

---
````
