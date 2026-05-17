import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../theme.dart';
import '../utilities/persistencia_partida.dart';
import 'propaganda_button.dart';

/// Muestra el diálogo de guardado manual. Permite sobrescribir el slot
/// principal con el estado actual y reporta éxito o fallo. También expone
/// la acción de borrar todas las partidas guardadas (con confirmación).
Future<void> mostrarDialogoGuardarPartida(
  BuildContext contextoAnclaje, {
  required EstadoJuego estadoActual,
}) async {
  await showDialog(
    context: contextoAnclaje,
    barrierDismissible: true,
    builder: (contextoDialogo) {
      return _DialogoGuardarPartida(estadoActual: estadoActual);
    },
  );
}

class _DialogoGuardarPartida extends StatefulWidget {
  final EstadoJuego estadoActual;
  const _DialogoGuardarPartida({required this.estadoActual});

  @override
  State<_DialogoGuardarPartida> createState() => _DialogoGuardarPartidaState();
}

class _DialogoGuardarPartidaState extends State<_DialogoGuardarPartida> {
  bool _estaProcesando = false;
  String? _mensajeFeedback;
  bool _operacionExitosa = false;

  Future<void> _guardarSlotPrincipal() async {
    if (_estaProcesando) return;
    setState(() {
      _estaProcesando = true;
      _mensajeFeedback = null;
    });
    final guardadoCorrecto =
        await persistenciaPartida.guardarPartida(widget.estadoActual);
    if (!mounted) return;
    setState(() {
      _estaProcesando = false;
      _operacionExitosa = guardadoCorrecto;
      _mensajeFeedback = guardadoCorrecto
          ? 'Expediente sellado. El archivero asiente con desgana.'
          : 'El archivero rompe el sello. Reintente, camarada.';
    });
  }

  Future<void> _borrarPartidasGuardadas() async {
    if (_estaProcesando) return;
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (contextoConfirmacion) => AlertDialog(
        backgroundColor: PaletaCosmoSovietica.papelViejo,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: PaletaCosmoSovietica.rojoOficial,
            width: 3,
          ),
        ),
        title: const Text(
          'DESTRUIR EXPEDIENTE',
          style: TipografiaPropaganda.etiquetaBurocratica,
        ),
        content: const Text(
          'Esto incinera todas las partidas guardadas. El acto es irreversible y será anotado en su hoja de servicio.',
          style: TipografiaPropaganda.cuerpoLargo,
        ),
        actions: [
          BotonPropaganda(
            texto: 'Cancelar',
            compacto: true,
            onPressed: () => Navigator.of(contextoConfirmacion).pop(false),
          ),
          BotonPropaganda(
            texto: 'Incinerar',
            destacado: true,
            compacto: true,
            onPressed: () => Navigator.of(contextoConfirmacion).pop(true),
          ),
        ],
      ),
    );
    if (confirmacion != true) return;
    if (!mounted) return;
    setState(() => _estaProcesando = true);
    await persistenciaPartida.borrarTodasLasPartidas();
    if (!mounted) return;
    setState(() {
      _estaProcesando = false;
      _operacionExitosa = true;
      _mensajeFeedback =
          'Todos los expedientes han sido incinerados. La memoria del Estado es limpia.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: PaletaCosmoSovietica.papelViejo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(
          color: PaletaCosmoSovietica.tintaNegra,
          width: 3,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ARCHIVERO CENTRAL · F-447/12',
                style: TipografiaPropaganda.etiquetaBurocratica,
              ),
              const SizedBox(height: 8),
              const Divider(
                color: PaletaCosmoSovietica.tintaNegra,
                thickness: 1.4,
              ),
              const SizedBox(height: 12),
              const Text(
                'El Estado conserva su progreso. Selle el expediente principal para preservar la partida actual.',
                style: TipografiaPropaganda.cuerpoLargo,
              ),
              const SizedBox(height: 14),
              _filaResumenEstado(
                'Cadete',
                widget.estadoActual.personaje.nombre,
              ),
              _filaResumenEstado(
                'Nivel',
                widget.estadoActual.nivelCadete.toString(),
              ),
              _filaResumenEstado(
                'Último módulo',
                widget.estadoActual.ultimoModuloVisitado,
              ),
              _filaResumenEstado(
                'Cuota burocrática',
                (widget.estadoActual.cuotaBurocratica >= 0 ? '+' : '') +
                    widget.estadoActual.cuotaBurocratica.toString(),
              ),
              if (_mensajeFeedback != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _operacionExitosa
                        ? PaletaCosmoSovietica.papelSombra
                        : PaletaCosmoSovietica.papelViejo,
                    border: Border.all(
                      color: _operacionExitosa
                          ? PaletaCosmoSovietica.tintaNegra
                          : PaletaCosmoSovietica.rojoOficial,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _mensajeFeedback!,
                    style: TipografiaPropaganda.cuerpoLargo.copyWith(
                      color: _operacionExitosa
                          ? PaletaCosmoSovietica.tintaNegra
                          : PaletaCosmoSovietica.rojoOficial,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BotonPropaganda(
                    texto: 'Incinerar partidas',
                    compacto: true,
                    onPressed: _estaProcesando ? null : _borrarPartidasGuardadas,
                  ),
                  Row(
                    children: [
                      BotonPropaganda(
                        texto: 'Cerrar',
                        compacto: true,
                        onPressed: _estaProcesando
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      BotonPropaganda(
                        texto: _estaProcesando
                            ? 'Sellando…'
                            : 'Sellar expediente',
                        destacado: true,
                        compacto: true,
                        onPressed:
                            _estaProcesando ? null : _guardarSlotPrincipal,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaResumenEstado(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              etiqueta.toUpperCase(),
              style: TipografiaPropaganda.etiquetaBurocratica,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TipografiaPropaganda.cuerpoLargo,
            ),
          ),
        ],
      ),
    );
  }
}
