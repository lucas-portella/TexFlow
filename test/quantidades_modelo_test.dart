import 'package:flutter_test/flutter_test.dart';
import 'package:texflow/models/fechamento.dart';
import 'package:texflow/models/funcionario.dart';
import 'package:texflow/models/operacao.dart';
import 'package:texflow/models/processo_produtivo.dart';

void main() {
  final joao = Funcionario(id: 1, nome: 'João');
  final maria = Funcionario(id: 2, nome: 'Maria');
  final pedro = Funcionario(id: 3, nome: 'Pedro');

  group('peças por responsável', () {
    test('lê as quantidades do servidor, que chegam com chave de texto', () {
      final processo = ProcessoProdutivo.fromMap({
        'descricao': 'Final',
        'funcionario': {'id': 1, 'nome': 'João'},
        'funcionariosAdicionais': [
          {'id': 2, 'nome': 'Maria'},
        ],
        'quantidades': {'1': 400, '2': 650},
      });

      expect(processo.quantidades, {1: 400, 2: 650});
      expect(processo.responsaveisComPecas, 'João (400), Maria (650)');
      expect(processo.semQuantidade, isEmpty);
    });

    test('servidor antigo, sem quantidades, continua funcionando', () {
      final processo = ProcessoProdutivo.fromMap({
        'descricao': 'Final',
        'funcionario': {'id': 1, 'nome': 'João'},
      });

      expect(processo.quantidades, isEmpty);
      expect(processo.responsaveisComPecas, 'João');
      expect(processo.semQuantidade.map((item) => item.nome), ['João']);
    });

    test('mostra a quantidade só de quem tem e lista quem falta', () {
      final processo = ProcessoProdutivo(
        descricao: 'Final',
        quantidades: {1: 400},
      )..definirResponsaveis([joao, maria, pedro]);

      expect(processo.responsaveisComPecas, 'João (400), Maria, Pedro');
      expect(processo.semQuantidade.map((item) => item.nome), ['Maria', 'Pedro']);
    });

    test('quem sai da etapa leva a quantidade junto', () {
      final processo = ProcessoProdutivo(
        descricao: 'Final',
        quantidades: {1: 400, 2: 650, 3: 100},
      )..definirResponsaveis([joao, maria, pedro]);

      processo.definirResponsaveis([joao, pedro]);

      expect(processo.quantidades, {1: 400, 3: 100});
    });

    test('pendências ao concluir ignoram etapa cancelada e quem já tem peças', () {
      final operacao = Operacao.fromMap({
        'id': 1,
        'status': 'emAndamento',
        'gradePedido': [],
        'gradeFabricada': [],
        'processos': [
          {
            'descricao': 'Corte',
            'status': 'concluido',
            'funcionario': {'id': 1, 'nome': 'João'},
            'quantidades': {'1': 100},
          },
          {
            'descricao': 'Final',
            'status': 'emAndamento',
            'funcionario': {'id': 1, 'nome': 'João'},
            'funcionariosAdicionais': [
              {'id': 2, 'nome': 'Maria'},
            ],
            'quantidades': {'1': 400},
          },
          {
            'descricao': 'Bordado',
            'status': 'cancelado',
            'funcionario': {'id': 3, 'nome': 'Pedro'},
          },
        ],
      });

      expect(operacao.pendenciasDeQuantidade, ['Final · Maria']);
    });
  });

  group('fechamento', () {
    test('cada etapa traz as peças da pessoa, quando o servidor informa', () {
      final etapa = RepasseEtapa.fromMap({
        'etapa': 'Final',
        'valorPorPeca': 0.3,
        'quantidade': 400,
        'total': 120,
      });

      expect(etapa.quantidade, 400);
    });

    test('servidor antigo não manda a quantidade da etapa', () {
      final etapa = RepasseEtapa.fromMap({
        'etapa': 'Final',
        'valorPorPeca': 0.3,
        'total': 120,
      });

      expect(etapa.quantidade, isNull);
    });
  });
}
