
# Quick Review of the Provided Files

To ensure we're on the same page, here's a high-level synthesis of what I've gleaned from the documents. This builds on the Spec-Kit structure (which focuses on iterative, AI-assisted spec-driven development) and highlights how your app's maturity influences our customization:

- **App_Design_Reference_Report.md**: This is a comprehensive design system guide, emphasizing an electrical-themed UI (copper accents, navy bases, circuit patterns, hard hat icons). It covers themes, typography (Inter font), spacing, animations (e.g., electricity flow, sparks), accessibility (WCAG AA), and state consistency (loading, error, success). Key integrations include custom widgets like JJElectricalSwitch, PowerLineLoader, and responsive layouts. It references Flutter's Material 3 and a migration guide for electrical enhancements. This screams for prompts that enforce design consistency, especially in UI/UX phases like planning and implementation.

- **architecture_2.0.md**: Details a production-ready full-stack architecture using Clean Architecture and Feature-Sliced Design. Highlights include 25+ services (auth, notifications, weather via NOAA), 25+ screens (home, jobs, crews, storm work), 30+ widgets, Firebase backend (Firestore collections like users/jobs/crews, Cloud Functions for matching/notifications), Riverpod for state, go_router for navigation. It notes evolutions beyond original plans (e.g., exceeded specs in services/widgets) and tech debt (e.g., FlutterFlow refactoring). This informs prompts for architecture alignment, scalability, offline support, and integrations like weather/NOAA.

- **continuous-user-authorization-guide_2.0.md**: Focuses on a robust, continuous auth system with Firebase (multi-provider: email/Google/Apple), offline resilience (24-hour retention), role-based access (Foreman/Lead/Member), rate limiting, and connectivity awareness. It includes code snippets for services/providers and emphasizes production metrics (e.g., <2s sign-in). This is critical for security/compliance in prompts, especially in planning/tasks where auth guards and RBAC must be baked in.

- **PROJECT_OVERVIEW_REPORT_2.0.md**: A high-level overview of the app's mission (job discovery for IBEW workers, storm work, crew collab). Covers features like job filtering, weather alerts, union directory (797+ locals), tools (calculators, NEC references), and evolutions (e.g., advanced crew matching). It includes user personas (wiremen, linemen), success metrics (10k+ users, 4.5+ stars), and privacy considerations (GDPR). This helps tailor prompts to user-centric, industry-specific needs (e.g., safety protocols, emergency response).

- **auth-report_2.0.md**: Similar to the auth guide but more analytical, covering multi-provider auth, Riverpod state management, error handling (15+ conditions), RBAC with 9 permissions, Firestore rules, and metrics. It reinforces production readiness and offline features. Overlaps with the auth guide, so prompts can consolidate auth best practices.

- **PROJECT_SPECS_2.0.md**: Summarizes specs with directory structure (lib/screens/widgets/providers/services/models/utils/design_system), data models/collections, and status (e.g., exceeded originals in services/widgets). Notes tech debt (refactoring, optimization) and future enhancements (e.g., advanced matching). This mirrors Spec-Kit's artifact structure (spec.md, plan.md, tasks.md) and can guide how we customize those outputs.

Overall Insights:

- **Project Maturity**: Your app is already in production with real users (IBEW workers), so prompts should focus on iterative enhancements/refinements rather than greenfield builds. Emphasize evolutions (e.g., beyond basics in crews/weather) and addressing tech debt (e.g., performance for large datasets like 797 locals).
- **Key Themes**: Electrical branding (copper/navy, circuits/sparks), safety/weather integration (NOAA), crew collab (RBAC, messaging), offline resilience, Firebase-heavy backend, Flutter/Riverpod frontend.
- **Gaps in Spec-Kit Coverage**: Spec-Kit is great for phased workflows but misses app-specifics like your custom electrical UI library, NOAA integrations, RBAC for crews, or production metrics/monitoring. It also doesn't deeply cover ongoing maintenance (e.g., tech debt refactoring) or industry compliance (e.g., union rules, safety protocols). We can add phases for "refine" (iterating on existing features) and "deploy/monitor" (post-implementation validation with metrics).

## Brainstorming: Structuring the Customized Prompts

