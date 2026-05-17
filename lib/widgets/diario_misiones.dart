import 'package:flutter/material.dart';
import '../data/insignias_secretas.dart';
import '../data/registro_misiones.dart';
import '../models/game_state.dart';
import '../theme.dart';
import 'propaganda_button.dart';

/// Diálogo modal del "Diario de Servicio · F-447 bis": muestra al cadete las
/// misiones pendientes/completadas y las pistas que ha recolectado en su
/// recorrido. Se accede desde el botón de la pantalla del Cuadrante Sigma
/// y, por accesibilidad, desde el panel lateral de cada planeta.
Future<void> mostrarDiarioMisiones(
  BuildContext contextoLlamante, {
  required EstadoJuego estado,
}) {
  return showDialog(
    context: contextoLlamante,
    barrierDismissible: true,
    builder: (contextoDialogo) => _DialogoDiarioMisiones(estado: estado),
  );
}

class _DialogoDiarioMisiones extends StatefulWidget {
  final EstadoJuego estado;

  const _DialogoDiarioMisiones({required this.estado});

  @override
  State<_DialogoDiarioMisiones> createState() =>
      _DialogoDiarioMisionesState();
}

enum _PestanaDiario { misiones, pistas, insignias }

class _DialogoDiarioMisionesState extends State<_DialogoDiarioMisiones> {
  _PestanaDiario pestanaActiva = _PestanaDiario.misiones;

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
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _construirCabecera(),
              const SizedBox(height: 6),
              const Divider(
                color: PaletaCosmoSovietica.rojoOficial,
                thickness: 1.5,
              ),
              const SizedBox(height: 12),
              _construirPestanas(),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: switch (pestanaActiva) {
                    _PestanaDiario.misiones => _construirListaMisiones(),
                    _PestanaDiario.pistas => _construirListaPistas(),
                    _PestanaDiario.insignias => _construirListaInsignias(),
                  },
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: BotonPropaganda(
                  texto: 'Archivar diario',
                  compacto: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCabecera() {
    final cantidadActivas = catalogoMisiones
        .where((mision) =>
            mision.evaluarEstado(widget.estado) == EstadoMision.activa)
        .length;
    final cantidadCompletadas = catalogoMisiones
        .where((mision) =>
            mision.evaluarEstado(widget.estado) == EstadoMision.completada)
        .length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DIARIO DE SERVICIO · F-447 BIS',
              style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
                color: PaletaCosmoSovietica.rojoOficial,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Cadete de la Pravda-12',
              style: TipografiaPropaganda.tituloSeccion,
            ),
          ],
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: PaletaCosmoSovietica.tintaNegra,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'EN CURSO: $cantidadActivas',
                style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
                  fontSize: 11,
                ),
              ),
              Text(
                'TRAMITADAS: $cantidadCompletadas',
                style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
                  fontSize: 11,
                  color: PaletaCosmoSovietica.rojoOficial,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirPestanas() {
    return Row(
      children: [
        _BotonPestana(
          etiqueta: 'EXPEDIENTES',
          activa: pestanaActiva == _PestanaDiario.misiones,
          onPressed: () =>
              setState(() => pestanaActiva = _PestanaDiario.misiones),
        ),
        const SizedBox(width: 8),
        _BotonPestana(
          etiqueta: 'PISTAS',
          activa: pestanaActiva == _PestanaDiario.pistas,
          onPressed: () =>
              setState(() => pestanaActiva = _PestanaDiario.pistas),
        ),
        const SizedBox(width: 8),
        _BotonPestana(
          etiqueta:
              'INSIGNIAS · ${cantidadInsigniasDesbloqueadas(widget.estado)}/${catalogoInsigniasSecretas.length}',
          activa: pestanaActiva == _PestanaDiario.insignias,
          onPressed: () =>
              setState(() => pestanaActiva = _PestanaDiario.insignias),
        ),
      ],
    );
  }

  Widget _construirListaInsignias() {
    final insigniasObtenidas = catalogoInsigniasSecretas
        .where((insignia) => widget.estado.tieneFlag(insignia.identificadorFlag))
        .toList();
    if (insigniasObtenidas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Ninguna insignia clandestina registrada. El Comité asume comportamiento ejemplar.\nIntenta cosas que un cadete ejemplar nunca haría.',
          textAlign: TextAlign.center,
          style: TipografiaPropaganda.subtitulo,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final insignia in insigniasObtenidas)
          _TarjetaInsignia(insignia: insignia),
        const SizedBox(height: 6),
        if (insigniasObtenidas.length < catalogoInsigniasSecretas.length)
          Text(
            'Quedan ${catalogoInsigniasSecretas.length - insigniasObtenidas.length} sin descubrir. '
            'El Estado niega oficialmente que existan.',
            style: TipografiaPropaganda.subtitulo,
          ),
      ],
    );
  }

  Widget _construirListaMisiones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final mision in catalogoMisiones)
          _TarjetaMision(
            mision: mision,
            estado: mision.evaluarEstado(widget.estado),
          ),
      ],
    );
  }

  Widget _construirListaPistas() {
    final pistasRecolectadas = catalogoPistas
        .where((pista) => widget.estado.tieneFlag(pista.identificadorFlag))
        .toList();
    if (pistasRecolectadas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'El cadete aún no ha consignado ninguna pista de campo.\n'
          'Investiga conversando con NPCs y revisando objetos sospechosos.',
          textAlign: TextAlign.center,
          style: TipografiaPropaganda.subtitulo,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final pista in pistasRecolectadas) _TarjetaPista(pista: pista),
      ],
    );
  }
}

