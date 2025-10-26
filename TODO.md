# TODO

## APP WIDE CHANGES

### **Task Overview:**

Update the user authentication and session handling logic in the application to implement a grace period for automatic logouts. This change aims to improve user experience by preventing abrupt session terminations, allowing users a brief window to resume activity without re-authenticating.
Specific Requirements:

**Target Behaviors to Modify:**
***THIS FUNCTION SHOULD BE DISABLED DURING DEVELOPMENT AND TESTING.DURING WHICH NO TIMEOUT/IDLE TIME LIMITATION SHALL BE APPLIED***
||| `Idle/inactivity detection (e.g., no user input or page interactions for a defined period).
||| App closure or backgrounding (e.g., user switches away from the app or explicitly closes it).
||| Any other automatic sign-out triggers (e.g., network disconnection, timeout on suspended sessions).`

**Current vs. Desired Behavior:**

Current: Immediate sign-out upon detection of the above conditions.
Desired: Delay sign-out by exactly 5 minutes after the condition is detected. During this delay, the session remains active and logged in, even if the app is closed or inactive.

**Implementation Guidelines:**

Start a 5-minute timer only after the triggering condition is confirmed (e.g., after 2 minutes of confirmed inactivity, begin the additional 5-minute grace period).
If the user resumes activity (e.g., reopens the app, performs an action) within the 5 minutes, reset the timer and maintain the session without interruption.
Ensure the delay applies universally across platforms (web, iOS, Android) and session types (e.g., browser tabs, mobile foreground/background).
Log relevant events for debugging (e.g., "Grace period started due to inactivity at [timestamp]") without exposing user data.

**Edge Cases to Handle:**

Multiple triggers in quick succession: Use the latest trigger to reset the timer.
Server-side vs. client-side enforcement: Synchronize timers where possible to avoid desyncs.
Security considerations: Do not extend the grace period beyond 5 minutes; enforce strict sign-out after expiration to maintain compliance.

**Testing Criteria:**

Verify no sign-out occurs within 5 minutes of triggering conditions.
Confirm sign-out happens precisely at the 5-minute mark if no resumption occurs.
Test resumption scenarios to ensure seamless session continuity.

Expected Output: Provide updated code snippets, configuration changes, or pseudocode for the affected modules (e.g., auth service, session manager). Include any necessary UI notifications (e.g., a subtle warning banner at the 4-minute mark: "Session expiring soon—stay active to continue").

## APP THEME

## ONBOARDING SCREENS

### WELCOME SCREEN

- **lib\screens\onboarding\welcome_screen.dart**

### AUTH SCREEN

- **lib\screens\onboarding\auth_screen.dart**

### ONBOARDING STEPS SCREEN

- **lib\screens\onboarding\onboarding_steps_screen.dart**

#### STEP 1: BASIC INFORMATION

#### STEP 2

#### STEP 3: PREFERENCES AND FEEDBACK

## HOME SCREEN

- **lib\screens\storm\home_screen.dart**

- On the home screen underneath welcome back text it should display the user's first name and last name as if the app were welcoming them so it would say welcome back David Mccarty instead of Journeyman or their email Peter had I have addressed this issue multiple times I don't understand why it still doesn't say the user's first name and last name.

- *Quick Actions*

- *Suggested Jobs*

## JOB SCREEN

- **lib\screens\storm\jobs_screen.dart**

## STORM SCREEN

- **lib\screens\storm\storm_screen.dart**

- There is a newly created section for the Youtube video player widget this is so that we can stream Fox News Weather now from Youtube for free in real time while they report on the current severe weather conditions. However there's a tag or title in this section that says `admin only` that needs to be removed.
- The Youtube video player widget needs to be completed It has simply been added to the screen there isn't any specific channel navigation or URL to identify which channel or video to play There is no logic behind it.

- **Storm Contractor Section**
  
- In the Storm Contractor section The `contractor cards` still do not populate There's an error saying "Error loading contractors cloud fire store permission denied the caller does not have permissions to execute the specific operation" This needs to be changed The permissions need to be relaxed so that any user has the permission to query the database to read the documents in the `stormcontractors` collection