Now, let's brainstorm how to adapt Spec-Kit's phases into a custom set of prompts (or prompt templates) for your app. The goal is a cohesive "Journeyman Jobs Spec-Kit" – a series of prompts you can feed to an AI (like me) for feature planning/implementation. We'll cover all Spec-Kit phases and fill gaps.

1. **Overall Structure**:
   - **One Prompt per Phase**: Create modular prompts, each mimicking a Spec-Kit command (e.g., "/specify" becomes a prompt for generating spec.md). Chain them like Spec-Kit (e.g., clarify before plan).
   - **Customization Layers**:
     - Embed app specifics (e.g., always reference electrical theme, Firebase, Riverpod, NOAA where relevant).
     - Include checklists for your evolutions/tech debt (e.g., check for offline support, RBAC integration).
     - Add outputs tailored to your structure (e.g., generate code snippets in Dart, update Firestore rules).
   - **Number of Prompts**: Aim for 7-9: One for each Spec-Kit phase (specify, clarify, constitution, plan, tasks, analyze, implement) + gaps like "refine" (for iterations) and "deploy" (for production checks/metrics).

2. **Covering Spec-Kit Phases + Gaps**:
   - **/specify (Feature Spec Creation)**: Prompt to generate/update spec.md from natural language. Tailor to include IBEW user stories, electrical UI requirements, weather/safety integrations.
   - **/clarify (Ambiguity Resolution)**: Interactive questioning prompt, focused on app-specific ambiguities (e.g., how does this affect crew RBAC? Offline behavior?).
   - **/constitution (Governance)**: Prompt to define/update principles, incorporating your design system (e.g., always enforce electrical theme consistency) and production rules (e.g., metrics thresholds).
   - **/plan (Implementation Planning)**: Generate plan.md with artifacts (research, data-model, contracts). Customize for Firebase schemas, Riverpod providers, custom widgets.
   - **/tasks (Task Breakdown)**: Create tasks.md with phases (Setup, Tests, Core, etc.). Add app-specific rules (e.g., TDD with flutter_test, integrate with electrical components).
   - **/analyze (Consistency Check)**: Read-only analysis prompt. Enhance with checks for your tech debt (e.g., flag legacy FlutterFlow code) and compliance (e.g., WCAG, GDPR).
   - **/implement (Task Execution)**: Execute tasks phase-by-phase. Tailor to generate Dart code, update Firebase configs, include electrical animations.
   - **Gaps to Add**:
     - **/refine (Iteration on Existing Features)**: For maturing features (e.g., optimize weather integration). Prompt to review current impl and suggest enhancements.
     - **/deploy (Deployment & Monitoring)**: Post-implement, generate deployment steps (e.g., GitHub Actions, Firebase emulators) and monitoring (e.g., check against your metrics like <2s auth).

3. **Key Tailoring Elements**:
   - **Incorporate App Context**: Every prompt should reference provided files (e.g., "Align with App_Design_Reference_Report.md for electrical themes").
   - **User Input Handling**: Like Spec-Kit, use $ARGUMENTS for feature descriptions.
   - **Output Formats**: Mirror Spec-Kit (e.g., Markdown artifacts, JSON paths) but add Dart code examples, Mermaid diagrams for architecture updates.
   - **Error/Validation**: Build in pauses for ambiguities, like in clarify.
   - **Brainstorm Risks**: Prompts should warn about tech debt (e.g., avoid expanding legacy code) and enforce best practices (e.g., offline-first, RBAC).
   - **Length/Complexity**: Keep prompts concise but comprehensive—aim for 500-1000 words each to fit AI contexts.

4. **Potential Challenges & Ideas**:
   - **Over-customization**: Risk making prompts too rigid; brainstorm flexibility (e.g., optional flags for "storm work" features).
   - **Integration with Tools**: Since you have tools like code_execution/browse_page, prompts could include steps to use them (e.g., browse NOAA docs during planning).
   - **Agreement Points**: What do you think about adding a "/refine" phase? Should prompts auto-reference all your files, or just key ones? Do we need multi-prompt sets for complex phases (e.g., plan has sub-phases 0-2)?
   - **Next Steps**: Once we agree, I can draft the first prompt (e.g., for /specify) as a sample, then iterate.

What are your thoughts? Do you want to prioritize certain phases (e.g., start with planning/tasks since your app is mature)? Any specific app elements (e.g., more emphasis on crews or weather) to weave in deeper? Let's refine this before I start writing!
