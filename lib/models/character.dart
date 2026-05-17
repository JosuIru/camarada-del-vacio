import 'game_class.dart';

class Combatiente {
  String nombre;
  ClaseCosmonauta? clase;
  bool esJugador;

  int cuerpo;
  int mente;
  int carisma;

  int puntosVida;
  int puntosVidaMaximos;
  int moral;
  int moralMaxima;

  int puntosAccionDisponibles;
  int puntosAccionPorTurno;

  int posicionFila;
  int posicionColumna;
  int velocidad;

  int armaduraFisica;
  int armaduraTecnica;
  int conviccion;

  bool empapado;
  int turnosEmpapado;

  /// Estado «intimidado»: el orador soviético del momento ha logrado plantar
  /// inseguridad en el combatiente. Reduce su carisma efectivo en 1 mientras
  /// dure. Persiste varios turnos y decrementa con [tickEstados].
  bool intimidado;
  int turnosIntimidado;

  /// Estado «eufórico»: tras un té o un discurso especialmente vehemente,
  /// el combatiente gana +1 PA al iniciar cada turno mientras dure.
  bool euforico;
  int turnosEuforico;

  int paPenalizacionAcumulada;
  int turnosPenalizacionPaPendientes;
  int paBonusProximoTurno;

  Combatiente({
    required this.nombre,
    required this.esJugador,
    this.clase,
    required this.cuerpo,
    required this.mente,
    required this.carisma,
    required this.puntosVidaMaximos,
    required this.moralMaxima,
    this.puntosAccionPorTurno = 4,
    this.armaduraFisica = 0,
    this.armaduraTecnica = 0,
    this.conviccion = 0,
    this.empapado = false,
    this.turnosEmpapado = 0,
    this.intimidado = false,
    this.turnosIntimidado = 0,
    this.euforico = false,
    this.turnosEuforico = 0,
    this.paPenalizacionAcumulada = 0,
    this.turnosPenalizacionPaPendientes = 0,
    this.paBonusProximoTurno = 0,
    this.posicionFila = 0,
    this.posicionColumna = 0,
    this.velocidad = 5,
  })  : puntosVida = puntosVidaMaximos,
        moral = moralMaxima,
        puntosAccionDisponibles = puntosAccionPorTurno;

  int calcularAPInicialCombate() {
    return 12 + (mente / 2).floor();
  }

  int distanciaA(Combatiente otro) {
    final dx = (posicionColumna - otro.posicionColumna).abs();
    final dy = (posicionFila - otro.posicionFila).abs();
    return dx > dy ? dx : dy;
  }

  bool get sigueEnPie => puntosVida > 0 && moral > 0;
  bool get cayoFisicamente => puntosVida <= 0;
  bool get cayoMoralmente => moral <= 0;

  void reiniciarPuntosAccion() {
    final base = puntosAccionPorTurno;
    final penalizacion =
        turnosPenalizacionPaPendientes > 0 ? paPenalizacionAcumulada : 0;
    puntosAccionDisponibles =
        (base + paBonusProximoTurno - penalizacion).clamp(0, 99);
    paBonusProximoTurno = 0;
    if (turnosPenalizacionPaPendientes > 0) {
      turnosPenalizacionPaPendientes -= 1;
      if (turnosPenalizacionPaPendientes <= 0) {
        paPenalizacionAcumulada = 0;
      }
    }
  }

  void aplicarPenalizacionPa(int cantidad, int turnos) {
    paPenalizacionAcumulada += cantidad;
    if (turnos > turnosPenalizacionPaPendientes) {
      turnosPenalizacionPaPendientes = turnos;
    }
  }

  void aplicarDanoFisico(int cantidad) {
    final danoEfectivo = cantidad < 1 ? 1 : cantidad;
    puntosVida = (puntosVida - danoEfectivo).clamp(0, puntosVidaMaximos);
  }

  void aplicarDanoMoral(int cantidad) {
    final danoEfectivo = cantidad < 1 ? 1 : cantidad;
    moral = (moral - danoEfectivo).clamp(0, moralMaxima);
  }

  void curar(int cantidad) {
    puntosVida = (puntosVida + cantidad).clamp(0, puntosVidaMaximos);
  }

  void recuperarMoral(int cantidad) {
    moral = (moral + cantidad).clamp(0, moralMaxima);
  }

  void mojar() {
    empapado = true;
    turnosEmpapado = 2;
  }

  void intimidar({int turnos = 2}) {
    intimidado = true;
    if (turnos > turnosIntimidado) turnosIntimidado = turnos;
  }

  void aplicarEuforia({int turnos = 2}) {
    euforico = true;
    if (turnos > turnosEuforico) turnosEuforico = turnos;
    paBonusProximoTurno += 1;
  }

  /// Carisma "efectivo" para los cálculos de daño moral/persuasión. Resta 1
  /// si el combatiente está intimidado.
  int get carismaEfectivo => intimidado ? (carisma - 1).clamp(0, 99) : carisma;

  void tickEstados() {
    if (empapado) {
      turnosEmpapado -= 1;
      if (turnosEmpapado <= 0) {
        empapado = false;
      }
    }
    if (intimidado) {
      turnosIntimidado -= 1;
      if (turnosIntimidado <= 0) {
        intimidado = false;
      }
    }
    if (euforico) {
      turnosEuforico -= 1;
      if (turnosEuforico <= 0) {
        euforico = false;
      } else {
        paBonusProximoTurno += 1;
      }
    }
  }
}
