import 'package:flutter/material.dart';
import '../data/classes.dart';
import '../models/character.dart';
import '../models/game_class.dart';
import '../models/game_state.dart';
import '../theme.dart';
import '../utilities/page_transitions.dart';
import '../widgets/paper_background.dart';
import '../widgets/propaganda_button.dart';
import '../widgets/sprite_clase_cadete.dart';
import 'room_screen.dart';

class PantallaSeleccionClase extends StatefulWidget {
  const PantallaSeleccionClase({super.key});

  @override
  State<PantallaSeleccionClase> createState() => _PantallaSeleccionClaseState();
}

class _PantallaSeleccionClaseState extends State<PantallaSeleccionClase> {
  ClaseCosmonauta? _seleccionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoPapelViejo(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'FORMULARIO DE ASIGNACIÓN  ·  IMPRESO 47-Б',
                  style: TipografiaPropaganda.etiquetaBurocratica,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Seleccione su especialidad cosmonáutica',
                style: TipografiaPropaganda.tituloSeccion,
              ),
              const SizedBox(height: 8),
              const SizedBox(
                width: 600,
                child: Text(
                  'La elección es vinculante y será registrada en su expediente. El Comité considera todas las clases igualmente útiles, en distintos grados.',
                  textAlign: TextAlign.center,
                  style: TipografiaPropaganda.subtitulo,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final esAncho = constraints.maxWidth > 900;
                    final tarjetas = ClaseCosmonauta.values
                        .map((c) => _TarjetaClase(
                              definicion: catalogoClases[c]!,
                              seleccionada: _seleccionada == c,
                              onTap: () =>
                                  setState(() => _seleccionada = c),
                            ))
                        .toList();
                    return esAncho
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final t in tarjetas) ...[
                                Expanded(child: t),
                                if (t != tarjetas.last)
                                  const SizedBox(width: 16),
                              ],
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                for (final t in tarjetas) ...[
                                  SizedBox(height: 360, child: t),
                                  const SizedBox(height: 16),
                                ],
                              ],
                            ),
                          );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BotonPropaganda(
                    texto: 'Volver',
                    compacto: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  BotonPropaganda(
                    texto: 'Sellar elección y desplegar',
                    destacado: true,
                    onPressed: _seleccionada == null
                        ? null
                        : () {
                            final definicion =
                                catalogoClases[_seleccionada!]!;
                            final personaje = Combatiente(
                              nombre: 'Cadete',
                              esJugador: true,
                              clase: definicion.identificador,
                              cuerpo: definicion.cuerpoBase,
                              mente: definicion.menteBase,
                              carisma: definicion.carismaBase,
                              puntosVidaMaximos:
                                  definicion.puntosVidaMaximos,
                              moralMaxima: definicion.moralMaxima,
                            );
                            final estado = EstadoJuego(personaje: personaje);
                            estado.anadirObjeto('gorra_cosmonauta');
                            estado.idObjetoCabezaEquipado =
                                'gorra_cosmonauta';
                            final identificadorArmaInicial =
                                _armaInicialDeClase(
                                    definicion.identificador);
                            estado.anadirObjeto(identificadorArmaInicial);
                            estado.idObjetoArmaEquipada =
                                identificadorArmaInicial;
                            Navigator.of(context).push(
                              crearRutaConTransicion(
                                PantallaSala(estado: estado),
                              ),
                            );
                          },
                  ),
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _armaInicialDeClase(ClaseCosmonauta clase) {
  switch (clase) {
    case ClaseCosmonauta.gimnasta:
      return 'arma_remache_neumatico';
    case ClaseCosmonauta.ingeniera:
      return 'arma_llave_inglesa';
    case ClaseCosmonauta.comisaria:
      return 'arma_libreta_decretos';
  }
}

class _TarjetaClase extends StatelessWidget {
  final DefinicionClase definicion;
  final bool seleccionada;
  final VoidCallback onTap;

  const _TarjetaClase({
    required this.definicion,
    required this.seleccionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: seleccionada
                ? PaletaCosmoSovietica.papelSombra
                : PaletaCosmoSovietica.papelViejo,
            border: Border.all(
              color: seleccionada
                  ? PaletaCosmoSovietica.rojoOficial
                  : PaletaCosmoSovietica.tintaNegra,
              width: seleccionada ? 4 : 2,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 170,
                child: Center(
                  child: SizedBox(
                    width: 130,
                    height: 170,
                    // Retrato de selección: sprite atlas por clase,
                    // estado idle. Sustituye al stick figure procedimental.
                    child: SpriteClaseCadete(
                      clase: definicion.identificador,
                      estado: EstadoSpriteClase.idle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                definicion.nombreCompleto.toUpperCase(),
                style: TipografiaPropaganda.tituloSeccion
                    .copyWith(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(definicion.subtitulo,
                  style: TipografiaPropaganda.subtitulo
                      .copyWith(fontSize: 14)),
              const SizedBox(height: 12),
              Text(
                definicion.descripcionBreve,
                style: TipografiaPropaganda.cuerpoLargo,
              ),
              const SizedBox(height: 12),
              _FilaStat(etiqueta: 'CUERPO', valor: definicion.cuerpoBase),
              _FilaStat(etiqueta: 'MENTE', valor: definicion.menteBase),
              _FilaStat(etiqueta: 'CARISMA', valor: definicion.carismaBase),
              const Spacer(),
              Text(
                '★ ${definicion.nombreHabilidadDestacada}',
                style: TipografiaPropaganda.etiquetaBurocratica
                    .copyWith(color: PaletaCosmoSovietica.rojoOficial),
              ),
              const SizedBox(height: 4),
              Text(
                definicion.descripcionHabilidadDestacada,
                style: TipografiaPropaganda.cuerpoLargo.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilaStat extends StatelessWidget {
  final String etiqueta;
  final int valor;

  const _FilaStat({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(etiqueta,
                style: TipografiaPropaganda.etiquetaBurocratica),
          ),
          Text(valor.toString(), style: TipografiaPropaganda.numeroStat),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                border: Border.all(
                  color: PaletaCosmoSovietica.tintaNegra,
                  width: 1.5,
                ),
              ),
              child: FractionallySizedBox(
                widthFactor: (valor / 10).clamp(0.0, 1.0),
                alignment: Alignment.centerLeft,
                child: Container(color: PaletaCosmoSovietica.tintaNegra),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
