import 'dart:convert';
import 'package:mini_app/domain/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StorageService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  // Sauvegarder un utilisateur
  Future<User> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Récupérer la liste des utilisateurs existants
    List<User> users = await getUsers();
    
    // Générer un ID unique
    final newUser = user.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    
    users.add(newUser);
    
    // Sauvegarder la liste mise à jour
    final usersJson = users.map((u) => jsonEncode(u.toJson())).toList();
    await prefs.setStringList(_usersKey, usersJson);
    
    return newUser;
  }

  // Récupérer tous les utilisateurs
  Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];
    
    return usersJson.map((jsonString) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return User.fromJson(json);
    }).toList();
  }

  // Trouver un utilisateur par email
  Future<User?> findUserByEmail(String email) async {
    final users = await getUsers();
    try {
      return users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // Mettre à jour un utilisateur
  Future<User?> updateUser(User updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();
    
    final index = users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;
      
      final usersJson = users.map((u) => jsonEncode(u.toJson())).toList();
      await prefs.setStringList(_usersKey, usersJson);
      
      // Mettre à jour l'utilisateur courant si c'est le même
      final currentUser = await getCurrentUser();
      if (currentUser?.id == updatedUser.id) {
        await setCurrentUser(updatedUser);
      }
      
      return updatedUser;
    }
    return null;
  }

  // Sauvegarder l'utilisateur courant
  Future<void> setCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    await prefs.setString(_tokenKey, 'token_${user.id}');
  }

  // Récupérer l'utilisateur courant
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Récupérer le token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.remove(_tokenKey);
  }

  // Vérifier si un email existe déjà
  Future<bool> emailExists(String email) async {
    final user = await findUserByEmail(email);
    return user != null;
  }
}
