import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';

class ApplicationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const ApplicationAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      backgroundColor: AppColors.white,
      shape: Border(bottom: BorderSide(color: AppColors.grey, width: 0.3)),
      leadingWidth: 60,
      titleSpacing: 12,
      leading: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Icon(Icons.chevron_left, size: 28, color: AppColors.ink),
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
