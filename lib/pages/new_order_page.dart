import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/empresa.dart';
import 'package:texflow/models/item_grade.dart';
import 'package:texflow/models/processo_produtivo.dart';
import 'package:texflow/providers/new_operation_page_provider.dart';
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

  Future<void> escolherData(BuildContext context) async {
    final hoje = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: hoje,
      lastDate: DateTime(hoje.year + 5),
    );

    if (d == null) return;
    final controller = context.read<NewOperationPageProvider>();

    controller.updateDataEntrega(d);
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
    return Consumer<NewOperationPageProvider>(
      builder: (context, controller, child) {
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
                          onPressed: controller.criarPedido,
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
      },
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
    return Consumer<NewOperationPageProvider>(
      builder: (context, controller, child) {
        bool clienteSelecionado = controller.cliente != null;
        if (clienteSelecionado) {
          return cartao([
            titulo('CLIENTE'),
            rotulo('EMPRESA CLIENTE'),
            GestureDetector(
              onTap: () {
                ModalSelecionarEmpresa(
                  context,
                  controller.listarEmpresas(),
                  controller.setCliente,
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.business_center_outlined),
                    SizedBox(width: 12),
                    Text(controller.cliente!.nomeFantasia),
                  ],
                ),
              ),
            ),
            rotulo('DATA DE ENTREGA'),
            TextField(
              controller: data,
              readOnly: true,
              onTap: () => escolherData(context),
              decoration: decoracao(
                'DD/MM/AAAA',
                icone: Icons.calendar_today_outlined,
              ),
            ),
            const SizedBox(height: 4),
          ]);
        }

        return cartao([
          titulo('CLIENTE'),
          rotulo('EMPRESA CLIENTE'),
          TextButton(
            onPressed: () {
              ModalSelecionarEmpresa(
                context,
                controller.listarEmpresas(),
                controller.setCliente,
              );
            },
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: roxo,
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              child: Center(
                child: Text(
                  'Selecione cliente',
                  style: TextStyle(color: Colors.white, fontFamily: 'DM Sans'),
                ),
              ),
            ),
          ),
          rotulo('DATA DE ENTREGA'),
          TextField(
            controller: data,
            readOnly: true,
            onTap: () => escolherData(context),
            decoration: decoracao(
              'DD/MM/AAAA',
              icone: Icons.calendar_today_outlined,
            ),
          ),
          const SizedBox(height: 4),
        ]);
      },
    );
  }

  Future<dynamic> ModalSelecionarEmpresa(
    BuildContext context,
    Future<List<Empresa>>? futureBuilder,
    void Function(Empresa) setFunction,
  ) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Empresa>>(
          future: futureBuilder,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar empresas'));
            }

            final empresas = snapshot.data ?? [];

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.business, color: navy),
                  ),
                  const Text(
                    'Selecione uma empresa:',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      color: navy,
                      fontSize: 18,
                    ),
                  ),

                  for (final empresa in empresas)
                    TextButton(
                      onPressed: () {
                        setFunction(empresa);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: roxo,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            empresa.nomeFantasia,
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
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

  Widget linhaTamanho(ItemGrade item) {
    return Consumer<NewOperationPageProvider>(
      builder: (context, controller, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              SizedBox(
                width: 34,
                child: Text(
                  item.descricao,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              botaoQtd(
                Icons.remove,
                () => controller.decrementarQuantidadeItemGrade(item),
              ),
              Expanded(
                child: Container(
                  height: 34,
                  color: campo,
                  alignment: Alignment.center,
                  child: Text(
                    '${item.quantidade}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              botaoQtd(
                Icons.add,
                () => controller.incrementarQuantidadeItemGrade(item),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget cartaoGrade() {
    return Consumer<NewOperationPageProvider>(
      builder: (context, controller, child) {
        final total = controller.gradePedido.fold<int>(
          0,
          (previousValue, element) => previousValue + element.quantidade,
        );
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
          for (final t in controller.gradePedido) linhaTamanho(t),
        ]);
      },
    );
  }

  Widget itemProcesso(ProcessoProdutivo processo) {
    return Consumer<NewOperationPageProvider>(
      builder: (context, controller, child) {
        bool selecionouEmpresa = processo.empresaResponsavel != null;
        Widget mostradorEmpresa;
        if (selecionouEmpresa) {
          mostradorEmpresa = GestureDetector(
            onTap: () {
              ModalSelecionarEmpresa(context, controller.listarEmpresas(), (
                empresa,
              ) {
                controller.updateEmpresaProcessoProdutivo(processo, empresa);
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.business_center_outlined),
                  SizedBox(width: 12),
                  Text(processo.empresaResponsavel!.nomeFantasia),
                ],
              ),
            ),
          );
        } else {
          mostradorEmpresa = TextButton(
            onPressed: () {
              ModalSelecionarEmpresa(context, controller.listarEmpresas(), (
                empresa,
              ) {
                controller.updateEmpresaProcessoProdutivo(processo, empresa);
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: roxo,
              ),
              child: Center(
                child: Text(
                  'Selecionar empresa responsável',
                  style: TextStyle(fontFamily: 'DM Sans', color: Colors.white),
                ),
              ),
            ),
          );
        }

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
                    'Processo',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5E5E68),
                    ),
                  ),
                  InkWell(
                    onTap: () => controller.deletarProcessoProdutivo(processo),
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
                onChanged: (value) {
                  controller.updateDescricaoProcessoProdutivo(processo, value);
                },
                controller: TextEditingController(text: processo.descricao),
                decoration: decoracao(processo.descricao),
              ),
              const SizedBox(height: 8),
              mostradorEmpresa,
            ],
          ),
        );
      },
    );
  }

  Widget cartaoProcessos() {
    return Consumer<NewOperationPageProvider>(
      builder: (context, controller, child) {
        return cartao([
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              titulo('PROCESSOS PRODUTIVOS'),
              InkWell(
                onTap: controller.criarProcessoProdutivo,
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
          for (final i in controller.processos) itemProcesso(i),
        ]);
      },
    );
  }
}
