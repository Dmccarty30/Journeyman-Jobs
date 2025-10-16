# TODO

## APP WIDE CHANGES

- ***I WANT TO USE THE DARK NAVY BLUE COLORED BACKGROUND ON THE `WELCOME SCREEN` AND `AUTH SCREEN` WILL BE THE THEME FOR `DARK MODE`. THIS MEANS THAT THERE NEEDS TO BE THE ADDITION OF A `DARK MODE` FEATURE. SO THAT MEANS, GO AHEAD AND CREATE THE THE `DARK MODE` APP THEME BASED OFF OF THE CURRENT MODE OF THE `WELCOME SCREEN` AND `AUTH SCREEN` AND ADD IT TO "lib\design_system\app_theme.dart" THEN, CHANGE THE COLOR THEME OF THE `WELCOME SCREEN` AND `AUTH SCREEN` BACK TO THE `LIGHT MODE`***
- ***BE SURE TO PROVIDE DETAILED AND COMPREHENSIVE DOCUMENTATION TO ANY AND ALL CHANGES/MODIFICATIONS/ADDITIONS THAT NEED TO BE MADE***

## APP THEME

- **Dark Mode**

- In text color on top of all of the `text fields` needs to be black. They are light grey so you cannot read the `text hint` or `text label`.

## ONBOARDING SCREENS

- I want for you to perform a comprehensive analysis on the User Auth process. I mean a super deep dive into the codebase to ensure that everything is working and is proper. From

### WELCOME SCREEN

- **lib\screens\onboarding\welcome_screen.dart**

- On the third screen/step of the welcome screen the `complete button` or `next button` needs smaller font sizes. Reduce the size by 15%

### AUTH SCREEN

- **lib\screens\onboarding\auth_screen.dart**

- I want to change the `tab bar` needs to be better aligned. The `sign up` and `sign in` tabs are smaller than the entire `tab bar` so there is a gap between the bottom boarder of the entire `tab bar` and the bottom of either of the tabs.. there is a screenshot @assets\tab-bar-gap.png
- REDUCE the border size of the `tab bar` by 50%
- Correct the overflow error for the continue with `Google button`

### ONBOARDING STEPS SCREEN

- **lib\screens\onboarding\onboarding_steps_screen.dart**

#### STEP 1: BASIC INFORMATION

- On step 1 of SETUP PROFILE when the user presses the `next button` this is when the user document is created using the input data from the `text fields` and the user navigates to step 2

#### STEP 2

- In the "Books you are currently on" `text field` replace the current values " Book1, Book2 etc" with examples of actual local number

#### STEP 3: PREFERENCES AND FEEDBACK

- The `choice chips` for 'construction type' the text values need to be capitalized. They are currently formatted like a backend value with the first letter lower case and the first letter of the second word capitalized. This needs to be corrected

## HOME SCREEN

- **lib\screens\storm\home_screen.dart**

- Read "docs\Home-Analysis.md" to get a better understanding of this files structure and potential issues
- Underneath the `app bar` it needs to have the user's name displayed where it says "Welcome Back, [usersName]!".

- *Quick Actions*

- ADD one more container that will navigate the user directly to the `Resources Screen`
- REMOVE the light blue shadow from the containers as well.

- *Suggested Jobs*

- Read "docs\plan-personalize-job-recommendations-0.md" to understand what i want to do about this section.
- REMOVE all colored font from all cards, containers, and or dialog popups. This includes the grey tint behind and around the local number of the job cards.

## JOB SCREEN

- **lib\screens\storm\jobs_screen.dart**

- Read "docs\Jobs-Analysis.md" to get a better understanding of this files structure and potential issues
- ADD a simple search feature so that the user can `Search` for any specific local union. Place this widget underneath the horizontal filter
- Make the `Search` widget a traditional seatch widget as in a `text field` with a magnifying icon on one end and the text hint "Search For A Specific Local"
- THE ONLY VALUE THAT WILL BE SEARCHABLE IS THE LOCAL UNION NUMBER.
- REMOVE "Storm Work" as one of the filtering options.

