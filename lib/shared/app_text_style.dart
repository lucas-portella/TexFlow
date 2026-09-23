import 'package:flutter/painting.dart';
import 'package:texflow/shared/app_colors.dart';

class AppTextStyle {
  static const title = TextStyle(
    fontSize: 35,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static const whiteSubtitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static const formLabel = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static const appTextField = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
}
