import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texflow/models/cor.dart';
import 'package:texflow/models/empresa.dart';
import 'package:texflow/models/etapa.dart';
import 'package:texflow/models/fechamento.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/models/processo_produtivo.dart';
import 'package:texflow/models/referencia.dart';
import 'package:texflow/models/tamanho.dart';
import 'package:texflow/pages/cores_page.dart';
import 'package:texflow/pages/new_order_page.dart';
import 'package:texflow/pages/tamanhos_page.dart';
import 'package:texflow/providers/cor_provider.dart';
import 'package:texflow/providers/etapa_provider.dart';
import 'package:texflow/providers/funcionario_provider.dart';
import 'package:texflow/providers/modelo_provider.dart';
import 'package:texflow/providers/new_operation_page_provider.dart';
import 'package:texflow/providers/tamanho_provider.dart';
import 'package:texflow/shared/cor_quadradinho.dart';
import 'package:texflow/shared/etapa_form_sheet.dart';
import 'package:texflow/shared/paleta_de_cores.dart';
import 'package:texflow/shared/repasse_funcionario_sheet.dart';

class _Cores extends CorProvider {
  final List<Cor> lista = [
    Cor(id: 1, nome: 'Branco', hex: '#FFFFFF'),
    Cor(id: 2, nome: 'Vermelho', hex: '#E5252A'),
    Cor(id: 3, nome: 'Verde', hex: '#2EAD5B'),
  ];
  final List<Map<String, Object?>> salvas = [];
  final List<int> excluidas = [];

  @override
  List<Cor> get cores => lista;

  @override
  bool get carregando => false;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> salvar({
    int? id,
    required String nome,
    required String hex,
  }) async {
    salvas.add({'id': id, 'nome': nome, 'hex': hex});
  }

  @override
  Future<void> excluir(int id) async {
    excluidas.add(id);
  }
}

class _Tamanhos extends TamanhoProvider {
  final List<Tamanho> lista = [
    Tamanho(id: 1, nome: 'PP'),
    Tamanho(id: 2, nome: 'P'),
  ];
  final List<Map<String, Object?>> salvos = [];
  final List<int> excluidos = [];

  @override
  List<Tamanho> get tamanhos => lista;

  @override
  bool get carregando => false;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> salvar({int? id, required String nome}) async {
    salvos.add({'id': id, 'nome': nome});
  }

  @override
  Future<void> excluir(int id) async {
    excluidos.add(id);
  }
}

class _Etapas extends EtapaProvider {
  final List<Map<String, Object?>> salvas = [];

  @override
  List<Etapa> get etapas => const [];

  @override
  bool get carregando => false;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> salvar({
    int? id,
    required String nome,
    required double valorComissao,
    bool permiteCores = false,
  }) async {
    salvas.add({
      'nome': nome,
      'valor': valorComissao,
      'permiteCores': permiteCores,
    });
  }
}

class _Modelos extends ModeloProvider {
  @override
  List<Referencia> get modelos => [
    Referencia(
      id: 1,
      nome: 'Camiseta',
      etapas: [
        Etapa(id: 1, nome: 'Estampa', valorComissao: 0.5, permiteCores: true),
        Etapa(id: 2, nome: 'Etiquetagem', valorComissao: 0.1),
      ],
    ),
  ];

  @override
  bool get carregando => false;

  @override
  Future<void> carregar() async {}
}

class _Funcionarios extends FuncionarioProvider {
  @override
  List<Funcionario> get funcionarios => [
    Funcionario(id: 1, nome: 'João Costureiro'),
    Funcionario(id: 2, nome: 'Maria Bordadeira'),
  ];

  @override
  bool get carregando => false;

  @override
  Future<void> carregar() async {}
}

