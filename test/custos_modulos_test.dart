import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/atalho_rapido.dart';
import 'package:texflow/models/custo.dart';
import 'package:texflow/models/empresa_cliente.dart';
import 'package:texflow/models/fechamento.dart';
import 'package:texflow/models/minha_empresa.dart';
import 'package:texflow/models/modulo.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/pages/custos_page.dart';
import 'package:texflow/pages/usuarios_page.dart';
import 'package:texflow/providers/admin_provider.dart';
import 'package:texflow/providers/custo_provider.dart';
import 'package:texflow/providers/minha_empresa_provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/providers/usuarios_provider.dart';
import 'package:texflow/routes/app_router.dart';
import 'package:texflow/shared/app_drawer.dart';
import 'package:texflow/shared/pacote_modulos_sheet.dart';

Usuario _usuario({
  int id = 1,
  String nome = 'Ana',
  bool dono = false,
  UserType tipo = UserType.GESTOR,
  Set<Modulo> modulos = const {},
}) {
  return Usuario(
    idUsuario: id,
    nome: nome,
    email: '$nome@texflow.com',
    senha: '',
    tipo: tipo,
    donoDaEmpresa: dono,
    modulos: modulos,
  );
}

class FakeUsuarioProvider extends UsuarioProvider {
  final Usuario _dado;

  FakeUsuarioProvider(this._dado);

  @override
  Usuario? get usuario => _dado;
}

class FakeCustoProvider extends CustoProvider {
  final List<Custo> lista;
  final List<Map<String, Object?>> salvos = [];
  final List<int> excluidos = [];

  FakeCustoProvider(this.lista);

  @override
  List<Custo> get custos => lista;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> salvar({
    int? id,
    required String descricao,
    required CategoriaCusto categoria,
    required double valor,
    required String data,
    int? intervaloDias,
    String? dataFim,
  }) async {
    salvos.add({
      'id': id,
      'descricao': descricao,
      'categoria': categoria,
      'valor': valor,
      'intervaloDias': intervaloDias,
    });
  }

  @override
  Future<void> excluir(int id) async {
    excluidos.add(id);
  }
}

class FakeUsuariosProvider extends UsuariosProvider {
  final List<Usuario> lista;
  final List<Map<String, Object?>> atualizacoes = [];
  final List<Map<String, Object?>> criacoes = [];

  FakeUsuariosProvider(this.lista);

  @override
  List<Usuario> get usuarios => lista;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> criar({
    required String nome,
    required String email,
    required String senha,
    required UserType tipo,
    String? cargo,
    required Set<Modulo> modulos,
  }) async {
    criacoes.add({
      'nome': nome,
      'email': email,
      'tipo': tipo,
      'modulos': modulos,
    });
  }

  @override
  Future<String?> atualizar(
    Usuario usuario, {
    required String nome,
    required String email,
    String? cargo,
    UserType? tipo,
    Set<Modulo>? modulos,
    String? novaSenha,
  }) async {
    atualizacoes.add({
      'id': usuario.idUsuario,
      'nome': nome,
      'email': email,
      'cargo': cargo,
      'tipo': tipo,
      'modulos': modulos,
      'novaSenha': novaSenha,
    });
    return null;
  }
}

class FakeMinhaEmpresaProvider extends MinhaEmpresaProvider {
  @override
  MinhaEmpresa? get empresa => MinhaEmpresa(nomeFantasia: 'Alfa');

  @override
  Future<void> carregar() async {}
}

class FakeAdminProvider extends AdminProvider {
  final List<(int, Set<Modulo>)> pacotes = [];

  @override
  Future<void> alterarModulos(
    EmpresaCliente empresa,
    Set<Modulo> modulos,
  ) async {
    pacotes.add((empresa.id, modulos));
  }
}

