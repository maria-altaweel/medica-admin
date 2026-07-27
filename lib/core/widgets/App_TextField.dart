import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';

class AppTextField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final int? maxLine;

  const AppTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    required this.controller,
    this.validator,
    this.errorText,
    this.keyboardType,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.maxLine = 1,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      maxLines: maxLine,

      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,

        errorStyle: TextStyle(fontSize: 12, color: Colors.red),
        prefixIcon: Icon(prefixIcon, color: AppColors.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.textField,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
