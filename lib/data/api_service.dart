import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mini_app/domain/models/user.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000'; 

  Future<AuthResponse> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return AuthResponse.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

// lib/data/api_service.dart
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🌐 Appel API login: $email');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('📡 Statut réponse: ${response.statusCode}');
      print('📦 Corps réponse: ${response.body}');

      if (response.statusCode == 200) {
        // Succès - parser le JSON
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw Exception('Format de réponse invalide');
        }
      } else {
        // Erreur HTTP - essayer de parser le message d'erreur
        String errorMessage = 'Erreur de connexion';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? errorMessage;
        } catch (e) {
          // Si ce n'est pas du JSON, utiliser le corps brut
          errorMessage = response.body.isNotEmpty
              ? response.body
              : 'Erreur ${response.statusCode}';
        }

        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      print('❌ ClientException: $e');
      throw Exception('Problème de connexion au serveur');
    } on TimeoutException catch (e) {
      print('❌ Timeout: $e');
      throw Exception('Délai d\'attente dépassé');
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<OtpResponse> sendOtp({required String userIdOrEmail}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userIdOrEmail': userIdOrEmail,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OtpResponse(
          success: data['success'],
          expiresIn: data['expiresIn'],
        );
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String userIdOrEmail,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userIdOrEmail': userIdOrEmail,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Verification failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? phone,
    String? country,
    String? currency,
    String? language,
  }) async {
    try {
      final userId = token.split('_')[1];

      final response = await http.put(
        Uri.parse('$baseUrl/profile/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'country': country,
          'currency': currency,
          'language': language,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Update failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
