
---
---

# APP WIDE CHANGES

- Integrate a custom model(Local of course) that will summarize the job data for each job, provide suggestions or feedback in real-time to the user about other users experiences, opinions, successes with the same job or related(this is where the suggestions come in). If one user is communicating to the custom model about their experience with a certain company, local, region, etc. then the custom model can provide that as feedback or suggestive to either take the job, or not, then provide either a better fitting job for that specific user or a closely related job to the original inquiry

- I want this custom model to be able to take action for the user such as change settings, update preferences, send messages or notifications to the user. For example, if a user wants to change their job preferences to reflect $200 a day in per diem jobs, then the custom model needs to be able to update the preferences, query firestore for matching jobs, then provide the new jobs to that user via notification or direct message. These capabilities are reserved for paying customers only. non-subscribers can only chat with the custom model.

---

# ONBOARDING SCREENS

- The app open and starts in `dark mode` for onboarding but is light mode once authed. need to double check for consistency. it needs to be either light or dark for every screen throughout the app.

## AUTH SCREEN

- Be sure to add the copper boarder to every `text field` for both the `signup` and the `signin` tabs.

- I want to change the `tab bar` on the [[auth_screen]] with this upgraded and enhanced `tab bar` in this file "guide\tab-bar-enhancement.md". Be sure to maintain all of the original functionality of the existing `tab bar` simply change the UI to this enhanced version.
- The border around the `signup`/`signin` `tab bar` is bigger than the `tab bar`. Or something like that. there is a small gap between the bottom of the two `signup`/`signin` tabs and the border around the entire `tab bar`

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
In the `Quick Action` section this is where we need to have the link to the `electrical calculator` as well as the view crews All of this should be under the `Quick Action` section There need not be independent active crew section nor independent electrical calculations for calculators. Both of them comment more or less are all best suited to fall under the `Quick Actions` section.
- *Suggested Jobs*
This section displays the best fitting and criteria fitting jobs set by the user during onboarding. The `job Cards` are a condensed version, only showing the top relevant job data, like the `Per Diem`, `hours`, `Rate`, and `conditions`. Once the user presses on one of the cards, then a detailed popup will appear containing all of the job posting data.

---

# JOB SCREEN

- The `job cards` need to be enhanced with it's own unique theme. Like money, paychecks, ovetime, doing work, dragging, travelling, 'Per Diem' "Book 2"
- To the job screen When I click on the `notification badge` or icon in the app bar I navigate to the correct correct page which is the [[notifications settings screen]] where there are two tabs one are for notifications and one are for settings that is the correct and only notification and or [[settings screen]] or page that this app will have.
- Underneath the `app bar` above the `scrollable list view` there is a sort or filter function horizontal scroll with multiple `choice chips` is what it looks like to me with all jobs set as the default.
- Whenever I press or select on the next choice chip which is journeyman lineman then I get this error.
- Other than the sort and filter function underneath the `app bar` whenever I press on the details button for any given jobs card the jobs dialog pop up that appears seems to be in order and functionable however there is room or opportunity

---

# STORM SCREEN

- ***I WANT FOR THE STORM SCREEN TO HAVE ITS OWN UNIQUE VIBE, FLOW, FEELING. IT'S OWN ANIMATIONS, SOUNDS, ICONS, INTERACTIONS. I WANT IT TO FEEL ENERGETIC AND ATTENTION GETTING.***

- `**App Bar**`: On the `app bar` the `notification badge` needs to navigate to the [[notifications settings screen]], not activate storm notifications. There is a setting for that in the [[notifications settings screen]].
  - The color of the `app bar` is off. it needs to be a solid primary navy blue color

- The entire screen needs to follow the apps design theme and use the apps custom themed components

- *Fix* the `Storm Contractors section`. The contractors data is located here: "docs\storm_roster.json" and a new "JJ" component needs to be created to display the data. It needs to be interactive so the users can click on the website, phone, email and have their devices react.

**Storm Contractors**

- In this section there will be a `list view`, or page view of all of the storm contractors and there basic contact information. Just like the rest of the app, once you click not eh `contractor's card` a popup or overlay will appear with more detail. From here you can click on a hyperlink, maps icon, or phone icon to have the users native device open the appropriate app to contact them.

