# Camarada del Vacío — Guía de prueba y lluvia de ideas

> **Para el equipo de prácticas.** Esto es un RPG cosmo-soviético satírico
> hecho en Flutter web. Estética "garabato West of Loathing": tinta papel
> viejo, dos tintas (negra + rojo soviético), nada realista. Es absurdo
> a propósito: burocracia espacial, sellos F-447, decretos.

---

## 0. Acceso

**URL de pruebas**: <https://gailu.it/desarrollo/games/cv/>

- Navegador: **Chrome / Firefox / Edge actualizados**. Safari debería ir
  pero está sin probar.
- Resolución mínima cómoda: **1280×800**. Por debajo se ve apretado.
- **Móvil**: NO soportado oficialmente. Si lo pruebas en móvil reporta
  qué pasa pero no son bugs prioritarios.
- Primera carga tarda 5-15 s (descarga ~98 MB). Recargas posteriores
  cachean casi todo. Si se queda colgado: vacía caché del navegador
  (`Ctrl+Shift+R`).

---

## 1. Controles

### Escenarios libres (cápsula, cantina, reactor, planetas)

| Acción | Tecla / Input |
|---|---|
| Mover cadete | `W A S D` o **flechas** |
| Correr | mantener `Shift` |
| Interactuar / hablar / leer | `E` o `Espacio` (sobre hotspot) |
| Modo Bola (rodar) | `B` (donde esté disponible) |
| Click ratón | mueve al cadete al punto / activa hotspot |

### Minijuegos

Cada minijuego tiene su esquema. **Lee las instrucciones en pantalla**
al entrar — todos las muestran. En general:

| Acción | Tecla |
|---|---|
| Movimiento | `WASD` / flechas |
| Disparo / acción | `J` / `Z` / `Espacio` / click |
| Pausa | `P` |
| Salto (los que aplican) | `W` / `↑` / `Espacio` |

### Combate

Por turnos, con habilidades por clase. Las teclas se muestran en pantalla.

---

## 2. Ruta de prueba recomendada (~30 min)

Hazla en este orden la primera vez para tener contexto narrativo:

1. **Pantalla de título** → arrancar.
2. **Selección de clase** → prueba las 3 (Comisaria / Gimnasta / Ingeniera).
3. **Cápsula del cadete** (interior, primer escenario) → mueve el cadete,
   interactúa con hotspots (catre, espejo, archivador, vela…), prueba
   el modo bola si está disponible.
4. **Cantina** → habla con NPCs, mira a Laika (la mascota), prueba diálogos.
5. **Reactor** → más hotspots, lee carteles.
6. **Mapa del overworld** → entra a un planeta (cualquiera).
7. **Cualquier planeta** (Pravda-7, Gélida-9, Zovnak-4, Sol Camarada) →
   recorrer, hablar, buscar entradas a minijuegos / combate.
8. **Un combate** (si encuentras un enemigo) → prueba todas las habilidades.
9. **Minijuegos** → idealmente los 8 (lista en §3).

Si tienes poco tiempo: título → clase → cápsula → un planeta → un
minijuego → un combate.

---

## 3. Inventario de escenarios y minijuegos

### Escenarios libres
- **Cápsula del cadete** (`room_screen`) — interior, 9 hotspots.
- **Cantina** (`canteen_screen`) — interior, NPCs.
- **Reactor** (`reactor_screen`) — interior, vela, etc.
- **Mapa Overworld** (`overworld_map_screen`) — selección de planeta.
- **Cuadrante Sigma** (`cuadrante_sigma_screen`).
- **Planeta Pravda-7** (pasillo interior, túneles).
- **Planeta Gélida-9** (tundra nevada).
- **Planeta Zovnak-4** (desierto agrietado, pirámides).
- **Planeta Sol Camarada** (llanura administrativa con domos).

### Minijuegos (sección numerada interna §N)
- **§13 Cosmoom Doom** — FPS pseudo-3D estilo Wolfenstein.
- **§14 Snow Kamarada** — plataformas estilo Snow Bros con cadete ushanka.
- **§15 Camarada Invasors** — Space Invaders con tío Sam, soldados,
  hamburguesas, Coca-Cola.