void _tela(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Custo _custo(
  int id,
  String descricao, {
  double valor = 100,
  int? intervalo,
  int ocorrencias = 1,
  CategoriaCusto categoria = CategoriaCusto.aluguel,
}) {
  return Custo(
    id: id,
    descricao: descricao,
    categoria: categoria,
    valor: valor,
    data: '2026-10-01',
    intervaloDias: intervalo,
    ocorrenciasNoMes: ocorrencias,
    totalNoMes: valor * ocorrencias,
  );
}

void main() {
  group('Modulo', () {
    test('lê e escreve a lista do backend ignorando o que não conhece', () {
      expect(Modulo.lerLista(['CUSTOS', 'XPTO', 'ETAPAS']), {
        Modulo.custos,
        Modulo.etapas,
      });
      expect(Modulo.lerLista(null), isEmpty);
      expect(Modulo.paraJson({Modulo.usuarios, Modulo.modelos}), [
        'MODELOS',
        'USUARIOS',
      ]);
    });

    test('Usuario guarda os módulos e sabe se tem cada um', () {
      final usuario = Usuario.fromMap({
        'idUsuario': 1,
        'nome': 'Ana',
        'email': 'a@a.com',
        'tipo': 'GESTOR',
        'modulos': ['CUSTOS'],
      });

      expect(usuario.temModulo(Modulo.custos), isTrue);
      expect(usuario.temModulo(Modulo.fechamento), isFalse);
      expect(usuario.temAlgumItemDoMenu, isTrue);
      expect(Usuario.fromMap(usuario.toMap()).modulos, {Modulo.custos});
      expect(_usuario(modulos: {Modulo.usuarios}).temAlgumItemDoMenu, isFalse);
    });
  });

  group('Custo', () {
    test('lê o JSON e sabe se é recorrente', () {
      final custo = Custo.fromMap({
        'id': 3,
        'descricao': 'Aluguel',
        'categoria': 'ALUGUEL',
        'valor': 1200,
        'data': '2026-10-05',
        'intervaloDias': 30,
        'ocorrenciasNoMes': 1,
        'totalNoMes': 1200,
      });

      expect(custo.recorrente, isTrue);
      expect(custo.categoria, CategoriaCusto.aluguel);
      expect(custo.totalNoMes, 1200);
      expect(
        Custo.fromMap({'id': 1, 'categoria': 'XPTO'}).categoria,
        CategoriaCusto.outros,
      );
      expect(Custo.fromMap({'id': 1}).recorrente, isFalse);
    });

    test('Fechamento lê os custos só quando vêm no JSON', () {
      final sem = Fechamento.fromMap({'mes': '2026-10'});
      expect(sem.custosIncluidos, isFalse);
      expect(sem.custosPorCategoria, isEmpty);

      final com = Fechamento.fromMap({
        'mes': '2026-10',
        'custosIncluidos': true,
        'totalCustos': 30,
        'custosPorCategoria': [
          {'categoria': 'ALUGUEL', 'total': 30},
        ],
      });
      expect(com.custosIncluidos, isTrue);
      expect(com.totalCustos, 30);
      expect(com.custosPorCategoria.single.categoria, CategoriaCusto.aluguel);
    });
  });

  group('atalhos', () {
    test('troca os que o usuário não pode usar por outros liberados', () {
      final escolhidos = [
        AtalhoRapido.porId('inicio')!,
        AtalhoRapido.porId('fechamento')!,
        AtalhoRapido.porId('clientes')!,
        AtalhoRapido.porId('configuracoes')!,
      ];

      final semAcesso = AtalhoRapido.visiveisPara(escolhidos, _usuario());
      expect(semAcesso.map((a) => a.id), [
        'inicio',
        'pesquisa',
        'configuracoes',
      ]);
      expect(semAcesso.any((a) => a.modulo != null), isFalse);

      final comAcesso = AtalhoRapido.visiveisPara(
        escolhidos,
        _usuario(modulos: {Modulo.fechamento, Modulo.clientes}),
      );
      expect(comAcesso.map((a) => a.id), [
        'inicio',
        'fechamento',
        'clientes',
        'configuracoes',
      ]);
    });
  });

  group('menu lateral', () {
    Future<void> abrirMenu(WidgetTester tester, Usuario usuario) async {
      _tela(tester);
      final chave = GlobalKey<ScaffoldState>();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UsuarioProvider>.value(
              value: FakeUsuarioProvider(usuario),
            ),
            ChangeNotifierProvider<MinhaEmpresaProvider>.value(
              value: FakeMinhaEmpresaProvider(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              key: chave,
              drawer: const AppDrawer(),
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => chave.currentState!.openDrawer(),
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    testWidgets('mostra só os módulos liberados', (tester) async {
      await abrirMenu(
        tester,
        _usuario(modulos: {Modulo.custos, Modulo.etapas}),
      );

      expect(find.text('Custos'), findsOneWidget);
      expect(find.text('Etapas'), findsOneWidget);
      expect(find.text('Modelos'), findsNothing);
      expect(find.text('Fechamento'), findsNothing);
      expect(find.text('Alfa'), findsOneWidget);
    });

    testWidgets('com todos os módulos mostra tudo', (tester) async {
      await abrirMenu(tester, _usuario(modulos: Modulo.values.toSet()));

      for (final nome in [
        'Modelos',
        'Etapas',
        'Funcionários',
        'Clientes',
        'Custos',
        'Fechamento',
      ]) {
        await tester.scrollUntilVisible(
          find.text(nome),
          100,
          scrollable: find.descendant(
            of: find.byType(Drawer),
            matching: find.byType(Scrollable),
          ),
        );
        expect(find.text(nome), findsOneWidget);
      }
    });
  });

  group('tela de custos', () {
    Future<FakeCustoProvider> abrir(WidgetTester tester) async {
      _tela(tester);
      final provider = FakeCustoProvider([
        _custo(1, 'Aluguel do galpão', valor: 1200, intervalo: 30),
        _custo(2, 'Internet', valor: 100, intervalo: 10, ocorrencias: 3),
        _custo(3, 'Conserto antigo', valor: 50, ocorrencias: 0),
      ]);

      await tester.pumpWidget(
        ChangeNotifierProvider<CustoProvider>.value(
          value: provider,
          child: const MaterialApp(home: CustosPage()),
        ),
      );
      await tester.pumpAndSettle();
      return provider;
    }

    testWidgets('mostra o total do mês e separa os lançamentos', (
      tester,
    ) async {
      await abrir(tester);

      expect(find.text('Custos do mês'), findsOneWidget);
      expect(find.text('R\$ 1.500,00'), findsWidgets);
      expect(find.text('2 lançamentos'), findsOneWidget);
      expect(find.text('NESTE MÊS'), findsOneWidget);
      expect(find.text('OUTROS LANÇAMENTOS'), findsOneWidget);
      expect(find.textContaining('a cada 30 dias'), findsOneWidget);
      expect(find.textContaining('3x no mês'), findsOneWidget);
      expect(find.text('Conserto antigo'), findsOneWidget);
    });

    testWidgets('cadastra um custo que se repete a cada 30 dias', (
      tester,
    ) async {
      final provider = await abrir(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final campos = find.byType(TextFormField);
      expect(tester.widget<TextFormField>(campos.at(3)).enabled, isFalse);
      expect(tester.widget<TextFormField>(campos.at(4)).enabled, isFalse);

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(find.text('Informe a descrição'), findsOneWidget);
      expect(find.text('Informe um valor maior que zero'), findsOneWidget);
      expect(find.text('Escolha a data'), findsOneWidget);
      expect(provider.salvos, isEmpty);

      await tester.enterText(campos.at(0), 'Contador');
      await tester.enterText(campos.at(1), '350,50');
      await tester.tap(campos.at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Repetir automaticamente'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextFormField>(campos.at(3)).enabled, isTrue);

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(find.text('Informe de quantos em quantos dias'), findsOneWidget);

      await tester.enterText(campos.at(3), '30');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(provider.salvos, hasLength(1));
      expect(provider.salvos.single['descricao'], 'Contador');
      expect(provider.salvos.single['valor'], 350.5);
      expect(provider.salvos.single['intervaloDias'], 30);
      expect(provider.salvos.single['id'], isNull);
    });

    testWidgets('custo avulso salva sem intervalo e excluir pede confirmação', (
      tester,
    ) async {
      final provider = await abrir(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'Tecido extra');
      await tester.enterText(campos.at(1), '80');
      await tester.tap(campos.at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(provider.salvos.single['intervaloDias'], isNull);

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      expect(find.text('Deseja excluir "Aluguel do galpão"?'), findsOneWidget);
      await tester.tap(find.text('Excluir').last);
      await tester.pumpAndSettle();
      expect(provider.excluidos, [1]);
    });
  });

  group('tela de usuários e acessos', () {
    Future<FakeUsuariosProvider> abrir(
      WidgetTester tester, {
      Usuario? logado,
      List<Usuario>? usuarios,
    }) async {
      _tela(tester);
      final provider = FakeUsuariosProvider(
        usuarios ??
            [
              _usuario(
                id: 1,
                nome: 'Ana',
                dono: true,
                modulos: Modulo.values.toSet(),
              ),
              _usuario(id: 2, nome: 'Beto', tipo: UserType.OPERADOR),
            ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UsuarioProvider>.value(
              value: FakeUsuarioProvider(
                logado ??
                    _usuario(id: 1, dono: true, modulos: Modulo.values.toSet()),
              ),
            ),
            ChangeNotifierProvider<UsuariosProvider>.value(value: provider),
          ],
          child: MaterialApp(
            routes: AppRouter.routes,
            home: const UsuariosPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return provider;
    }

    testWidgets('lista os usuários com o resumo dos acessos', (tester) async {
      await abrir(tester);

      expect(find.text('Ana'), findsOneWidget);
      expect(find.textContaining('Acessa tudo'), findsOneWidget);
      expect(find.text('Principal'), findsOneWidget);
      expect(find.textContaining('Somente produções'), findsOneWidget);
    });

    testWidgets('usuário novo abre a tela de cadastro', (tester) async {
      await abrir(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Cadastrar usuário'), findsOneWidget);
      expect(find.text('Alterar usuário'), findsNothing);
      expect(find.widgetWithText(ElevatedButton, 'Cadastrar'), findsOneWidget);
    });

    testWidgets('usuário existente abre a mesma tela, já preenchida', (
      tester,
    ) async {
      await abrir(
        tester,
        usuarios: [
          _usuario(
            id: 1,
            nome: 'Ana',
            dono: true,
            modulos: Modulo.values.toSet(),
          ),
          Usuario(
            idUsuario: 2,
            nome: 'Beto',
            email: 'beto@texflow.com',
            senha: '',
            tipo: UserType.OPERADOR,
            cargo: 'Costureiro',
            modulos: {Modulo.etapas},
          ),
        ],
      );

      await tester.tap(find.text('Beto'));
      await tester.pumpAndSettle();

      expect(find.text('Alterar usuário'), findsOneWidget);
      expect(find.text('Cadastrar usuário'), findsNothing);
      expect(find.text('Beto'), findsOneWidget);
      expect(find.text('Costureiro'), findsOneWidget);
      expect(find.text('beto@texflow.com'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Salvar'), findsOneWidget);
      expect(
        tester
            .widget<SwitchListTile>(
              find.widgetWithText(SwitchListTile, 'Etapas'),
            )
            .value,
        isTrue,
      );
      expect(
        tester
            .widget<SwitchListTile>(
              find.widgetWithText(SwitchListTile, 'Custos'),
            )
            .value,
        isFalse,
      );
    });

    testWidgets('altera os dados e os acessos do usuário e salva', (
      tester,
    ) async {
      final provider = await abrir(tester);

      await tester.tap(find.text('Beto'));
      await tester.pumpAndSettle();

      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'Beto Silva');
      await tester.enterText(campos.at(1), 'Corte');
      await tester.tap(find.widgetWithText(SwitchListTile, 'Custos'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(provider.atualizacoes, hasLength(1));
      final atualizacao = provider.atualizacoes.single;
      expect(atualizacao['id'], 2);
      expect(atualizacao['nome'], 'Beto Silva');
      expect(atualizacao['cargo'], 'Corte');
      expect(atualizacao['tipo'], UserType.OPERADOR);
      expect(atualizacao['modulos'], {Modulo.custos});
      expect(provider.criacoes, isEmpty);
      expect(find.text('Usuário atualizado com sucesso'), findsOneWidget);
      expect(find.text('Alterar usuário'), findsNothing);
    });

    testWidgets('trocar o perfil de um usuário existente mantém os acessos', (
      tester,
    ) async {
      final provider = await abrir(tester);

      await tester.tap(find.text('Beto'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Operador'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Supervisor').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(provider.atualizacoes.single['tipo'], UserType.GESTOR);
      expect(provider.atualizacoes.single['modulos'], <Modulo>{});
    });

    testWidgets('o usuário principal abre com perfil e acessos travados', (
      tester,
    ) async {
      final provider = await abrir(tester);

      await tester.tap(find.text('Ana'));
      await tester.pumpAndSettle();

      final chave = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Custos'),
      );
      expect(chave.value, isTrue);
      expect(chave.onChanged, isNull);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();

      final atualizacao = provider.atualizacoes.single;
      expect(atualizacao['tipo'], isNull);
      expect(atualizacao['modulos'], isNull);
    });

    testWidgets('quem concede só alcança os módulos que tem', (tester) async {
      await abrir(
        tester,
        logado: _usuario(id: 1, modulos: {Modulo.usuarios, Modulo.etapas}),
        usuarios: [_usuario(id: 2, nome: 'Beto', tipo: UserType.OPERADOR)],
      );

      await tester.tap(find.text('Beto'));
      await tester.pumpAndSettle();

      SwitchListTile chave(String nome) => tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, nome),
      );

      expect(chave('Etapas').onChanged, isNotNull);
      expect(chave('Custos').onChanged, isNull);
      expect(chave('Fechamento').onChanged, isNull);
      expect(find.widgetWithText(SwitchListTile, 'Custos'), findsOneWidget);
    });
  });

  group('pacote da empresa', () {
    testWidgets('o admin escolhe os módulos que a empresa contratou', (
      tester,
    ) async {
      _tela(tester);
      final admin = FakeAdminProvider();
      final empresa = EmpresaCliente(
        id: 7,
        nomeFantasia: 'Malhas Beta',
        ativa: true,
        totalUsuarios: 2,
        modulos: Modulo.values.toSet(),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AdminProvider>.value(
          value: admin,
          child: MaterialApp(
            home: Scaffold(body: PacoteModulosSheet(empresa: empresa)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pacote de Malhas Beta'), findsOneWidget);

      SwitchListTile chave(String nome) => tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, nome),
      );
      expect(chave('Modelos').value, isTrue);
      expect(chave('Modelos').onChanged, isNull);
      expect(chave('Usuários').onChanged, isNull);
      expect(chave('Modo de operação').onChanged, isNull);
      expect(chave('Custos').onChanged, isNotNull);
      expect(chave('Fechamento').onChanged, isNotNull);
      expect(chave('Logs').onChanged, isNotNull);

      await tester.tap(find.widgetWithText(SwitchListTile, 'Custos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar pacote'));
      await tester.pumpAndSettle();

      expect(admin.pacotes.single.$1, 7);
      expect(admin.pacotes.single.$2.contains(Modulo.custos), isFalse);
      expect(admin.pacotes.single.$2.length, Modulo.values.length - 1);
    });
  });
}
