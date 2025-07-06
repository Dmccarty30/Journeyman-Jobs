import '/backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'locals_model.dart';
export 'locals_model.dart';

class LocalsWidget extends StatefulWidget {
  const LocalsWidget({super.key});

  static String routeName = 'locals';
  static String routePath = '/locals';

  @override
  State<LocalsWidget> createState() => _LocalsWidgetState();
}

class _LocalsWidgetState extends State<LocalsWidget> {
  late LocalsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = LocalsModel();
    _model.emailLoginTextController = TextEditingController();
    _model.emailLoginFocusNode = FocusNode();
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Local Unions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
        elevation: 2.0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              // Search bar
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _model.emailLoginTextController,
                          focusNode: _model.emailLoginFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Search local unions here',
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.0,
                            ),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: 14.0,
                            height: 2.0,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.search_rounded,
                        color: Colors.black.withOpacity(0.4),
                        size: 24.0,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              // Locals list
              Expanded(
                child: StreamBuilder<List<LocalsRecord>>(
                  stream: queryLocalsRecord(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      );
                    }
                    
                    List<LocalsRecord> localsRecordList = snapshot.data!;
                    
                    return ListView.separated(
                      itemCount: localsRecordList.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.0),
                      itemBuilder: (context, index) {
                        final localsRecord = localsRecordList[index];
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Local union name
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Local ',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: localsRecord.localUnion,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                // Location
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.black.withOpacity(0.8),
                                      size: 18.0,
                                    ),
                                    SizedBox(width: 10.0),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Location: ',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 12.0,
                                              ),
                                            ),
                                            TextSpan(
                                              text: localsRecord.address,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 12.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                // Meeting schedule
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.black.withOpacity(0.8),
                                      size: 18.0,
                                    ),
                                    SizedBox(width: 10.0),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Next Meeting: ',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 12.0,
                                              ),
                                            ),
                                            TextSpan(
                                              text: localsRecord.meetingSchedule,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 12.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                // View details button
                                SizedBox(
                                  width: double.infinity,
                                  height: 40.0,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      print('ViewDetailsButton pressed ...');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[100],
                                      elevation: 0.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: Text(
                                      'View more details',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