void _tela(WidgetTester tester, [Size tamanho = const Size(800, 3000)]) {
  tester.view.physicalSize = tamanho;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  final joao = Funcionario(id: 1, nome: 'João Costureiro');
  final maria = Funcionario(id: 2, nome: 'Maria Bordadeira');
  final branco = Cor(id: 1, nome: 'Branco', hex: '#FFFFFF');
  final vermelho = Cor(id: 2, nome: 'Vermelho', hex: '#E5252A');

  group('modelo de etapa com cores', () {
    test('a cor vem do código #RRGGBB e erro vira cinza', () {
      expect(Cor.corDoHex('#E5252A'), const Color(0xFFE5252A));
      expect(Cor.corDoHex('E5252A'), const Color(0xFFE5252A));
      expect(Cor.corDoHex('xyz'), const Color(0xFFCCCCCC));
    });

    test('a paleta tem quadradinhos válidos e sem repetir', () {
      expect(paletaDeCores.length, greaterThanOrEqualTo(20));
      expect(paletaDeCores.toSet().length, paletaDeCores.length);
      for (final hex in paletaDeCores) {
        expect(RegExp(r'^#[0-9A-F]{6}$').hasMatch(hex), isTrue, reason: hex);
      }
    });

    test('adicionar cores monta o responsável e as cores de cada um', () {
      final etapa = ProcessoProdutivo(descricao: 'Estampa', permiteCores: true);

      etapa.adicionarCores(joao, [branco, vermelho]);
      etapa.adicionarCores(maria, [branco]);

      expect(etapa.funcionarios.map((item) => item.nome), [
        'João Costureiro',
        'Maria Bordadeira',
      ]);
      expect(etapa.coresDe(1).map((cor) => cor.nome), ['Branco', 'Vermelho']);
      expect(etapa.coresDe(2).map((cor) => cor.nome), ['Branco']);
      expect(etapa.linhas, hasLength(3));
    });

    test('a mesma cor pode ter mais de um responsável e não duplica a linha', () {
      final etapa = ProcessoProdutivo(descricao: 'Estampa', permiteCores: true);

      etapa.adicionarCores(joao, [branco]);
      etapa.adicionarCores(joao, [branco]);
      etapa.adicionarCores(maria, [branco]);

      expect(etapa.linhas, hasLength(2));
    });

    test('trocar as cores de alguém tira as que saíram e guarda o resto', () {
      final etapa = ProcessoProdutivo(descricao: 'Estampa', permiteCores: true);
      etapa.adicionarCores(joao, [branco, vermelho]);
      etapa.linhas.first.quantidade = 300;

      etapa.definirCores(joao, [branco]);

      expect(etapa.linhas, hasLength(1));
      expect(etapa.linhas.single.quantidade, 300);
    });

    test('remover o responsável tira as linhas e passa o posto adiante', () {
      final etapa = ProcessoProdutivo(descricao: 'Estampa', permiteCores: true);
      etapa.adicionarCores(joao, [branco]);
      etapa.adicionarCores(maria, [vermelho]);

      etapa.removerResponsavel(joao);

      expect(etapa.funcionario?.nome, 'Maria Bordadeira');
      expect(etapa.funcionariosAdicionais, isEmpty);
      expect(etapa.linhas, hasLength(1));
    });

    test('peças da pessoa somam os lotes; completo exige cor e peças', () {
      final etapa = ProcessoProdutivo(descricao: 'Estampa', permiteCores: true);
      etapa.adicionarCores(joao, [branco, vermelho]);

      expect(etapa.pecasDe(1), isNull);
      expect(etapa.responsavelCompleto(joao), isFalse);

      etapa.linhas[0].quantidade = 1120;
      expect(etapa.responsavelCompleto(joao), isFalse);

      etapa.linhas[1].quantidade = 30;
      expect(etapa.pecasDe(1), 1150);
      expect(etapa.responsavelCompleto(joao), isTrue);
    });

    test('etapa comum continua valendo só a quantidade da pessoa', () {
      final etapa = ProcessoProdutivo(descricao: 'Etiquetagem')
        ..definirResponsaveis([joao]);

      expect(etapa.responsavelCompleto(joao), isFalse);
      etapa.quantidades[1] = 90;
      expect(etapa.responsavelCompleto(joao), isTrue);
      expect(etapa.pecasDe(1), 90);
    });

    test('lê e envia as linhas no formato do servidor', () {
      final etapa = ProcessoProdutivo.fromMap({
        'id': 5,
        'descricao': 'Estampa',
        'permiteCores': true,
        'funcionario': {'id': 1, 'nome': 'João'},
        'linhas': [
          {
            'funcionario': {'id': 1, 'nome': 'João'},
            'cor': {'id': 1, 'nome': 'Branco', 'hex': '#FFFFFF'},
            'tamanho': {'id': 3, 'nome': 'GG'},
            'quantidade': 1120,
          },
        ],
      });

      expect(etapa.permiteCores, isTrue);
      expect(etapa.linhas.single.tamanho?.nome, 'GG');
      expect(etapa.toMap()['linhas'], [
        {
          'funcionario': {'id': 1},
          'cor': {'id': 1},
          'tamanho': {'id': 3},
          'quantidade': 1120,
        },
      ]);
    });

    test('servidor antigo, sem cores, continua funcionando', () {
      final etapa = ProcessoProdutivo.fromMap({
        'descricao': 'Manga',
        'funcionario': {'id': 1, 'nome': 'João'},
      });

      expect(etapa.permiteCores, isFalse);
      expect(etapa.linhas, isEmpty);
    });

    test('etapa do catálogo lembra se aceita cores', () {
      expect(
        Etapa.fromMap({'id': 1, 'nome': 'Estampa', 'permiteCores': true})
            .permiteCores,
        isTrue,
      );
      expect(Etapa.fromMap({'id': 2, 'nome': 'Corte'}).permiteCores, isFalse);
    });
  });

  group('cadastros de cores e tamanhos', () {
    testWidgets('cores: lista com quadradinho, nova cor pede nome e paleta', (
      tester,
    ) async {
      _tela(tester);
      final cores = _Cores();
      await tester.pumpWidget(
        ChangeNotifierProvider<CorProvider>.value(
          value: cores,
          child: const MaterialApp(home: CoresPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cores'), findsOneWidget);
      expect(find.text('Branco'), findsOneWidget);
      expect(find.text('#E5252A'), findsOneWidget);
      expect(find.byType(CorQuadradinho), findsNWidgets(3));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Nova cor'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();
      expect(find.text('Informe o nome da cor'), findsOneWidget);
      expect(find.text('Escolha o quadradinho da cor'), findsOneWidget);
      expect(cores.salvas, isEmpty);

      await tester.enterText(find.byType(TextFormField), 'Coral');
      await tester.tap(find.byTooltip('#FF7F50'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(cores.salvas, [
        {'id': null, 'nome': 'Coral', 'hex': '#FF7F50'},
      ]);
    });

    testWidgets('cores: editar abre preenchida e excluir pede confirmação', (
      tester,
    ) async {
      _tela(tester);
      final cores = _Cores();
      await tester.pumpWidget(
        ChangeNotifierProvider<CorProvider>.value(
          value: cores,
          child: const MaterialApp(home: CoresPage()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vermelho'));
      await tester.pumpAndSettle();
      expect(find.text('Editar cor'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Vermelho'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Excluir').first);
      await tester.pumpAndSettle();
      expect(find.text('Deseja excluir "Branco"?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
      await tester.pumpAndSettle();
      expect(cores.excluidas, [1]);
    });

    testWidgets('tamanhos: lista, cria e exclui', (tester) async {
      _tela(tester);
      final tamanhos = _Tamanhos();
      await tester.pumpWidget(
        ChangeNotifierProvider<TamanhoProvider>.value(
          value: tamanhos,
          child: const MaterialApp(home: TamanhosPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PP'), findsOneWidget);
      expect(find.text('P'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();
      expect(find.text('Informe o nome do tamanho'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'XG');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();
      expect(tamanhos.salvos, [
        {'id': null, 'nome': 'XG'},
      ]);

      await tester.tap(find.byTooltip('Excluir').first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
      await tester.pumpAndSettle();
      expect(tamanhos.excluidos, [1]);
    });

    testWidgets('etapa: a caixinha de cores é salva junto com a etapa', (
      tester,
    ) async {
      _tela(tester);
      final etapas = _Etapas();
      await tester.pumpWidget(
        ChangeNotifierProvider<EtapaProvider>.value(
          value: etapas,
          child: MaterialApp(
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => EtapaFormSheet.abrir(context),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Podem haver mais cores para esta etapa'), findsOneWidget);
      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'Estampa');
      await tester.enterText(campos.at(1), '0,50');
      await tester.tap(find.text('Podem haver mais cores para esta etapa'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(etapas.salvas, [
        {'nome': 'Estampa', 'valor': 0.5, 'permiteCores': true},
      ]);
    });

    testWidgets('etapa: sem marcar, não aceita cores', (tester) async {
      _tela(tester);
      final etapas = _Etapas();
      await tester.pumpWidget(
        ChangeNotifierProvider<EtapaProvider>.value(
          value: etapas,
          child: MaterialApp(
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => EtapaFormSheet.abrir(context),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'Etiquetagem');
      await tester.enterText(campos.at(1), '0,10');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(etapas.salvas.single['permiteCores'], isFalse);
    });
  });

  group('novo pedido com etapa colorida', () {
    Future<NewOperationPageProvider> abrir(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      _tela(tester);
      final pedido = NewOperationPageProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<NewOperationPageProvider>.value(
              value: pedido,
            ),
            ChangeNotifierProvider<ModeloProvider>.value(value: _Modelos()),
            ChangeNotifierProvider<FuncionarioProvider>.value(
              value: _Funcionarios(),
            ),
            ChangeNotifierProvider<CorProvider>.value(value: _Cores()),
          ],
          child: const MaterialApp(home: NovoPedidoPage()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Selecione o modelo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Camiseta'));
      await tester.pumpAndSettle();
      return pedido;
    }

    testWidgets('só a etapa marcada oferece responsável com cor', (tester) async {
      await abrir(tester);

      expect(find.text('Adicionar responsável e cor'), findsOneWidget);
      expect(find.text('Adicionar responsável'), findsOneWidget);
      expect(find.text('Selecionar responsável'), findsNothing);
      expect(find.text('R\$ 0,50'), findsOneWidget);
      expect(find.textContaining('por peça'), findsNothing);
    });

    testWidgets('escolhe o responsável e as cores dele, já com os quadradinhos', (
      tester,
    ) async {
      final pedido = await abrir(tester);

      await tester.tap(find.text('Adicionar responsável e cor'));
      await tester.pumpAndSettle();
      expect(find.text('Responsável e cores'), findsOneWidget);

      var confirmar = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirmar'),
      );
      expect(confirmar.onPressed, isNull);

      await tester.tap(find.text('Funcionário'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('João Costureiro').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Branco'));
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Vermelho'));
      await tester.pumpAndSettle();

      confirmar = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirmar (2)'),
      );
      expect(confirmar.onPressed, isNotNull);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Confirmar (2)'));
      await tester.pumpAndSettle();

      expect(find.text('João Costureiro'), findsOneWidget);
      expect(find.byType(CorQuadradinho), findsNWidgets(2));
      final estampa = pedido.processos.first;
      expect(estampa.funcionario?.nome, 'João Costureiro');
      expect(estampa.linhas, hasLength(2));
      expect(pedido.validar(), 'Informe o número do pedido');
    });

    testWidgets('quem já está na etapa sai da lista, e dá para remover', (
      tester,
    ) async {
      final pedido = await abrir(tester);
      pedido.processos.first.adicionarCores(joao, [branco]);
      pedido.atualizouEtapa();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Adicionar responsável e cor'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Funcionário'));
      await tester.pumpAndSettle();
      expect(find.text('Maria Bordadeira'), findsOneWidget);
      expect(find.text('João Costureiro'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Remover João Costureiro'));
      await tester.pumpAndSettle();
      expect(pedido.processos.first.linhas, isEmpty);
      expect(pedido.processos.first.funcionario, isNull);
    });

    testWidgets('o pedido não exige responsável ao criar', (tester) async {
      final pedido = await abrir(tester);

      expect(
        pedido.processos.every((processo) => processo.funcionario == null),
        isTrue,
      );
      pedido.setNumero('1');
      pedido.setCliente(
        // ignore: prefer_const_constructors
        Empresa(id: 1, cnpj: '1', nomeFantasia: 'Cliente'),
      );
      pedido.setValorPeca(3);
      pedido.setQuantidadeSolicitada(10);
      expect(pedido.validar(), isNull);
    });
  });

  group('fechamento com cores', () {
    RepasseFuncionario repasse() {
      return RepasseFuncionario(
        funcionarioId: 1,
        funcionario: 'João Costureiro',
        total: 675,
        operacoes: [
          RepasseOperacao(
            operacaoId: 7,
            numero: '4521',
            cliente: 'Moda João',
            quantidade: 3000,
            total: 675,
            etapas: [
              RepasseEtapa(
                etapa: 'Estampa',
                valorPorPeca: 0.5,
                quantidade: 1150,
                total: 575,
                linhas: [
                  RepasseLinha(
                    cor: 'Branco',
                    hex: '#FFFFFF',
                    tamanho: 'GG',
                    quantidade: 1120,
                  ),
                  RepasseLinha(
                    cor: 'Vermelho',
                    hex: '#E5252A',
                    quantidade: 30,
                  ),
                ],
              ),
              RepasseEtapa(
                etapa: 'Etiquetagem',
                valorPorPeca: 0.1,
                quantidade: 1000,
                total: 100,
              ),
            ],
          ),
        ],
      );
    }

    Future<void> abrir(WidgetTester tester, {double escala = 1}) async {
      _tela(tester, const Size(360, 1800));
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(escala)),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    RepasseFuncionarioSheet.abrir(context, repasse()),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    testWidgets('cada lote mostra cor, tamanho, código e peças', (tester) async {
      await abrir(tester, escala: 0.5);

      expect(find.text('OP-4521 · Moda João'), findsOneWidget);
      expect(find.text('Total a receber: R\$ 675,00'), findsOneWidget);
      expect(find.text('Estampa'), findsOneWidget);
      expect(find.text('R\$ 0,50 × 1.150 peças'), findsOneWidget);
      expect(find.text('R\$ 575,00'), findsOneWidget);

      expect(find.text('Branco · GG'), findsOneWidget);
      expect(find.text('#FFFFFF'), findsOneWidget);
      expect(find.text('1.120 peças'), findsOneWidget);
      expect(find.text('Vermelho'), findsOneWidget);
      expect(find.text('#E5252A'), findsOneWidget);
      expect(find.text('30 peças'), findsOneWidget);

      expect(find.text('Etiquetagem'), findsOneWidget);
      expect(find.text('R\$ 0,10 × 1.000 peças'), findsOneWidget);
    });

    testWidgets('etapa sem cores não ganha caixa de lotes', (tester) async {
      await abrir(tester, escala: 0.5);

      expect(find.text('Sem cor'), findsNothing);
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets('em tela de celular, nada se sobrepõe e nada estoura', (
      tester,
    ) async {
      await abrir(tester, escala: 0.5);

      expect(tester.takeException(), isNull);
      final nome = tester.getRect(find.text('Branco · GG'));
      final codigo = tester.getRect(find.text('#FFFFFF'));
      final pecas = tester.getRect(find.text('1.120 peças'));
      final etapa = tester.getRect(find.text('Estampa'));
      final total = tester.getRect(find.text('R\$ 575,00'));

      expect(codigo.top, greaterThanOrEqualTo(nome.bottom - 1));
      expect(pecas.left, greaterThan(nome.right));
      expect(pecas.right, lessThanOrEqualTo(360));
      expect(total.right, lessThanOrEqualTo(360));
      expect(total.left, greaterThan(etapa.right));
      expect(nome.overlaps(pecas), isFalse);
    });
  });
}
