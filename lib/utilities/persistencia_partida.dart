import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';
import '../models/game_class.dart';
import '../models/game_state.dart';

/// Servicio de persistencia de la partida del cadete. Serializa el estado
/// completo a JSON y lo guarda en SharedPreferences (localStorage en web).
/// Soporta un único slot principal y un auto-save independiente que se
/// actualiza al cambiar de escenario.
class PersistenciaPartida {
  static const String _claveSlotPrincipal = 'camarada_partida_slot_principal';
  static const String _claveSlotAutoguardado =
      'camarada_partida_slot_autoguardado';
  static const String _claveSelloVersion = 'camarada_persistencia_version';
  static const int _versionPersistenciaActual = 1;

  /// Serializa el estado completo de la partida a un mapa JSON-able.
  /// Incluye personaje, flags, inventario, equipo, nivel, XP, compañero y
  /// salas visitadas.
  Map<String, dynamic> serializarEstado(EstadoJuego estado) {
    return {
      'version': _versionPersistenciaActual,
      'personaje': _serializarPersonaje(estado.personaje),
      'flagsActivos': estado.flagsActivos.toList(),
      'inventario': estado.inventario,
      'buffsActivos': estado.buffsActivosPorTurnos,
      'cuotaBurocratica': estado.cuotaBurocratica,
      'ultimoModuloVisitado': estado.ultimoModuloVisitado,
      'experienciaAcumulada': estado.experienciaAcumulada,
      'nivelCadete': estado.nivelCadete,
      'idObjetoCabezaEquipado': estado.idObjetoCabezaEquipado,
      'idObjetoArmaEquipada': estado.idObjetoArmaEquipada,
      'idObjetoTorsoEquipado': estado.idObjetoTorsoEquipado,
      'companeroFerruginosaActivo': estado.companeroFerruginosaActivo,
      'salasVisitadasUnaVez': estado.salasVisitadasUnaVez.toList(),
    };
  }

  /// Reconstruye un EstadoJuego a partir del mapa JSON. Si el mapa viene
  /// de una versión anterior, intentamos aplicar valores por defecto para
  /// los campos nuevos.
  EstadoJuego deserializarEstado(Map<String, dynamic> mapaSerializado) {
    final mapaPersonaje =
        Map<String, dynamic>.from(mapaSerializado['personaje'] as Map);
    final personajeReconstruido = _deserializarPersonaje(mapaPersonaje);

    final flagsRaw = mapaSerializado['flagsActivos'] as List? ?? const [];
    final inventarioRaw =
        Map<String, dynamic>.from(mapaSerializado['inventario'] as Map? ?? {});
    final buffsRaw = Map<String, dynamic>.from(
        mapaSerializado['buffsActivos'] as Map? ?? {});
    final salasRaw =
        mapaSerializado['salasVisitadasUnaVez'] as List? ?? const [];

    return EstadoJuego(
      personaje: personajeReconstruido,
      flagsActivos: flagsRaw.map((e) => e.toString()).toSet(),
      inventario: inventarioRaw
          .map((clave, valor) => MapEntry(clave, (valor as num).toInt())),
      buffsActivos: buffsRaw
          .map((clave, valor) => MapEntry(clave, (valor as num).toInt())),
      cuotaBurocratica:
          (mapaSerializado['cuotaBurocratica'] as num?)?.toInt() ?? 0,
      ultimoModuloVisitado:
          mapaSerializado['ultimoModuloVisitado'] as String? ?? 'capsula',
      experienciaAcumulada:
          (mapaSerializado['experienciaAcumulada'] as num?)?.toInt() ?? 0,
      nivelCadete:
          (mapaSerializado['nivelCadete'] as num?)?.toInt() ?? 1,
      idObjetoCabezaEquipado:
          mapaSerializado['idObjetoCabezaEquipado'] as String?,
      idObjetoArmaEquipada:
          mapaSerializado['idObjetoArmaEquipada'] as String?,
      idObjetoTorsoEquipado:
          mapaSerializado['idObjetoTorsoEquipado'] as String?,
      companeroFerruginosaActivo:
          mapaSerializado['companeroFerruginosaActivo'] as bool? ?? false,
      salasVisitadasUnaVez:
          salasRaw.map((e) => e.toString()).toSet(),
    );
  }

  Map<String, dynamic> _serializarPersonaje(Combatiente personaje) {
    return {
      'nombre': personaje.nombre,
      'clase': personaje.clase?.name,
      'esJugador': personaje.esJugador,
      'cuerpo': personaje.cuerpo,
      'mente': personaje.mente,
      'carisma': personaje.carisma,
      'puntosVida': personaje.puntosVida,
      'puntosVidaMaximos': personaje.puntosVidaMaximos,
      'moral': personaje.moral,
      'moralMaxima': personaje.moralMaxima,
      'puntosAccionPorTurno': personaje.puntosAccionPorTurno,
      'armaduraFisica': personaje.armaduraFisica,
      'armaduraTecnica': personaje.armaduraTecnica,
      'conviccion': personaje.conviccion,
      'velocidad': personaje.velocidad,
      'intimidado': personaje.intimidado,
      'turnosIntimidado': personaje.turnosIntimidado,
      'euforico': personaje.euforico,
      'turnosEuforico': personaje.turnosEuforico,
    };
  }

