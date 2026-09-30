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
      leading: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.appbarIconBackground,
            borderRadius: BorderRadius.circular(6),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.chevron_left),
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
