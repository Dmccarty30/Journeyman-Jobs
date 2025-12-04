# QA/QC Methodology: AI Action Automation User Flow Testing

This document outlines a conceptual methodology for Quality Assurance and Quality Control (QA/QC) of user flows involving AI action automation, particularly focusing on subscription gating and rate limiting.

## 1. Objectives

*   Verify that subscription-gated AI features are correctly restricted to pro users.
*   Ensure that AI-triggered actions (e.g., notifications, message composition) function as intended.
*   Confirm that rate-limiting mechanisms prevent abuse of AI services without blocking legitimate usage.
*   Validate the end-to-end user experience for AI-enhanced interactions.

## 2. Test Scenarios and User Journeys

### 2.1. Subscription Gating Scenarios

*   **Non-Pro User Attempts AI-Gated Feature**:
    *   **Scenario**: User without active subscription attempts to access a pro-only AI feature (e.g., requesting an AI job recommendation).
    *   **Expected**: Feature is inaccessible, a clear message indicating pro-status requirement is displayed. No backend AI action is triggered.
*   **Pro User Accesses AI-Gated Feature**:
    *   **Scenario**: User with an active subscription successfully accesses a pro-only AI feature.
    *   **Expected**: Feature functions correctly.
*   **Subscription Expiration/Cancellation**:
    *   **Scenario**: User's subscription expires or is cancelled while attempting to use a pro-only feature.
    *   **Expected**: Access is revoked, and the user is gracefully informed.

### 2.2. AI-Triggered Action Scenarios

*   **Real-time Job Matching Notification**:
    *   **Scenario**: New jobs are loaded that match a pro user's preferences, triggering the AI job recommendation system.
    *   **Expected**: A notification dialog (e.g., `AiRecommendationDialog`) appears with the suggested job details. User can interact with the dialog.
*   **Direct Message Composition from Suggestion**:
    *   **Scenario**: Pro user initiates "compose message from AI suggestion" action.
    *   **Expected**: Message composition interface is pre-filled with relevant AI suggestion details. The message is sent successfully to the chat system.

### 2.3. Rate Limiting Scenarios

*   **Legitimate Usage within Limits**:
    *   **Scenario**: Pro user triggers an AI action (e.g., asks for a new AI recommendation) multiple times, staying within the defined rate limit (e.g., 5 requests per minute).
    *   **Expected**: All requests are processed successfully.
*   **Exceeding Rate Limit**:
    *   **Scenario**: Pro user triggers an AI action more times than allowed within the time window.
    *   **Expected**: Subsequent requests are blocked. A clear message informs the user they are rate-limited and when they can retry. No backend AI action is triggered for blocked requests.
*   **Rate Limit Reset**:
    *   **Scenario**: User exceeds limit, then waits for the rate limit window to pass.
    *   **Expected**: User can successfully trigger the AI action again.

## 3. Verification Steps

*   **UI/UX**: Check for correct display of messages, dialogs, and button states.
*   **Backend Interaction**: Monitor Firebase logs (Firestore, Cloud Functions) to confirm that API calls are made/blocked as expected.
*   **Data Integrity**: Verify that data (e.g., feedback, rate limit records) is correctly written to/read from Firestore.
*   **Notifications**: Ensure local notifications are triggered (if using `flutter_local_notifications`).

## 4. Test Data Setup

*   **User Profiles**: Create test users with varying subscription statuses (pro, non-pro, expired).
*   **User Preferences**: Define diverse sets of user preferences for job matching.
*   **Job Data**: Populate Firestore with various job postings, some matching preferences, some not.
*   **Rate Limit Records**: Manually inject `rate_limits` documents into Firestore to simulate exceeded limits.

## 5. Automation Strategy

*   **Integration Tests**: Use Flutter's `integration_test` framework to simulate complex user journeys across UI and backend.
*   **Widget Tests**: For individual UI components (e.g., `AiRecommendationDialog`), verify correct rendering and interaction.
*   **Unit Tests**: For `SubscriptionService`, `ProActionVerificationService`, `RateLimitingService`, and `JobsNotifier` methods, ensure core logic functions correctly.
*   **Mocking**: Use `mockito` or `mocktail` to mock Firebase dependencies and other services during testing to isolate units.
*   **CI/CD Integration**: Automate execution of integration tests in the CI/CD pipeline to prevent regressions.
