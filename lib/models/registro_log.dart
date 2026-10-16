import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';

enum TipoLog {
  cadastro('CADASTRO', 'Cadastro', Icons.add_circle_outline, AppColors.success),
  criacao('CRIACAO', 'Criação', Icons.post_add, AppColors.primary),
  alteracao('ALTERACAO', 'Alteração', Icons.edit_outlined, AppColors.warning),
  exclusao('EXCLUSAO', 'Exclusão', Icons.delete_outline, AppColors.danger),
  acesso('ACESSO', 'Acesso', Icons.login, AppColors.muted);

  final String json;
  final String rotulo;
  final IconData icone;
  final Color cor;

  const TipoLog(this.json, this.rotulo, this.icone, this.cor);

  static TipoLog deJson(String? valor) {
    for (final tipo in TipoLog.values) {
      if (tipo.json == valor) return tipo;
    }
    return TipoLog.alteracao;
  }
}

class RegistroLog {
  final int id;
  final DateTime dataHora;
  final TipoLog tipo;
  final String area;
  final String usuarioNome;
  final String descricao;

  RegistroLog({
    required this.id,
    required this.dataHora,
    required this.tipo,
    required this.area,
    required this.usuarioNome,
    required this.descricao,
  });

  factory RegistroLog.fromMap(Map<String, dynamic> map) {
    return RegistroLog(
      id: map['id'] ?? 0,
      dataHora:
          DateTime.tryParse(map['dataHora'] ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      tipo: TipoLog.deJson(map['tipo']),
      area: map['area'] ?? '',
      usuarioNome: map['usuarioNome'] ?? '',
      descricao: map['descricao'] ?? '',
    );
  }

  String get frase => '$usuarioNome $descricao';

  String get hora =>
      '${dataHora.hour.toString().padLeft(2, '0')}:${dataHora.minute.toString().padLeft(2, '0')}';

  DateTime get dia => DateTime(dataHora.year, dataHora.month, dataHora.day);
}
