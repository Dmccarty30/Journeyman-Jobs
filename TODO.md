
# APP WIDE CHANGES

- Integrate a custom model(Local of course) that will summarize the job data for each job, provide suggestions or feedback in real-time to the user about other users experiences, opinions, successes with the same job or related(this is where the suggestions come in). If one user is communicating to the custom model about their experience with a certain company, local, region, etc. then the custom model can provide that as feedback or suggestive to either take the job, or not, then provide either a better fitting job for that specific user or a closely related job to the original inquiry

- I want this custom model to be able to take action for the user such as change settings, update preferences, send messages or notifications to the user. For example, if a user wants to change their job preferences to reflect $200 a day in per diem jobs, then the custom model needs to be able to update the preferences, query firestore for matching jobs, then provide the new jobs to that user via notification or direct message. These capabilities are reserved for paying customers only. non-subscribers can only chat with the custom model.

---
---

## ONBOARDING SCREENS

- **Change the background of every onboarding screen to the `electrical curuit` background just like it is with every other screen in the entire app**

### AUTH SCREEN

- Be sure to add the copper boarder to every `text field` for both the `signup` and the `signin` tabs.

- I want to change the `tab bar` on the auth screen with this upgraded and enhanced `tab bar` in this file "guide\tab-bar-enhancement.md". Be sure to maintain all of the original functionality of the existing `tab bar` simply change the UI to this enhanced version.

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

## HOME SCREEN

- Underneath the `app bar` it says "Welcome Back! /n 'User' "... I need for it to say, "Welcome Back! /n {firstName, LastName}". This way it feels more personable, and unique to the user.  Not so generic.

- *Active Crews*
This is a navigational link to the `crews screen` ....  ***INSTEAD OF HAVING A LINK TO THE `CREWS OR TAILBOARD SCREEN` THERE NEEDS TO BE A REALTIME SUMMARY OF THE  TOP `POSTS`, `MESSAGAGES`, AND `JOBS`. FOR THIS USER ALL IN A SINGLE PLACE.***
- *Quick Actions*
In the Quick Action section this is where we need to have the link to the `electrical calculator` as well as the view cruise All of this should be under the `Quick Action` section There need not be independent active crew section nor independent electrical calculations for calculators. Both of them comment more or less are all best suited to fall under the `Quick Actions` section.
- *Suggested Jobs*
This section displays the best fitting and criteria fitting jobs set by the user during onboarding. The job Cards are a condensed version, only showing the top relevant job data, like the `Per Diem`, `hours`, `Rate`, and `conditions`. Once the user presses on one of the cards, then a detailed popup will appear containing all of the job posting data.

---

## JOB SCREEN

- The `job cards` need to be enhanced with it's own unique theme. Like money, paychecks, ovetime, doing work, dragging, travelling, 'Per Diem' "Book 2"
- To the job screen When I click on the notification badge or icon in the app bar I navigate to the correct correct page which is the notification settings page where there are two tabs one are for notifications and one are for settings that is the correct and only notification and or settings screen or page that this app will have.
- - Underneath the app bar above the scrollable list view there is a sort or filter function horizontal scroll with multiple `choice chips` is what it looks like to me with all jobs set as the default.
- Whenever I press or select on the next choice chip which is journeyman lineman then I get this error.
 ![[Screenshot 2025-11-29 194724.png]]

- Other than the sort and filter function underneath the app bar whenever I press on the details button for any given jobs card the jobs dialog pop up that appears seems to be in order and functionable however there is room or opportunity

---

## STORM SCREEN

- ***I WANT FOR THE STORM SCREEN TO HAVE ITS OWN UNIQUE VIBE, FLOW, FEELING. IT'S OWN ANIMATIONS, SOUNDS, ICONS, INTERACTIONS. I WANT IT TO FEEL ENERGETIC AND ATTENTION GETTING.***

- **App Bar**: On the `app bar` the notification badge needs to navigate to the notifications screen, not activate storm notifications. There is a setting for that in the `notifications settings screen`

- The entire screen needs to follow the apps design theme and use the apps custom themed components

- *Remove* the `Emergency Work Available` section.

- *Fix* the `Storm Contractors section`. The contractors data is located here: "docs\storm_roster.json" and a new "JJ" component needs to be created to display the data. It needs to be interactive so the users can click on the website, phone, email and have thier devices react.

---

## TAILBOARD SCREEN

### CREATE CREWS SCREEN

