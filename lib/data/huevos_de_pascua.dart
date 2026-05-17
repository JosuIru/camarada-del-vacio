import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../theme.dart';
import '../utilities/audio_procedural.dart';
import '../widgets/notificacion_insignia.dart';
import '../widgets/overlay_celebracion.dart';

/// Cómo de espectacular es la reacción del escenario al descubrir el huevo.
enum NivelCelebracionHuevo {
  /// Solo notificación de insignia + frase en la crónica. Default.
  discreto,

  /// Notificación + sello rojo flotante grande con el rótulo `selloRojo`.
  selloRojo,

  /// Overlay de celebración a pantalla completa (medalla + confetti rojo).
  cinematografico,
}

/// Catálogo declarativo de huevos de pascua: cuando el cadete descubre uno,
/// el motor del escenario invoca [desencadenarHuevoPascua] con su id y se
/// dispara la cadena unificada (insignia + frase + regalo opcional + visual).
class HuevoPascuaInfo {
  /// Identificador del flag de la insignia secreta asociada. Si está vacío,
  /// no se otorga insignia (solo eventos visuales).
  final String idFlagInsignia;

  /// Etiqueta corta de la escena donde vive el huevo. Sirve para depuración
  /// y para que el diario pueda agruparlos en una futura pestaña.
  final String idEscena;

  /// Línea que se añade a la crónica de la sala. Si el escenario no tiene
  /// log, se ignora silenciosamente.
  final String fraseCronica;

  /// Identificador del objeto del inventario que se regala. `null` = sin
  /// regalo material.
  final String? idObjetoRegalo;

  /// Bonus a la cuota burocrática. `0` = sin cambio.
  final int deltaCuota;

  /// Flag de historia adicional que se activa (además del flag de insignia).
  /// Útil para conectar el huevo con el sistema de misiones.
  final String? flagHistoriaAdicional;

  /// Texto corto pintado dentro del sello rojo (solo si nivel = selloRojo o
  /// cinematografico).
  final String? selloRojo;

  /// Subtítulo de la celebración cinematográfica.
  final String? subtituloCelebracion;

  /// Cómo de espectacular es la reacción del escenario.
  final NivelCelebracionHuevo nivel;

  /// Ruta opcional al PNG del sello temático del huevo (sello_archivo,
  /// sello_inspector, sello_f447, etc.). Si está definido, se usa como
  /// fondo del sello flotante; si no, fallback al sello oficial genérico.
  final String? rutaSelloPng;

  const HuevoPascuaInfo({
    required this.idFlagInsignia,
    required this.idEscena,
    required this.fraseCronica,
    this.idObjetoRegalo,
    this.deltaCuota = 0,
    this.flagHistoriaAdicional,
    this.selloRojo,
    this.subtituloCelebracion,
    this.nivel = NivelCelebracionHuevo.discreto,
    this.rutaSelloPng,
  });
}

