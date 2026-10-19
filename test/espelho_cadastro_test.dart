import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texflow/models/empresa.dart';
import 'package:texflow/models/modulo.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/pages/cadastro_usuario_page.dart';
import 'package:texflow/pages/clientes_page.dart';
import 'package:texflow/pages/new_order_page.dart';
import 'package:texflow/providers/cliente_provider.dart';
import 'package:texflow/providers/funcionario_provider.dart';
import 'package:texflow/providers/modelo_provider.dart';
import 'package:texflow/providers/new_operation_page_provider.dart';
import 'package:texflow/providers/usuario_provider.dart';
import 'package:texflow/providers/usuarios_provider.dart';
import 'package:texflow/routes/app_router.dart';

class _ModelosFalsos extends ModeloProvider {
  @override
  Future<void> carregar() async {}
}

class _FuncionariosFalsos extends FuncionarioProvider {
  @override
  Future<void> carregar() async {}
}

class _ClientesFalsos extends ClienteProvider {
  final List<Empresa> lista;
  final List<int> excluidos = [];

  _ClientesFalsos(this.lista);

  @override
  List<Empresa> get clientes => lista;

  @override
  bool get carregando => false;

  @override
  String? get erro => null;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> excluir(int id) async {
    excluidos.add(id);
  }
}

class _LogadoFalso extends UsuarioProvider {
  final Usuario _dado;
  final List<String> tokens = [];

  _LogadoFalso(this._dado);

  @override
  Usuario? get usuario => _dado;

  @override
  Future<void> trocarToken(String token) async {
    tokens.add(token);
  }
}

class _UsuariosFalsos extends UsuariosProvider {
  final List<Usuario> lista;
  final List<Map<String, Object?>> atualizacoes = [];
  final String? tokenDevolvido;

  _UsuariosFalsos(this.lista, {this.tokenDevolvido});

  @override
  List<Usuario> get usuarios => lista;

  @override
  Future<void> carregar() async {}

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
    atualizacoes.add({'id': usuario.idUsuario, 'novaSenha': novaSenha});
    return tokenDevolvido;
  }
}

Usuario _usuario({
  required int id,
  required String nome,
  bool dono = false,
  UserType tipo = UserType.GESTOR,
}) {
  return Usuario(
    idUsuario: id,
    nome: nome,
    email: '${nome.toLowerCase()}@texflow.com',
    senha: '',
    tipo: tipo,
    donoDaEmpresa: dono,
    modulos: Modulo.values.toSet(),
  );
}