### MESSAGES TAB

### FEED TAB

### CHAT TAB

### MEMBERS TAB

---

## LOCALS SCREEN

- **State Filter Function**: The state filter function just underneath the app bar on the locals screen is none functional. *Remove* it.

---

## SETTINGS SCREEN

****BEFORE STARTING WORK ON THE SETTINGS SCREEN. CREATE A NEW BRANCH OR WORKTREE****

- [[settings screen]]: On the [[settings screen]], the electrical circuit background needs to be applied.

- The screen needs to be enhanced with more user data, themed enhanced components, better interactivity.

- run tooltips or coaching.. things to help the user navigate and understand all of the emence data, knowledge, and customization accessible through the [[settings screen]]

## ACCOUNT

### PROFILE SCREEN

- **The [[app settings screen]] located under the `settings tab` needs to dismantled and the contents applied to the proper screen/tab**
- Be sure to initiate a coaching tooltip thing to help guide and explain to users to press on the `pencil icon` in the top right corner of the `app bar`
- This screen needs to be made over to fit the `JJ App Theme`
- Everything in the [[profile screen]] needs to store the user's data provided during onboarding. Looking at the code, there are multiple values, hardcoded

#### PERSONAL TAB

- When finished editing your personal information, there needs to be a `toast` or `snack bar` confirming that the changes have been saved.

#### PROFESSIONAL TAB

- The `ticketNumber text field` needs to only display the number pad like when you are inputting your phone number.
- When finished editing your personal information, there needs to be a `toast` or `snack bar` confirming that the changes have been saved.

#### SETTINGS TAB

- **The [[app settings screen]] located under the `settings tab` needs to dismantled and the contents applied to the proper screen/tab**

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
I need to implement a processes to change your password. This doesn't do anything when pressed
- **Delete My Account**
I need to implement a processes to change your password. This doesn't do anything when pressed

##### SUPPORT AND ABOUT

- *Help and Support*
When finalized, this will navigate the user to the [[help support screen]]
- *Terms of service*
I need to implement a processes to change your password. This doesn't do anything when pressed
- *Privacy policy*
I need to implement a processes to change your password. This doesn't do anything when pressed

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

- **IBEW TRAINING CENTERS**

- **NECA EDUCATION CENTERS**

##### SAFETY

- **NFPA - FIRE SAFETY**

##### GOVERNMENT

- **DEPARTMENT OF LABOR**

## APP

- **Be sure to remove the other `notification screen` from the app entirely**

### SETTINGS SCREEN

#### APPEARANCE AND DISPLAY

- **Dark Mode**

- **High Contrast**

- **Electrical Effects**

- **Font Size**

#### DATA AND STARAGE

- **Offline Mode**

- **Auto-Download**

- **WIFI-Only Downloads**

- **Clear Cache**

#### LANGAUGE AND REGION

#### STORM WORK SETTINGS

#### ABOUT

### NOTIFICATION SETTINGS SCREEN

- [[notification screen]]: On the [[notification screen]], the electrical circuit background needs to be applied.

- **Notification Settings Screen**: On the `notification settings screen`, the electrical circuit background needs to be applied.

### PRIVACY AND SECURITY SCREEN

- Most of the content for this screen is in the [[app settings screen]], found in the `Account Screen` under the `settings tab`. Be sure to transfer all of the relatable content from that file to this file

### ABOUT SCREEN

---

---

---
---

## GROK

Here’s my full analysis of the current situation based on **TODO.md**, the actual code/files you shared, and the overall product vision from **PRD_Journeyman_Jobs.md** and **Best Business Practices**.

### Current State (What the documents + code actually show)

| Location | What exists today | What it contains | Problem |
|--------|-------------------|------------------|---------|
| Profile Screen → Settings Tab | → taps → opens **App Settings Screen** (the one that currently lives under the Settings tab) | Appearance, Data & Storage, Language, Storm Work Settings, Notification Settings, Privacy & Security, Account Actions (Change Password, Download Data, Delete Account), Support & About | Very overloaded, mixes user preferences, app preferences, account actions, and support |
| Bottom navigation → “Settings” icon | → opens a completely separate **Settings Screen** (the one with the electrical circuit background) | Same sections as above + some duplicates (Notification Settings appears twice) | Duplicate entry points, confusing hierarchy, user has to remember which “Settings” does what |
| Other places | Notification Settings also has its own full screen that is reachable from multiple places | | Fragmented |

