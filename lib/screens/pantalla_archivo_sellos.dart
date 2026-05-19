import 'package:flutter/material.dart';

import '../datos/sellos_f447.dart';
import '../minijuegos/pintor_rotulador.dart';
import '../models/game_state.dart';
import '../theme.dart';
import '../widgets/propaganda_button.dart';

/// Pantalla "Archivo F-447" — expediente personal del cadete con todos
/// los sellos que ha coleccionado. Los sellos no obtenidos aparecen
/// como tarjeta TACHADA con su nombre y categoría visibles pero sin
/// descripción ni decreto (para no destripar las condiciones de
/// desbloqueo).
class PantallaArchivoSellos extends StatelessWidget {
  final EstadoJuego estado;

  const PantallaArchivoSellos({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    // Agrupar sellos por origen para mostrar por bloques temáticos.
    final Map<String, List<SelloF447>> sellosPorOrigen =
        <String, List<SelloF447>>{};
    for (final sello in catalogoSellosF447) {
      final clave = sello.idOrigen ?? 'transversales';
      sellosPorOrigen.putIfAbsent(clave, () => <SelloF447>[]).add(sello);
    }

    final int totalSellos = catalogoSellosF447.length;
    final int sellosObtenidos = catalogoSellosF447
        .where((sello) => estado.tieneFlag(sello.id))
        .length;

    return Scaffold(
      backgroundColor: PaletaCosmoSovietica.papelViejo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _construirCabecera(context, sellosObtenidos, totalSellos),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final entrada in sellosPorOrigen.entries) ...[
                        _construirCabeceraGrupo(entrada.key),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final sello in entrada.value)
                              SizedBox(
                                width: 280,
                                child: _TarjetaSelloArchivo(
                                  sello: sello,
                                  obtenido: estado.tieneFlag(sello.id),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCabecera(BuildContext context, int obtenidos, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ARCHIVO F-447 · EXPEDIENTE PERSONAL',
              style: TextStyle(
                fontFamily: 'CosmoMono',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                color: PaletaCosmoSovietica.tintaNegra,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sellos archivados: $obtenidos / $total',
              style: const TextStyle(
                fontFamily: 'CosmoSerif',
                fontSize: 13,
                color: PaletaCosmoSovietica.tintaTenue,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        BotonPropaganda(
          texto: 'Cerrar archivo',
          compacto: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _construirCabeceraGrupo(String idOrigen) {
    final etiqueta = _etiquetaOrigen(idOrigen);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: const BoxDecoration(
        color: PaletaCosmoSovietica.papelSombra,
      ),
      child: Text(
        etiqueta,
        style: const TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: PaletaCosmoSovietica.rojoOficial,
        ),
      ),
    );
  }

  String _etiquetaOrigen(String idOrigen) {
    switch (idOrigen) {
      case 'pixel_perdido':
        return 'PÍXEL PERDIDO · TUBERÍA DEL PÍXEL';
      case 'snow_kamarada':
        return 'SNOW KAMARADA · LADERA NEVADA';
      case 'dokumentris':
        return 'DOKUMENTRIS · CADENA DE TRAMITACIÓN';
      case 'frecuencia_747':
        return 'FRECUENCIA 7.47 · DIAL DE LA RAZÓN';
      case 'camarada_invasors':
        return 'CAMARADA INVASORS · BUNKER F-447';
      case 'inspektor_pacman':
        return 'INSPEKTOR PAC-MAN · LABERINTO DE PAPEL';
      case 'cosmoom_doom':
        return 'COSMOOM DOOM · PASILLOS DEL TEMPLO';
      case 'super_pang':
        return 'SUPER PANG GALÁCTICO · GLOBOS BUROCRÁTICOS';
      case 'transversales':
        return 'EXPEDIENTES TRANSVERSALES';
      default:
        return idOrigen.toUpperCase();
    }
  }
}

class _TarjetaSelloArchivo extends StatelessWidget {
  final SelloF447 sello;
  final bool obtenido;

  const _TarjetaSelloArchivo({
    required this.sello,
    required this.obtenido,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorTinta =
        obtenido ? sello.categoria.colorTinta : PaletaCosmoSovietica.tintaTenue;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: obtenido
            ? PaletaCosmoSovietica.papelViejo
            : PaletaCosmoSovietica.papelSombra,
        border: Border.all(color: colorTinta, width: 1.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  sello.tituloLargo,
                  style: TextStyle(
                    fontFamily: 'CosmoMono',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: colorTinta,
                    // Sello pendiente: tachado en línea.
                    decoration: obtenido
                        ? TextDecoration.none
                        : TextDecoration.lineThrough,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: colorTinta, width: 1.0),
                ),
                child: Text(
                  sello.categoria.etiqueta,
                  style: TextStyle(
                    fontFamily: 'CosmoMono',
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: colorTinta,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            obtenido
                ? sello.descripcionNarrativa
                : 'Sello pendiente. Las condiciones de archivo no se '
                    'comunican a los camaradas no condecorados.',
            style: TextStyle(
              fontFamily: 'CosmoSerif',
              fontSize: 11,
              color: PaletaRotulador.tinta,
              fontStyle: obtenido ? FontStyle.normal : FontStyle.italic,
              height: 1.4,
            ),
          ),
          if (obtenido) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PaletaCosmoSovietica.papelSombra,
                border: Border.all(color: colorTinta, width: 0.8),
              ),
              child: Text(
                sello.decretoComite,
                style: const TextStyle(
                  fontFamily: 'CosmoSerif',
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: PaletaCosmoSovietica.tintaNegra,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
