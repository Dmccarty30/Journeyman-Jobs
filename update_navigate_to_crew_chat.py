#!/usr/bin/env python3
"""Script to update _navigateToCrewChat method in tailboard_screen.dart"""

import re
import sys

def update_navigate_to_crew_chat(file_path):
    """Replace the _navigateToCrewChat method with functional implementation"""
    
    # Read the file
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Define the new method implementation
    new_method = """  void _navigateToCrewChat() async {
    final selectedCrew = ref.read(selectedCrewProvider);

    if (selectedCrew == null) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Please select a crew first',
        type: ElectricalNotificationType.error,
      );
      return;
    }

    try {
      // Get Stream Chat client
      final client = await ref.read(streamChatClientProvider.future);
      
      // Query for the #general channel for this crew
      // Using team filter to ensure we get the correct crew's general channel
      final channels = await client.queryChannels(
        filter: Filter.and([
          Filter.equal('team', selectedCrew.id),  // Team isolation
          Filter.equal('type', 'team'),            // Team channel type
          Filter.equal('name', 'general'),         // General channel name
        ]),
        sort: [const SortOption('last_message_at', direction: SortOption.DESC)],
      ).first;

      if (channels.isNotEmpty) {
        // Found the #general channel, navigate to it
        final generalChannel = channels.first;
        
        // Update user's team assignment to ensure access
        await ref.read(streamChatServiceProvider).updateUserTeam(selectedCrew.id);
        
        // Store as active channel
        ref.read(activeChannelProvider.notifier).state = generalChannel;
        
        // Navigate to chat tab
        _tabController.animateTo(2);
        
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Opening #general channel',
          type: ElectricalNotificationType.success,
        );
      } else {
        // #general channel doesn't exist, create it
        final generalChannel = await client.channel(
          'team', 
          'general-${selectedCrew.id}',  // Unique ID for crew's general channel
          extraData: {
            'name': 'general',
            'team': selectedCrew.id,
            'created_by': 'system',
            'description': 'General announcements and discussions for ${selectedCrew.name}',
          },
        );
        
        // Create the channel
        await generalChannel.create();
        
        // Add current user as a member
        await generalChannel.addMembers([client.state.user!.id]);
        
        // Store as active channel
        ref.read(activeChannelProvider.notifier).state = generalChannel;
        
        // Navigate to chat tab
        _tabController.animateTo(2);
        
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Created and opened #general channel',
          type: ElectricalNotificationType.success,
        );
      }
    } catch (e) {
      debugPrint('Error navigating to crew chat: $e');
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Failed to open crew chat',
        type: ElectricalNotificationType.error,
      );
      
      // Fallback: just navigate to chat tab
      _tabController.animateTo(2);
    }
  }"""
    
    # Find the existing method and replace it
    pattern = r'  void _navigateToCrewChat\(\) \{.*?^\s*\}'
    replacement = new_method
    
    # Use re.DOTALL to match across newlines
    updated_content = re.sub(pattern, replacement, content, flags=re.DOTALL | re.MULTILINE)
    
    # Check if replacement was successful
    if updated_content == content:
        print("ERROR: Could not find _navigateToCrewChat method to replace")
        return False
    
    # Write the updated content back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(updated_content)
    
    print("Successfully updated _navigateToCrewChat method")
    return True

if __name__ == "__main__":
    file_path = r"D:\Journeyman-Jobs\lib\features\crews\screens\tailboard_screen.dart"
    success = update_navigate_to_crew_chat(file_path)
    sys.exit(0 if success else 1)
