import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

class ConfiguracionModuloMapa {
  final String identificador;
  final String etiqueta;
  final Offset posicionRelativa;
  final Size tamano;
  final bool esRectangulo;
  final String? subtitulo;

  const ConfiguracionModuloMapa({
    required this.identificador,
    required this.etiqueta,
    required this.posicionRelativa,
    this.tamano = const Size(0.08, 0.12),
    this.esRectangulo = true,
    this.subtitulo,
  });
}

const List<ConfiguracionModuloMapa> modulosPravda12 = [
  ConfiguracionModuloMapa(
    identificador: 'capsula',
    etiqueta: 'CÁPSULA DE LLEGADA',
    posicionRelativa: Offset(0.08, 0.5),
    tamano: Size(0.07, 0.13),
    esRectangulo: false,
    subtitulo: 'Compuerta provisional · acoplada en condiciones adversas (1962)',
  ),
  ConfiguracionModuloMapa(
    identificador: 'cantina',
    etiqueta: 'CANTINA DEL OLVIDO',
    posicionRelativa: Offset(0.33, 0.5),
    tamano: Size(0.13, 0.15),
    subtitulo: 'Pasillo Central · zona común',
  ),
  ConfiguracionModuloMapa(
    identificador: 'camarotes',
    etiqueta: 'CAMAROTES',
    posicionRelativa: Offset(0.6, 0.28),
    tamano: Size(0.1, 0.12),
    subtitulo: 'Cápsulas de descanso · bloqueado por sacos de patata',
  ),
  ConfiguracionModuloMapa(
    identificador: 'propaganda',
    etiqueta: 'SALA DE PROPAGANDA',
    posicionRelativa: Offset(0.6, 0.74),
    tamano: Size(0.1, 0.12),
    subtitulo: 'Estudio de grabación · clausurado',
  ),
  ConfiguracionModuloMapa(
    identificador: 'reactor',
    etiqueta: 'SALA DEL REACTOR',
    posicionRelativa: Offset(0.78, 0.5),
    tamano: Size(0.12, 0.18),
    subtitulo: 'Núcleo + panel + Ingeniera Vostrikova',
  ),
  ConfiguracionModuloMapa(
    identificador: 'yuriovka',
    etiqueta: 'COMPUERTA · PRAVDA-7',
    posicionRelativa: Offset(0.94, 0.5),
    tamano: Size(0.07, 0.16),
    esRectangulo: false,
    subtitulo: 'Acoplamiento al señuelo · sellado con 3 precintos del F-447',
  ),
];

class PintorMapaOverworld extends CustomPainter {
  final double fase;
  final Set<String> modulosAccesibles;
  final String? moduloDestacado;
  final String? moduloVisitando;
  final String? moduloUbicacionActual;

