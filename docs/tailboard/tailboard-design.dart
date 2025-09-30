// Mock random data utilities
String randomString(int minLength, int maxLength, bool includeLetters, bool includeNumbers, bool includeSymbols) {
  final chars = StringBuffer();
  if (includeLetters) chars.writeAll('abcdefghijklmnopqrstuvwxyz ');
  if (includeNumbers) chars.writeAll('0123456789');
  if (includeSymbols) chars.writeAll('!@#$%^&*()');
  if (chars.isEmpty) return '';
  final length = minLength + (DateTime.now().millisecondsSinceEpoch % (maxLength - minLength + 1));
  return List.generate(length, (index) => chars.toString()[DateTime.now().millisecondsSinceEpoch % chars.length]).join('');
}

int randomInteger(int min, int max) => min + (DateTime.now().millisecondsSinceEpoch % (max - min + 1));

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// Remove auto_size_text and simple_gradient_text; use standard Text for now until deps added

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../lib/shims/flutterflow_shims.dart';
import '../../../../lib/models/jobs_record.dart';
import '../../../../lib/models/users_record.dart';

// TailboardModel (included here for completeness)
class TailboardModel extends ChangeNotifier {
  AnimationInfo? animationInfo;
  JobsRecord? selectedJob;
  UsersRecord? user;
  final TextEditingController textController = TextEditingController();
  GlobalKey textFieldKey = GlobalKey();

  bool _mounted = true;

  TailboardModel() : super();

  factory TailboardModel.createModel(BuildContext context) {
    final model = TailboardModel();
    model.animationInfo = const AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effect: 'fadeIn',
      duration: Duration(milliseconds: 600),
    );
    return model;
  }

  void safeSetState(VoidCallback fn) {
    if (_mounted) fn();
  }

  void setState(VoidCallback fn) {
    if (_mounted) {
      fn();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    textController.dispose();
    super.dispose();
  }
}

// Stub queries (included here for self-contained)
Future<List<JobsRecord>> queryJobsRecord() async {
  // Stub with mock data
  return [
    JobsRecord(
      id: '1',
      company: 'Mock Company 1',
      location: 'Mock Location 1',
      classification: 'Lineman',
      jobTitle: 'Test Job',
      hours: 8,
      wage: 30.0,
      timestamp: DateTime.now(),
      deleted: false,
    ),
    JobsRecord(
      id: '2',
      company: 'Mock Company 2',
      location: 'Mock Location 2',
      classification: 'Foreman',
      jobTitle: 'Another Job',
      hours: 10,
      wage: 35.0,
      timestamp: DateTime.now(),
      deleted: false,
    ),
  ];
}

Future<List<UsersRecord>> queryUsersRecord() async {
  return [
    UsersRecord(
      uid: '1',
      email: 'user1@example.com',
      displayName: 'User 1',
      isActive: true,
      createdTime: DateTime.now(),
    ),
  ];
}

class TailboardWidget extends StatefulWidget {
  const TailboardWidget({super.key});

  @override
  State<TailboardWidget> createState() => _TailboardWidgetState();
}

