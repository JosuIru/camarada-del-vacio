import '../models/game_state.dart';
import 'free_scene.dart';

/// Flag de partida que marca que Laika ha sido adoptada en la
/// cantina. Hasta que el cadete no la encuentre y la adopte, la
/// mascota no aparece en ningún escenario.
const String flagLaikaAdoptada = 'mascota_laika_adoptada';

/// Devuelve la configuración de la mascota Laika si está disponible
/// para acompañar al cadete en el escenario actual, o `null` si no
/// procede. Hay tres requisitos:
///
/// 1. El cadete tiene que haber adoptado a Laika ([flagLaikaAdoptada]).
/// 2. El escenario lo permite explícitamente (no en sitios donde
///    rompería el tono — combates de cripta, sarcófago, etc.).
/// 3. Tirada determinista basada en la semilla del escenario y el
///    contador de visitas: a veces aparece, a veces no, para que se
///    sienta como una mascota que tiene su propia vida.
ConfiguracionMascota? mascotaLaikaSiProcede(
  EstadoJuego estado, {
  required String identificadorEscenario,
  bool forzar = false,
  List<String>? frasesEspecificas,
}) {
  if (!estado.tieneFlag(flagLaikaAdoptada)) return null;
  if (!forzar) {
    // Tirada cosmética determinista para que Laika no aparezca en
    // TODAS las visitas a TODOS los escenarios — sólo a veces.
    // Combinamos (id + revisita) como semilla. Resultado estable
    // dentro de la misma visita pero variable entre escenarios.
    final int marcaRevisita = estado.esRevisita(identificadorEscenario) ? 1 : 0;
    final int hash =
        (identificadorEscenario.hashCode + marcaRevisita * 31) & 0xFFFF;
    if ((hash % 10) >= 7) return null;
  }
  return ConfiguracionMascota(
    nombre: 'LAIKA',
    altoRelativo: 0.07,
    frases: frasesEspecificas ??
        const <String>[
          'Guau, camarada.',
          'Anota el F-447.',
          'Esto huele a comité.',
          'Por aquí, ¡rápido!',
          'Bola, bola.',
          'El Inspector se acerca.',
          'Olfateo papel viejo.',
        ],
  );
}
