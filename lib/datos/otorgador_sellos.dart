import '../models/game_state.dart';
import 'sellos_f447.dart';

/// Helper común para que los minijuegos otorguen sellos F-447 sin
/// repetir la misma lógica (activar flag idempotente, añadir objeto
/// equipable si procede, devolver lista de sellos nuevos para UI).
///
/// La función es pura sobre [estado]: muta el flag y el inventario,
/// pero no toca nada más. Cada minijuego decide CUÁNDO llamarla
/// (al ganar, al cumplir un hito interno, al perder N veces seguidas).
class OtorgadorSellos {
  /// Otorga el sello [idSello] al cadete si todavía no lo tiene.
  /// Devuelve el sello otorgado (para mostrarlo en UI) o `null` si el
  /// sello ya estaba activo o el id no existe en el catálogo.
  static SelloF447? intentarOtorgar(EstadoJuego estado, String idSello) {
    if (estado.tieneFlag(idSello)) return null;
    final sello = selloPorId(idSello);
    if (sello == null) return null;
    estado.activarFlag(idSello);
    if (sello.idObjetoOtorgado != null) {
      estado.anadirObjeto(sello.idObjetoOtorgado!);
    }
    return sello;
  }

  /// Versión por lote: intenta otorgar varios sellos y devuelve solo
  /// los que se otorgaron por primera vez (los que ya estaban se
  /// descartan). Útil al final de partida cuando hay varios sellos
  /// candidatos (victoria, recolector total, sin morir...).
  static List<SelloF447> otorgarLote(
      EstadoJuego estado, List<String> idsSello) {
    final nuevos = <SelloF447>[];
    for (final id in idsSello) {
      final s = intentarOtorgar(estado, id);
      if (s != null) nuevos.add(s);
    }
    return nuevos;
  }
}
