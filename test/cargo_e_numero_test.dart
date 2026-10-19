import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:texflow/models/fechamento.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/shared/settings_page_user_card.dart';

Usuario _usuario({String? cargo, UserType tipo = UserType.GESTOR}) {
  return Usuario(
    idUsuario: 1,
    nome: 'Marina',
    email: 'marina@texflow.com',
    senha: '',
    tipo: tipo,
    cargo: cargo,
  );
}

Future<void> _cartao(WidgetTester tester, Usuario usuario) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SettingsPageUserCard(usuario: usuario)),
    ),
  );
}

void main() {
  group('cargo espelha o cadastro do usuário', () {
    test('usa só o que foi escrito no cadastro', () {
      expect(_usuario(cargo: 'Gerente de produção').cargoInformado, 'Gerente de produção');
      expect(_usuario(cargo: '  Corte  ').cargoInformado, 'Corte');
    });

    test('sem cargo não inventa nenhum, nem pelo perfil', () {
      expect(_usuario().cargoInformado, isNull);
      expect(_usuario(cargo: '').cargoInformado, isNull);
      expect(_usuario(cargo: '   ').cargoInformado, isNull);
      expect(_usuario(tipo: UserType.OPERADOR).cargoInformado, isNull);
    });

    testWidgets('configurações mostra o cargo escrito', (tester) async {
      await _cartao(tester, _usuario(cargo: 'Gerente de produção'));

      expect(find.text('Marina'), findsOneWidget);
      expect(find.text('Gerente de produção'), findsOneWidget);
    });

    testWidgets('configurações mostra só o nome quando não há cargo', (
      tester,
    ) async {
      await _cartao(tester, _usuario());

      expect(find.text('Marina'), findsOneWidget);
      expect(find.textContaining('Supervisor'), findsNothing);
      expect(find.textContaining('Operador'), findsNothing);
    });
  });

  group('fechamento mostra o número do pedido', () {
    test('usa o número digitado no cadastro', () {
      final operacao = RepasseOperacao.fromMap({
        'operacaoId': 77,
        'numero': '4521',
        'quantidade': 10,
        'total': 3,
        'etapas': [],
      });

      expect(operacao.codigo, 'OP-4521');
    });

    test('sem número, cai no identificador interno', () {
      expect(
        RepasseOperacao.fromMap({'operacaoId': 77, 'etapas': []}).codigo,
        'OP-77',
      );
      expect(
        RepasseOperacao.fromMap({
          'operacaoId': 77,
          'numero': '  ',
          'etapas': [],
        }).codigo,
        'OP-77',
      );
    });
  });
}
