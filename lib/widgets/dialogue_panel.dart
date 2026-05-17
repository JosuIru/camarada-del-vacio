import 'dart:async';
import 'package:flutter/material.dart';
import '../models/dialogue.dart';
import '../models/game_state.dart';
import '../theme.dart';

typedef CallbackConsecuencia = void Function(String consecuencia);

class PanelDialogo extends StatefulWidget {
  final ConversacionNpc conversacion;
  final EstadoJuego estado;
  final CallbackConsecuencia? onConsecuencia;

  const PanelDialogo({
    super.key,
    required this.conversacion,
    required this.estado,
    this.onConsecuencia,
  });

  @override
  State<PanelDialogo> createState() => _PanelDialogoState();
}

class _LineaConversacion {
  final String textoCompleto;
  final bool esRespuestaJugador;
  int caracteresMostrados;

  _LineaConversacion({
    required this.textoCompleto,
    required this.esRespuestaJugador,
  }) : caracteresMostrados = 0;

  bool get estaCompleta => caracteresMostrados >= textoCompleto.length;
  String get textoVisible =>
      textoCompleto.substring(0, caracteresMostrados);
}

class _PanelDialogoState extends State<PanelDialogo> {
  static const Duration intervaloEntreCaracteres =
      Duration(milliseconds: 24);

  late String idNodoActual;
  final List<_LineaConversacion> registroLineas = [];
  Timer? temporizadorTipeo;

  @override
  void initState() {
    super.initState();
    idNodoActual = widget.conversacion.idNodoInicial;
    final nodo = widget.conversacion.obtenerNodo(idNodoActual);
    _agregarLinea(
      '${nodo.nombreEmisor}: ${nodo.textoEnunciado}',
      esRespuestaJugador: false,
    );
  }

  @override
  void dispose() {
    temporizadorTipeo?.cancel();
    super.dispose();
  }

  void _agregarLinea(String textoCompleto,
      {required bool esRespuestaJugador}) {
    // Si había una línea en tipeo, complétala antes de añadir la nueva.
    if (registroLineas.isNotEmpty && !registroLineas.last.estaCompleta) {
      registroLineas.last.caracteresMostrados =
          registroLineas.last.textoCompleto.length;
    }
    registroLineas.add(_LineaConversacion(
      textoCompleto: textoCompleto,
      esRespuestaJugador: esRespuestaJugador,
    ));
    _reanudarTipeo();
  }

