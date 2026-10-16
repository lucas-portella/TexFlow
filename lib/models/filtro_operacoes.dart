import 'package:texflow/models/operacao.dart';
import 'package:texflow/models/status.dart';

class FiltroOperacoes {
  final String texto;
  final Status? status;
  final int? modeloId;
  final int? clienteId;
  final DateTime? mes;

  const FiltroOperacoes({
    this.texto = '',
    this.status,
    this.modeloId,
    this.clienteId,
    this.mes,
  });

  FiltroOperacoes copiarCom({
    String? texto,
    Status? status,
    bool limparStatus = false,
    int? modeloId,
    bool limparModelo = false,
    int? clienteId,
    bool limparCliente = false,
    DateTime? mes,
    bool limparMes = false,
  }) {
    return FiltroOperacoes(
      texto: texto ?? this.texto,
      status: limparStatus ? null : (status ?? this.status),
      modeloId: limparModelo ? null : (modeloId ?? this.modeloId),
      clienteId: limparCliente ? null : (clienteId ?? this.clienteId),
      mes: limparMes ? null : (mes ?? this.mes),
    );
  }

  int get quantidadeAtivos {
    var total = 0;
    if (status != null) total++;
    if (modeloId != null) total++;
    if (clienteId != null) total++;
    if (mes != null) total++;
    return total;
  }

  bool get temFiltro => quantidadeAtivos > 0 || texto.trim().isNotEmpty;

  FiltroOperacoes get semFiltros => const FiltroOperacoes();

  static DateTime? dataDeReferencia(Operacao operacao) {
    final texto = operacao.dataFinalizacao ?? operacao.dataEntrega;
    if (texto == null) return null;
    return DateTime.tryParse(texto);
  }

  bool aceita(Operacao operacao) {
    if (status != null && operacao.status != status) return false;
    if (modeloId != null && operacao.referencia?.id != modeloId) return false;
    if (clienteId != null && operacao.cliente?.id != clienteId) return false;

    if (mes != null) {
      final data = dataDeReferencia(operacao);
      if (data == null || data.year != mes!.year || data.month != mes!.month) {
        return false;
      }
    }

    final termo = texto.trim().toLowerCase();
    if (termo.isEmpty) return true;

    final campos = [
      operacao.cliente?.nomeFantasia,
      operacao.referencia?.nome,
      operacao.codigo,
      operacao.numero,
      '${operacao.id}',
    ];
    return campos.any((campo) => (campo ?? '').toLowerCase().contains(termo));
  }

  List<Operacao> aplicar(List<Operacao> operacoes) {
    return operacoes.where(aceita).toList();
  }
}
