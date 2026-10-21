import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/models/processo_produtivo.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/providers/new_operation_page_provider.dart';
import 'package:texflow/shared/process_tile.dart';

void main() {
  final joao = Funcionario(id: 1, nome: 'João');
  final maria = Funcionario(id: 2, nome: 'Maria');
  final pedro = Funcionario(id: 3, nome: 'Pedro');

  group('etapa com mais de um responsável', () {
    test('o primeiro é o principal e os demais são adicionais', () {
      final processo = ProcessoProdutivo(descricao: 'Manga');

      processo.definirResponsaveis([maria, joao, pedro]);

      expect(processo.funcionario, maria);
      expect(processo.funcionariosAdicionais, [joao, pedro]);
      expect(processo.funcionarios, [maria, joao, pedro]);
      expect(processo.nomesDosResponsaveis, 'Maria, João, Pedro');
    });

    test('trocar para uma só pessoa limpa os adicionais; nenhuma limpa tudo', () {
      final processo = ProcessoProdutivo(descricao: 'Manga')
        ..definirResponsaveis([joao, maria]);

      processo.definirResponsaveis([maria]);
      expect(processo.funcionariosAdicionais, isEmpty);
      expect(processo.funcionarios, [maria]);

      processo.definirResponsaveis([]);
      expect(processo.funcionario, isNull);
      expect(processo.funcionarios, isEmpty);
      expect(processo.nomesDosResponsaveis, '');
    });

    test('lê e envia os adicionais no mesmo formato do servidor', () {
      final processo = ProcessoProdutivo.fromMap({
        'id': 9,
        'descricao': 'Manga',
        'valorComissao': 0.3,
        'status': 'naoIniciado',
        'funcionario': {'id': 1, 'nome': 'João'},
        'funcionariosAdicionais': [
          {'id': 2, 'nome': 'Maria'},
          {'id': 3, 'nome': 'Pedro'},
        ],
      });

      expect(processo.funcionarios.map((item) => item.id), [1, 2, 3]);
      expect(processo.toMap()['funcionariosAdicionais'], [
        {'id': 2},
        {'id': 3},
      ]);
    });

    test('resposta de servidor antigo, sem adicionais, continua funcionando', () {
      final processo = ProcessoProdutivo.fromMap({
        'descricao': 'Gola',
        'funcionario': {'id': 1, 'nome': 'João'},
      });

      expect(processo.funcionariosAdicionais, isEmpty);
      expect(processo.funcionarios.single.nome, 'João');
    });

    test('novo pedido: basta uma pessoa por etapa e várias são aceitas', () {
      final provider = NewOperationPageProvider();
      provider.processos = [ProcessoProdutivo(descricao: 'Manga')];

      provider.setResponsaveis(provider.processos[0], [joao, maria]);

      expect(provider.processos[0].nomesDosResponsaveis, 'João, Maria');
      expect(
        provider.processos[0].funcionariosAdicionais.map((item) => item.id),
        [2],
      );
    });

    testWidgets('a linha da etapa mostra todos os responsáveis', (tester) async {
      final processo = ProcessoProdutivo(
        descricao: 'Manga',
        valorComissao: 0.3,
        status: Status.naoIniciado,
      )..definirResponsaveis([joao, maria]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ProcessTile(processo: processo)),
        ),
      );

      expect(find.text('João'), findsOneWidget);
      expect(find.text('Maria'), findsOneWidget);
      expect(find.text('R\$ 0,30'), findsOneWidget);
    });
  });
}
