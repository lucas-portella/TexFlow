import 'package:flutter/material.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/app_bottom_nav.dart';
import 'package:texflow/shared/app_colors.dart';

class AppMainScaffold extends StatelessWidget {
  final String current;
  final Widget body;

  const AppMainScaffold({super.key, required this.current, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(child: body),
      bottomNavigationBar: AppBottomNav(current: current),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navBar,
        shape: const CircleBorder(),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.novoPedido),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
