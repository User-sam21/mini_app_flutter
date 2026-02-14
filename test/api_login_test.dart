import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Version simplifiée sans utiliser ApiService
void main() {
  test('Test direct de l\'API JSON Server', () async {
    print('\n🚀 TEST DIRECT DE L\'API');
    print('══════════════════════════════');

    // 1. Tester l'accès à la liste des utilisateurs
    print('📡 Test 1: Récupération des utilisateurs...');
    try {
      final response = await http
          .get(
            Uri.parse('http://localhost:3000/users'),
          )
          .timeout(const Duration(seconds: 5));

      print('   Statut: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List users = jsonDecode(response.body);
        print('   ✅ Succès! ${users.length} utilisateur(s) trouvé(s)');
       
      } else {
        print('   ❌ Erreur: ${response.statusCode}');
      }
    } catch (e) {
      print('   ❌ Exception: $e');
    }

    print('\n📡 Test 2: Recherche de jean@example.com...');
    try {
      // 2. Chercher l'utilisateur spécifique
      final response = await http
          .get(
            Uri.parse('http://localhost:3000/users?email=jean@example.com'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List users = jsonDecode(response.body);
        if (users.isNotEmpty) {
          print('   ✅ Utilisateur trouvé:');
         
        } else {
          print('   ❌ Utilisateur non trouvé');
          print('   💡 Vérifiez que jean@example.com existe dans db.json');
        }
      }
    } catch (e) {
      print('   ❌ Exception: $e');
    }

    print('\n📡 Test 3: Tentative de login...');
    try {
      // 3. Simuler un login (méthode alternative)
      final response = await http
          .get(
            Uri.parse(
                'http://localhost:3000/users?email=jean@example.com&password=password123'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List users = jsonDecode(response.body);
        if (users.isNotEmpty) {
          print('   ✅ Login réussi!');
          print(
              '   🔑 Token: token_${users.first['id']}_${DateTime.now().millisecondsSinceEpoch}');
        } else {
          print('   ❌ Identifiants invalides');
        }
      }
    } catch (e) {
      print('   ❌ Exception: $e');
    }

    print('══════════════════════════════\n');
  });
}
