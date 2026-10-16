import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/item_grade.dart';
import 'package:texflow/models/processo_produtivo.dart';
import 'package:texflow/providers/funcionario_provider.dart';
import 'package:texflow/providers/modelo_provider.dart';
import 'package:texflow/providers/new_operation_page_provider.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/adicionar_etapa_sheet.dart';
import 'package:texflow/shared/comissao_etapa_dialog.dart';
import 'package:texflow/shared/formatters.dart';
import 'package:texflow/shared/selecionar_cliente_sheet.dart';

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

class _NovoPedidoPageState extends State<NovoPedidoPage> {
  final data = TextEditingController();
  final numeroController = TextEditingController();
  final valorPeca = TextEditingController();
  final quantidade = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewOperationPageProvider>().limpar();
      context.read<ModeloProvider>().carregar();
      context.read<FuncionarioProvider>().carregar();
    });
  }

  Future<void> escolherData(BuildContext context) async {
    final hoje = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: hoje,
      lastDate: DateTime(hoje.year + 5),
    );

    if (d == null || !context.mounted) return;
    final controller = context.read<NewOperationPageProvider>();

    controller.updateDataEntrega(d);
    data.text =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> criarPedido() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final controller = context.read<NewOperationPageProvider>();

    try {
      await controller.criarPedido();
      messenger.showSnackBar(
        const SnackBar(content: Text('Pedido criado com sucesso')),
      );
      navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  void dispose() {
    data.dispose();
    numeroController.dispose();
    valorPeca.dispose();
    quantidade.dispose();
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
                      cartaoProducao(),
                      const SizedBox(height: 16),
                      cartaoGrade(),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: controller.salvando ? null : criarPedido,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.mainBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: controller.salvando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
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
        final cliente = controller.cliente;

        return cartao([
          titulo('CLIENTE'),
          rotulo('CLIENTE'),
          campoSelecao(
            icone: Icons.business_center_outlined,
            texto: cliente?.nomeFantasia,
            detalhe: cliente?.cnpj,
            vazio: 'Selecione o cliente',
            aoTocar: () async {
              final escolhido = await SelecionarClienteSheet.abrir(
                context,
                carregar: controller.listarEmpresas,
              );
              if (escolhido != null) controller.setCliente(escolhido);
            },
          ),
          rotulo('PREVISÃO DE ENTREGA'),
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

  Future<void> escolherModelo(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return Consumer<ModeloProvider>(
          builder: (_, provider, child) {
            if (provider.carregando && provider.modelos.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (provider.ativos.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nenhum modelo ativo. Cadastre ou ative no menu Modelos.',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                for (final modelo in provider.ativos)
                  ListTile(
                    title: Text(modelo.nome),
                    subtitle: Text('${modelo.etapas.length} etapas'),
                    onTap: () {
                      context.read<NewOperationPageProvider>().setModelo(
                        modelo,
                      );
                      Navigator.pop(sheetContext);
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> escolherResponsavel(
    BuildContext context,
    ProcessoProdutivo processo,
  ) {
    return showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return Consumer<FuncionarioProvider>(
          builder: (_, provider, child) {
            if (provider.carregando && provider.funcionarios.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (provider.ativos.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nenhum funcionário ativo. Cadastre no menu Funcionários.',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                  child: Text(
                    'Responsável pela etapa ${processo.descricao}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                for (final funcionario in provider.ativos)
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(funcionario.nome),
                    subtitle: funcionario.cargo == null
                        ? null
                        : Text(funcionario.cargo!),
                    onTap: () {
                      context.read<NewOperationPageProvider>().setResponsavel(
                        processo,
                        funcionario,
                      );
                      Navigator.pop(sheetContext);
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> alterarValor(
    BuildContext context,
    ProcessoProdutivo processo,
  ) async {
    final controller = context.read<NewOperationPageProvider>();

    final novoValor = await pedirComissaoDaEtapa(
      context,
      etapa: processo.descricao,
      valorAtual: processo.valorComissao ?? 0,
    );

    if (novoValor != null) {
      controller.alterarValorEtapa(processo, novoValor);
    }
  }

  Widget cartaoProducao() {
    return Consumer<NewOperationPageProvider>(
      builder: (context, controller, child) {
        final modelo = controller.modelo;

        return cartao([
          titulo('PRODUÇÃO'),
          rotulo('NÚMERO DO PEDIDO'),
          TextField(
            controller: numeroController,
            onChanged: controller.setNumero,
            decoration: decoracao('Ex.: 4521', icone: Icons.tag),
          ),
          rotulo('VALOR DA PEÇA (R\$)'),
          TextField(
            controller: valorPeca,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (valor) => controller.setValorPeca(lerValor(valor)),
            decoration: decoracao('0,00', icone: Icons.attach_money),
          ),
          rotulo('QUANTIDADE SOLICITADA'),
          TextField(
            controller: quantidade,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (valor) =>
                controller.setQuantidadeSolicitada(int.tryParse(valor)),
            decoration: decoracao(
              'Ex.: 1000',
              icone: Icons.inventory_2_outlined,
            ),
          ),
          rotulo('MODELO'),
          campoSelecao(
            icone: Icons.checkroom_outlined,
            texto: modelo?.nome,
            vazio: 'Selecione o modelo',
            aoTocar: () => escolherModelo(context),
          ),
          if (modelo == null)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Ao escolher o modelo, as etapas aparecem aqui.',
                style: TextStyle(color: cinza, fontSize: 13),
              ),
            )
          else ...[
            rotulo('ETAPAS'),
            for (final processo in controller.processos) itemProcesso(processo),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => AdicionarEtapaSheet.abrir(
                    context,
                    descricoesExistentes: controller.processos
                        .map((processo) => processo.descricao)
                        .toList(),
                    aoConfirmar: controller.adicionarEtapaAoPedido,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar etapa'),
                ),
              ),
            ),
          ],
        ]);
      },
    );
  }

  Widget campoSelecao({
    required IconData icone,
    required String? texto,
    required String vazio,
    required VoidCallback aoTocar,
    String? detalhe,
  }) {
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borda),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icone, size: 18, color: cinza),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    texto ?? vazio,
                    style: TextStyle(
                      fontWeight: texto == null
                          ? FontWeight.w400
                          : FontWeight.w600,
                      color: texto == null
                          ? const Color(0xFFB0B0B8)
                          : Colors.black,
                    ),
                  ),
                  if (detalhe != null)
                    Text(
                      detalhe,
                      style: const TextStyle(fontSize: 12, color: cinza),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: cinza),
          ],
        ),
      ),
    );
  }

  Widget itemProcesso(ProcessoProdutivo processo) {
    return Consumer<NewOperationPageProvider>(
      builder: (context, controller, child) {
        final funcionario = processo.funcionario;

        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: campo,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      processo.descricao,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${formatarMoeda(processo.valorComissao ?? 0)} por peça',
                    style: const TextStyle(
                      color: roxo,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  InkWell(
                    onTap: () => alterarValor(context, processo),
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.edit_outlined, size: 16, color: roxo),
                    ),
                  ),
                  if (controller.ehEtapaExtra(processo))
                    InkWell(
                      onTap: () => controller.removerEtapaExtra(processo),
                      borderRadius: BorderRadius.circular(10),
                      child: const Tooltip(
                        message: 'Remover etapa',
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.close, size: 16, color: Colors.red),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => escolherResponsavel(context, processo),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: funcionario == null ? roxo : Colors.white,
                    border: funcionario == null
                        ? null
                        : Border.all(color: borda),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 18,
                        color: funcionario == null ? Colors.white : cinza,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          funcionario?.nome ?? 'Selecionar responsável',
                          style: TextStyle(
                            color: funcionario == null
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
