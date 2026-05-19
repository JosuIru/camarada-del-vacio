/// Catálogo de Sellos F-447 que el cadete puede coleccionar a lo largo
/// de la partida. Cada sello es una pieza de propaganda burocrática que
/// el Comité acuña tras un acto del cadete digno (o ridículo) de quedar
/// archivado.
///
/// Los sellos se modelan como flags del [EstadoJuego]: el id del sello
/// es el propio flag. Para comprobar si el cadete tiene un sello se usa
/// `estado.tieneFlag(sello.id)`.
///
/// El catálogo es la fuente única para:
/// - la pantalla `PantallaArchivoSellos` (vista de colección),
/// - la lógica de cada minijuego cuando otorga sellos,
/// - los NPCs que comentan los sellos del cadete.
library;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Categoría narrativa de un sello. Sirve para agruparlos en la vista
/// de archivo y para el flavor textual (los del Comité son condecorativos,
/// los Antiburocráticos son satíricos, etc.).
enum CategoriaSelloF447 {
  /// Sellos otorgados por completar minijuegos limpiamente.
  meritoTramitador,

  /// Sellos satíricos otorgados por fracasar / rendirse / hacer
  /// el ridículo de formas espectaculares.
  antiburocratico,

  /// Sellos por desbloqueo de secretos narrativos del overworld.
  expedienteOculto,

  /// Sellos por completar logros transversales (todos los minijuegos,
  /// todos los planetas…).
  cumbreDelPartido,
}

extension CategoriaSelloF447Visual on CategoriaSelloF447 {
  String get etiqueta {
    switch (this) {
      case CategoriaSelloF447.meritoTramitador:
        return 'MÉRITO TRAMITADOR';
      case CategoriaSelloF447.antiburocratico:
        return 'ANTIBUROCRÁTICO';
      case CategoriaSelloF447.expedienteOculto:
        return 'EXPEDIENTE OCULTO';
      case CategoriaSelloF447.cumbreDelPartido:
        return 'CUMBRE DEL PARTIDO';
    }
  }

  Color get colorTinta {
    switch (this) {
      case CategoriaSelloF447.meritoTramitador:
        return PaletaCosmoSovietica.rojoOficial;
      case CategoriaSelloF447.antiburocratico:
        return PaletaCosmoSovietica.tintaNegra;
      case CategoriaSelloF447.expedienteOculto:
        return PaletaCosmoSovietica.rojoSombra;
      case CategoriaSelloF447.cumbreDelPartido:
        return PaletaCosmoSovietica.rojoOficial;
    }
  }
}

/// Definición inmutable de un Sello F-447.
class SelloF447 {
  /// Id único — coincide con el flag que se activa en `EstadoJuego`
  /// cuando el cadete obtiene el sello.
  final String id;

  /// Nombre corto que aparece en la cara del sello.
  final String nombreCorto;

  /// Título largo que aparece en el archivo y en los registros.
  final String tituloLargo;

  /// Descripción narrativa breve (cómo se consigue, in-universe).
  final String descripcionNarrativa;

  /// Decreto del Comité que acompaña al sello — flavor burocrático.
  final String decretoComite;

  /// Categoría de archivo.
  final CategoriaSelloF447 categoria;

  /// Id del minijuego u origen del sello (para agrupar en la UI).
  /// Ej: `pixel_perdido`, `dokumentris`, `frecuencia_747`…
  /// Puede ser `null` para sellos transversales.
  final String? idOrigen;

  /// Id del objeto que se otorga al inventario JUNTO con este sello.
  /// Null si el sello no entrega objeto físico.
  final String? idObjetoOtorgado;

  const SelloF447({
    required this.id,
    required this.nombreCorto,
    required this.tituloLargo,
    required this.descripcionNarrativa,
    required this.decretoComite,
    required this.categoria,
    this.idOrigen,
    this.idObjetoOtorgado,
  });
}

