
import 'package:flutter/material.dart';

class MainScreenDark extends StatefulWidget {
  const MainScreenDark({super.key});

  @override
  State<MainScreenDark> createState() => _MainScreenDarkState();
}

class _MainScreenDarkState extends State<MainScreenDark> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildFolderTabs(),
            _buildTabBar(),
            _buildTabBarView(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Icon(Icons.groups, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'test',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '1 members • Journeyman',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF97316).withValues(alpha:0.5),
                  blurRadius: 15.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          _buildFolderTab('Channels'),
          const SizedBox(width: 8),
          _buildFolderTab('Files'),
          const SizedBox(width: 8),
          _buildFolderTab('History'),
          const SizedBox(width: 8),
          _buildFolderTab('Crew Chat'),
        ],
      ),
    );
  }

  Widget _buildFolderTab(String text) {
    return Expanded(
      child: CustomPaint(
        painter: _FolderPainter(color: const Color(0xFFD1D5DB)),
        child: Container(
          padding: const EdgeInsets.only(top: 12, bottom: 12, left: 8, right: 8),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 60,
      color: const Color(0xFF1F2937),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        indicator: BoxDecoration(
          color: const Color(0xFFF97316),
          borderRadius: BorderRadius.circular(8.0),
        ),
        tabs: const [
          Tab(icon: Icon(Icons.rss_feed), text: 'Feed'),
          Tab(icon: Icon(Icons.work), text: 'Jobs'),
          Tab(icon: Icon(Icons.chat_bubble), text: 'Chat'),
          Tab(icon: Icon(Icons.people), text: 'Members'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: TabBarView(
          controller: _tabController,
          children: [
            const Center(child: Text('Feed Content')),
            const Center(child: Text('Jobs Content')),
            _buildChatScreen(),
            const Center(child: Text('Members Content')),
          ],
        ),
      ),
    );
  }

  Widget _buildChatScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Chat Header
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFF97316),
                child: Text('T', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('test', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('1 members', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.people_outline, color: Colors.grey),
              const SizedBox(width: 16),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
          const Divider(height: 32),
          // Empty Chat Area
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0xFFF3F4F6),
                  child: Icon(Icons.chat_bubble_outline, color: Color(0xFF9CA3AF), size: 48),
                ),
                SizedBox(height: 16),
                Text(
                  'Send a message to connect with your team',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          // Message Input
          const Divider(height: 32),
          Row(
            children: [
              const Icon(Icons.attach_file, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                backgroundColor: Color(0xFFF97316),
                child: Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FolderPainter extends CustomPainter {
  final Color color;
  _FolderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    const tabHeight = 8.0;
    const tabWidthPercent = 0.45;
    const radius = Radius.circular(6.0);

    // Main body
    path.moveTo(0, tabHeight);
    path.lineTo(0, size.height - radius.y);
    path.arcToPoint(Offset(radius.x, size.height), radius: radius, clockwise: false);
    path.lineTo(size.width - radius.x, size.height);
    path.arcToPoint(Offset(size.width, size.height - radius.y), radius: radius, clockwise: false);
    path.lineTo(size.width, tabHeight);
    path.lineTo(size.width * tabWidthPercent + 12, tabHeight);
    
    // Top tab part
    path.arcToPoint(Offset(size.width * tabWidthPercent, 0), radius: const Radius.circular(8), clockwise: false);
    path.lineTo(radius.x, 0);
    path.arcToPoint(const Offset(0, tabHeight), radius: radius, clockwise: false);
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
