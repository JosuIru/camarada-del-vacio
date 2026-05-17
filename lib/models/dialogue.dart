class OpcionDialogo {
  final String texto;
  final String? idNodoDestino;
  final String? consecuenciaNarrativa;
  final bool cierraDialogo;
  final bool destacada;
  final int? requiereCuerpoMinimo;
  final int? requiereMenteMinima;
  final int? requiereCarismaMinimo;
  final String? requiereFlag;
  final String? requiereSinFlag;

  const OpcionDialogo({
    required this.texto,
    this.idNodoDestino,
    this.consecuenciaNarrativa,
    this.cierraDialogo = false,
    this.destacada = false,
    this.requiereCuerpoMinimo,
    this.requiereMenteMinima,
    this.requiereCarismaMinimo,
    this.requiereFlag,
    this.requiereSinFlag,
  });

  String? motivoBloqueoSegunRequisitos({
    required int cuerpo,
    required int mente,
    required int carisma,
    required bool Function(String) tieneFlag,
  }) {
    if (requiereCuerpoMinimo != null && cuerpo < requiereCuerpoMinimo!) {
      return 'Cuerpo $cuerpo/$requiereCuerpoMinimo';
    }
    if (requiereMenteMinima != null && mente < requiereMenteMinima!) {
      return 'Mente $mente/$requiereMenteMinima';
    }
    if (requiereCarismaMinimo != null && carisma < requiereCarismaMinimo!) {
      return 'Carisma $carisma/$requiereCarismaMinimo';
    }
    if (requiereFlag != null && !tieneFlag(requiereFlag!)) {
      return 'requiere progreso previo';
    }
    if (requiereSinFlag != null && tieneFlag(requiereSinFlag!)) {
      return 'ya descartado';
    }
    return null;
  }
}

class NodoDialogo {
  final String id;
  final String nombreEmisor;
  final String textoEnunciado;
  final String? acotacion;
  final List<OpcionDialogo> opciones;

  const NodoDialogo({
    required this.id,
    required this.nombreEmisor,
    required this.textoEnunciado,
    this.acotacion,
    required this.opciones,
  });
}

class ConversacionNpc {
  final String nombreNpc;
  final String tituloRol;
  final Map<String, NodoDialogo> nodos;
  final String idNodoInicial;

  const ConversacionNpc({
    required this.nombreNpc,
    required this.tituloRol,
    required this.nodos,
    required this.idNodoInicial,
  });

  NodoDialogo obtenerNodo(String id) {
    final nodo = nodos[id];
    if (nodo == null) {
      throw StateError('Nodo de diálogo no encontrado: $id');
    }
    return nodo;
  }
}
