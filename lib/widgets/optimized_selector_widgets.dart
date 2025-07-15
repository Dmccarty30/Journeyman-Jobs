import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/job_model.dart';

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
class JobsListStateSelector extends StatelessWidget {
  final Widget Function(BuildContext context, JobsListState jobsState, Widget? child) builder;
  final Widget? child;

  const JobsListStateSelector({
    super.key,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<AppStateProvider, JobsListState>(
      selector: (context, provider) => JobsListState(
        jobs: provider.jobs,
        isLoading: provider.isLoadingJobs,
        error: provider.jobsError,
        hasMore: provider.hasMoreJobs,
      ),
      builder: builder,
      child: child,
    );
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
class LocalsListStateSelector extends StatelessWidget {
  final Widget Function(BuildContext context, LocalsListState localsState, Widget? child) builder;
  final Widget? child;

  const LocalsListStateSelector({
    super.key,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<AppStateProvider, LocalsListState>(
      selector: (context, provider) => LocalsListState(
        locals: provider.locals,
        isLoading: provider.isLoadingLocals,
        error: provider.localsError,
        hasMore: provider.hasMoreLocals,
      ),
      builder: builder,
      child: child,
    );
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
      user!.uid.hashCode;
}

/// Optimized selector widget for auth state
class AuthStateSelector extends StatelessWidget {
  final Widget Function(BuildContext context, AuthState authState, Widget? child) builder;
  final Widget? child;

  const AuthStateSelector({
    super.key,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<AppStateProvider, AuthState>(
      selector: (context, provider) => AuthState(
        isAuthenticated: provider.isAuthenticated,
        isLoading: provider.isLoadingAuth,
        error: provider.authError,
        user: provider.user,
      ),
      builder: builder,
      child: child,
    );
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
class CombinedAppStateSelector extends StatelessWidget {
  final Widget Function(BuildContext context, CombinedAppState appState, Widget? child) builder;
  final Widget? child;

  const CombinedAppStateSelector({
    super.key,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<AppStateProvider, CombinedAppState>(
      selector: (context, provider) => CombinedAppState(
        authState: AuthState(
          isAuthenticated: provider.isAuthenticated,
          isLoading: provider.isLoadingAuth,
          error: provider.authError,
          user: provider.user,
        ),
        jobsState: JobsListState(
          jobs: provider.jobs,
          isLoading: provider.isLoadingJobs,
          error: provider.jobsError,
          hasMore: provider.hasMoreJobs,
        ),
        localsState: LocalsListState(
          locals: provider.locals,
          isLoading: provider.isLoadingLocals,
          error: provider.localsError,
          hasMore: provider.hasMoreLocals,
        ),
      ),
      builder: builder,
      child: child,
    );
  }
}
