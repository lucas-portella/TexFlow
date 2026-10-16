enum ModoOperacao {
  porStatus('porStatus', 'Por status'),
  porEtapas('porEtapas', 'Por etapas');

  final String json;
  final String rotulo;

  const ModoOperacao(this.json, this.rotulo);

  String get descricao {
    switch (this) {
      case ModoOperacao.porStatus:
        return 'Você muda o status da produção direto nos detalhes: Novo, Em andamento ou Concluído. Não precisa marcar as etapas.';
      case ModoOperacao.porEtapas:
        return 'Você conclui as etapas uma a uma, ou várias de uma vez. Quando todas estiverem concluídas, o botão de concluir a operação é liberado.';
    }
  }

  static ModoOperacao deJson(String? valor) {
    for (final modo in ModoOperacao.values) {
      if (modo.json == valor) return modo;
    }
    return ModoOperacao.porStatus;
  }
}
