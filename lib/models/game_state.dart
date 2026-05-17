import 'character.dart';

class EstadoJuego {
  final Combatiente personaje;
  final Set<String> flagsActivos;
  final Map<String, int> inventario;
  final Map<String, int> buffsActivosPorTurnos;
  int cuotaBurocratica;
  String ultimoModuloVisitado;
  int experienciaAcumulada;
  int nivelCadete;
  String? idObjetoCabezaEquipado;
  String? idObjetoArmaEquipada;
  String? idObjetoTorsoEquipado;
  bool companeroFerruginosaActivo;
  final Set<String> salasVisitadasUnaVez;

  EstadoJuego({
    required this.personaje,
    Set<String>? flagsActivos,
    Map<String, int>? inventario,
    Map<String, int>? buffsActivos,
    this.cuotaBurocratica = 0,
    this.ultimoModuloVisitado = 'capsula',
    this.experienciaAcumulada = 0,
    this.nivelCadete = 1,
    this.idObjetoCabezaEquipado,
    this.idObjetoArmaEquipada,
    this.idObjetoTorsoEquipado,
    this.companeroFerruginosaActivo = false,
    Set<String>? salasVisitadasUnaVez,
  })  : flagsActivos = flagsActivos ?? <String>{},
        inventario = inventario ?? <String, int>{},
        buffsActivosPorTurnos = buffsActivos ?? <String, int>{},
        salasVisitadasUnaVez = salasVisitadasUnaVez ?? <String>{};

  bool tieneFlag(String flag) => flagsActivos.contains(flag);

  void activarFlag(String flag) {
    flagsActivos.add(flag);
  }

  void desactivarFlag(String flag) {
    flagsActivos.remove(flag);
  }

  void modificarCuota(int delta) {
    cuotaBurocratica += delta;
  }

  void anadirObjeto(String idObjeto, [int cantidad = 1]) {
    inventario[idObjeto] = (inventario[idObjeto] ?? 0) + cantidad;
  }

  bool consumirObjeto(String idObjeto, [int cantidad = 1]) {
    final cantidadActual = inventario[idObjeto] ?? 0;
    if (cantidadActual < cantidad) return false;
    final restante = cantidadActual - cantidad;
    if (restante <= 0) {
      inventario.remove(idObjeto);
    } else {
      inventario[idObjeto] = restante;
    }
    return true;
  }

  int contarObjeto(String idObjeto) => inventario[idObjeto] ?? 0;

  String? identificadorEquipoEnSlot(int indiceSlot) {
    switch (indiceSlot) {
      case 0:
        return idObjetoCabezaEquipado;
      case 1:
        return idObjetoArmaEquipada;
      case 2:
        return idObjetoTorsoEquipado;
      default:
        return null;
    }
  }

  void equiparEnSlot(int indiceSlot, String? identificadorEquipo) {
    switch (indiceSlot) {
      case 0:
        idObjetoCabezaEquipado = identificadorEquipo;
        break;
      case 1:
        idObjetoArmaEquipada = identificadorEquipo;
        break;
      case 2:
        idObjetoTorsoEquipado = identificadorEquipo;
        break;
    }
  }

  void registrarVisitaModulo(String identificadorModulo) {
    ultimoModuloVisitado = identificadorModulo;
    salasVisitadasUnaVez.add(identificadorModulo);
  }

  bool esRevisita(String identificadorModulo) =>
      salasVisitadasUnaVez.contains(identificadorModulo);

  int get xpParaSiguienteNivel => 4 + nivelCadete * 4;

  bool puedeSubirDeNivel() => experienciaAcumulada >= xpParaSiguienteNivel;

  void otorgarExperiencia(int cantidad) {
    experienciaAcumulada += cantidad;
  }

  void consumirXpParaSubirNivel() {
    final umbral = xpParaSiguienteNivel;
    experienciaAcumulada =
        (experienciaAcumulada - umbral).clamp(0, 9999);
    nivelCadete += 1;
  }
}
