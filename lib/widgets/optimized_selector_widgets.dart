import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/riverpod/app_state_riverpod_provider.dart';
import '../providers/riverpod/auth_riverpod_provider.dart';
import '../providers/riverpod/jobs_riverpod_provider.dart';
import '../providers/riverpod/locals_riverpod_provider.dart';
import '../models/job_model.dart';
import '../models/locals_record.dart';

/// State class for jobs list to optimize rebuilds
class JobsListState {
  final List<Job> jobs;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  const JobsListState({
    required this.jobs,
    required this.isLoading,
    this.error,
    required this.hasMore,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobsListState &&
          runtimeType == other.runtimeType &&
          jobs.length == other.jobs.length &&
          isLoading == other.isLoading &&
          error == other.error &&
          hasMore == other.hasMore;

  @override
  int get hashCode =>
      jobs.length.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      hasMore.hashCode;
}

/// Optimized selector widget for jobs list state
class JobsListStateSelector extends ConsumerWidget {
  final Widget Function(BuildContext context, JobsListState jobsState, Widget? child) builder;
  final Widget? child;

  const JobsListStateSelector({
    super.key,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsProviderState = ref.watch(jobsNotifierProvider);
    final jobsState = JobsListState(
      jobs: jobsProviderState.jobs,
      isLoading: jobsProviderState.isLoading,
      error: jobsProviderState.error,
      hasMore: jobsProviderState.hasMoreJobs,
    );
    return builder(context, jobsState, child);
  }
}

/// State class for locals list to optimize rebuilds
class LocalsListState {
  final List locals;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  const LocalsListState({
    required this.locals,
    required this.isLoading,
    this.error,
    required this.hasMore,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalsListState &&
          runtimeType == other.runtimeType &&
          locals.length == other.locals.length &&
          isLoading == other.isLoading &&
          error == other.error &&
          hasMore == other.hasMore;

  @override
  int get hashCode =>
      locals.length.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      hasMore.hashCode;
}

/// Optimized selector widget for locals list state
class LocalsListStateSelector extends ConsumerWidget {
  final Widget Function(BuildContext context, LocalsListState localsState, Widget? child) builder;
  final Widget? child;

  const LocalsListStateSelector({
    super.key,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateNotifierProvider);
    final localsState = LocalsListState(
      locals: appState.locals,
      isLoading: appState.isLoadingLocals,
      error: appState.localsError,
      hasMore: appState.hasMoreLocals,
    );
    return builder(context, localsState, child);
  }
}

/// State class for auth state to optimize rebuilds
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final dynamic user;

  const AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.error,
    this.user,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          isAuthenticated == other.isAuthenticated &&
          isLoading == other.isLoading &&
          error == other.error &&
          user?.uid == other.user?.uid;

  @override
  int get hashCode =>
      isAuthenticated.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      (user?.uid.hashCode ?? 0);
}

/// Optimized selector widget for auth state
class AuthStateSelector extends ConsumerWidget {
  final Widget Function(BuildContext context, AuthState authState, Widget? child) builder;
  final Widget? child;

  const AuthStateSelector({
    super.key,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateNotifierProvider);
    final authState = AuthState(
      isAuthenticated: appState.isAuthenticated,
      isLoading: appState.isLoadingAuth,
      error: appState.authError,
      user: appState.user,
    );
    return builder(context, authState, child);
  }
}

/// Combined app state for comprehensive state management
class CombinedAppState {
  final AuthState authState;
  final JobsListState jobsState;
  final LocalsListState localsState;

  const CombinedAppState({
    required this.authState,
    required this.jobsState,
    required this.localsState,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CombinedAppState &&
          runtimeType == other.runtimeType &&
          authState == other.authState &&
          jobsState == other.jobsState &&
          localsState == other.localsState;

  @override
  int get hashCode =>
      authState.hashCode ^
      jobsState.hashCode ^
      localsState.hashCode;
}

/// Optimized selector widget for combined app state
class CombinedAppStateSelector extends ConsumerWidget {
  final Widget Function(BuildContext context, CombinedAppState appState, Widget? child) builder;
  final Widget? child;

  const CombinedAppStateSelector({
    super.key,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateNotifierProvider);
    final combinedState = CombinedAppState(
      authState: AuthState(
        isAuthenticated: appState.isAuthenticated,
        isLoading: appState.isLoadingAuth,
        error: appState.authError,
        user: appState.user,
      ),
      jobsState: JobsListState(
        jobs: appState.jobs,
        isLoading: appState.isLoadingJobs,
        error: appState.jobsError,
        hasMore: appState.hasMoreJobs,
      ),
      localsState: LocalsListState(
        locals: appState.locals,
        isLoading: appState.isLoadingLocals,
        error: appState.localsError,
        hasMore: appState.hasMoreLocals,
      ),
    );
    return builder(context, combinedState, child);
  }
}
