import '../models/game_state.dart';

/// Estado lógico en el que se encuentra una misión, derivado de los flags
/// vigentes del [EstadoJuego]. No se persiste por separado: cada vez que se
/// consulta, se evalúa con la información que el jugador ya ha desbloqueado.
enum EstadoMision {
  bloqueada,
  activa,
  completada,
}

class MisionInfo {
  final String identificador;
  final String titulo;
  final String descripcion;
  final String pistaSiguientePaso;
  final bool Function(EstadoJuego) condicionDesbloqueo;
  final bool Function(EstadoJuego) condicionCompletada;

  const MisionInfo({
    required this.identificador,
    required this.titulo,
    required this.descripcion,
    required this.pistaSiguientePaso,
    required this.condicionDesbloqueo,
    required this.condicionCompletada,
  });

  EstadoMision evaluarEstado(EstadoJuego estado) {
    if (condicionCompletada(estado)) return EstadoMision.completada;
    if (condicionDesbloqueo(estado)) return EstadoMision.activa;
    return EstadoMision.bloqueada;
  }
}

class PistaInfo {
  final String identificadorFlag;
  final String fuente;
  final String contenido;

  const PistaInfo({
    required this.identificadorFlag,
    required this.fuente,
    required this.contenido,
  });
}

/// Misiones del prototipo Acto 1. El orden importa: se listan al usuario en
/// el mismo orden en que probablemente las encuentre, simulando el progreso
/// narrativo del cadete por el Cuadrante Sigma.
const List<MisionInfo> catalogoMisiones = [
  MisionInfo(
    identificador: 'mision_pravda7_general',
    titulo: 'Localizar la Pravda-7',
    descripcion:
        'La estación orbital Pravda-7 desapareció en el incidente del '
        'miércoles. El Camarada Directorskov niega haberse equivocado, '
        'pero su silencio es ensordecedor. Hay que encontrarla.',
    pistaSiguientePaso:
        'Vostrikova te entregó la primera coordenada en el reactor. '
        'Hacen falta dos firmas más para triangular: una en Gélida-9 '
        '(Recepción) y otra en Sol Camarada (Delegación Sindical). '
        'La Asamblea de Zovnak-4 aporta un voto corroborante pero no '
        'es necesaria.',
    condicionDesbloqueo: _siempreActiva,
    condicionCompletada: _pravda7Localizable,
  ),
  MisionInfo(
    identificador: 'mision_glasnov_ostrog',
    titulo: 'Hablar con Ostrog en la cantina',
    descripcion:
        'Ostrog regenta la cantina de Pravda-12 y oye más rumores que '
        'el propio Comisariado. Si alguien sabe por dónde empezar, es él.',
    pistaSiguientePaso:
        'Bajar a la cantina y pedirle un té de Madre Ferruginosa.',
    condicionDesbloqueo: _siempreActiva,
    condicionCompletada: _habloConOstrog,
  ),
  MisionInfo(
    identificador: 'mision_zovnak4',
    titulo: 'Atravesar la Asamblea Permanente de Zovnak-4 (opcional)',
    descripcion:
        'Zovnak-4 está en sesión electoral permanente desde 1957. '
        'El Alcalde Provisional bloquea el paso hasta que el votante '
        'ejerza su deber cívico. Por las buenas o por las malas. '
        'Visitar Zovnak NO es necesario para localizar la Pravda-7 — '
        'el voto del Marciano Provisional corrobora la pista de '
        'Vostrikova, no la sustituye.',
    pistaSiguientePaso:
        'Hablar con el Alcalde o convencer a la asamblea con Carisma. '
        'Ruta secundaria del Acto 1.',
    condicionDesbloqueo: _habloConOstrog,
    condicionCompletada: _asambleaZovnakResueltaOVencida,
  ),
  MisionInfo(
    identificador: 'mision_gelida9',
    titulo: 'Pasar la Recepción de Gélida-9',
    descripcion:
        'Gélida-9 mantiene una cola burocrática de hace 17 años. '
        'El Jefe de Recepción exige formulario F-447 sellado por '
        'duplicado antes de autorizar el tránsito.',
    pistaSiguientePaso:
        'Convencer al Jefe, presentar el F-447 o forzar el paso.',
    condicionDesbloqueo: _tieneRumor1,
    condicionCompletada: _pasoGelidaOVencido,
  ),
  MisionInfo(
    identificador: 'mision_sol_camarada',
    titulo: 'Resolver la Huelga del Sol Camarada',
    descripcion:
        'Los Delegados Sindicales Solares han parado las refinerías '
        'de protones. Sin esa energía no se puede triangular hacia el '
        'sur del Cuadrante.',
    pistaSiguientePaso:
        'Negociar con el delegado, sabotear el altavoz o '
        'derrotar la mesa sindical.',
    condicionDesbloqueo: _tieneFragmento2,
    condicionCompletada: _solarResuelto,
  ),
  MisionInfo(
    identificador: 'mision_pravda7_abordaje',
    titulo: 'Abordar la Pravda-7',
    descripcion:
        'Con las tres firmas convergentes, la Pravda-7 es localizable. '
        'Hay que abordarla. El Espectro de Directorskov espera dentro.',
    pistaSiguientePaso:
        'Viajar al planeta Pravda-7 desde el Cuadrante Sigma.',
    condicionDesbloqueo: _pravda7Localizable,
    condicionCompletada: _finalAlcanzado,
  ),
  MisionInfo(
    identificador: 'mision_investigar_krilov',
    titulo: 'Expediente Krilov · Hilo abierto del Acto 2',
    descripcion:
        'El Inspector Krilov reclama cajas «para custodia oficial» que '
        'el Comisariado Central no ha solicitado. Su nombre aparece en '
        'el margen de tres expedientes y en ningún registro firmado. '
        'Alguien tiene que tirar del hilo — pero el careo formal está '
        'reservado al Acto 2 del prototipo extendido.',
    pistaSiguientePaso:
        '[Acto 2] El expediente queda formalmente abierto al alcanzar '
        'el epílogo del Acto 1: las evidencias recolectadas en este '
        'arco (nota del cocinero, caja del reactor, derrota del Cabo) '
        'se archivan para el careo posterior. Confrontación cara a '
        'cara pendiente.',
    condicionDesbloqueo: _krilovEnEscena,
    condicionCompletada: _expedienteKrilovArchivado,
  ),
  MisionInfo(
    identificador: 'mision_te_de_madre',
    titulo: 'Té de Madre Ferruginosa',
    descripcion:
        'Madre Ferruginosa sirve un té reparador (1 PA extra al iniciar '
        'el siguiente combate) a quien acepte sentarse a su mesa. '
        'Ostrog la menciona de pasada en la cantina, pero quien lo da '
        '— y a quien hay que pedírselo — es ella.',
    pistaSiguientePaso:
        'Hablar con Madre Ferruginosa en la cantina y aceptar el té '
        'antes del próximo combate. El efecto se consume al entrar a '
        'la siguiente pelea.',
    condicionDesbloqueo: _habloConOstrog,
    condicionCompletada: _teDeMadreReclamado,
  ),
];