## STORM SCREEN

- **lib\screens\storm\storm_screen.dart**

- Read "docs\Storm-Analysis.md" to get a better understanding of this files structure and potential issues
- The borders around everything on the `Storm Screen` are to thick. They need to be reduced in thickness by 1/2.
- I am not sure what is exactly is going on with this screen. They're just like everything is inside of the container or column including the background Like the circuit board background is inside this container and column it just seems weird something's off but needs to be redone Yeah something's off

## TAILBOARD SCREEN

- **lib\features\crews\screens\tailboard_screen.dart**

- Once a user joins a crew or creates a crew then it can be assumed that that user will be active with the crew from this point forward therefore the welcome to the tail board heading and the description below will be removed and replaced with a lower profile header of the name of the active crew with that crew's description underneath just in smaller text and font So There is more room Or the tab bar and the messages below it
- When you're on the tailboard screen and you turn the phone horizontally there is an overflow error.

### CREATE CREWS SCREEN

- **lib\features\crews\screens\create_crew_screen.dart**

- **STEP 1**

- Though on the tail board screen there's the Create a Crew button and then a drop down button to select or join a crew So when you hit the create a crew and you start the crew on boarding you then again get the option to create a crew or join a crew I think this is too much So on the first screen of the crew_boarding_screen.dart remove the join a crew button.
- Change the creator crew text from `Create a Crew` to `next`

- **STEP 2**

- On the second step of the crew on boarding we need to add all of the classifications that were listed and the main apps onboarding to include `operator` `tree trimmer` so on and so on and not just limit it to `inside wireman` and `journeyman lineman`
- On the second step of the onboarding be sure to add the copper border around all of the input fields the text box the text input the drop down
- Add the electrical circuit background to the crew onboarding screen
- Change the switch to the custom JJ circuit breaker switch We need to maintain consistency throughout the app in every aspect
- I'd like to do something with the Create a Crew button add some persistent animation or gradient color gradient or shadow or something something unique to make it pop to signify you know you're you're creating a crew and you're part of something and you're committed. Be sure to maintain consistency with the design schema and app theme.

- **SET CREW PREFERENCES**

- There is an overflow on the top right corner of the `set crew preference dialog`
- `Apprentice Lineman` needs to be removed `electrical Foreman` needs to be removed `project Manager` needs to be removed `electrical Engineer` needs to be removed `safety Coordinator` needs to be removed `Journeyman Lineman` needs to be removed `inside wireman` needs to be removed This initial preference is a job type so all of these values need to be replaced with the construction type meaning `Transmission` `distribution` `substation` `underground` `industrial` `commercial` `residential` `Data center` etcetera.
- The `Save Preferences` button is wrong we need to remove the word preferences it's understood that this is what you're saving so we'll keep cancel and change `save preferences` to simply `save` or `continue`
- When I hit the save preference button I can't move any further because I'm not authorized. The error is the firststore error updating crew caller does not have permission

### JOBS

- **docs\tailboard\jobs-tab.png**

### FEED

- **docs\tailboard\feed-tab.png**

- The user should have access and be able to interact with the `feed tab` regardless of whether or not that user is a member of a crew or just exploring the app.
- The purpose of the `feed tab` is to provide all users with the opportunity to `post` about a job they've heard about, or read someone else's `post` with out having the pressure, or feeling obligated to be a member or participate in/with a crew.
- When the user tabs on the `feed tab` There needs to be some sort of `FAB` or user input window As to or to show the user or to prompt the user into writing something or posting something
- When the user taps on the `feed tab` then all of the prior `posts` will automatically populate Starting with the most recent at the top
- I don't think that I'm going to implement a `sort` or `filter` feature or the `feed tab`
- I'm going to put a cap on the maximum amount of `posts` visible or displayed at any given time 50 `posts`

