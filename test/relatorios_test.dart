import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/custo.dart';
import 'package:texflow/models/modulo.dart';
import 'package:texflow/models/relatorio.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/pages/relatorios_page.dart';
import 'package:texflow/providers/minha_empresa_provider.dart';
import 'package:texflow/providers/relatorios_provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_drawer.dart';
import 'package:texflow/shared/formatters.dart';
import 'package:texflow/shared/variacao_chip.dart';

PeriodoDoRelatorio _periodo({String unidade = 'semana'}) {
  return PeriodoDoRelatorio(
    dias: 18,
    inicio: '2026-03-01',
    fim: '2026-03-18',
    anteriorInicio: '2026-02-11',
    anteriorFim: '2026-02-28',
    unidadeMedia: unidade,
  );
}

Metrica _m(
  double atual,
  double anterior, {
  double? variacao,
  double media = 0,
  double mediaAnterior = 0,
}) {
  return Metrica(
    atual: atual,
    anterior: anterior,
    variacaoPercentual: variacao,
    mediaAtual: media,
    mediaAnterior: mediaAnterior,
  );
}

RelatorioEmpresa _empresa({bool custos = true}) {
  return RelatorioEmpresa(
    periodo: _periodo(),
    custosIncluidos: custos,
    faturamento: _m(
      1500,
      2000,
      variacao: -25,
      media: 583.33,
      mediaAnterior: 777.78,
    ),
    repasses: _m(150, 200, variacao: -25, media: 58.33),
    despesas: _m(300, 100, variacao: 200, media: 116.67),
    lucro: _m(1050, 1700, variacao: -38.2, media: 408.33),
    producoes: _m(2, 1, variacao: 100),
    pecas: _m(150, 200, variacao: -25),
    faturamentoDoAno: _m(3500, 1000, variacao: 250, media: 1356.25),
    despesasPorCategoria: [
      LinhaCategoriaRelatorio(
        categoria: CategoriaCusto.aluguel,
        valor: _m(300, 100, variacao: 200, media: 116.67),
      ),
    ],
    repassesPorEtapa: [
      LinhaEtapaRelatorio(etapa: 'Costura', valor: _m(150, 0, media: 58.33)),
      LinhaEtapaRelatorio(etapa: 'Corte', valor: _m(0, 200, variacao: -100)),
    ],
  );
}

RelatorioFuncionarios _funcionarios() {
  return RelatorioFuncionarios(
    periodo: _periodo(),
    totalPecas: _m(150, 200, variacao: -25, media: 58.3),
    totalRepasse: _m(150, 200, variacao: -25, media: 58.33),
    funcionarios: [
      LinhaFuncionarioRelatorio(
        funcionarioId: 1,
        funcionario: 'Ana',
        pecas: _m(150, 0, media: 58.3),
        producoes: _m(2, 0),
        repasse: _m(150, 0),
        valorMedioPorPeca: 1,
        etapaPrincipal: 'Costura',
      ),
      LinhaFuncionarioRelatorio(
        funcionarioId: 2,
        funcionario: 'Bia',
        pecas: _m(0, 200, variacao: -100),
        producoes: _m(0, 1),
        repasse: _m(0, 200),
        valorMedioPorPeca: 0,
      ),
    ],
  );
}

class FakeRelatoriosProvider extends RelatoriosProvider {
  final RelatorioEmpresa _empresaFalsa;
  final RelatorioFuncionarios _funcionariosFalsos;
  final List<DateTimeRange> periodos = [];
  int voltouAoPadrao = 0;
  DateTime? _inicioEscolhido;
  DateTime? _fimEscolhido;

  FakeRelatoriosProvider({bool custos = true})
    : _empresaFalsa = _empresa(custos: custos),
      _funcionariosFalsos = _funcionarios();

  @override
  DateTime get inicio => _inicioEscolhido ?? DateTime(2026, 3, 1);

  @override
  DateTime get fim => _fimEscolhido ?? DateTime(2026, 3, 18);

  @override
  bool get periodoEhPadrao => _inicioEscolhido == null;

  @override
  RelatorioEmpresa? get empresa => _empresaFalsa;

  @override
  RelatorioFuncionarios? get funcionarios => _funcionariosFalsos;

  @override
  bool get carregando => false;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> filtrarPeriodo(DateTime inicio, DateTime fim) async {
    periodos.add(DateTimeRange(start: inicio, end: fim));
    _inicioEscolhido = inicio;
    _fimEscolhido = fim;
    notifyListeners();
  }

  @override
  Future<void> voltarParaPadrao() async {
    voltouAoPadrao++;
    _inicioEscolhido = null;
    _fimEscolhido = null;
    notifyListeners();
  }
}

class FakeUsuarioProvider extends UsuarioProvider {
  final Set<Modulo> modulos;

  FakeUsuarioProvider(this.modulos);

  @override
  Usuario? get usuario => Usuario(
    idUsuario: 1,
    nome: 'Ana',
    email: 'a@a.com',
    senha: '',
    tipo: UserType.GESTOR,
    modulos: modulos,
  );
}

