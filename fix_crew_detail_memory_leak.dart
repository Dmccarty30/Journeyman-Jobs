// MEMORY LEAK FIX - CrewDetailScreen
// CRITICAL: TabController and stream subscription memory leak fix

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/crew.dart';
import '../models/crew_member.dart';
import '../models/group_bid.dart';
import '../providers/crew_communication_provider.dart';
import '../services/crew_service.dart';
import '../widgets/crew_member_card.dart';

/// FIXED: Added proper dispose() method to prevent battery drain
/// during electrical work shifts
class CrewDetailScreen extends StatefulWidget {
  final String crewId;
  final String currentUserId;

  const CrewDetailScreen({
    Key? key,
    required this.crewId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<CrewDetailScreen> createState() => _CrewDetailScreenState();
}

class _CrewDetailScreenState extends State<CrewDetailScreen>
    with TickerProviderStateMixin {
  // Controllers that need disposal
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _bidAmountController = TextEditingController();
  final TextEditingController _bidNotesController = TextEditingController();

  late CrewService _crewService;

  // Stream subscriptions that need cancellation
  StreamSubscription<Crew>? _crewSubscription;
  StreamSubscription<List<CrewMember>>? _membersSubscription;
  StreamSubscription<List<GroupBid>>? _bidsSubscription;

  Crew? _crew;
  List<CrewMember> _members = [];
  List<GroupBid> _bids = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _crewService = CrewService();
    _initializeStreams();
  }

  void _initializeStreams() {
    // Initialize stream subscriptions
    _crewSubscription = _crewService
        .getCrewStream(widget.crewId)
        .listen((crew) {
      if (mounted) {
        setState(() {
          _crew = crew;
          _isLoading = false;
        });
      }
    });

    _membersSubscription = _crewService
        .getCrewMembersStream(widget.crewId)
        .listen((members) {
      if (mounted) {
        setState(() {
          _members = members;
        });
      }
    });

    _bidsSubscription = _crewService
        .getGroupBidsStream(widget.crewId)
        .listen((bids) {
      if (mounted) {
        setState(() {
          _bids = bids;
        });
      }
    });
  }

  // CRITICAL MEMORY LEAK FIX: Proper disposal of all resources
  @override
  void dispose() {
    // Dispose controllers
    _tabController.dispose();
    _scrollController.dispose();
    _bidAmountController.dispose();
    _bidNotesController.dispose();

    // Cancel stream subscriptions
    _crewSubscription?.cancel();
    _membersSubscription?.cancel();
    _bidsSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_crew?.name ?? 'Crew Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Members'),
            Tab(text: 'Bids'),
            Tab(text: 'Activity'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMembersTab(),
          _buildBidsTab(),
          _buildActivityTab(),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _members.length,
      itemBuilder: (context, index) {
        return CrewMemberCard(member: _members[index]);
      },
    );
  }

  Widget _buildBidsTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _bidAmountController,
                decoration: InputDecoration(
                  labelText: 'Bid Amount',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              TextField(
                controller: _bidNotesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitBid,
                child: Text('Submit Group Bid'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _bids.length,
            itemBuilder: (context, index) {
              final bid = _bids[index];
              return ListTile(
                title: Text('\$${bid.amount}'),
                subtitle: Text(bid.notes ?? ''),
                trailing: Text(bid.status.toString()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTab() {
    return Center(
      child: Text('Activity feed coming soon'),
    );
  }

  void _submitBid() {
    final amount = double.tryParse(_bidAmountController.text);
    if (amount != null) {
      _crewService.submitGroupBid(
        crewId: widget.crewId,
        amount: amount,
        notes: _bidNotesController.text,
      );
      _bidAmountController.clear();
      _bidNotesController.clear();
    }
  }
}