import 'package:flutter/material.dart';
import 'package:texflow/models/modulo.dart';

class ModulosSwitches extends StatelessWidget {
  final Set<Modulo> selecionados;
  final Set<Modulo> liberados;
  final bool travado;
  final ValueChanged<Set<Modulo>> aoMudar;

  const ModulosSwitches({
    super.key,
    required this.selecionados,
    required this.liberados,
    required this.aoMudar,
    this.travado = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final modulo in Modulo.values)
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(modulo.icone),
              title: Text(modulo.rotulo),
              subtitle: Text(modulo.descricao),
              value: selecionados.contains(modulo),
              onChanged: travado || !liberados.contains(modulo)
                  ? null
                  : (ligado) {
                      final novo = Set.of(selecionados);
                      ligado ? novo.add(modulo) : novo.remove(modulo);
                      aoMudar(novo);
                    },
            ),
          ),
      ],
    );
  }
}
