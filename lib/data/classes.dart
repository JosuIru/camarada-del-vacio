import '../models/game_class.dart';

const Map<ClaseCosmonauta, DefinicionClase> catalogoClases = {
  ClaseCosmonauta.gimnasta: DefinicionClase(
    identificador: ClaseCosmonauta.gimnasta,
    nombreCompleto: 'Cosmonauta de Gimnasia',
    subtitulo: 'Cuerpo · Mártir Cardiovascular',
    descripcionBreve:
        'Las rutinas de gimnasia matutina soviética son, en realidad, series de combate. Una plancha bien ejecutada inflige más daño que un misil mediocre.',
    saborInicial:
        '"El cuerpo es el primer instrumento de la revolución. Afílalo como si fuera una hoz." — Manual de Gimnasia Patriótica, Volumen III.',
    cuerpoBase: 8,
    menteBase: 6,
    carismaBase: 5,
    nombreHabilidadDestacada: 'Salto Mortal Patriótico',
    descripcionHabilidadDestacada:
        'Avanzas tres casillas en pirueta y golpeas con +50% de daño. Cuesta 3 PA.',
    nombreArmaInicial: 'Llave Inglesa "Estakhanov"',
    danoArmaInicial: 3,
    costePaArmaInicial: 2,
    tipoDanoInicial: 'físico',
    idsHabilidadesClase: [
      'gimnasta_salto_mortal',
      'gimnasta_calistenia',
      'gimnasta_pulso_cardiovascular',
      'gimnasta_patada_olimpica',
    ],
  ),
  ClaseCosmonauta.ingeniera: DefinicionClase(
    identificador: ClaseCosmonauta.ingeniera,
    nombreCompleto: 'Ingeniera de Cinta Adhesiva',
    subtitulo: 'Mente · Reparar y Sabotear',
    descripcionBreve:
        'Con cinta adhesiva suficiente y la teoría correcta, se puede reparar cualquier cosa. También sabotear cualquier cosa. El equilibrio es delicado.',
    saborInicial:
        '"La cinta adhesiva no tiene ideología. Pero pega igual de bien en todos los sistemas políticos." — Diario de campo, Ingeniera Vostrikova.',
    cuerpoBase: 6,
    menteBase: 9,
    carismaBase: 4,
    nombreHabilidadDestacada: 'Sabotaje Quinquenal',
    descripcionHabilidadDestacada:
        'Inutilizas el arma o sistema del enemigo durante 2 turnos. Cuesta 4 PA.',
    nombreArmaInicial: 'Soldador Improvisado',
    danoArmaInicial: 3,
    costePaArmaInicial: 2,
    tipoDanoInicial: 'técnico',
    idsHabilidadesClase: [
      'ingeniera_sabotaje',
      'ingeniera_parche_urgencia',
      'ingeniera_caja_inversa',
      'ingeniera_cinta_inmovilizante',
    ],
  ),
  ClaseCosmonauta.comisaria: DefinicionClase(
    identificador: ClaseCosmonauta.comisaria,
    nombreCompleto: 'Comisario Poeta',
    subtitulo: 'Carisma · Discurso y Persuasión',
    descripcionBreve:
        'Un buen discurso, con la métrica adecuada y tres referencias históricas, puede reescribir la realidad local. Los enemigos no mueren: se convencen de estar derrotados.',
    saborInicial:
        '"¡Camaradas! El verso libre es un oxímoron contrarrevolucionario. La métrica es disciplina. La rima es solidaridad." — Comisario Petrov-Lyrikov, discurso inaugural.',
    cuerpoBase: 5,
    menteBase: 6,
    carismaBase: 8,
    nombreHabilidadDestacada: 'Decreto de Realidad',
    descripcionHabilidadDestacada:
        'Reescribes una propiedad del entorno por 1 turno: una puerta "siempre estuvo abierta", un enemigo "nunca tuvo arma". Cuesta 4 PA.',
    nombreArmaInicial: 'Manifiesto de Bolsillo',
    danoArmaInicial: 2,
    costePaArmaInicial: 2,
    tipoDanoInicial: 'moral',
    idsHabilidadesClase: [
      'comisaria_decreto_realidad',
      'comisaria_soneto_demoledor',
      'comisaria_discurso_tedioso',
      'comisaria_cita_reglamentaria',
    ],
  ),
};
