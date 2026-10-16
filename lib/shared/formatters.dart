String formatarData(String? data) {
  if (data == null || data.isEmpty) return '-';
  final partes = data.split('-');
  if (partes.length != 3) return data;
  return '${partes[2]}/${partes[1]}/${partes[0]}';
}

String formatarMoeda(double valor) {
  final negativo = valor < 0;
  final partes = valor.abs().toStringAsFixed(2).split('.');
  final inteiro = partes[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
  return '${negativo ? '-' : ''}R\$ $inteiro,${partes[1]}';
}

double? lerValor(String texto) {
  final limpo = texto.trim().replaceAll('R\$', '').replaceAll(' ', '');
  if (limpo.isEmpty) return null;
  final normalizado = limpo.contains(',')
      ? limpo.replaceAll('.', '').replaceAll(',', '.')
      : limpo;
  return double.tryParse(normalizado);
}

String nomeDoMes(DateTime mes) {
  const nomes = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];
  return '${nomes[mes.month - 1]} de ${mes.year}';
}

String formatarNumero(double valor, {int casas = 1}) {
  final negativo = valor < 0;
  final partes = valor.abs().toStringAsFixed(casas).split('.');
  final inteiro = partes[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
  final decimal = partes.length > 1 ? ',${partes[1]}' : '';
  return '${negativo ? '-' : ''}$inteiro$decimal';
}

String formatarInteiro(double valor) => formatarNumero(valor, casas: 0);
