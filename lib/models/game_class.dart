enum ClaseCosmonauta {
  gimnasta,
  ingeniera,
  comisaria,
}

extension ClaseCosmonautaEtiqueta on ClaseCosmonauta {
  String get etiquetaCanonica {
    switch (this) {
      case ClaseCosmonauta.gimnasta:
        return 'Cosmonauta de Gimnasia';
      case ClaseCosmonauta.ingeniera:
        return 'Ingeniera de Cinta Adhesiva';
      case ClaseCosmonauta.comisaria:
        return 'Comisario Poeta';
    }
  }

  String get etiquetaCorta {
    switch (this) {
      case ClaseCosmonauta.gimnasta:
        return 'Cosmonauta';
      case ClaseCosmonauta.ingeniera:
        return 'Ingeniera';
      case ClaseCosmonauta.comisaria:
        return 'Comisario';
    }
  }
}

class DefinicionClase {
  final ClaseCosmonauta identificador;
  final String nombreCompleto;
  final String subtitulo;
  final String descripcionBreve;
  final String saborInicial;
  final int cuerpoBase;
  final int menteBase;
  final int carismaBase;
  final String nombreHabilidadDestacada;
  final String descripcionHabilidadDestacada;
  final String nombreArmaInicial;
  final int danoArmaInicial;
  final int costePaArmaInicial;
  final String tipoDanoInicial;
  final List<String> idsHabilidadesClase;

  const DefinicionClase({
    required this.identificador,
    required this.nombreCompleto,
    required this.subtitulo,
    required this.descripcionBreve,
    required this.saborInicial,
    required this.cuerpoBase,
    required this.menteBase,
    required this.carismaBase,
    required this.nombreHabilidadDestacada,
    required this.descripcionHabilidadDestacada,
    required this.nombreArmaInicial,
    required this.danoArmaInicial,
    required this.costePaArmaInicial,
    required this.tipoDanoInicial,
    required this.idsHabilidadesClase,
  });

  int get puntosVidaMaximos => 20 + (cuerpoBase * 2);
  int get moralMaxima => 10 + (carismaBase * 1.5).floor();
}
