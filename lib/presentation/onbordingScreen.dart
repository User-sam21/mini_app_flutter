import 'package:flutter/material.dart';
import 'package:mini_app/data/api_service.dart';
import 'package:mini_app/presentation/constant/CustomPasswordField.dart';
import 'package:mini_app/presentation/constant/custom_text_field.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mini_app/presentation/constant/otpinput.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;


  // Form keys for each page
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>(); // Added form key for page 4

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedCountry = "Morocco";
  String _selectedCurrency = "MAD";
  String _selectedLanguage = "FR";

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose(); // Added dispose
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      // Validate current page before moving
      bool isValid = false;
      if (_currentPage == 0) {
        isValid = _formKey1.currentState?.validate() ?? false;
      } else if (_currentPage == 1) {
        isValid = _formKey2.currentState?.validate() ?? false;
      } else if (_currentPage == 2) {
        isValid = _formKey3.currentState?.validate() ?? false;
      }

      if (isValid) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      // Last page - validate and submit
      if (_formKey4.currentState?.validate() ?? false) {
        // Handle final submission
        _submitForm();
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Dans la méthode _submitForm()
  void _submitForm() async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Appel API pour l'inscription
      final authResponse = await ApiService().signup(
      firstName: _nameController.text.trim(),
      lastName: _lastnameController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      password: _passwordController.text,
    );

      // Mettre à jour le profil avec les informations supplémentaires
      if (_phoneController.text.isNotEmpty ||
          _selectedCountry != "Morocco" ||
          _selectedCurrency != "MAD" ||
          _selectedLanguage != "FR") {
        await ApiService().updateProfile(
          token: authResponse.token,
          phone:
              _phoneController.text.isNotEmpty ? _phoneController.text : null,
          country: _selectedCountry,
          currency: _selectedCurrency,
          language: _selectedLanguage,
        );
      }

      // Fermer le dialogue de chargement
      Navigator.pop(context);

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription réussie!')),
      );

      // Naviguer vers l'écran d'accueil
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      // Fermer le dialogue de chargement
      Navigator.pop(context);

      // Afficher l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  String _getPageTitle() {
    switch (_currentPage) {
      case 0:
        return 'Welcome to Morocco';
      case 1:
        return 'Welcome to Morocco';
      case 2:
        return 'Personalize your experience';
      case 3:
        return 'Check your email';
      default:
        return 'Welcome to Morocco';
    }
  }

  String _getPageSubtitle() {
    switch (_currentPage) {
      case 0:
        return 'Begin your journey to discover Morocco';
      case 1:
        return 'Begin your journey to discover Morocco';
      case 2:
        return 'Choose your preferences';
      case 3:
        return 'We sent a verification code to your email';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _getPageTitle(),
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _getPageSubtitle(),
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),

                  // Page Indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.blueAccent
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),

                  // PageView
                  SizedBox(
                    height: 450,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildSignUpPage(),
                        _buildDetailsContact(),
                        _buildPreference(),
                        _buildCheckEmail()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Page 1 - Sign Up
  Widget _buildSignUpPage() {
    return Form(
      key: _formKey1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _nameController,
            label: "Name",
            keyboardType: TextInputType.name,
            prefixIcon: Icons.person_2_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Name is required";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          CustomTextField(
            controller: _lastnameController,
            label: "Lastname",
            keyboardType: TextInputType.name,
            prefixIcon: Icons.person_2_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Lastname is required";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          CustomTextField(
            controller: _emailController,
            label: "Email",
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Email is required";
              }
              if (!value.contains('@') || !value.contains('.')) {
                return "Invalid email";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          CustomPasswordField(
            controller: _passwordController,
            label: "Password",
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
          const SizedBox(height: 15),
          // Buttons
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/');
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
                    side: const BorderSide(color: Colors.blueAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _nextPage,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
        ],
      ),
    );
  }

// Page 2 - Contact Details with intl_phone_field
  Widget _buildDetailsContact() {
    return Form(
      key: _formKey2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // International Phone Field (version simplifiée)
          IntlPhoneField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter your phone number',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            initialCountryCode: 'MA',
            onChanged: (phone) {
              setState(() {
              });
              print('Complete number: ${phone.completeNumber}');
              print('Country code: ${phone.countryCode}');
              print('National number: ${phone.number}');
            },
            onCountryChanged: (country) {
              setState(() {});
              print('Country changed to: ${country.name}');
            },
            validator: (value) {
              if (value == null || value.number.isEmpty) {
                return 'Phone number is required';
              }
              if (!value.isValidNumber()) {
                return 'Invalid phone number';
              }
              return null;
            },
          ),

          const SizedBox(height: 25),

          // Buttons
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _previousPage,
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
                    side: const BorderSide(color: Colors.blueAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _nextPage,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
        ],
      ),
    );
  }

  Widget _buildPreference() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              items: ["Morocco", "France", "USA", "Spain", "Italy"]
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select a country";
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.attach_money_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              items: ["MAD", "EUR", "USD"]
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select a currency";
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.translate_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              items: ["EN", "FR", "AR"]
                  .map((lang) => DropdownMenuItem(
                        value: lang,
                        child: Text(lang),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select a language";
                }
                return null;
              },
            ),

            const Spacer(),

            /// BUTTONS
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _previousPage,
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
                      side: const BorderSide(color: Colors.blueAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _nextPage,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
          ],
        ),
      ),
    );
  }

  // Page 4 - Check Email
  Widget _buildCheckEmail() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Verification code field avec OTPInput
            OTPInput(
              length: 6,
              onCompleted: (code) {
                print('Code completed: $code');
                // Optionnel: Auto-submit quand le code est complet
              },
              onChanged: (value) {
                print('Current value: $value');
              },
            ),

            const SizedBox(height: 25),

            // Bouton Verify - Prend toute la largeur
            SizedBox(
              width: double.infinity, // Prend toute la largeur
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey4.currentState!.validate()) {
                    _nextPage();
                  }
                },
                child: const Text(
                  "Verify Email",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Lien pour renvoyer le code
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verification code resent!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Resend code',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Bouton Back - Prend toute la largeur
            // Sans Expanded, taille basée sur le contenu
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: _previousPage,
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
