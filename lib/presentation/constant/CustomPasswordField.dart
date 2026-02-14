import 'package:flutter/material.dart';

class CustomPasswordField extends StatefulWidget {
  final String label;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller; 

  const CustomPasswordField({
    super.key,
    required this.label,
    this.onChanged,
    this.validator,
    this.controller, 
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller, 
      obscureText: isObscure,
      onChanged: widget.onChanged,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              isObscure = !isObscure;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}