class _TailboardWidgetState extends State<TailboardWidget> with TickerProviderStateMixin {
  late TailboardModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = TailboardModel.createModel(context);

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          const FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 400.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          const MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 400.0.ms,
            begin: const Offset(0.0, 100.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.primary,
        automaticallyImplyLeading: false,
        title: const Text(
          'Page Title',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        actions: [],
        centerTitle: false,
        elevation: 2,
      ),
      body: SafeArea(
        top: true,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: FlutterFlowTheme.primaryBackground,
              ),
              child: Align(
                alignment: AlignmentDirectional.center,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 40, 0, 0),
                        child: Text(
                          'Welcome to the Tailboard',
                        ),
                      ),
                    ),
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(
                          'This is where you can, fuck off!',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(30, 0, 30, 0),
                      child: ElevatedButton(
                        onPressed: () {
                          print('Button pressed ...');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add),
                            const Text('+ Create or Join a Crew'),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
                        child: Column(
                          children: [
                            const Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: TabBar(
                                labelColor: Color(0xFF4B39EF),
                                unselectedLabelColor: Color(0xFF757575),
                                labelStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                unselectedLabelStyle: TextStyle(
                                  fontSize: 16,
                                ),
                                indicatorColor: FlutterFlowTheme.primary,
                                tabs: [
                                  Tab(
                                    text: 'Feed',
                                    icon: Icon(
                                      Icons.feed,
                                      color: FlutterFlowTheme.secondary,
                                    ),
                                  ),
                                  Tab(
                                    text: 'Jobs',
                                    icon: const Icon(
                                      Icons.forest,
                                      color: FlutterFlowTheme.secondary,
                                    ),
                                  ),
                                  Tab(
                                    text: 'Chat',
                                    icon: const Icon(
                                      Icons.chat_bubble_outline_outlined,
                                      color: FlutterFlowTheme.secondary,
                                    ),
                                  ),
                                  Tab(
                                    text: 'Members',
                                    icon: const Icon(
                                      Icons.people_alt_outlined,
                                      color: FlutterFlowTheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Builder(
                                        builder: (context) {
                                          final feedPosts = List.generate(
                                            randomInteger(5, 5),
                                            (index) => randomString(
                                              0,
                                              0,
                                              true,
                                              false,
                                              false,
                                            ),
                                          );

                                          return ListView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemCount: feedPosts.length,
                                            itemBuilder: (context, feedPostsIndex) {
                                              final feedPostsItem = feedPosts[feedPostsIndex];
                                              return Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      const BoxShadow(
                                                        blurRadius: 5,
                                                        color: Color(0x3416202A),
                                                        offset: Offset(0, 3),
                                                      ),
                                                    ],
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(
                                                      color: FlutterFlowTheme.secondary,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(4),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsetsDirectional.fromSTEB(8, 12, 8, 8),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.max,
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius: BorderRadius.circular(40),
                                                                child: Image.network(
                                                                  'https://images.unsplash.com/photo-1580489944761-15a19d654956?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MzR8fHByb2ZpbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=800&q=60',
                                                                  width: 40,
                                                                  height: 40,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                                child: Text(
                                                                  '[Username]',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.w500,
                                                                    fontSize: 16,
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                                                                child: Text(
                                                                  '2h',
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsetsDirectional.fromSTEB(8, 0, 8, 4),
                                                          child: Text(
                                                            'Nice outdoor courts, solid concrete and good hoops for the neighborhood.',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                        Divider(
                                                          height: 8,
                                                          thickness: 1,
                                                          indent: 4,
                                                          endIndent: 4,
                                                          color: Color(0xFFF1F4F8),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsetsDirectional.fromSTEB(4, 0, 4, 4),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.max,
                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.max,
                                                                  children: [
                                                                    Icon(
                                                                      Icons.mode_comment_outlined,
                                                                      color: Color(0xFF57636C),
                                                                      size: 24,
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(4, 0, 8, 0),
                                                                      child: Text(
                                                                        '4',
                                                                        style: TextStyle(
                                                                          fontSize: 14,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.max,
                                                                  children: [
                                                                    Icon(
                                                                      Icons.favorite_border_rounded,
                                                                      color: Color(0xFF57636C),
                                                                      size: 24,
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(4, 0, 8, 0),
                                                                      child: Text(
                                                                        '4',
                                                                        style: TextStyle(
                                                                          fontSize: 14,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                                                                child: Icon(
                                                                  Icons.bookmark_border,
                                                                  color: Color(0xFF57636C),
                                                                  size: 24,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                                                                child: Icon(
                                                                  Icons.ios_share,
                                                                  color: Color(0xFF57636C),
                                                                  size: 24,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      // Jobs tab - stub list for demo
                                      FutureBuilder<List<JobsRecord>>(
                                        future: queryJobsRecord(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                                            return const Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          }
                                          final listViewJobsRecordList = snapshot.data!;
                                          return ListView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemCount: listViewJobsRecordList.length,
                                            itemBuilder: (context, listViewIndex) {
                                              final listViewJobsRecord = listViewJobsRecordList[listViewIndex];
                                              return Padding(
                                                padding: const EdgeInsets.all(10),
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0x19666666),
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: FlutterFlowTheme.secondary,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(15),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                                        Row(
                                                          mainAxisSize: MainAxisSize.max,
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Local: ${listViewJobsRecord.local ?? 'N/A'}',
                                                              style: const TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                              child: VerticalDivider(
                                                                thickness: 2,
                                                                color: FlutterFlowTheme.secondary,
                                                              ),
                                                            ),
                                                            Text(
                                                              listViewJobsRecord.classification,
                                                              style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisSize: MainAxisSize.max,
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                                                                  child: Icon(
                                                                    Icons.access_time,
                                                                    color: FlutterFlowTheme.primary,
                                                                    size: 18,
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 10),
                                                                const Text('Posted 2h ago'),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                                                                  child: Icon(
                                                                    Icons.location_on,
                                                                    color: Color(0xD1000000),
                                                                    size: 18,
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 10),
                                                                Text(
                                                                  'Location: ${listViewJobsRecord.location}',
                                                                  style: const TextStyle(
                                                                    fontSize: 14,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisSize: MainAxisSize.max,
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                                                                  child: FaIcon(
                                                                    FontAwesomeIcons.clock,
                                                                    color: Color(0xD1000000),
                                                                    size: 18,
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 10),
                                                                Text(
                                                                  'Hours: ${listViewJobsRecord.hours}',
                                                                  style: const TextStyle(
                                                                    fontSize: 14,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                                                                  child: FaIcon(
                                                                    FontAwesomeIcons.dollarSign,
                                                                    color: Color(0xD1000000),
                                                                    size: 18,
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 10),
                                                                Text(
                                                                  'Per Diem: \$${listViewJobsRecord.perDiem}',
                                                                  style: const TextStyle(
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: ElevatedButton.icon(
                                                                onPressed: () {
                                                                  print('View Details Button pressed ...');
                                                                },
                                                                icon: const Icon(Icons.visibility, color: FlutterFlowTheme.primary),
                                                                label: const Text('View Details'),
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor: FlutterFlowTheme.primary,
                                                                  foregroundColor: Colors.white,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 19),
                                                            Expanded(
                                                              child: OutlinedButton.icon(
                                                                onPressed: () {
                                                                  print('Bid Now Button pressed ...');
                                                                },
                                                                icon: const Icon(Icons.gavel, color: Colors.white),
                                                                label: const Text('Bid now'),
                                                                style: OutlinedButton.styleFrom(
                                                                  foregroundColor: Colors.white,
                                                                  side: const BorderSide(width: 1.5),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                  ),
                                                                  backgroundColor: FlutterFlowTheme.secondary,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      // Chat tab - stub
                                      const Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Container(
                                                    width: 185.5,
                                                    height: 72.3,
                                                    decoration: BoxDecoration(
                                                      color: Color(0x8E220ED8),
                                                      borderRadius: BorderRadius.circular(24),
                                                      border: Border.all(
                                                        color: FlutterFlowTheme.secondary,
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    child: const Padding(
                                                      padding: EdgeInsets.all(10),
                                                      child: Text(
                                                        'Hi I Found this job out of 111 got 200 a day it's looking pretty good',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // More chat stubs...
                                        ],
                                      ),
                                      // Members tab - stub
                                      FutureBuilder<List<UsersRecord>>(
                                        future: queryUsersRecord(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                                            return const Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          }
                                          final listViewUsersRecordList = snapshot.data!;
                                          return ListView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemCount: listViewUsersRecordList.length,
                                            itemBuilder: (context, listViewIndex) {
                                              final listViewUsersRecord = listViewUsersRecordList[listViewIndex];
                                              return Padding(
                                                padding: const EdgeInsets.all(10),
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.primaryBackground,
                                                    boxShadow: [
                                                      const BoxShadow(
                                                        blurRadius: 0,
                                                        color: FlutterFlowTheme.alternate,
                                                        offset: const Offset(0.0, 1),
                                                      ),
                                                    ],
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(
                                                      color: FlutterFlowTheme.secondary,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets.all(2),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(40),
                                                            child: Image.network(
                                                              'https://images.unsplash.com/photo-1633332755192-727a05c4013d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8dXNlcnxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=900&q=60',
                                                              width: 60,
                                                              height: 60,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.max,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                'Randy Rudolph',
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              Text(
                                                                'name@domain.com',
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.all(4),
                                                          child: Icon(
                                                            Icons.keyboard_arrow_right_rounded,
                                                            color: FlutterFlowTheme.secondary,
                                                            size: 24,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Bottom row with Autocomplete and icon
                        const Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      'Hello World',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Add the animation
                ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation']!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