/// Catálogo completo de sellos F-447 que el cadete puede coleccionar.
///
/// **Sellos de Pixel Perdido (piloto del sistema):**
const List<SelloF447> catalogoSellosF447 = <SelloF447>[
  // ──────────────────── PIXEL PERDIDO ────────────────────
  SelloF447(
    id: 'sello_pixel_reformado',
    nombreCorto: 'PÍXEL REF.',
    tituloLargo: 'Sello del Píxel Reformado',
    descripcionNarrativa:
        'Completaste un recorrido de Pixel Perdido alcanzando la bandera '
        'roja sin desintegrarte por tercera vez. El Comité reconoce tu '
        'capacidad de moverte como masa de un solo cuadrado.',
    decretoComite:
        'Decreto F-447/Π-1: "Camarada cadete demuestra aptitud satisfactoria '
        'para reducirse al tamaño mínimo cuando el Partido lo requiera. '
        'Aprobado para colaborar en archivos de baja resolución."',
    categoria: CategoriaSelloF447.meritoTramitador,
    idOrigen: 'pixel_perdido',
    idObjetoOtorgado: 'gorra_pixel_reformado',
  ),
  SelloF447(
    id: 'sello_martir_burocratico',
    nombreCorto: 'MÁRTIR',
    tituloLargo: 'Sello del Mártir Burocrático',
    descripcionNarrativa:
        'Caíste siete veces en el tubo del Píxel sin completar el '
        'recorrido. Una hazaña de devoción improductiva tan absoluta que '
        'el Comité no puede sino reconocerla.',
    decretoComite:
        'Decreto F-447/Π-2: "El camarada cadete demuestra que el sacrificio '
        'estéril también edifica al Partido. Se le condona el formulario '
        'M-7 por hoy. Mañana es otra historia."',
    categoria: CategoriaSelloF447.antiburocratico,
    idOrigen: 'pixel_perdido',
  ),
  SelloF447(
    id: 'sello_recolector_total',
    nombreCorto: 'RECOLECT.',
    tituloLargo: 'Sello del Recolector Íntegro de Kopeks',
    descripcionNarrativa:
        'Recogiste TODOS los kopeks intergalácticos de los tres recorridos '
        'sin dejarte ni uno. Eficiencia digna de auditoría.',
    decretoComite:
        'Decreto F-447/Π-3: "Se sospecha que el camarada cadete acumula '
        'capital extra-soviético. Investigación abierta. Mientras tanto, '
        'se le condecora."',
    categoria: CategoriaSelloF447.meritoTramitador,
    idOrigen: 'pixel_perdido',
  ),
  SelloF447(
    id: 'sello_topografo_universal',
    nombreCorto: 'TOPÓGR.',
    tituloLargo: 'Sello del Topógrafo Universal',
    descripcionNarrativa:
        'Cruzaste los tres recorridos del Píxel sin caer ni una sola vez. '
        'El Comité no entiende cómo es posible. Tampoco lo investiga.',
    decretoComite:
        'Decreto F-447/Π-4: "Camarada cadete demuestra dominio total del '
        'territorio cuadriculado. Se le encomienda redactar el próximo '
        'plano (en grafito blando para que pueda corregirse)."',
    categoria: CategoriaSelloF447.cumbreDelPartido,
    idOrigen: 'pixel_perdido',
  ),

  // ──────────────────── SNOW KAMARADA ────────────────────
  SelloF447(
    id: 'sello_snow_tramitador_helado',
    nombreCorto: 'HELADO',
    tituloLargo: 'Sello del Tramitador Helado',
    descripcionNarrativa:
        'Sobreviviste a tu primera oleada de burócratas capitalistas '
        'lanzándoles formularios F-447. El frío del exterior te ha '
        'curtido la sintaxis administrativa.',
    decretoComite:
        'Decreto F-447/Ω-1: "El camarada cadete sella expedientes incluso '
        'en condiciones de hipotermia. Se le entrega una ushanka oficial '
        'con cuello reglamentario."',
    categoria: CategoriaSelloF447.meritoTramitador,
    idOrigen: 'snow_kamarada',
    idObjetoOtorgado: 'ushanka_oficial',
  ),
  SelloF447(
    id: 'sello_snow_purga_capitalista',
    nombreCorto: 'PURGA',
    tituloLargo: 'Sello de la Purga Capitalista',
    descripcionNarrativa:
        'Tres oleadas de capitalistas reducidos a bolas de papel sellado. '
        'El Partido archiva tu rendimiento como ejemplo de eficiencia '
        'redactora bajo presión exterior.',
    decretoComite:
        'Decreto F-447/Ω-2: "Camarada cadete demuestra capacidad de '
        'tramitación masiva con resultado terminal. Se recomienda '
        'asignarle un sector más amplio."',
    categoria: CategoriaSelloF447.meritoTramitador,
    idOrigen: 'snow_kamarada',
  ),
  SelloF447(
    id: 'sello_snow_cafeina_eterna',
    nombreCorto: 'CAFÉ',
    tituloLargo: 'Sello del Café Inagotable',
    descripcionNarrativa:
        'Recogiste cinco cafés soviéticos seguidos sin pestañear. El '
        'Comité estudia si lo consideras una bebida o un combustible.',
    decretoComite:
        'Decreto F-447/Ω-3: "Camarada cadete demuestra apego excesivo a '
        'estimulante cafeínico. Se ordena visita preventiva al médico '
        'del Partido. Se le da otro café."',
    categoria: CategoriaSelloF447.antiburocratico,
    idOrigen: 'snow_kamarada',
  ),

  // ──────────────────── CAMARADA INVASORS ────────────────────
  SelloF447(
    id: 'sello_invasors_defensa_bunker',
    nombreCorto: 'BUNKER',
    tituloLargo: 'Sello del Defensor del Bunker F-447',
    descripcionNarrativa:
        'Repeliste a la primera escuadra de invasores capitalistas con el '
        'cañón burocrático del Bunker F-447. El Partido respira aliviado.',
    decretoComite:
        'Decreto F-447/Δ-1: "El camarada cadete defiende sin titubear el '
        'territorio soviético del cosmos. Se le condecora con una insignia '
        'metálica idéntica al sello, pero de plomo."',
    categoria: CategoriaSelloF447.meritoTramitador,
    idOrigen: 'camarada_invasors',
    idObjetoOtorgado: 'insignia_bunker',
  ),
  SelloF447(
    id: 'sello_invasors_alto_mando',
    nombreCorto: 'ALTO MAND.',
    tituloLargo: 'Sello del Alto Mando',
    descripcionNarrativa:
        'Tres tíos Sam derribados en una sola sesión. El Comité valora '
        'tu coordinación visual y tu ortografía proyectada.',
    decretoComite:
        'Decreto F-447/Δ-2: "Camarada cadete eficaz contra figura '
        'arquetípica enemiga. Se le abre expediente positivo y se le '
        'invita a almuerzo extraordinario."',
    categoria: CategoriaSelloF447.meritoTramitador,
    idOrigen: 'camarada_invasors',
  ),
  SelloF447(
    id: 'sello_invasors_comelon_forzoso',
    nombreCorto: 'COMELÓN',
    tituloLargo: 'Sello del Comelón Forzoso',
    descripcionNarrativa:
        'Las hamburguesas capitalistas te derrotaron. Te encontraron '
        'rodeado de envoltorios y con sospechosamente buena cara.',
    decretoComite:
        'Decreto F-447/Δ-3: "Sospechas de contaminación dietética del '
        'camarada cadete. Se ordena dieta de kvas durante una semana y '
        'reciclaje ideológico voluntario."',
    categoria: CategoriaSelloF447.antiburocratico,
    idOrigen: 'camarada_invasors',
  ),

  // ──────────────────── INSPEKTOR PAC-MAN ────────────────────
  SelloF447(
    id: 'sello_pacman_archivero',
    nombreCorto: 'ARCHIVER.',
    tituloLargo: 'Sello del Archivero Implacable',
    descripcionNarrativa:
        'Recorriste todo el laberinto de papel y archivaste cada '
        'expediente disperso. Ningún komisario te pilló in fraganti.',
    decretoComite:
        'Decreto F-447/Ξ-1: "Camarada cadete completó tarea de archivo '
        'en condiciones de persecución sin pérdida de documentación. '
        'Promoción inmediata pendiente de aprobación pendiente."',
    categoria: CategoriaSelloF447.meritoTramitador,
    idOrigen: 'inspektor_pacman',
    idObjetoOtorgado: 'monoculo_inspektor',
  ),
  SelloF447(
    id: 'sello_pacman_tinta_inagotable',
    nombreCorto: 'TINTA',
    tituloLargo: 'Sello de la Tinta Inagotable',
    descripcionNarrativa:
        'Usaste todos los power-ups de tinta de un laberinto. Tu cadete '
        'huele a tintero soviético durante 48 horas.',
    decretoComite:
        'Decreto F-447/Ξ-2: "Se sospecha que el camarada cadete tiene '
        'un suministro propio de tinta. Investigación abierta. Mientras '
        'tanto, se le condecora."',
    categoria: CategoriaSelloF447.meritoTramitador,
    idOrigen: 'inspektor_pacman',
  ),
  SelloF447(
    id: 'sello_pacman_burlador',
    nombreCorto: 'BURLADOR',
    tituloLargo: 'Sello del Burlador Soviético',
    descripcionNarrativa:
        'Escapaste de los cuatro komisarios (Gorro, Monóculo, Bigote, '
        'Pipa) en la misma sesión sin caer en sus arrestos.',
    decretoComite:
        'Decreto F-447/Ξ-3: "Camarada cadete con talento para esquivar '
        'autoridad. El Comité no decide si recompensarlo o vigilarlo. '
        'Hace ambas cosas."',
    categoria: CategoriaSelloF447.expedienteOculto,
    idOrigen: 'inspektor_pacman',
  ),

  // ──────────────────── FRECUENCIA 7.47 ────────────────────
  SelloF447(
    id: 'sello_frecuencia_sintonizador',
    nombreCorto: 'SINTONIZ.',
    tituloLargo: 'Sello del Sintonizador Fiel',
    descripcionNarrativa:
        'Encontraste una estación secreta entre el ruido blanco. El '
        'Partido escucha lo que dices y a quién lo dices.',
    decretoComite:
        'Decreto F-447/Ψ-1: "Camarada cadete demuestra fidelidad auditiva '
        'a la propaganda oficial. Recibe el rango de Oyente Cualificado '
        'de Tercera Categoría."',
    categoria: CategoriaSelloF447.meritoTramitador,
    idOrigen: 'frecuencia_747',
  ),
  SelloF447(
    id: 'sello_frecuencia_verdad_recibida',
    nombreCorto: 'VERDAD',
    tituloLargo: 'Sello de la Verdad Recibida',
    descripcionNarrativa:
        'Encontraste TODAS las estaciones secretas del dial. Conoces '
        'cosas que oficialmente no existen. Bienvenido al Comité.',
    decretoComite:
        'Decreto F-447/Ψ-2: "Se considera al camarada cadete apto para '
        'recibir información clasificada que ya conoce. Se le asigna '
        'una cuota silenciosa."',
    categoria: CategoriaSelloF447.cumbreDelPartido,
    idOrigen: 'frecuencia_747',
    idObjetoOtorgado: 'aguja_dial_oficial',
  ),
  SelloF447(
    id: 'sello_estatica_eterna',
    nombreCorto: 'ESTÁTICA',
    tituloLargo: 'Sello del Ruido Blanco',
    descripcionNarrativa:
        'Pasaste un minuto entero girando el dial sin enganchar ninguna '
        'estación. El Comité respeta tu compromiso con el ruido sin '
        'origen.',
    decretoComite:
        'Decreto F-447/Ψ-3: "El camarada cadete medita correctamente. '
        'Se le exime del próximo discurso obligatorio. (Se le añade el '
        'siguiente)."',
    categoria: CategoriaSelloF447.antiburocratico,
    idOrigen: 'frecuencia_747',
  ),

  // ──────────────────── DOKUMENTRIS ────────────────────
  SelloF447(
    id: 'sello_dokumentris_tramitador',
    nombreCorto: 'TRAMITAD.',
    tituloLargo: 'Sello del Tramitador Eficiente',
    descripcionNarrativa:
        'Limpiaste una fila completa de formularios apilados antes de '
        'que el archivo te aplastase. Un acto burocrático básico, pero '
        'archivable.',
    decretoComite:
        'Decreto F-447/Δm-1: "Camarada cadete tramita formularios con '
        'fluidez. Se le admite a la cadena oficial de aprobación de '
        'aprobaciones."',
    categoria: CategoriaSelloF447.meritoTramitador,
    idOrigen: 'dokumentris',
    idObjetoOtorgado: 'sello_mano_oficial',
  ),
  SelloF447(
    id: 'sello_dokumentris_cascada',
    nombreCorto: 'CASCADA',
    tituloLargo: 'Sello de la Cascada de Aprobaciones',
    descripcionNarrativa:
        'Aprobaste cuatro filas a la vez con una sola pieza vertical. '
        'El Comité llama a esto "tetris burocrático" en privado.',
    decretoComite:
        'Decreto F-447/Δm-2: "Camarada cadete demuestra eficiencia que '
        'puede atribuirse al sistema o a la suerte. Ambas se '
        'consideran propiedad del Partido."',
    categoria: CategoriaSelloF447.cumbreDelPartido,
    idOrigen: 'dokumentris',
  ),
  SelloF447(
    id: 'sello_dokumentris_atasco',
    nombreCorto: 'ATASCO',
    tituloLargo: 'Sello del Atasco de Papeleo',
    descripcionNarrativa:
        'El tablero se llenó hasta arriba y el archivo te sepultó. El '
        'Partido entiende: a veces el papeleo gana.',
    decretoComite:
        'Decreto F-447/Δm-3: "Camarada cadete sucumbe a presión '
        'administrativa razonable. Se le ofrece una semana de descanso '
        'archivada como semana de trabajo."',
    categoria: CategoriaSelloF447.antiburocratico,
    idOrigen: 'dokumentris',
  ),

  // ──────────────────── SUPER PANG GALÁCTICO ────────────────────
  SelloF447(
    id: 'sello_pang_pinchador',
    nombreCorto: 'PINCHADOR',
    tituloLargo: 'Sello del Pinchador de Burbujas',
    descripcionNarrativa:
        'Reventaste diez globos burocráticos con tu arpón soviético. '
        'Cada estallido archivó una queja sin tramitar.',
    decretoComite:
        'Decreto F-447/Γ-1: "El camarada cadete reduce burbujas '
        'administrativas. Se le entrega arpón conmemorativo (no apto '
        'para uso real)."',
    categoria: CategoriaSelloF447.meritoTramitador,
    idOrigen: 'super_pang',
    idObjetoOtorgado: 'arpon_ceremonial',
  ),
  SelloF447(
    id: 'sello_pang_arponero',
    nombreCorto: 'ARPONERO',
    tituloLargo: 'Sello del Arponero Soviético',
    descripcionNarrativa:
        'Completaste un nivel completo de globos sin perder una sola '
        'vida. Tu puntería es objeto de estudio académico.',
    decretoComite:
        'Decreto F-447/Γ-2: "Camarada cadete sin desperdicio en '
        'munición ni vida. Eficiencia digna de protocolo militar."',
    categoria: CategoriaSelloF447.cumbreDelPartido,
    idOrigen: 'super_pang',
  ),
  SelloF447(
    id: 'sello_pang_martir_inflado',
    nombreCorto: 'INFLADO',
    tituloLargo: 'Sello del Mártir Inflado',
    descripcionNarrativa:
        'Te aplastaron tres globos seguidos. El Partido condecora la '
        'persistencia, no necesariamente la habilidad.',
    decretoComite:
        'Decreto F-447/Γ-3: "El camarada cadete demuestra que la goma '
        'también gobierna. Se le recomienda libro: \'Aerodinámica del '
        'sufrimiento administrativo\'."',
    categoria: CategoriaSelloF447.antiburocratico,
    idOrigen: 'super_pang',
  ),
];

/// Acceso por id — útil para resolver flag → metadatos del sello.
SelloF447? selloPorId(String id) {
  for (final sello in catalogoSellosF447) {
    if (sello.id == id) return sello;
  }
  return null;
}

/// Filtra el catálogo por origen (minijuego/zona).
List<SelloF447> sellosDeOrigen(String idOrigen) {
  return catalogoSellosF447
      .where((sello) => sello.idOrigen == idOrigen)
      .toList(growable: false);
}
