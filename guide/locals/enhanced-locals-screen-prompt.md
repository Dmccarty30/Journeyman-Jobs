# Enhanced IBEW Locals Screen Implementation Prompt

## Overview

Implement a comprehensive directory screen for IBEW (International Brotherhood of Electrical Workers) union locals within a Flutter application. This screen serves as a centralized hub for electrical workers to find and connect with their local unions, providing essential contact information, leadership details, and meeting schedules.

## Technical Requirements

### Data Source

- Query the 'locals' Firestore collection
- Implement real-time stream updates for data changes
- Sort locals by local_union number by default
- Handle error states gracefully with retry functionality

### Core Features

#### 1. Search Functionality

- Implement real-time search filtering across multiple fields:
  - Local union number
  - City name
  - State abbreviation
  - Classification type
- Case-insensitive search with instant results
- Clear search with single tap
- Search persistence during screen lifecycle

#### 2. Main List View

- Display locals in visually appealing cards with:
  - **Header**: Local number and city/state
  - **Primary Info**: Address, phone, website, classification
  - **Visual Indicators**: Clickable items should have distinct styling
  - **Navigation Arrow**: Subtle indicator for more details
- Implement smooth scrolling with proper padding
- Add pull-to-refresh functionality
- Show loading skeleton during data fetch

#### 3. Interactive Elements

All contact information must be actionable:

- **Phone Numbers**: Launch device dialer with cleaned number format
- **Addresses**: Open native maps app with full address
- **Websites**: Launch in external browser with https:// validation
- **Email**: Open default email client with pre-filled recipient

#### 4. Detail Dialog/Modal

Comprehensive popup showing all available information:

- **Header Section**: Gradient background with local number and location
- **Contact Section**: All communication methods
- **Leadership Section**: Executive positions and names
- **Meeting Section**: Schedule and location details
- **Sign-in Section**: Procedures and requirements
- Scrollable content for smaller screens
- Close button prominently displayed

### Design Specifications

#### Color Palette (from app_theme.dart)

- **Primary Navy**: #1a202c (headers, titles)
- **Accent Copper**: #b45309 (interactive elements, CTAs)
- **Secondary Navy**: #2d3748 (subtle backgrounds)
- **Light Copper**: #d69e2e (hover states)
- **Text Colors**:
  - Dark: #2D3748 (primary text)
  - Light: #718096 (secondary text)

#### Typography

- All text must use RichText widgets with:
  - **Key** (label): Lighter color, smaller font
  - **Value**: Darker color, standard font
  - Consistent spacing between key-value pairs

#### Layout Guidelines

- Card elevation: 2dp with subtle shadow
- Border radius: 12px (radiusMd)
- Padding: 16px (spacingMd) standard
- Icon size: 16px (iconSm) for inline icons
- Consistent margins between sections

### Data Validation & Error Handling

- Check for empty/null values before display
- Provide fallback text for missing data
- Validate URLs before launching
- Handle platform-specific launching (iOS vs Android)
- Show appropriate error messages for failed actions

### Performance Optimizations

- Implement ListView.builder for efficient scrolling
- Use const constructors where possible
- Minimize widget rebuilds with proper state management
- Cache search results to reduce Firestore reads
- Implement debouncing for search input

### Accessibility Requirements

- Proper semantic labels for screen readers
- Sufficient color contrast ratios
- Touch targets minimum 44x44 pixels
- Focus indicators for keyboard navigation
- Descriptive error messages

### Platform Considerations

- Test URL launching on both iOS and Android
- Handle different map app preferences
- Ensure proper permissions for phone/email actions
- Responsive design for tablets

### Code Quality Standards

- Follow Flutter best practices and conventions
- Implement proper error boundaries
- Add comprehensive documentation
- Use meaningful variable and function names
- Separate concerns with proper widget composition

### Testing Requirements

- Unit tests for data parsing and filtering
- Widget tests for UI components
- Integration tests for Firestore queries
- Manual testing on various screen sizes
- Performance profiling for large datasets

## Implementation Notes

1. Remove any "Active" status indicators completely
2. Remove member count fields from all views
3. Ensure all clickable elements have appropriate visual feedback
4. Implement proper loading and empty states
5. Consider offline functionality with local caching
6. Add analytics tracking for user interactions
7. Implement proper dispose methods for controllers
8. Use proper null safety throughout

## Future Enhancements (Phase 2)

- Favorite locals functionality
- Distance-based sorting using device location
- Direct messaging to union officials
- Meeting reminder notifications
- Export contact to device contacts
- Share local information functionality
- Map view showing all locals
- Advanced filtering options