/// Pistas concretas que el cadete puede recolectar. Cada una se desbloquea
/// cuando el flag correspondiente está activo. Si la pista no se ha
/// obtenido, en el diario aparecerá como «sin información».
const List<PistaInfo> catalogoPistas = [
  PistaInfo(
    identificadorFlag: 'hablo_con_ostrog',
    fuente: 'Ostrog · Cantina Pravda-12',
    contenido:
        'Lo último que oyó por la radio antes del apagón fue una orden '
        'de evacuación abortada. La Pravda-7 nunca completó la maniobra.',
  ),
  PistaInfo(
    identificadorFlag: 'pista_pravda7_inicial',
    fuente: 'Ingeniera Vostrikova · Reactor de Pravda-12',
    contenido:
        'Al despedirse, Vostrikova garabateó la primera coordenada de '
        'la Pravda-7 en una servilleta. Apunta hacia el Cuadrante '
        'Sigma; basta para abrir el tránsito a Gélida-9 sin pasar '
        'por la Asamblea de Zovnak-4.',
  ),
  PistaInfo(
    identificadorFlag: 'rumor_pravda7',
    fuente: 'Marciano Provisional · Asamblea de Zovnak-4',
    contenido:
        'Un voto en la urna 47 declaraba haber visto «una caja orbital '
        'silenciosa» pasar sobre Zovnak-4 el miércoles del incidente. '
        'Trayectoria: rumbo Gélida-9. (Corroboración opcional de la '
        'pista inicial del reactor.)',
  ),
  PistaInfo(
    identificadorFlag: 'rumor_pravda7_fragmento2',
    fuente: 'Jefe de Recepción · Gélida-9',
    contenido:
        'En su archivador escondió coordenadas con extensión Y-447. '
        'Insistió en que «no son nuestras» y exigió silencio bajo el '
        'sello del Comisariado.',
  ),
  PistaInfo(
    identificadorFlag: 'rumor_pravda7_fragmento3',
    fuente: 'Delegado Sindical · Sol Camarada',
    contenido:
        'Hay un campo gravitacional anómalo al sur del Sol Camarada '
        'desde el incidente. Las brigadas refineras lo llaman «el bulto '
        'que no consta en el Plan».',
  ),
  PistaInfo(
    identificadorFlag: 'pravda7_localizable',
    fuente: 'Triangulación oficial',
    contenido:
        'Las tres firmas convergen: la Pravda-7 está en órbita '
        'sub-solar, congelada por el desfase temporal. Acceso posible '
        'desde el Cuadrante Sigma.',
  ),
  PistaInfo(
    identificadorFlag: 'caja_vista',
    fuente: 'Ingeniera Vostrikova · Reactor',
    contenido:
        'La caja sin etiquetar que está en el reactor lleva un sello '
        'idéntico al que se aplica a la correspondencia entre Pravda-7 '
        'y el Comisariado Central. No es coincidencia.',
  ),
  PistaInfo(
    identificadorFlag: 'caja_entregada_krilov',
    fuente: 'Camarada Krilov · Antagonista',
    contenido:
        'Reclamó la caja del reactor «para custodia oficial». Su versión '
        'no coincide con la del Comisariado Central. Sospechoso.',
  ),
  PistaInfo(
    identificadorFlag: 'caja_perdida_en_cabo',
    fuente: 'Pasillo del Reactor · Inspección',
    contenido:
        'El Cabo dijo que «el Inspector Krilov agradecerá la entrega». '
        'No mostró credenciales. El nombre Krilov no figura en el '
        'organigrama oficial de Pravda-12 ni del Comisariado Central.',
  ),
  PistaInfo(
    identificadorFlag: 'venciste_cabo',
    fuente: 'Bolsillo del Cabo derrotado',
    contenido:
        'Una nota arrugada en la solapa: «K. ordena recuperar la caja. '
        'Compartimento 7-Б sin testigos. Quemar este papel.» Firmado '
        'con una sola letra: К.',
  ),
];

