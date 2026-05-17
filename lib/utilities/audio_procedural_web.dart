import 'dart:js_interop';
import 'dart:math' as math;
import 'package:web/web.dart' as web;

/// Servicio de audio procedural basado en Web Audio API. No usa samples
/// pre-grabados: cada SFX es síntesis con osciladores + envolvente, lo que
/// mantiene el bundle ligero y refuerza el aire industrial-soviético del
/// prototipo. Es lazy: el AudioContext solo se crea tras la primera
/// interacción del usuario (los navegadores bloquean audio hasta entonces).
class AudioProcedural {
  web.AudioContext? _contextoAudio;
  web.GainNode? _gananciaMaestra;
  bool _silenciado = false;
  bool _intentoInicializarFallido = false;
  final math.Random _aleatorio = math.Random();

  bool get silenciado => _silenciado;

  set silenciado(bool valor) {
    _silenciado = valor;
    final ganancia = _gananciaMaestra;
    if (ganancia != null) {
      ganancia.gain.value = valor ? 0.0 : 0.7;
    }
  }

  /// Asegura que el contexto de audio existe. Devuelve null si el navegador
  /// rechaza la creación (por ejemplo, sin interacción del usuario aún).
  web.AudioContext? _asegurarContexto() {
    if (_contextoAudio != null) return _contextoAudio;
    if (_intentoInicializarFallido) return null;
    try {
      final contextoCreado = web.AudioContext();
      final gananciaCreada = contextoCreado.createGain();
      gananciaCreada.gain.value = _silenciado ? 0.0 : 0.7;
      gananciaCreada.connect(contextoCreado.destination);
      _contextoAudio = contextoCreado;
      _gananciaMaestra = gananciaCreada;
      return contextoCreado;
    } catch (_) {
      _intentoInicializarFallido = true;
      return null;
    }
  }

  /// Despierta el contexto si estuviera suspendido (cuando el usuario aún
  /// no ha interactuado, Chrome lo deja suspendido).
  void despertarSiNecesario() {
    final contextoActual = _asegurarContexto();
    if (contextoActual == null) return;
    if (contextoActual.state == 'suspended') {
      contextoActual.resume();
    }
  }

  void alternarSilenciado() {
    silenciado = !_silenciado;
  }

  /// Construye una nota corta con envolvente ADSR mínima y la conecta a la
  /// salida maestra. [frecuenciaInicialHz] y [frecuenciaFinalHz] permiten
  /// rampas (slide); deja [frecuenciaFinalHz] null para nota plana.
  void _reproducirNota({
    required double frecuenciaInicialHz,
    double? frecuenciaFinalHz,
    required double duracionSegundos,
    required String tipoOnda,
    double volumen = 0.5,
    double tiempoAtaqueSegundos = 0.005,
    double tiempoCaidaSegundos = 0.02,
    double sostenidoFraccion = 0.3,
    double retardoInicioSegundos = 0.0,
    double frecuenciaFiltroPasaBajos = 0,
  }) {
    final contextoActual = _asegurarContexto();
    if (contextoActual == null) return;
    final gananciaMaestra = _gananciaMaestra;
    if (gananciaMaestra == null) return;

    final instanteInicio = contextoActual.currentTime + retardoInicioSegundos;
    final instanteFin = instanteInicio + duracionSegundos;

    final oscilador = contextoActual.createOscillator();
    oscilador.type = tipoOnda;
    oscilador.frequency.setValueAtTime(frecuenciaInicialHz, instanteInicio);
    if (frecuenciaFinalHz != null) {
      oscilador.frequency.exponentialRampToValueAtTime(
        math.max(0.01, frecuenciaFinalHz),
        instanteFin,
      );
    }

    final envolvente = contextoActual.createGain();
    envolvente.gain.setValueAtTime(0.0001, instanteInicio);
    envolvente.gain.exponentialRampToValueAtTime(
      volumen,
      instanteInicio + tiempoAtaqueSegundos,
    );
    envolvente.gain.exponentialRampToValueAtTime(
      math.max(0.0001, volumen * sostenidoFraccion),
      instanteInicio + tiempoAtaqueSegundos + tiempoCaidaSegundos,
    );
    envolvente.gain.exponentialRampToValueAtTime(0.0001, instanteFin);

    web.AudioNode nodoSalida = envolvente;
    if (frecuenciaFiltroPasaBajos > 0) {
      final filtroPasaBajos = contextoActual.createBiquadFilter();
      filtroPasaBajos.type = 'lowpass';
      filtroPasaBajos.frequency.value = frecuenciaFiltroPasaBajos;
      envolvente.connect(filtroPasaBajos);
      nodoSalida = filtroPasaBajos;
    }

    oscilador.connect(envolvente);
    nodoSalida.connect(gananciaMaestra);
    oscilador.start(instanteInicio);
    oscilador.stop(instanteFin + 0.02);
  }

