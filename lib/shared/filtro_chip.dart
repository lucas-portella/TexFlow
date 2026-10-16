import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';

class FiltroChip extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String? valor;
  final VoidCallback onTap;
  final VoidCallback? onLimpar;

  const FiltroChip({
    super.key,
    required this.icone,
    required this.rotulo,
    required this.onTap,
    this.valor,
    this.onLimpar,
  });

  bool get _ativo => valor != null;

  @override
  Widget build(BuildContext context) {
    final cor = _ativo ? AppColors.primary : AppColors.ink;

    return Material(
      color: _ativo ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: _ativo ? AppColors.primary : AppColors.cardBorder,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 16, color: cor),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  valor ?? rotulo,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cor,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              if (_ativo && onLimpar != null)
                InkWell(
                  onTap: onLimpar,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(Icons.close, size: 16, color: cor),
                  ),
                )
              else
                Icon(Icons.keyboard_arrow_down, size: 18, color: cor),
            ],
          ),
        ),
      ),
    );
  }
}
