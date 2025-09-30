# TODO

## APP WIDE CHANGES

- ALL backgrounds are to be the 'high' density electrical circuit back ground exactly as the jobs screen background is.

- I need some sort of wrapper to apply to the text and format of what is shown on the job cards. Not all jobs in firestore are the exact same format. Fore example some classifications are "Journeyman-Lineman" some are "journeyman_lineman", etc. I need for everything to be consistent using `Title Case`.
- Search the \lib directory recursively for any instance of a toast widget or snack bar and ensure that they follow these designs `lib\electrical_components\jj_electrical_toast.dart` and `lib\electrical_components\jj_electrical_theme.dart`

## ONBOARDING SCREENS

- Step one of three `setup profile screen` make the city `text field` its own row. and move the state `dropdown` and zipcode `text field` below the city `text field` because there isnt enought room to see the entire user input so they can see if they may have made an typo or error.

## HOME SCREEN

- *Quick Actions*

- *Suggested Jobs*

- ***When the user presses on a job card i need for the dialog popup to be formatted exactly like lib\widgets\dialogs\job_details_dialog.dart. There must be consistancy throughout the entire app.***

## JOB SCREEN

- INCREASE the font size of the cards by 10%

## STORM SCREEN

- CREATE a new card called `contractor_card`. The card will have the exact same format as lib\widgets\rich_text_job_card.dart. Except the data will be pulled from a new fire store collection that has yet been created however the data from docs\storm_roster.json Will be the data written to this new collection so you can go ahead and format the span one Of each rich rich text according to the Storm roster. json file and Populate the rest of the card with dummy data. Also create this card as an independent component not directly written into the Storm screen
- ADD `Contractors` section with a list view for `contractor cards`

## TAILBOARD SCREEN

## CREATE CREWS SCREEN

- Also that snack bar does not follow the consistent At for these widgets. All of the snack bars and all of the Toasts widgets must follow the electrical component widgets from the lib\electrical_components\jj_electrical_theme.dart and lib\electrical_components\jj_electrical_toast.dart files

## LOCALS SCREEN

## SETTINGS SCREEN
