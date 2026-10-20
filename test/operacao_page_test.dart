import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/etapa.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/models/modo_operacao.dart';
import 'package:texflow/models/modulo.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/providers/etapa_provider.dart';
import 'package:texflow/providers/funcionario_provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/pages/operacao_page.dart';
import 'package:texflow/providers/operacao_detalhe_provider.dart';
import 'package:texflow/providers/preferencias_provider.dart';

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
    'valorPeca': 5.5,
    'quantidadeSolicitada': 120,
    'gradePedido': [
      {'descricao': 'P', 'quantidade': 60},
      {'descricao': 'M', 'quantidade': 40},
    ],
    'gradeFabricada': [
      {'descricao': 'P', 'quantidade': 50},
    ],
    'processos': [
      {
        'id': 11,
        'descricao': 'Corte',
        'status': 'concluido',
        'empresaResponsavel': {
          'id': 2,
          'cnpj': '98.765.432/0001-10',
          'nomeFantasia': 'Cortex Ltda.',
        },
      },
      {
        'id': 12,
        'descricao': 'Costura',
        'status': 'emAndamento',
        'valorComissao': 0.3,
        'funcionario': {'id': 1, 'nome': 'João Costureiro'},
      },
    ],
    'status': 'emAndamento',
  });
}

class FakeEtapaProvider extends EtapaProvider {
  @override
  List<Etapa> get etapas => _etapas;

  final _etapas = [
    Etapa(id: 1, nome: 'Corte', valorComissao: 0.5),
    Etapa(id: 2, nome: 'Costura', valorComissao: 0.3),
    Etapa(id: 3, nome: 'Bordado', valorComissao: 2),
    Etapa(id: 4, nome: 'Estampa', valorComissao: 1.2),
  ];

  @override
  Future<void> carregar() async {}
}

class FakeFuncionarioProvider extends FuncionarioProvider {
  @override
  List<Funcionario> get ativos => _ativos;

  final _ativos = [
    Funcionario(id: 1, nome: 'João Costureiro'),
    Funcionario(id: 2, nome: 'Maria Bordadeira'),
  ];

  @override
  Future<void> carregar() async {}
}

class FakeUsuarioProvider extends UsuarioProvider {
  final Set<Modulo> modulos;

  FakeUsuarioProvider(this.modulos);

  @override
  Usuario? get usuario => Usuario(
    idUsuario: 1,
    nome: 'Ana',
    email: 'ana@texflow.com',
    senha: '',
    tipo: UserType.GESTOR,
    modulos: modulos,
  );
}

class FakePreferenciasProvider extends PreferenciasProvider {
  final ModoOperacao _modo;

  FakePreferenciasProvider(this._modo);

  @override
  ModoOperacao get modoOperacao => _modo;

  @override
  Future<void> carregar() async {}
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

  final List<int> finalizacoes = [];
  final List<DateTime> datasDeEntrega = [];
  final List<Map<String, Object?>> etapasAdicionadas = [];
  final List<Status> statusEscolhidos = [];
  final List<List<int>> etapasAtualizadas = [];
  final List<Status> statusDasEtapas = [];
  int excluidas = 0;
  final List<Map<String, Object?>> quantidadesInformadas = [];

  @override
  Future<void> informarQuantidades(
    int processoId,
    Map<int, int> quantidades,
  ) async {
    quantidadesInformadas.add({'processo': processoId, 'quantidades': quantidades});
  }

  @override
  Future<void> excluir() async {
    excluidas++;
  }

  @override
  Future<void> finalizar(int quantidadeProduzida, DateTime dataEntrega) async {
    finalizacoes.add(quantidadeProduzida);
    datasDeEntrega.add(dataEntrega);
  }

