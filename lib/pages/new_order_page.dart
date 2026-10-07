import 'package:flutter/material.dart';
import 'package:texflow/shared/app_colors.dart';

const navy = Color(0xFF252A5C);
const roxo = Color(0xFF5B4FC9);
const campo = Color(0xFFF1F1F4);
const borda = Color(0xFFE3E3E8);
const cinza = Color(0xFF8A8A94);
const vermelho = Color(0xFFE5484D);

class NovoPedidoPage extends StatefulWidget {
  const NovoPedidoPage({super.key});

  @override
  State<NovoPedidoPage> createState() => _NovoPedidoPageState();
}

class _Processo {
  final nome = TextEditingController();
  final empresa = TextEditingController();

  _Processo([String n = '']) {
    nome.text = n;
  }
}

class _NovoPedidoPageState extends State<NovoPedidoPage> {
  final empresa = TextEditingController();
  final data = TextEditingController();
  final tamanhos = ['PP', 'P', 'M', 'G', 'GG'];
  final grade = {'PP': 0, 'P': 0, 'M': 0, 'G': 0, 'GG': 0};
  final processos = [_Processo('Corte'), _Processo('Costura')];

  int get total => grade.values.fold(0, (a, b) => a + b);

  void alterar(String t, int d) {
    final v = grade[t]! + d;
    if (v < 0) return;
    setState(() => grade[t] = v);
  }

  Future<void> escolherData() async {
    final hoje = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: hoje,
      lastDate: DateTime(hoje.year + 5),
    );
    if (d == null) return;
    data.text =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  void adicionarProcesso() => setState(() => processos.add(_Processo()));

  void removerProcesso(int i) => setState(() => processos.removeAt(i));

  void criarPedido() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Pedido criado com $total peças')));
  }

  @override
  void dispose() {
    empresa.dispose();
    data.dispose();
    for (final p in processos) {
      p.nome.dispose();
      p.empresa.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            cabecalho(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  cartaoCliente(),
                  const SizedBox(height: 16),
                  cartaoGrade(),
                  const SizedBox(height: 16),
                  cartaoProcessos(),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: criarPedido,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.mainBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Criar pedido',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cabecalho() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: campo,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chevron_left, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Novo Pedido',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget cartao(List<Widget> filhos) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: filhos,
      ),
    );
  }

  Widget titulo(String t) {
    return Text(
      t,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget rotulo(String t) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: Color(0xFF5E5E68),
        ),
      ),
    );
  }

  InputDecoration decoracao(String hint, {IconData? icone}) {
    final b = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: borda),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB0B0B8), fontSize: 14),
      prefixIcon: icone == null ? null : Icon(icone, size: 18, color: cinza),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: b,
      enabledBorder: b,
      focusedBorder: b.copyWith(borderSide: const BorderSide(color: roxo)),
    );
  }

  Widget cartaoCliente() {
    return cartao([
      titulo('CLIENTE'),
      rotulo('EMPRESA CLIENTE'),
      TextField(
        controller: empresa,
        decoration: decoracao(
          'Ex.: Moda Bella Confecções',
          icone: Icons.business_center_outlined,
        ),
      ),
      rotulo('DATA DE ENTREGA'),
      TextField(
        controller: data,
        readOnly: true,
        onTap: escolherData,
        decoration: decoracao(
          'DD/MM/AAAA',
          icone: Icons.calendar_today_outlined,
        ),
      ),
      const SizedBox(height: 4),
    ]);
  }

  Widget botaoQtd(IconData i, VoidCallback f) {
    return InkWell(
      onTap: f,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 30,
        height: 34,
        decoration: BoxDecoration(
          color: campo,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(i, size: 16),
      ),
    );
  }

  Widget linhaTamanho(String t) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              t,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
          botaoQtd(Icons.remove, () => alterar(t, -1)),
          Expanded(
            child: Container(
              height: 34,
              color: campo,
              alignment: Alignment.center,
              child: Text(
                '${grade[t]}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          botaoQtd(Icons.add, () => alterar(t, 1)),
        ],
      ),
    );
  }

  Widget cartaoGrade() {
    return cartao([
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          titulo('GRADE DO PEDIDO'),
          Text(
            '$total peças',
            style: const TextStyle(
              color: roxo,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      for (final t in tamanhos) linhaTamanho(t),
    ]);
  }

  Widget itemProcesso(int i) {
    final p = processos[i];
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: campo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Processo ${i + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5E5E68),
                ),
              ),
              InkWell(
                onTap: () => removerProcesso(i),
                child: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: vermelho,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: p.nome,
            decoration: decoracao('Nome do processo'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: p.empresa,
            decoration: decoracao('Empresa responsável'),
          ),
        ],
      ),
    );
  }

  Widget cartaoProcessos() {
    return cartao([
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          titulo('PROCESSOS PRODUTIVOS'),
          InkWell(
            onTap: adicionarProcesso,
            child: const Row(
              children: [
                Icon(Icons.add, size: 16, color: roxo),
                SizedBox(width: 2),
                Text(
                  'Adicionar',
                  style: TextStyle(
                    color: roxo,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      for (var i = 0; i < processos.length; i++) itemProcesso(i),
    ]);
  }
}
