# mini_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Architecture
   #folder presentation : les screens (UI)
   #folder data : api client
   #folder domain :contients models
## Technologie
SharedPreferences => Stockage local des données 
HTTP => Communication avec l'API 
intl_phone_field => Champ de téléphone international
JSON Server => API mock pour le développement 
            installation de json server : npm install -g json-server
            creer le fichier db.json qui stock les donnees 
            creer le fichier routes.json pour configurer les routes
            creer le fichier server.js personnalisé avec logique métier
            package.json : Dépendances Node
            lancer le serveur : json-server --watch db.json --port 3000
Lorsque l utilisateur creer leur compte les donnees sont stocker dans db.json et lorsqu il se connecte a leur compte une formulaire s affiche avec toutes ses informations.

### **Services**

1. **ApiService** (`lib/data/api_service.dart`)
   - Communication avec le backend
   - Gestion des requêtes HTTP
   - Endpoints : signup, login, OTP, profil

2. **StorageService** (`lib/services/storage_service.dart`)
   - Persistance locale avec SharedPreferences
   - Gestion des utilisateurs et sessions
   - Cache local des données

#### Le code OTP de test est 123456

### **Gestion des Tokens**
```dart
// Format simplifié pour le développement
token = 'token_${user.id}_${timestamp}'

#### Le test
pour tester on execute la commande : flutter test test/api_login_test.dart
voici le resultat de test:


Test 1: Récupération des utilisateurs...
   Statut: 200
   ✅ Succès! 3 utilisateur(s) trouvé(s)

Test 2: Recherche de jean@example.com...
   ✅ Utilisateur trouvé:

Test 3: Tentative de login...
   ✅ Login réussi!
   🔑 Token: token_1_1771096219784


00:02 +1: All tests passed!