- **§16 Inspektor Pac-Man** — laberinto con komisarios y expedientes.
- **§17 Pixel Perdido** — plataformas pixel-art.
- **§18 Frecuencia 747** — radio analógica buscando estaciones secretas.
- **§19 Dokumentris** — Tetris con sellos F-447 (7 piezas).
- **§21 Super Pang Galáctico** — globos burocráticos cayendo, arpón.
- **Pinball del Comité** — pinball con el Camarada Directorskov fantasma.
- **Bóveda de los Sueños** — variante onírica.

### Sistemas globales
- **Combate por turnos** (`combat_screen`) — 3 clases, habilidades únicas.
- **Transformaciones** del cadete (aguja de radio, pieza Tetris, bola
  de nieve…) — transiciones narrativas.
- **Epílogo** (cuando completas la ruta principal).

---

## 4. Qué buscar (checklist por categoría)

### 4.1 Bugs visuales

- [ ] **Sprites flotando**: el cadete o un mueble que no toca el suelo
  dibujado.
- [ ] **Sprites atravesando paredes** (mete los pies en una pared del
  fondo).
- [ ] **Tamaños desproporcionados**: cadete enano, mueble gigante,
  bola enorme, etc.
- [ ] **Sprite que NO coincide con el resto del juego** (ej. cadete
  procedural feo donde debería verse el cadete dibujado).
- [ ] **Texturas mal estiradas / pixeladas / deformadas**.
- [ ] **Texto cortado, oculto, fuera del bocadillo**.
- [ ] **Capas mal ordenadas** (cadete detrás de un mueble cuando debería
  estar delante, o al revés).
- [ ] **Fondo desplazado**: el suelo dibujado y la línea lógica donde
  pisa el cadete no coinciden.

### 4.2 Bugs de lógica / física

- [ ] **El cadete no puede llegar a una zona del fondo** que claramente
  parece pisable (suelo dibujado pero el cadete se detiene antes).
- [ ] **El cadete sube por el cielo / techo** (el límite superior es
  más alto de lo que parece pisable).
- [ ] **Hotspot que no responde** al pasar cerca o pulsar `E`.
- [ ] **En minijuegos: caídas infinitas, atravesar suelo, atravesar
  enemigos, disparos que no llegan**.
- [ ] **Pausa que no pausa** algo (animación que sigue corriendo).
- [ ] **Reset al morir** que deja el juego en estado raro.

### 4.3 Bugs de control / input

- [ ] **Una tecla queda "pegada"** (el cadete sigue moviéndose tras
  soltarla).
- [ ] **Pierde el foco**: pulsar tecla y no responde.
- [ ] **Click en hotspot pequeño** que no se registra.

### 4.4 UX / claridad

- [ ] **¿Entiendes qué tienes que hacer al entrar a cada zona?** Si
  no — apunta dónde te perdiste.
- [ ] **¿Las instrucciones de los minijuegos son claras?**
- [ ] **¿Algún hotspot interactivo no tiene indicador visual** de que
  puedes interactuar?
- [ ] **¿La fuente / tamaño de texto se lee bien** en tu resolución?

### 4.5 Texto / contenido

- [ ] **Faltas de ortografía o de estilo** (el tono debería ser
  burocrático-absurdo soviético; si suena "normal" o "moderno", apunta).
- [ ] **Cosas en otro idioma** colándose donde no toca (placeholders,
  textos en inglés…).
- [ ] **Frases que se repiten demasiado**.

### 4.6 Consola del navegador (opcional pero útil)

Si sabes abrir DevTools (F12) → **pestaña Console**:
- Apunta cualquier `error` rojo. Especialmente `404`, `Uncaught
  Exception`, `Failed to load`. Pega el texto completo en el reporte.

---

## 5. Cómo reportar

Para cada hallazgo, usa este formato:

```
TÍTULO: (1 línea, qué pasa)

TIPO: [bug | idea | confusión | mejora]

DÓNDE: (qué pantalla / minijuego / momento)

PASOS PARA REPRODUCIR (sólo bugs):
1. ...
2. ...
3. ...

RESULTADO ACTUAL:
...

RESULTADO ESPERADO:
...

CAPTURA / VÍDEO: (adjunta si puedes — `Print` o herramienta de
captura). Para vídeo: ShareX / OBS / la grabadora de Windows.

GRAVEDAD: [bloqueante | grave | molesto | menor | cosmético]

NAVEGADOR / RESOLUCIÓN: (Chrome 130 / 1920×1080)
```

