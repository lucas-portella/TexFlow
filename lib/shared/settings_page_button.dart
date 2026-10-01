import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';

class SettingsPageButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const SettingsPageButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    softWrap: true,
                    maxLines: 3,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Icon(Icons.chevron_right_outlined, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
