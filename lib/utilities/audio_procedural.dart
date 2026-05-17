/// Punto de entrada del servicio de audio procedural. Hace export
/// condicional: en plataformas con Web Audio API (cualquier build web)
/// expone la implementación real; en VM/nativo, expone el stub no-op.
///
/// Los callers (`title_screen.dart`, `combat_screen.dart`, etc.) sólo
/// necesitan `import '../utilities/audio_procedural.dart'` — no saben
/// en qué plataforma están corriendo.
library;

export 'audio_procedural_stub.dart'
    if (dart.library.js_interop) 'audio_procedural_web.dart';
