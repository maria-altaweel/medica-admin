import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';

class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoadingIndicator({super.key, this.size = 70, this.color});

  @override
  Widget build(BuildContext context) {
    return SpinKitCircle(color: color ?? AppColors.primary, size: size);
  }
}
