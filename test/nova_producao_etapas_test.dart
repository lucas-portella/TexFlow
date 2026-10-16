import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/etapa.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/models/referencia.dart';
import 'package:texflow/pages/new_order_page.dart';
import 'package:texflow/providers/etapa_provider.dart';
import 'package:texflow/providers/funcionario_provider.dart';
import 'package:texflow/providers/modelo_provider.dart';
import 'package:texflow/providers/new_operation_page_provider.dart';
import 'package:texflow/shared/adicionar_etapa_sheet.dart';

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
  final lista = [_blusa()];

  @override
  List<Referencia> get modelos => lista;

  @override
  bool get carregando => false;

  @override
  Future<void> carregar() async {}
}

class FakeFuncionarioProvider extends FuncionarioProvider {
  final lista = [Funcionario(id: 1, nome: 'João Costureiro')];

  @override
  List<Funcionario> get funcionarios => lista;

  @override
  List<Funcionario> get ativos => lista;

  @override
  bool get carregando => false;

  @override
  Future<void> carregar() async {}
}

class FakeEtapaProvider extends EtapaProvider {
  final lista = [
    Etapa(id: 1, nome: 'Manga', valorComissao: 0.3),
    Etapa(id: 2, nome: 'Gola', valorComissao: 0.5),
    Etapa(id: 3, nome: 'Bordado', valorComissao: 2),
  ];

  @override
  List<Etapa> get etapas => lista;

  @override
  Future<void> carregar() async {}
}