class _BotonPestana extends StatelessWidget {
  final String etiqueta;
  final bool activa;
  final VoidCallback onPressed;

  const _BotonPestana({
    required this.etiqueta,
    required this.activa,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: activa
                ? PaletaCosmoSovietica.rojoOficial
                : PaletaCosmoSovietica.papelSombra,
            border: Border.all(
              color: PaletaCosmoSovietica.tintaNegra,
              width: 1.5,
            ),
          ),
          child: Text(
            etiqueta,
            style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
              color: activa
                  ? PaletaCosmoSovietica.papelViejo
                  : PaletaCosmoSovietica.tintaNegra,
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaMision extends StatelessWidget {
  final MisionInfo mision;
  final EstadoMision estado;

  const _TarjetaMision({
    required this.mision,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    final esBloqueada = estado == EstadoMision.bloqueada;
    final esCompletada = estado == EstadoMision.completada;
    final colorBorde = esCompletada
        ? PaletaCosmoSovietica.rojoOficial
        : esBloqueada
            ? PaletaCosmoSovietica.tintaTenue
            : PaletaCosmoSovietica.tintaNegra;
    final etiquetaEstado = esCompletada
        ? 'TRAMITADA'
        : esBloqueada
            ? 'NO ASIGNADA'
            : 'EN CURSO';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: esBloqueada
            ? PaletaCosmoSovietica.papelSombra.withValues(alpha: 0.6)
            : PaletaCosmoSovietica.papelViejo,
        border: Border.all(color: colorBorde, width: 1.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  esBloqueada ? '[ EXPEDIENTE CLASIFICADO ]' : mision.titulo,
                  style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
                    fontSize: 13,
                    color: esBloqueada
                        ? PaletaCosmoSovietica.tintaTenue
                        : PaletaCosmoSovietica.tintaNegra,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: esCompletada
                      ? PaletaCosmoSovietica.rojoOficial
                      : PaletaCosmoSovietica.papelSombra,
                  border: Border.all(
                    color: PaletaCosmoSovietica.tintaNegra,
                    width: 1,
                  ),
                ),
                child: Text(
                  etiquetaEstado,
                  style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
                    fontSize: 10,
                    color: esCompletada
                        ? PaletaCosmoSovietica.papelViejo
                        : PaletaCosmoSovietica.tintaTenue,
                  ),
                ),
              ),
            ],
          ),
          if (!esBloqueada) ...[
            const SizedBox(height: 6),
            Text(
              mision.descripcion,
              style: TipografiaPropaganda.cuerpoLargo
                  .copyWith(fontSize: 13),
            ),
            if (!esCompletada) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '→ ',
                    style: TextStyle(
                      fontFamily: TipografiaPropaganda.familiaMonoespaciada,
                      fontSize: 12,
                      color: PaletaCosmoSovietica.rojoOficial,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      mision.pistaSiguientePaso,
                      style: TipografiaPropaganda.subtitulo
                          .copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _TarjetaPista extends StatelessWidget {
  final PistaInfo pista;

  const _TarjetaPista({required this.pista});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.papelViejo,
        border: Border.all(
          color: PaletaCosmoSovietica.tintaNegra,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                color: PaletaCosmoSovietica.rojoOficial,
              ),
              Expanded(
                child: Text(
                  pista.fuente.toUpperCase(),
                  style: TipografiaPropaganda.etiquetaBurocratica.copyWith(
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '«${pista.contenido}»',
            style: TipografiaPropaganda.cuerpoLargo
                .copyWith(fontStyle: FontStyle.italic, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _TarjetaInsignia extends StatelessWidget {
  final InsigniaSecretaInfo insignia;

  const _TarjetaInsignia({required this.insignia});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PaletaCosmoSovietica.papelSombra,
        border: Border.all(
          color: PaletaCosmoSovietica.rojoOficial,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: PaletaCosmoSovietica.rojoOficial,
              border: Border.all(
                color: PaletaCosmoSovietica.tintaNegra,
                width: 1.5,
              ),
            ),
            child: Text(
              insignia.pictograma,
              style: const TextStyle(
                color: PaletaCosmoSovietica.papelViejo,
                fontFamily: 'CosmoSerif',
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insignia.nombreOficial,
                  style: TipografiaPropaganda.tituloSeccion
                      .copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  insignia.motivoBurocratico,
                  style: TipografiaPropaganda.cuerpoLargo.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