  Combatiente _deserializarPersonaje(Map<String, dynamic> mapaPersonaje) {
    final nombreClase = mapaPersonaje['clase'] as String?;
    ClaseCosmonauta? claseDeserializada;
    if (nombreClase != null) {
      try {
        claseDeserializada =
            ClaseCosmonauta.values.firstWhere((c) => c.name == nombreClase);
      } catch (_) {
        claseDeserializada = null;
      }
    }
    final personajeReconstruido = Combatiente(
      nombre: mapaPersonaje['nombre'] as String,
      esJugador: mapaPersonaje['esJugador'] as bool? ?? true,
      clase: claseDeserializada,
      cuerpo: (mapaPersonaje['cuerpo'] as num).toInt(),
      mente: (mapaPersonaje['mente'] as num).toInt(),
      carisma: (mapaPersonaje['carisma'] as num).toInt(),
      puntosVidaMaximos:
          (mapaPersonaje['puntosVidaMaximos'] as num).toInt(),
      moralMaxima: (mapaPersonaje['moralMaxima'] as num).toInt(),
      puntosAccionPorTurno:
          (mapaPersonaje['puntosAccionPorTurno'] as num?)?.toInt() ?? 4,
      armaduraFisica:
          (mapaPersonaje['armaduraFisica'] as num?)?.toInt() ?? 0,
      armaduraTecnica:
          (mapaPersonaje['armaduraTecnica'] as num?)?.toInt() ?? 0,
      conviccion: (mapaPersonaje['conviccion'] as num?)?.toInt() ?? 0,
      velocidad: (mapaPersonaje['velocidad'] as num?)?.toInt() ?? 5,
    );
    // Aplicar PV/moral actuales (pueden ser menores que máximos).
    personajeReconstruido.puntosVida =
        (mapaPersonaje['puntosVida'] as num).toInt();
    personajeReconstruido.moral =
        (mapaPersonaje['moral'] as num).toInt();
    personajeReconstruido.intimidado =
        mapaPersonaje['intimidado'] as bool? ?? false;
    personajeReconstruido.turnosIntimidado =
        (mapaPersonaje['turnosIntimidado'] as num?)?.toInt() ?? 0;
    personajeReconstruido.euforico =
        mapaPersonaje['euforico'] as bool? ?? false;
    personajeReconstruido.turnosEuforico =
        (mapaPersonaje['turnosEuforico'] as num?)?.toInt() ?? 0;
    return personajeReconstruido;
  }

  /// Persiste la partida en el slot principal (acción explícita del usuario).
  Future<bool> guardarPartida(EstadoJuego estado) async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      final cargaSerializada = jsonEncode(serializarEstado(estado));
      await preferencias.setString(_claveSlotPrincipal, cargaSerializada);
      await preferencias.setInt(
          _claveSelloVersion, _versionPersistenciaActual);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Persiste la partida en el slot de auto-guardado. Pensado para llamarse
  /// al cambiar de escenario, terminar combate, completar misión, etc.
  Future<bool> autoguardarPartida(EstadoJuego estado) async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      final cargaSerializada = jsonEncode(serializarEstado(estado));
      await preferencias.setString(_claveSlotAutoguardado, cargaSerializada);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Lee el slot principal y reconstruye la partida. Devuelve `null` si no
  /// hay partida guardada o si la deserialización falla.
  Future<EstadoJuego?> cargarPartidaPrincipal() async {
    return _cargarDesdeClave(_claveSlotPrincipal);
  }

  /// Lee el slot de auto-guardado.
  Future<EstadoJuego?> cargarAutoguardado() async {
    return _cargarDesdeClave(_claveSlotAutoguardado);
  }

  Future<EstadoJuego?> _cargarDesdeClave(String clave) async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      final cargaSerializada = preferencias.getString(clave);
      if (cargaSerializada == null || cargaSerializada.isEmpty) return null;
      final mapaSerializado =
          Map<String, dynamic>.from(jsonDecode(cargaSerializada) as Map);
      return deserializarEstado(mapaSerializado);
    } catch (_) {
      return null;
    }
  }

  Future<bool> existePartidaGuardada() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.containsKey(_claveSlotPrincipal) ||
        preferencias.containsKey(_claveSlotAutoguardado);
  }

  Future<void> borrarTodasLasPartidas() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove(_claveSlotPrincipal);
    await preferencias.remove(_claveSlotAutoguardado);
  }
}

/// Instancia singleton accesible desde cualquier pantalla.
final persistenciaPartida = PersistenciaPartida();