void main() {
  final joao = Funcionario(id: 1, nome: 'João Costureiro');
  final cadastradas = <String>[];

  NewOperationPageProvider criar({List<Etapa> catalogo = const []}) {
    cadastradas.clear();
    return NewOperationPageProvider(
      listarEtapas: () async => catalogo,
      cadastrarEtapa: (nome, valor) async {
        cadastradas.add('$nome|$valor');
        return Etapa(id: 99, nome: nome, valorComissao: valor);
      },
    );
  }

  group('adicionar etapa ao pedido', () {
    test(
      'etapa já cadastrada entra no fim com o valor e o responsável',
      () async {
        final provider = criar();
        provider.setModelo(_blusa());

        await provider.adicionarEtapaAoPedido(
          DadosDaEtapaAdicionada(
            etapa: Etapa(id: 3, nome: 'Bordado', valorComissao: 2),
            valor: 2.5,
            funcionario: joao,
          ),
        );

        expect(provider.processos.map((p) => p.descricao), [
          'Manga',
          'Gola',
          'Bordado',
        ]);
        expect(provider.processos.last.valorComissao, 2.5);
        expect(provider.processos.last.funcionario, joao);
        expect(cadastradas, isEmpty);
        expect(provider.modelo!.etapas.map((e) => e.nome), ['Manga', 'Gola']);
      },
    );

    test('etapa nova também é cadastrada no cadastro de etapas', () async {
      final provider = criar();
      provider.setModelo(_blusa());

      await provider.adicionarEtapaAoPedido(
        DadosDaEtapaAdicionada(
          nome: 'Acabamento',
          valor: 1.2,
          funcionario: joao,
        ),
      );

      expect(cadastradas, ['Acabamento|1.2']);
      expect(provider.processos.last.descricao, 'Acabamento');
      expect(provider.modelo!.etapas.map((e) => e.nome), ['Manga', 'Gola']);
    });

    test('nome que já existe no cadastro reaproveita a etapa', () async {
      final provider = criar(
        catalogo: [Etapa(id: 7, nome: 'Estampa', valorComissao: 1)],
      );
      provider.setModelo(_blusa());

      await provider.adicionarEtapaAoPedido(
        DadosDaEtapaAdicionada(nome: 'estampa', valor: 1.4, funcionario: joao),
      );

      expect(cadastradas, isEmpty);
      expect(provider.processos.last.descricao, 'Estampa');
      expect(provider.processos.last.valorComissao, 1.4);
    });

    test(
      'só as etapas adicionadas podem ser removidas, as do modelo não',
      () async {
        final provider = criar();
        provider.setModelo(_blusa());

        await provider.adicionarEtapaAoPedido(
          DadosDaEtapaAdicionada(
            nome: 'Acabamento',
            valor: 1,
            funcionario: joao,
          ),
        );
        final extra = provider.processos.last;
        final doModelo = provider.processos.first;

        expect(provider.ehEtapaExtra(extra), isTrue);
        expect(provider.ehEtapaExtra(doModelo), isFalse);

        provider.removerEtapaExtra(doModelo);
        expect(provider.processos, hasLength(3));

        provider.removerEtapaExtra(extra);
        expect(provider.processos.map((p) => p.descricao), ['Manga', 'Gola']);
        expect(provider.ehEtapaExtra(extra), isFalse);
      },
    );

    test('trocar de modelo descarta as etapas adicionadas', () async {
      final provider = criar();
      provider.setModelo(_blusa());
      await provider.adicionarEtapaAoPedido(
        DadosDaEtapaAdicionada(nome: 'Acabamento', valor: 1, funcionario: joao),
      );

      provider.setModelo(_blusa());

      expect(provider.processos.map((p) => p.descricao), ['Manga', 'Gola']);
    });

    test('não deixa repetir uma etapa que já está no pedido', () async {
      final provider = criar();
      provider.setModelo(_blusa());

      await expectLater(
        provider.adicionarEtapaAoPedido(
          DadosDaEtapaAdicionada(nome: ' manga ', valor: 1, funcionario: joao),
        ),
        throwsA(isA<Exception>()),
      );
      expect(provider.processos, hasLength(2));
      expect(cadastradas, isEmpty);
    });
  });

  testWidgets('novo pedido: botão para adicionar etapa só desse pedido', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 3600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final pedido = criar();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<NewOperationPageProvider>.value(value: pedido),
          ChangeNotifierProvider<ModeloProvider>.value(
            value: FakeModeloProvider(),
          ),
          ChangeNotifierProvider<FuncionarioProvider>.value(
            value: FakeFuncionarioProvider(),
          ),
          ChangeNotifierProvider<EtapaProvider>.value(
            value: FakeEtapaProvider(),
          ),
        ],
        child: const MaterialApp(home: NovoPedidoPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Adicionar etapa'), findsNothing);

    await tester.tap(find.text('Selecione o modelo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blusa'));
    await tester.pumpAndSettle();

    final botao = find.widgetWithText(OutlinedButton, 'Adicionar etapa');
    await tester.ensureVisible(botao);
    await tester.tap(botao);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Escolha uma etapa'));
    await tester.pumpAndSettle();
    expect(find.text('Bordado'), findsOneWidget);
    await tester.tap(find.text('Bordado'));
    await tester.pumpAndSettle();
    expect(find.text('2,00'), findsOneWidget);

    await tester.tap(find.text('Escolha o funcionário'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('João Costureiro').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Adicionar etapa'));
    await tester.pumpAndSettle();

    expect(find.text('R\$ 2,00 por peça'), findsOneWidget);
    expect(pedido.processos.map((p) => p.descricao), [
      'Manga',
      'Gola',
      'Bordado',
    ]);

    await tester.ensureVisible(botao);
    await tester.tap(botao);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova etapa'));
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Acabamento');
    await tester.enterText(campos.at(1), '1,10');
    await tester.tap(find.text('Escolha o funcionário'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('João Costureiro').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Adicionar etapa'));
    await tester.pumpAndSettle();

    expect(cadastradas, ['Acabamento|1.1']);
    expect(pedido.processos.last.descricao, 'Acabamento');
    expect(find.byTooltip('Remover etapa'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Remover etapa').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remover etapa'), findsOneWidget);
    expect(pedido.processos.map((p) => p.descricao), [
      'Manga',
      'Gola',
      'Acabamento',
    ]);
  });
}
