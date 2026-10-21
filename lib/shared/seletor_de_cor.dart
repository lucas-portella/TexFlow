import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:texflow/models/cor.dart';
import 'package:texflow/shared/app_colors.dart';
import 'package:texflow/shared/paleta_de_cores.dart';

class SeletorDeCor extends StatefulWidget {
  final String? hex;
  final ValueChanged<String> aoEscolher;

  const SeletorDeCor({super.key, required this.hex, required this.aoEscolher});

  @override
  State<SeletorDeCor> createState() => _SeletorDeCorState();
}

class _SeletorDeCorState extends State<SeletorDeCor> {
  late HSVColor _hsv = HSVColor.fromColor(
    Cor.corDoHex(widget.hex ?? '#E5252A'),
  );
  late final _hexController = TextEditingController(text: _hexSemCerquilha());
  late String? _ultimoEscolhido = widget.hex;
  bool _personalizando = false;

  String _hexSemCerquilha() => hexDaCor(_hsv.toColor()).substring(1);

  @override
  void didUpdateWidget(SeletorDeCor antigo) {
    super.didUpdateWidget(antigo);
    final novo = widget.hex;
    if (novo != null && novo != _ultimoEscolhido) {
      _ultimoEscolhido = novo;
      _hsv = HSVColor.fromColor(Cor.corDoHex(novo));
      _hexController.text = _hexSemCerquilha();
    }
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _mudouHsv(HSVColor hsv) {
    setState(() => _hsv = hsv);
    _hexController.text = _hexSemCerquilha();
    _ultimoEscolhido = hexDaCor(hsv.toColor());
    widget.aoEscolher(_ultimoEscolhido!);
  }

  void _digitouHex(String texto) {
    if (texto.length != 6) return;
    final hsv = HSVColor.fromColor(Cor.corDoHex(texto));
    setState(() => _hsv = hsv);
    _ultimoEscolhido = '#${texto.toUpperCase()}';
    widget.aoEscolher(_ultimoEscolhido!);
  }

  @override
  Widget build(BuildContext context) {
    final escolhida = widget.hex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        LayoutBuilder(
          builder: (context, restricoes) {
            const espaco = 4.0;
            final lado =
                ((restricoes.maxWidth - espaco * (colunasDaPaleta - 1)) /
                        colunasDaPaleta)
                    .floorToDouble();
            return Wrap(
              spacing: espaco,
              runSpacing: espaco,
              children: [
                for (final hex in paletaDeCores)
                  _Amostra(
                    hex: hex,
                    lado: lado,
                    selecionada: escolhida == hex,
                    aoTocar: () => widget.aoEscolher(hex),
                  ),
              ],
            );
          },
        ),
        InkWell(
          onTap: () => setState(() => _personalizando = !_personalizando),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.colorize_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Criar outra cor',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Icon(
                  _personalizando ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.muted,
                ),
              ],
            ),
          ),
        ),
        if (_personalizando) ...[
          _QuadradoDeTom(hsv: _hsv, aoMudar: _mudouHsv),
          _FaixaDeMatiz(hsv: _hsv, aoMudar: _mudouHsv),
          Row(
            spacing: 12,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _hsv.toColor(),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black26),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _hexController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
                    LengthLimitingTextInputFormatter(6),
                    TextInputFormatter.withFunction(
                      (antigo, novo) =>
                          novo.copyWith(text: novo.text.toUpperCase()),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Código da cor',
                    prefixText: '#',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: _digitouHex,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Amostra extends StatelessWidget {
  final String hex;
  final double lado;
  final bool selecionada;
  final VoidCallback aoTocar;

  const _Amostra({
    required this.hex,
    required this.lado,
    required this.selecionada,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = Cor.corDoHex(hex);
    final claro = cor.computeLuminance() > 0.6;

    return Tooltip(
      message: hex,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: lado,
          height: lado,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selecionada ? AppColors.primary : Colors.black26,
              width: selecionada ? 3 : 1,
            ),
          ),
          child: selecionada
              ? Icon(
                  Icons.check,
                  size: lado * 0.6,
                  color: claro ? Colors.black87 : Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}

class _QuadradoDeTom extends StatelessWidget {
  final HSVColor hsv;
  final ValueChanged<HSVColor> aoMudar;

  const _QuadradoDeTom({required this.hsv, required this.aoMudar});

  void _tocar(Offset posicao, Size tamanho) {
    final saturacao = (posicao.dx / tamanho.width).clamp(0.0, 1.0);
    final valor = 1 - (posicao.dy / tamanho.height).clamp(0.0, 1.0);
    aoMudar(hsv.withSaturation(saturacao).withValue(valor));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricoes) {
        final tamanho = Size(restricoes.maxWidth, 180);
        final x = hsv.saturation * tamanho.width;
        final y = (1 - hsv.value) * tamanho.height;

        return GestureDetector(
          key: const ValueKey('quadrado-de-tons'),
          onPanDown: (d) => _tocar(d.localPosition, tamanho),
          onPanUpdate: (d) => _tocar(d.localPosition, tamanho),
          child: SizedBox.fromSize(
            size: tamanho,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor(),
                          ],
                        ),
                      ),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: x - 11,
                  top: y - 11,
                  child: IgnorePointer(
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 3),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FaixaDeMatiz extends StatelessWidget {
  final HSVColor hsv;
  final ValueChanged<HSVColor> aoMudar;

  const _FaixaDeMatiz({required this.hsv, required this.aoMudar});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              gradient: LinearGradient(
                colors: [
                  for (var grau = 0; grau <= 360; grau += 60)
                    HSVColor.fromAHSV(1, grau.toDouble(), 1, 1).toColor(),
                ],
              ),
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 14,
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbColor: Colors.white,
              overlayColor: Colors.black12,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 12,
                elevation: 3,
              ),
            ),
            child: Slider(
              min: 0,
              max: 360,
              value: hsv.hue,
              onChanged: (matiz) => aoMudar(hsv.withHue(matiz)),
            ),
          ),
        ],
      ),
    );
  }
}
