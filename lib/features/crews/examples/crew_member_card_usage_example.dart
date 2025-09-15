import 'package:flutter/material.dart';
import '../widgets/crew_member_card.dart';
import '../models/crew_member.dart';
import '../models/crew_enums.dart';

/// Example usage of CrewMemberCard widget
///
/// Demonstrates various configurations and use cases for displaying
/// IBEW crew members with proper electrical theme integration.
class CrewMemberCardUsageExample extends StatefulWidget {
  const CrewMemberCardUsageExample({super.key});

  @override
  State<CrewMemberCardUsageExample> createState() => _CrewMemberCardUsageExampleState();
}

class _CrewMemberCardUsageExampleState extends State<CrewMemberCardUsageExample> {
  late List<CrewMember> _crewMembers;
  CrewRole _currentUserRole = CrewRole.foreman;

  @override
  void initState() {
    super.initState();
    _initializeMemberData();
  }

  void _initializeMemberData() {
    _crewMembers = [
      // Foreman - experienced leader
      CrewMember(
        id: 'foreman1',
        userId: 'user1',
        crewId: 'crew1',
        displayName: 'Mike Johnson',
        email: 'mike.johnson@ibew123.org',
        phone: '+15551234567',
        profileImageUrl: 'https://i.pravatar.cc/150?img=1',
        role: CrewRole.foreman,
        joinedAt: DateTime.now().subtract(const Duration(days: 365)),
        lastActiveAt: DateTime.now().subtract(const Duration(minutes: 15)),
        isActive: true,
        workPreferences: const CrewMemberPreferences(
          availableForStormWork: true,
          availableForOvertime: true,
          maxTravelRadius: 100,
        ),
        notifications: const NotificationSettings(),
        classifications: ['Journeyman Lineman', 'Foreman'],
        localNumber: '123',
        yearsExperience: 15,
        certifications: ['OSHA 30', 'Arc Flash', 'First Aid', 'CPR'],
        skills: ['Crew Management', 'Safety Compliance', 'Storm Restoration'],
        availability: MemberAvailability.available,
        rating: 4.8,
        jobsCompleted: 125,
        emergencyContact: const EmergencyContact(
          name: 'Sarah Johnson',
          relationship: 'Spouse',
          phone: '+15559876543',
          email: 'sarah.johnson@email.com',
        ),
      ),

      // Lead Journeyman - technical expert
      CrewMember(
        id: 'lead1',
        userId: 'user2',
        crewId: 'crew1',
        displayName: 'Carlos Rodriguez',
        email: 'carlos.rodriguez@ibew456.org',
        phone: '+15552345678',
        role: CrewRole.leadJourneyman,
        joinedAt: DateTime.now().subtract(const Duration(days: 200)),
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 1)),
        isActive: true,
        workPreferences: const CrewMemberPreferences(
          availableForStormWork: true,
          availableForNightShift: true,
        ),
        notifications: const NotificationSettings(),
        classifications: ['Inside Wireman', 'Motor Control Specialist'],
        localNumber: '456',
        yearsExperience: 12,
        certifications: ['OSHA 10', 'NFPA 70E', 'Motor Controls'],
        skills: ['PLC Programming', 'Motor Controls', 'Troubleshooting'],
        availability: MemberAvailability.onJob,
        rating: 4.6,
        jobsCompleted: 89,
        emergencyContact: const EmergencyContact(
          name: 'Maria Rodriguez',
          relationship: 'Mother',
          phone: '+15558765432',
        ),
      ),

