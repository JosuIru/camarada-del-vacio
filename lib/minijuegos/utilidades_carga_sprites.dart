import 'dart:ui' as ui;
import 'package:flutter/services.dart';

/// Carga una imagen desde `assets/` devolviendo `null` si el asset no
/// existe todavía. Pensado para el patrón de "cableado anticipado":
/// el código pide la imagen, si está cableada se renderiza; si aún no
/// la has generado, el painter usa el fallback procedural sin petar.
///
/// Centralizado aquí para que los 9 minijuegos no dupliquen el
/// `try/catch` ni el `instantiateImageCodec`.
Future<ui.Image?> cargarImagenOpcional(String rutaAsset) async {
  try {
    final ByteData datos = await rootBundle.load(rutaAsset);
    final Uint8List bytes = datos.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  } catch (_) {
    return null;
  }
}

/// Carga un lote de imágenes en paralelo. Devuelve la lista en el
/// mismo orden que las rutas, con `null` donde el asset no exista.
///
/// Conveniente al cargar los 5-8 sprites de un minijuego en `initState`:
///
/// ```dart
/// final imagenes = await cargarLoteOpcional([
///   'assets/svg/doom_pared_ministerio.png',
///   'assets/svg/doom_suelo_baldosa.png',
/// ]);
/// // imagenes[0] o null, imagenes[1] o null, …
/// ```
Future<List<ui.Image?>> cargarLoteOpcional(List<String> rutas) {
  return Future.wait(rutas.map(cargarImagenOpcional));
}