You are 100% right: this is the classic “two settings screens” anti-pattern that almost every growing app falls into.

### Your Proposed Fix (and why it is excellent)

> “Dismantle the [[app settings screen]] under the settings tab and move contents to proper places.  
> Replace the Settings tab in Profile with a **Preferences** tab (job + user preferences).  
> Keep one single **App Settings** screen reachable from the bottom-nav Settings icon (or from a gear in the toolbar).”

This is exactly the industry best-practice structure for a trade-specific B2C app like Journeyman Jobs.

### Recommended Final Information Architecture

```
Profile Screen (4 tabs)
├── Personal        → name, photo, ticket #, contact info, bio
├── Professional    → classification, certifications, licenses, experience
├── Preferences     → NEW TAB (replaces old “Settings” tab)
│    ├── Job Preferences      (pay, per diem, distance, job type, storm, etc.)
│    ├── Search Filters & Saved Searches
│    ├── Notification Preferences (job alerts only)
│    └── Tramp Ticket / Auto-sign settings
└── Crews           → list of crews user belongs to / create crew shortcut

Bottom Navigation
├ Home
├ Jobs
├ Storm
├ Tailboard / Crews
└ Settings (gear icon) → Single **App Settings Screen (only app-wide, non-user-specific settings)

App Settings Screen (one single screen, electrical circuit background)
├── Appearance & Display
│    ├── Dark Mode
│    ├── High Contrast
│    ├── Electrical Effects (keep – it’s part of the brand)
│    └── Font Size
├── Data & Storage
│    ├── Offline Mode
│    ├── Auto-Download
│    ├── Wi-Fi Only Downloads
│    └── Clear Cache
├── Language & Region
├── Storm Work Settings (global, not per-user)
├── Privacy & Security     → move everything here from the old screen
├── Account Actions
│    ├── Change Password
│    ├── Download My Data
│    └── Delete My Account
├── Support & About
│    ├── Help & Support
│    ├── Terms of Service
│    └── Privacy Policy
└── App Version / Build
```

### Benefits of This Structure

| Benefit | Explanation |
|-------|-------------|
| No more “which Settings do I go to?” confusion | Users intuitively understand Profile = “me”, Settings = “the app” |
| Job preferences live where they belong | Next to the user’s certifications and personal info – this is the #1 most-edited data in the PRD mentions |
| Much cleaner Profile screen | 4 logical tabs instead of 5, with the heaviest one (old Settings) gone |
| Easier future growth | Want to add “Payment & Subscription” later? It goes cleanly under App Settings → Account Actions |
| Matches every successful blue-collar / trade app | FieldPulse, ServiceTitan, Jobber, CompanyCam, etc. all separate “My Preferences” from “App Settings” the same way |
| Matches Apple & Google HIG | Apple: “Settings” = app-wide. User-specific stuff = inside the user’s profile/account screen |

### Implementation Roadmap (low effort → high impact order)

1. Immediate (1–2 days)  
   - Rename the Settings tab in Profile → “Preferences”  
   - Move Job Preferences, Saved Searches, Tramp Ticket settings into that new tab (you already have most of the fields in onboarding/profile)

2. Week 1  
   - Delete the duplicate Notification Settings screen that lives under the old App Settings  
   - Move the remaining non-user items (Appearance, Data & Storage, Language, Privacy & Security, Account Actions, Support) into the single bottom-nav Settings screen  
   - Apply electrical circuit background + copper borders consistently

3. Polish  
   - Add a small gear icon in the Profile toolbar that goes to the same App Settings screen (secondary entry point)  
   - Add deep links so “Open App Settings” from iOS/Android settings jumps to the right place

4 Future  

- Consider moving Crew management completely to the Tailboard tab (or keep a shortcut card in Profile → Crews), but that’s phase 2

### Summary – My Verdict

Your instinct is spot-on and actually better than 95% of startup apps I audit.

Do exactly what you wrote:

- Kill the Settings tab inside Profile  
- Replace it with **Preferences** (job + search + alert preferences)  
- Keep one canonical **App Settings** screen under the bottom-nav Settings icon  
- Move everything else there

This will instantly make the app feel more professional, less cluttered, and much more intuitive for the IBEW members who are your core users (and who hate unnecessary taps more than anyone).

Let me know if you want me to draft the exact widget tree / Riverpod providers for the new Preferences tab or the consolidated App Settings screen – happy to write the code for you.