  PintorMapaOverworld({
    required this.fase,
    required this.modulosAccesibles,
    this.moduloDestacado,
    this.moduloVisitando,
    this.moduloUbicacionActual,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pincelFondo = Paint()..color = PaletaCosmoSovietica.papelViejo;
    canvas.drawRect(Offset.zero & size, pincelFondo);

    _pintarCuadriculaTecnica(canvas, size);

    final pincelMarcoExterior = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final rectMarco = Rect.fromLTWH(
      size.width * 0.04,
      size.height * 0.08,
      size.width * 0.92,
      size.height * 0.84,
    );
    canvas.drawRect(rectMarco, pincelMarcoExterior);
    canvas.drawRect(
      rectMarco.deflate(6),
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    _pintarEsquinasEnL(canvas, rectMarco);
    _pintarReglaTecnica(canvas, rectMarco);

    _pintarCabeceraMapa(canvas, size, rectMarco);
    _pintarSelloPlanoTecnico(canvas, size, rectMarco);
    _pintarRosaCardinal(canvas, size, rectMarco);

    _pintarPasillosYParedes(canvas, size);

    final pulsoGeneral = math.sin(fase * math.pi * 2) * 0.5 + 0.5;
    for (final modulo in modulosPravda12) {
      final esAccesible = modulosAccesibles.contains(modulo.identificador);
      final esDestacado = moduloDestacado == modulo.identificador;
      final esVisitando = moduloVisitando == modulo.identificador;
      _pintarModulo(
        canvas,
        size,
        modulo,
        esAccesible: esAccesible,
        esDestacado: esDestacado,
        esVisitando: esVisitando,
        pulso: pulsoGeneral,
      );
    }

    _pintarIndicadorUbicacionActual(canvas, size, pulsoGeneral);
  }

  /// Cuadrícula técnica tenue de fondo (estilo papel cuadriculado).
  void _pintarCuadriculaTecnica(Canvas canvas, Size size) {
    final pincelLineaTenue = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.07)
      ..strokeWidth = 0.6;
    final pincelLineaCadaCinco = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.13)
      ..strokeWidth = 0.9;
    const espaciado = 22.0;
    int contadorVertical = 0;
    for (double x = 0; x <= size.width; x += espaciado) {
      final pincelLinea =
          contadorVertical % 5 == 0 ? pincelLineaCadaCinco : pincelLineaTenue;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), pincelLinea);
      contadorVertical++;
    }
    int contadorHorizontal = 0;
    for (double y = 0; y <= size.height; y += espaciado) {
      final pincelLinea = contadorHorizontal % 5 == 0
          ? pincelLineaCadaCinco
          : pincelLineaTenue;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), pincelLinea);
      contadorHorizontal++;
    }
  }

  void _pintarEsquinasEnL(Canvas canvas, Rect rectMarco) {
    final pincelEsquina = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.square;
    const tamanoLinea = 22.0;
    // Cuatro esquinas en L.
    for (final esquina in [
      (rectMarco.left, rectMarco.top, 1, 1),
      (rectMarco.right, rectMarco.top, -1, 1),
      (rectMarco.left, rectMarco.bottom, 1, -1),
      (rectMarco.right, rectMarco.bottom, -1, -1),
    ]) {
      final origenX = esquina.$1;
      final origenY = esquina.$2;
      final signoX = esquina.$3.toDouble();
      final signoY = esquina.$4.toDouble();
      canvas.drawLine(
        Offset(origenX, origenY),
        Offset(origenX + tamanoLinea * signoX, origenY),
        pincelEsquina,
      );
      canvas.drawLine(
        Offset(origenX, origenY),
        Offset(origenX, origenY + tamanoLinea * signoY),
        pincelEsquina,
      );
    }
  }

  /// Pequeñas marcas de medida en el borde inferior del marco, como un
  /// plano técnico real con escala.
  void _pintarReglaTecnica(Canvas canvas, Rect rectMarco) {
    final pincelMarca = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..strokeWidth = 1.2;
    final yRegla = rectMarco.bottom - 12;
    final inicio = rectMarco.left + 30;
    final fin = rectMarco.right - 30;
    final cantidadDivisiones = 12;
    final pasoDivision = (fin - inicio) / cantidadDivisiones;
    canvas.drawLine(
      Offset(inicio, yRegla),
      Offset(fin, yRegla),
      pincelMarca,
    );
    for (int indiceDivision = 0;
        indiceDivision <= cantidadDivisiones;
        indiceDivision++) {
      final x = inicio + indiceDivision * pasoDivision;
      final esDivisionGrande = indiceDivision % 3 == 0;
      canvas.drawLine(
        Offset(x, yRegla),
        Offset(x, yRegla + (esDivisionGrande ? 6 : 3)),
        pincelMarca,
      );
    }
    final pintorEscala = TextPainter(
      text: const TextSpan(
        text: 'ESCALA 1:200 · UNIDADES SOVIÉTICAS',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: PaletaCosmoSovietica.tintaNegra,
          letterSpacing: 1.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorEscala.paint(
      canvas,
      Offset(inicio, yRegla + 8),
    );
  }

  /// Sello técnico circular en la esquina inferior derecha del marco.
  void _pintarSelloPlanoTecnico(Canvas canvas, Size size, Rect rectMarco) {
    final centroSello = Offset(
      rectMarco.right - 56,
      rectMarco.bottom - 56,
    );
    final radioSello = 32.0;
    canvas.drawCircle(
      centroSello,
      radioSello,
      Paint()
        ..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      centroSello,
      radioSello,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.drawCircle(
      centroSello,
      radioSello * 0.7,
      Paint()
        ..color = PaletaCosmoSovietica.papelViejo
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    _dibujarEstrellaCentrada(
      canvas,
      centroSello,
      radioSello * 0.42,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    final pintorAnotacion = TextPainter(
      text: const TextSpan(
        text: 'V·B\nCOMITÉ',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 7,
          fontWeight: FontWeight.bold,
          color: PaletaCosmoSovietica.papelViejo,
          letterSpacing: 0.6,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    pintorAnotacion.paint(
      canvas,
      Offset(
        centroSello.dx - pintorAnotacion.width / 2,
        centroSello.dy + radioSello * 0.5,
      ),
    );
  }

  /// Mini rosa de los vientos en la esquina superior derecha del marco
  /// indicando "PROA" (frente de la nave).
  void _pintarRosaCardinal(Canvas canvas, Size size, Rect rectMarco) {
    final centro = Offset(rectMarco.right - 36, rectMarco.top + 36);
    final radio = 18.0;
    canvas.drawCircle(
      centro,
      radio,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    canvas.drawCircle(
      centro,
      radio,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    final pincelAguja = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial
      ..style = PaintingStyle.fill;
    final caminoAgujaProa = Path()
      ..moveTo(centro.dx, centro.dy - radio + 2)
      ..lineTo(centro.dx - 4, centro.dy)
      ..lineTo(centro.dx + 4, centro.dy)
      ..close();
    canvas.drawPath(caminoAgujaProa, pincelAguja);
    final caminoAgujaPopa = Path()
      ..moveTo(centro.dx, centro.dy + radio - 2)
      ..lineTo(centro.dx - 4, centro.dy)
      ..lineTo(centro.dx + 4, centro.dy)
      ..close();
    canvas.drawPath(
      caminoAgujaPopa,
      Paint()..color = PaletaCosmoSovietica.tintaNegra,
    );
    canvas.drawCircle(
      centro,
      2.4,
      Paint()..color = PaletaCosmoSovietica.tintaNegra,
    );
    final pintorProa = TextPainter(
      text: const TextSpan(
        text: 'PROA',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: PaletaCosmoSovietica.tintaNegra,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorProa.paint(
      canvas,
      Offset(centro.dx - pintorProa.width / 2, centro.dy - radio - 14),
    );
  }

  /// Pasillos como rectángulos con paredes negras gruesas y suelo claro,
  /// estilo plano arquitectónico.
  void _pintarPasillosYParedes(Canvas canvas, Size size) {
    final yCentro = size.height * 0.5;
    final pincelParedSuelo = Paint()
      ..color = PaletaCosmoSovietica.papelSombra
      ..style = PaintingStyle.fill;
    final pincelParedBorde = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final grosorPasillo = size.height * 0.06;

    // Pasillo horizontal principal.
    final rectPasilloHorizontal = Rect.fromLTRB(
      size.width * 0.13,
      yCentro - grosorPasillo / 2,
      size.width * 0.93,
      yCentro + grosorPasillo / 2,
    );
    canvas.drawRect(rectPasilloHorizontal, pincelParedSuelo);
    canvas.drawRect(rectPasilloHorizontal, pincelParedBorde);

    // Marcas de baldosas en el suelo del pasillo.
    final pincelBaldosa = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.25)
      ..strokeWidth = 0.8;
    for (double xBaldosa = rectPasilloHorizontal.left + 18;
        xBaldosa < rectPasilloHorizontal.right;
        xBaldosa += 24) {
      canvas.drawLine(
        Offset(xBaldosa, rectPasilloHorizontal.top + 4),
        Offset(xBaldosa, rectPasilloHorizontal.bottom - 4),
        pincelBaldosa,
      );
    }

    // Ramificaciones verticales hacia camarotes (arriba) y propaganda (abajo).
    final grosorRama = size.width * 0.05;
    final xRama = size.width * 0.6;
    final rectRamaArriba = Rect.fromLTRB(
      xRama - grosorRama / 2,
      size.height * 0.34,
      xRama + grosorRama / 2,
      yCentro - grosorPasillo / 2 + 1,
    );
    final rectRamaAbajo = Rect.fromLTRB(
      xRama - grosorRama / 2,
      yCentro + grosorPasillo / 2 - 1,
      xRama + grosorRama / 2,
      size.height * 0.68,
    );
    for (final rectRama in [rectRamaArriba, rectRamaAbajo]) {
      canvas.drawRect(rectRama, pincelParedSuelo);
      canvas.drawRect(rectRama, pincelParedBorde);
      for (double yBaldosa = rectRama.top + 12;
          yBaldosa < rectRama.bottom - 4;
          yBaldosa += 22) {
        canvas.drawLine(
          Offset(rectRama.left + 3, yBaldosa),
          Offset(rectRama.right - 3, yBaldosa),
          pincelBaldosa,
        );
      }
    }
  }

  void _pintarIndicadorUbicacionActual(
      Canvas canvas, Size size, double pulsoGeneral) {
    final identificadorUbicacion = moduloUbicacionActual;
    if (identificadorUbicacion == null) return;
    final moduloUbicacion = modulosPravda12.firstWhere(
      (m) => m.identificador == identificadorUbicacion,
      orElse: () => modulosPravda12.first,
    );
    final centroModulo = Offset(
      moduloUbicacion.posicionRelativa.dx * size.width,
      moduloUbicacion.posicionRelativa.dy * size.height,
    );
    final altoModulo = moduloUbicacion.tamano.height * size.height;
    final puntoIndicador = Offset(
      centroModulo.dx,
      centroModulo.dy - altoModulo / 2 - 24,
    );

    final radioPulsante = 8 + pulsoGeneral * 4;
    final pincelHaloRojo = Paint()
      ..color = PaletaCosmoSovietica.rojoOficial.withValues(alpha: 0.32)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(puntoIndicador, radioPulsante + 6, pincelHaloRojo);
    canvas.drawCircle(
      puntoIndicador,
      radioPulsante,
      Paint()..color = PaletaCosmoSovietica.rojoOficial,
    );
    canvas.drawCircle(
      puntoIndicador,
      radioPulsante,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    final pathFlecha = Path()
      ..moveTo(puntoIndicador.dx - 7, puntoIndicador.dy + radioPulsante - 1)
      ..lineTo(puntoIndicador.dx, puntoIndicador.dy + radioPulsante + 9)
      ..lineTo(puntoIndicador.dx + 7, puntoIndicador.dy + radioPulsante - 1)
      ..close();
    canvas.drawPath(
      pathFlecha,
      Paint()..color = PaletaCosmoSovietica.rojoOficial,
    );
    canvas.drawPath(
      pathFlecha,
      Paint()
        ..color = PaletaCosmoSovietica.tintaNegra
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final origenEtiqueta = Offset(
      puntoIndicador.dx + 12,
      puntoIndicador.dy - 7,
    );
    final pintor = TextPainter(
      text: const TextSpan(
        text: 'USTED ESTÁ AQUÍ',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: PaletaCosmoSovietica.tintaNegra,
          letterSpacing: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rectEtiqueta = Rect.fromLTWH(
      origenEtiqueta.dx - 4,
      origenEtiqueta.dy - 2,
      pintor.width + 8,
      pintor.height + 4,
    );
    canvas.drawRect(
      rectEtiqueta,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
    canvas.drawRect(
      rectEtiqueta,
      Paint()
        ..color = PaletaCosmoSovietica.rojoOficial
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    pintor.paint(canvas, origenEtiqueta);
  }

  void _pintarCabeceraMapa(Canvas canvas, Size size, Rect rectMarco) {
    final rectCabecera = Rect.fromLTWH(
      rectMarco.left + 10,
      rectMarco.top + 8,
      rectMarco.width - 20,
      26,
    );
    final pincelCabeceraRelleno = Paint()
      ..color = PaletaCosmoSovietica.papelSombra;
    final pincelCabeceraBorde = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rectCabecera, pincelCabeceraRelleno);
    canvas.drawRect(rectCabecera, pincelCabeceraBorde);

    final pintorTituloIzquierdo = TextPainter(
      text: const TextSpan(
        text: 'PRAVDA-12 · PLANO TÉCNICO · LÁMINA 1/3',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: PaletaCosmoSovietica.tintaNegra,
          letterSpacing: 1.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorTituloIzquierdo.paint(
      canvas,
      Offset(
        rectCabecera.left + 8,
        rectCabecera.center.dy - pintorTituloIzquierdo.height / 2,
      ),
    );

    // Sello rojo a la derecha con texto «APROBADO».
    final centroSelloAprobado = Offset(
      rectCabecera.right - 56,
      rectCabecera.center.dy,
    );
    final rectoSelloAprobado = Rect.fromCenter(
      center: centroSelloAprobado,
      width: 96,
      height: rectCabecera.height - 8,
    );
    canvas.drawRect(
      rectoSelloAprobado,
      Paint()..color = PaletaCosmoSovietica.rojoOficial,
    );
    canvas.drawRect(rectoSelloAprobado, pincelCabeceraBorde);
    final pintorAprobado = TextPainter(
      text: const TextSpan(
        text: 'APROBADO',
        style: TextStyle(
          fontFamily: 'CosmoMono',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: PaletaCosmoSovietica.papelViejo,
          letterSpacing: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintorAprobado.paint(
      canvas,
      Offset(
        rectoSelloAprobado.center.dx - pintorAprobado.width / 2,
        rectoSelloAprobado.center.dy - pintorAprobado.height / 2,
      ),
    );
    canvas.drawCircle(
      Offset(rectoSelloAprobado.right + 18, rectCabecera.center.dy),
      8,
      Paint()..color = PaletaCosmoSovietica.rojoOficial,
    );
    canvas.drawCircle(
      Offset(rectoSelloAprobado.right + 18, rectCabecera.center.dy),
      8,
      pincelCabeceraBorde,
    );
    _dibujarEstrellaCentrada(
      canvas,
      Offset(rectoSelloAprobado.right + 18, rectCabecera.center.dy),
      4,
      Paint()..color = PaletaCosmoSovietica.papelViejo,
    );
  }

  /// Pinta una estrella regular de 5 puntas con relleno [pincel].
  void _dibujarEstrellaCentrada(
      Canvas canvas, Offset centro, double radio, Paint pincel) {
    final camino = Path();
    const cantidadPuntas = 5;
    for (int indicePunto = 0;
        indicePunto < cantidadPuntas * 2;
        indicePunto++) {
      final esExterior = indicePunto % 2 == 0;
      final radioActual = esExterior ? radio : radio * 0.42;
      final angulo =
          -math.pi / 2 + indicePunto * math.pi / cantidadPuntas;
      final x = centro.dx + math.cos(angulo) * radioActual;
      final y = centro.dy + math.sin(angulo) * radioActual;
      if (indicePunto == 0) {
        camino.moveTo(x, y);
      } else {
        camino.lineTo(x, y);
      }
    }
    camino.close();
    canvas.drawPath(camino, pincel);
  }

  void _pintarModulo(
    Canvas canvas,
    Size size,
    ConfiguracionModuloMapa modulo, {
    required bool esAccesible,
    required bool esDestacado,
    required bool esVisitando,
    required double pulso,
  }) {
    final centro = Offset(
      modulo.posicionRelativa.dx * size.width,
      modulo.posicionRelativa.dy * size.height,
    );
    final tamano = Size(
      modulo.tamano.width * size.width,
      modulo.tamano.height * size.height,
    );
    final rect = Rect.fromCenter(
      center: centro,
      width: tamano.width,
      height: tamano.height,
    );

    final pincelRelleno = Paint()
      ..color = esAccesible
          ? PaletaCosmoSovietica.papelSombra
          : PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.7);
    final pincelTrazo = Paint()
      ..color = esAccesible
          ? PaletaCosmoSovietica.tintaNegra
          : PaletaCosmoSovietica.tintaTenue
      ..style = PaintingStyle.stroke
      ..strokeWidth = esDestacado ? 3.6 : 2.5;
    final pincelSombraInterior = Paint()
      ..color = PaletaCosmoSovietica.tintaNegra.withValues(alpha: 0.08);

    if (modulo.esRectangulo) {
      canvas.drawRect(rect, pincelRelleno);
      // Sombra interior abajo+derecha simulando volumen.
      canvas.drawRect(
        Rect.fromLTRB(rect.left, rect.bottom - 6, rect.right, rect.bottom),
        pincelSombraInterior,
      );
      canvas.drawRect(
        Rect.fromLTRB(rect.right - 4, rect.top, rect.right, rect.bottom),
        pincelSombraInterior,
      );
      canvas.drawRect(rect, pincelTrazo);
    } else {
      canvas.drawOval(rect, pincelRelleno);
      canvas.drawOval(rect, pincelTrazo);
    }

    _pintarIconoIdentificador(canvas, rect, modulo, esAccesible);

    // Etiqueta de código en esquina superior izquierda del módulo.
    final codigoModulo = _codigoCortoDelModulo(modulo.identificador);
    if (codigoModulo != null) {
      final pintorCodigo = TextPainter(
        text: TextSpan(
          text: codigoModulo,
          style: TextStyle(
            fontFamily: 'CosmoMono',
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: esAccesible
                ? PaletaCosmoSovietica.tintaNegra
                : PaletaCosmoSovietica.tintaTenue,
            letterSpacing: 0.6,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final fondoCodigo = Rect.fromLTWH(
        rect.left + 3,
        rect.top + 3,
        pintorCodigo.width + 6,
        pintorCodigo.height + 2,
      );
      canvas.drawRect(
        fondoCodigo,
        Paint()..color = PaletaCosmoSovietica.papelViejo.withValues(alpha: 0.85),
      );
      canvas.drawRect(
        fondoCodigo,
        Paint()
          ..color = pincelTrazo.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
      pintorCodigo.paint(
        canvas,
        Offset(fondoCodigo.left + 3, fondoCodigo.top + 1),
      );
    }

    if (esDestacado) {
      final auraExtra = pulso * 6;
      canvas.drawRect(
        rect.inflate(4 + auraExtra),
        Paint()
          ..color = PaletaCosmoSovietica.rojoOficial
              .withValues(alpha: 0.25 + pulso * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    if (esVisitando) {
      canvas.drawCircle(
        Offset(rect.center.dx, rect.top - 12),
        4 + pulso * 2,
        Paint()..color = PaletaCosmoSovietica.rojoOficial,
      );
    }

    if (!esAccesible) {
      final pathTacha = Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.bottom)
        ..moveTo(rect.right, rect.top)
        ..lineTo(rect.left, rect.bottom);
      canvas.drawPath(
        pathTacha,
        Paint()
          ..color = PaletaCosmoSovietica.tintaTenue.withValues(alpha: 0.55)
          ..strokeWidth = 2,
      );
    }
  }

  /// Devuelve el código burocrático corto que se imprime en la esquina del
  /// módulo. Por convención: M-01, M-02… con un sufijo informativo.
  String? _codigoCortoDelModulo(String identificador) {
    switch (identificador) {
      case 'capsula':
        return 'M-01';
      case 'cantina':
        return 'M-02';
      case 'camarotes':
        return 'M-03';
      case 'propaganda':
        return 'M-04';
      case 'reactor':
        return 'M-05';
      case 'yuriovka':
        return 'C-Y7';
      default:
        return null;
    }
  }

  /// Pictograma vectorial específico de cada módulo, centrado abajo.
  void _pintarIconoIdentificador(
      Canvas canvas, Rect rect, ConfiguracionModuloMapa modulo, bool esAccesible) {
    final colorIcono = esAccesible
        ? PaletaCosmoSovietica.tintaNegra
        : PaletaCosmoSovietica.tintaTenue;
    final pincelTrazo = Paint()
      ..color = colorIcono
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final pincelRelleno = Paint()
      ..color = colorIcono
      ..style = PaintingStyle.fill;
    final centroIcono = Offset(rect.center.dx, rect.center.dy + 2);
    final tamanoIcono = rect.shortestSide * 0.42;
    switch (modulo.identificador) {
      case 'capsula':
        _pintarIconoCapsula(canvas, centroIcono, tamanoIcono, pincelTrazo,
            pincelRelleno, esAccesible);
        break;
      case 'cantina':
        _pintarIconoCantina(canvas, centroIcono, tamanoIcono, pincelTrazo,
            pincelRelleno);
        break;
      case 'camarotes':
        _pintarIconoCamarotes(canvas, centroIcono, tamanoIcono, pincelTrazo);
        break;
      case 'propaganda':
        _pintarIconoPropaganda(canvas, centroIcono, tamanoIcono, pincelTrazo,
            pincelRelleno);
        break;
      case 'reactor':
        _pintarIconoReactor(canvas, centroIcono, tamanoIcono, pincelTrazo,
            pincelRelleno, esAccesible);
        break;
      case 'yuriovka':
        _pintarIconoCompuertaSellada(
            canvas, centroIcono, tamanoIcono, pincelTrazo, pincelRelleno);
        break;
    }
  }

  void _pintarIconoCapsula(Canvas canvas, Offset centro, double tamano,
      Paint trazo, Paint relleno, bool esAccesible) {
    final caminoBala = Path()
      ..moveTo(centro.dx, centro.dy - tamano * 0.7)
      ..quadraticBezierTo(
        centro.dx + tamano * 0.4,
        centro.dy - tamano * 0.55,
        centro.dx + tamano * 0.4,
        centro.dy + tamano * 0.2,
      )
      ..lineTo(centro.dx + tamano * 0.4, centro.dy + tamano * 0.6)
      ..lineTo(centro.dx - tamano * 0.4, centro.dy + tamano * 0.6)
      ..lineTo(centro.dx - tamano * 0.4, centro.dy + tamano * 0.2)
      ..quadraticBezierTo(
        centro.dx - tamano * 0.4,
        centro.dy - tamano * 0.55,
        centro.dx,
        centro.dy - tamano * 0.7,
      )
      ..close();
    canvas.drawPath(caminoBala, trazo);
    // Escotilla.
    canvas.drawCircle(
      Offset(centro.dx, centro.dy - tamano * 0.05),
      tamano * 0.18,
      trazo,
    );
  }

  void _pintarIconoCantina(Canvas canvas, Offset centro, double tamano,
      Paint trazo, Paint relleno) {
    // Vaso trapezoidal.
    final caminoVaso = Path()
      ..moveTo(centro.dx - tamano * 0.35, centro.dy - tamano * 0.5)
      ..lineTo(centro.dx + tamano * 0.35, centro.dy - tamano * 0.5)
      ..lineTo(centro.dx + tamano * 0.25, centro.dy + tamano * 0.5)
      ..lineTo(centro.dx - tamano * 0.25, centro.dy + tamano * 0.5)
      ..close();
    canvas.drawPath(caminoVaso, trazo);
    // Línea de líquido a la mitad.
    canvas.drawLine(
      Offset(centro.dx - tamano * 0.3, centro.dy),
      Offset(centro.dx + tamano * 0.3, centro.dy),
      trazo,
    );
    // Burbujitas (3 puntos).
    for (int indiceBurbuja = 0; indiceBurbuja < 3; indiceBurbuja++) {
      canvas.drawCircle(
        Offset(
          centro.dx - tamano * 0.18 + indiceBurbuja * tamano * 0.18,
          centro.dy + tamano * 0.18,
        ),
        1.4,
        relleno,
      );
    }
  }

  void _pintarIconoCamarotes(
      Canvas canvas, Offset centro, double tamano, Paint trazo) {
    // Litera: rectángulo grande con división horizontal y dos almohadas.
    final rectoLitera = Rect.fromCenter(
      center: centro,
      width: tamano * 0.95,
      height: tamano * 0.95,
    );
    canvas.drawRect(rectoLitera, trazo);
    canvas.drawLine(
      Offset(rectoLitera.left, rectoLitera.center.dy),
      Offset(rectoLitera.right, rectoLitera.center.dy),
      trazo,
    );
    // Almohadas (rectángulos pequeños).
    final pincelRellenoTrazo = Paint()
      ..color = trazo.color
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        rectoLitera.left + 3,
        rectoLitera.top + 3,
        rectoLitera.width * 0.28,
        rectoLitera.height * 0.18,
      ),
      pincelRellenoTrazo,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        rectoLitera.left + 3,
        rectoLitera.center.dy + 3,
        rectoLitera.width * 0.28,
        rectoLitera.height * 0.18,
      ),
      pincelRellenoTrazo,
    );
  }

  void _pintarIconoPropaganda(Canvas canvas, Offset centro, double tamano,
      Paint trazo, Paint relleno) {
    // Megáfono apuntando a la derecha.
    final caminoMegafono = Path()
      ..moveTo(centro.dx - tamano * 0.4, centro.dy - tamano * 0.1)
      ..lineTo(centro.dx + tamano * 0.1, centro.dy - tamano * 0.35)
      ..lineTo(centro.dx + tamano * 0.1, centro.dy + tamano * 0.35)
      ..lineTo(centro.dx - tamano * 0.4, centro.dy + tamano * 0.1)
      ..close();
    canvas.drawPath(caminoMegafono, trazo);
    // Líneas de sonido.
    for (int indiceOnda = 0; indiceOnda < 3; indiceOnda++) {
      final xOnda = centro.dx + tamano * (0.18 + indiceOnda * 0.12);
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(xOnda - 2, centro.dy),
          width: tamano * 0.25,
          height: tamano * 0.5,
        ),
        -math.pi / 3,
        math.pi * 2 / 3,
        false,
        trazo,
      );
    }
  }

  void _pintarIconoReactor(Canvas canvas, Offset centro, double tamano,
      Paint trazo, Paint relleno, bool esAccesible) {
    // Átomo: tres elipses cruzadas + núcleo.
    for (int indiceElipse = 0; indiceElipse < 3; indiceElipse++) {
      canvas.save();
      canvas.translate(centro.dx, centro.dy);
      canvas.rotate(indiceElipse * math.pi / 3);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: tamano * 0.95,
          height: tamano * 0.35,
        ),
        trazo,
      );
      canvas.restore();
    }
    // Núcleo central (rojo si accesible para destacarlo).
    canvas.drawCircle(
      centro,
      tamano * 0.13,
      Paint()
        ..color = esAccesible
            ? PaletaCosmoSovietica.rojoOficial
            : PaletaCosmoSovietica.tintaTenue,
    );
    canvas.drawCircle(centro, tamano * 0.13, trazo);
  }

  void _pintarIconoCompuertaSellada(Canvas canvas, Offset centro, double tamano,
      Paint trazo, Paint relleno) {
    // Compuerta circular con tres precintos en cruz.
    final radioCompuerta = tamano * 0.45;
    canvas.drawCircle(centro, radioCompuerta, trazo);
    for (int indicePrecinto = 0; indicePrecinto < 3; indicePrecinto++) {
      final angulo = indicePrecinto * math.pi / 3 + math.pi / 6;
      final fin = Offset(
        centro.dx + math.cos(angulo) * radioCompuerta * 1.1,
        centro.dy + math.sin(angulo) * radioCompuerta * 1.1,
      );
      final inicio = Offset(
        centro.dx - math.cos(angulo) * radioCompuerta * 1.1,
        centro.dy - math.sin(angulo) * radioCompuerta * 1.1,
      );
      canvas.drawLine(inicio, fin, trazo);
    }
    // Sello rojo central.
    canvas.drawCircle(
      centro,
      tamano * 0.12,
      Paint()..color = PaletaCosmoSovietica.rojoOficial,
    );
  }

  @override
  bool shouldRepaint(covariant PintorMapaOverworld viejo) =>
      viejo.fase != fase ||
      viejo.modulosAccesibles.length != modulosAccesibles.length ||
      viejo.moduloDestacado != moduloDestacado ||
      viejo.moduloVisitando != moduloVisitando ||
      viejo.moduloUbicacionActual != moduloUbicacionActual;
}
