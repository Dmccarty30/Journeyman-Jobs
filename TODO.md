# TODO

## APP WIDE CHANGES

## ONBOARDING SCREENS

- **Change the backgrond of every onboarding screen to the `electrical curuit` background just like it is with every other screen in the entire app**

### AUTH SCREEN

- Be sure to add the copper boarder to every `text field` for both the `signup` and the `signin` screens.
- I want to change the 

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

- ADD the copper border around all of the `text fields` in the entire file
- Shorten the `state dropdown` by half and expand the `zip code` text field to take up the remaining space.
- The `Next Button` Does not have any action assocciated with it. When the user presses the next button this is when the user document is created 
- 

#### STEP 2

#### STEP 3 

## HOME SCREEN

- *Quick Actions*

- *Suggested Jobs*

## JOB SCREEN

## STORM SCREEN

## TAILBOARD SCREEN

### CREATE CREWS SCREEN

### MESSAGES

### FEED

### CHAT

### MEMBERS

## LOCALS SCREEN

## SETTINGS SCREEN
