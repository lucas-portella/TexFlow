import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/fechamento.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_drawer.dart';

class FakeUsuarioProvider extends UsuarioProvider {
  @override
  Usuario? get usuario => Usuario(
    idUsuario: 1,
    nome: 'Ana Carvalho',
    email: 'ana@texflow.com',
    senha: '',
    tipo: UserType.GESTOR,
  );
}

void main() {
  test('Operacao lê o JSON do backend com modelo, etapas e responsáveis', () {
    final operacao = Operacao.fromMap({
      'id': 7,
      'status': 'concluido',
      'valorPeca': 5.0,
      'quantidadeSolicitada': 1200,
      'quantidadeProduzida': 1000,
      'dataFinalizacao': '2026-10-20',
      'referencia': {
        'id': 1,
        'nome': 'Blusa',
        'etapas': [
          {'id': 1, 'nome': 'Manga', 'valorComissao': 0.30},
          {'id': 2, 'nome': 'Gola', 'valorComissao': 0.5},
        ],
      },
      'processos': [
        {
          'id': 11,
          'descricao': 'Manga',
          'status': 'concluido',
          'valorComissao': 0.30,
          'funcionario': {'id': 3, 'nome': 'João', 'ativo': true},
        },
      ],
    });

    expect(operacao.finalizada, isTrue);
    expect(operacao.valorPeca, 5.0);
    expect(operacao.quantidadeProduzida, 1000);
    expect(operacao.referencia!.etapas.map((e) => e.nome), ['Manga', 'Gola']);
    expect(operacao.referencia!.etapas.first.valorComissao, 0.3);
    expect(operacao.processos.first.idProcessoProdutivo, 11);
    expect(operacao.processos.first.funcionario!.nome, 'João');
    expect(operacao.processos.first.valorComissao, 0.3);
  });

  test('Operacao sem os campos novos continua válida', () {
    final operacao = Operacao.fromMap({'id': 1, 'status': 'naoIniciado'});

    expect(operacao.finalizada, isFalse);
    expect(operacao.valorPeca, isNull);
    expect(operacao.processos, isEmpty);
  });

  test('Fechamento lê o JSON do backend', () {
    final fechamento = Fechamento.fromMap({
      'mes': '2026-10',
      'quantidadeOperacoes': 2,
      'totalPecas': 1500,
      'totalRecebido': 7000.00,
      'totalRepasse': 700.00,
      'lucro': 6300.00,
      'repasses': [
        {
          'funcionarioId': 3,
          'funcionario': 'João',
          'total': 700.00,
          'operacoes': [
            {
              'operacaoId': 7,
              'cliente': 'Moda João',
              'quantidade': 1000,
              'total': 300.00,
              'etapas': [
                {'etapa': 'Manga', 'valorPorPeca': 0.30, 'total': 300.00},
              ],
            },
          ],
        },
      ],
    });

    expect(fechamento.lucro, 6300);
    expect(fechamento.repasses.first.funcionario, 'João');
    expect(fechamento.repasses.first.operacoes.first.etapas.first.total, 300);
  });

  testWidgets('menu lateral abre as telas de cadastro e o fechamento', (
    tester,
  ) async {
    final aberturas = <String>[];
    final chave = GlobalKey<ScaffoldState>();

    await tester.pumpWidget(
      ChangeNotifierProvider<UsuarioProvider>.value(
        value: FakeUsuarioProvider(),
        child: MaterialApp(
          onGenerateRoute: (settings) {
            aberturas.add(settings.name!);
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => const Scaffold(body: Text('destino')),
            );
          },
          home: Builder(
            builder: (context) => Scaffold(
              key: chave,
              drawer: const AppDrawer(),
              body: Center(
                child: ElevatedButton(
                  onPressed: () => chave.currentState!.openDrawer(),
                  child: const Text('menu'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    for (final item in [
      ('Modelos', AppRoutes.modelos),
      ('Etapas', AppRoutes.etapas),
      ('Funcionários', AppRoutes.funcionarios),
      ('Fechamento', AppRoutes.fechamento),
    ]) {
      await tester.tap(find.widgetWithText(ElevatedButton, 'menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(item.$1));
      await tester.pumpAndSettle();
      expect(aberturas.last, item.$2);
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
    }
  });
}
