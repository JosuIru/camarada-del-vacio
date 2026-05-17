import '../models/character.dart';

Combatiente crearFuncionarioEspectralDeArchivo() {
  return Combatiente(
    nombre: 'Funcionario Espectral de Archivo',
    esJugador: false,
    cuerpo: 0,
    mente: 4,
    carisma: 3,
    puntosVidaMaximos: 8,
    moralMaxima: 1,
    puntosAccionPorTurno: 3,
    armaduraFisica: 5,
    armaduraTecnica: 0,
    conviccion: 1,
    velocidad: 4,
  );
}

Combatiente crearCaboDelCuerpoDeInspeccion() {
  return Combatiente(
    nombre: 'Cabo del Cuerpo de Inspección',
    esJugador: false,
    cuerpo: 5,
    mente: 3,
    carisma: 3,
    puntosVidaMaximos: 14,
    moralMaxima: 8,
    puntosAccionPorTurno: 4,
    armaduraFisica: 2,
    armaduraTecnica: 1,
    conviccion: 2,
    velocidad: 5,
  );
}

/// Variante de la Brigada del Sello con garrote: el tanque del grupo.
/// Pega fuerte, encaja golpes, va lento. Cuerpo a cuerpo puro.
Combatiente crearBrigadistaSelloGarrote() {
  return Combatiente(
    nombre: 'Brigada del Sello (Garrote)',
    esJugador: false,
    cuerpo: 6,
    mente: 2,
    carisma: 2,
    puntosVidaMaximos: 16,
    moralMaxima: 9,
    puntosAccionPorTurno: 3,
    armaduraFisica: 3,
    armaduraTecnica: 1,
    conviccion: 2,
    velocidad: 4,
  );
}

/// Variante de la Brigada del Sello a puño desnudo: rápido y agresivo.
/// Menos pegada que el de garrote, pero corre más y tiene más PA.
Combatiente crearBrigadistaSelloPunos() {
  return Combatiente(
    nombre: 'Brigada del Sello (Puños)',
    esJugador: false,
    cuerpo: 4,
    mente: 2,
    carisma: 3,
    puntosVidaMaximos: 11,
    moralMaxima: 7,
    puntosAccionPorTurno: 5,
    armaduraFisica: 1,
    armaduraTecnica: 1,
    conviccion: 2,
    velocidad: 7,
  );
}

/// Variante a distancia: lleva un rifle ceremonial y sella desde lejos.
/// Frágil de cerca, peligroso a 3-6 casillas.
Combatiente crearBrigadistaSelloRifle() {
  return Combatiente(
    nombre: 'Brigada del Sello (Rifle)',
    esJugador: false,
    cuerpo: 3,
    mente: 4,
    carisma: 3,
    puntosVidaMaximos: 9,
    moralMaxima: 8,
    puntosAccionPorTurno: 4,
    armaduraFisica: 1,
    armaduraTecnica: 2,
    conviccion: 3,
    velocidad: 5,
  );
}

Combatiente crearRataMutadaDeMantenimiento() {
  return Combatiente(
    nombre: 'Rata Mutada de Mantenimiento',
    esJugador: false,
    cuerpo: 3,
    mente: 1,
    carisma: 0,
    puntosVidaMaximos: 4,
    moralMaxima: 1,
    puntosAccionPorTurno: 2,
    armaduraFisica: 0,
    armaduraTecnica: 0,
    conviccion: 0,
    velocidad: 7,
  );
}

Combatiente crearAuxiliarBurocratico() {
  return Combatiente(
    nombre: 'Auxiliar Burocrático',
    esJugador: false,
    cuerpo: 2,
    mente: 5,
    carisma: 4,
    puntosVidaMaximos: 10,
    moralMaxima: 12,
    puntosAccionPorTurno: 3,
    armaduraFisica: 1,
    armaduraTecnica: 3,
    conviccion: 3,
    velocidad: 4,
  );
}

Combatiente crearMarcianoVotante() {
  return Combatiente(
    nombre: 'Marciano Votante',
    esJugador: false,
    cuerpo: 3,
    mente: 4,
    carisma: 5,
    puntosVidaMaximos: 8,
    moralMaxima: 14,
    puntosAccionPorTurno: 3,
    armaduraFisica: 0,
    armaduraTecnica: 0,
    conviccion: 4,
    velocidad: 4,
  );
}

Combatiente crearAlcaldeProvisional() {
  return Combatiente(
    nombre: 'Alcalde Provisional de Zovnak-4',
    esJugador: false,
    cuerpo: 2,
    mente: 6,
    carisma: 8,
    puntosVidaMaximos: 12,
    moralMaxima: 18,
    puntosAccionPorTurno: 4,
    armaduraFisica: 0,
    armaduraTecnica: 1,
    conviccion: 6,
    velocidad: 3,
  );
}

Combatiente crearBurocrataCongelado() {
  return Combatiente(
    nombre: 'Burócrata Congelado',
    esJugador: false,
    cuerpo: 3,
    mente: 5,
    carisma: 3,
    puntosVidaMaximos: 10,
    moralMaxima: 12,
    puntosAccionPorTurno: 2,
    armaduraFisica: 2,
    armaduraTecnica: 1,
    conviccion: 4,
    velocidad: 2,
  );
}

Combatiente crearJefeDeRecepcionGelida() {
  return Combatiente(
    nombre: 'Jefe de Recepción de Gélida-9',
    esJugador: false,
    cuerpo: 4,
    mente: 7,
    carisma: 5,
    puntosVidaMaximos: 16,
    moralMaxima: 14,
    puntosAccionPorTurno: 3,
    armaduraFisica: 2,
    armaduraTecnica: 3,
    conviccion: 5,
    velocidad: 3,
  );
}

Combatiente crearDelegadoSindicalSolar() {
  return Combatiente(
    nombre: 'Delegado Sindical Solar',
    esJugador: false,
    cuerpo: 4,
    mente: 6,
    carisma: 7,
    puntosVidaMaximos: 14,
    moralMaxima: 16,
    puntosAccionPorTurno: 4,
    armaduraFisica: 2,
    armaduraTecnica: 4,
    conviccion: 5,
    velocidad: 4,
  );
}

Combatiente crearInspectorSindical() {
  return Combatiente(
    nombre: 'Inspector Sindical',
    esJugador: false,
    cuerpo: 5,
    mente: 5,
    carisma: 4,
    puntosVidaMaximos: 12,
    moralMaxima: 12,
    puntosAccionPorTurno: 3,
    armaduraFisica: 3,
    armaduraTecnica: 2,
    conviccion: 4,
    velocidad: 5,
  );
}

Combatiente crearEspectroDirectorskov() {
  return Combatiente(
    nombre: 'Espectro de Directorskov',
    esJugador: false,
    cuerpo: 5,
    mente: 9,
    carisma: 10,
    puntosVidaMaximos: 24,
    moralMaxima: 28,
    puntosAccionPorTurno: 5,
    armaduraFisica: 4,
    armaduraTecnica: 6,
    conviccion: 8,
    velocidad: 4,
  );
}

Combatiente crearSombraDeCosmonauta() {
  return Combatiente(
    nombre: 'Sombra de Cosmonauta',
    esJugador: false,
    cuerpo: 4,
    mente: 4,
    carisma: 3,
    puntosVidaMaximos: 12,
    moralMaxima: 8,
    puntosAccionPorTurno: 3,
    armaduraFisica: 3,
    armaduraTecnica: 1,
    conviccion: 3,
    velocidad: 4,
  );
}
