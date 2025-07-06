import 'package:flutter/material.dart';

class UnionsModel extends ChangeNotifier {
  // Placeholder model for unions screen
  // This can be expanded with actual union data and functionality
  
  List<String> _unions = [
    'IBEW Local 1',
    'IBEW Local 3', 
    'IBEW Local 11',
    'IBEW Local 46',
    'IBEW Local 58',
  ];
  
  List<String> get unions => _unions;
  
  void addUnion(String union) {
    _unions.add(union);
    notifyListeners();
  }
  
  void removeUnion(String union) {
    _unions.remove(union);
    notifyListeners();
  }
}

// Helper function to create model (replaces FlutterFlow createModel)
T createModel<T>(BuildContext context, T Function() create) {
  return create();
}
