// lib/screens/personal_info_screen.dart
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mini_app/data/storage_service.dart';
import 'package:mini_app/presentation/constant/custom_text_field.dart';
import 'package:mini_app/domain/models/user.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final StorageService _storage = StorageService();
  User? _user;
  bool _isLoading = true;

  late TextEditingController _nameController;
  late TextEditingController _lastnameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String _selectedCountry = 'Morocco';
  String _selectedCurrency = 'MAD';
  String _selectedLanguage = 'FR';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _storage.getCurrentUser();
    setState(() {
      _user = user;
      _isLoading = false;
    });

    if (user != null) {
      _nameController = TextEditingController(text: user.firstName);
      _lastnameController = TextEditingController(text: user.lastName);
      _phoneController = TextEditingController(text: user.phone ?? '');
      _emailController = TextEditingController(text: user.email);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _user == null
                ? const Center(child: Text('Aucun utilisateur connecté'))
                : Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Titre
                            Container(),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Contact ',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .black, // Couleur pour "Welcome to"
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Details',
                                    style: const TextStyle(
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
                              'Your personal information',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 40),

                            // Formulaire
                            Column(
                              children: [
                                // Prénom
                                CustomTextField(
                                  controller: _nameController,
                                  label: "First Name",
                                  keyboardType: TextInputType.name,
                                  prefixIcon: Icons.person_2_outlined,
                                ),

                                const SizedBox(height: 15),

                                // Nom
                                CustomTextField(
                                  controller: _lastnameController,
                                  label: "Last Name",
                                  keyboardType: TextInputType.name,
                                  prefixIcon: Icons.person_2_outlined,
                                ),

                                const SizedBox(height: 15),

                                // Téléphone
                                IntlPhoneField(
                                  controller: _phoneController,
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                    prefixIcon:
                                        const Icon(Icons.phone_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                  ),
                                  initialCountryCode: 'MA',
                                  enabled: false,
                                  onChanged: (phone) {},
                                  onCountryChanged: (country) {},
                                ),
                                const SizedBox(height: 15),
                                // Pays
                                DropdownButtonFormField<String>(
                                  value: _selectedCountry,
                                  decoration: InputDecoration(
                                    labelText: 'Country',
                                    prefixIcon:
                                        const Icon(Icons.location_on_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: [
                                    "Morocco",
                                    "France",
                                    "USA",
                                    "Spain",
                                    "Italy",
                                    "Germany"
                                  ]
                                      .map((country) => DropdownMenuItem(
                                            value: country,
                                            child: Text(country),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCountry = value!;
                                    });
                                  },
                                ),

                                const SizedBox(height: 15),

                                // Devise
                                DropdownButtonFormField<String>(
                                  value: _selectedCurrency,
                                  decoration: InputDecoration(
                                    labelText: 'Currency',
                                    prefixIcon:
                                        const Icon(Icons.attach_money_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: ["MAD", "EUR", "USD", "GBP"]
                                      .map((currency) => DropdownMenuItem(
                                            value: currency,
                                            child: Text(currency),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCurrency = value!;
                                    });
                                  },
                                ),

                                const SizedBox(height: 15),

                                // Langue
                                DropdownButtonFormField<String>(
                                  value: _selectedLanguage,
                                  decoration: InputDecoration(
                                    labelText: 'Language',
                                    prefixIcon:
                                        const Icon(Icons.translate_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                        value: "FR", child: Text("Français")),
                                    DropdownMenuItem(
                                        value: "EN", child: Text("English")),
                                    DropdownMenuItem(
                                        value: "AR", child: Text("العربية")),
                                    DropdownMenuItem(
                                        value: "ES", child: Text("Español")),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedLanguage = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            // Boutons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade300,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                          context, '/');
                                    },
                                    icon: const Icon(Icons.arrow_back),
                                    label: const Text("Back"),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.blueAccent,
                                      side: const BorderSide(
                                          color: Colors.blueAccent),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                    onPressed: () {},
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Continue"),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
