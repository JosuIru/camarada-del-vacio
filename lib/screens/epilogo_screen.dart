import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/game_state.dart';
import '../theme.dart';
import '../widgets/paper_background.dart';
import '../widgets/propaganda_button.dart';

enum FinalPrototipo { partido, humanista, combate }

class PantallaEpilogo extends StatefulWidget {
  final EstadoJuego estado;
  final FinalPrototipo finalElegido;

  const PantallaEpilogo({
    super.key,
    required this.estado,
    required this.finalElegido,
  });

  @override
  State<PantallaEpilogo> createState() => _PantallaEpilogoState();
}

class _PantallaEpilogoState extends State<PantallaEpilogo>
    with SingleTickerProviderStateMixin {
  late AnimationController controladorSello;

  @override
  void initState() {
    super.initState();
    controladorSello = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    controladorSello.dispose();
    super.dispose();
  }

  String _tituloFinal() {
    switch (widget.finalElegido) {
      case FinalPrototipo.partido:
        return 'EXPEDIENTE ENTREGADO AL COMITÉ';
      case FinalPrototipo.humanista:
        return 'EXPEDIENTE SELLADO POR EL CADETE';
      case FinalPrototipo.combate:
        return 'EXPEDIENTE EXPULSADO A MARTILLAZOS';
    }
  }

  String _cuerpoFinal() {
    switch (widget.finalElegido) {
      case FinalPrototipo.partido:
        return 'El Inspector Krilov recibe la bitácora con asentimiento mineral. La Pravda-7 figura desde mañana en los manuales como "incidente sin víctimas, debido al uso correcto del formulario F-447 (47 copias)". Los nombres de los dieciséis pasan a "vacantes administrativas". El cadete recibe la Medalla del Trámite Concluido (categoría: bronce inquieto) y un destino de prestigio menor.\n\nEn una mesa congelada del Cuadrante Sigma, tres tazas siguen llenas.';
      case FinalPrototipo.humanista:
        return 'El cadete sella los tres fragmentos de la bitácora en una caja sin etiqueta y la esconde detrás del samovar de Madre Ferruginosa. La Pravda-7 sigue, oficialmente, sin existir; pero deja de gritar.\n\nLa Camarada Vostrikova abre la caja una noche y reconoce su propia letra. Llora reglamentariamente durante dos minutos. Después suelda mejor. Ostrog descubre la trama y, en lugar de reportarla, anota tres frases ilegibles. El Inspector Krilov se reasigna a una boya.\n\nEl cadete pierde la Medalla y gana algo más útil.';
      case FinalPrototipo.combate:
        return 'El Espectro de Directorskov se disuelve en formularios sin nombre. El botón gira en el aire como si dudara, y por primera vez en treinta años duda en serio. Las luces de la Pravda-7 se atenúan. Las tres tazas se enfrían.\n\nGromov se queda. Pide expresamente quedarse. Los otros quince también. La estación se apaga con dignidad de chatarra.\n\nEl cadete vuelve a la Pravda-12 con la respiración corta y la convicción más larga.';
    }
  }

  String _selloFinal() {
    switch (widget.finalElegido) {
      case FinalPrototipo.partido:
        return 'APROBADO POR EL PARTIDO';
      case FinalPrototipo.humanista:
        return 'EXPEDIENTE OMITIDO';
      case FinalPrototipo.combate:
        return 'CASO CERRADO POR FUERZA';
    }
  }

  @override
  Widget build(BuildContext context) {
    final flagsActivos = widget.estado.flagsActivos;
    final lineasExpediente = <String>[];
    if (widget.estado.tieneFlag('combate_archivador_resuelto')) {
      lineasExpediente.add(
        '· Venciste al Funcionario Espectral en la Pravda-12.',
      );
    }
    if (widget.estado.tieneFlag('hablo_con_ostrog')) {
      lineasExpediente.add('· Ostrog te alineó con la cadena de mando.');
    }
    if (widget.estado.tieneFlag('te_de_madre')) {
      lineasExpediente.add('· Aceptaste el té de Madre Ferruginosa.');
    }
    if (widget.estado.companeroFerruginosaActivo) {
      lineasExpediente.add(
        '· Madre Ferruginosa portátil te acompañó en combate.',
      );
    }
    if (widget.estado.tieneFlag('caja_escondida_vela')) {
      lineasExpediente.add('· Escondiste la caja por Vostrikova.');
    }
    if (widget.estado.tieneFlag('caja_entregada_krilov')) {
      lineasExpediente.add('· Entregaste la caja al Inspector Krilov.');
    }
    if (widget.estado.tieneFlag('venciste_cabo')) {
      lineasExpediente.add('· Venciste al Cabo del Cuerpo de Inspección.');
    }
    if (widget.estado.tieneFlag('alcalde_zovnak_aliado')) {
      lineasExpediente.add('· El Alcalde Provisional de Zovnak-4 te respeta.');
    }
    if (widget.estado.tieneFlag('venciste_asamblea_zovnak')) {
      lineasExpediente.add(
        '· Disolviste la asamblea de Zovnak-4 por procedimiento.',
      );
    }
    if (widget.estado.tieneFlag('paso_gelida_concedido')) {
      lineasExpediente.add(
        '· El Comité de Bienvenida de Gélida-9 te concedió el pase.',
      );
    }
    if (widget.estado.tieneFlag('venciste_recepcion_gelida')) {
      lineasExpediente.add('· Reventaste la cola de Gélida-9.');
    }
    if (widget.estado.tieneFlag('solar_acuerdo_aceptado')) {
      lineasExpediente.add('· Firmaste el pliego sindical del Sol Camarada.');
    }
    if (widget.estado.tieneFlag('solar_altavoz_saboteado')) {
      lineasExpediente.add('· Saboteaste el altavoz del Sol Camarada.');
    }
    if (widget.estado.tieneFlag('venciste_delegacion_solar')) {
      lineasExpediente.add('· Reventaste la delegación sindical solar.');
    }
    if (widget.estado.tieneFlag('venciste_espectro_directorskov')) {
      lineasExpediente.add('· Expulsaste al Espectro de Directorskov.');
    }
    if (lineasExpediente.isEmpty) {
      lineasExpediente.add('· No queda constancia administrativa.');
    }

    return Scaffold(
      body: FondoPapelViejo(
        densidadMotas: 320,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'INFORME FINAL DEL PROTOTIPO · ACTO 1',
                        style: TipografiaPropaganda.etiquetaBurocratica,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _tituloFinal(),
                        style: TipografiaPropaganda.tituloEnorme.copyWith(
                          fontSize: 36,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Divider(
                        color: PaletaCosmoSovietica.rojoOficial,
                        thickness: 2,
                      ),
                      const SizedBox(height: 18),
                      // Retrato del Inspector Central: sólo aparece en
                      // el final del Partido, donde el Inspector Krilov
                      // recibe la bitácora. Se carga directamente desde
                      // el SVG mediante `flutter_svg`.
                      if (widget.finalElegido == FinalPrototipo.partido)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: SvgPicture.asset(
                              'assets/svg/inspector_central.svg',
                              width: 180,
                              height: 270,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      Text(
                        _cuerpoFinal(),
                        style: TipografiaPropaganda.cuerpoLargo.copyWith(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'EXPEDIENTE DEL CADETE',
                        style: TipografiaPropaganda.etiquetaBurocratica,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: PaletaCosmoSovietica.papelSombra,
                          border: Border.all(
                            color: PaletaCosmoSovietica.tintaNegra,
                            width: 1.6,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final linea in lineasExpediente)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  linea,
                                  style: TipografiaPropaganda.textoLog.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              'Nivel final: ${widget.estado.nivelCadete} · XP: ${widget.estado.experienciaAcumulada} · Cuota burocrática final: ${widget.estado.cuotaBurocratica >= 0 ? '+' : ''}${widget.estado.cuotaBurocratica}',
                              style: TipografiaPropaganda.etiquetaBurocratica
                                  .copyWith(
                                    color: PaletaCosmoSovietica.rojoOficial,
                                  ),
                            ),
                            Text(
                              'Flags acumuladas: ${flagsActivos.length}',
                              style: TipografiaPropaganda.etiquetaBurocratica,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        '★ FIN DEL PROTOTIPO ACTO 1 ★\nEl Cosmos sigue mirando.',
                        style: TipografiaPropaganda.subtitulo,
                      ),
                      const SizedBox(height: 18),
                      BotonPropaganda(
                        texto: 'Volver al título',
                        destacado: true,
                        onPressed: () =>
                            Navigator.of(context).popUntil((r) => r.isFirst),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: AnimatedBuilder(
                    animation: controladorSello,
                    builder: (contexto, _) {
                      final rotacion =
                          math.sin(controladorSello.value * math.pi * 2) * 0.04;
                      return Transform.rotate(
                        angle: -0.12 + rotacion,
                        child: _SelloFinal(texto: _selloFinal()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelloFinal extends StatelessWidget {
  final String texto;
  const _SelloFinal({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: PaletaCosmoSovietica.rojoOficial, width: 3),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontFamily: TipografiaPropaganda.familiaPrincipal,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: PaletaCosmoSovietica.rojoOficial,
          letterSpacing: 2.4,
        ),
      ),
    );
  }
}