bool _siempreActiva(EstadoJuego estado) => true;

bool _pravda7Localizable(EstadoJuego estado) =>
    estado.tieneFlag('pravda7_localizable');

bool _habloConOstrog(EstadoJuego estado) =>
    estado.tieneFlag('hablo_con_ostrog');

bool _asambleaZovnakResueltaOVencida(EstadoJuego estado) =>
    estado.tieneFlag('asamblea_zovnak4_resuelta') ||
    estado.tieneFlag('venciste_asamblea_zovnak');

bool _tieneRumor1(EstadoJuego estado) =>
    estado.tieneFlag('pista_pravda7_inicial');

bool _tieneFragmento2(EstadoJuego estado) =>
    estado.tieneFlag('rumor_pravda7_fragmento2');

bool _pasoGelidaOVencido(EstadoJuego estado) =>
    estado.tieneFlag('paso_gelida_concedido') ||
    estado.tieneFlag('venciste_recepcion_gelida');

bool _solarResuelto(EstadoJuego estado) =>
    estado.tieneFlag('solar_negociacion_resuelta') ||
    estado.tieneFlag('venciste_delegacion_solar');

bool _finalAlcanzado(EstadoJuego estado) =>
    estado.tieneFlag('pravda7_final_partido') ||
    estado.tieneFlag('pravda7_final_humanista') ||
    estado.tieneFlag('pravda7_final_combate');

bool _krilovEnEscena(EstadoJuego estado) =>
    estado.tieneFlag('caja_perdida_en_cabo') ||
    estado.tieneFlag('caja_entregada_krilov') ||
    estado.tieneFlag('venciste_cabo');

/// La misión Krilov es contenido planteado para el Acto 2 (careo cara
/// a cara con el Inspector). En el Acto 1 sólo se acumulan evidencias.
/// Damos por "archivada" la misión al alcanzar cualquiera de los tres
/// finales: el expediente queda físicamente abierto pero el arco
/// narrativo de este prototipo se ha cerrado.
bool _expedienteKrilovArchivado(EstadoJuego estado) =>
    estado.tieneFlag('expediente_krilov_cerrado') || _finalAlcanzado(estado);

bool _teDeMadreReclamado(EstadoJuego estado) =>
    estado.tieneFlag('te_de_madre') ||
    estado.tieneFlag('te_de_madre_consumido');
