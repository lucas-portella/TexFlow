import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/minha_empresa.dart';
import 'package:texflow/models/modo_operacao.dart';
import 'package:texflow/pages/modo_operacao_page.dart';
import 'package:texflow/providers/preferencias_provider.dart';

class FakePreferenciasProvider extends PreferenciasProvider {
  ModoOperacao _atual = ModoOperacao.porStatus;
  bool falhar = false;

  @override
  ModoOperacao get modoOperacao => _atual;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> alterarModoOperacao(ModoOperacao modo) async {
    if (falhar) throw Exception('Sem conexão');
    _atual = modo;
    notifyListeners();
  }
}

Future<FakePreferenciasProvider> _abrir(WidgetTester tester) async {
  final provider = FakePreferenciasProvider();
  await tester.pumpWidget(
    ChangeNotifierProvider<PreferenciasProvider>.value(
      value: provider,
      child: const MaterialApp(home: ModoOperacaoPage()),
    ),
  );
  await tester.pumpAndSettle();
  return provider;
}

void main() {
  test('ModoOperacao.deJson converte e assume por status', () {
    expect(ModoOperacao.deJson('porEtapas'), ModoOperacao.porEtapas);
    expect(ModoOperacao.deJson('porStatus'), ModoOperacao.porStatus);
    expect(ModoOperacao.deJson(null), ModoOperacao.porStatus);
    expect(ModoOperacao.deJson('xyz'), ModoOperacao.porStatus);
  });

  test('MinhaEmpresa lê o modo de operação', () {
    final empresa = MinhaEmpresa.fromMap({
      'id': 1,
      'nome': 'Têxtil',
      'modoOperacao': 'porEtapas',
    });
    expect(empresa.modoOperacao, ModoOperacao.porEtapas);
    expect(
      MinhaEmpresa.fromMap({'id': 1}).modoOperacao,
      ModoOperacao.porStatus,
    );
  });

  testWidgets('mostra as duas opções e troca o modo', (tester) async {
    final provider = await _abrir(tester);

    expect(find.text('Por status'), findsOneWidget);
    expect(find.text('Por etapas'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);

    await tester.tap(find.text('Por etapas'));
    await tester.pumpAndSettle();

    expect(provider.modoOperacao, ModoOperacao.porEtapas);
    expect(find.text('Modo de operação: Por etapas'), findsOneWidget);
  });

  testWidgets('mostra o erro quando não consegue salvar', (tester) async {
    final provider = await _abrir(tester);
    provider.falhar = true;

    await tester.tap(find.text('Por etapas'));
    await tester.pumpAndSettle();

    expect(provider.modoOperacao, ModoOperacao.porStatus);
    expect(find.text('Sem conexão'), findsOneWidget);
  });
}
