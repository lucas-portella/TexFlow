import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:texflow/shared/app_colors.dart';

OutlineInputBorder appFieldBorder([Color cor = AppColors.border]) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: cor),
  );
}

InputDecoration appFieldDecoration({
  String? hintText,
  IconData? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, size: 20, color: AppColors.textMuted),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    border: appFieldBorder(),
    enabledBorder: appFieldBorder(),
    focusedBorder: appFieldBorder(AppColors.primary),
    errorBorder: appFieldBorder(AppColors.danger),
    focusedErrorBorder: appFieldBorder(AppColors.danger),
  );
}

class AppFieldLabel extends StatelessWidget {
  final String texto;

  const AppFieldLabel(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class AppTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _escondido = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFieldLabel(widget.label),
        TextFormField(
          controller: widget.controller,
          obscureText: _escondido,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          style: const TextStyle(fontSize: 14, color: AppColors.black),
          decoration: appFieldDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () => setState(() => _escondido = !_escondido),
                    icon: Icon(
                      _escondido
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textMuted,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
