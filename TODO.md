# TODO

## APP WIDE CHANGES

- ***IMPLEMENT THE ELECTRICAL CIRCUIT DESIGN AND THEME TO ANY AND ALL `TOASTS`, `SNACK BARS`, AND `TOOL TIPS` EXACTLY AS THEY ARE IN THE "DEMO_SCREEN" WITH A THICK BOARDER, THE BACKGROUND IS SLIGHTLY TRANSPARENT WITH AN ELECTRICAL CURCUIT BOARD DESIGN AND ANIMATION. WITH THE COLORS OF RED FOR WARNING, GREEN FOR SUCCESS, AND YELLOW FOR CAUTION(NOT EXACTLY SURE HOW THOSE LABELS ARE GOING TO TRANSLATE TO THE APP. MAYBE RED IS PERMENANT?). WITH THE ONLY EXCEPTION TO THE COLOR CODE ARE THE TOOL TIPS. THE TOOL TIPS SHOULD COMPLEMENT THE MOOD AND SITUATIONS.***

## ONBOARDING SCREENS

### WELCOME SCREEN

- **lib\screens\onboarding\welcome_screen.dart**

- On the third screen/step of the welcome screen the `complete button` or `next button` needs smaller font sizes. Reduce the size by 15%

### AUTH SCREEN

- **lib\screens\onboarding\auth_screen.dart**

- I want to change the `tab bar` needs to be better aligned. The `sign up` and `sign in` tabs are smaller than the entire `tab bar` so there is a gap between the bottom boarder of the entire `tab bar` and the bottom of either of the tabs.. there is a screenshot @assets\tab-bar-gap.png
- REMOVE this gap and make either the tabs bigger or the `tab bar` smaller so that the height is the same for everything

### ONBOARDING STEPS SCREEN

- **lib\screens\onboarding\onboarding_steps_screen.dart**

#### STEP 1: BASIC INFORMATION

- On step 1 of SETUP PROFILE when the user presses the `next button` this is when the user document is created using the input data from the `text fields` and the user navigates to step 2

#### STEP 2

- Because the `next button` has no functionality or navigation, i cannot get to this screen to identify any changes that need to be made. That being said, what i do know that needs to be done is the same as the first step. When the user presses the `complete button` all of the input data provided by the user needs to be written to thet user document and then navigate to step 3

#### STEP 3: PREFERENCES AND FEEDBACK

- Because the `next button` has no functionality or navigation, i cannot get to this screen to identify any changes that need to be made. That being said, what i do know that needs to be done is the same as the two previous steps. When the user presses the `next button` all of the input data provided by the user needs to be written to thet user document and then navigate to the `home screen`

## HOME SCREEN

- **lib\screens\storm\home_screen.dart**

- There needs to be a text/font formatter wrapper for all cards, containers, overlays, dialog popups, etc to ensure absolute consistency displayed to the users regardless of what means, the user will always be presented with proper and consistant formatting.
- This formatting will be `Title Case`.
- We need to clean-up what is shown on the job cards provided there are prospects.This bleeds over to the "Jobs Screen"

- *Quick Actions*

- ADD two `dummy containers` or `placeholders` for future use

- *Suggested Jobs*

- REMOVE all colored font from all cards, containers, and or dialog popups. This includes the grey tint behind and around the local number of the job cards.

## JOB SCREEN

- **lib\screens\storm\jobs_screen.dart**

