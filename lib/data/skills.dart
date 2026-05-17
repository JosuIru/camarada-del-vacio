import '../models/combat_action.dart';

const Map<String, AccionCombate> catalogoHabilidades = {
  'gimnasta_salto_mortal': AccionCombate(
    identificador: 'gimnasta_salto_mortal',
    nombre: 'Salto Mortal Patriótico',
    descripcion:
        'Acrobacia explosiva: saltas hasta 3 casillas y golpeas al enemigo objetivo. Ignora armadura física.',
    costePuntosAccion: 3,
    categoria: CategoriaAccion.habilidadClase,
    targeting: TipoTargeting.enemigoUnico,
    tipoDano: TipoDano.fisico,
    danoBase: 6,
    alcanceMinimo: 1,
    alcanceMaximo: 3,
    ignoraArmaduraFisica: true,
  ),
  'gimnasta_calistenia': AccionCombate(
    identificador: 'gimnasta_calistenia',
    nombre: 'Calistenia Intimidante',
    descripcion:
        'Rutina física frente al rival. Daño moral en el área inmediata, enemigos cercanos pierden 1 PA.',
    costePuntosAccion: 2,
    categoria: CategoriaAccion.habilidadClase,
    targeting: TipoTargeting.cualquierCasilla,
    tipoDano: TipoDano.moral,
    danoBase: 3,
    alcanceMinimo: 1,
    alcanceMaximo: 2,
    radioArea: 1,
    penalizacionPaEnemigo: 1,
    turnosPenalizacionPaEnemigo: 1,
  ),
  'gimnasta_pulso_cardiovascular': AccionCombate(
    identificador: 'gimnasta_pulso_cardiovascular',
    nombre: 'Pulso Cardiovascular',
    descripcion:
        'Respiras profundamente. Curas 4 PV. Acción sobre ti mismo.',
    costePuntosAccion: 2,
    categoria: CategoriaAccion.habilidadClase,
    targeting: TipoTargeting.ningunObjetivo,
    curaPuntosVidaPropios: 4,
  ),
  'gimnasta_patada_olimpica': AccionCombate(
    identificador: 'gimnasta_patada_olimpica',
    nombre: 'Patada Olímpica',
    descripcion:
        'Patada giratoria. Daño físico fuerte cuerpo a cuerpo + enemigo pierde 1 PA.',
    costePuntosAccion: 3,
    categoria: CategoriaAccion.habilidadClase,
    targeting: TipoTargeting.enemigoUnico,
    tipoDano: TipoDano.fisico,
    danoBase: 5,
    alcanceMinimo: 1,
    alcanceMaximo: 1,
    penalizacionPaEnemigo: 1,
    turnosPenalizacionPaEnemigo: 1,
  ),

  'ingeniera_sabotaje': AccionCombate(
    identificador: 'ingeniera_sabotaje',
    nombre: 'Sabotaje Quinquenal',
    descripcion:
        'Inutilizas un sistema enemigo a media distancia. Daño técnico, −2 PA durante 2 turnos.',
    costePuntosAccion: 4,
    categoria: CategoriaAccion.habilidadClase,
    targeting: TipoTargeting.enemigoUnico,
    tipoDano: TipoDano.tecnico,
    danoBase: 3,
    alcanceMinimo: 1,
    alcanceMaximo: 4,
    penalizacionPaEnemigo: 2,
    turnosPenalizacionPaEnemigo: 2,
  ),
  'ingeniera_parche_urgencia': AccionCombate(
    identificador: 'ingeniera_parche_urgencia',
    nombre: 'Parche de Urgencia',
    descripcion:
        'Te recompones con cinta y dos cables. +5 PV y +2 Moral.',
    costePuntosAccion: 2,
    categoria: CategoriaAccion.habilidadClase,
    targeting: TipoTargeting.ningunObjetivo,
    curaPuntosVidaPropios: 5,
    curaMoralPropia: 2,
  ),
  'ingeniera_caja_inversa': AccionCombate(
    identificador: 'ingeniera_caja_inversa',
    nombre: 'Caja de Herramientas Inversa',
    descripcion:
        'La herramienta exacta para destruirlo. Daño técnico alto cuerpo a cuerpo, ignora armadura.',
    costePuntosAccion: 3,
    categoria: CategoriaAccion.habilidadClase,
    targeting: TipoTargeting.enemigoUnico,
    tipoDano: TipoDano.tecnico,
    danoBase: 6,
    alcanceMinimo: 1,
    alcanceMaximo: 1,
    ignoraArmaduraFisica: true,
  ),
  'ingeniera_cinta_inmovilizante': AccionCombate(
    identificador: 'ingeniera_cinta_inmovilizante',
    nombre: 'Cinta Inmovilizante',
    descripcion:
        'Enroscas al enemigo en cinta de aluminio. Cuerpo a cuerpo. Pierde 3 PA el próximo turno.',
    costePuntosAccion: 2,
    categoria: CategoriaAccion.habilidadClase,
    targeting: TipoTargeting.enemigoUnico,
    tipoDano: TipoDano.tecnico,
    danoBase: 1,
    alcanceMinimo: 1,
    alcanceMaximo: 1,
    penalizacionPaEnemigo: 3,
    turnosPenalizacionPaEnemigo: 1,
  ),

  'comisaria_decreto_realidad': AccionCombate(
    identificador: 'comisaria_decreto_realidad',
    nombre: 'Decreto de Realidad',
    descripcion:
        'Declaras al enemigo anticonstitucional. Daño moral devastador a cualquier distancia. Ignora convicción.',
    costePuntosAccion: 4,
    categoria: CategoriaAccion.habilidadClase,
    targeting: TipoTargeting.enemigoUnico,
    tipoDano: TipoDano.moral,
    danoBase: 8,
    alcanceMinimo: 1,
    alcanceMaximo: 99,
    ignoraConviccion: true,
  ),
  'comisaria_soneto_demoledor': AccionCombate(
    identificador: 'comisaria_soneto_demoledor',
    nombre: 'Soneto Demoledor',
    descripcion:
        'Catorce versos endecasílabos. Daño moral sostenido a media distancia.',
    costePuntosAccion: 3,
    categoria: CategoriaAccion.habilidadClase,
    targeting: TipoTargeting.enemigoUnico,
    tipoDano: TipoDano.moral,
    danoBase: 5,
    alcanceMinimo: 1,
    alcanceMaximo: 5,
  ),
  'comisaria_discurso_tedioso': AccionCombate(
    identificador: 'comisaria_discurso_tedioso',
    nombre: 'Discurso Tedioso',
    descripcion:
        'Recitas el Plan Quinquenal a varios enemigos. Daño moral leve en área, −1 PA por 2 turnos.',
    costePuntosAccion: 2,
    categoria: CategoriaAccion.habilidadClase,
    targeting: TipoTargeting.cualquierCasilla,
    tipoDano: TipoDano.moral,
    danoBase: 2,
    alcanceMinimo: 1,
    alcanceMaximo: 4,
    radioArea: 1,
    penalizacionPaEnemigo: 1,
    turnosPenalizacionPaEnemigo: 2,
  ),
  'comisaria_cita_reglamentaria': AccionCombate(
    identificador: 'comisaria_cita_reglamentaria',
    nombre: 'Auto-Cita Reglamentaria',
    descripcion:
        'Te citas a ti mismo: daño moral a un enemigo a distancia + recuperas 3 Moral propia.',
    costePuntosAccion: 3,
    categoria: CategoriaAccion.habilidadClase,
    targeting: TipoTargeting.enemigoUnico,
    tipoDano: TipoDano.moral,
    danoBase: 4,
    alcanceMinimo: 1,
    alcanceMaximo: 4,
    curaMoralPropia: 3,
  ),
};