  /// Genera una ráfaga de ruido blanco corto, útil para impactos.
  void _reproducirRuidoBreve({
    required double duracionSegundos,
    double volumen = 0.4,
    double frecuenciaFiltroPasaBajos = 1200,
    double retardoInicioSegundos = 0.0,
  }) {
    final contextoActual = _asegurarContexto();
    if (contextoActual == null) return;
    final gananciaMaestra = _gananciaMaestra;
    if (gananciaMaestra == null) return;

    final instanteInicio = contextoActual.currentTime + retardoInicioSegundos;
    final instanteFin = instanteInicio + duracionSegundos;

    final cantidadMuestras =
        (contextoActual.sampleRate * duracionSegundos).round();
    final buffer = contextoActual.createBuffer(
      1,
      cantidadMuestras,
      contextoActual.sampleRate,
    );
    final canal = buffer.getChannelData(0).toDart;
    for (int indiceMuestra = 0;
        indiceMuestra < cantidadMuestras;
        indiceMuestra++) {
      canal[indiceMuestra] = (_aleatorio.nextDouble() * 2 - 1).toDouble();
    }

    final fuente = contextoActual.createBufferSource();
    fuente.buffer = buffer;

    final filtroPasaBajos = contextoActual.createBiquadFilter();
    filtroPasaBajos.type = 'lowpass';
    filtroPasaBajos.frequency.value = frecuenciaFiltroPasaBajos;

    final envolvente = contextoActual.createGain();
    envolvente.gain.setValueAtTime(volumen, instanteInicio);
    envolvente.gain.exponentialRampToValueAtTime(0.0001, instanteFin);

    fuente.connect(filtroPasaBajos);
    filtroPasaBajos.connect(envolvente);
    envolvente.connect(gananciaMaestra);
    fuente.start(instanteInicio);
    fuente.stop(instanteFin + 0.02);
  }

  // ── Catálogo de SFX ──────────────────────────────────────────────────

  void reproducirClickBoton() {
    _reproducirNota(
      frecuenciaInicialHz: 880,
      frecuenciaFinalHz: 620,
      duracionSegundos: 0.07,
      tipoOnda: 'square',
      volumen: 0.18,
    );
  }

  void reproducirPaso() {
    _reproducirRuidoBreve(
      duracionSegundos: 0.06,
      volumen: 0.25,
      frecuenciaFiltroPasaBajos: 500,
    );
  }

  void reproducirSelloBurocratico() {
    _reproducirRuidoBreve(
      duracionSegundos: 0.05,
      volumen: 0.5,
      frecuenciaFiltroPasaBajos: 900,
    );
    _reproducirNota(
      frecuenciaInicialHz: 180,
      frecuenciaFinalHz: 90,
      duracionSegundos: 0.18,
      tipoOnda: 'sine',
      volumen: 0.45,
      retardoInicioSegundos: 0.02,
    );
  }

  void reproducirGolpeFisico() {
    _reproducirRuidoBreve(
      duracionSegundos: 0.09,
      volumen: 0.6,
      frecuenciaFiltroPasaBajos: 800,
    );
    _reproducirNota(
      frecuenciaInicialHz: 140,
      frecuenciaFinalHz: 60,
      duracionSegundos: 0.22,
      tipoOnda: 'triangle',
      volumen: 0.5,
    );
  }

  void reproducirGolpeTecnico() {
    _reproducirNota(
      frecuenciaInicialHz: 1100,
      frecuenciaFinalHz: 280,
      duracionSegundos: 0.18,
      tipoOnda: 'square',
      volumen: 0.35,
      frecuenciaFiltroPasaBajos: 2400,
    );
  }

  void reproducirGolpeMoral() {
    _reproducirNota(
      frecuenciaInicialHz: 320,
      frecuenciaFinalHz: 220,
      duracionSegundos: 0.35,
      tipoOnda: 'sawtooth',
      volumen: 0.28,
      frecuenciaFiltroPasaBajos: 1100,
    );
    _reproducirNota(
      frecuenciaInicialHz: 260,
      frecuenciaFinalHz: 180,
      duracionSegundos: 0.38,
      tipoOnda: 'sine',
      volumen: 0.22,
      retardoInicioSegundos: 0.04,
    );
  }

  void reproducirTransicionEscenario() {
    _reproducirNota(
      frecuenciaInicialHz: 180,
      frecuenciaFinalHz: 540,
      duracionSegundos: 0.5,
      tipoOnda: 'sawtooth',
      volumen: 0.28,
      frecuenciaFiltroPasaBajos: 2000,
    );
  }

  void reproducirFanfarriaVictoria() {
    const frecuenciasArpegioCMayor = [261.63, 329.63, 392.0, 523.25];
    for (int indiceNota = 0;
        indiceNota < frecuenciasArpegioCMayor.length;
        indiceNota++) {
      _reproducirNota(
        frecuenciaInicialHz: frecuenciasArpegioCMayor[indiceNota],
        duracionSegundos: 0.22,
        tipoOnda: 'triangle',
        volumen: 0.35,
        retardoInicioSegundos: indiceNota * 0.14,
      );
    }
  }

  void reproducirDoblesCampanasDerrota() {
    const frecuenciasAcordeMenor = [196.0, 233.08, 277.18];
    for (int indiceNota = 0;
        indiceNota < frecuenciasAcordeMenor.length;
        indiceNota++) {
      _reproducirNota(
        frecuenciaInicialHz: frecuenciasAcordeMenor[indiceNota],
        duracionSegundos: 0.9,
        tipoOnda: 'sawtooth',
        volumen: 0.18,
        frecuenciaFiltroPasaBajos: 1200,
        retardoInicioSegundos: indiceNota * 0.05,
      );
    }
  }

  void reproducirSubidaDeNivel() {
    const frecuenciasArpegioAscendente = [392.0, 523.25, 659.25, 783.99];
    for (int indiceNota = 0;
        indiceNota < frecuenciasArpegioAscendente.length;
        indiceNota++) {
      _reproducirNota(
        frecuenciaInicialHz: frecuenciasArpegioAscendente[indiceNota],
        duracionSegundos: 0.18,
        tipoOnda: 'sine',
        volumen: 0.3,
        retardoInicioSegundos: indiceNota * 0.09,
      );
    }
  }
}

/// Instancia singleton del servicio de audio. Compartida por toda la app.
final audioProcedural = AudioProcedural();
