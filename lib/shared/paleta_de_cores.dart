import 'package:flutter/material.dart';

const colunasDaPaleta = 10;

String hexDaCor(Color cor) {
  final valor = cor.toARGB32() & 0xFFFFFF;
  return '#${valor.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

List<String> _gerarPaleta() {
  const tonsDeCinza = [
    1.0, 0.89, 0.78, 0.67, 0.56, 0.45, 0.34, 0.23, 0.12, 0.0, //
  ];
  const matizes = [
    0.0,
    25.0,
    48.0,
    95.0,
    150.0,
    175.0,
    200.0,
    225.0,
    270.0,
    320.0,
  ];
  const variacoes = [
    (0.25, 1.0),
    (0.55, 1.0),
    (1.0, 1.0),
    (1.0, 0.7),
    (1.0, 0.45),
  ];

  return [
    for (final valor in tonsDeCinza)
      hexDaCor(HSVColor.fromAHSV(1, 0, 0, valor).toColor()),
    for (final (saturacao, valor) in variacoes)
      for (final matiz in matizes)
        hexDaCor(HSVColor.fromAHSV(1, matiz, saturacao, valor).toColor()),
  ];
}

final paletaDeCores = _gerarPaleta();
