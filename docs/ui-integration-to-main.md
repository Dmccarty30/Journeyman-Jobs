# This is the Guide to help AI Integrate some of the newly added UI enhancments from the UI-UX Worktree back to the `MAIN` branch

My goal for this action is to create a single file prompt, so to speak. That will spell out, step-by-step to the AI system that I choose exactly what files, features, functions, models, etc. That i want to take from "C:\Users\david\Desktop\worktrees\ui-ux" and integrate them into "C:\Users\david\Desktop\Journeyman-Jobs" which is the primary repo for my app. I want to first implement the changes to the `UI` branch before I merge it with the `MAIN`. I will try to include ample diescription as well as absolute file paths.

## CORE INTEGRATIONS

1. **Electrical Backgrounds**: Change the background of every single screen to the new `ElectricalCircuitBackground` from `"C:\Users\david\Desktop\Journeyman-Jobs\lib\electrical_components\circuit_board_background.dart"`
2. **Riverpod Provider**: Use Riverpod Provider intead of Provider
3. **Electrical Theme Enhancements**: Implement everything from this file, `"C:\Users\david\Desktop\Journeyman-Jobs\lib\electrical_components\README_ENHANCEMENTS.md"`
4. **Correct Userflow To Transformer Training**: Be sure to follow the diagram in `"C:\Users\david\Desktop\Journeyman-Jobs\assets\transformer-user-flow.png"` entry point at || void _navigateToTool(BuildContext context, ResourceItem item) {
Widget? toolScreen; || except i want to create a new section in the tools screen explicitly for transformers. So it will have `Calculators`, `References`, and `Transformers`.
5. **JJ App Theme**: I want to ensure that there is only one reference to the `JJ APP THEME` and that the `JJ APP THEME` is absolutely correct and covers every single possible variable. From boarder widths, to color schemes, to font families, components shadows, ***EVERYTHING!!***
6. **Legacy FLutterFlow**: Be sure to properly remove all of the legacy `FlutterFlow` files to reduce overall project file size. First, be sure to integrate any and all code references needed from the `FlutterFlow` files before deletion.

## QUESTIONABLE OR UNSURE OF FEATURES/FILES

1. **C:\Users\david\Desktop\Journeyman-Jobs\lib\electrical_components\optimized_electrical_exports.dart**
2. **Clear up the two main files**: `C:\Users\david\Desktop\Journeyman-Jobs\lib\main_riverpod.dart` and `C:\Users\david\Desktop\Journeyman-Jobs\lib\main.dart`

## NEW EPIC IMPLENTATIONS

Read the files in `"C:\Users\david\Desktop\Journeyman-Jobs\docs\job-sharing-feature"` for context.

### CREWS EPIC

**Description**: This new Epic will give the users the familiar sense of being on a crew with one another. As Journeymen in the I.B.E.W. alot of members that travel for work tend to find other Journeymen that travel as well. And when you travel for work, most people look for certain criteria when taking a job. That is high `Per Diem`=$200+, `Long Hours`=12-14hrs a day, `Schedule`=6-7 days a week. And when a Journeyman meets another hand, they tend to want to stay together and tramp the country for the big jobs, splitting living expenses along the way furthure increasing their take home. That being said, there should'nt be any difference here. The users can create `CREWS` with the Journeymen they tramp with, and when one of them finds a good job, they can share, suggest, and potentially even bid for that job on their behalf sorta like a `Crew Bid`. That is, as long as everyone is qualified and meets all of the job requirements.

#### FEATURES

1. **Messaging System**:
2. **Job Sharing**:
3. **Crew Member Management**:
4. 