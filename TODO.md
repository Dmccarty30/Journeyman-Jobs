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

* **REMOVE**

1. The `FAB` For the demo Screen
2. The second `Notification Badge` that is underneath the `App Bar`
3. `Find Jobs` button in the quick action section

* **MODIFY**

1. The `job card` need to have "STANDARD" removed from the top right corner of every `card`
2. The `job card` need to have the hard coded "$" and "Day" removed
3. The `job card` needs to be formatted with `Rich Text` widgets. `Span 1` will be, for example "Local:", then `span 2` will be the actual value queried from the backend. For example "111" so it will look like "Local": "111", "Classification": "Journeyman Lineman", "Per Diem": "$100". Where the first span is the hardcoded description and the second span is the actual value from the document. The `card` should look like C:\Users\david\Desktop\Journeyman-Jobs\assets\images\job-card.png

* **ADD**

1. When the user clicks on the `job card` the same `Dialog Popup` that appears when a user clicks on the `job card` on the `Jobs Screen` will appear. This promotes consistancy throughout the app.
2. The `Dialog Popup` design and layout will reflect "C:\Users\david\Desktop\Journeyman-Jobs\lib\design_system\popup_theme.dart"

## JOB SCREEN

* **REMOVE**

1. The `Search` and `Filter` buttons to the right of *Job Opportunities* in the `App Bar`
2. The `FAB` that refreshes the screen and make it to where the user pulls down to refresh the screen.

* **MODIFY**

1. The `Job Card` look exactly like "C:\Users\david\Desktop\Journeyman-Jobs\assets\images\jobs-card-layout.png". Where there are two(2) `columns` each with five(5) `rows`. In each `row` there will be a leading `icon` related to the data in that row. `Rich Text` where `span 1` will be a constant and hardcoded like "Local:" and `span 2`, the value inside of the brackets will be the actual value from the backend query.
2. In between the two columns there will be a `line segment` or `divider` to break up the `card` a little bit
3. The `Details Button` will be the navy blue color and when pressed wil display the `Dialog Popup` containing all of the data for that job and the `Bid Button` will be the copper color and be inactive for the time being.
4. The `Dialog Popup` design and layout will reflect "C:\Users\david\Desktop\Journeyman-Jobs\lib\design_system\popup_theme.dart"

* **ADD**

1. A copper icon to the left of "Job Opportunities" in the `App Bar`
2. `Search` and `Filter` functions just below the `App Bar`
3. The copper boarder and shadow to the card that is consistant with the `app theme`
4. If the value isn't available from the backend query simple show "N/A".

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

* **REMOVE**

1. 
2. 
3. 

* **MODIFY**

1. 
2. 
3. 

* **ADD**

1. 
2. 
3. 

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

##### TOOLS

##### LINKS

#### SEND FEEDBACK

### APP

#### NOTIFICATIONS

#### PRIVACY AND SECURITY

#### ABOUT
