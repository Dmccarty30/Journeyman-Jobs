# Provider Error Resolution Implementation Plan

## Overview

Implement critical fixes for Riverpod provider errors in the Journeyman Jobs codebase based on analysis of silent error handling patterns and missing provider functionality. This plan addresses the most critical issues identified in the provider-fix.md and provider-fix2.md reports, specifically silent error suppression and missing reaction count implementations.

## Types

Standardize error handling across Riverpod providers using AsyncValue where appropriate. Define consistent error propagation patterns with user feedback integration.

Error state management will include:

- Global error state notifier
- User-friendly error messages
- Proper error logging for debugging
- Recovery mechanisms for providers

## Files

### New Files Created

- `lib/providers/error_state_provider.dart` - Global error state management with notifier for aggregating and displaying provider errors
- `lib/providers/riverpod/comment_reaction_provider.dart` - Complete implementation of comment reaction counts and user reaction status
- `lib/services/error_aggregator_service.dart` - Service for collecting error information from multiple providers

### Existing Files Modified

- `lib/features/crews/providers/feed_provider.dart` - Replace silent error handlers with proper error propagation and implement missing reaction count logic
- `lib/features/crews/providers/global_feed_riverpod_provider.dart` - Fix AsyncValue error handling patterns
- `lib/features/crews/providers/messaging_riverpod_provider.dart` - Implement proper error recovery in message streams
- `lib/features/crews/providers/crews_riverpod_provider.dart` - Resolve provider name conflicts and update error handling
- `lib/providers/core_providers.dart` - Clean up legacy provider naming conflicts and standardize error approaches
- `lib/features/crews/providers/tailboard_riverpod_provider.dart` - Implement proper error state management
- `lib/providers/riverpod/app_state_riverpod_provider.dart` - Integrate global error state into app-level providers

### Configuration File Updates

- Update logging configuration in `analysis_options.yaml` to route provider errors through centralized logging

## Functions

### New Functions Added

- `errorAggregator.addProviderError(String providerName, String error, StackTrace stack)` - Centralized error aggregation from any provider
- `feedService.getPostReactionCounts(String postId)` - Retrieve actual reaction counts from Firestore
- `feedService.getUserReactionForPost(String postId, String userId)` - Check user's reaction status for posts

### Modified Functions Updated

- `crewPosts(Ref ref, String crewId)` - Change error handler from silent suppression to proper error state injection
- `postComments(Ref ref, String postId)` - Replace silent error handling with error logging and user feedback
- `globalMessages(Ref ref)` - Implement error recovery in global message streams
- `selectedCrewPosts(Ref ref)` - Add error boundary for selected crew validation
- `postReactionCounts(Ref ref, String postId)` - Replace empty map return with actual Firestore data fetching

## Classes

### New Classes Created

- `ErrorStateNotifier` - Riverpod notifier for managing global error state across the application
- `ProviderErrorData` - Data class for standardizing error information from providers

### Modified Classes Updated

- `CommentNotifier` - Add error state reset and improved error handling in comment operations
- `ReactionNotifier` - Replace silent failures with proper error propagation to global error state
- `PostCreationNotifier` - Implement error recovery mechanisms for post creation failures
- `PostUpdateNotifier` - Add better error handling for post update operations

## Dependencies

No new external package dependencies needed. Current Riverpod and Flutter versions (flutter_riverpod ^3.0.0-dev.17, riverpod_annotation ^3.0.0-dev.17) are sufficient for the fixes.

## Testing

### Test Files Created

- `test/providers/error_state_provider_test.dart` - Unit tests for global error state management
- `test/providers/feed_provider_error_test.dart` - Tests for improved error handling in feed providers

### Existing Test Files Modified

- `test/features/crews/tailboard_screen_test.dart` - Update tests to handle new error propagation patterns
- `test/presentation/providers/job_filter_provider_test.dart` - Verify error state integration doesn't break existing tests

### Error Scenarios to Test

- Network disconnection during provider operations
- Firestore permission errors
- Invalid data format handling
- Authentication failures in provider watchers

## Implementation Order

1. **Create global error state management** (`error_state_provider.dart`) - Foundation for all error handling improvements
2. **Fix silent error handlers** in feed_provider.dart - Replace `(_, __) => []` patterns with proper error propagation
3. **Implement reaction count providers** - Add actual Firestore integration for post reactions
4. **Update crew providers** - Resolve naming conflicts and standardize error handling
5. **Enhance messaging providers** - Fix error recovery in stream providers
6. **Integrate error state** into app_state providers - Connect global error management
7. **Add comprehensive error logging** - Ensure all providers route errors through central logging
8. **Update tests** - Verify all error handling improvements work correctly