### CHAT

- **docs\tailboard\chat-tab.png**

- So for the chat feature the chat tab this is for the members of a crew so that they can chat amongst each other and amongst themselves about whatever they want to talk about This tab is exclusively for members of the same active crew
- I need to design the chat box the colors and everything that goes along with messaging feature The users message that is sent will be on the right and everyone else's will be on the left as far as incoming messages
- The app will float like most all other messaging apps to where the message that you post is at the bottom of the screen and then the next person post and it goes below your message and then the next person post and it goes below that message so the newest most up to date messages on the bottom of the screen
- At the very bottom of the messaging window is where you will see the single line text input and the send button just like you normally do on all of the other messaging apps and once you click into that single line text input then that activates your keyboard and your keyboard is then overlaid or displayed on the screen you type it out and you hit send Same functionality as everything else
- I do want for there to be a circular icon for the user avatar If the user doesn't have an avatar then they can have their initials I can change the color they can put any other icon or image that's their way to personalize it just like any other messaging app on the planet

### MEMBERS

- **docs\tailboard\members-tab.png**

- The Members tab simply lists all of the members in the active crew on the tail board screen it shows their name their basic information like their home local maybe what books they're on or where they want to work or maybe even a custom input by the user to you know show whoever and that's essentially all of the Members tab is you can select a member from the Members tab and It will bring up a set of options so that you can send `direct message` or view profile Maybe that last one view profile is the very beginning stages of a concept so don't even take it seriously however the `direct message` we can plan for that

## LOCALS SCREEN

- **lib\screens\storm\locals_screen.dart**

- The search function for the `Locals Screen` does not function properly. Regardless if I search for city, state, "local number", just the number, nothing.

## SETTINGS SCREEN

- `ACCOUNT SECTION`

- **lib\screens\storm\settings_screen.dart**

- When i am in edit mode in the settings, if try to upload an image from my gallery, when i press upload or okay or whatever the button is called to upload the image, the entire app crashes.
- When I press the `edit profile button` in the settings screen  I get an error "Error loading data 'init' is not a sub type of "string"
- Change the main container at the top of the settings screen to reflect a more personal vibe or connection with the user by displaying their ticket number, their name and a random but catcthy expression,something, anything....as long as it is different than what it is now.

### PROFILE SCREEN

- At the top of the screen, i guess the header or maybe it could be part of the `app bar`, You need to remove the user's email and replace it with thier name or something else. Underneath that in copper is "IBEW Local 296" for example. That entire expression needs to be replaced with a `rich text widget` and formatted like so"IBEW Local: " [localNumber]
- You need to implement or activate to tool tips again to better explain to users how to edit thier profiles.

#### PERSONAL TAB

#### PROFESSIONAL TAB

- For the `Books on` `text field` remove the hint text in the center of the text field and replace it with actual local number like.. REMOVE 'Book 1', 'Book 2' and replace it with 84, 222, 111, 1249, 71. I feel like user would better understand what it is that we are asking of them.

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

***REMOVE `GOVERNMENT` SECTIONS AND REPLACE IT WITH A `HELPFUL` SECTION***

- **IBEW OFFICIAL**

- **TRAINING**

- **HELPFUL**

- ADD a container for "Union Pay Scales". and have the link icon connected to <https://unionpayscales.com/trades/ibew-linemen/>
- ADD another container for "Union Pay Scales". and have the link icon and have it set to dispay @lib\widgets\pay_scale_card.dart instead of navidating to the devices browser

- **SAFETY**

- connect NFPA to <https://www.nfpa.org/en/for-professionals/codes-and-standards/list-of-codes-and-standards#sortCriteria=%40computedproductid%20ascending%2C%40productid%20ascending&aq=%40culture%3D%22en%22&cq=%40tagtype%3D%3D(%22Standards%20Development%20Process%22)%20%20>
