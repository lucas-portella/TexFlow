import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';

BoxShadow appShadowEffect() {
  return BoxShadow(
    color: AppColors.shadowColor,
    offset: Offset(0, 10),
    blurRadius: 20,
    spreadRadius: 10,
  );
}
