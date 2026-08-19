import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class Appsnackbar {
  static void showError(BuildContext context, String message) {
    showTopSnackBar(
      Overlay.of(context),
      Center(
        child: SizedBox(
          width: 450,
          child: CustomSnackBar.error(
            message: message,
            backgroundColor: const Color(0xFFFF5252),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
      displayDuration: const Duration(seconds: 2),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    showTopSnackBar(
      Overlay.of(context),
      Center(
        child: SizedBox(
          width: 450,
          child: CustomSnackBar.success(
            message: message,
            backgroundColor: const Color(0xFF4CAF50),
          ),
        ),
      ),
      displayDuration: const Duration(seconds: 2),
    );
  }
}
