import '../models/character.dart';

Combatiente crearMadreFerruginosaPortatil() {
  return Combatiente(
    nombre: 'Madre Ferruginosa portátil',
    esJugador: false,
    cuerpo: 3,
    mente: 5,
    carisma: 6,
    puntosVidaMaximos: 9,
    moralMaxima: 12,
    puntosAccionPorTurno: 3,
    armaduraFisica: 1,
    armaduraTecnica: 2,
    conviccion: 3,
    velocidad: 3,
  );
}
