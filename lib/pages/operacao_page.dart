import 'package:flutter/material.dart';

class OperacaoPage extends StatelessWidget {
  const OperacaoPage({super.key});

  static const _grade = {
    'PP': 12,
    'P': 30,
    'M': 48,
    'G': 35,
    'GG': 20,
    'XGG': 5,
  };

  static const _processos = [
    ('Corte', 'Cortex Ltda.', true),
    ('Costura', 'Alfa Costuras', true),
    ('Bordado', 'Arte & Ponto', false),
    ('Lavagem', 'LavArt Têxtil', false),
    ('Embalagem', 'Pack & Go', false),
  ];

  static const _bg = Color(0xFFF4F5F8);
  static const _ink = Color(0xFF161A2B);
  static const _muted = Color(0xFF7A8098);
  static const _primary = Color(0xFF4652D9);
  static const _green = Color(0xFF2FBF71);
  static const _orange = Color(0xFFF2A03D);

  @override
  Widget build(BuildContext context) {
    final concluidos = _processos.where((p) => p.$3).length;
    final total = _grade.values.reduce((a, b) => a + b);

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _progresso(0.62, concluidos, _processos.length),
                const SizedBox(height: 24),
                _titulo('GRADE DE ROUPAS'),
                _gradeCard(total),
                const SizedBox(height: 24),
                _titulo('PROCESSOS PRODUTIVOS'),
                for (final p in _processos) _processoCard(p.$1, p.$2, p.$3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.maybePop(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: _ink,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Detalhes da produção',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ),
              _badge('Em produção', _primary),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _chip('PRD-2024-089', _ink),
              const SizedBox(width: 8),
              _chip('MOD-FEM-045', _primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String texto, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cor),
      ),
    );
  }

  Widget _chip(String texto, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
          color: cor,
        ),
      ),
    );
  }

  Widget _titulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: _ink,
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EBF2)),
      ),
      child: child,
    );
  }

  Widget _progresso(double valor, int feitos, int total) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progresso geral',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              Text(
                '${(valor * 100).round()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: valor,
              minHeight: 6,
              backgroundColor: const Color(0xFFE9EBF2),
              valueColor: const AlwaysStoppedAnimation(_primary),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$feitos de $total processos concluídos',
            style: const TextStyle(fontSize: 12, color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _gradeCard(int total) {
    final linhas = _grade.entries.toList();
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EBF2)),
      ),
      child: Column(
        children: [
          Container(
            color: _bg,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TAMANHO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _muted,
                  ),
                ),
                Text(
                  'QUANTIDADE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < linhas.length; i++)
            Container(
              color: i.isOdd ? const Color(0xFFFAFAFC) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    linhas[i].key,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  Text(
                    '${linhas[i].value} pç',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                      color: Color(0xFF3D4260),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            color: const Color(0xFFEDF0F7),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                Text(
                  '$total pç',
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _processoCard(String nome, String empresa, bool concluido) {
    final cor = concluido ? _green : _orange;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _card(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: concluido ? _green.withOpacity(0.12) : _bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                concluido ? Icons.check : Icons.schedule,
                size: 18,
                color: concluido ? _green : _muted,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    empresa,
                    style: const TextStyle(fontSize: 12, color: _muted),
                  ),
                ],
              ),
            ),
            _badge(concluido ? 'Concluído' : 'Pendente', cor),
          ],
        ),
      ),
    );
  }
}
