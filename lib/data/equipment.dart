enum SlotEquipo { cabeza, arma, torso }

class ObjetoEquipable {
  final String identificador;
  final String nombre;
  final String descripcion;
  final SlotEquipo slot;
  final int bonusCuerpo;
  final int bonusMente;
  final int bonusCarisma;
  final int bonusArmaduraFisica;
  final int bonusConviccion;
  final int bonusPaInicialCombate;

  const ObjetoEquipable({
    required this.identificador,
    required this.nombre,
    required this.descripcion,
    required this.slot,
    this.bonusCuerpo = 0,
    this.bonusMente = 0,
    this.bonusCarisma = 0,
    this.bonusArmaduraFisica = 0,
    this.bonusConviccion = 0,
    this.bonusPaInicialCombate = 0,
  });
}

const Map<String, ObjetoEquipable> catalogoEquipo = {
  'gorra_cosmonauta': ObjetoEquipable(
    identificador: 'gorra_cosmonauta',
    nombre: 'Gorra de Cosmonauta Honorario',
    descripcion:
        'Gorra reglamentaria con estrella roja. +1 Carisma y +1 Convicción al portarla.',
    slot: SlotEquipo.cabeza,
    bonusCarisma: 1,
    bonusConviccion: 1,
  ),
  'ushanka_termica': ObjetoEquipable(
    identificador: 'ushanka_termica',
    nombre: 'Ushanka Térmica',
    descripcion:
        'Gorro de piel con orejeras forradas. +1 Armadura Física y +1 PA inicial en combate.',
    slot: SlotEquipo.cabeza,
    bonusArmaduraFisica: 1,
    bonusPaInicialCombate: 1,
  ),
  'casco_ingeniera': ObjetoEquipable(
    identificador: 'casco_ingeniera',
    nombre: 'Casco de Soldadura Plegable',
    descripcion:
        'Visera levantable, manchada de chispas. +1 Mente y +1 Armadura Física.',
    slot: SlotEquipo.cabeza,
    bonusMente: 1,
    bonusArmaduraFisica: 1,
  ),
  'arma_llave_inglesa': ObjetoEquipable(
    identificador: 'arma_llave_inglesa',
    nombre: 'Llave Inglesa Reglamentaria',
    descripcion:
        'Herramienta soviética de doble propósito. +1 Cuerpo en combate.',
    slot: SlotEquipo.arma,
    bonusCuerpo: 1,
  ),
  'arma_remache_neumatico': ObjetoEquipable(
    identificador: 'arma_remache_neumatico',
    nombre: 'Pistola de Remaches',
    descripcion:
        'Mantenimiento aprobado. +2 Cuerpo en combate, ruido considerable.',
    slot: SlotEquipo.arma,
    bonusCuerpo: 2,
  ),
  'arma_libreta_decretos': ObjetoEquipable(
    identificador: 'arma_libreta_decretos',
    nombre: 'Libreta de Decretos Provisionales',
    descripcion:
        'Cada hoja un decreto. +1 Mente, +1 Carisma para discursos demoledores.',
    slot: SlotEquipo.arma,
    bonusMente: 1,
    bonusCarisma: 1,
  ),
  'torso_chaleco_reforzado': ObjetoEquipable(
    identificador: 'torso_chaleco_reforzado',
    nombre: 'Chaleco Reforzado de Acolchados',
    descripcion:
        'Tres capas de manta militar y dos formularios doblados. +2 Armadura Física.',
    slot: SlotEquipo.torso,
    bonusArmaduraFisica: 2,
  ),
  'torso_capote_oficial': ObjetoEquipable(
    identificador: 'torso_capote_oficial',
    nombre: 'Capote Oficial con Galones',
    descripcion:
        'Lana pesada con galones rojos. +1 Convicción y +1 Carisma.',
    slot: SlotEquipo.torso,
    bonusConviccion: 1,
    bonusCarisma: 1,
  ),
};

ObjetoEquipable? obtenerEquipoPorIdentificador(String? identificador) {
  if (identificador == null) return null;
  return catalogoEquipo[identificador];
}
