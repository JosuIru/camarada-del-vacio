import 'package:flutter/material.dart';

class ConfiguracionPlanetaCosmos {
  final String identificador;
  final String etiqueta;
  final String subtitulo;
  final Offset posicionRelativa;
  final double radioRelativo;
  final Color colorCentro;
  final Color colorBorde;
  final String emojiDecoracion;
  final bool implementado;

  const ConfiguracionPlanetaCosmos({
    required this.identificador,
    required this.etiqueta,
    required this.subtitulo,
    required this.posicionRelativa,
    required this.radioRelativo,
    required this.colorCentro,
    required this.colorBorde,
    required this.emojiDecoracion,
    this.implementado = false,
  });
}

const List<ConfiguracionPlanetaCosmos> planetasCuadranteSigma = [
  ConfiguracionPlanetaCosmos(
    identificador: 'pravda12',
    etiqueta: 'PRAVDA-12',
    subtitulo: 'Nave del cadete · base orbital',
    posicionRelativa: Offset(0.5, 0.5),
    radioRelativo: 0.07,
    colorCentro: Color(0xFFC8102E),
    colorBorde: Color(0xFF15110D),
    emojiDecoracion: '☭',
    implementado: true,
  ),
  ConfiguracionPlanetaCosmos(
    identificador: 'zovnak4',
    etiqueta: 'ZOVNAK-4',
    subtitulo: 'Asamblea Permanente · cuórum desde 1922',
    posicionRelativa: Offset(0.22, 0.32),
    radioRelativo: 0.075,
    colorCentro: Color(0xFFE05A3A),
    colorBorde: Color(0xFF8C1A10),
    emojiDecoracion: '🌋',
    implementado: true,
  ),
  ConfiguracionPlanetaCosmos(
    identificador: 'gelida9',
    etiqueta: 'GÉLIDA-9',
    subtitulo: 'Luna burocrática · −180 °C · F-447 requerido x47',
    posicionRelativa: Offset(0.78, 0.28),
    radioRelativo: 0.07,
    colorCentro: Color(0xFF4A8FC8),
    colorBorde: Color(0xFF0B2A4A),
    emojiDecoracion: '❄',
    implementado: true,
  ),
  ConfiguracionPlanetaCosmos(
    identificador: 'sol_camarada',
    etiqueta: 'SOL CAMARADA',
    subtitulo: 'Estrella sindicalizada · SESG Rama 7-B',
    posicionRelativa: Offset(0.15, 0.74),
    radioRelativo: 0.085,
    colorCentro: Color(0xFFF5C518),
    colorBorde: Color(0xFF8A620A),
    emojiDecoracion: '☀',
    implementado: true,
  ),
  ConfiguracionPlanetaCosmos(
    identificador: 'formulario13',
    etiqueta: 'FORMULARIO-13',
    subtitulo: 'Planeta administrativo · 87% papeleo',
    posicionRelativa: Offset(0.82, 0.72),
    radioRelativo: 0.065,
    colorCentro: Color(0xFF6B4C9A),
    colorBorde: Color(0xFF2A1A4A),
    emojiDecoracion: '🌑',
    implementado: false,
  ),
  ConfiguracionPlanetaCosmos(
    identificador: 'agujero_sindicalizado',
    etiqueta: 'AGUJERO NEGRO',
    subtitulo: 'Singularidad con convenio colectivo desde 1971',
    posicionRelativa: Offset(0.5, 0.86),
    radioRelativo: 0.06,
    colorCentro: Color(0xFF401005),
    colorBorde: Color(0xFF15110D),
    emojiDecoracion: '⊙',
    implementado: false,
  ),
  ConfiguracionPlanetaCosmos(
    identificador: 'pravda7',
    etiqueta: 'PRAVDA-7',
    subtitulo: 'Estación perdida · señal: «todavía estamos abajo»',
    posicionRelativa: Offset(0.5, 0.14),
    radioRelativo: 0.07,
    colorCentro: Color(0xFF2E8B57),
    colorBorde: Color(0xFF0A3020),
    emojiDecoracion: '?',
    implementado: true,
  ),
  ConfiguracionPlanetaCosmos(
    identificador: 'pi7',
    etiqueta: 'Π-7',
    subtitulo: 'Planeta-bola · sólo visible tras sintonizar 7.47 MHz',
    posicionRelativa: Offset(0.36, 0.18),
    radioRelativo: 0.045,
    colorCentro: Color(0xFFE0E0DC),
    colorBorde: Color(0xFFC8102E),
    emojiDecoracion: '●',
    implementado: true,
  ),
];
