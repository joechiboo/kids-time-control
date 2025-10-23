import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  String _userRole = 'child'; // 'parent' or 'child'
  String _userId = '';
  String _familyId = '';
  bool _isLoggedIn = false;

  String get userRole => _userRole;
  String get userId => _userId;
  String get familyId => _familyId;
  bool get isLoggedIn => _isLoggedIn;

  void setUserRole(String role) {
    _userRole = role;
    notifyListeners();
  }

  void setUserId(String id) {
    _userId = id;
    notifyListeners();
  }

  void setFamilyId(String id) {
    _familyId = id;
    notifyListeners();
  }

  void login(String userId, String familyId, String role) {
    _userId = userId;
    _familyId = familyId;
    _userRole = role;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _userId = '';
    _familyId = '';
    _userRole = 'child';
    _isLoggedIn = false;
    notifyListeners();
  }
}