  void _reanudarTipeo() {
    temporizadorTipeo?.cancel();
    if (registroLineas.isEmpty || registroLineas.last.estaCompleta) return;
    temporizadorTipeo =
        Timer.periodic(intervaloEntreCaracteres, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final lineaActual = registroLineas.last;
      if (lineaActual.estaCompleta) {
        timer.cancel();
        return;
      }
      setState(() {
        lineaActual.caracteresMostrados += 1;
      });
    });
  }

  void _saltarTipeoLineaActual() {
    if (registroLineas.isEmpty) return;
    final ultima = registroLineas.last;
    if (ultima.estaCompleta) return;
    temporizadorTipeo?.cancel();
    setState(() {
      ultima.caracteresMostrados = ultima.textoCompleto.length;
    });
  }

  void _seleccionarOpcion(OpcionDialogo opcion) {
    if (opcion.consecuenciaNarrativa != null) {
      widget.onConsecuencia?.call(opcion.consecuenciaNarrativa!);
    }
    setState(() {
      _agregarLinea('Camarada: ${opcion.texto}', esRespuestaJugador: true);
    });
    if (opcion.cierraDialogo || opcion.idNodoDestino == null) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        Navigator.of(context).pop();
      });
      return;
    }
    setState(() {
      idNodoActual = opcion.idNodoDestino!;
      final nodo = widget.conversacion.obtenerNodo(idNodoActual);
      _agregarLinea(
        '${nodo.nombreEmisor}: ${nodo.textoEnunciado}',
        esRespuestaJugador: false,
      );
    });
  }

  String? _motivoBloqueo(OpcionDialogo opcion) {
    return opcion.motivoBloqueoSegunRequisitos(
      cuerpo: widget.estado.personaje.cuerpo,
      mente: widget.estado.personaje.mente,
      carisma: widget.estado.personaje.carisma,
      tieneFlag: widget.estado.tieneFlag,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nodo = widget.conversacion.obtenerNodo(idNodoActual);
    final ultimaLineaEnTipeo =
        registroLineas.isNotEmpty && !registroLineas.last.estaCompleta;
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
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 640),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: ultimaLineaEnTipeo ? _saltarTipeoLineaActual : null,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.conversacion.nombreNpc.toUpperCase(),
                      style: TipografiaPropaganda.tituloSeccion
                          .copyWith(fontSize: 22),
                    ),
                    Text(
                      widget.conversacion.tituloRol,
                      style: TipografiaPropaganda.etiquetaBurocratica,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Divider(
                  color: PaletaCosmoSovietica.rojoOficial,
                  thickness: 1.5,
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int indiceLinea = 0;
                            indiceLinea < registroLineas.length;
                            indiceLinea++)
                          _construirLineaBocadillo(
                              registroLineas[indiceLinea],
                              esUltima:
                                  indiceLinea == registroLineas.length - 1),
                        if (!ultimaLineaEnTipeo && nodo.acotacion != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 12, left: 12),
                            child: Text(
                              '— ${nodo.acotacion!}',
                              style: TipografiaPropaganda.subtitulo
                                  .copyWith(fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(
                  color: PaletaCosmoSovietica.tintaNegra,
                  thickness: 1,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TUS OPCIONES',
                      style: TipografiaPropaganda.etiquetaBurocratica,
                    ),
                    if (ultimaLineaEnTipeo)
                      const Text(
                        '(toca para acelerar)',
                        style: TextStyle(
                          fontFamily:
                              TipografiaPropaganda.familiaMonoespaciada,
                          fontSize: 10,
                          color: PaletaCosmoSovietica.tintaTenue,
                          letterSpacing: 1,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final opcion in nodo.opciones) ...[
                  _BotonOpcion(
                    texto: opcion.texto,
                    destacado: opcion.destacada,
                    motivoBloqueo: _motivoBloqueo(opcion),
                    onPressed: ultimaLineaEnTipeo ||
                            _motivoBloqueo(opcion) != null
                        ? null
                        : () => _seleccionarOpcion(opcion),
                  ),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirLineaBocadillo(_LineaConversacion linea,
      {required bool esUltima}) {
    final mostrarCursor = esUltima && !linea.estaCompleta;
    final textoVisible =
        '${linea.textoVisible}${mostrarCursor ? '▍' : ''}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        textoVisible,
        style: TipografiaPropaganda.bocadilloDialogo.copyWith(
          color: linea.esRespuestaJugador
              ? PaletaCosmoSovietica.rojoOficial
              : PaletaCosmoSovietica.tintaNegra,
        ),
      ),
    );
  }
}

class _BotonOpcion extends StatefulWidget {
  final String texto;
  final bool destacado;
  final String? motivoBloqueo;
  final VoidCallback? onPressed;

  const _BotonOpcion({
    required this.texto,
    required this.destacado,
    required this.motivoBloqueo,
    required this.onPressed,
  });

  @override
  State<_BotonOpcion> createState() => _BotonOpcionState();
}

class _BotonOpcionState extends State<_BotonOpcion> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final habilitada = widget.onPressed != null;
    return MouseRegion(
      cursor: habilitada
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: !habilitada
                ? PaletaCosmoSovietica.papelSombra.withValues(alpha: 0.5)
                : _hover
                    ? PaletaCosmoSovietica.papelSombra
                    : PaletaCosmoSovietica.papelViejo,
            border: Border.all(
              color: !habilitada
                  ? PaletaCosmoSovietica.tintaTenue
                  : widget.destacado
                      ? PaletaCosmoSovietica.rojoOficial
                      : PaletaCosmoSovietica.tintaNegra,
              width: _hover && habilitada ? 2.5 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: !habilitada
                      ? PaletaCosmoSovietica.tintaTenue
                      : widget.destacado
                          ? PaletaCosmoSovietica.rojoOficial
                          : PaletaCosmoSovietica.tintaNegra,
                ),
              ),
              Expanded(
                child: Text(
                  widget.texto,
                  style: TipografiaPropaganda.cuerpoLargo.copyWith(
                    color: habilitada
                        ? PaletaCosmoSovietica.tintaNegra
                        : PaletaCosmoSovietica.tintaTenue,
                  ),
                ),
              ),
              if (widget.motivoBloqueo != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: PaletaCosmoSovietica.tintaTenue,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.motivoBloqueo!.toUpperCase(),
                    style: TipografiaPropaganda.etiquetaBurocratica
                        .copyWith(
                      fontSize: 10,
                      color: PaletaCosmoSovietica.tintaTenue,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> mostrarPanelDialogo(
  BuildContext context, {
  required ConversacionNpc conversacion,
  required EstadoJuego estado,
  CallbackConsecuencia? onConsecuencia,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (contextoDialogo) => PanelDialogo(
      conversacion: conversacion,
      estado: estado,
      onConsecuencia: onConsecuencia,
    ),
  );
}
