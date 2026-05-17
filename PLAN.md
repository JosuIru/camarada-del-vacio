# Plan de desarrollo — Camarada del Vacío

> Documento canónico de seguimiento. Persiste entre sesiones.
> Acompaña a `BRIEFING_ARTE.md` (canónico de arte) y `AGENTS.md`
> (reglas para asistentes). Cada vez que se completa una fase,
> marcarla en este archivo y actualizar también la sección
> "Estado actual" del briefing (línea 1804).

Última actualización: 2026-05-17.

## Estado en una línea

Núcleo del juego cableado y jugable. Pinball del Comité (§11)
completo. **Pendiente: cableado de los 9 minijuegos satélite
(§12-§21) y 4 animaciones de pulido (§10.2/.3/.8/.16).** Cero
assets generados para §12-§21 — render procedural en todos.

## Fase 0 — Infraestructura (prerequisito)

- [x] **F0.1 — Inicializar git** (hecho 2026-05-17): `git init -b main`
  con `.gitignore` actualizado para excluir `tmp/`, `tmp_*.svg/png`.
  Primer commit baseline: `acf3cbc chore: baseline inicial del
  proyecto` con 299 archivos.
- [x] **F0.2 — Baseline limpio** (hecho 2026-05-17): `flutter analyze`
  → "No issues found!" en 3.1s. Flutter 3.41.9 estable, framework
  rev 00b0c91f06. Pendiente: `flutter test` (sin tests escritos
  todavía; carpeta `test/` vacía o mínima).
- [x] **F0.3 — Auditoría del briefing** (hecha 2026-05-17):
  corregido "8 hotspots" → "9 hotspots" en §12; añadidas
  dimensiones 600×900 a §10.16. Resto de prompts §10-§21
  completos y verificados.

## Fase 1 — Hotspots de la cápsula (§12)

**Prioridad máxima**: la cápsula es el primer escenario del
juego. Es donde el jugador pasa más rato en estado de exploración
estática. 9 PNGs sustituyen 9 `SizedBox.shrink()`.

- [ ] **F1.1** — Generar los 9 PNGs (`capsula_retrato_familiar`,
  `_catre`, `_mesilla_vela`, `_espejo_lavabo`, `_estante_libros`,
  `_uniforme_colgado`, `_calendario`, `_intercomunicador`,
  `_manguera_combustible`). Prompts: §12.1-§12.9.
- [ ] **F1.2** — Sustituir en `lib/screens/room_screen.dart`
  cada `representacion: const SizedBox.shrink()` por
  `IconoHotspotImagen` con la tabla de `anchoSombra` (briefing
  líneas 2755-2767).
- [ ] **F1.3** — Verificar in-game: cargar la cápsula, comprobar
  que las 9 representaciones aparecen y que `IconoHotspotImagen`
  no muestra sombra-fantasma para los que aún falten.
- [ ] **F1.4** — Actualizar §"Estado actual" del briefing.

## Fase 2 — Minijuegos prioridad alta (§13-§15)

**Por qué primero estos**: el briefing los marca como "alta
prioridad" y son los tres más visibles después del Pinball.

### F2.A — Cosmoom Doom (§13, 5 sprites)
- [ ] Generar: `doom_pared_ministerio` (512×512 tileable),
  `doom_suelo_baldosa` (512×512 tileable XY), `doom_mesa_burocratica`
  (320×440), `doom_sello_proyectil` (160×160),
  `doom_hud_cadete` (800×260).
- [ ] Cablear en `lib/minijuegos/pantalla_cosmoom_doom.dart`:
  replicar patrón existente de la línea 122 (`_cargarImagenDesdeAsset`
  + `ui.Image?` + Future.wait). En `_PintorVistaDoom`, columna
  por columna, sustituir `canvas.drawRect` por `canvas.drawImageRect`
  consultando la columna correspondiente de la textura.

### F2.B — Snow Kamarada (§14, 8 sprites)
- [ ] Generar: 4 frames del cadete-ushanka caminando, capitalista
  espacial, formulario F-447 proyectil, bola de papel sellada,
  fondo paisaje gélido (1920×1080).
- [ ] Cablear en `pantalla_snow_kamarada.dart` con el patrón
  pinball (`_cargarSpritesPinballOpcionales`): 8 `ui.Image?`,
  carga en `initState` con `try/catch + Future.wait`, paso al
  painter, `drawImageRect` con fallback.