class FakeMinhaEmpresaProvider extends MinhaEmpresaProvider {
  @override
  Future<void> carregar() async {}
}

Future<FakeRelatoriosProvider> _abrir(
  WidgetTester tester, {
  bool custos = true,
}) async {
  tester.view.physicalSize = const Size(800, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final provider = FakeRelatoriosProvider(custos: custos);
  await tester.pumpWidget(
    ChangeNotifierProvider<RelatoriosProvider>.value(
      value: provider,
      child: const MaterialApp(home: RelatoriosPage()),
    ),
  );
  await tester.pumpAndSettle();
  return provider;
}

void main() {
  group('modelos', () {
    test('lê o JSON do relatório da empresa', () {
      final relatorio = RelatorioEmpresa.fromMap({
        'periodo': {
          'tipo': 'ANO',
          'inicio': '2026-01-01',
          'fim': '2026-03-18',
          'anteriorInicio': '2025-01-01',
          'anteriorFim': '2025-03-18',
          'unidadeMedia': 'mês',
        },
        'custosIncluidos': true,
        'faturamento': {
          'atual': 3500,
          'anterior': 1000,
          'variacaoPercentual': 250.0,
          'mediaAtual': 1356.25,
          'mediaAnterior': 387.5,
        },
        'despesas': {'atual': 0, 'anterior': 0, 'variacaoPercentual': null},
        'despesasPorCategoria': [
          {
            'categoria': 'ALUGUEL',
            'valor': {'atual': 300, 'anterior': 100},
          },
        ],
        'repassesPorEtapa': [
          {
            'etapa': 'Costura',
            'valor': {'atual': 150, 'anterior': 0},
          },
        ],
      });

      expect(relatorio.periodo.unidadeMedia, 'mês');
      expect(relatorio.faturamento.atual, 3500);
      expect(relatorio.faturamento.variacaoPercentual, 250);
      expect(relatorio.despesas.variacaoPercentual, isNull);
      expect(relatorio.lucro.atual, 0);
      expect(
        relatorio.despesasPorCategoria.single.categoria,
        CategoriaCusto.aluguel,
      );
      expect(relatorio.repassesPorEtapa.single.etapa, 'Costura');
    });

    test('lê o JSON do relatório de funcionários', () {
      final relatorio = RelatorioFuncionarios.fromMap({
        'totalPecas': {'atual': 150, 'anterior': 200},
        'funcionarios': [
          {
            'funcionarioId': 4,
            'funcionario': 'Ana',
            'pecas': {'atual': 150, 'anterior': 0},
            'producoes': {'atual': 2, 'anterior': 0},
            'repasse': {'atual': 150, 'anterior': 0},
            'valorMedioPorPeca': 1,
            'etapaPrincipal': 'Costura',
          },
        ],
      });

      expect(relatorio.funcionarios.single.funcionario, 'Ana');
      expect(relatorio.funcionarios.single.valorMedioPorPeca, 1);
      expect(relatorio.funcionarios.single.etapaPrincipal, 'Costura');
      expect(relatorio.totalPecas.anterior, 200);
    });

    test('formata números com vírgula e ponto de milhar', () {
      expect(formatarNumero(1356.25), '1.356,3');
      expect(formatarNumero(58.3, casas: 2), '58,30');
      expect(formatarInteiro(12500), '12.500');
      expect(formatarNumero(-3.04), '-3,0');
    });
  });

  group('variação', () {
    Future<void> mostrar(WidgetTester tester, Widget chip) {
      return tester.pumpWidget(MaterialApp(home: Scaffold(body: chip)));
    }

    Color? corDoTexto(WidgetTester tester, String texto) {
      return tester.widget<Text>(find.text(texto)).style?.color;
    }

    testWidgets('subir é verde quando mais é melhor, vermelho quando não é', (
      tester,
    ) async {
      await mostrar(tester, const VariacaoChip(variacao: 12.5));
      expect(find.text('+12,5%'), findsOneWidget);
      expect(corDoTexto(tester, '+12,5%'), AppColors.success);

      await mostrar(
        tester,
        const VariacaoChip(variacao: 12.5, maisEhBom: false),
      );
      expect(corDoTexto(tester, '+12,5%'), AppColors.danger);

      await mostrar(tester, const VariacaoChip(variacao: -8));
      expect(find.text('-8,0%'), findsOneWidget);
      expect(corDoTexto(tester, '-8,0%'), AppColors.danger);
    });

    testWidgets('sem base, zero e neutro têm cinza', (tester) async {
      await mostrar(tester, const VariacaoChip(variacao: null));
      expect(find.text('Sem base'), findsOneWidget);

      await mostrar(tester, const VariacaoChip(variacao: 0));
      expect(find.text('0,0%'), findsOneWidget);

      await mostrar(tester, const VariacaoChip(variacao: 30, maisEhBom: null));
      expect(corDoTexto(tester, '+30,0%'), AppColors.muted);
    });
  });

  group('tela de relatórios', () {
    testWidgets('o período vem do calendário e mostra o que foi comparado', (
      tester,
    ) async {
      final provider = await _abrir(tester);

      expect(find.text('01/03/2026 a 18/03/2026'), findsOneWidget);
      expect(
        find.text('18 dias · comparado com 11/02/2026 a 28/02/2026'),
        findsOneWidget,
      );
      expect(find.text('Esta semana'), findsNothing);
      expect(find.text('Este mês'), findsNothing);
      expect(find.text('Este ano'), findsNothing);

      await tester.tap(find.text('01/03/2026 a 18/03/2026'));
      await tester.pumpAndSettle();
      expect(find.text('Aplicar'), findsOneWidget);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(provider.periodos, isEmpty);

      await provider.filtrarPeriodo(
        DateTime(2026, 1, 5),
        DateTime(2026, 1, 20),
      );
      await tester.pumpAndSettle();
      expect(find.text('05/01/2026 a 20/01/2026'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(provider.voltouAoPadrao, 1);
      expect(find.text('01/03/2026 a 18/03/2026'), findsOneWidget);
    });

    testWidgets('um único dia aparece sem repetir a data', (tester) async {
      final provider = await _abrir(tester);

      await provider.filtrarPeriodo(
        DateTime(2026, 3, 10),
        DateTime(2026, 3, 10),
      );
      await tester.pumpAndSettle();

      expect(find.text('10/03/2026'), findsOneWidget);
    });

    testWidgets('funcionários: totais, ranking, média e comparação', (
      tester,
    ) async {
      await _abrir(tester);

      expect(find.text('Total de peças'), findsOneWidget);
      expect(find.text('Total de repasses'), findsOneWidget);
      expect(find.text('POR FUNCIONÁRIO'), findsOneWidget);
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Mais faz: Costura'), findsOneWidget);
      expect(find.text('150 peças'), findsWidgets);
      expect(find.text('Média por semana: 58,3 peças'), findsOneWidget);
      expect(
        find.text('Comparado ao período anterior: 0 peças'),
        findsOneWidget,
      );
      expect(find.text('Sem base'), findsOneWidget);
      expect(find.text('Bia'), findsOneWidget);
      expect(find.text('-100,0%'), findsOneWidget);
      expect(find.text('Produções'), findsWidgets);
      expect(find.text('Por peça'), findsWidgets);
    });

    testWidgets(
      'empresa: faturamento, médias, despesas por categoria e etapa',
      (tester) async {
        await _abrir(tester);

        await tester.tap(find.text('Empresa'));
        await tester.pumpAndSettle();

        expect(find.text('Média de faturamento'), findsOneWidget);
        expect(find.text('R\$ 583,33'), findsOneWidget);
        expect(find.textContaining('Média por semana'), findsNothing);
        expect(
          find.text('Média do período anterior: R\$ 777,78'),
          findsOneWidget,
        );
        expect(find.text('-25,0%'), findsWidgets);
        expect(find.text('Faturamento do ano até agora'), findsOneWidget);
        expect(find.text('R\$ 3.500,00'), findsOneWidget);
        expect(find.text('Período anterior: R\$ 1.000,00'), findsOneWidget);
        expect(find.text('Média de repasses aos funcionários'), findsOneWidget);
        expect(find.text('Média de despesas (custos)'), findsOneWidget);
        expect(find.text('Média de lucro'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('DESPESAS POR CATEGORIA'),
          400,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.text('REPASSES POR TIPO DE ETAPA'), findsOneWidget);
        expect(find.text('Costura'), findsOneWidget);
        expect(find.text('Corte'), findsOneWidget);
        expect(find.text('Aluguel'), findsOneWidget);
      },
    );

    testWidgets(
      'sem o módulo de custos na empresa não aparece nenhuma despesa',
      (tester) async {
        await _abrir(tester, custos: false);

        await tester.tap(find.text('Empresa'));
        await tester.pumpAndSettle();

        expect(find.text('Média de despesas (custos)'), findsNothing);
        expect(find.text('Média de lucro'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('REPASSES POR TIPO DE ETAPA'),
          400,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.text('DESPESAS POR CATEGORIA'), findsNothing);
      },
    );
  });

  group('menu', () {
    Future<void> abrirMenu(WidgetTester tester, Set<Modulo> modulos) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final chave = GlobalKey<ScaffoldState>();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UsuarioProvider>.value(
              value: FakeUsuarioProvider(modulos),
            ),
            ChangeNotifierProvider<MinhaEmpresaProvider>.value(
              value: FakeMinhaEmpresaProvider(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              key: chave,
              drawer: const AppDrawer(),
              body: TextButton(
                onPressed: () => chave.currentState!.openDrawer(),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    testWidgets('Relatórios aparece para quem tem a aba', (tester) async {
      await abrirMenu(tester, {Modulo.relatorios});
      expect(find.text('Relatórios'), findsOneWidget);
    });

    testWidgets('Relatórios some para quem não tem a aba', (tester) async {
      await abrirMenu(tester, {Modulo.etapas});
      expect(find.text('Relatórios'), findsNothing);
    });

    test('Relatórios é opcional no pacote da empresa', () {
      expect(Modulo.opcionaisNoPacote, contains(Modulo.relatorios));
      expect(Modulo.doMenu, contains(Modulo.relatorios));
    });
  });
}
