import 'package:flutter/material.dart';
import 'package:texflow/pages/cadastro_page.dart';
import 'package:texflow/pages/dashboard_page.dart';
import 'package:texflow/pages/login_page.dart';
import 'package:texflow/pages/new_order_page.dart';
import 'package:texflow/pages/search_page.dart';
import 'package:texflow/pages/settings_page.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_coming_soon_page.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
    AppRoutes.login: (context) => const LoginPage(),
    AppRoutes.cadastro: (context) => const CadastroPage(),
    AppRoutes.dashboard: (context) => const DashboardPage(),
    AppRoutes.pesquisa: (context) => const SearchPage(),
    AppRoutes.configuracoes: (context) => const SettingsPage(),
    AppRoutes.novoPedido: (context) => const NovoPedidoPage(),
  };

  static Route<dynamic> rotaDesconhecida(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const AppComingSoonPage(),
      settings: settings,
    );
  }
}