**Storm Stats**

- This is where the user keeps track of the storms that they have been on that year. Using the `storm track form`user can keep track of the
  - contractor
  - utility,
  - the local
  - location
  - duration
  - storm type
  - pay
  - hours
  - travel/completion compensation
- User can quickly see their storm stats using an interactive tool to help then calculate different values based off of the user's wants/needs.

**HOW IT WORKS**

The user will be prompted to complete a simple form:

### Storm Track Form

```dart

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../design_system/app_theme.dart';
import '../../../design_system/components/reusable_components.dart';
import '../../../models/storm_track.dart';
import '../../../services/storm_tracking_service.dart';

class StormTrackForm extends StatefulWidget {
  final StormTrack? track;
  final ScrollController scrollController;

  const StormTrackForm({
    super.key,
    this.track,
    required this.scrollController,
  });

  @override
  State<StormTrackForm> createState() => _StormTrackFormState();
}

class _StormTrackFormState extends State<StormTrackForm> {
  final _formKey = GlobalKey<FormState>();
  final _trackingService = StormTrackingService();

  late TextEditingController _contractorController;
  late TextEditingController _utilityController;
  late TextEditingController _stormTypeController;
  late TextEditingController _payRateController;
  late TextEditingController _perDiemController;
  late TextEditingController _workingHoursController;
  late TextEditingController _hoursWorkedController;
  late TextEditingController _mobilizationHoursController;
  late TextEditingController _demobilizationHoursController;
  late TextEditingController _travelReimbursementController;
  late TextEditingController _completionBonusController;
  late TextEditingController _conditionsController;
  late TextEditingController _notesController;

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final track = widget.track;
    _contractorController = TextEditingController(text: track?.contractor);
    _utilityController = TextEditingController(text: track?.utility);
    _stormTypeController = TextEditingController(text: track?.stormType);
    _payRateController =
        TextEditingController(text: track?.payRate.toString() ?? '');
    _perDiemController =
        TextEditingController(text: track?.perDiem.toString() ?? '');
    _workingHoursController =
        TextEditingController(text: track?.workingHours.toString() ?? '');
    _hoursWorkedController =
        TextEditingController(text: track?.hoursWorked.toString() ?? '');
    _mobilizationHoursController =
        TextEditingController(text: track?.mobilizationHours.toString() ?? '');
    _demobilizationHoursController = TextEditingController(
        text: track?.demobilizationHours.toString() ?? '');
    _travelReimbursementController = TextEditingController(
        text: track?.travelReimbursement.toString() ?? '');
    _completionBonusController =
        TextEditingController(text: track?.completionBonus.toString() ?? '');
    _conditionsController = TextEditingController(text: track?.conditions);
    _notesController = TextEditingController(text: track?.notes);

    if (track != null) {
      _startDate = track.startDate;
      _endDate = track.endDate;
    }
  }

  @override
  void dispose() {
    _contractorController.dispose();
    _utilityController.dispose();
    _stormTypeController.dispose();
    _payRateController.dispose();
    _perDiemController.dispose();
    _workingHoursController.dispose();
    _hoursWorkedController.dispose();
    _mobilizationHoursController.dispose();
    _demobilizationHoursController.dispose();
    _travelReimbursementController.dispose();
    _completionBonusController.dispose();
    _conditionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveTrack() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final track = StormTrack(
        id: widget.track?.id ?? '',
        userId: '', // Service handles this
        startDate: _startDate,
        endDate: _endDate,
        contractor: _contractorController.text,
        utility: _utilityController.text,
        stormType: _stormTypeController.text,
        payRate: double.tryParse(_payRateController.text) ?? 0.0,
        perDiem: double.tryParse(_perDiemController.text) ?? 0.0,
        workingHours: double.tryParse(_workingHoursController.text) ?? 0.0,
        hoursWorked: double.tryParse(_hoursWorkedController.text) ?? 0.0,
        mobilizationHours:
            double.tryParse(_mobilizationHoursController.text) ?? 0.0,
        demobilizationHours:
            double.tryParse(_demobilizationHoursController.text) ?? 0.0,
        travelReimbursement:
            double.tryParse(_travelReimbursementController.text) ?? 0.0,
        completionBonus:
            double.tryParse(_completionBonusController.text) ?? 0.0,
        conditions: _conditionsController.text,
        notes: _notesController.text,
      );

      if (widget.track == null) {
        await _trackingService.addStormTrack(track);
      } else {
        await _trackingService.updateStormTrack(track);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving track: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: AppTheme.spacingMd),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.track == null ? 'Add Storm Track' : 'Edit Storm Track',
                style: AppTheme.headlineSmall,
              ),
              if (widget.track != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppTheme.errorRed),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Track'),
                        content: const Text(
                            'Are you sure you want to delete this storm track?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete',
                                style: TextStyle(color: AppTheme.errorRed)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && mounted) {
                      await _trackingService.deleteStormTrack(widget.track!.id);
                      if (mounted) Navigator.pop(context);
                    }
                  },
                ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(
                          'Start Date',
                          _startDate,
                          () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: _buildDatePicker(
                          'End Date',
                          _endDate,
                          () => _selectDate(context, false),
                          placeholder: 'Ongoing',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  // Contractor & Utility
                  JJTextField(
                    controller: _contractorController,
                    label: 'Contractor',
                    hintText: 'e.g. Pike, Quanta',
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  JJTextField(
                    controller: _utilityController,
                    label: 'Utility',
                    hintText: 'e.g. FPL, Duke',
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  JJTextField(
                    controller: _stormTypeController,
                    label: 'Storm Type',
                    hintText: 'e.g. Hurricane, Ice Storm',
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Financials
                  _buildSectionHeader('Financials'),
                  Row(
                    children: [
                      Expanded(
                        child: JJTextField(
                          controller: _payRateController,
                          label: 'Base Pay Rate (\$/hr)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: JJTextField(
                          controller: _perDiemController,
                          label: 'Per Diem (\$/day)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Hours Breakdown
                  _buildSectionHeader('Hours Breakdown'),
                  JJTextField(
                    controller: _mobilizationHoursController,
                    label: 'Mobilization Hours (2x)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  JJTextField(
                    controller: _workingHoursController,
                    label: 'Working Hours (2x)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  JJTextField(
                    controller: _demobilizationHoursController,
                    label: 'De-mobilization Hours (1.5x)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Bonuses & Reimbursements
                  _buildSectionHeader('Bonuses & Reimbursements'),
                  JJTextField(
                    controller: _travelReimbursementController,
                    label: 'Travel Reimbursement',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  JJTextField(
                    controller: _completionBonusController,
                    label: 'Storm Completion Bonus',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  // Details
                  _buildSectionHeader('Details'),
                  JJTextField(
                    controller: _conditionsController,
                    label: 'Conditions',
                    hintText: 'e.g. Flooded, Icy',
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  JJTextField(
                    controller: _notesController,
                    label: 'Notes',
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppTheme.spacingXl),

                  JJPrimaryButton(
                    text: 'Save Track',
                    onPressed: _isSaving ? null : _saveTrack,
                    isLoading: _isSaving,
                    isFullWidth: true,
                    variant: JJButtonVariant.primary,
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Text(
        title,
        style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryNavy),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap,
      {String? placeholder}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXs),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.borderLight),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  date != null
                      ? DateFormat('MMM d, y').format(date)
                      : (placeholder ?? 'Select Date'),
                  style: AppTheme.bodyMedium.copyWith(
                    color: date != null
                        ? AppTheme.textPrimary
                        : AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


```

