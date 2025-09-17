import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/app_theme.dart';
import '../models/crew.dart';
import '../models/crew_enums.dart';
import '../widgets/crew_card.dart';

/// Example usage of CrewCard widget with electrical theme and IBEW styling.
/// 
/// Demonstrates various crew states including active crews, storm specialists,
/// and different member configurations for electrical worker teams.
class CrewCardUsageExample extends ConsumerWidget {
  const CrewCardUsageExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text('Crew Card Examples'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Active Crews'),
          CrewCard(
            crew: _createSampleCrew(
              id: 'crew-1',
              name: 'IBEW Local 123 Alpha Crew',
              memberIds: ['user1', 'user2', 'user3', 'user4'],
              classifications: ['insideWireman', 'journeymanLineman'],
              isActive: true,
              homeLocal: '123',
              totalJobs: 15,
              averageRating: 4.8,
            ),
            onTap: () => _showCrewDetails(context, 'Alpha Crew'),
          ),
          const SizedBox(height: 16),
          
          _buildSectionHeader('Storm Work Specialists'),
          CrewCard(
            crew: _createSampleCrew(
              id: 'crew-2',
              name: 'Storm Response Team Beta',
              memberIds: ['user1', 'user2', 'user3', 'user4', 'user5', 'user6'],
              classifications: ['journeymanLineman', 'treeTrimmer'],
              isActive: true,
              homeLocal: '456',
              availableForStormWork: true,
              totalJobs: 32,
              averageRating: 4.9,
            ),
            onTap: () => _showCrewDetails(context, 'Storm Response Team'),
          ),
          const SizedBox(height: 16),
          
          _buildSectionHeader('Recruiting Crews'),
          CrewCard(
            crew: _createSampleCrew(
              id: 'crew-3',
              name: 'Commercial Electrical Crew',
              memberIds: ['user1', 'user2'],
              classifications: ['insideWireman'],
              isActive: false,
              homeLocal: '789',
              totalJobs: 8,
              averageRating: 4.5,
            ),
            onTap: () => _showCrewDetails(context, 'Commercial Crew'),
          ),
          const SizedBox(height: 16),
          
          _buildSectionHeader('Full Capacity Crews'),
          CrewCard(
            crew: _createSampleCrew(
              id: 'crew-4',
              name: 'Industrial Maintenance Team',
              memberIds: List.generate(10, (i) => 'user$i'), // Full crew
              classifications: ['insideWireman', 'equipmentOperator'],
              isActive: true,
              homeLocal: '101',
              totalJobs: 45,
              averageRating: 4.7,
              maxMembers: 10,
            ),
            onTap: () => _showCrewDetails(context, 'Industrial Team'),
          ),
          const SizedBox(height: 16),
          
          _buildSectionHeader('New Crews'),
          CrewCard(
            crew: _createSampleCrew(
              id: 'crew-5',
              name: 'Underground Specialists',
              memberIds: ['user1'],
              classifications: ['journeymanLineman'],
              isActive: true,
              homeLocal: '202',
              totalJobs: 0,
              averageRating: 0.0,
            ),
            onTap: () => _showCrewDetails(context, 'Underground Specialists'),
          ),
          const SizedBox(height: 16),
          
          _buildSectionHeader('Edge Cases'),
          CrewCard(
            crew: _createSampleCrew(
              id: 'crew-6',
              name: '', // Empty name to test fallback
              memberIds: [], // No members
              classifications: [],
              isActive: false,
              totalJobs: 0,
              averageRating: 0.0,
            ),
            onTap: () => _showCrewDetails(context, 'Unnamed Crew'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: AppTheme.headlineMedium.copyWith(
          color: AppTheme.primaryNavy,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Crew _createSampleCrew({
    required String id,
    required String name,
    required List<String> memberIds,
    required List<String> classifications,
    required bool isActive,
    String? homeLocal,
    bool availableForStormWork = false,
    int totalJobs = 0,
    double averageRating = 0.0,
    int maxMembers = 8,
  }) {
    return Crew(
      id: id,
      name: name,
      createdBy: 'foreman_001',
      memberIds: memberIds,
      maxMembers: maxMembers,
      classifications: classifications,
      jobTypes: [JobType.insideWireman],
      travelRadius: 50,
      isActive: isActive,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      homeLocal: homeLocal,
      availableForStormWork: availableForStormWork,
      totalJobs: totalJobs,
      averageRating: averageRating,
      lastActivityAt: DateTime.now().subtract(const Duration(minutes: 15)),
    );
  }

  void _showCrewDetails(BuildContext context, String crewName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped on $crewName'),
        backgroundColor: AppTheme.primaryNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Demo screen for testing CrewCard in isolation
class CrewCardDemo extends StatelessWidget {
  const CrewCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'CrewCard Demo',
        theme: AppTheme.lightTheme,
        home: const CrewCardUsageExample(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Sample crew data for testing and development
class SampleCrewData {
  static final List<Crew> crews = [
    Crew(
      id: 'crew_alpha',
      name: 'IBEW Local 123 Alpha Crew',
      createdBy: 'foreman_alpha',
      memberIds: ['member1', 'member2', 'member3', 'member4'],
      maxMembers: 8,
      classifications: ['insideWireman', 'journeymanLineman'],
      jobTypes: [JobType.insideWireman, JobType.commercialElectrical],
      travelRadius: 75,
      isActive: true,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      homeLocal: '123',
      totalJobs: 24,
      averageRating: 4.8,
      completedJobs: 20,
      lastActivityAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    
    Crew(
      id: 'storm_beta',
      name: 'Storm Response Team Beta',
      createdBy: 'foreman_beta',
      memberIds: ['storm1', 'storm2', 'storm3', 'storm4', 'storm5', 'storm6'],
      maxMembers: 10,
      classifications: ['journeymanLineman', 'treeTrimmer', 'equipmentOperator'],
      jobTypes: [JobType.stormWork, JobType.journeymanLineman],
      travelRadius: 200,
      isActive: true,
      createdAt: DateTime(2024, 2, 1),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      homeLocal: '456',
      availableForStormWork: true,
      availableForEmergencyWork: true,
      totalJobs: 45,
      averageRating: 4.9,
      completedJobs: 40,
      lastActivityAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    
    Crew(
      id: 'commercial_gamma',
      name: 'Commercial Electrical Specialists',
      createdBy: 'foreman_gamma',
      memberIds: ['comm1', 'comm2'],
      maxMembers: 6,
      classifications: ['insideWireman', 'insideJourneymanElectrician'],
      jobTypes: [JobType.commercialElectrical, JobType.industrialElectrical],
      travelRadius: 50,
      isActive: false,
      createdAt: DateTime(2024, 3, 10),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      homeLocal: '789',
      totalJobs: 12,
      averageRating: 4.6,
      completedJobs: 10,
      lastActivityAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  /// Get a crew by ID for testing
  static Crew? getCrewById(String id) {
    try {
      return crews.firstWhere((crew) => crew.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get sample crews for different test scenarios
  static Crew get activeCrew => crews[0];
  static Crew get stormCrew => crews[1];
  static Crew get recruitingCrew => crews[2];
}
