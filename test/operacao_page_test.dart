import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/pages/operacao_page.dart';
import 'package:texflow/providers/operacao_detalhe_provider.dart';

Operacao _operacao() {
  return Operacao.fromMap({
    'id': 7,
    'referencia': {'id': 1, 'nome': 'MOD-FEM-045'},
    'cliente': {
      'id': 1,
      'cnpj': '12.345.678/0001-90',
      'nomeFantasia': 'Moda João',
    },
    'dataEntrega': '2026-10-15',
    'gradePedido': [
      {'descricao': 'P', 'quantidade': 60},
      {'descricao': 'M', 'quantidade': 40},
    ],
    'gradeFabricada': [
      {'descricao': 'P', 'quantidade': 50},
    ],
    'processos': [
      {
        'descricao': 'Corte',
        'status': 'concluido',
        'empresaResponsavel': {
          'id': 2,
          'cnpj': '98.765.432/0001-10',
          'nomeFantasia': 'Cortex Ltda.',
        },
      },
      {'descricao': 'Costura', 'status': 'emAndamento'},
    ],
    'status': 'emAndamento',
  });
}

class FakeDetalheProvider extends OperacaoDetalheProvider {
  final Operacao? _dado;
  final bool _estaCarregando;
  final String? _mensagemErro;

  FakeDetalheProvider({
    Operacao? operacao,
    bool carregando = false,
    String? erro,
  }) : _dado = operacao,
       _estaCarregando = carregando,
       _mensagemErro = erro;

  @override
  Operacao? get operacao => _dado;

  @override
  bool get carregando => _estaCarregando;

  @override
  String? get erro => _mensagemErro;
}

Future<void> _abrir(WidgetTester tester, FakeDetalheProvider provider) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider<OperacaoDetalheProvider>.value(
        value: provider,
        child: const OperacaoPage(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('mostra os dados vindos do backend', (tester) async {
    await _abrir(tester, FakeDetalheProvider(operacao: _operacao()));

    expect(find.text('Moda João'), findsOneWidget);
    expect(find.text('OP-7'), findsOneWidget);
    expect(find.text('MOD-FEM-045'), findsOneWidget);
    expect(find.text('Entrega em 15/10/2026'), findsOneWidget);
    expect(find.text('Em produção'), findsWidgets);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('1 de 2 processos concluídos'), findsOneWidget);
    expect(find.text('60 pç'), findsOneWidget);
    expect(find.text('100 pç'), findsOneWidget);
    expect(find.text('Corte'), findsOneWidget);
    expect(find.text('Cortex Ltda.'), findsOneWidget);
    expect(find.text('Costura'), findsOneWidget);
    expect(find.text('Sem empresa responsável'), findsOneWidget);
    expect(find.text('Concluído'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mostra carregando enquanto busca', (tester) async {
    await _abrir(tester, FakeDetalheProvider(carregando: true));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Detalhes da produção'), findsOneWidget);
  });

  testWidgets('mostra erro com opção de tentar de novo', (tester) async {
    await _abrir(tester, FakeDetalheProvider(erro: 'Sem conexão'));

    expect(find.text('Sem conexão'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
  });
}
