# TODO

## APP WIDE CHANGES

## APP THEME

- **Dark Mode**

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

## TAILBOARD SCREEN

- **lib\features\crews\screens\tailboard_screen.dart**

### CREATE CREWS SCREEN

- **lib\features\crews\screens\create_crew_screen.dart**

- **STEP 1**

- **STEP 2**

- **SET CREW PREFERENCES**

- When I hit the save preference button I can't move any further because I'm not authorized. The error is the firststore error updating crew caller does not have permission

### JOBS

- **docs\tailboard\jobs-tab.png**

### FEED

- **docs\tailboard\feed-tab.png**

### CHAT

- **docs\tailboard\chat-tab.png**

### MEMBERS

- **docs\tailboard\members-tab.png**

## LOCALS SCREEN

- **lib\screens\storm\locals_screen.dart**

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

- ADD a container for "Union Pay Scales". and have the link icon connected to <https://unionpayscales.com/trades/ibew-linemen/>
- ADD another container for "Union Pay Scales". and have the link icon and have it set to dispay @lib\widgets\pay_scale_card.dart instead of navidating to the devices browser

- **SAFETY**

- connect NFPA to <https://www.nfpa.org/en/for-professionals/codes-and-standards/list-of-codes-and-standards#sortCriteria=%40computedproductid%20ascending%2C%40productid%20ascending&aq=%40culture%3D%22en%22&cq=%40tagtype%3D%3D(%22Standards%20Development%20Process%22)%20%20>

---

- The auth screen whenever you're signing up for an account or you put your email password and confirm your password correct the overflow associated with the Continue with Google button

- On step one of onboarding apply the app theme to the state drop down menu
- On step the hints or labels for the text fields are black they're too dark and you can't read them
- Also on step the classification choice chips I need to format the classification entitled
- Also step two the toggle switch for are you currently working needs to be set at no for default also later down the line maybe consider redesigning the toggle switch it's kind of difficult to understand if it's yes or no or on or off
- Step three of onboarding the label for the text fields it's a light Gray it's a little more legible because the background is darker but this text color needs to be changed to white for all of the widgets summer Gray and Summer black as of now
- Step three at the middle with all of the check boxes we can do better with the design add some dividers in between or do something also that container needs to have the copper border
- So whenever I completed onboarding I check my status in firebase and my user document has been created however there are several duplicate fields such as ticket number preferred locals phone number for DM updated time home local hours per week How'd you hear about US is working last act of those are all duplicates and I noticed that well there's a lot for some reason and somehow which I didn't even know this existed but there is a role field and mine has a value of electrician I don't understand how that came to be I never selected electrician for any option so need to investigate and then for the online status the value is false it should be true I don't know how that came to be either So yeah I don't understand a lot of this the duplicate How do you hear about us One of them says the quantum field was my answer and the other says dream That's crazy I don't know what that's about Duplicate home locals one value is 49 the other is 369 It does say that do you have AFCM token The duplicate books on one has the values that I listed one says null

## HOME SCREEN

- When I navigate to the home screen after onboarding it still says welcome back guest user that needs to change
- I don't understand what this power grid status container is on the home screen but that needs to be removed and I need to return the suggested jobs section because there are no jobs displayed on the home screen

## JOBS SCREEN

- I noticed that the text formatting on the jobs card on the job screen is correct with title Case however when you put details and the dialog pop up appears none of the text values are formatted as Title Case so I need to apply the Title Case formatting on the dialog box for jobs on the job screen

## STORM SCREEN

- On the storm screen still have this ridiculous format that different from every other screen in the entire app as far as the electrical circuit background it seems that the background is Gray but inside the container has the background which the container doesn't cover up the entire screen it's got padding the corners the borders of the whole this holes green needs to be reworked I'll address it later

## LOCALS SCREEN

- When I navigate to the local screen from the storm screen it says no locals found

## CREWS SCREEN

- Again when I navigate to the cruise screen I am redirected to the off screen and from here I have no other option than to either sign back in sign up or XP app I'm going to sign in and see what happens
- On the sign in screen I didn't notice before but the forgot password button needs to be reformatted It's very difficult so you can see it It's simply a clear background and a copper border However when I signed in I was successful and it brought me to the teleport screen yet there are two loading widgets on the teleport screen and nothing is happening
- And once again I've signed in twice There's no way that I have not been authenticated or been granted permission to create a crew but just as before when I click Create a crew button it says that I do not have the proper permissions or authentication

## SETTINGS SCREEN

- On the setting screen at the top it says Welcome back brother I don't understand why this is here on the settings screen this is not a landing page That makes no sense

### JOB PREFFERENCES CONTAINER

- When you click on the job preference container in the profile section of the settings screen dialog box appears in that dialog box need to correct the overflow error on the save preference button
- Need to add journeyman lineman as a classification on the job preference remove apprentice electrician Remove Master electrician remove solar systems technician Remove Instrumentation technician
- In the construction type section remove renewable energy education health care transportation and manufacturing
- Remove min minimum hourly wage from dialog box And maximum travel distance apply the AT theme toast the electrical circuit toast or snack bar that appears when you save your preferences
- ** Need to implement or add so update user document or preferences related to the user when the user presses the save preferences button because I just checked Firebase and there's nothing in the fire base collection
  