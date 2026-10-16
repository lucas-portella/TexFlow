import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/pages/admin_empresas_page.dart';
import 'package:texflow/pages/alterar_senha_page.dart';
import 'package:texflow/pages/cadastro_usuario_page.dart';
import 'package:texflow/models/referencia.dart';
import 'package:texflow/models/usuario.dart';
import 'package:texflow/pages/atalhos_page.dart';
import 'package:texflow/pages/clientes_page.dart';
import 'package:texflow/pages/custos_page.dart';
import 'package:texflow/pages/dashboard_page.dart';
import 'package:texflow/pages/etapas_page.dart';
import 'package:texflow/pages/fechamento_page.dart';
import 'package:texflow/pages/funcionarios_page.dart';
import 'package:texflow/pages/login_page.dart';
import 'package:texflow/pages/logs_page.dart';
import 'package:texflow/pages/minha_empresa_page.dart';
import 'package:texflow/pages/modelo_form_page.dart';
import 'package:texflow/pages/modo_operacao_page.dart';
import 'package:texflow/pages/modelos_page.dart';
import 'package:texflow/pages/new_order_page.dart';
import 'package:texflow/pages/operacao_page.dart';
import 'package:texflow/pages/search_page.dart';
import 'package:texflow/pages/settings_page.dart';
import 'package:texflow/pages/usuarios_page.dart';
import 'package:texflow/providers/operacao_detalhe_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_coming_soon_page.dart';
import 'package:texflow/pages/register_company.dart';
import 'package:texflow/pages/relatorios_page.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static Map<String, WidgetBuilder> get routes => {
    AppRoutes.login: (context) => const LoginPage(),
    AppRoutes.novoUsuario: (context) {
      final usuario = ModalRoute.of(context)?.settings.arguments as Usuario?;
      return CadastroUsuarioPage(usuario: usuario);
    },
    AppRoutes.alterarSenha: (context) => const AlterarSenhaPage(),
    AppRoutes.dashboard: (context) => const DashboardPage(),
    AppRoutes.pesquisa: (context) => const SearchPage(),
    AppRoutes.configuracoes: (context) => const SettingsPage(),
    AppRoutes.novoPedido: (context) => const NovoPedidoPage(),
    AppRoutes.novaEmpresa: (context) => const CadastroEmpresaPage(),
    AppRoutes.modelos: (context) => const ModelosPage(),
    AppRoutes.modeloForm: (context) {
      final modelo = ModalRoute.of(context)?.settings.arguments as Referencia?;
      return ModeloFormPage(modelo: modelo);
    },
    AppRoutes.etapas: (context) => const EtapasPage(),
    AppRoutes.funcionarios: (context) => const FuncionariosPage(),
    AppRoutes.fechamento: (context) => const FechamentoPage(),
    AppRoutes.clientes: (context) => const ClientesPage(),
    AppRoutes.minhaEmpresa: (context) => const MinhaEmpresaPage(),
    AppRoutes.atalhos: (context) => const AtalhosPage(),
    AppRoutes.modoOperacao: (context) => const ModoOperacaoPage(),
    AppRoutes.admin: (context) => const AdminEmpresasPage(),
    AppRoutes.custos: (context) => const CustosPage(),
    AppRoutes.logs: (context) => const LogsPage(),
    AppRoutes.relatorios: (context) => const RelatoriosPage(),
    AppRoutes.usuarios: (context) => const UsuariosPage(),
    AppRoutes.operacaoDetalhes: (context) {
      final id = ModalRoute.of(context)!.settings.arguments as int;
      return ChangeNotifierProvider(
        create: (_) => OperacaoDetalheProvider()..carregar(id),
        child: const OperacaoPage(),
      );
    },
  };

  static Route<dynamic> rotaDesconhecida(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const AppComingSoonPage(),
      settings: settings,
    );
  }
}
