# TODO

I am going screen by screen, calling out any and all issues, errors, inconsistancies, problems, potential problems, misalignments,....... What ever i can find so we can fix it, hopefully for the last time.

## APP WIDE

* **All CARDS**

1. Whether it be the `job card` the `locals card` or any other `card` that may be added in the future WILL and MUST follow the same design and layout format.
2. Which will consist of x amount of `columns` with x amount of `rows` inside of each `column`.
3. Inside each `row` there will be from left to right, an `icon` then a `rich text` widget.
4. Where `span 1` will be in bold font, a hardcoded value ending with ": ".
5. `Span 2` will be the backend query value.
6. In between each `column` there will be a `line segment` or `divider` to add a little more design to the `card` as well as make each `column` easily identifiable.

* **ALL DIALOG POPUPS**

1. All `Dialog Popups` that may be added in the future WILL and MUST follow the same design and layout format.
2. The format will follow "C:\Users\david\Desktop\Journeyman-Jobs\lib\design_system\popup_theme.dart"

## HOME SCREEN

1. Be sure to follow the app theme when modifying this screen. The theme ***MUST*** be consistent throughout the entire app. So make sure thet the borders are copper and the correct thickness. The animations are applied and correct as far as when pressing a button, it should spark. The toasts and snack bars are all correct and consistant.

* **APP BAR**

1. Center 'Journeyman Jobs' text in the `app bar`.

* **QUICK ACTION**

1. Add `Transformer Workbench` to `Quick Action`.

* **JOBS CARD**

1. Add copper border around each `condensed card`.
2. Clean-up the data on the `condensed card`. Move `Wages` From R1C3 to R2C2.
3. Enforce that each row in each column is formatted from left to right, `icon`, `span1`(BOLD), `span2`(REGULAR).
4. Remove color text
5. Remove highlighted background from `locals`
6. Add `span1`: 'Classification'
7. Add vertical line divider in between each column

* **DIALOG POPUP**

1. Increase font text size by 2.
2. Remove colored text

## JOB SCREEN

* **APP BAR**

1. Center 'Job Opportunity' text in the `app bar`.

* **JOBS CARD**

1. Complete `Bid Now` Button. (Automate form submition at the locals job board)
2. Apply JJ app theme to the `snack bar` showing success after pressing the `Bid Now` Button.
3. Increase the font size by 2. The text is disporportianatly smaller than the button size
4. Remove color text
5. Remove sorting `FAB`. Use horizontall filter mechanism.
6. Relocate search `FAB` tobelow the horizontal filter and above the `job card`.
7. Add vertical line divider in between each column

* **DIALOG POPUP**

1. Increase font text size by 2.
2. Remove colored text
3. Broken action. Failed action when `Local Union` link is pressed.
4. Apply JJ app theme to `snack bar` after link is pressed
5. Add 'Contractor' to popup
6. Reorganize the text. Data flows from left to right. In the popup the backend data `span2` is below the hardcoded data `span1`
7. Remove link icon to the right of 'location' and 'local union'. The underlined and altered color is enough indication of a link.

## LOCALS SCREEN

***THE LOCALS SCREEN DOESN'T EVEN LOAD PROPERLY. THERE IS NOTHING DISPLAYED WHEN I NAVIGATE TO THE LOCALS SCREEN. BECAUSE OF THIS, I WILL BUILD OUT THE SCREEN FROM THE TOP DOWN.***

### LAYOUT

* **APP BAR**

1. Like every other screen there will be the `App Bar` with the same layout for consistancy. From laft to right, there will be a copper color `Icon` related to the locals, so a building `Icon`. 
2. A `Text` widget saying "Locals Directory"
3. Finally, the `Notifications Badge` which will have the exact functionalities as all of the other  `Notifications Badge`

* **SEARCH AND FILTER**

1. Underneath the `App Bar` there will be a `row` designated for the search and filter functions
2. Because of the shear number of locals, which is 787, give or take. The search function will simply be a `Text Field` where the user can type the local that they are looking for.
3. 

## STORM SCREEN

* **APP BAR**

1. Center 'Storm' text in the `app bar`.
2. Change left `icon` to 'hurricane' or 'tornado' `icon`

* **CURRENT STORM ACTIVITY**

1. This is where i will include the 'power outage' data.
2. Modify the 'power outage' data to be displayed at all times. updating every quarter hour.
3. Include any and all 'Severa Weather' alerts 'Watches/Warnings'
4. Need a scrolling banner type widget like what is shown on T.V. for the alerts.

* **RADAR**

1. Remove the ' Emergency Work Available' container from the top of the screen and put it below the `contractor cards`
2. Maybe add 'Severe Weather' news clips from the 'Weather Channel' in the same section as the radar.

* **CONTRACTOR CARD**

1. Increase font text size by 2.
2. Remove colored text
3. Add vertical line divider in between each column

## SETTINGS SCREEN

* **REMOVE**

1. 
2. 
3. 

* **MODIFY**

1. 
2. 
3. 

* **ADD**

1. To the left of the "Settings" `text` in the `App Bar`, add a copper color gear `icon` that resembles settings in most instances.
2. Ad the `Notification Badge` to the right of "Settings" in the `App Bar`.

### ACCOUNT

#### PROFILE SCREEN

##### PERSONAL TAB

##### PROFESSIONAL TAB

##### SETTINGS TAB

#### TRAINING AND CARTIFICATIONS

##### CERTIFICATES

##### COURSES

##### HISTORY

### SUPPORT

#### HELP AND SUPPORT

##### FAQ

##### CONTACT

##### GUIDES

#### RESOURCES

##### DOCUMENTS

###### IBEW DOCUMENTS

* **IBEW CONSTITUTION**
  
* **CODE OF EXCELLENCE**

###### SAFETY

* **NFPA 70E STANDARD**
  
* **OSHA ELECTRICAL STANDARDS**

###### TECHNICAL

* **NATIONAL ELECTRICAL CODE (NEC)**
  
* **IEEE STANDARDS**

##### TOOLS

###### CALCULATORS

###### REFERENCES

###### TRANSFORMERS

##### LINKS

###### IBEW OFFICIAL

###### TRAINING

###### SAFETY

###### GOVERNMENT

#### SEND FEEDBACK

### APP

#### NOTIFICATIONS

#### PRIVACY AND SECURITY

#### ABOUT
