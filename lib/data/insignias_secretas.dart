import '../models/game_state.dart';

/// Insignia honorífica clandestina. El Estado no las reconoce oficialmente,
/// pero quedan apuntadas en el expediente del cadete bajo «curiosidades de
/// conducta». Coleccionarlas no aporta ventaja mecánica directa; sí da
/// líneas de diálogo nuevas y, en algún caso, micro-recompensas.
class InsigniaSecretaInfo {
  /// Identificador interno del flag que la activa: `insignia_<algo>`.
  final String identificadorFlag;
  final String nombreOficial;
  final String motivoBurocratico;
  final String pictograma;
  /// Ruta opcional al PNG con arte oficial de la insignia. Si está
  /// definida, la notificación la muestra en lugar del pictograma
  /// Unicode. Resolución típica 1254×1254, renderizada en miniatura.
  final String? rutaIconoPng;

  const InsigniaSecretaInfo({
    required this.identificadorFlag,
    required this.nombreOficial,
    required this.motivoBurocratico,
    required this.pictograma,
    this.rutaIconoPng,
  });
}

/// Catálogo cerrado de insignias secretas del prototipo. Añadir más sólo
/// requiere insertarlas aquí: el diario las recoge automáticamente.
const List<InsigniaSecretaInfo> catalogoInsigniasSecretas = [
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_martir_del_tornillo',
    nombreOficial: 'Mártir del Tornillo',
    motivoBurocratico:
        'Por sangrar repetidamente contra remaches de fabricación '
        'estatal y registrar la queja con voz audible.',
    pictograma: '★',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_chiste_prohibido',
    nombreOficial: 'Oyente del Chiste Prohibido',
    motivoBurocratico:
        'Por insistir hasta el séptimo vaso de vodka sintético, '
        'desbloqueando una anécdota que el Comité considera improbable.',
    pictograma: '☼',
    rutaIconoPng: 'assets/svg/insignia_chiste_prohibido.png',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_te_sin_sufrimiento',
    nombreOficial: 'Té Sin Sufrimiento',
    motivoBurocratico:
        'Por convencer al samovar del reactor de servir té sin '
        'requisar la presencia de la Madre Ferruginosa.',
    pictograma: '♨',
    rutaIconoPng: 'assets/svg/insignia_te_sin_sufrimiento.png',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_voto_marciano',
    nombreOficial: 'Voto Marciano Reconocido',
    motivoBurocratico:
        'Por depositar cinco papeletas en blanco en la Asamblea de '
        'Zovnak-4. El Marciano Provisional asintió.',
    pictograma: '☉',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_cadete_traidor',
    nombreOficial: 'Cadete de Comportamiento Curioso',
    motivoBurocratico:
        'Por introducir, en suelo soviético oficial, una secuencia '
        'capitalista de movimientos no homologados por el Manual.',
    pictograma: '✕',
    rutaIconoPng: 'assets/svg/insignia_cadete_traidor.png',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_pulgar_del_comisariado',
    nombreOficial: 'Pulgar del Comisariado',
    motivoBurocratico:
        'Por accionar reiteradamente el dispositivo de tramitación sin '
        'sujeto válido. El Comité agradece su entusiasmo procedimental.',
    pictograma: '☞',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_susurro_archivero',
    nombreOficial: 'Susurro del Archivero',
    motivoBurocratico:
        'Por permanecer absolutamente quieto durante cuatro segundos '
        'consecutivos en presencia oficial del archivador. El archivo '
        'le devolvió un nombre.',
    pictograma: '⌘',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_hierro_caliente',
    nombreOficial: 'El Hierro Caliente',
    motivoBurocratico:
        'Por palpar repetidamente el núcleo del reactor con la mano '
        'desnuda y declararlo «templado». El médico del Estado declina '
        'comentar.',
    pictograma: '☢',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_cara_al_sol',
    nombreOficial: 'Cara al Sol Camarada',
    motivoBurocratico:
        'Por permanecer cuatro segundos contemplando un sol soviético '
        'sin parpadear. La retina aprueba.',
    pictograma: '☀',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_tipo_glacial',
    nombreOficial: 'Tipo Glacial',
    motivoBurocratico:
        'Por accionar doce veces el dispositivo de tramitación sobre la '
        'nieve burocrática de Gélida-9. El frío congela el formulario '
        'pero no el celo del cadete.',
    pictograma: '❄',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_eco_pravda',
    nombreOficial: 'Eco de la Pravda',
    motivoBurocratico:
        'Por escuchar, en pleno silencio, una transmisión del miércoles '
        'que el Comité jura no haber emitido nunca.',
    pictograma: '☉',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_madre_te_ve',
    nombreOficial: 'Madre Te Ve',
    motivoBurocratico:
        'Por quedarse el suficiente tiempo en la cantina para que Madre '
        'Ferruginosa, burbujeando, te transmita su preocupación maternal.',
    pictograma: '♥',
    rutaIconoPng: 'assets/svg/insignia_madre_te_ve.png',
  ),

  // ─── Insignias con sólo arte: nuevos disparadores para PNG huérfanos ──
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_laika_adoptada',
    nombreOficial: 'Adopción Soviética No Aprobada',
    motivoBurocratico:
        'Por adoptar, sin el formulario F-Z47 ni la firma del Comisariado '
        'de Mascotas, a una gatita-perra cosmonauta perdida bajo una '
        'mesa. El Comité finge no haberse enterado.',
    pictograma: '🐾',
    rutaIconoPng: 'assets/svg/insignia_laika_adoptada.png',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_primer_combate',
    nombreOficial: 'Primer Expediente Cerrado',
    motivoBurocratico:
        'Por neutralizar al Funcionario Espectral de Archivo y dos Ratas '
        'Mutadas en el incidente inaugural de la Pravda-12. El cadete '
        'queda inscrito en el registro de "combatientes con suerte".',
    pictograma: '⚔',
    rutaIconoPng: 'assets/svg/insignia_primer_combate.png',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_strike_burocratico',
    nombreOficial: 'Strike Burocrático',
    motivoBurocratico:
        'Por derribar, en una sola embestida rodante, todos los bolos '
        'burocráticos en formación. El Comité de Bolos del Partido '
        'levanta acta y la archiva inmediatamente.',
    pictograma: '★',
    rutaIconoPng: 'assets/svg/insignia_strike_burocratico.png',
  ),

  // ─── Huevos de pascua (puzles del escenario) ──────────────────────────
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_pacto_bajo_la_mesa',
    nombreOficial: 'Pacto Bajo la Mesa',
    motivoBurocratico:
        'Por accionar, en modo rodante, la placa oculta bajo la mesa del '
        'Comandante Ostrog. Cayó una jarra. De la jarra salió una nota '
        'firmada con una sola letra.',
    pictograma: '☕',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_archivero_krilov',
    nombreOficial: 'Archivero de Krilov',
    motivoBurocratico:
        'Por mover un cajón institucional sin permiso burocrático y '
        'descubrir, debajo, un sello que el organigrama no admite. El '
        'expediente Krilov gana espesor.',
    pictograma: '⌬',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_grafiti_pravda7',
    nombreOficial: 'Grafiti Subversivo',
    motivoBurocratico:
        'Por embestir, en modo bola, una tubería que el Comité daba por '
        'sellada y revelar, en pintura roja: «PRAVDA-7 NO MURIÓ». El '
        'archivo prefiere ignorarlo.',
    pictograma: '✎',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_quincalla_vostrikova',
    nombreOficial: 'Quincalla con Permiso',
    motivoBurocratico:
        'Por derribar cinco conos de mantenimiento del reactor con '
        'precisión irresponsable. La Ingeniera Vostrikova, al cabo de un '
        'silencio largo, le ha pasado un rollo extra de cinta adhesiva.',
    pictograma: '✖',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_urna_descubierta',
    nombreOficial: 'Urna Desplazada',
    motivoBurocratico:
        'Por empujar la urna nº 47 de la Asamblea Permanente de Zovnak-4 '
        'fuera de su rectángulo oficial. Debajo: papeletas con la letra K '
        'tachadas con sangre vegetal marciana.',
    pictograma: '☐',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_pinguino_burocratico',
    nombreOficial: 'Pingüino Burocrático',
    motivoBurocratico:
        'Por reventar, contra la voluntad del Comité de Gélida-9, el muro '
        'de formularios F-447 congelados. Tras la grieta, un pingüino '
        'oficial estampó tu visado y se fue sin decir adiós.',
    pictograma: '❅',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_huelga_silenciosa',
    nombreOficial: 'Huelga Silenciosa',
    motivoBurocratico:
        'Por derribar la cristalera del sindicato del Sol Camarada con '
        'arrojo rodante. El Delegado, en lugar de denunciarte, ha aplaudido '
        'tres veces.',
    pictograma: '⚒',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_susurro_petrov',
    nombreOficial: 'Susurro Petrov',
    motivoBurocratico:
        'Por pulsar, en la Pravda-7, el panel central con la masa exacta '
        'que un cadete erguido nunca consigue. La estación susurró el '
        'nombre que el archivo ha tachado dos veces: Petrov 58.',
    pictograma: '☋',
  ),
  InsigniaSecretaInfo(
    identificadorFlag: 'insignia_estrella_pulsada_siete',
    nombreOficial: 'Estrella Pulsada Siete',
    motivoBurocratico:
        'Por pulsar, en el pórtico de bienvenida, la estrella roja del '
        'banner siete veces sin que nadie se lo pidiera. Se abre acceso '
        'al «Expediente Sin Filtro».',
    pictograma: '✦',
  ),
];

bool insigniaDesbloqueada(EstadoJuego estado, String idFlag) =>
    estado.tieneFlag(idFlag);

int cantidadInsigniasDesbloqueadas(EstadoJuego estado) {
  int total = 0;
  for (final insignia in catalogoInsigniasSecretas) {
    if (estado.tieneFlag(insignia.identificadorFlag)) total++;
  }
  return total;
}
