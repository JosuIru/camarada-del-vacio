import '../models/game_state.dart';
import 'sellos_f447.dart';

/// Mapeo sello → 1-2 frases que un NPC de la base puede soltar al
/// reconocer ese sello en el expediente del cadete. Cada frase es
/// pequeña, irónica y burocrática.
const Map<String, List<String>> _rumoresPorSello = <String, List<String>>{
  // ── Pixel Perdido ──
  'sello_pixel_reformado': <String>[
    'Dicen que el Camarada cadete ha sabido reducirse al tamaño de un '
        'cuadrado. Lo cual, en burocracia, es valioso.',
    'Π-1 archivado. El cadete pasó por el tubo y volvió más cuadrado, '
        'pero igual de tarde.',
  ],
  'sello_martir_burocratico': <String>[
    'Se rumorea que el cadete cayó siete veces en el tubo. Siete. El '
        'Comité ha pedido una conferencia sobre persistencia inútil.',
  ],
  'sello_recolector_total': <String>[
    'Hay quien sospecha que el cadete recoge kopeks. Kopeks. En el '
        'cosmos. ¿De dónde salen? Mejor no preguntar.',
  ],
  'sello_topografo_universal': <String>[
    'El cadete cruzó los tres recorridos del Píxel sin caerse. Eso o '
        'el tubo se ha vuelto blando. El Partido investiga.',
  ],

  // ── Snow Kamarada ──
  'sello_snow_tramitador_helado': <String>[
    'Te ví defender el Bunker entre las nieves con el formulario en la '
        'mano. Si todos fuésemos así, ya estaríamos en casa.',
  ],
  'sello_snow_purga_capitalista': <String>[
    'Tres oleadas. Cero capitalistas en pie. El Comité considera abrir '
        'una calle a tu nombre. Si encuentra una.',
  ],
  'sello_snow_cafeina_eterna': <String>[
    'Cinco cafés en una sola misión. Esto va más allá del tramitador: '
        'es un acto de fe líquida.',
  ],

  // ── Camarada Invasors ──
  'sello_invasors_defensa_bunker': <String>[
    'Defendiste el Bunker F-447. Mientras tanto los demás firmábamos '
        'formularios. Cada cual su frente.',
  ],
  'sello_invasors_alto_mando': <String>[
    'Tres Tíos Sam. En un solo turno. Los superiores lo han comentado '
        'en la sauna. (No se ha levantado acta.)',
  ],

  // ── Inspektor Pac-Man ──
  'sello_pacman_archivero': <String>[
    'Archivaste todos los expedientes del laberinto. El Komisariato '
        'no entiende cómo. Te observan con cariño y suspicacia.',
  ],
  'sello_pacman_tinta_inagotable': <String>[
    'Se dice que el cadete consumió toda la tinta del laberinto. La '
        'oficina de suministros mira a otro lado.',
  ],
  'sello_pacman_burlador': <String>[
    'Burlaste a los cuatro komisarios el mismo día. Gorro, Monóculo, '
        'Bigote, Pipa. Te imaginas la sala de reuniones.',
  ],

  // ── Frecuencia 7.47 ──
  'sello_frecuencia_sintonizador': <String>[
    'Encontraste UNA estación. Lo cual quiere decir que existen MÁS. '
        'O las has imaginado. Pero la imaginación se aprueba aquí.',
  ],
  'sello_frecuencia_verdad_recibida': <String>[
    'Todas las estaciones secretas. Sabes lo que sabe el Comité. El '
        'Comité ahora sabe que tú lo sabes. Suerte.',
  ],
  'sello_estatica_eterna': <String>[
    'Un minuto entero girando el dial sin enganchar. Eso es '
        'meditación, camarada. O sabotaje. Depende del informe.',
  ],

  // ── Dokumentris ──
  'sello_dokumentris_tramitador': <String>[
    'Te ví apilar formularios con velocidad razonable. El Partido '
        'aprueba la mediocridad cumplidora.',
  ],
  'sello_dokumentris_cascada': <String>[
    'Cuatro filas a la vez. La cantina aún habla de aquel día. Algunos '
        'lo niegan. Otros lo han copiado en su expediente.',
  ],
  'sello_dokumentris_atasco': <String>[
    'Te aplastó el papeleo. Bienvenido al club. Yo lo llevo desde el '
        '57.',
  ],

  // ── Super Pang ──
  'sello_pang_pinchador': <String>[
    'Diez globos burocráticos reventados. Que sepas que cada uno '
        'contenía una queja real. Y ya no.',
  ],
  'sello_pang_arponero': <String>[
    'Nivel completo sin perder vida. Tu arpón es admirado. Tu '
        'expediente, todavía más.',
  ],
  'sello_pang_martir_inflado': <String>[
    'Te aplastaron tres globos seguidos. El Comité considera ofrecerte '
        'una semana en el sanatorio. (No la tienes.)',
  ],
};

/// Devuelve una frase contextual sobre uno de los sellos que el cadete
/// ya tiene archivados. Si el cadete no tiene ningún sello, devuelve
/// `null`. La selección es pseudoaleatoria pero estable dentro de la
/// misma sesión: el mismo NPC repite la misma frase hasta que el
/// cadete consigue un sello nuevo.
String? rumorSobreSellosDelCadete(EstadoJuego estado) {
  final sellosObtenidos = catalogoSellosF447
      .where((sello) => estado.tieneFlag(sello.id))
      .toList(growable: false);
  if (sellosObtenidos.isEmpty) return null;

  // Determinismo en sesión: el índice se calcula con la cantidad de
  // sellos, así que cada vez que el cadete suma uno, el rumor cambia.
  final SelloF447 sello =
      sellosObtenidos[sellosObtenidos.length % sellosObtenidos.length];
  final List<String>? frases = _rumoresPorSello[sello.id];
  if (frases == null || frases.isEmpty) {
    return 'Dicen que el camarada cadete ha conseguido el sello '
        '"${sello.tituloLargo}". El Partido lo registra.';
  }
  return frases[sellosObtenidos.length % frases.length];
}
