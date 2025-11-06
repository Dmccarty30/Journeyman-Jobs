import 'package:flutter/material.dart';
import 'package:journeyman_jobs/features/crews/services/crew_service.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/services/connectivity_service.dart';
import 'package:journeyman_jobs/services/offline_data_service.dart';

// --- THEME COLORS (Customize these to match your app) ---
const Color kBackgroundColor = Color(0xFF1A1A2E); // A dark blue/black guess
const Color kSurfaceColor = Color(0xFF24243E); // Slightly lighter surface
const Color kPrimaryTextColor = Colors.white;
const Color kSecondaryTextColor = Colors.grey;
const Color kAccentColorOrange = Color(0xFFE98A44);

// Gradient for buttons and highlights
const LinearGradient kCopperGradient = LinearGradient(
  colors: [Color(0xFFF09849), Color(0xFFD47A2E)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

class CrewScreen extends StatefulWidget {
  final String crewId;
  final CrewService crewService;
  
  const CrewScreen({
    super.key,
    required this.crewId,
    required this.crewService,
  });

  @override
  State<CrewScreen> createState() => _CrewScreenState();
}

class _CrewScreenState extends State<CrewScreen> {
  // This integer controls which tab is currently selected.
  // 0: Feed, 1: Jobs, 2: Chat, 3: Members
  int _selectedTabIndex = 1; // Default to Jobs to match one of the screenshots

  // This would control the bottom navigation bar
  int _selectedBottomNavIndex = 4; // "Crews" is selected

  // --- Data for the conditional "chip" buttons ---
  // We use a Map where the key is the tab index.
  final Map<int, List<String>> _chipData = {
    0: ['All Posts', 'My Posts', 'Mentions', 'Saved'], // For Feed Tab
    1: ['All Jobs', 'Saved Jobs', 'Bids', 'History'], // For Jobs Tab
    2: ['Channels', 'Direct Messages', 'History', 'Crew Chat'], // For Chat Tab
    3: ['All Members', 'Foreman', 'Journeymen', 'Admins'], // For Members Tab
  };

  // Crew name state
  String? _crewName;

  @override
  void initState() {
    super.initState();
    _fetchCrewName();
  }

  /// Fetches the crew name from the backend using the CrewService.
  /// Updates the state with the fetched crew name or handles errors appropriately.
  Future<void> _fetchCrewName() async {
    try {
      final crew = await widget.crewService.getCrew(widget.crewId);
      if (crew != null && mounted) {
        setState(() {
          _crewName = crew.name;
        });
      }
    } catch (e) {
      // Handle error gracefully - crew name remains null if fetch fails
      if (mounted) {
        setState(() {
          _crewName = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      // The body is wrapped in SafeArea to avoid system intrusions (like the notch)
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildConditionalChips(),
            _buildTabBar(),
            // Expanded tells the content to take up all remaining vertical space
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildConditionalFab(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- BUILDER METHODS FOR UI COMPONENTS ---

  /// Builds the top header with group info and settings icon
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: kAccentColorOrange,
                child: Icon(Icons.group, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _crewName ?? 'Loading...',
                    style: const TextStyle(
                      color: kPrimaryTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '1 members • Journeyman',
                    style: TextStyle(color: kSecondaryTextColor, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              gradient: kCopperGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                // TODO: Handle settings tap
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the four conditional chips that change with the main tab
  Widget _buildConditionalChips() {
    List<String> currentChips = _chipData[_selectedTabIndex] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: currentChips.map((label) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                gradient: kCopperGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12, // smaller font for chips
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  /// Builds the main tab bar (Feed, Jobs, Chat, Members)
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kSurfaceColor.withValues(alpha:0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabItem(icon: Icons.dynamic_feed, label: 'Feed', index: 0),
          _buildTabItem(icon: Icons.work, label: 'Jobs', index: 1),
          _buildTabItem(icon: Icons.chat_bubble, label: 'Chat', index: 2),
          _buildTabItem(icon: Icons.group, label: 'Members', index: 3),
        ],
      ),
    );
  }

  /// Helper for creating a single item in the tab bar
  Widget _buildTabItem({required IconData icon, required String label, required int index}) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected ? kCopperGradient : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : kSecondaryTextColor,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : kSecondaryTextColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns the correct content widget based on the selected tab index
  Widget _buildContent() {
    switch (_selectedTabIndex) {
      case 0:
        return const FeedContent();
      case 1:
        return JobsContent(crewName: _crewName);
      case 2:
        return const ChatContent();
      case 3:
        return const MembersContent();
      default:
        return const FeedContent();
    }
  }

  /// Builds the Floating Action Button conditionally
  Widget? _buildConditionalFab() {
    switch (_selectedTabIndex) {
      case 0: // Feed
        return FloatingActionButton(
          onPressed: () {},
          backgroundColor: kAccentColorOrange,
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 1: // Jobs
         return FloatingActionButton(
          onPressed: () {},
          backgroundColor: kAccentColorOrange,
          child: const Icon(Icons.share, color: Colors.white),
        );
      case 3: // Members
        return FloatingActionButton(
          onPressed: () {},
          backgroundColor: kAccentColorOrange,
          child: const Icon(Icons.person_add, color: Colors.white),
        );
      case 2: // Chat has no FAB in the screenshot
      default:
        return null; // Return null to hide the FAB
    }
  }

  /// Builds the main Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedBottomNavIndex,
      onTap: (index) {
        setState(() {
          _selectedBottomNavIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed, // Ensures all labels are visible
      backgroundColor: kSurfaceColor,
      selectedItemColor: kAccentColorOrange,
      unselectedItemColor: kSecondaryTextColor,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
        BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Storm'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Locals'),
        BottomNavigationBarItem(icon: Icon(Icons.group_work), label: 'Crews'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}

// --- PLACEHOLDER CONTENT WIDGETS ---
// Replace these with your actual screen implementations.

class FeedContent extends StatelessWidget {
  const FeedContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: kAccentColorOrange),
          SizedBox(height: 16),
          Text(
            'Loading Public Feed...',
            style: TextStyle(color: kSecondaryTextColor),
          )
        ],
      ),
    );
  }
}

class JobsContent extends StatelessWidget {
  final String? crewName;
  
  const JobsContent({super.key, this.crewName});

  @override
  Widget build(BuildContext context) {
    // This mimics the Jobs screen UI
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jobs for ${crewName ?? 'Loading...'}', style: const TextStyle(color: kPrimaryTextColor, fontSize: 18, fontWeight: FontWeight.bold)),
              Chip(
                label: const Text('1 preferences'),
                backgroundColor: kAccentColorOrange.withValues(alpha:0.3),
                labelStyle: const TextStyle(color: kAccentColorOrange),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Job Types: Journeyman Lineman\nConstruction Types: Commercial, Industrial', style: TextStyle(color: kSecondaryTextColor)),
          const SizedBox(height: 16),
          
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search jobs...',
              hintStyle: const TextStyle(color: kSecondaryTextColor),
              prefixIcon: const Icon(Icons.search, color: kSecondaryTextColor),
              filled: true,
              fillColor: kSurfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Job Card Example
          _buildJobCard(),
        ],
      ),
    );
  }

  Widget _buildJobCard() {
    return Card(
      color: kSurfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kAccentColorOrange),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Local: 125', style: TextStyle(color: kPrimaryTextColor, fontWeight: FontWeight.bold)),
                Text('Classification: General', style: TextStyle(color: kPrimaryTextColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(color: kSecondaryTextColor, height: 20),
            _buildJobDetailRow('Contractor:', 'Asplundh Tree Expert Llc'),
            _buildJobDetailRow('Location:', 'N/a'),
            _buildJobDetailRow('Wages:', 'Contact for Rate'),
            _buildJobDetailRow('Hours:', '5/week'),
            _buildJobDetailRow('Start Date:', '8/12/2024'),
            _buildJobDetailRow('Per Diem:', 'Not Specified'),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Details Button
                OutlinedButton(onPressed: null, child: Text('Details')), // Use `onPressed: () {}` to enable
                SizedBox(width: 8),
                // Bid Now Button
                DecoratedBox(
                  decoration: BoxDecoration(gradient: kCopperGradient, borderRadius: BorderRadius.circular(8)),
                  child: ElevatedButton(
                    onPressed: null, // Use `onPressed: () {}` to enable
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                    child: Text('Bid Now', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(title, style: const TextStyle(color: kSecondaryTextColor, fontWeight: FontWeight.w600, width: 1.5)),
          Expanded(child: Text(value, style: const TextStyle(color: kPrimaryTextColor))),
        ],
      ),
    );
  }
}

class ChatContent extends StatelessWidget {
  const ChatContent({super.key});

  @override
  Widget build(BuildContext context) {
    // This layout prevents the "Bottom Overflow" error
    return Column(
      children: [
        // The chat messages area would go here, in an Expanded widget
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 80, color: kSecondaryTextColor.withValues(alpha:0.5)),
                const SizedBox(height: 16),
                const Text('Send a message to connect with your crew', style: TextStyle(color: kSecondaryTextColor)),
              ],
            ),
          ),
        ),
        // The message input field at the bottom
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: kSurfaceColor.withValues(alpha:0.5),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.attach_file, color: kSecondaryTextColor), onPressed: () {}),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: kSecondaryTextColor),
                filled: true,
                fillColor: kSurfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
             decoration: BoxDecoration(
              gradient: kCopperGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}

class MembersContent extends StatelessWidget {
  const MembersContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const [
        // Example member list item
        ListTile(
          leading: CircleAvatar(backgroundColor: kAccentColorOrange, child: Text('F')),
          title: Text('FOREMAN', style: TextStyle(color: kPrimaryTextColor)),
          subtitle: Text('Joined: 2025-10-24\nAvailable', style: TextStyle(color: kSecondaryTextColor)),
          trailing: Icon(Icons.chat, color: kAccentColorOrange),
          isThreeLine: true,
        ),
        // Add more members here...
      ],
    );
  }
}
