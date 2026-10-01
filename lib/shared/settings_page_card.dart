import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/settings_page_button.dart';

class SettingsPageCard extends StatelessWidget {
  final String title;
  final List<SettingsPageButton> buttons;
  const SettingsPageCard({
    super.key,
    required this.title,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.grey),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'DM Sans',
                color: AppColors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          for (var button in buttons) ...[
            Divider(color: AppColors.grey, thickness: 0.3),
            button,
          ],
        ],
      ),
    );
  }
}
