class ItemGrade {
  String descricao;
  int quantidade;

  ItemGrade({required this.descricao, required this.quantidade});

  factory ItemGrade.fromMap(Map<String, dynamic> map) {
    return ItemGrade(
      descricao: map['descricao'] ?? '',
      quantidade: map['quantidade'] ?? 0,
    );
  }
}
