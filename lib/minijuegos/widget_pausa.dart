import 'package:flutter/material.dart';
import 'pintor_rotulador.dart';

/// Overlay de PAUSA reutilizable por todos los minijuegos con acción
/// continua (pinball, doom, invasors, platformer, dokumentris, etc.).
///
/// Se monta como un `Positioned.fill` dentro del Stack del minijuego.
/// Cuando `visible` es `false` no aparece nada; cuando `visible` es
/// `true` se muestra un fondo semi-translúcido tipo papel viejo con
/// "PAUSA" en serif italic rojo, una línea horizontal a tinta y un
/// recordatorio de la tecla para reanudar.
class OverlayPausaMinijuego extends StatelessWidget {
  final bool visible;
  final String teclaReanudar;
  final String? subtitulo;

  const OverlayPausaMinijuego({
    super.key,
    required this.visible,
    this.teclaReanudar = 'P',
    this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Positioned.fill(
      child: Container(
        // Velo de papel translúcido — deja entrever el minijuego congelado
        // detrás, refuerza la idea de que "el tiempo se detuvo".
        color: PaletaRotulador.papel.withValues(alpha: 0.86),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSA',
              style: TextStyle(
                fontFamily: 'CosmoSerif',
                fontSize: 78,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w900,
                color: PaletaRotulador.rojoEstampilla,
                letterSpacing: 8,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: 220,
              height: 2,
              color: PaletaRotulador.tinta,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: PaletaRotulador.papelSucio,
                border: Border.all(
                  color: PaletaRotulador.tinta,
                  width: 1.6,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: const BoxDecoration(
                      color: PaletaRotulador.tinta,
                    ),
                    child: Text(
                      teclaReanudar,
                      style: const TextStyle(
                        fontFamily: 'CosmoMono',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: PaletaRotulador.papel,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    subtitulo ?? 'PARA REANUDAR EL EXPEDIENTE',
                    style: const TextStyle(
                      fontFamily: 'CosmoSerif',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: PaletaRotulador.tinta,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '«El reloj del Comité se detiene cuando lo ordena»',
              style: TextStyle(
                fontFamily: 'CosmoSerif',
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: PaletaRotulador.tintaDiluida(0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
