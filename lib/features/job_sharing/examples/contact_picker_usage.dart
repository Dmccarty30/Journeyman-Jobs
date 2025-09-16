import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/riverpod_contact_picker.dart';
import '../services/contact_service.dart';

/// Example implementations showing how to use the contact picker in different scenarios

class JobSharingExample {
  /// Example 1: Basic job sharing with contact picker
  static Future<void> shareJobWithContacts(BuildContext context, String jobId) async {
    final selectedContacts = await Navigator.of(context).push<List<ContactInfo>>(
      MaterialPageRoute(
        builder: (context) => JJRiverpodContactPicker(
          onContactsSelected: (contacts) {
            // This callback is called as contacts are selected
            // You can use it for real-time UI updates if needed
          },
          allowMultiSelect: true,
          maxSelection: 10,
          highlightExistingUsers: true,
        ),
      ),
    );

    if (selectedContacts != null && selectedContacts.isNotEmpty) {
      // Process the selected contacts
      await _processJobSharing(jobId, selectedContacts);
    }
  }

  /// Example 2: Share with specific existing platform users highlighted
  static Future<void> shareWithIBEWMembers(BuildContext context, String jobId, List<String> existingMembers) async {
    final selectedContacts = await Navigator.of(context).push<List<ContactInfo>>(
      MaterialPageRoute(
        builder: (context) => JJRiverpodContactPicker(
          onContactsSelected: (contacts) {
            // Real-time callback
          },
          existingPlatformUsers: existingMembers,
          allowMultiSelect: true,
          maxSelection: 15,
          highlightExistingUsers: true,
        ),
      ),
    );

    if (selectedContacts != null && selectedContacts.isNotEmpty) {
      await _processJobSharing(jobId, selectedContacts);
    }
  }

  /// Example 3: Single contact selection for mentorship assignments
  static Future<ContactInfo?> selectMentor(BuildContext context, List<String> certifiedMentors) async {
    final selectedContacts = await Navigator.of(context).push<List<ContactInfo>>(
      MaterialPageRoute(
        builder: (context) => JJRiverpodContactPicker(
          onContactsSelected: (contacts) {},
          existingPlatformUsers: certifiedMentors,
          allowMultiSelect: false, // Single selection only
          maxSelection: 1,
          highlightExistingUsers: true,
        ),
      ),
    );

    return selectedContacts?.isNotEmpty == true ? selectedContacts!.first : null;
  }

  /// Process the job sharing with selected contacts
  static Future<void> _processJobSharing(String jobId, List<ContactInfo> contacts) async {
    // Example implementation - replace with actual job sharing logic
    for (final contact in contacts) {
      if (contact.primaryEmail != null) {
        await _sendEmailInvite(jobId, contact.primaryEmail!, contact.displayName);
      } else if (contact.primaryPhoneNumber != null) {
        await _sendSMSInvite(jobId, contact.primaryPhoneNumber!, contact.displayName);
      }
    }
  }

  static Future<void> _sendEmailInvite(String jobId, String email, String name) async {
    // Implement email sharing logic
    print('Sending email invite for job $jobId to $name ($email)');
  }

  static Future<void> _sendSMSInvite(String jobId, String phone, String name) async {
    // Implement SMS sharing logic
    print('Sending SMS invite for job $jobId to $name ($phone)');
  }
}

/// Example widget showing integration with job details screen
class JobDetailsShareButton extends ConsumerWidget {
  final String jobId;
  final String jobTitle;
  final List<String>? existingPlatformUsers;

  const JobDetailsShareButton({
    Key? key,
    required this.jobId,
    required this.jobTitle,
    this.existingPlatformUsers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () => _handleSharePressed(context),
      icon: const Icon(Icons.share),
      label: const Text('Share with Brothers'),
    );
  }

  Future<void> _handleSharePressed(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _ShareOptionsBottomSheet(
        jobId: jobId,
        jobTitle: jobTitle,
        existingPlatformUsers: existingPlatformUsers,
      ),
    );

    if (result != null) {
      // Handle the sharing result
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    }
  }
}

/// Bottom sheet with sharing options
class _ShareOptionsBottomSheet extends StatelessWidget {
  final String jobId;
  final String jobTitle;
  final List<String>? existingPlatformUsers;

