import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/equipment.dart';
import '../models/game_class.dart';
import '../models/game_state.dart';
import '../painters/stick_figure_painter.dart';
import '../theme.dart';
import 'breathing_stick_figure.dart';
import 'propaganda_button.dart';

Future<void> mostrarDialogoInventario(
  BuildContext contextoLlamante, {
  required EstadoJuego estado,
}) {
  return showDialog<void>(
    context: contextoLlamante,
    builder: (_) => DialogoInventario(estado: estado),
  );
}

class DialogoInventario extends StatefulWidget {
  final EstadoJuego estado;

  const DialogoInventario({super.key, required this.estado});

  @override
  State<DialogoInventario> createState() => _DialogoInventarioState();
}

class _DialogoInventarioState extends State<DialogoInventario> {
  SlotEquipo slotSeleccionado = SlotEquipo.cabeza;
  String? identificadorEquipoEnFoco;

  int _indiceSlot(SlotEquipo slot) {
    switch (slot) {
      case SlotEquipo.cabeza:
        return 0;
      case SlotEquipo.arma:
        return 1;
      case SlotEquipo.torso:
        return 2;
    }
  }

  String _etiquetaSlot(SlotEquipo slot) {
    switch (slot) {
      case SlotEquipo.cabeza:
        return 'CABEZA';
      case SlotEquipo.arma:
        return 'ARMA';
      case SlotEquipo.torso:
        return 'TORSO';
    }
  }

  List<String> _objetosPoseidosEnSlot(SlotEquipo slot) {
    final identificadoresPoseidos = <String>[];
    for (final entrada in widget.estado.inventario.entries) {
      final equipoCandidato = catalogoEquipo[entrada.key];
      if (equipoCandidato == null) continue;
      if (equipoCandidato.slot != slot) continue;
      identificadoresPoseidos.add(entrada.key);
    }
    return identificadoresPoseidos;
  }

  Map<String, int> _objetosNarrativos() {
    final restoObjetos = <String, int>{};
    for (final entrada in widget.estado.inventario.entries) {
      if (catalogoEquipo.containsKey(entrada.key)) continue;
      restoObjetos[entrada.key] = entrada.value;
    }
    return restoObjetos;
  }

  void _equipar(String identificadorEquipo) {
    final equipo = catalogoEquipo[identificadorEquipo];
    if (equipo == null) return;
    setState(() {
      widget.estado.equiparEnSlot(
          _indiceSlot(equipo.slot), identificadorEquipo);
      identificadorEquipoEnFoco = identificadorEquipo;
    });
  }

  void _desequiparSlotActual() {
    setState(() {
      widget.estado.equiparEnSlot(_indiceSlot(slotSeleccionado), null);
      identificadorEquipoEnFoco = null;
    });
  }

  String _traducirObjeto(String idObjeto) {
    switch (idObjeto) {
      case 'caja_sin_etiquetar':
        return 'Caja sin etiquetar (oculta)';
      default:
        return idObjeto;
    }
  }