---

---

Then during the storm they can either keep track of their time, hours, locations, etc. or they can set up constants which will allow them to simply select the utility, the local start date, completion date, and if there travel or completion compensation, and based off of the data that we have stored we will be able to calculate their potential earnings.

**STATS SUMMARIES**

We will provide comprehensive storm stat summaries with all o fthe data provided by the user

**FEEDBACK**

After each storm the user will be able to provide feedback about their experience wit this feature. what they liked, didn't like. This give us the opportunity to hear what are users are saying and make adjustments accordingly.

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

This is a filter to filter and display only the posts that you have submitted

- **Sort**

You can sort between dates, most populat, most liked, etc.

- **History**

### JOBS TAB

![[jobs-tab 1.png]]

#### JOBS TAB ACTION HANDLERS

- **Construction**

You can set the `Construction Type` to filter the displayed jobs from

- **Local**

You can filter any `local` from the displayed jobs from

- **Classification**

### CHAT TAB

![[chat-tab.png]]

#### CHAT TAB ACTION HANDLERS

- **Channels**

This is where the user can set the channel or chat to partici

- **DM's**

This is where the user can send direct messages to other crew members or user's

- **History**

### MEMBERS TAB

![[members-tab.png]]

#### MEMBERS TAB ACTION HANDLERS