/// Catálogo cerrado de huevos de pascua del prototipo. Añadir nuevos sólo
/// requiere insertarlos aquí + activar el helper desde el escenario.
final Map<String, HuevoPascuaInfo> catalogoHuevosPascua = {
  'pacto_bajo_la_mesa': const HuevoPascuaInfo(
    idFlagInsignia: 'insignia_pacto_bajo_la_mesa',
    idEscena: 'cantina',
    fraseCronica:
        '★ Bajo la mesa de Ostrog cede una placa. Una jarra de hojalata se '
        'desploma. Dentro, una nota arrugada: «K. exige cerrar el caso del '
        'cocinero antes del miércoles». Firmada con una sola K.',
    idObjetoRegalo: 'nota_krilov_cocinero',
    flagHistoriaAdicional: 'pista_krilov_cocinero',
    selloRojo: '★ K. NO CONSTA ★',
    nivel: NivelCelebracionHuevo.selloRojo,
    rutaSelloPng: 'assets/svg/sello_inspector.png',
  ),
  'archivero_krilov': const HuevoPascuaInfo(
    idFlagInsignia: 'insignia_archivero_krilov',
    idEscena: 'cantina',
    fraseCronica:
        '★ Empujas el cajón del fregadero. Debajo, un sello de cera con la '
        'letra «К» y el código «7-Б». No figura en el organigrama de la '
        'Pravda-12.',
    idObjetoRegalo: 'sello_cera_krilov',
    flagHistoriaAdicional: 'pista_krilov_cocinero',
    rutaSelloPng: 'assets/svg/sello_no_leer.png',
  ),
  'grafiti_pravda7': const HuevoPascuaInfo(
    idFlagInsignia: 'insignia_grafiti_pravda7',
    idEscena: 'reactor',
    fraseCronica:
        '★ La tubería oxidada cede al impacto. Detrás, pintado a brocha gorda '
        'con tinta roja: «PRAVDA-7 NO MURIÓ». Una flecha apunta hacia el '
        'sello del Comisariado.',
    flagHistoriaAdicional: 'pista_pravda7_inicial',
    selloRojo: '★ NO MURIÓ ★',
    nivel: NivelCelebracionHuevo.selloRojo,
    rutaSelloPng: 'assets/svg/sello_prohibido.png',
  ),
  'quincalla_vostrikova': const HuevoPascuaInfo(
    idFlagInsignia: 'insignia_quincalla_vostrikova',
    idEscena: 'reactor',
    fraseCronica:
        '★ STRIKE. Cinco conos de mantenimiento ruedan en abanico. La '
        'Ingeniera Vostrikova levanta una ceja, anota algo en su diario de '
        'campo, y te lanza un rollo extra de cinta adhesiva.',
    idObjetoRegalo: 'cinta_adhesiva_extra',
    rutaSelloPng: 'assets/svg/sello_archivo.png',
  ),
  'urna_desplazada': const HuevoPascuaInfo(
    idFlagInsignia: 'insignia_urna_descubierta',
    idEscena: 'zovnak4',
    fraseCronica:
        '★ Empujas la urna nº 47 fuera de su rectángulo oficial. Bajo el '
        'fondo de la urna, un fajo de papeletas con la letra K tachadas con '
        'savia marciana. La asamblea finge no haberlo visto.',
    idObjetoRegalo: 'papeletas_k_zovnak',
    flagHistoriaAdicional: 'pista_krilov_zovnak',
    rutaSelloPng: 'assets/svg/sello_urgente.png',
  ),
  'pinguino_burocratico': const HuevoPascuaInfo(
    idFlagInsignia: 'insignia_pinguino_burocratico',
    idEscena: 'gelida9',
    fraseCronica:
        '★ El muro de F-447 congelados se astilla con tu impacto. Tras el '
        'agujero, un pingüino oficial estampa tu visado en seco y se '
        'esfuma sin protocolo.',
    idObjetoRegalo: 'visado_pinguino',
    deltaCuota: -1,
    selloRojo: '★ VISADO PINGÜINO ★',
    nivel: NivelCelebracionHuevo.selloRojo,
    rutaSelloPng: 'assets/svg/sello_visado.png',
  ),
  'huelga_silenciosa': const HuevoPascuaInfo(
    idFlagInsignia: 'insignia_huelga_silenciosa',
    idEscena: 'sol_camarada',
    fraseCronica:
        '★ La cristalera sindical estalla en mil esquirlas dóciles. El '
        'Delegado aplaude tres veces y te susurra: «el sindicato tiene '
        'memoria, pero no constancia». Se abre un atajo a la sala de actas.',
    flagHistoriaAdicional: 'sindicato_atajo_abierto',
    rutaSelloPng: 'assets/svg/sello_comite.png',
  ),
  'susurro_petrov': const HuevoPascuaInfo(
    idFlagInsignia: 'insignia_susurro_petrov',
    idEscena: 'pravda7',
    fraseCronica:
        '★ Con la masa exacta de la bola, el panel central de la Pravda-7 '
        'cede. Una voz tachada dos veces susurra: «Petrov 58 sigue arriba». '
        'La pantalla parpadea con coordenadas que no constan.',
    flagHistoriaAdicional: 'susurro_petrov_oido',
    selloRojo: '★ PETROV 58 ★',
    nivel: NivelCelebracionHuevo.cinematografico,
    subtituloCelebracion:
        'La Pravda-7 te ha hablado.\nEl archivo lo registrará como ruido.',
    rutaSelloPng: 'assets/svg/sello_pravda.png',
  ),
  'estrella_pulsada_siete': const HuevoPascuaInfo(
    idFlagInsignia: 'insignia_estrella_pulsada_siete',
    idEscena: 'titulo',
    fraseCronica: '',
    selloRojo: '★ EXPEDIENTE SIN FILTRO ★',
    nivel: NivelCelebracionHuevo.cinematografico,
    subtituloCelebracion:
        'La estrella ha sido pulsada siete veces.\nSe abre el Expediente Sin Filtro.',
    rutaSelloPng: 'assets/svg/sello_f447.png',
  ),
};

