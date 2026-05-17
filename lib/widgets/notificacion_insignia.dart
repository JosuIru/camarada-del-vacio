import 'package:flutter/material.dart';
import '../data/insignias_secretas.dart';
import '../models/game_state.dart';
import '../theme.dart';
import '../utilities/audio_procedural.dart';

/// Muestra una notificación tipo "toast" en la esquina inferior derecha
/// cuando el cadete desbloquea una insignia secreta. Es no bloqueante: el
/// cadete puede seguir jugando mientras el panel se desvanece.
void mostrarNotificacionInsignia(
  BuildContext contextoAnclaje, {
  required InsigniaSecretaInfo insignia,
}) {
  final overlay = Overlay.maybeOf(contextoAnclaje);
  if (overlay == null) return;
  final entrada = OverlayEntry(
    builder: (_) => _PanelNotificacionInsignia(insignia: insignia),
  );
  overlay.insert(entrada);
  Future<void>.delayed(const Duration(milliseconds: 4200), () {
    if (entrada.mounted) entrada.remove();
  });
}

/// Helper canónico: activa el flag, reproduce SFX y muestra la notificación
/// sólo si la insignia aún no estaba desbloqueada (idempotente).
void desbloquearInsigniaSiNueva(
  BuildContext contextoAnclaje, {
  required EstadoJuego estado,
  required String identificadorFlag,
}) {
  if (estado.tieneFlag(identificadorFlag)) return;
  final coincidencia = catalogoInsigniasSecretas.firstWhere(
    (insigniaCandidata) =>
        insigniaCandidata.identificadorFlag == identificadorFlag,
    orElse: () => const InsigniaSecretaInfo(
      identificadorFlag: '',
      nombreOficial: '',
      motivoBurocratico: '',
      pictograma: '',
    ),
  );
  if (coincidencia.identificadorFlag.isEmpty) return;
  estado.activarFlag(identificadorFlag);
  audioProcedural.reproducirSubidaDeNivel();
  mostrarNotificacionInsignia(contextoAnclaje, insignia: coincidencia);
}

class _PanelNotificacionInsignia extends StatefulWidget {
  final InsigniaSecretaInfo insignia;

  const _PanelNotificacionInsignia({required this.insignia});

  @override
  State<_PanelNotificacionInsignia> createState() =>
      _PanelNotificacionInsigniaState();
}

class _PanelNotificacionInsigniaState
    extends State<_PanelNotificacionInsignia>
    with SingleTickerProviderStateMixin {
  late AnimationController controladorDeslizamiento;

  @override
  void initState() {
    super.initState();
    controladorDeslizamiento = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    controladorDeslizamiento.forward();
    Future<void>.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) controladorDeslizamiento.reverse();
    });
  }

  @override
  void dispose() {
    controladorDeslizamiento.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 24,
      bottom: 24,
      child: AnimatedBuilder(
        animation: controladorDeslizamiento,
        builder: (contexto, hijo) {
          final progresoEntrada = Curves.easeOutCubic
              .transform(controladorDeslizamiento.value);
          return Opacity(
            opacity: progresoEntrada,
            child: Transform.translate(
              offset: Offset(40 * (1 - progresoEntrada), 0),
              child: hijo,
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PaletaCosmoSovietica.papelViejo,
                border: Border.all(
                  color: PaletaCosmoSovietica.rojoOficial,
                  width: 2.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: PaletaCosmoSovietica.tintaNegra,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.insignia.rutaIconoPng != null
                          ? PaletaCosmoSovietica.papelViejo
                          : PaletaCosmoSovietica.rojoOficial,
                      border: Border.all(
                        color: PaletaCosmoSovietica.tintaNegra,
                        width: 2,
                      ),
                    ),
                    child: widget.insignia.rutaIconoPng != null
                        ? Padding(
                            padding: const EdgeInsets.all(2),
                            child: Image.asset(
                              widget.insignia.rutaIconoPng!,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          )
                        : Text(
                            widget.insignia.pictograma,
                            style: const TextStyle(
                              color: PaletaCosmoSovietica.papelViejo,
                              fontFamily: 'CosmoSerif',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'INSIGNIA CONCEDIDA',
                          style: TipografiaPropaganda.etiquetaBurocratica,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.insignia.nombreOficial,
                          style: TipografiaPropaganda.tituloSeccion
                              .copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.insignia.motivoBurocratico,
                          style: TipografiaPropaganda.cuerpoLargo
                              .copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