Para **ideas** y **mejoras** basta con TÍTULO + DÓNDE + descripción.

---

## 6. Lluvia de ideas — áreas abiertas

Estamos especialmente abiertos a ideas en:

### 6.1 Minijuegos nuevos
¿Algún clásico de los 80/90 que encaje con la sátira burocrática
soviética? Pensar en "fórmula del juego clásico + giro absurdo
de bureaucracia + estética tinta". Ej. existentes: Tetris se convirtió
en estampar formularios.

### 6.2 Diálogos y NPCs
- Frases nuevas para Laika (la mascota cosmonauta).
- Diálogos para NPCs de la cantina.
- Carteles, decretos, panfletos absurdos para los planetas.
- Eslóganes propagandísticos.

### 6.3 Hotspots con flavor
Cualquier objeto del fondo que merezca interacción y una frase
absurda (un cartel oxidado, un samovar, un panel rojo…).

### 6.4 Sellos / coleccionables
Sistema de "sellos F-447 conseguidos" como achievements. ¿Qué
sellos te imaginas? (Ej. "Sello Burocrático del Sufrimiento
Inútil — entregado por leer todos los carteles de Pravda-7").

### 6.5 Power-ups y consumibles
Estilo del power-up Café que ya existe en Snow Kamarada. ¿Qué
otros bebibles / objetos rusificados podrían existir? (vodka
ratificado, samovar de campaña, kvas oficial…).

### 6.6 Transiciones narrativas
Las transformaciones del cadete (en aguja de radio, en pieza
Tetris, en bola de nieve…) son momentos de transición. ¿Qué otra
transformación cabría con cuál minijuego?

### 6.7 Final / epílogo
¿Qué ending alternativo daría más jugo a la sátira?

---

## 7. Estado conocido — **NO reportar como bugs**

Estos puntos están en backlog. Si los encuentras, ignóralos:

1. **Cápsula del cadete — muebles "duplicados"**: el fondo de la cápsula
   tiene muebles dibujados y antes existían hotspots PNG encima que se
   solapaban. **Ya están desactivados** los hotspots conflictivos
   (catre, espejo, etc. siguen siendo hotspots invisibles funcionales,
   sólo se quitó la imagen extra). Si ves muebles dobles aún, sí
   reporta.

2. **Animaciones §10 pendientes**: golpe de combate, idle respira, cola
   de Laika animada, ataque de Brigada del Sello. Falta generar los
   PNGs. Donde se ven, hay fallback procedural — si te parece
   "feo pero estable" eso es ese fallback, no un bug.

3. **3 escenarios interiores con borde inferior conservador**: cápsula,
   cantina, reactor no se ha re-validado el `bordeInferior` contra los
   fondos. Si el cadete no baja del todo en esos tres → es conocido
   (apúntalo igual con cuál escenario, sirve).

4. **Primera carga lenta** la primera vez: ~98 MB de assets. Esperable.

5. **Caché agresiva**: si tras un update sigues viendo cosas viejas,
   `Ctrl+Shift+R` o pestaña incógnita.

---

## 8. Formato del informe final

Cuando termines la ronda, envía:

- **Un documento** (Markdown / Google Docs / lo que sea) con
  todas las entradas en el formato de §5.
- **Ordenado por gravedad** (bloqueante → cosmético) dentro de cada
  tipo (bugs primero, luego ideas).
- **Una sección "Impresión general"** al final: ¿el juego es divertido?
  ¿qué te sobró / qué te faltó? ¿qué minijuego se llevó la palma y
  cuál era el más flojo?

No hace falta probar TODO en una sola sesión. Mejor 2 sesiones de
una hora con buen reporte que 4 horas seguidas y notas a medias.

---

## 9. Contacto rápido

Cualquier duda durante la prueba — apúntala como **"confusión"** en
el reporte, con qué tratabas de hacer y qué esperabas. Eso también
es señal valiosa.

¡Gracias por la mano! Disfruta la burocracia espacial.
