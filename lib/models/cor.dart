import 'package:flutter/material.dart';

class Cor {
  int id;
  String nome;
  String hex;

  Cor({this.id = 0, required this.nome, required this.hex});

  factory Cor.fromMap(Map<String, dynamic> map) {
    return Cor(
      id: map['id'] ?? 0,
      nome: map['nome'] ?? '',
      hex: map['hex'] ?? '#CCCCCC',
    );
  }

  Color get cor => corDoHex(hex);

  static Color corDoHex(String hex) {
    final limpo = hex.replaceFirst('#', '');
    final valor = int.tryParse(limpo, radix: 16);
    if (limpo.length != 6 || valor == null) return const Color(0xFFCCCCCC);
    return Color(0xFF000000 | valor);
  }
}