      // Journeyman - solid performer
      CrewMember(
        id: 'journey1',
        userId: 'user3',
        crewId: 'crew1',
        displayName: 'David Thompson',
        email: 'david.thompson@ibew789.org',
        phone: '+15553456789',
        role: CrewRole.journeyman,
        joinedAt: DateTime.now().subtract(const Duration(days: 90)),
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 6)),
        isActive: true,
        workPreferences: const CrewMemberPreferences(
          availableForWeekends: true,
          maxTravelRadius: 75,
        ),
        notifications: const NotificationSettings(),
        classifications: ['Journeyman Lineman'],
        localNumber: '789',
        yearsExperience: 8,
        certifications: ['OSHA 30', 'CDL Class A'],
        skills: ['Hot Line Work', 'Pole Installation', 'Underground Splicing'],
        availability: MemberAvailability.available,
        rating: 4.3,
        jobsCompleted: 52,
        emergencyContact: const EmergencyContact(
          name: 'Jennifer Thompson',
          relationship: 'Spouse',
          phone: '+15557654321',
        ),
      ),

      // Apprentice - learning and growing
      CrewMember(
        id: 'apprentice1',
        userId: 'user4',
        crewId: 'crew1',
        displayName: 'Alex Chen',
        email: 'alex.chen@apprentice.ibew123.org',
        phone: '+15554567890',
        role: CrewRole.apprentice,
        joinedAt: DateTime.now().subtract(const Duration(days: 30)),
        lastActiveAt: DateTime.now().subtract(const Duration(minutes: 45)),
        isActive: true,
        workPreferences: const CrewMemberPreferences(
          availableForOvertime: true,
          maxTravelRadius: 50,
        ),
        notifications: const NotificationSettings(),
        classifications: ['3rd Year Apprentice'],
        localNumber: '123',
        yearsExperience: 3,
        certifications: ['OSHA 10', 'Basic First Aid'],
        skills: ['Conduit Bending', 'Wire Pulling', 'Basic Troubleshooting'],
        availability: MemberAvailability.available,
        rating: 4.0,
        jobsCompleted: 15,
        emergencyContact: const EmergencyContact(
          name: 'Linda Chen',
          relationship: 'Mother',
          phone: '+15556543210',
        ),
      ),

      // Safety Coordinator - specialized role
      CrewMember(
        id: 'safety1',
        userId: 'user5',
        crewId: 'crew1',
        displayName: 'Robert Williams',
        email: 'robert.williams@safety.ibew123.org',
        phone: '+15555678901',
        role: CrewRole.safetyCoordinator,
        joinedAt: DateTime.now().subtract(const Duration(days: 150)),
        lastActiveAt: DateTime.now().subtract(const Duration(days: 2)),
        isActive: true,
        workPreferences: const CrewMemberPreferences(
          availableForStormWork: true,
          availableForNightShift: false, // Safety oversight during day hours
        ),
        notifications: const NotificationSettings(),
        classifications: ['Safety Specialist', 'Inside Wireman'],
        localNumber: '123',
        yearsExperience: 20,
        certifications: ['OSHA 30', 'NFPA 70E Instructor', 'Safety Management'],
        skills: ['Safety Training', 'Incident Investigation', 'Risk Assessment'],
        availability: MemberAvailability.onVacation,
        rating: 4.9,
        jobsCompleted: 78,
        emergencyContact: const EmergencyContact(
          name: 'Susan Williams',
          relationship: 'Spouse',
          phone: '+15554321098',
          email: 'susan.williams@email.com',
        ),
      ),

      // Equipment Operator - unavailable member
      CrewMember(
        id: 'operator1',
        userId: 'user6',
        crewId: 'crew1',
        displayName: 'Tommy Martinez',
        email: 'tommy.martinez@ibew999.org',
        phone: '+15556789012',
        role: CrewRole.operator,
        joinedAt: DateTime.now().subtract(const Duration(days: 60)),
        lastActiveAt: DateTime.now().subtract(const Duration(days: 5)),
        isActive: true,
        workPreferences: const CrewMemberPreferences(
          availableForStormWork: true,
          availableForWeekends: false,
        ),
        notifications: const NotificationSettings(),
        classifications: ['Equipment Operator', 'CDL Class A'],
        localNumber: '999',
        yearsExperience: 10,
        certifications: ['CDL Class A', 'Crane Operator', 'OSHA 30'],
        skills: ['Boom Truck Operation', 'Digger Derrick', 'Heavy Equipment'],
        availability: MemberAvailability.sick,
        rating: 4.4,
        jobsCompleted: 67,
        emergencyContact: const EmergencyContact(
          name: 'Elena Martinez',
          relationship: 'Spouse',
          phone: '+15553210987',
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crew Member Cards'),
        actions: [
          PopupMenuButton<CrewRole>(
            onSelected: (role) => setState(() => _currentUserRole = role),
            itemBuilder: (context) => CrewRole.values.map((role) =>
              PopupMenuItem(
                value: role,
                child: Text('View as ${role.displayName}'),
              ),
            ).toList(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Role: ${_currentUserRole.displayName}'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Full Layout Cards
          _buildSectionHeader('Full Layout'),
          const SizedBox(height: 8),
          ..._crewMembers.map((member) => CrewMemberCard(
            member: member,
            currentUserRole: _currentUserRole,
            onTap: () => _showMemberDetails(context, member),
            onRoleChange: (newRole) => _handleRoleChange(member, newRole),
            onRemove: () => _handleRemoveMember(member),
            onContact: (contactType) => _handleContact(member, contactType),
            showActions: true,
            compact: false,
          )),

          const SizedBox(height: 32),

          // Section: Compact Layout Cards
          _buildSectionHeader('Compact Layout'),
          const SizedBox(height: 8),
          ..._crewMembers.take(3).map((member) => CrewMemberCard(
            member: member,
            currentUserRole: _currentUserRole,
            onTap: () => _showMemberDetails(context, member),
            showActions: true,
            compact: true,
          )),

          const SizedBox(height: 32),

          // Section: Read-only Cards (no actions)
          _buildSectionHeader('Read-only (No Actions)'),
          const SizedBox(height: 8),
          ..._crewMembers.take(2).map((member) => CrewMemberCard(
            member: member,
            currentUserRole: _currentUserRole,
            showActions: false,
          )),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showMemberDetails(BuildContext context, CrewMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(member.displayName ?? 'Member Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Role', member.role.displayName),
              _buildDetailRow('Local', 'IBEW ${member.localNumber ?? "N/A"}'),
              _buildDetailRow('Experience', '${member.yearsExperience ?? "Unknown"} years'),
              _buildDetailRow('Classification', member.classifications.join(', ')),
              _buildDetailRow('Availability', member.availability.displayName),
              _buildDetailRow('Jobs Completed', '${member.jobsCompleted}'),
              if (member.rating != null)
                _buildDetailRow('Rating', '${member.rating!.toStringAsFixed(1)}/5.0'),
              _buildDetailRow('Certifications', member.certifications.join(', ')),
              _buildDetailRow('Skills', member.skills.join(', ')),
              if (member.hasEmergencyContact)
                _buildDetailRow('Emergency Contact', 'Available'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  void _handleRoleChange(CrewMember member, CrewRole newRole) {
    setState(() {
      final index = _crewMembers.indexWhere((m) => m.id == member.id);
      if (index != -1) {
        _crewMembers[index] = member.copyWith(role: newRole);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Changed ${member.displayName}\'s role to ${newRole.displayName}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleRemoveMember(CrewMember member) {
    setState(() {
      _crewMembers.removeWhere((m) => m.id == member.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${member.displayName} from crew'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _crewMembers.add(member);
            });
          },
        ),
      ),
    );
  }

  void _handleContact(CrewMember member, String contactType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Contacted ${member.displayName} via $contactType',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

/// Demo screen to show different member card configurations
class CrewMemberCardDemo extends StatelessWidget {
  const CrewMemberCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const CrewMemberCardUsageExample();
  }
}