### F2.C — Camarada Invasors (§15, 7+ sprites)
- [ ] Generar: Tío Sam invasor, soldado USA, hamburguesa, Coca-Cola,
  cañón burocrático, bunker F-447, proyectil rojo, proyectil dollar.
- [ ] Cablear en `_PintorMundoInvasors` (línea ≈703): sustituir
  cada `_dibujar*` procedural por `drawImageRect`. Convertir la
  animación de patas oscilantes en sutil `Transform.translate` Y
  del sprite estático.

## Fase 3 — Minijuegos prioridad media (§16-§18)

### F3.A — Inspektor Pac-Man (§16, 8 sprites)
- [ ] Generar: inspektor jugador, 4 komisarios (gorro/monóculo/
  bigote/pipa) con misma silueta base, expediente pellet, tinta
  power-up, fondo laberinto (880×1100).
- [ ] Cablear en `pantalla_inspektor_pacman.dart` mismo patrón.

### F3.B — Pixel Perdido (§17, 5 sprites pixel-art)
- [ ] Generar: cadete pixel idle (64×96), kopek (48×48), charco
  tinta (96×48), bloque sólido tile (64×64), bandera meta (64×128).
  **Único módulo pixel-art puro** — confirmar paleta/grid coherente
  antes de generar.
- [ ] Cablear en `pantalla_pixel_perdido.dart`.

### F3.C — Frecuencia 747 (§18, 5 sprites)
- [ ] Generar: marco completo radio (1100×750), aguja dial
  (40×140), aguja VU (100×100), pulso sintonizado (240×240),
  panel mensaje (600×220).
- [ ] Cablear en `_PintorDialRadio` (línea ≈637): colapsar el
  chasis a una sola `drawImageRect` cuando `radio_marco_completo`
  esté cargado. Las dos agujas siguen siendo runtime
  (rotación/translación geométrica).

## Fase 4 — Minijuegos prioridad baja (§19-§21)

### F4.A — Dokumentris (§19, 8 sprites)
- [ ] Generar: 7 celdas-sello (`dokumentris_celda_<id>.png`,
  80×80 c/u) + marco escritorio (1000×1400).
- [ ] Cablear como `Map<int, ui.Image?>` por tipo de pieza.
  Sustituir `drawRect` por `drawImageRect` en
  `_PintorTableroDokumentris` y `_PintorPiezaPreview`.

### F4.B — Transformaciones del cadete (§20, 2 sprites nuevos)
- [ ] Generar: `transform_cadete_pieza_tetris.png` (240×360) y
  `transform_cadete_aguja_radio.png` (80×280).
- [ ] Reutilizar `pacman_inspektor.png` (§16.1) para `comecocos`
  y `snow_bola_papel.png` (§14.4) para `bolaNieve` — esto crea
  dependencia: §20 depende de §16 y §14.
- [ ] Cablear en `_PintorTransformacion.paint` (línea ≈256):
  sustituir cada caso del `switch(formaDestino)` por
  `drawImageRect` con fallback procedural.

### F4.C — Super Pang Galáctico (§21, 5 sprites)
- [ ] Generar: 3 globos (grande 280, medio 200, pequeño 120) +
  arpón (40×500) + banner nivel (700×200).
- [ ] Cablear en `_PintorSuperPang.paint`: sustituir `drawCircle`
  por `drawImageRect` según tamaño. Banner como overlay aparte
  (no parte del painter).

## Fase 5 — Pulido de animaciones (§10)

- [ ] **F5.1 — §10.2 Cadete golpe**: 3 frames (`cadete_golpe_f01..f03.png`,
  600×900). Hoy es un solo `Transform`. Sustituye en `combat_screen.dart`
  donde se anima la habilidad melee.
- [ ] **F5.2 — §10.3 Laika cola idle**: 2 frames (`laika_idle_f01.png`,
  `_f02.png`, 400×400). Reemplaza el wag procedural en la cantina.
- [ ] **F5.3 — §10.8 Brigada del Sello ataque**: 3 opcionales
  (`brigada_sello_garrote_ataque`, `_punos_ataque`, `_rifle_ataque`).
  Mismo lienzo que los idle. Alternar al golpear en combate.
