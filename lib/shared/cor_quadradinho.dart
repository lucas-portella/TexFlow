import 'package:flutter/material.dart';
import 'package:texflow/models/cor.dart';

class CorQuadradinho extends StatelessWidget {
  final Cor cor;
  final double tamanho;

  const CorQuadradinho({super.key, required this.cor, this.tamanho = 16});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: cor.nome,
      child: Container(
        width: tamanho,
        height: tamanho,
        decoration: BoxDecoration(
          color: cor.cor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black26),
        ),
      ),
    );
  }
}