  @override
  Widget build(BuildContext context) {
    final objetosEnSlot = _objetosPoseidosEnSlot(slotSeleccionado);
    final identificadorEquipadoEnSlot = widget.estado
        .identificadorEquipoEnSlot(_indiceSlot(slotSeleccionado));
    final identificadorEnfoque =
        identificadorEquipoEnFoco ?? identificadorEquipadoEnSlot;
    final equipoEnfoque = identificadorEnfoque != null
        ? catalogoEquipo[identificadorEnfoque]
        : null;
    final objetosNarrativos = _objetosNarrativos();

    return Dialog(
      backgroundColor: PaletaCosmoSovietica.papelViejo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(
          color: PaletaCosmoSovietica.tintaNegra,
          width: 3,
        ),
      ),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 820, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'EXPEDIENTE PERSONAL · CADETE',
                    style: TipografiaPropaganda.etiquetaBurocratica,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      'CERRAR ✕',
                      style: TipografiaPropaganda.etiquetaBurocratica,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(
                color: PaletaCosmoSovietica.rojoOficial,
                thickness: 1.5,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final slot in SlotEquipo.values) ...[
                    _construirPestanaSlot(slot),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _construirRetratoCadete(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: _construirListaEquipo(
                        objetosEnSlot,
                        identificadorEquipadoEnSlot,
                        objetosNarrativos,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: _construirPanelDetalle(equipoEnfoque),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirPestanaSlot(SlotEquipo slot) {
    final estaSeleccionada = slot == slotSeleccionado;
    final identificadorEquipadoEnPestana =
        widget.estado.identificadorEquipoEnSlot(_indiceSlot(slot));
    final colorContenido = estaSeleccionada
        ? PaletaCosmoSovietica.papelViejo
        : PaletaCosmoSovietica.tintaNegra;
    return GestureDetector(
      onTap: () => setState(() {
        slotSeleccionado = slot;
        identificadorEquipoEnFoco = null;
      }),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: estaSeleccionada
                ? PaletaCosmoSovietica.tintaNegra
                : PaletaCosmoSovietica.papelViejo,
            border: Border.all(
              color: PaletaCosmoSovietica.tintaNegra,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CustomPaint(
                  painter: _PintorIconoSlot(
                    slot: slot,
                    color: colorContenido,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _etiquetaSlot(slot),
                style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
                  color: colorContenido,
                ),
              ),
              if (identificadorEquipadoEnPestana != null) ...[
                const SizedBox(width: 5),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: PaletaCosmoSovietica.rojoOficial,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirRetratoCadete() {
    final equipoCabezaActual =
        catalogoEquipo[widget.estado.idObjetoCabezaEquipado];
    final equipoArmaActual =
        catalogoEquipo[widget.estado.idObjetoArmaEquipada];
    final equipoTorsoActual =
        catalogoEquipo[widget.estado.idObjetoTorsoEquipado];
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.papelSombra,
        border:
            Border.all(color: PaletaCosmoSovietica.tintaNegra, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.estado.personaje.clase?.etiquetaCorta.toUpperCase() ?? 'CADETE',
            style: TipografiaPropaganda.etiquetaBurocratica,
          ),
          const SizedBox(height: 4),
          Text(
            'NIVEL ${widget.estado.nivelCadete}',
            style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
              color: PaletaCosmoSovietica.rojoOficial,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Center(
              child: StickFigureViviente(
                clase: widget.estado.personaje.clase,
                pose: PoseStickFigure.saludoMilitar,
                idSombreroEquipado: widget.estado.idObjetoCabezaEquipado,
                idArmaEquipada: widget.estado.idObjetoArmaEquipada,
                idTorsoEquipado: widget.estado.idObjetoTorsoEquipado,
              ),
            ),
          ),
          const SizedBox(height: 6),
          _filaSlotResumen('CABEZA', equipoCabezaActual?.nombre),
          _filaSlotResumen('ARMA', equipoArmaActual?.nombre),
          _filaSlotResumen('TORSO', equipoTorsoActual?.nombre),
        ],
      ),
    );
  }

  Widget _filaSlotResumen(String etiqueta, String? nombreEquipo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(etiqueta,
                style: TipografiaPropaganda.etiquetaBurocratica),
          ),
          Expanded(
            child: Text(
              nombreEquipo ?? '— libre —',
              overflow: TextOverflow.ellipsis,
              style: TipografiaPropaganda.cuerpoLargo
                  .copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirListaEquipo(
    List<String> objetosEnSlot,
    String? identificadorEquipadoEnSlot,
    Map<String, int> objetosNarrativos,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.papelViejo,
        border:
            Border.all(color: PaletaCosmoSovietica.tintaNegra, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SLOT · ${_etiquetaSlot(slotSeleccionado)}',
            style: TipografiaPropaganda.etiquetaBurocratica,
          ),
          const SizedBox(height: 6),
          if (objetosEnSlot.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Nada disponible en este slot todavía.',
                style: TipografiaPropaganda.cuerpoLargo.copyWith(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: objetosEnSlot.length,
                separatorBuilder: (c, i) => const SizedBox(height: 4),
                itemBuilder: (c, i) {
                  final identificadorObjeto = objetosEnSlot[i];
                  final equipoEnSlot =
                      catalogoEquipo[identificadorObjeto]!;
                  final estaEquipado =
                      identificadorEquipadoEnSlot == identificadorObjeto;
                  final estaEnfocado =
                      identificadorEquipoEnFoco == identificadorObjeto;
                  return GestureDetector(
                    onTap: () => setState(() =>
                        identificadorEquipoEnFoco = identificadorObjeto),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: estaEnfocado
                              ? PaletaCosmoSovietica.papelSombra
                              : PaletaCosmoSovietica.papelViejo,
                          border: Border.all(
                            color: estaEquipado
                                ? PaletaCosmoSovietica.rojoOficial
                                : PaletaCosmoSovietica.tintaNegra,
                            width: estaEquipado ? 2.5 : 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    equipoEnSlot.nombre,
                                    style: TipografiaPropaganda
                                        .etiquetaBurocratica,
                                  ),
                                  Text(
                                    equipoEnSlot.descripcion,
                                    style: TipografiaPropaganda.cuerpoLargo
                                        .copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            if (estaEquipado)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                color: PaletaCosmoSovietica.rojoOficial,
                                child: const Text(
                                  'EN USO',
                                  style: TextStyle(
                                    fontFamily: TipografiaPropaganda
                                        .familiaMonoespaciada,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        PaletaCosmoSovietica.papelViejo,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (objetosNarrativos.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(
                color: PaletaCosmoSovietica.tintaNegra, height: 1),
            const SizedBox(height: 6),
            const Text('OBJETOS DE EXPEDIENTE',
                style: TipografiaPropaganda.etiquetaBurocratica),
            const SizedBox(height: 4),
            for (final entrada in objetosNarrativos.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '· ${_traducirObjeto(entrada.key)}${entrada.value > 1 ? ' × ${entrada.value}' : ''}',
                  style: TipografiaPropaganda.textoLog
                      .copyWith(fontSize: 11),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _construirPanelDetalle(ObjetoEquipable? equipoEnfoque) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.papelViejo,
        border:
            Border.all(color: PaletaCosmoSovietica.tintaNegra, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DETALLE',
              style: TipografiaPropaganda.etiquetaBurocratica),
          const SizedBox(height: 6),
          if (equipoEnfoque == null) ...[
            const Text(
              'Seleccione un objeto del slot para revisar bonificaciones.',
              style: TipografiaPropaganda.cuerpoLargo,
            ),
          ] else ...[
            Text(
              equipoEnfoque.nombre,
              style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
                color: PaletaCosmoSovietica.rojoOficial,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              equipoEnfoque.descripcion,
              style:
                  TipografiaPropaganda.cuerpoLargo.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 8),
            _filaBonus('CUERPO', equipoEnfoque.bonusCuerpo),
            _filaBonus('MENTE', equipoEnfoque.bonusMente),
            _filaBonus('CARISMA', equipoEnfoque.bonusCarisma),
            _filaBonus('ARMADURA FÍSICA',
                equipoEnfoque.bonusArmaduraFisica),
            _filaBonus('CONVICCIÓN', equipoEnfoque.bonusConviccion),
            _filaBonus('PA INICIAL COMBATE',
                equipoEnfoque.bonusPaInicialCombate),
            const Spacer(),
            Row(
              children: [
                if (widget.estado.identificadorEquipoEnSlot(
                        _indiceSlot(equipoEnfoque.slot)) !=
                    equipoEnfoque.identificador)
                  BotonPropaganda(
                    texto: 'Equipar',
                    compacto: true,
                    destacado: true,
                    onPressed: () => _equipar(equipoEnfoque.identificador),
                  )
                else
                  BotonPropaganda(
                    texto: 'Quitar',
                    compacto: true,
                    onPressed: _desequiparSlotActual,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _filaBonus(String etiquetaBonus, int valor) {
    if (valor == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              etiquetaBonus,
              style: TipografiaPropaganda.etiquetaBurocratica,
            ),
          ),
          Text(
            valor > 0 ? '+$valor' : '$valor',
            style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
              color: PaletaCosmoSovietica.rojoOficial,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _PintorIconoSlot extends CustomPainter {
  final SlotEquipo slot;
  final Color color;

  _PintorIconoSlot({required this.slot, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final pincelTrazo = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final pincelRelleno = Paint()..color = color;

    switch (slot) {
      case SlotEquipo.cabeza:
        // Gorra con visera
        final rectVisera = Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.72),
          width: size.width * 0.85,
          height: size.height * 0.14,
        );
        canvas.drawRect(rectVisera, pincelRelleno);
        final rectGorra = Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.5),
          width: size.width * 0.7,
          height: size.height * 0.32,
        );
        canvas.drawRect(rectGorra, pincelRelleno);
        _pintarEstrellita(
          canvas,
          Offset(size.width / 2, size.height * 0.5),
          size.width * 0.16,
          Paint()..color = PaletaCosmoSovietica.rojoOficial,
        );
        break;
      case SlotEquipo.arma:
        // Llave inglesa diagonal
        canvas.save();
        canvas.translate(size.width / 2, size.height / 2);
        canvas.rotate(-math.pi / 5);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: size.width * 0.18,
            height: size.height * 0.7,
          ),
          pincelRelleno,
        );
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(0, -size.height * 0.32),
            width: size.width * 0.45,
            height: size.height * 0.22,
          ),
          pincelRelleno,
        );
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(0, -size.height * 0.32),
            width: size.width * 0.2,
            height: size.height * 0.12,
          ),
          Paint()..color = PaletaCosmoSovietica.papelViejo,
        );
        canvas.restore();
        break;
      case SlotEquipo.torso:
        // Chaleco
        final pathChaleco = Path()
          ..moveTo(size.width * 0.18, size.height * 0.22)
          ..lineTo(size.width * 0.32, size.height * 0.16)
          ..lineTo(size.width * 0.5, size.height * 0.28)
          ..lineTo(size.width * 0.68, size.height * 0.16)
          ..lineTo(size.width * 0.82, size.height * 0.22)
          ..lineTo(size.width * 0.78, size.height * 0.88)
          ..lineTo(size.width * 0.22, size.height * 0.88)
          ..close();
        canvas.drawPath(pathChaleco, pincelRelleno);
        canvas.drawPath(
          pathChaleco,
          pincelTrazo..color = PaletaCosmoSovietica.papelViejo,
        );
        canvas.drawLine(
          Offset(size.width * 0.5, size.height * 0.28),
          Offset(size.width * 0.5, size.height * 0.88),
          Paint()
            ..color = PaletaCosmoSovietica.rojoOficial
            ..strokeWidth = 1.4,
        );
        break;
    }
  }

  void _pintarEstrellita(
      Canvas canvas, Offset centro, double radio, Paint pincel) {
    const puntos = 5;
    final pathEstrella = Path();
    for (int indice = 0; indice < puntos * 2; indice++) {
      final esExterior = indice % 2 == 0;
      final radioActual = esExterior ? radio : radio * 0.45;
      final angulo = -math.pi / 2 + indice * math.pi / puntos;
      final x = centro.dx + math.cos(angulo) * radioActual;
      final y = centro.dy + math.sin(angulo) * radioActual;
      if (indice == 0) {
        pathEstrella.moveTo(x, y);
      } else {
        pathEstrella.lineTo(x, y);
      }
    }
    pathEstrella.close();
    canvas.drawPath(pathEstrella, pincel);
  }

  @override
  bool shouldRepaint(covariant _PintorIconoSlot viejo) =>
      viejo.slot != slot || viejo.color != color;
}