- **Roster**

- **Availability**

- **Roles**

---

# LOCALS SCREEN

- **State Filter Function**: The state filter function just underneath the app bar on the locals screen is none functional. *Remove* it.

---

# SETTINGS SCREEN

****BEFORE STARTING WORK ON THE SETTINGS SCREEN. CREATE A NEW BRANCH OR WORKTREE****

- [[settings screen]]: On the [[settings screen]], the `electrical circuit background`needs to be applied.

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
- We will replace the `settings tab` with a `preference tab` where the user will  be able to set or change any job preferences

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
I need to implement a processes to download the user's data. This doesn't do anything when pressed
- **Delete My Account**
I need to implement a processes to delete the users account. This doesn't do anything when pressed

##### SUPPORT AND ABOUT

- *Help and Support*
When finalized, this will navigate the user to the [[help support screen]]
- *Terms of service*
I need to compose the `Journeyman Jobs` terms of service. This doesn't do anything when pressed
- *Privacy policy*
I need to compose the `Journeyman Jobs` privacy policy. This doesn't do anything when pressed

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
- **For some reason a screen was created for each of the topics in the `apps section`. THIS IS WRONG. I DO `*NOT*` WANT THIS.. THAT IS OVERKILL. THIS SHOULD ONLY BE A SINGLE SCREEN WITH EACH SECTION BEING A SCREEN OVERLAY SIMILAR TO A TAB BAR BUT HORIZONTAL.. MAYBE. REGARDLESS, I DO NOT WANT 47 SCREENS LIKE I DO NOW, WHEN MULTIPLE SCREENS CAN BE COMBINED USING AN OVERLAY. IN FACT, THAT IS HOW I WANT ALL OF THE SECTIONS IN THE [[SETTINGS SCREEN]]. MOST ARE ALREADY FORMATTED THIS WAY BUT I KNOW THAT THERE ARE A FEW THAT ARE NOT AND HAVE A SEPERATE SCREEN FOR EACH.**
-

### SETTINGS SCREEN

#### APPEARANCE AND DISPLAY

- **Dark Mode**

This `toggle switch` allows the user to switch between `light mode` and `dark mode`

- **High Contrast**

This `toggle switch` allows the user to switch between `high contrast mode` and `normal mode`

<span style="background:#d3f8b6">- **Electrical Effects**</span>

This `toggle switch` allows the user activate all of the `electrical effects` or deactivate the effects for a simplistic and normal experienced.

- **Font Size**

This `toggle switch` allows the user to switch between `light mode` and `dark mode`

#### DATA AND STORAGE

- **Offline Mode**

Implement an offline mode with minimal activity

- **Auto-Download**

Create and implement this `auto-download` feature

- **WIFI-Only Downloads**

Create and implement this `WIFI-only download` feature

- **Clear Cache**

Create a `ClearCache` function

#### LANGAUGE AND REGION

#### STORM WORK SETTINGS

#### ABOUT

### NOTIFICATION SETTINGS SCREEN

- `notification tab`: On the [[notifications settings screen]], the `electrical circuit background` needs to be applied.

- **[[notifications settings screen]]**: On the `notification settings screen`, the electrical circuit background needs to be applied.
- We need to integrate the JJBreaker_switch or another "JJ" themed boolean/switch to replace the generic toggle switches
- The `electrical background` that you have integrated into this screen is the dark mode version. I need for you to change it as whatever the user has set because as of right now some screens are dark mode and some are light mode
-

### PRIVACY AND SECURITY SCREEN

- Most of the content for this screen is in the [[app settings screen]], found in the `Account Screen` under the `settings tab`. Be sure to transfer all of the relatable content from that file to this file

### ABOUT SCREEN

---

---
