/// Stub no-op del servicio de audio procedural para plataformas sin
/// Web Audio API (VM en `flutter test`, builds nativos no-web). Mantiene
/// idéntica firma pública a `audio_procedural_web.dart` para que el
/// export condicional de `audio_procedural.dart` sea transparente.
///
/// Cuando se invocan los métodos `reproducir*` en VM, no suena nada —
/// pero la app no peta y los tests pueden ejecutar widgets que importen
/// `audio_procedural.dart` sin arrastrar `dart:js_interop`.
class AudioProcedural {
  bool _silenciado = false;

  // ignore: unnecessary_getters_setters
  bool get silenciado => _silenciado;

  set silenciado(bool valor) {
    _silenciado = valor;
  }

  void despertarSiNecesario() {}

  void alternarSilenciado() {
    _silenciado = !_silenciado;
  }

  void reproducirClickBoton() {}
  void reproducirPaso() {}
  void reproducirSelloBurocratico() {}
  void reproducirGolpeFisico() {}
  void reproducirGolpeTecnico() {}
  void reproducirGolpeMoral() {}
  void reproducirTransicionEscenario() {}
  void reproducirFanfarriaVictoria() {}
  void reproducirDoblesCampanasDerrota() {}
  void reproducirSubidaDeNivel() {}
}

/// Instancia singleton — el stub conserva el mismo símbolo público.
final audioProcedural = AudioProcedural();
