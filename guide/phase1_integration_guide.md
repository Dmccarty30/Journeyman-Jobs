# Phase 1 Integration Guide: Mobbin-Inspired Components

## Overview
This guide explains how to integrate the Phase 1 enhanced components into the Journeyman Jobs app. These components are inspired by professional mobile apps from Mobbin and optimized for IBEW electrical workers.

## 🎯 Component Replacements

### 1. Job Card: `JJJobCard` → `JJEnhancedJobCard`

**Old Component Usage:**
```dart
JJJobCard(
  jobTitle: 'Transmission Line Construction',
  company: 'Pike Electric',
  location: 'Dallas, TX',
  wage: '\$52.50/hr',
  startDate: 'Nov 15',
  tags: ['Transmission', '345kV'],
  isFavorite: true,
  onFavoriteToggle: () {},
  onTap: () {},
)
```

**New Enhanced Component:**
```dart
JJEnhancedJobCard(
  // Required fields
  jobTitle: 'Transmission Line Construction',
  company: 'Pike Electric Corporation',
  location: 'Dallas, TX',
  wage: '\$52.50/hr',
  
  // New enhanced fields
  distance: '12 mi',                      // Calculated distance
  classification: 'Journeyman Lineman',   // Worker classification
  localNumber: 'Local 125',               // IBEW local
  constructionTypes: ['Transmission', '345kV'], // Work types
  positionsAvailable: 8,                  // Number of openings
  duration: '6 months',                   // Job duration
  hasPerDiem: true,                       // Per diem indicator
  
  // Updated interaction
  isSaved: true,                          // Replaces isFavorite
  onSaveToggle: () {},                    // Replaces onFavoriteToggle
  onTap: () {},
)
```

**Key Improvements:**
- ✅ Distance indicator for location-based relevance
- ✅ Classification badge for quick identification
- ✅ Local union number display
- ✅ Positions available counter
- ✅ Duration and per diem prominently shown
- ✅ Cleaner layout with better visual hierarchy

### 2. Filter Chips: `JJChip` → `JJEnhancedFilterChip`

**Old Component Usage:**
```dart
JJChip(
  label: 'Transmission',
  isSelected: true,
  onTap: () {},
)
```

**New Enhanced Component:**
```dart
JJEnhancedFilterChip(
  label: 'Transmission',
  isSelected: true,
  onTap: () {},
  
  // New optional features
  icon: Icons.bolt,        // Optional icon
  count: 24,              // Optional count indicator
)
```

**Key Improvements:**
- ✅ Professional rounded design with smooth animations
- ✅ Optional icons for visual context
- ✅ Count indicators for available jobs
- ✅ Better touch targets and visual feedback
- ✅ Shadow effects when selected

### 3. Bottom Sheet: `JJBottomSheet` → `JJEnhancedBottomSheet`

**Old Component Usage:**
```dart
JJBottomSheet.show(
  context: context,
  title: 'Filter Jobs',
  child: SingleChildScrollView(
    child: Column(
      children: [...],
    ),
  ),
);
```

**New Enhanced Component:**
```dart
JJEnhancedBottomSheet.show(
  context: context,
  title: 'Filter Jobs',
  subtitle: 'Refine your job search',
  
  // Organized sections instead of single child
  sections: [
    JJBottomSheetSection(
      title: 'Classification',
      subtitle: 'Select your worker classification',
      child: Wrap(
        children: [...],
      ),
    ),
    JJBottomSheetSection(
      title: 'Construction Type',
      child: JJFilterGroup(
        title: 'Work Types',
        children: [...],
      ),
    ),
  ],
  
  // New features
  headerAction: TextButton(...),  // Optional header action
  initialChildSize: 0.5,         // Draggable sheet sizing
  maxChildSize: 0.9,
);
```

**Key Improvements:**
- ✅ Organized sections with titles and subtitles
- ✅ Draggable sheet with smooth interactions
- ✅ Header actions for clear/apply buttons
- ✅ Better visual separation between sections
- ✅ Professional drag handle indicator

## 📱 Implementation Steps

### Step 1: Update Imports
```dart
// Add to your imports
import 'package:journeyman_jobs/design_system/components/phase1_enhanced_components.dart';
```

### Step 2: Replace Job Cards in Jobs Page

**In `jobs_page.dart`, update the StreamBuilder:**
```dart
StreamBuilder<List<JobsRecord>>(
  stream: queryJobsRecord(
    queryBuilder: (jobsRecord) => jobsRecord
        .orderBy('timestamp', descending: true),
  ),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const JJLoadingIndicator(
        message: 'Loading jobs...',
      );
    }
    
    final jobs = snapshot.data!;
    
    if (jobs.isEmpty) {
      return JJEmptyState(
        title: 'No jobs found',
        subtitle: 'Try adjusting your filters',
        icon: Icons.work_off,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        
        // Calculate distance (implement your logic)
        final distance = _calculateDistance(job.location);
        
        return JJEnhancedJobCard(
          jobTitle: job.jobTitle,
          company: job.company,
          location: job.location,
          wage: job.wage,
          distance: distance,
          classification: job.classification,
          localNumber: 'Local ${job.local}',
          startDate: job.startDate,
          constructionTypes: [job.typeOfWork],
          positionsAvailable: int.tryParse(job.numberOfJobs),
          duration: job.duration,
          hasPerDiem: job.perDiem.isNotEmpty,
          isSaved: _savedJobs.contains(job.reference.id),
          onSaveToggle: () => _toggleSavedJob(job.reference.id),
          onTap: () => _navigateToJobDetails(job),
        );
      },
    );
  },
)
```

