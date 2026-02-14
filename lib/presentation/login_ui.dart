import 'package:flutter/material.dart';
import 'package:mini_app/data/api_service.dart';

import 'package:mini_app/data/storage_service.dart';
import 'package:mini_app/presentation/constant/CustomPasswordField.dart';
import 'package:mini_app/presentation/constant/custom_text_field.dart';
import 'package:mini_app/domain/models/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final StorageService _storage = StorageService();
  final ApiService _apiService = ApiService();

  String email = '';
  String password = '';
  bool isLoading = false;

  void login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      print('🔄 Tentative de connexion pour: $email');

      // 1. Appel à l'API de connexion
      final response = await _apiService.login(
        email: email.trim().toLowerCase(),
        password: password,
      );

      print('✅ Connexion API réussie!');

      // 2. Récupérer les données utilisateur de la réponse
      final userData = response['user'] as Map<String, dynamic>;

      // 3. Créer un objet User à partir des données
      final user = User(
        id: userData['id'],
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        email: userData['email'],
        password: userData[
            'password'], // En production, ne pas stocker le mot de passe
        isEmailVerified: userData['isEmailVerified'] ?? false,
        phone: userData['phone'] ?? '',
        country: userData['country'] ?? '',
        currency: userData['currency'] ?? '',
        language: userData['language'] ?? '',
      );

      // 4. Sauvegarder l'utilisateur dans StorageService
      await _storage.saveUser(user);
      await _storage.setCurrentUser(user);

      

      setState(() {
        isLoading = false;
      });

      if (mounted) {
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bienvenue ${user.firstName} !'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Naviguer vers la page d'accueil
        Navigator.pushReplacementNamed(context, '/account');
      }
    } catch (e) {
      print('❌ Erreur de connexion: $e');

      setState(() {
        isLoading = false;
      });

      if (mounted) {
        // Message d'erreur convivial
        String errorMessage = _getUserFriendlyErrorMessage(e.toString());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _getUserFriendlyErrorMessage(String error) {
    if (error.contains('Invalid email or password')) {
      return 'Email ou mot de passe incorrect';
    } else if (error.contains('Network error')) {
      return 'Problème de connexion au serveur';
    } else if (error.contains('SocketException') ||
        error.contains('Connection refused')) {
      return 'Serveur inaccessible. Vérifiez que JSON Server est lancé (port 3000)';
    } else if (error.contains('timeout')) {
      return 'Délai d\'attente dépassé';
    } else {
      // Enlever le préfixe "Exception: " si présent
      final cleanError = error.replaceAll('Exception: ', '');
      return 'Erreur: $cleanError';
    }
  }

  // Fonction pour le mot de passe oublié

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Welcome to ',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Couleur pour "Welcome to"
                          ),
                        ),
                        TextSpan(
                          text: 'Morocco',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors
                                .orange, // Couleur différente pour "Morocco"
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sign in to continue your journey',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 35),

                  // Google Sign In Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      icon: Image.network(
                        "https://cdn-icons-png.flaticon.com/512/2991/2991148.png",
                        height: 20,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error, size: 20),
                      ),
                      label: const Text(
                        "Continue with Google",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        // Implémenter Google Sign In
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Google Sign In à implémenter'),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Separator
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "or sign in with email",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Email Field
                  CustomTextField(
                    label: "Email",
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    onChanged: (value) => setState(() => email = value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return "Invalid email format";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  // Password Field
                  CustomPasswordField(
                    label: "Password",
                    onChanged: (value) => setState(() => password = value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      }
                      if (value.length < 8) {
                        return "Password must be at least 8 characters";
                      }

                      // Vérifier au moins un chiffre
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return "Password must contain at least one number";
                      }

                      // Vérifier au moins une lettre
                      if (!value.contains(RegExp(r'[a-zA-Z]'))) {
                        return "Password must contain at least one letter";
                      }
                      return null;
                    },
                  ),

                  // Forgot Password
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fonctionnalité à implémenter'),
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: isLoading ? null : login,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Login"),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "OR",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/onboarding');
                          },
                          child: const Text("Create account"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
