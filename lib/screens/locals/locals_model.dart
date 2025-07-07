import 'package:flutter/material.dart';

class LocalsModel extends ChangeNotifier {
  // Model for IBEW locals screen
  // This can be expanded with actual local data and functionality
  
  final List<String> _locals = [
    'IBEW Local 1',
    'IBEW Local 3', 
    'IBEW Local 11',
    'IBEW Local 46',
    'IBEW Local 58',
  ];
  
  List<String> get locals => _locals;
  
  void addLocal(String local) {
    _locals.add(local);
    notifyListeners();
  }
  
  void removeLocal(String local) {
    _locals.remove(local);
    notifyListeners();
  }
}

// Helper function to create model (replaces FlutterFlow createModel)
T createModel<T>(BuildContext context, T Function() create) {
  return create();
}
