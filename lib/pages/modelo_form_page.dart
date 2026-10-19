import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:texflow/models/etapa.dart';
import 'package:texflow/models/referencia.dart';
import 'package:texflow/providers/etapa_provider.dart';
import 'package:texflow/providers/modelo_provider.dart';
import 'package:texflow/routes/app_routes.dart';
import 'package:texflow/shared/etapa_form_sheet.dart';
import 'package:texflow/shared/app_card.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/app_primary_button.dart';
import 'package:texflow/shared/app_text_field.dart';
import 'package:texflow/shared/application_app_bar.dart';
import 'package:texflow/shared/formatters.dart';
import 'package:texflow/shared/section_title.dart';
import 'package:texflow/shared/validators.dart';

class ModeloFormPage extends StatefulWidget {
  final Referencia? modelo;

  const ModeloFormPage({super.key, this.modelo});

  static const route = AppRoutes.modeloForm;

  @override
  State<ModeloFormPage> createState() => _ModeloFormPageState();
}

class _ModeloFormPageState extends State<ModeloFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nomeController = TextEditingController(text: widget.modelo?.nome);
  late final List<Etapa> _etapas = List.of(widget.modelo?.etapas ?? []);
  late bool _ativo = widget.modelo?.ativo ?? true;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EtapaProvider>().carregar();
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _escolherEtapa() async {
    final disponiveis = context
        .read<EtapaProvider>()
        .etapas
        .where((etapa) => !_etapas.any((escolhida) => escolhida.id == etapa.id))
        .toList();

    var cadastrarEtapa = false;

    final escolhida = await showModalBottomSheet<Etapa>(
      context: context,
      builder: (context) {
        void pedirCadastro() {
          cadastrarEtapa = true;
          Navigator.pop(context);
        }

        if (disponiveis.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Não há etapas cadastradas.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: pedirCadastro,
                  child: const Text('Cadastrar etapa'),
                ),
              ],
            ),
          );
        }

        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            for (final etapa in disponiveis)
              ListTile(
                title: Text(etapa.nome),
                trailing: Text(formatarMoeda(etapa.valorComissao)),
                onTap: () => Navigator.pop(context, etapa),
              ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Cadastrar etapa'),
              onTap: pedirCadastro,
            ),
          ],
        );
      },
    );

    if (escolhida != null) {
      setState(() => _etapas.add(escolhida));
      return;
    }

    if (!cadastrarEtapa || !mounted) return;
    final etapas = context.read<EtapaProvider>();
    await EtapaFormSheet.abrir(context);
    await etapas.carregar();
    if (mounted) await _escolherEtapa();
  }

  void _reordenar(int antigo, int novo) {
    setState(() {
      _etapas.insert(novo, _etapas.removeAt(antigo));
    });
  }

  Future<void> _salvar() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<ModeloProvider>();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      await provider.salvar(
        id: widget.modelo?.id,
        nome: _nomeController.text.trim(),
        etapaIds: _etapas.map((etapa) => etapa.id).toList(),
        ativo: _ativo,
      );
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: ApplicationAppBar(
        title: widget.modelo == null ? 'Novo modelo' : 'Editar modelo',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                children: [
                  AppTextField(
                    label: 'NOME DO MODELO',
                    hintText: 'Ex.: Blusa',
                    prefixIcon: Icons.checkroom_outlined,
                    controller: _nomeController,
                    validator: (valor) =>
                        validarObrigatorio(valor, 'Informe o nome do modelo'),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Ativo'),
                      subtitle: const Text(
                        'Modelos inativos não aparecem ao criar uma produção.',
                      ),
                      value: _ativo,
                      onChanged: (valor) => setState(() => _ativo = valor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionTitle(texto: 'ETAPAS DO MODELO'),
                TextButton.icon(
                  onPressed: _escolherEtapa,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar etapa'),
                ),
              ],
            ),
            if (_etapas.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Nenhuma etapa escolhida (opcional)',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              )
            else
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                onReorderItem: _reordenar,
                children: [
                  for (var i = 0; i < _etapas.length; i++)
                    Padding(
                      key: ValueKey(_etapas[i].id),
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${i + 1}. ${_etapas[i].nome}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${formatarMoeda(_etapas[i].valorComissao)} por peça',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remover',
                              onPressed: () =>
                                  setState(() => _etapas.removeAt(i)),
                              icon: const Icon(
                                Icons.close,
                                size: 20,
                                color: AppColors.danger,
                              ),
                            ),
                            ReorderableDragStartListener(
                              index: i,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.drag_handle,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: 'Salvar modelo',
              carregando: _carregando,
              onPressed: _salvar,
            ),
          ],
        ),
      ),
    );
  }
}