/// Helper canónico: dispara un huevo de pascua de manera idempotente. Si la
/// insignia ya está desbloqueada, no hace nada (evita re-disparos).
///
/// - `registroEscenario` recibe la línea para la crónica de la sala (puede
///   ser null si el escenario no tiene log visible).
/// - `claseCelebracion` se usa para colorear la medalla en el overlay
///   cinematográfico. Si es null, se omite la celebración grande.
void desencadenarHuevoPascua(
  BuildContext context, {
  required EstadoJuego estado,
  required String idHuevo,
  void Function(String fraseCronica)? registroEscenario,
  dynamic claseCelebracion,
}) {
  final huevo = catalogoHuevosPascua[idHuevo];
  if (huevo == null) return;
  if (huevo.idFlagInsignia.isNotEmpty &&
      estado.tieneFlag(huevo.idFlagInsignia)) {
    return;
  }

  if (huevo.idFlagInsignia.isNotEmpty) {
    desbloquearInsigniaSiNueva(
      context,
      estado: estado,
      identificadorFlag: huevo.idFlagInsignia,
    );
  }
  if (huevo.flagHistoriaAdicional != null) {
    estado.activarFlag(huevo.flagHistoriaAdicional!);
  }
  if (huevo.idObjetoRegalo != null) {
    estado.anadirObjeto(huevo.idObjetoRegalo!);
  }
  if (huevo.deltaCuota != 0) {
    estado.modificarCuota(huevo.deltaCuota);
  }
  if (huevo.fraseCronica.isNotEmpty) {
    registroEscenario?.call(huevo.fraseCronica);
  }

  if (huevo.nivel == NivelCelebracionHuevo.selloRojo &&
      huevo.selloRojo != null) {
    _mostrarSelloRojoFlotante(
      context,
      texto: huevo.selloRojo!,
      rutaSelloPng: huevo.rutaSelloPng,
    );
  } else if (huevo.nivel == NivelCelebracionHuevo.cinematografico) {
    audioProcedural.reproducirSubidaDeNivel();
    if (claseCelebracion != null) {
      mostrarCelebracion(
        context,
        texto: huevo.selloRojo ?? '★ HUEVO DE PASCUA ★',
        subtitulo:
            huevo.subtituloCelebracion ?? 'El archivo no lo registrará.',
        clase: claseCelebracion,
        duracion: const Duration(milliseconds: 2400),
      );
    }
  }
}

/// Sello rojo flotante: aparece centrado, escala 2.6 → 1.2 con rebote, se
/// desvanece tras 1.8 s. No requiere Scaffold ni Overlay especial: usa
/// `Overlay.of(context)` como las notificaciones de insignia.
void _mostrarSelloRojoFlotante(
  BuildContext context, {
  required String texto,
  String? rutaSelloPng,
}) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;
  late OverlayEntry entrada;
  entrada = OverlayEntry(
    builder: (_) => _SelloRojoFlotante(
      texto: texto,
      rutaSelloPng: rutaSelloPng,
      alTerminar: () {
        if (entrada.mounted) entrada.remove();
      },
    ),
  );
  overlay.insert(entrada);
}

class _SelloRojoFlotante extends StatefulWidget {
  final String texto;
  final String? rutaSelloPng;
  final VoidCallback alTerminar;

  const _SelloRojoFlotante({
    required this.texto,
    required this.alTerminar,
    this.rutaSelloPng,
  });

  @override
  State<_SelloRojoFlotante> createState() => _SelloRojoFlotanteState();
}

class _SelloRojoFlotanteState extends State<_SelloRojoFlotante>
    with SingleTickerProviderStateMixin {
  late final AnimationController controladorEstampado;

  @override
  void initState() {
    super.initState();
    controladorEstampado = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    controladorEstampado.forward();
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) widget.alTerminar();
    });
  }

  @override
  void dispose() {
    controladorEstampado.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: AnimatedBuilder(
            animation: controladorEstampado,
            builder: (contexto, hijo) {
              final double fase = controladorEstampado.value;
              double escala;
              double opacidad;
              if (fase < 0.18) {
                final t = fase / 0.18;
                escala = 2.6 - t * 1.4;
                opacidad = t.clamp(0.0, 1.0);
              } else if (fase < 0.72) {
                final t = (fase - 0.18) / 0.54;
                escala = 1.2 + (1 - t) * 0.1;
                opacidad = 1.0;
              } else {
                final t = (fase - 0.72) / 0.28;
                escala = 1.2 - t * 0.12;
                opacidad = 1.0 - t;
              }
              final double anguloVibracion =
                  (fase < 0.4) ? (0.18 - fase * 0.4) : -0.05;
              return Opacity(
                opacity: opacidad.clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: anguloVibracion,
                  child: Transform.scale(
                    scale: escala,
                    child: hijo,
                  ),
                ),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Fondo del sello flotante. Si el huevo trae sello PNG
                // temático (sello_inspector, sello_prohibido, etc.) lo
                // usa; si no, fallback al sello oficial genérico.
                SizedBox(
                  width: 320,
                  height: 320,
                  child: Image.asset(
                    widget.rutaSelloPng ??
                        'assets/svg/sello_oficial_gigante.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                // Texto del huevo superpuesto en el centro del sello,
                // ligeramente desplazado para que no tape el aro.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56),
                  child: Text(
                    widget.texto,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'CosmoSerif',
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: PaletaCosmoSovietica.rojoOficial,
                      letterSpacing: 2,
                      height: 1.05,
                    ),
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
