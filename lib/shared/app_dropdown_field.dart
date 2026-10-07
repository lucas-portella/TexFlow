import 'package:flutter/material.dart';
import 'package:texflow/shared/app_text_field.dart';

class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFieldLabel(label),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          decoration: appFieldDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}
