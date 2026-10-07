String? validarObrigatorio(String? valor, String mensagem) {
  if (valor == null || valor.trim().isEmpty) return mensagem;
  return null;
}

String? validarEmail(String? valor) {
  if (valor == null || !valor.contains('@')) {
    return 'Digite um e-mail válido';
  }
  return null;
}

String? validarSenha(String? valor) {
  if (valor == null || valor.length < 6) {
    return 'A senha precisa ter pelo menos 6 caracteres';
  }
  if (!RegExp(r'[a-z]').hasMatch(valor)) {
    return 'A senha precisa ter uma letra minúscula';
  }
  if (!RegExp(r'[A-Z]').hasMatch(valor)) {
    return 'A senha precisa ter uma letra maiúscula';
  }
  if (!RegExp(r'[.,!?;:@#\$%&*()\-_+=]').hasMatch(valor)) {
    return 'A senha precisa ter uma pontuação';
  }
  return null;
}
