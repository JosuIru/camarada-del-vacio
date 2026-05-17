enum TipoDano { fisico, tecnico, moral, ninguno }

enum CategoriaAccion {
  ataqueArmaBasico,
  ataqueArmaEspecial,
  habilidadClase,
  utilidad,
  esperar,
  moverse,
}

enum TipoTargeting {
  ningunObjetivo,
  enemigoUnico,
  casillaLibre,
  cualquierCasilla,
}

class AccionCombate {
  final String identificador;
  final String nombre;
  final String descripcion;
  final int costePuntosAccion;
  final CategoriaAccion categoria;
  final TipoTargeting targeting;
  final TipoDano tipoDano;
  final int danoBase;
  final int alcanceMinimo;
  final int alcanceMaximo;
  final int radioArea;
  final bool requiereLineaDeVision;
  final int curaPuntosVidaPropios;
  final int curaMoralPropia;
  final int penalizacionPaEnemigo;
  final int turnosPenalizacionPaEnemigo;
  final bool ignoraArmaduraFisica;
  final bool ignoraConviccion;
  final bool aplicaMojar;
  final int usosPorCombate;

  const AccionCombate({
    required this.identificador,
    required this.nombre,
    required this.descripcion,
    required this.costePuntosAccion,
    required this.categoria,
    this.targeting = TipoTargeting.enemigoUnico,
    this.tipoDano = TipoDano.ninguno,
    this.danoBase = 0,
    this.alcanceMinimo = 1,
    this.alcanceMaximo = 1,
    this.radioArea = 0,
    this.requiereLineaDeVision = false,
    this.curaPuntosVidaPropios = 0,
    this.curaMoralPropia = 0,
    this.penalizacionPaEnemigo = 0,
    this.turnosPenalizacionPaEnemigo = 0,
    this.ignoraArmaduraFisica = false,
    this.ignoraConviccion = false,
    this.aplicaMojar = false,
    this.usosPorCombate = -1,
  });
}