const Map<String, List<String>> habilidadesPorClase = {
  'gimnasta': [
    'gimnasta_salto_mortal',
    'gimnasta_calistenia',
    'gimnasta_pulso_cardiovascular',
    'gimnasta_patada_olimpica',
  ],
  'ingeniera': [
    'ingeniera_sabotaje',
    'ingeniera_parche_urgencia',
    'ingeniera_caja_inversa',
    'ingeniera_cinta_inmovilizante',
  ],
  'comisaria': [
    'comisaria_decreto_realidad',
    'comisaria_soneto_demoledor',
    'comisaria_discurso_tedioso',
    'comisaria_cita_reglamentaria',
  ],
};

const AccionCombate utilidadSamovarPortatil = AccionCombate(
  identificador: 'samovar_portatil',
  nombre: 'Arrojar samovar',
  descripcion:
      'Lanzas un samovar con agua hirviendo. Moja al objetivo y a los enemigos en 1 casilla a la redonda.',
  costePuntosAccion: 2,
  categoria: CategoriaAccion.utilidad,
  targeting: TipoTargeting.cualquierCasilla,
  tipoDano: TipoDano.fisico,
  danoBase: 1,
  alcanceMinimo: 1,
  alcanceMaximo: 4,
  radioArea: 1,
  aplicaMojar: true,
  usosPorCombate: 1,
);