  const _ShareOptionsBottomSheet({
    required this.jobId,
    required this.jobTitle,
    this.existingPlatformUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Share Job Opportunity',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            jobTitle,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Share with contacts button
          ElevatedButton.icon(
            onPressed: () => _shareWithContacts(context),
            icon: const Icon(Icons.contacts),
            label: const Text('Select from Contacts'),
          ),
          const SizedBox(height: 12),
          
          // Share with IBEW members only
          if (existingPlatformUsers?.isNotEmpty == true)
            ElevatedButton.icon(
              onPressed: () => _shareWithIBEWMembers(context),
              icon: const Icon(Icons.electrical_services),
              label: const Text('IBEW Members Only'),
            ),
          const SizedBox(height: 12),
          
          // Other sharing options
          OutlinedButton.icon(
            onPressed: () => _shareViaLink(context),
            icon: const Icon(Icons.link),
            label: const Text('Copy Share Link'),
          ),
          const SizedBox(height: 8),
          
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareWithContacts(BuildContext context) async {
    Navigator.of(context).pop(); // Close bottom sheet
    
    final selectedContacts = await Navigator.of(context).push<List<ContactInfo>>(
      MaterialPageRoute(
        builder: (context) => JJRiverpodContactPicker(
          onContactsSelected: (contacts) {},
          existingPlatformUsers: existingPlatformUsers,
          allowMultiSelect: true,
          maxSelection: 10,
        ),
      ),
    );

    if (selectedContacts != null && selectedContacts.isNotEmpty) {
      await JobSharingExample._processJobSharing(jobId, selectedContacts);
      if (context.mounted) {
        Navigator.of(context).pop('Job shared with ${selectedContacts.length} contacts');
      }
    }
  }

  Future<void> _shareWithIBEWMembers(BuildContext context) async {
    Navigator.of(context).pop(); // Close bottom sheet
    
    final selectedContacts = await Navigator.of(context).push<List<ContactInfo>>(
      MaterialPageRoute(
        builder: (context) => JJRiverpodContactPicker(
          onContactsSelected: (contacts) {},
          existingPlatformUsers: existingPlatformUsers ?? [],
          allowMultiSelect: true,
          maxSelection: 15,
          highlightExistingUsers: true,
        ),
      ),
    );

    if (selectedContacts != null && selectedContacts.isNotEmpty) {
      // Filter to only IBEW members
      final ibewMembers = selectedContacts.where((contact) {
        return existingPlatformUsers?.any((user) =>
          contact.emails.contains(user.toLowerCase()) ||
          contact.phoneNumbers.any((phone) => 
              phone.replaceAll(RegExp(r'\D'), '').endsWith(user.replaceAll(RegExp(r'\D'), '')))
        ) ?? false;
      }).toList();

      if (ibewMembers.isNotEmpty) {
        await JobSharingExample._processJobSharing(jobId, ibewMembers);
        if (context.mounted) {
          Navigator.of(context).pop('Job shared with ${ibewMembers.length} IBEW members');
        }
      } else {
        if (context.mounted) {
          Navigator.of(context).pop('No IBEW members selected');
        }
      }
    }
  }

  Future<void> _shareViaLink(BuildContext context) async {
    // Generate and copy share link
    
    // Copy to clipboard (you'd need to add clipboard dependency)
    // await Clipboard.setData(ClipboardData(text: shareLink));
    
    Navigator.of(context).pop('Share link copied to clipboard');
  }
}

/// Example of using contact picker in a storm roster sign-up scenario
class StormRosterContactSelection extends ConsumerStatefulWidget {
  final String stormEventId;

  const StormRosterContactSelection({
    super.key,
    required this.stormEventId,
  });

  @override
  ConsumerState<StormRosterContactSelection> createState() => _StormRosterContactSelectionState();
}

class _StormRosterContactSelectionState extends ConsumerState<StormRosterContactSelection> {
  List<ContactInfo> _selectedEmergencyContacts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Storm Roster Sign-up',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select up to 3 emergency contacts who should be notified if you don\'t check in during storm work.',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _selectEmergencyContacts,
                      icon: const Icon(Icons.contact_emergency),
                      label: const Text('Select Emergency Contacts'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          if (_selectedEmergencyContacts.isNotEmpty) ...[
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedEmergencyContacts.length,
                itemBuilder: (context, index) {
                  final contact = _selectedEmergencyContacts[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.contact_emergency),
                    ),
                    title: Text(contact.displayName),
                    subtitle: Text(contact.primaryEmail ?? contact.primaryPhoneNumber ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () {
                        setState(() {
                          _selectedEmergencyContacts.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectEmergencyContacts() async {
    final selectedContacts = await Navigator.of(context).push<List<ContactInfo>>(
      MaterialPageRoute(
        builder: (context) => JJRiverpodContactPicker(
          onContactsSelected: (contacts) {},
          allowMultiSelect: true,
          maxSelection: 3, // Limit to 3 emergency contacts
          highlightExistingUsers: false, // Don't need to highlight for emergency contacts
        ),
      ),
    );

    if (selectedContacts != null) {
      setState(() {
        _selectedEmergencyContacts = selectedContacts;
      });
    }
  }
}