- REMOVE all colored font from all cards, containers, and or dialog popups. This includes the grey tint behind and around the local number of the job cards.
- For the `job cards` on this screen... I'd like to have the same copper divider seperating the `local number`/`classification` and the rest of the values.
- The cards need to be more evenly spaced out.
- EVERYTHING MUST FOLLOW A STRICT ADHERENCE TO DATA FLOWS FROM LEFT TO RIGHT FIRST, THEN FROM TOP TO BOTTOM. IN THE CASE OF THE `RICH TEXT WIDGETS``SPAN1` WILL BE BOLD AND THE HARDCODED VALUE ENDING WITH ": ". WHILE `SPAN2` WILL BE THE REGULAR STYLE FONT AND WEIGHT BUT WILL BE THE ACTUAL BACKENDQUERY VALUE. SO, THE EXAMPLE `RICH TEXT WIDGET` GOES AS FOLLOWS... "LOCAL: "[111]
- It is important to have the semicolon and space between the two spans. This ensures that the users will be able to see and understand the values being presented.
- ***ALL DATA MUST AND ONLY WILL FLOW FROM LEFT TO RIGHT ON THE JOB CARDS. THERE WILL BY NO MEANS BE `SPAN1` ABOVE `SPAN2`. IF WE HAVE TO CHANGE THE FONT SIZE AND WEIGHTS, THEN WE WILL***
- I must get better with the formatting, word matching, word mapping, something. We cannot have `job cards` where half of the data is "N/A". Or even worse, it's N/A or something in the card, but something completely different in the dialog popup.

## STORM SCREEN

- **lib\screens\storm\storm_screen.dart**

- We're going to remove the `current storm activity` section I don't need any of that I don't none of it is useful
- We're also going to remove the `active storm events` section
- Need to button up the Storm contractors card company card or container whichever it is so that we can get some companies on this screen
- I want to implement the `poweroutage.us` API and custom widgets as a full time widget in API however with a toggle switch or something to minimize it like an accordion or something so that way at any given time a user can easily see you know how many outages are in Ohio and then very quickly look to see how many outages are in Michigan or New York or Texas I'm not quite sure how far down the rabbit hole I'll go with the outages as far as counties and utilities and uh customers and things like that there's a lot that you can get from `poweroutage.us` I know that I'll start with the States and I know that I'll start with the utilities
- Again we need to change the color of the `emergency work available` container that has the `View live weather radar` button to match this at color scheme there's nothing about this apps color scheme `app theme` or system designer `app design` that is orange and yellow.
- Somehow I'd like to get or build the foundation for real time current Emergency declaration videos or news clips from The Local news channel about the weather but just set up the foundation to upload and view videos This is not going to be a user feature This is going to be like an admin feature like only me it's Really all I need is a place cut out and the script with commented out code or placeholders or the video player widget and whatever else is required to play videos in the map and that's it I don't want any AI coding assistant to take this out of context and take it out and get out of hand and start coding all kinds of crazy crap

## TAILBOARD SCREEN

- **lib\features\crews\screens\tailboard_screen.dart**

- Once a user joins a crew or creates a crew then it can be assumed that that user will be active with the crew from this point forward therefore the welcome to the tail board heading and the description below will be removed and replaced with a lower profile header of the name of the active crew with that crew's description underneath just in smaller text and font So There is more room Or the tab bar and the messages below it
- When you're on the till board screen and you turn the phone horizontally there is an overflow error.

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

- As far as the local screen I'm pretty much done with it I mean it looks good and I'm not fooling with it I mess it up so that screen is done.

## SETTINGS SCREEN

- **lib\screens\storm\settings_screen.dart**

- When i am in edit mode in the settings, if try to upload an image from my gallery, when i press upload or okay or whatever the button is called to upload the image, the entire app crashes.
- When I press the `edit profile button` in the settings screen  I get an error "Error loading data 'init' is not a sub type of "string"
- Change the main container at the top of the settings screen to reflect a more personal vibe or connection with the user by displaying their ticket number, their name and a random but catcthy expression,something, anything....as long as it is different than what it is now.

### PROFILE SCREEN

- At the top of the screen, i guess the header or maybe it could be part of the `app bar`, You need to remove the user's email and replace it with thier name or something else. Underneath that in copper is "IBEW Local 296" for example. That entire expression needs to be replaced with a `rich text widget` and formatted like so"IBEW Local: " [localNumber]
- You need to implement or activate to tool tips again to better explain to users how to edit thier profiles.

#### PROFESSIONAL TAB

- For the `Books on` `text field` remove the hint text in the center of the text field and replace it with actual local number like.. REMOVE 'Book 1', 'Book 2' and replace it with 84, 222, 111, 1249, 71. I feel like user would better understand what it is that we are asking of them.