## TAILBOARD SCREEN

- **lib\features\crews\screens\tailboard_screen.dart**

- The UR needs to be modified I like a lot of dynamic and reactive features and animations however the theme the color theme is too dark It was as if the user activated dark mode but didn't the user has light mode activated so the screen needs to have primarily white or light colors according to the Light Mode app theme.
- I'm not quite sure what the active pending and applaud containers of four I'm guessing it's related to the member count of that crew. They can be removed and replaced with something else maybe maybe keep the act of container which at most conserved team members because each crew has a limit of 10 members so that that logic needs to be applied you can remove the pending and applied containers and replace it with something else
- At the top of the screen you have the name of the crew needs to be displayed I see that now but we can make that a better layout and easier to read The widgets and layout needs to be needs to flow and mesh a little better than what it does or it is

### CREATE CREWS SCREEN

- **lib\features\crews\screens\create_crew_screen.dart**

- **SET CREW PREFERENCES**

- **lib\widgets\dialogs\user_job_preferences_dialog.dart**

### JOBS

- **docs\tailboard\jobs-tab.png**

- For the `Jobs tab` this suggested jobs uses the exact same suggested jobs sort and filter algorithm and and function as the sorting filter function for suggested jobs for the individual user at which the user sets the job preferences during onboarding so that exact same sort and filter function needs to be applied for the suggested jobs immediately after the `foreman` sets the job preferences Sir as soon as the `foreman` sets the job preferences there should be jobs displayed on the `Jobs tab` immediately. For some reason no messages are displayed no jobs are displayed however the `foreman` is displayed under the `Members tab` so that is semi functional there needs to be some improvements but at least that tab works.

### FEED

- **docs\tailboard\feed-tab.png**

- When a user posts a massage using the `feed tab` that message should post and be displayed immediately after sending it. Regardless of the amount of users the app has or the number of members that are in a crew, or whatever. That is the sole purpose for the `feed tab` is that it allows the individual user the ability to post a message so all the other users can see it and any given user can interact with any other user whether they're a member of a crew or not.

### CHAT

- **docs\tailboard\chat-tab.png**

- The same logic goes for the CH  Sending messages to the other members of a crew and only for members of that crew.
- As soon as a member post or sends a message it needs to be displayed in the real time window.
- This is like AA live feed type system so if user one post a message then everyone including user one can see the message and any other member can respond so let's say user 2 reads the message and then replies to that message whenever user two posts that message then it is also displayed in real time so that all members can see the message regardless of the amount of members in a crew or if or whom the message was directed towards There should be no reason why user one can't post 30 consecutive messages back to back and not every single one of those messages be displayed in real time in the order of which it was posted.

### MEMBERS

- **docs\tailboard\members-tab.png**

## LOCALS SCREEN

- **lib\screens\storm\locals_screen.dart**

- So with implementation of a `unified job card` given that there were six separate Cards but serve all serve the same purpose yet only one or two of the cards were actually used in the app while the other ones were dead code and false references the `locals card` needs to be redesigned Specifically for the type of data query from the `locals collection`.

## SETTINGS SCREEN

- `ACCOUNT SECTION`

- **lib\screens\storm\settings_screen.dart**

### PROFILE SCREEN

#### PERSONAL TAB

#### PROFESSIONAL TAB

#### SETTINGS TAB

### TRAINING AND CERTIFICATES SCREEN

#### CERTIFICATES TAB

#### COURSES TAB

#### HISTORY TAB

- `SUPPORT SECTION`

### HELP AND SUPPORT SCREEN

#### FAQ TAB

#### CONTACT TAB

#### GUIDES TAB

### RESOURCES SCREEN

#### DOCUMENTS TAB

- **IBEW CONSTITUTION**

- **SAFETY**

- **TECHNICAL**

#### TOOLS TAB

- **CALCULATORS**

- **REFERENCES**

#### LINKS TAB

- **IBEW OFFICIAL**

- **TRAINING**

- **HELPFUL**

- **SAFETY**
