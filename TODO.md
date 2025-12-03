
---
---

# APP WIDE CHANGES

- Integrate a custom model(Local of course) that will summarize the job data for each job, provide suggestions or feedback in real-time to the user about other users experiences, opinions, successes with the same job or related(this is where the suggestions come in). If one user is communicating to the custom model about their experience with a certain company, local, region, etc. then the custom model can provide that as feedback or suggestive to either take the job, or not, then provide either a better fitting job for that specific user or a closely related job to the original inquiry

- I want this custom model to be able to take action for the user such as change settings, update preferences, send messages or notifications to the user. For example, if a user wants to change their job preferences to reflect $200 a day in per diem jobs, then the custom model needs to be able to update the preferences, query firestore for matching jobs, then provide the new jobs to that user via notification or direct message. These capabilities are reserved for paying customers only. non-subscribers can only chat with the custom model.

---  
---

# ONBOARDING SCREENS

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

# HOME SCREEN

- Underneath the `app bar` it says "Welcome Back! /n 'User' "... I need for it to say, "Welcome Back! /n {firstName, LastName}". This way it feels more personable, and unique to the user.  Not so generic.

- *Active Crews*
This is a navigational link to the `crews screen` ....  ***INSTEAD OF HAVING A LINK TO THE `CREWS OR TAILBOARD SCREEN` THERE NEEDS TO BE A REALTIME SUMMARY OF THE  TOP `POSTS`, `MESSAGAGES`, AND `JOBS`. FOR THIS USER ALL IN A SINGLE PLACE.***
- *Quick Actions*
In the Quick Action section this is where we need to have the link to the `electrical calculator` as well as the view cruise All of this should be under the `Quick Action` section There need not be independent active crew section nor independent electrical calculations for calculators. Both of them comment more or less are all best suited to fall under the `Quick Actions` section.
- *Suggested Jobs*
This section displays the best fitting and criteria fitting jobs set by the user during onboarding. The job Cards are a condensed version, only showing the top relevant job data, like the `Per Diem`, `hours`, `Rate`, and `conditions`. Once the user presses on one of the cards, then a detailed popup will appear containing all of the job posting data.

---

# JOB SCREEN

- The `job cards` need to be enhanced with it's own unique theme. Like money, paychecks, ovetime, doing work, dragging, travelling, 'Per Diem' "Book 2"
- To the job screen When I click on the notification badge or icon in the app bar I navigate to the correct correct page which is the notification settings page where there are two tabs one are for notifications and one are for settings that is the correct and only notification and or settings screen or page that this app will have.
- Underneath the app bar above the scrollable list view there is a sort or filter function horizontal scroll with multiple `choice chips` is what it looks like to me with all jobs set as the default.
- Whenever I press or select on the next choice chip which is journeyman lineman then I get this error.
- Other than the sort and filter function underneath the app bar whenever I press on the details button for any given jobs card the jobs dialog pop up that appears seems to be in order and functionable however there is room or opportunity

---

# STORM SCREEN

- ***I WANT FOR THE STORM SCREEN TO HAVE ITS OWN UNIQUE VIBE, FLOW, FEELING. IT'S OWN ANIMATIONS, SOUNDS, ICONS, INTERACTIONS. I WANT IT TO FEEL ENERGETIC AND ATTENTION GETTING.***

- **App Bar**: On the `app bar` the notification badge needs to navigate to the notifications screen, not activate storm notifications. There is a setting for that in the `notifications settings screen`.
 	- The color of the `app bar` is off. it needs to be a solid primary navy blue color

- The entire screen needs to follow the apps design theme and use the apps custom themed components

- *Fix* the `Storm Contractors section`. The contractors data is located here: "docs\storm_roster.json" and a new "JJ" component needs to be created to display the data. It needs to be interactive so the users can click on the website, phone, email and have thier devices react.

**Storm Contractors**

- In this section there will be a list view, or page view of all of the storm contractors and there basic contact information. Just like the rest of the app, once you click not eh contractor's cord a popup or overlay will appear with more detail. From here you can click on a hyperlink, maps icon, or phone icon to have the users native device open the appropriate app to contact them.

---

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

- **Sort**

- **History**

- **Settings**

### JOBS TAB

![[jobs-tab 1.png]]

#### JOBS TAB ACTION HANDLERS

- **Construction**

- **Local**

- **Classification**

- **Settings**

### CHAT TAB

![[chat-tab.png]]

#### CHAT TAB ACTION HANDLERS

- **Channels**

- **DM's**

- **History**

- **Settings**

### MEMBERS TAB

![[members-tab.png]]

#### MEMBERS TAB ACTION HANDLERS

- **Roster**

- **Availability**

- **Roles**

- **Settings**

---

# LOCALS SCREEN

- **State Filter Function**: The state filter function just underneath the app bar on the locals screen is none functional. *Remove* it.

---

# SETTINGS SCREEN

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

###### IBEW TRAINING CENTERS

###### NECA EDUCATION CENTERS

##### SAFETY

###### NFPA - FIRE SAFETY

##### GOVERNMENT

###### DEPARTMENT OF LABOR

## APP

- **Be sure to remove the other `notification screen` from the app entirely**
- **For some reason a screen was created for each of the topics in the `apps section`. THIS IS WRONG. I DO `*NOT*` WANT THIS.. THAT IS OVERKILL. THIS SHOULD ONLY BE A SINGLE SCREEN WITH EACH SECTION BEING A SCREEN OVERLAY SIMILAR TO A TAB BAR BUT HORIZONTAL.. MAYBE. REGARDLESS, I DO NOT WANT 47 SCREENS LIKE I DO NOW, WHEN MULTIPLE SCREENS CAN BE COMBINED USING AN OVERLAY. IN FACT, THAT IS HOW I WANT ALL OF THE SECTIONS IN THE SETTINGS SCREEN. MOST ARE ALREADY FORMATTED THIS WAY BUT I KNOW THAT THERE ARE A FEW THAT ARE NOT AND HAVE A SEPERATE SCREEN FOR EACH.**
-

### SETTINGS SCREEN

#### APPEARANCE AND DISPLAY

- **Dark Mode**

- **High Contrast**

<span style="background:#d3f8b6">- **Electrical Effects**</span>

- **Font Size**

#### DATA AND STORAGE

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
- We need to integrate the JJBreaker_switch or another "JJ" themed boolean/switch to replace the generic toggle switches
- The electrical background that you have integrated into this screen is the dark mode version. I need for you to change it as whatever the user has set because as of right now some screens are dark mode and some are light mode
-

### PRIVACY AND SECURITY SCREEN

- Most of the content for this screen is in the [[app settings screen]], found in the `Account Screen` under the `settings tab`. Be sure to transfer all of the relatable content from that file to this file

### ABOUT SCREEN

---

---
