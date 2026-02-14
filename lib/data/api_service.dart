import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mini_app/domain/models/user.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  ApiService() {
    print('⚙️ ApiService initialisé avec: $baseUrl');
  }

  // ==================== INSCRIPTION ====================
  Future<AuthResponse> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      print('📝 Inscription: $email');

      // Vérifier si l'email existe
      final checkResponse = await http.get(
        Uri.parse('$baseUrl/users?email=$email'),
      );

      if (checkResponse.statusCode == 200) {
        final List existingUsers = jsonDecode(checkResponse.body);
        if (existingUsers.isNotEmpty) {
          throw Exception('Email already exists');
        }
      }

      // Créer l'utilisateur
      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'isEmailVerified': false,
        'phone': '',
        'country': '',
        'currency': '',
        'language': '',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newUser),
      );

      if (response.statusCode == 201) {
        final createdUser = jsonDecode(response.body);
        return AuthResponse(
          userId: createdUser['id'],
          token:
              'token_${createdUser['id']}_${DateTime.now().millisecondsSinceEpoch}',
          requiresEmailVerification: true,
        );
      } else {
        throw Exception('Signup failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ==================== CONNEXION ====================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🌐 Login: $email');

      final response = await http.get(
        Uri.parse('$baseUrl/users?email=$email&password=$password'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);

        if (users.isEmpty) {
          throw Exception('Invalid email or password');
        }

        final user = users.first;
        final token =
            'token_${user['id']}_${DateTime.now().millisecondsSinceEpoch}';

        return {
          'token': token,
          'user': user,
        };
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ==================== ENVOI OTP ====================
  Future<OtpResponse> sendOtp({required String userIdOrEmail}) async {
    // Simulation pour le développement
    await Future.delayed(const Duration(seconds: 1));
    print('📧 OTP envoyé à $userIdOrEmail (code: 123456)');
    return OtpResponse(success: true, expiresIn: 300);
  }

  // ==================== VÉRIFICATION OTP ====================
  Future<Map<String, dynamic>> verifyOtp({
    required String userIdOrEmail,
    required String code,
  }) async {
    if (code == '123456') {
      // Marquer l'utilisateur comme vérifié
      try {
        // Récupérer l'utilisateur
        final response = await http.get(
          Uri.parse('$baseUrl/users?email=$userIdOrEmail'),
        );

        if (response.statusCode == 200) {
          final List users = jsonDecode(response.body);
          if (users.isNotEmpty) {
            final user = users.first;
            user['isEmailVerified'] = true;

            // Mettre à jour
            await http.put(
              Uri.parse('$baseUrl/users/${user['id']}'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(user),
            );
          }
        }
      } catch (e) {
        print('Erreur mise à jour: $e');
      }

      return {'verified': true};
    }
    throw Exception('Invalid verification code');
  }

  // ==================== MISE À JOUR PROFIL ====================
  Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? phone,
    String? country,
    String? currency,
    String? language,
  }) async {
    try {
      final userId = token.split('_')[1];

      // Récupérer l'utilisateur actuel
      final getResponse = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
      );

      if (getResponse.statusCode == 200) {
        final user = jsonDecode(getResponse.body);

        // Mettre à jour les champs
        final updatedUser = {
          ...user,
          if (phone != null) 'phone': phone,
          if (country != null) 'country': country,
          if (currency != null) 'currency': currency,
          if (language != null) 'language': language,
        };

        final putResponse = await http.put(
          Uri.parse('$baseUrl/users/$userId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updatedUser),
        );

        if (putResponse.statusCode == 200) {
          return {'user': updatedUser};
        }
      }

      throw Exception('Update failed');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