### Step 3: Update Filter Implementation

**Create a filter bottom sheet method:**
```dart
void _showFilterBottomSheet() {
  JJEnhancedBottomSheet.show(
    context: context,
    title: 'Filter Jobs',
    subtitle: 'Refine your job search with detailed filters',
    headerAction: TextButton(
      onPressed: _clearAllFilters,
      child: Text(
        'Clear All',
        style: AppTheme.labelMedium.copyWith(
          color: AppTheme.accentCopper,
        ),
      ),
    ),
    sections: [
      // Classification Section
      JJBottomSheetSection(
        title: 'Classification',
        subtitle: 'Select your worker classification',
        child: StatefulBuilder(
          builder: (context, setState) {
            return Wrap(
              spacing: AppTheme.spacingSm,
              runSpacing: AppTheme.spacingSm,
              children: Classification.values.map((classification) {
                return JJEnhancedFilterChip(
                  label: classification.displayName,
                  icon: _getClassificationIcon(classification),
                  isSelected: _selectedClassifications.contains(classification),
                  onTap: () {
                    setState(() {
                      if (_selectedClassifications.contains(classification)) {
                        _selectedClassifications.remove(classification);
                      } else {
                        _selectedClassifications.add(classification);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
      
      // Construction Type Section
      JJBottomSheetSection(
        title: 'Construction Type',
        subtitle: 'Filter by type of electrical work',
        child: StatefulBuilder(
          builder: (context, setState) {
            return JJFilterGroup(
              title: 'Work Types',
              children: ConstructionTypes.values.map((type) {
                return JJEnhancedFilterChip(
                  label: type.displayName,
                  isSelected: _selectedConstructionTypes.contains(type),
                  onTap: () {
                    setState(() {
                      if (_selectedConstructionTypes.contains(type)) {
                        _selectedConstructionTypes.remove(type);
                      } else {
                        _selectedConstructionTypes.add(type);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
      
      // Add more sections as needed...
    ],
  );
}
```

### Step 4: Helper Methods

**Add these helper methods to support the enhanced components:**

```dart
// Calculate distance from user location
String _calculateDistance(String jobLocation) {
  // Implement your distance calculation logic
  // For now, return mock data
  final random = Random();
  return '${random.nextInt(50) + 5} mi';
}

// Get icon for classification
IconData _getClassificationIcon(Classification classification) {
  switch (classification) {
    case Classification.JourneymanLineman:
      return Icons.bolt;
    case Classification.JourneymanWireman:
      return Icons.electrical_services;
    case Classification.JourneymanElectrician:
      return Icons.power;
    case Classification.JourneymanTreeTrimmer:
      return Icons.park;
    case Classification.Operator:
      return Icons.construction;
    default:
      return Icons.work;
  }
}

// Toggle saved job
void _toggleSavedJob(String jobId) {
  setState(() {
    if (_savedJobs.contains(jobId)) {
      _savedJobs.remove(jobId);
    } else {
      _savedJobs.add(jobId);
    }
  });
  
  // Optionally save to Firebase or local storage
  _updateSavedJobsInFirebase();
}
```

## 🎨 Styling Guidelines

### Color Usage
- **Primary Navy (#1a202c)**: Headers, badges, primary text
- **Accent Copper (#b45309)**: CTAs, selected states, wage displays
- **Success Green**: Per diem indicators, positive states
- **Neutral Grays**: Borders, secondary text, unselected states

### Spacing
- Use consistent spacing from AppTheme
- Cards: `spacingLg` padding
- Between sections: `spacingXl`
- Inline elements: `spacingSm`

### Typography
- Job titles: `headlineSmall` with `fontWeight.w600`
- Company names: `bodyLarge`
- Metadata: `bodySmall` with `textLight` color
- Badges: `labelSmall` with uppercase

## 🧪 Testing Checklist

Before deploying Phase 1:

- [ ] All job cards display correctly with new fields
- [ ] Filter chips show selection states properly
- [ ] Bottom sheet is draggable and sections are organized
- [ ] Save/bookmark functionality works
- [ ] Distance calculations are accurate
- [ ] Performance is smooth with large job lists
- [ ] Accessibility: All interactive elements are reachable
- [ ] Dark mode compatibility (if applicable)

## 📊 Migration Strategy

1. **Phase 1a**: Create enhanced components alongside existing ones
2. **Phase 1b**: Test enhanced components in demo screens
3. **Phase 1c**: Gradually replace components in main screens
4. **Phase 1d**: Remove old components once migration is complete

## 🚀 Next Steps

After Phase 1 is complete:
- **Phase 2**: Integrate electrical-themed loading components
- **Phase 3**: Add custom electrical icons and animations
- **Phase 4**: Implement advanced filtering with AI-powered suggestions

---

**Note**: All enhanced components maintain backward compatibility where possible. The additional fields in `JJEnhancedJobCard` are optional, allowing for gradual data migration.
