String formatarData(String? data) {
  if (data == null || data.isEmpty) return '-';
  final partes = data.split('-');
  if (partes.length != 3) return data;
  return '${partes[2]}/${partes[1]}/${partes[0]}';
}
