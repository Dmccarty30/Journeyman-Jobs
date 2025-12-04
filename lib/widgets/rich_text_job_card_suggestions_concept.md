# Conceptual Integration: Suggestion Previews in `RichTextJobCard`

This document outlines a conceptual approach for integrating AI-powered job suggestion previews into the `RichTextJobCard` widget. The goal is to display relevant suggestions when a user hovers over (or long-presses) a job card, without disrupting the main job listing flow.

## 1. Data Source for Suggestions

* **Provider**: The `JobSuggestion` data will be fetched via a Riverpod provider, likely one that depends on the `jobRecommendationProvider` or a similar mechanism that provides context-aware suggestions (e.g., suggestions related to the currently viewed job, or personalized top suggestions).
* **Dependency**: The `RichTextJobCard` (or its parent widget) would need to `watch` or `read` this provider to have access to the `JobSuggestion` objects.

## 2. Triggering the Preview (Hover/Long-Press)

### For Web/Desktop (Hover State)

* **Widget**: Wrap the `RichTextJobCard` with a `MouseRegion` widget.
* **Detection**: Use `onEnter` and `onExit` callbacks of `MouseRegion` to detect when the mouse pointer enters or leaves the card area.
* **Delay**: Implement a short delay (e.g., 500ms) on `onEnter` before showing the preview to prevent accidental triggers and flickering. Cancel the delay timer on `onExit`.

### For Mobile (Long-Press Gesture)

* **Widget**: Wrap the `RichTextJobCard` with a `GestureDetector`.
* **Detection**: Use the `onLongPress` callback to trigger the display of the preview.
* **Dismissal**: The preview should dismiss when the user taps elsewhere or explicitly closes it.

## 3. Displaying the Preview UI

Several UI elements could be used for the preview:

* **`Tooltip` (Simple)**: For very brief, single-line suggestions. Limited customizability.
* **`OverlayEntry` (Flexible)**: Provides maximum flexibility to build a custom, rich overlay widget that appears directly above the card.
  * **Content**: Could include a mini `JobSuggestionCard` (or a simplified version of it), highlighting key differences or benefits.
  * **Positioning**: Position the overlay relative to the `RichTextJobCard`.
* **Expanded Section (Inline)**: A small, collapsible section within the `RichTextJobCard` itself that expands to show suggestions.
  * **Interaction**: Triggered by a small icon or a dedicated "Show Suggestions" button.

### Proposed UI for Preview

Using `OverlayEntry` for a custom, non-intrusive popup:

* **Appearance**: A small, themed card (similar to `JobSuggestionCard` but more compact) with a distinct background (e.g., a slightly translucent copper gradient or electric blue).
* **Content**:
  * "AI Suggestion:" header.
  * **Suggested Job Title/Company**: From `JobSuggestion.suggestedJobId` (or more details if available via `Job` model lookup).
  * **Reason**: `JobSuggestion.reason`.
  * **Key Differentiator**: Briefly highlight why this job is better (e.g., "+ \$5/hr", "closer commute").
  * Small action buttons: "View Details" (navigates to suggested job) and "Dismiss".

## 4. Integration Steps (Conceptual Code Flow)

1. **Parent Widget (`JobsScreen` or a dedicated `JobCardWrapper`):**
    * `watch` `jobRecommendationProvider` for relevant suggestions.
    * Pass `JobSuggestion` data down to `RichTextJobCard` if available and relevant for that specific job.
2. **`RichTextJobCard` Modifications:**
    * Add a `JobSuggestion? suggestion` property.
    * Wrap its `Container` with `MouseRegion` (for web) or `GestureDetector` (for mobile).
    * Implement logic in `onEnter`/`onLongPress` to:
        * Check if `suggestion` is not null.
        * Create and insert an `OverlayEntry` with the preview UI.
    * Implement logic in `onExit`/`onTapOutside` (for `OverlayEntry`) to remove the `OverlayEntry`.
    * Ensure the preview doesn't interfere with existing `onDetails` or `onBid` actions.

This conceptual design provides a foundation for the future implementation of interactive job suggestion previews.
