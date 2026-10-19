import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/empresa.dart';
import 'package:texflow/models/etapa.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/models/referencia.dart';
import 'package:texflow/pages/new_order_page.dart';
import 'package:texflow/providers/funcionario_provider.dart';
import 'package:texflow/providers/modelo_provider.dart';
import 'package:texflow/providers/new_operation_page_provider.dart';

Referencia _blusa() {
  return Referencia(
    id: 1,
    nome: 'Blusa',
    etapas: [
      Etapa(id: 1, nome: 'Manga', valorComissao: 0.3),
      Etapa(id: 2, nome: 'Gola', valorComissao: 0.5),
    ],
  );
}

class FakeModeloProvider extends ModeloProvider {
  @override
  List<Referencia> get modelos => [
    _blusa(),
    Referencia(id: 2, nome: 'Camisa', ativo: false),
  ];

  @override
  bool get carregando => false;

  @override
  Future<void> carregar() async {}
}

class FakeFuncionarioProvider extends FuncionarioProvider {
  final lista = [
    Funcionario(id: 1, nome: 'João Costureiro'),
    Funcionario(id: 2, nome: 'Maria Cortadora', ativo: false),
  ];

  @override
  List<Funcionario> get funcionarios => lista;

  @override
  List<Funcionario> get ativos => lista.where((f) => f.ativo).toList();

  @override
  bool get carregando => false;

  @override
  Future<void> carregar() async {}
}

void main() {
  group('NewOperationPageProvider', () {
    test('escolher o modelo traz as etapas com os valores, em ordem', () {
      final provider = NewOperationPageProvider();

      provider.setModelo(_blusa());

      expect(provider.processos.map((p) => p.descricao), ['Manga', 'Gola']);
      expect(provider.processos.map((p) => p.valorComissao), [0.3, 0.5]);
      expect(provider.processos.every((p) => p.funcionario == null), isTrue);
    });

    test('mudar o valor de uma etapa não altera o modelo', () {
      final provider = NewOperationPageProvider();
      final modelo = _blusa();
      provider.setModelo(modelo);

      provider.alterarValorEtapa(provider.processos.first, 0.45);

      expect(provider.processos.first.valorComissao, 0.45);
      expect(modelo.etapas.first.valorComissao, 0.3);
    });

    test('valida os campos na ordem e exige o responsável de cada etapa', () {
      final provider = NewOperationPageProvider();
      expect(provider.validar(), 'Informe o número do pedido');

      provider.setNumero('4521');
      expect(provider.validar(), 'Selecione o cliente');

      provider.setCliente(Empresa(id: 1, cnpj: '1', nomeFantasia: 'Moda João'));

      expect(provider.validar(), 'Selecione o modelo');

      provider.setModelo(_blusa());
      expect(provider.validar(), 'Informe o valor da peça');

      provider.setValorPeca(5);
      expect(provider.validar(), 'Informe a quantidade solicitada');

      provider.setQuantidadeSolicitada(1000);
      expect(provider.validar(), 'Escolha o responsável da etapa Manga');

      provider.setResponsaveis(provider.processos[0], [
        Funcionario(id: 1, nome: 'João'),
      ]);
      expect(provider.validar(), 'Escolha o responsável da etapa Gola');

      provider.setResponsaveis(provider.processos[1], [
        Funcionario(id: 1, nome: 'João'),
      ]);
      expect(provider.validar(), isNull);
    });

    test(
      'criarPedido recusa dados incompletos sem chamar o servidor',
      () async {
        final provider = NewOperationPageProvider();

        expect(provider.criarPedido(), throwsA(isA<Exception>()));
      },
    );

    test('limpar zera tudo, inclusive a grade', () {
      final provider = NewOperationPageProvider();
      provider.setModelo(_blusa());
      provider.incrementarQuantidadeItemGrade(provider.gradePedido.first);

      provider.limpar();

      expect(provider.modelo, isNull);
      expect(provider.processos, isEmpty);
      expect(provider.gradePedido.first.quantidade, 0);
    });
  });

  testWidgets('novo pedido: modelo, valor da etapa e responsável', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NewOperationPageProvider()),
          ChangeNotifierProvider<ModeloProvider>.value(
            value: FakeModeloProvider(),
          ),
          ChangeNotifierProvider<FuncionarioProvider>.value(
            value: FakeFuncionarioProvider(),
          ),
        ],
        child: const MaterialApp(home: NovoPedidoPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Ao escolher o modelo, as etapas aparecem aqui.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Selecione o modelo'));
    await tester.pumpAndSettle();
    expect(find.text('2 etapas'), findsOneWidget);
    expect(find.text('Camisa'), findsNothing);
    await tester.tap(find.text('Blusa'));
    await tester.pumpAndSettle();

    expect(find.text('Manga'), findsOneWidget);
    expect(find.text('Gola'), findsOneWidget);
    expect(find.text('R\$ 0,30 por peça'), findsOneWidget);
    expect(find.text('R\$ 0,50 por peça'), findsOneWidget);
    expect(find.text('Selecionar responsável'), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('Comissão de Manga'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '0,45');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('R\$ 0,45 por peça'), findsOneWidget);

    await tester.tap(find.text('Selecionar responsável').first);
    await tester.pumpAndSettle();
    expect(find.text('Responsáveis pela etapa Manga'), findsOneWidget);
    expect(find.text('Maria Cortadora'), findsNothing);
    await tester.tap(find.text('João Costureiro'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('João Costureiro'), findsOneWidget);
    expect(find.text('Selecionar responsável'), findsOneWidget);
  });
}
