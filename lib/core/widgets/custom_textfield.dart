import 'package:flutter/material.dart';

//the password visibility changes when the user taps the eye icon.
class AppTextField extends StatefulWidget {

  final TextEditingController controller;
  final String label;
  final IconData icon;

  //optional validation function.
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  //Accepts one String argument. Returns nothing.
  final ValueChanged<String>? onSubmitted;
  final bool isPassword;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.isPassword = false
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
//Initializes the variable later, when it is first accessed.
//Private variable that controls password visibility.
//Gets the password setting from the parent widget.
  late bool _obsecure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      obscureText: _obsecure,
      //Passwords should not be automatically corrected by the keyboard.
      autocorrect: !widget.isPassword,
      enableSuggestions:!widget.isPassword,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(Icons.widgets),
        suffixIcon: widget.isPassword
          ? IconButton(
          //A tooltip provides a short description of what a button does.
          //If the password is hidden → Tooltip says "Show password".
          // If the password is visible → Tooltip says "Hide password".
          tooltip: _obsecure ? "Show Password" : "Hide Password",

          //Change the eye icon
          icon: Icon(
            _obsecure
            ?Icons.visibility_outlined
                :Icons.visibility_off_outlined
          ),
          //Handle icon click
          onPressed: () => setState(() => _obsecure = !_obsecure),

        )
: null,
      ),

    );
  }
}
