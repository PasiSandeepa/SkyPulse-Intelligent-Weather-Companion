import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const String _usersKey = 'users';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _currentUserKey = 'current_user';

  // ✅ Password hash කරන method
  String _hashPassword(String password) {
    final bytes = utf8.encode(password + 'skypulse_salt');
    return base64Encode(bytes);
  }

  Future<void> saveUser(String email, String password, String name) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();
    users[email] = {
      'name': name,
      'email': email,
      'password': _hashPassword(password), // ✅ plain text වෙනුවට hash
    };
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<Map<String, dynamic>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getString(_usersKey);
    if (usersString == null) return {};
    return jsonDecode(usersString);
  }

  Future<bool> getUser(String email, String password) async {
    final users = await getUsers();
    final user = users[email];
    if (user == null) return false;
    return user['password'] == _hashPassword(password); // ✅ hash compare
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> saveCurrentUser(String email, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _currentUserKey,
      jsonEncode({'email': email, 'name': name}),
    );
  }

  Future<Map<String, String>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_currentUserKey);
    if (userString == null) return null;
    return Map<String, String>.from(jsonDecode(userString));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_currentUserKey);
  }
}