  @override
  Future<void> adicionarEtapa({
    int? etapaId,
    String? nome,
    required double valorComissao,
    required int funcionarioId,
    List<int> outrosFuncionarioIds = const [],
  }) async {
    etapasAdicionadas.add({
      'etapaId': etapaId,
      'nome': nome,
      'valor': valorComissao,
      'funcionarioId': funcionarioId,
      'outros': outrosFuncionarioIds,
    });
  }

  @override
  Future<void> alterarStatus(Status status) async {
    statusEscolhidos.add(status);
  }

  @override
  Future<void> atualizarEtapas(List<int> processoIds, Status status) async {
    etapasAtualizadas.add(processoIds);
    statusDasEtapas.add(status);
  }
}

Future<void> _abrir(
  WidgetTester tester,
  FakeDetalheProvider provider, {
  ModoOperacao modo = ModoOperacao.porEtapas,
  Set<Modulo> modulos = const {Modulo.etapas},
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PreferenciasProvider>.value(
          value: FakePreferenciasProvider(modo),
        ),
        ChangeNotifierProvider<EtapaProvider>.value(value: FakeEtapaProvider()),
        ChangeNotifierProvider<FuncionarioProvider>.value(
          value: FakeFuncionarioProvider(),
        ),
        ChangeNotifierProvider<UsuarioProvider>.value(
          value: FakeUsuarioProvider(modulos),
        ),
      ],
      child: MaterialApp(
        home: ChangeNotifierProvider<OperacaoDetalheProvider>.value(
          value: provider,
          child: const OperacaoPage(),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _confirmarPendencias(WidgetTester tester) async {
  expect(find.text('Peças sem informar'), findsOneWidget);
  await tester.tap(find.widgetWithText(TextButton, 'Concluir'));
  await tester.pumpAndSettle();
}

Future<void> _escolherResponsaveis(
  WidgetTester tester,
  List<String> nomes,
) async {
  await tester.tap(find.text('Escolha os funcionários'));
  await tester.pumpAndSettle();
  for (final nome in nomes) {
    await tester.tap(find.widgetWithText(CheckboxListTile, nome));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.textContaining('Confirmar'));
  await tester.pumpAndSettle();
}

void main() {
  group('peças por responsável na etapa', () {
    Operacao pedido({bool preenchido = false, bool finalizado = false}) {
      return Operacao.fromMap({
        'id': 9,
        'numero': '4521',
        'status': 'emAndamento',
        'dataFinalizacao': finalizado ? '2026-10-20' : null,
        'gradePedido': [],
        'gradeFabricada': [],
        'processos': [
          {
            'id': 1,
            'descricao': 'Final',
            'status': 'concluido',
            'valorComissao': 0.3,
            'funcionario': {'id': 1, 'nome': 'João Costureiro'},
            'funcionariosAdicionais': [
              {'id': 2, 'nome': 'Maria Bordadeira'},
            ],
            'quantidades': preenchido ? {'1': 400, '2': 650} : <String, dynamic>{},
          },
        ],
      });
    }

    testWidgets('a etapa mostra as peças de cada responsável', (tester) async {
      await _abrir(
        tester,
        FakeDetalheProvider(operacao: pedido(preenchido: true)),
        modo: ModoOperacao.porStatus,
      );

      expect(
        find.textContaining('João Costureiro (400), Maria Bordadeira (650)'),
        findsOneWidget,
      );
    });

    testWidgets('sem peças informadas aparecem só os nomes', (tester) async {
      await _abrir(
        tester,
        FakeDetalheProvider(operacao: pedido()),
        modo: ModoOperacao.porStatus,
      );

      expect(find.textContaining('João Costureiro, Maria Bordadeira'), findsOneWidget);
      expect(find.textContaining('('), findsNothing);
    });

    testWidgets('informar as peças de cada pessoa e salvar', (tester) async {
      final provider = FakeDetalheProvider(operacao: pedido());
      await _abrir(tester, provider, modo: ModoOperacao.porStatus);

      await tester.tap(find.byTooltip('Peças por responsável'));
      await tester.pumpAndSettle();
      expect(find.text('Peças por responsável'), findsWidgets);
      expect(find.text('JOÃO COSTUREIRO'), findsOneWidget);
      expect(find.text('MARIA BORDADEIRA'), findsOneWidget);

      final campos = find.byType(TextField);
      await tester.enterText(campos.at(0), '400');
      await tester.enterText(campos.at(1), '');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(provider.quantidadesInformadas, [
        {
          'processo': 1,
          'quantidades': {1: 400},
        },
      ]);
      expect(find.text('Peças salvas'), findsOneWidget);
    });

    testWidgets('produção finalizada não deixa mexer nas peças', (tester) async {
      await _abrir(
        tester,
        FakeDetalheProvider(operacao: pedido(preenchido: true, finalizado: true)),
        modo: ModoOperacao.porStatus,
      );

      expect(find.byTooltip('Peças por responsável'), findsNothing);
    });

    testWidgets('ao concluir, avisa quem está sem peças e usa a quantidade final', (
      tester,
    ) async {
      final provider = FakeDetalheProvider(operacao: pedido());
      await _abrir(tester, provider);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Concluir operação'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '1000');
      await tester.tap(find.text('Finalizar'));
      await tester.pumpAndSettle();

      expect(find.text('Peças sem informar'), findsOneWidget);
      expect(find.textContaining('1000 peças informadas agora'), findsOneWidget);
      expect(find.text('• Final · João Costureiro'), findsOneWidget);
      expect(find.text('• Final · Maria Bordadeira'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
      await tester.pumpAndSettle();
      expect(provider.finalizacoes, isEmpty);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Concluir operação'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '1000');
      await tester.tap(find.text('Finalizar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Concluir'));
      await tester.pumpAndSettle();
      expect(provider.finalizacoes, [1000]);
    });

    testWidgets('com todas as peças informadas conclui sem aviso', (tester) async {
      final provider = FakeDetalheProvider(operacao: pedido(preenchido: true));
      await _abrir(tester, provider);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Concluir operação'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '1050');
      await tester.tap(find.text('Finalizar'));
      await tester.pumpAndSettle();

      expect(find.text('Peças sem informar'), findsNothing);
      expect(provider.finalizacoes, [1050]);
    });
  });

  group('editar e excluir o pedido', () {
    Operacao pedido({
      String status = 'naoIniciado',
      String etapa = 'naoIniciado',
      String? finalizacao,
    }) {
      return Operacao.fromMap({
        'id': 9,
        'numero': '4521',
        'status': status,
        'dataFinalizacao': finalizacao,
        'gradePedido': [],
        'gradeFabricada': [],
        'processos': [
          {'id': 1, 'descricao': 'Corte', 'status': etapa},
          {'id': 2, 'descricao': 'Costura', 'status': 'naoIniciado'},
        ],
      });
    }

    testWidgets('pedido novo em planejamento pode ser editado e excluído', (
      tester,
    ) async {
      await _abrir(
        tester,
        FakeDetalheProvider(operacao: pedido()),
        modo: ModoOperacao.porStatus,
      );

      expect(find.byTooltip('Editar pedido'), findsOneWidget);
      expect(find.byTooltip('Excluir pedido'), findsOneWidget);
    });

    testWidgets('excluir pede confirmação e só então exclui', (tester) async {
      final provider = FakeDetalheProvider(operacao: pedido());
      await _abrir(tester, provider, modo: ModoOperacao.porStatus);

      await tester.tap(find.byTooltip('Excluir pedido'));
      await tester.pumpAndSettle();
      expect(find.text('Deseja excluir "OP-4521"?'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(provider.excluidas, 0);

      await tester.tap(find.byTooltip('Excluir pedido'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
      await tester.pumpAndSettle();
      expect(provider.excluidas, 1);
    });

    testWidgets('com etapa iniciada ainda edita, mas não exclui', (tester) async {
      await _abrir(
        tester,
        FakeDetalheProvider(operacao: pedido(etapa: 'emAndamento')),
        modo: ModoOperacao.porStatus,
      );

      expect(find.byTooltip('Editar pedido'), findsOneWidget);
      expect(find.byTooltip('Excluir pedido'), findsNothing);
    });

    testWidgets('em andamento por status não exclui; por etapas exclui se nada começou', (
      tester,
    ) async {
      await _abrir(
        tester,
        FakeDetalheProvider(operacao: pedido(status: 'emAndamento')),
        modo: ModoOperacao.porStatus,
      );
      expect(find.byTooltip('Excluir pedido'), findsNothing);

      await _abrir(
        tester,
        FakeDetalheProvider(operacao: pedido(status: 'emAndamento')),
        modo: ModoOperacao.porEtapas,
      );
      expect(find.byTooltip('Excluir pedido'), findsOneWidget);
    });

    testWidgets('produção finalizada não edita nem exclui', (tester) async {
      await _abrir(
        tester,
        FakeDetalheProvider(
          operacao: pedido(status: 'concluido', finalizacao: '2026-10-20'),
        ),
      );

      expect(find.byTooltip('Editar pedido'), findsNothing);
      expect(find.byTooltip('Excluir pedido'), findsNothing);
    });
  });

  testWidgets('mostra os dados vindos do backend', (tester) async {
    await _abrir(tester, FakeDetalheProvider(operacao: _operacao()));

    expect(find.text('Moda João'), findsOneWidget);
    expect(find.text('OP-7'), findsOneWidget);
    expect(find.text('MOD-FEM-045'), findsOneWidget);
    expect(find.text('Previsão de entrega: 15/10/2026'), findsOneWidget);
    expect(find.text('Em produção'), findsWidgets);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('1 de 2 processos concluídos'), findsOneWidget);
    expect(find.text('60 pç'), findsOneWidget);
    expect(find.text('100 pç'), findsOneWidget);
    expect(find.text('Corte'), findsOneWidget);
    expect(find.text('Cortex Ltda.'), findsOneWidget);
    expect(find.text('Costura'), findsOneWidget);
    expect(find.text('João Costureiro · R\$ 0,30 por peça'), findsOneWidget);
    expect(find.text('Valor da peça: R\$ 5,50'), findsOneWidget);
    expect(find.text('Solicitadas: 120 peças'), findsOneWidget);
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

  testWidgets('por etapas: concluir operação só habilita com tudo concluído', (
    tester,
  ) async {
    final operacao = _operacao();
    await _abrir(tester, FakeDetalheProvider(operacao: operacao));

    final botao = find.widgetWithText(ElevatedButton, 'Concluir operação');
    expect(botao, findsOneWidget);
    expect(tester.widget<ElevatedButton>(botao).onPressed, isNull);
    expect(find.text('STATUS'), findsNothing);

    operacao.processos[1].status = Status.concluido;
    await _abrir(tester, FakeDetalheProvider(operacao: operacao));
    expect(tester.widget<ElevatedButton>(botao).onPressed, isNotNull);
  });

  testWidgets('por etapas: seleciona etapas e conclui de uma vez', (
    tester,
  ) async {
    final operacao = _operacao();
    operacao.processos.add(
      _operacao().processos[1]
        ..idProcessoProdutivo = 13
        ..descricao = 'Acabamento'
        ..status = Status.naoIniciado,
    );
    final provider = FakeDetalheProvider(operacao: operacao);
    await _abrir(tester, provider);

    expect(find.textContaining('Concluir 1 etapa'), findsNothing);

    await tester.tap(find.text('Costura'));
    await tester.pump();
    expect(find.text('Concluir 1 etapa selecionada'), findsOneWidget);

    await tester.tap(find.text('Acabamento'));
    await tester.pump();
    expect(find.text('Concluir 2 etapas selecionadas'), findsOneWidget);

    await tester.tap(find.text('Concluir 2 etapas selecionadas'));
    await tester.pumpAndSettle();

    expect(provider.etapasAtualizadas, [
      [12, 13],
    ]);
    expect(provider.statusDasEtapas, [Status.concluido]);
  });

  testWidgets('por etapas: tocar numa etapa concluída pergunta e reabre', (
    tester,
  ) async {
    final provider = FakeDetalheProvider(operacao: _operacao());
    await _abrir(tester, provider);

    await tester.tap(find.text('Corte'));
    await tester.pumpAndSettle();
    expect(find.text('Reabrir etapa'), findsOneWidget);

    await tester.tap(find.text('Reabrir'));
    await tester.pumpAndSettle();

    expect(provider.etapasAtualizadas, [
      [11],
    ]);
    expect(provider.statusDasEtapas, [Status.naoIniciado]);
  });

  testWidgets('por etapas: concluir operação pede a quantidade produzida', (
    tester,
  ) async {
    final operacao = _operacao();
    operacao.processos[1].status = Status.concluido;
    final provider = FakeDetalheProvider(operacao: operacao);
    await _abrir(tester, provider);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Concluir operação'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, '');
    await tester.tap(find.text('Finalizar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe uma quantidade maior que zero'), findsOneWidget);
    expect(provider.finalizacoes, isEmpty);

    await tester.enterText(find.byType(TextField).last, '110');
    await tester.tap(find.text('Finalizar'));
    await tester.pumpAndSettle();
    await _confirmarPendencias(tester);

    expect(provider.finalizacoes, [110]);
    expect(find.text('Produção finalizada'), findsOneWidget);
  });

  testWidgets('por status: campo de status e nenhum botão de concluir', (
    tester,
  ) async {
    final provider = FakeDetalheProvider(operacao: _operacao());
    await _abrir(tester, provider, modo: ModoOperacao.porStatus);

    expect(find.text('STATUS'), findsOneWidget);
    expect(find.text('Em andamento'), findsOneWidget);
    expect(find.text('Concluir operação'), findsNothing);
    expect(find.text('Finalizar produção'), findsNothing);

    await tester.tap(find.text('STATUS'));
    await tester.pumpAndSettle();
    expect(find.text('Novo'), findsOneWidget);
    expect(find.text('Concluído'), findsOneWidget);

    await tester.tap(find.text('Novo'));
    await tester.pumpAndSettle();
    expect(provider.statusEscolhidos, [Status.naoIniciado]);
  });

  testWidgets('por status: escolher Concluído pede a quantidade e finaliza', (
    tester,
  ) async {
    final provider = FakeDetalheProvider(operacao: _operacao());
    await _abrir(tester, provider, modo: ModoOperacao.porStatus);

    await tester.tap(find.text('STATUS'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Concluído'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, '100');
    await tester.tap(find.text('Finalizar'));
    await tester.pumpAndSettle();
    await _confirmarPendencias(tester);

    expect(provider.finalizacoes, [100]);
    expect(provider.statusEscolhidos, isEmpty);
  });

  testWidgets('produção já finalizada mostra o resumo e sem ações', (
    tester,
  ) async {
    final operacao = _operacao()
      ..dataFinalizacao = '2026-10-20'
      ..quantidadeProduzida = 110;
    await _abrir(tester, FakeDetalheProvider(operacao: operacao));

    expect(
      find.text('Entregue em 20/10/2026 · 110 peças produzidas'),
      findsOneWidget,
    );
    expect(find.text('Concluir operação'), findsNothing);

    await _abrir(
      tester,
      FakeDetalheProvider(operacao: operacao),
      modo: ModoOperacao.porStatus,
    );
    expect(find.text('Concluir operação'), findsNothing);
    await tester.tap(find.text('STATUS'));
    await tester.pumpAndSettle();
    expect(find.text('Novo'), findsNothing);
  });

  testWidgets('finalizar pede a data de entrega e a quantidade de peças', (
    tester,
  ) async {
    final provider = FakeDetalheProvider(operacao: _operacao());
    final operacao = provider.operacao!;
    operacao.processos[1].status = Status.concluido;
    await _abrir(tester, provider);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Concluir operação'));
    await tester.pumpAndSettle();

    expect(find.text('DATA DE ENTREGA'), findsOneWidget);
    expect(find.text('PEÇAS PRODUZIDAS'), findsOneWidget);
    final hoje = DateTime.now();
    final textoDeHoje =
        '${hoje.day.toString().padLeft(2, '0')}/${hoje.month.toString().padLeft(2, '0')}/${hoje.year}';
    expect(find.text(textoDeHoje), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, '95');
    await tester.tap(find.text('Finalizar'));
    await tester.pumpAndSettle();
    await _confirmarPendencias(tester);

    expect(provider.finalizacoes, [95]);
    expect(provider.datasDeEntrega.single.year, hoje.year);
    expect(provider.datasDeEntrega.single.month, hoje.month);
    expect(provider.datasDeEntrega.single.day, hoje.day);
  });

  testWidgets('sem previsão de entrega a linha some do cabeçalho', (
    tester,
  ) async {
    final operacao = _operacao()..dataEntrega = null;
    await _abrir(tester, FakeDetalheProvider(operacao: operacao));

    expect(find.textContaining('Previsão de entrega'), findsNothing);
    expect(find.text('Solicitadas: 120 peças'), findsOneWidget);
  });

  group('adicionar etapa na produção', () {
    Future<FakeDetalheProvider> abrirSheet(
      WidgetTester tester, {
      ModoOperacao modo = ModoOperacao.porEtapas,
      Set<Modulo> modulos = const {Modulo.etapas},
    }) async {
      final provider = FakeDetalheProvider(operacao: _operacao());
      await _abrir(tester, provider, modo: modo, modulos: modulos);

      await tester.ensureVisible(
        find.widgetWithText(OutlinedButton, 'Adicionar etapa'),
      );
      await tester.tap(find.widgetWithText(OutlinedButton, 'Adicionar etapa'));
      await tester.pumpAndSettle();
      return provider;
    }

    testWidgets(
      'o botão existe nos dois modos e some com a produção finalizada',
      (tester) async {
        await _abrir(tester, FakeDetalheProvider(operacao: _operacao()));
        expect(
          find.widgetWithText(OutlinedButton, 'Adicionar etapa'),
          findsOneWidget,
        );

        await _abrir(
          tester,
          FakeDetalheProvider(operacao: _operacao()),
          modo: ModoOperacao.porStatus,
        );
        expect(
          find.widgetWithText(OutlinedButton, 'Adicionar etapa'),
          findsOneWidget,
        );

        final finalizada = _operacao()..dataFinalizacao = '2026-10-20';
        await _abrir(tester, FakeDetalheProvider(operacao: finalizada));
        expect(
          find.widgetWithText(OutlinedButton, 'Adicionar etapa'),
          findsNothing,
        );
      },
    );

    testWidgets('escolhe uma etapa cadastrada que ainda não está na produção', (
      tester,
    ) async {
      final provider = await abrirSheet(tester);

      expect(find.text('Já cadastrada'), findsOneWidget);
      expect(find.text('Nova etapa'), findsOneWidget);

      await tester.tap(find.text('Escolha uma etapa'));
      await tester.pumpAndSettle();
      expect(find.text('Bordado'), findsOneWidget);
      expect(find.text('Estampa'), findsOneWidget);
      expect(find.text('Corte'), findsOneWidget);
      expect(find.text('Costura'), findsOneWidget);
      await tester.tap(find.text('Bordado'));
      await tester.pumpAndSettle();

      expect(find.text('2,00'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Adicionar etapa'));
      await tester.pumpAndSettle();
      expect(find.text('Escolha pelo menos um responsável'), findsOneWidget);
      expect(provider.etapasAdicionadas, isEmpty);

      await _escolherResponsaveis(tester, ['Maria Bordadeira']);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Adicionar etapa'));
      await tester.pumpAndSettle();

      expect(provider.etapasAdicionadas, [
        {
          'etapaId': 3,
          'nome': null,
          'valor': 2.0,
          'funcionarioId': 2,
          'outros': <int>[],
        },
      ]);
      expect(find.text('Etapa adicionada'), findsOneWidget);
    });

    testWidgets('cadastra uma etapa nova só para essa produção', (
      tester,
    ) async {
      final provider = await abrirSheet(tester);

      await tester.tap(find.text('Nova etapa'));
      await tester.pumpAndSettle();

      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'Acabamento fino');
      await tester.enterText(campos.at(1), '1,75');
      await _escolherResponsaveis(tester, ['João Costureiro']);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Adicionar etapa'));
      await tester.pumpAndSettle();

      expect(provider.etapasAdicionadas, [
        {
          'etapaId': null,
          'nome': 'Acabamento fino',
          'valor': 1.75,
          'funcionarioId': 1,
          'outros': <int>[],
        },
      ]);
    });

    testWidgets('várias pessoas na mesma etapa: a primeira é a principal', (
      tester,
    ) async {
      final provider = await abrirSheet(tester);

      await tester.tap(find.text('Nova etapa'));
      await tester.pumpAndSettle();
      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'Barra');
      await tester.enterText(campos.at(1), '0,80');
      await _escolherResponsaveis(tester, ['Maria Bordadeira', 'João Costureiro']);

      expect(find.text('Maria Bordadeira, João Costureiro'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Adicionar etapa'));
      await tester.pumpAndSettle();

      expect(provider.etapasAdicionadas, [
        {
          'etapaId': null,
          'nome': 'Barra',
          'valor': 0.8,
          'funcionarioId': 2,
          'outros': <int>[1],
        },
      ]);
    });

    testWidgets('a escolha de responsáveis exige pelo menos uma pessoa', (
      tester,
    ) async {
      await abrirSheet(tester);

      await tester.tap(find.text('Nova etapa'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Escolha os funcionários'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Cada pessoa'), findsNothing);
      final confirmar = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirmar'),
      );
      expect(confirmar.onPressed, isNull);

      await tester.tap(find.widgetWithText(CheckboxListTile, 'João Costureiro'));
      await tester.pumpAndSettle();
      expect(find.text('Confirmar (1)'), findsOneWidget);
      await tester.tap(find.widgetWithText(CheckboxListTile, 'João Costureiro'));
      await tester.pumpAndSettle();
      expect(find.text('Confirmar'), findsOneWidget);
    });

    testWidgets('nova etapa pede o nome e o valor', (tester) async {
      final provider = await abrirSheet(tester);

      await tester.tap(find.text('Nova etapa'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Adicionar etapa'));
      await tester.pumpAndSettle();

      expect(find.text('Informe o nome da etapa'), findsOneWidget);
      expect(find.text('Informe o valor da etapa'), findsOneWidget);
      expect(find.text('Escolha pelo menos um responsável'), findsOneWidget);
      expect(provider.etapasAdicionadas, isEmpty);
    });

    testWidgets('quem não tem a aba de etapas também cadastra uma etapa nova', (
      tester,
    ) async {
      await abrirSheet(tester, modulos: const {});

      final botao = tester.widget<SegmentedButton<bool>>(
        find.byType(SegmentedButton<bool>),
      );
      expect(botao.segments[0].enabled, isTrue);
      expect(botao.segments[1].enabled, isTrue);

      await tester.tap(find.text('Nova etapa'));
      await tester.pumpAndSettle();
      expect(find.text('NOME DA ETAPA'), findsOneWidget);
    });
  });
}
