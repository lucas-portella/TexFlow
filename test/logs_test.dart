import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/modulo.dart';
import 'package:texflow/models/registro_log.dart';
import 'package:texflow/pages/logs_page.dart';
import 'package:texflow/providers/logs_provider.dart';

RegistroLog _log(
  int id,
  TipoLog tipo,
  String descricao, {
  DateTime? dataHora,
  String usuario = 'Ana',
  String area = 'Produções',
}) {
  return RegistroLog(
    id: id,
    dataHora: dataHora ?? DateTime.now(),
    tipo: tipo,
    area: area,
    usuarioNome: usuario,
    descricao: descricao,
  );
}

class FakeLogsProvider extends LogsProvider {
  final List<RegistroLog> lista;
  final List<TipoLog?> tiposFiltrados = [];
  final List<DateTimeRange> periodos = [];
  int voltouParaHoje = 0;
  DateTime? _primeiro;
  DateTime? _ultimo;

  FakeLogsProvider(this.lista);

  @override
  List<RegistroLog> get logs => lista;

  @override
  DateTime get primeiroDia => _primeiro ?? super.primeiroDia;

  @override
  DateTime get ultimoDia => _ultimo ?? super.ultimoDia;

  @override
  bool get periodoEhHoje => _primeiro == null;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> filtrarTipo(TipoLog? tipo) async {
    tiposFiltrados.add(tipo);
  }

  @override
  Future<void> filtrarPeriodo(DateTime primeiro, DateTime ultimo) async {
    periodos.add(DateTimeRange(start: primeiro, end: ultimo));
    _primeiro = primeiro;
    _ultimo = ultimo;
    notifyListeners();
  }

  @override
  Future<void> voltarParaHoje() async {
    voltouParaHoje++;
    _primeiro = null;
    _ultimo = null;
    notifyListeners();
  }
}

Future<FakeLogsProvider> _abrir(
  WidgetTester tester,
  List<RegistroLog> logs,
) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final provider = FakeLogsProvider(logs);
  await tester.pumpWidget(
    ChangeNotifierProvider<LogsProvider>.value(
      value: provider,
      child: const MaterialApp(home: LogsPage()),
    ),
  );
  await tester.pumpAndSettle();
  return provider;
}

void main() {
  group('RegistroLog', () {
    test('lê o JSON, converte a hora do UTC e monta a frase', () {
      final log = RegistroLog.fromMap({
        'id': 4,
        'dataHora': '2026-10-16T17:30:00Z',
        'tipo': 'ALTERACAO',
        'area': 'Produções',
        'usuarioNome': 'Ana',
        'descricao': 'concluiu a etapa Corte da produção OP-262727',
      });

      expect(log.tipo, TipoLog.alteracao);
      expect(log.frase, 'Ana concluiu a etapa Corte da produção OP-262727');
      expect(log.dataHora.isUtc, isFalse);
      expect(log.dataHora.toUtc().hour, 17);
      expect(log.hora, hasLength(5));
    });

    test('tipo desconhecido vira alteração e o módulo Logs existe', () {
      expect(TipoLog.deJson('XPTO'), TipoLog.alteracao);
      expect(TipoLog.deJson('EXCLUSAO'), TipoLog.exclusao);
      expect(Modulo.deJson('LOGS'), Modulo.logs);
      expect(TipoLog.values.map((t) => t.rotulo), [
        'Cadastro',
        'Criação',
        'Alteração',
        'Exclusão',
        'Acesso',
      ]);
    });
  });

  group('tela de logs', () {
    testWidgets('mostra os registros separados por dia', (tester) async {
      final hoje = DateTime.now();
      final ontem = hoje.subtract(const Duration(days: 1));

      await _abrir(tester, [
        _log(3, TipoLog.alteracao, 'finalizou a produção OP-262727 (90 peças)'),
        _log(2, TipoLog.cadastro, 'cadastrou a etapa Corte', area: 'Etapas'),
        _log(1, TipoLog.exclusao, 'excluiu o custo Luz', dataHora: ontem),
      ]);

      expect(
        find.text('Ana finalizou a produção OP-262727 (90 peças)'),
        findsOneWidget,
      );
      expect(find.text('Ana cadastrou a etapa Corte'), findsOneWidget);
      expect(find.textContaining('HOJE ·'), findsOneWidget);
      expect(find.textContaining('ONTEM ·'), findsOneWidget);
      expect(find.text('3 registros'), findsOneWidget);
      expect(find.textContaining('Alteração · Produções'), findsOneWidget);
    });

    testWidgets('mostra mensagem quando não há registros', (tester) async {
      await _abrir(tester, []);

      expect(find.text('Nenhum registro neste período'), findsOneWidget);
    });

    testWidgets('filtra pelo tipo de alteração', (tester) async {
      final provider = await _abrir(tester, [
        _log(1, TipoLog.cadastro, 'cadastrou a etapa Corte'),
      ]);

      for (final rotulo in [
        'Todos',
        'Cadastro',
        'Criação',
        'Alteração',
        'Exclusão',
        'Acesso',
      ]) {
        expect(find.widgetWithText(ChoiceChip, rotulo), findsOneWidget);
      }

      await tester.tap(find.widgetWithText(ChoiceChip, 'Exclusão'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Todos'));
      await tester.pumpAndSettle();

      expect(provider.tiposFiltrados, [TipoLog.exclusao, null]);
    });

    testWidgets('abre o seletor de datas e permite voltar para hoje', (
      tester,
    ) async {
      final provider = await _abrir(tester, []);

      expect(find.text('Hoje'), findsOneWidget);

      await tester.tap(find.text('Hoje'));
      await tester.pumpAndSettle();
      expect(find.text('Aplicar'), findsOneWidget);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(provider.periodos, isEmpty);

      await provider.filtrarPeriodo(
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 5),
      );
      await tester.pumpAndSettle();
      expect(find.text('01/10 a 05/10'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(provider.voltouParaHoje, 1);
      expect(find.text('Hoje'), findsOneWidget);
    });
  });
}
