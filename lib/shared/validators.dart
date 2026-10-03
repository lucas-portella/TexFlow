String? validarObrigatorio(String? valor, String mensagem) {
  if (valor == null || valor.trim().isEmpty) return mensagem;
  return null;
}
