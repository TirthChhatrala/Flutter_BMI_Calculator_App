import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  // Register a new user
  Future<bool> register(String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if username already exists
      final String? usersJson = prefs.getString(Constants.keyUserData);
      List<User> users = [];
      
      if (usersJson != null) {
        final List<dynamic> decodedUsers = jsonDecode(usersJson);
        users = decodedUsers.map((user) => User.fromMap(user)).toList();
        
        // Check if username already exists
        if (users.any((user) => user.username == username)) {
          return false;
        }
      }
      
      // Add new user
      users.add(User(username: username, password: password));
      
      // Save updated users list
      await prefs.setString(Constants.keyUserData, jsonEncode(users.map((user) => user.toMap()).toList()));
      
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }
  
  // Login user
  Future<bool> login(String username, String password) async {
    try {
      // Check for admin login
      if (username == Constants.adminUsername && password == Constants.adminPassword) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(Constants.keyIsLoggedIn, true);
        await prefs.setString(Constants.keyUsername, username);
        await prefs.setBool(Constants.keyIsAdmin, true);
        return true;
      }
      
      // Check for regular user login
      final prefs = await SharedPreferences.getInstance();
      final String? usersJson = prefs.getString(Constants.keyUserData);
      
      if (usersJson != null) {
        final List<dynamic> decodedUsers = jsonDecode(usersJson);
        final users = decodedUsers.map((user) => User.fromMap(user)).toList();
        
        // Find user with matching credentials
        final user = users.firstWhere(
          (user) => user.username == username && user.password == password,
          orElse: () => User(username: '', password: ''),
        );
        
        if (user.username.isNotEmpty) {
          await prefs.setBool(Constants.keyIsLoggedIn, true);
          await prefs.setString(Constants.keyUsername, username);
          await prefs.setBool(Constants.keyIsAdmin, false);
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }
  
  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.keyIsLoggedIn, false);
    await prefs.remove(Constants.keyUsername);
    await prefs.remove(Constants.keyIsAdmin);
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Constants.keyIsLoggedIn) ?? false;
  }
  
  // Check if current user is admin
  Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Constants.keyIsAdmin) ?? false;
  }
  
  // Get current username
  Future<String> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.keyUsername) ?? '';
  }
}