- [ ] **F5.4 — §10.16 Cadete idle respira**: 2 frames
  (`cadete_idle_breath_f01..f02.png`, 600×900). Subtle, escenas de
  diálogo estáticas.

## Fase 6 — Bugs y deuda técnica conocida

- [ ] **F6.1 — TODO mascota_narrativa.dart:28**: confirmar que la
  mascota NO aparece en todas las visitas a todos los escenarios
  (sólo a veces). Revisar probabilidad/cooldown. Eliminar el
  comentario TODO al terminar.
- [ ] **F6.2 — Acceso debug en producción**: `title_screen.dart:328`
  y `:590` muestran "ACCESO RÁPIDO · MENÚ DE DEBUG". Confirmar que
  está detrás de un flag o eliminarlo antes de release final.
- [ ] **F6.3 — `dart:js_interop` sin conditional import**
  (detectado 2026-05-17): `lib/utilities/audio_procedural.dart:1`
  importa `dart:js_interop` directamente. Sólo existe en web →
  rompe `flutter test` (VM). Hace que sea imposible escribir
  widget tests que toquen `title_screen.dart`. Solución: stub
  pattern con conditional import o `kIsWeb` guard.
- [ ] **F6.4 — Tests obsoletos**: `test/widget_test.dart` busca
  texto "CAMARADA" / "DEL VACÍO" que ya no existen (el título es
  imagen `portada_principal.png`). Sustituir por aserciones
  verificables. Tras F6.3+F6.4, debe pasar `flutter test --platform chrome`.

## Verificaciones rápidas que han pasado

- ✅ `flutter analyze` → "No issues found!" (Flutter 3.41.9, 2026-05-17).
- ❌ `flutter test` → falla por F6.3 (import web).
- ❌ `flutter test --platform chrome` → falla por F6.4 (test obsoleto).

## Patrón canónico de cableado (referencia)

Validado en pinball (§11) y replicado en Doom (§13). Para cada
minijuego nuevo:

```dart
// 1. Campos en el State
ui.Image? imagenFoo;
ui.Image? imagenBar;

// 2. Helper compartido (ya existe en doom: línea 122)
Future<ui.Image> _cargarImagenDesdeAsset(String ruta) async {
  final ByteData datos = await rootBundle.load(ruta);
  final ui.Codec codec = await ui.instantiateImageCodec(
    datos.buffer.asUint8List(),
  );
  final ui.FrameInfo frame = await codec.getNextFrame();
  return frame.image;
}

// 3. Carga paralela tolerante a faltantes en initState
@override
void initState() {
  super.initState();
  _cargarSprites();
}

Future<void> _cargarSprites() async {
  final resultados = await Future.wait([
    _cargarOpcional('assets/svg/foo.png'),
    _cargarOpcional('assets/svg/bar.png'),
  ]);
  if (!mounted) return;
  setState(() {
    imagenFoo = resultados[0];
    imagenBar = resultados[1];
  });
}

Future<ui.Image?> _cargarOpcional(String ruta) async {
  try {
    return await _cargarImagenDesdeAsset(ruta);
  } catch (_) {
    return null;  // fallback procedural mantiene la pantalla viva
  }
}

// 4. Pasar al painter como `final ui.Image?`
// 5. En el painter: `if (imagen != null) drawImageRect(...) else <procedural>`
```

## Orden recomendado de ejecución

1. **Fase 0** completa antes de tocar arte (git + analyze).
2. **Fase 1 (cápsula)** — visibilidad/jugador antes que minijuegos.
3. **Fase 2** en paralelo si puedes generar arte en lotes; si no,
   F2.A → F2.B → F2.C en ese orden.
4. **Fase 3** después de Fase 2.
5. **Fase 4** después de Fase 3 (F4.B depende de F2.B y F3.A
   completos para reutilizar sprites).
6. **Fase 5** (pulido §10) — se puede hacer en cualquier momento
   tras Fase 0; no bloquea minijuegos.
7. **Fase 6** (bugs) — antes del release final.

## Cómo medir progreso

Tras cada fase: actualizar la sección "Estado actual" de
`BRIEFING_ARTE.md:1804` con el ✅ correspondiente y marcar la
fase aquí como completa. Si la auditoría textual del briefing
y el `ls assets/svg/` divergen, la verdad es el filesystem —
corregir el briefing.
