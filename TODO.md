# TODO

## APP WIDE CHANGES

### [DISABLE DURING DEVELOPMENT AND TESTING] **Task Overview:** [DISABLE DURING DEVELOPMENT AND TESTING]

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

- ***PERFORM A COMPREHENSIVE ANALYSIS OF THE TAILBOARD SCREEN TO GET A COMPLETE AND FULL UNDERSTANDING OF ALL OF THE OPERATIONS, RELATIONSHIPS BETWEEN, TABS, THE BACKEND, USER INTERACTIONS , WIDGETS, ETC.***

- *INVESTIGATE* THE IMPLEMENTATION OF <lib\utils\crew_validation.dart> it's logic, it's purpose, it's functionality, etc...
- The UI needs to be modified I like a lot of dynamic and reactive features and animations however the theme the color theme is too dark It was as if the user activated dark mode but didn't the user has light mode activated so the screen needs to have primarily white or light colors according to the Light Mode app theme.
- **MODIFY** The first or top row. It is too cluttered, and with unneccessary things.
- **REMOVE** the `icon` on the far left of the `row`. I don't even know what tghat `icon` is for. The middle of the `row` needs to be redisgned. Customize or enhance it's features
- **REMOVE** the member count.
  
```dart
Row(
children: [
    Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
        gradient: TailboardTheme.copperAccent,
        borderRadius: TailboardTheme.radiusLarge,
        boxShadow: TailboardTheme.elevation2,
    ),
    child: Icon(
        Icons.group,
        color: Colors.white,
        size: 24,
    ),
    ),
    const SizedBox(width: TailboardTheme.spacingMd),
    Expanded(
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
            crewName,
            style: TailboardTheme.headingLarge,
        ),
        Text(
            "$memberCount members • $userRole",
            style: TailboardTheme.bodyMedium.copyWith(
            color: TailboardTheme.copper600,
            ),
        ),
        ],
    ),
    ),
    glowContainer(
    context,
    isActive: true,
    child: IconButton(
        icon: Icon(
        Icons.settings,
        color: TailboardTheme.copper600,
        ),
        onPressed: onSettingsTap,
    ),
    ),
],
),
```

- **REMOVE** The row with the three container `active`, `pending`, and `applied`

```dart
Row(
children: [
    _buildStatusCard(context, "Active", "12", TailboardTheme.successGradient),
    const SizedBox(width: TailboardTheme.spacingSm),
    _buildStatusCard(context, "Pending", "5", TailboardTheme.warningGradient),
    const SizedBox(width: TailboardTheme.spacingSm),
    _buildStatusCard(context, "Applied", "3", TailboardTheme.infoGradient),
],
),
```

- At the top of the screen you have the name of the crew needs to be displayed I see that now but we can make that a better layout and easier to read The widgets and layout needs to be needs to flow and mesh a little better than what it does or it is
- implement the custom rotation meter loading widget <lib\design_system\components\three_phase_rotation_meter.dart>

### CREATE CREWS SCREEN

- **lib\features\crews\screens\create_crew_screen.dart**

- **SET CREW PREFERENCES**

- **lib\widgets\dialogs\user_job_preferences_dialog.dart**

### JOBS

- **docs\tailboard\jobs-tab.png**

- This tab seems to be functioning properly. When the tab is activated, jobs are displayed in the interactive window. I have not confirmed that the jobs are sortde and filtered against the job preferences.

### FEED

- **docs\tailboard\feed-tab.png**

- When a user posts a massage using the `feed tab` that message should post and be displayed immediately after sending it. Regardless of the amount of users the app has or the number of members that are in a crew, or whatever. That is the sole purpose for the `feed tab` is that it allows the individual user the ability to post a message so all the other users can see it and any given user can interact with any other user whether they're a member of a crew or not.

### CHAT

- **docs\tailboard\chat-tab.png**

- ***WHEN I SELECT THE CHAT TAB I GET AN ERROR MESSAGE STATING **"Error loading crew members: Exception: Failed to get crew members: type 'Timestamp' is not a subtype of type 'DateTime?"** THIS ERROR MUST BE CORRECTED.***
- Even though i get that error message, i am able to send a message  recieve a message sent `toast` but it never post in the interactive window. [TROUBLESHOOT]
- The same logic goes for the `CHAT tab` when a user Sends a message to the CREW only current members of your crew is able to read it.
- As soon as a member post or sends a message it needs to be displayed in the real time window.
- This is like A real-time messagingsystem so if user one post a message then everyone including the user that made the post can see the message and any other crew member can respond to it. So let's say user 1 posts a message, then user 2 reads the message and then replies to that message whenever user two posts that message then it is also displayed in real time so that all members can see the message regardless of the amount of members in a crew or if or whom the message was directed towards There should be no reason why user one can't post 30 consecutive messages back to back and not every single one of those messages be displayed in real time in the order of which it was posted.
- *INVESTIGATE* the implementation of the `crew message bubble`<lib\widgets\crew_message_bubbl >
- *IMPLEMENT* the `TODO` in <lib\services\crew_messaging_service.dart Implement push notification using NotificationService.sendNotificatione.dart>

### MEMBERS

- This tab seems to be functioning properly. When the tab is activated, members are displayed in the interactive window. However, you cannot interact with the membersb card. TODO: Eventually i want to be able to click on a members card and a popup appears with that users basic info.
- *INVESTIGATE* the implementation of the <lib\services\crew_invitation_service.dart>. Where, How, What are the implementation specs?
- What is the order of operations?
- Where is the `crew invitation card` implemented? <lib\widgets\crew_invitation_card.dart>
- When do you interact with the `invite crew member dialog` <lib\widgets\invite_crew_member_dialog.dart>

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
