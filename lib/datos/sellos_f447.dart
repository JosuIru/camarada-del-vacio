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