void _tela(WidgetTester tester, [Size tamanho = const Size(800, 3000)]) {
  tester.view.physicalSize = tamanho;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Operacao _pedido() {
  return Operacao.fromMap({
    'id': 9,
    'numero': '4521',
    'status': 'naoIniciado',
    'referencia': {'id': 1, 'nome': 'Blusa'},
    'cliente': {'id': 1, 'cnpj': '12.345.678/0001-90', 'nomeFantasia': 'Moda João'},
    'dataEntrega': '2026-10-15',
    'valorPeca': 5.5,
    'quantidadeSolicitada': 120,
    'gradePedido': [
      {'descricao': 'P', 'quantidade': 60},
      {'descricao': 'M', 'quantidade': 60},
    ],
    'gradeFabricada': [],
    'processos': [
      {
        'id': 11,
        'descricao': 'Manga',
        'status': 'naoIniciado',
        'valorComissao': 0.3,
        'funcionario': {'id': 1, 'nome': 'João Costureiro'},
        'funcionariosAdicionais': [
          {'id': 2, 'nome': 'Maria Cortadora'},
        ],
      },
      {
        'id': 12,
        'descricao': 'Gola',
        'status': 'emAndamento',
        'valorComissao': 0.5,
        'funcionario': {'id': 1, 'nome': 'João Costureiro'},
      },
    ],
  });
}

void main() {
  group('alterar pedido espelha o cadastro', () {
    test('carrega tudo do pedido e trabalha numa cópia das etapas', () {
      final original = _pedido();
      final provider = NewOperationPageProvider();

      provider.carregarParaEdicao(original);

      expect(provider.editando, isTrue);
      expect(provider.numero, '4521');
      expect(provider.cliente!.nomeFantasia, 'Moda João');
      expect(provider.modelo!.nome, 'Blusa');
      expect(provider.valorPeca, 5.5);
      expect(provider.quantidadeSolicitada, 120);
      expect(provider.dataEntrega, DateTime(2026, 10, 15));
      expect(provider.gradePedido.map((item) => item.quantidade), [60, 60]);
      expect(provider.processos, hasLength(2));
      expect(provider.processos[0].idProcessoProdutivo, 11);
      expect(provider.processos[0].nomesDosResponsaveis, 'João Costureiro, Maria Cortadora');

      provider.processos[0].valorComissao = 9;
      provider.processos[0].definirResponsaveis([]);
      expect(original.processos[0].valorComissao, 0.3);
      expect(original.processos[0].funcionarios, hasLength(2));
    });

    test('só remove etapa que ainda não começou', () {
      final provider = NewOperationPageProvider();
      provider.carregarParaEdicao(_pedido());

      expect(provider.podeRemoverEtapa(provider.processos[0]), isTrue);
      expect(provider.podeRemoverEtapa(provider.processos[1]), isFalse);

      provider.removerEtapaExtra(provider.processos[1]);
      expect(provider.processos, hasLength(2));
      provider.removerEtapaExtra(provider.processos[0]);
      expect(provider.processos.map((item) => item.descricao), ['Gola']);
    });

    test('no cadastro novo a etapa do modelo não sai; no alterar, a nova sim', () {
      final provider = NewOperationPageProvider();
      final criada = _pedido().processos.first;
      provider.processos = [criada];

      expect(provider.editando, isFalse);
      expect(provider.podeRemoverEtapa(criada), isFalse);
    });

    test('pedido antigo sem número ainda pode ser salvo', () {
      final antigo = _pedido()..numero = null;
      final provider = NewOperationPageProvider();
      provider.carregarParaEdicao(antigo);

      expect(provider.numero, '');
      expect(provider.validar(), isNull);
    });

    test('limpar sai do modo de alteração', () {
      final provider = NewOperationPageProvider();
      provider.carregarParaEdicao(_pedido());

      provider.limpar();

      expect(provider.editando, isFalse);
      expect(provider.numero, '');
      expect(provider.processos, isEmpty);
    });

    testWidgets('a tela abre preenchida, com o número travado', (tester) async {
      SharedPreferences.setMockInitialValues({});
      _tela(tester);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => NewOperationPageProvider()),
            ChangeNotifierProvider<ModeloProvider>.value(value: _ModelosFalsos()),
            ChangeNotifierProvider<FuncionarioProvider>.value(
              value: _FuncionariosFalsos(),
            ),
          ],
          child: MaterialApp(home: NovoPedidoPage(operacao: _pedido())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alterar Pedido'), findsOneWidget);
      expect(find.text('Novo Pedido'), findsNothing);
      expect(find.text('Salvar alterações'), findsOneWidget);
      expect(find.text('Criar pedido'), findsNothing);

      final numero = tester.widget<TextField>(find.widgetWithText(TextField, '4521'));
      expect(numero.enabled, isFalse);
      expect(find.widgetWithText(TextField, '5,50'), findsOneWidget);
      expect(find.widgetWithText(TextField, '120'), findsOneWidget);
      expect(find.widgetWithText(TextField, '15/10/2026'), findsOneWidget);
      expect(find.text('Moda João'), findsOneWidget);
      expect(find.text('Blusa'), findsOneWidget);
      expect(find.text('João Costureiro, Maria Cortadora'), findsOneWidget);
      expect(find.text('João Costureiro'), findsOneWidget);
      expect(find.byTooltip('Remover etapa'), findsOneWidget);
    });
  });

  group('usuário: a senha também se altera no cadastro', () {
    Future<_UsuariosFalsos> abrir(
      WidgetTester tester, {
      required Usuario logado,
      required Usuario alvo,
      String? token,
    }) async {
      _tela(tester, const Size(800, 2400));
      final falsos = _UsuariosFalsos([logado, alvo], tokenDevolvido: token);
      final sessao = _LogadoFalso(logado);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UsuarioProvider>.value(value: sessao),
            ChangeNotifierProvider<UsuariosProvider>.value(value: falsos),
          ],
          child: MaterialApp(
            routes: AppRouter.routes,
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  CadastroUsuarioPage.route,
                  arguments: alvo,
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      return falsos;
    }

    testWidgets('o campo existe e está liberado ao alterar', (tester) async {
      await abrir(
        tester,
        logado: _usuario(id: 1, nome: 'Ana', dono: true),
        alvo: _usuario(id: 2, nome: 'Beto', tipo: UserType.OPERADOR),
      );

      expect(find.text('Alterar usuário'), findsOneWidget);
      expect(find.text('NOVA SENHA'), findsOneWidget);
      expect(find.text('Deixe em branco para manter'), findsOneWidget);
      final campo = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField).at(3),
          matching: find.byType(TextField),
        ),
      );
      expect(campo.enabled, isNot(false));
    });

    testWidgets('quem tem a aba define a senha de outro usuário', (tester) async {
      final falsos = await abrir(
        tester,
        logado: _usuario(id: 1, nome: 'Ana', dono: true),
        alvo: _usuario(id: 2, nome: 'Beto', tipo: UserType.OPERADOR),
      );

      await tester.enterText(find.widgetWithText(TextFormField, 'Deixe em branco para manter'), 'Nova123!');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(falsos.atualizacoes.single['id'], 2);
      expect(falsos.atualizacoes.single['novaSenha'], 'Nova123!');
    });

    testWidgets('em branco mantém a senha atual', (tester) async {
      final falsos = await abrir(
        tester,
        logado: _usuario(id: 1, nome: 'Ana', dono: true),
        alvo: _usuario(id: 2, nome: 'Beto', tipo: UserType.OPERADOR),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(falsos.atualizacoes.single['novaSenha'], '');
    });

    testWidgets('senha curta é recusada antes de enviar', (tester) async {
      final falsos = await abrir(
        tester,
        logado: _usuario(id: 1, nome: 'Ana', dono: true),
        alvo: _usuario(id: 2, nome: 'Beto', tipo: UserType.OPERADOR),
      );

      await tester.enterText(find.widgetWithText(TextFormField, 'Deixe em branco para manter'), '123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('A senha precisa ter pelo menos 6 caracteres'), findsOneWidget);
      expect(falsos.atualizacoes, isEmpty);
    });

    testWidgets('ao trocar a própria senha o app guarda o token novo', (tester) async {
      final ana = _usuario(id: 1, nome: 'Ana', dono: true);
      final sessaoFalsa = _LogadoFalso(ana);
      _tela(tester, const Size(800, 2400));
      final falsos = _UsuariosFalsos([ana], tokenDevolvido: 'token-novo');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UsuarioProvider>.value(value: sessaoFalsa),
            ChangeNotifierProvider<UsuariosProvider>.value(value: falsos),
          ],
          child: MaterialApp(
            routes: AppRouter.routes,
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  CadastroUsuarioPage.route,
                  arguments: ana,
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Deixe em branco para manter'), 'Nova123!');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(sessaoFalsa.tokens, ['token-novo']);
    });

    testWidgets('trocar a senha de outra pessoa não mexe no meu token', (tester) async {
      final ana = _usuario(id: 1, nome: 'Ana', dono: true);
      final sessaoFalsa = _LogadoFalso(ana);
      _tela(tester, const Size(800, 2400));
      final beto = _usuario(id: 2, nome: 'Beto', tipo: UserType.OPERADOR);
      final falsos = _UsuariosFalsos([ana, beto], tokenDevolvido: 'token-do-beto');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UsuarioProvider>.value(value: sessaoFalsa),
            ChangeNotifierProvider<UsuariosProvider>.value(value: falsos),
          ],
          child: MaterialApp(
            routes: AppRouter.routes,
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  CadastroUsuarioPage.route,
                  arguments: beto,
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Deixe em branco para manter'), 'Nova123!');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(sessaoFalsa.tokens, isEmpty);
    });
  });

  group('clientes: editar e excluir', () {
    Future<_ClientesFalsos> abrir(WidgetTester tester) async {
      _tela(tester, const Size(800, 1600));
      final falsos = _ClientesFalsos([
        Empresa(
          id: 1,
          cnpj: '12.345.678/0001-90',
          nomeFantasia: 'Moda João',
          contatoNome: 'João Silva',
          contatoTelefone: '(47) 99999-0000',
        ),
        Empresa(id: 2, cnpj: '98.765.432/0001-10', nomeFantasia: 'Baby Chic'),
      ]);

      await tester.pumpWidget(
        ChangeNotifierProvider<ClienteProvider>.value(
          value: falsos,
          child: MaterialApp(
            routes: AppRouter.routes,
            home: const ClientesPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return falsos;
    }

    testWidgets('tocar no cliente abre o mesmo cadastro, já preenchido', (tester) async {
      await abrir(tester);

      await tester.tap(find.text('Moda João'));
      await tester.pumpAndSettle();

      expect(find.text('Alterar cliente'), findsOneWidget);
      expect(find.text('Cadastrar cliente'), findsNothing);
      expect(find.widgetWithText(TextFormField, 'Moda João'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '12.345.678/0001-90'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'João Silva'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '(47) 99999-0000'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Salvar'), findsOneWidget);
    });

    testWidgets('o botão de novo cliente abre o cadastro vazio', (tester) async {
      await abrir(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Cadastrar cliente'), findsWidgets);
      expect(find.text('Alterar cliente'), findsNothing);
      expect(find.widgetWithText(TextFormField, 'Moda João'), findsNothing);
    });

    testWidgets('excluir pede confirmação', (tester) async {
      final falsos = await abrir(tester);

      await tester.tap(find.byTooltip('Excluir').first);
      await tester.pumpAndSettle();
      expect(find.text('Deseja excluir "Moda João"?'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(falsos.excluidos, isEmpty);

      await tester.tap(find.byTooltip('Excluir').first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
      await tester.pumpAndSettle();
      expect(falsos.excluidos, [1]);
    });
  });

  test('o status nunca é apagado ao copiar a etapa para alterar', () {
    final provider = NewOperationPageProvider();
    provider.carregarParaEdicao(_pedido());

    expect(provider.processos[1].status, Status.emAndamento);
  });
}
