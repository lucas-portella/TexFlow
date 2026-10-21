import 'package:texflow/models/cor.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/models/tamanho.dart';

class LinhaDaEtapa {
  Funcionario funcionario;
  Cor? cor;
  Tamanho? tamanho;
  int? quantidade;

  LinhaDaEtapa({
    required this.funcionario,
    this.cor,
    this.tamanho,
    this.quantidade,
  });

  factory LinhaDaEtapa.fromMap(Map<String, dynamic> map) {
    return LinhaDaEtapa(
      funcionario: Funcionario.fromMap(map['funcionario']),
      cor: map['cor'] == null ? null : Cor.fromMap(map['cor']),
      tamanho: map['tamanho'] == null ? null : Tamanho.fromMap(map['tamanho']),
      quantidade: (map['quantidade'] as num?)?.toInt(),
    );
  }

  bool get completa => cor != null && quantidade != null;

  LinhaDaEtapa copia() {
    return LinhaDaEtapa(
      funcionario: funcionario,
      cor: cor,
      tamanho: tamanho,
      quantidade: quantidade,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'funcionario': {'id': funcionario.id},
      if (cor != null) 'cor': {'id': cor!.id},
      if (tamanho != null) 'tamanho': {'id': tamanho!.id},
      'quantidade': quantidade,
    };
  }
}