const AccionCombate utilidadEsperar = AccionCombate(
  identificador: 'esperar_meditar',
  nombre: 'Esperar y meditar',
  descripcion: 'Pasa el turno. Recuperas 2 PA y 2 Moral.',
  costePuntosAccion: 0,
  categoria: CategoriaAccion.esperar,
  targeting: TipoTargeting.ningunObjetivo,
  curaMoralPropia: 2,
);

const AccionCombate accionMoverse = AccionCombate(
  identificador: 'moverse',
  nombre: 'Mover',
  descripcion:
      'Te desplazas a una casilla libre. Cuesta 1 PA por casilla movida.',
  costePuntosAccion: 1,
  categoria: CategoriaAccion.moverse,
  targeting: TipoTargeting.casillaLibre,
  alcanceMinimo: 1,
  alcanceMaximo: 4,
);

const AccionCombate accionAtaqueBasicoMelee = AccionCombate(
  identificador: 'ataque_basico_melee',
  nombre: 'Ataque básico (cuerpo a cuerpo)',
  descripcion:
      'Atacas con tu arma a un enemigo adyacente. No cuesta PA. Daño según arma y tu Cuerpo.',
  costePuntosAccion: 0,
  categoria: CategoriaAccion.ataqueArmaBasico,
  targeting: TipoTargeting.enemigoUnico,
  tipoDano: TipoDano.fisico,
  danoBase: 3,
  alcanceMinimo: 1,
  alcanceMaximo: 1,
);

/// Habilidad disponible sólo si el cadete ha adoptado a Laika en la
/// cantina. Cuesta 2 PA, alcance 3 casillas (la gata salta), daño
/// físico moderado, una vez por combate. La idea narrativa: Laika
/// sale del bolsillo y muerde el tobillo del enemigo señalado.
const AccionCombate accionLaikaMordisco = AccionCombate(
  identificador: 'laika_mordisco',
  nombre: 'Laika muerde',
  descripcion:
      'Laika salta de tu bolsillo y muerde el tobillo del enemigo. '
      'Alcance 3 casillas. Ignora armadura física (los dientes pasan '
      'entre las placas reglamentarias). Una sola vez por combate.',
  costePuntosAccion: 2,
  categoria: CategoriaAccion.utilidad,
  targeting: TipoTargeting.enemigoUnico,
  tipoDano: TipoDano.fisico,
  danoBase: 4,
  alcanceMinimo: 1,
  alcanceMaximo: 3,
  ignoraArmaduraFisica: true,
  usosPorCombate: 1,
);
