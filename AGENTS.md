# Instrucciones para agentes (Codex / Claude Code / cualquier asistente)

**Antes de generar UNA SOLA imagen para este proyecto, lee este archivo
y aplica TODO lo que dice, sin excepciones.**

## 1. Qué es esto

*Camarada del Vacío* es un RPG Flutter web con estética cosmo-soviética
absurda. El arte tiene una única regla visual y una única regla de
paleta. Cuando un asset se sale de cualquiera de las dos, se descarta.

## 2. Estilo OBLIGATORIO (regla de oro)

**Garabato minimalista inspirado en *West of Loathing*.**

- Stick figure plano, silueta clarísima, **muy pocas líneas**.
- Cero detalle realista. Cero textura pintada. Cero degradados suaves.
- Trazo grueso, ligeramente tembloroso, hecho a rotulador sobre papel.
- Cross-hatching mínimo (4-6 líneas) sólo para sombras.
- **La imagen entera tiene que poder describirse en menos de 10 trazos.**

**Lo que NO es este estilo:**
- Foto realista de cualquier cosa (perros, paisajes, retratos, etc.).
- Renders 3D, estilo Pixar, anime, cómic moderno.
- Pintura digital con sombreado por degradado.
- Cualquier color que no sea negro o el rojo concreto de abajo.

## 3. Paleta ESTRICTA

| Rol | Hex |
|---|---|
| Papel viejo (fondo) | `#F5F1E8` |
| Papel sombra | `#E8E2D2` |
| Tinta negra (todos los trazos) | `#15110D` |
| Tinta tenue (gris medio único) | `#625E58` |
| Rojo oficial (único color de acento) | `#C8102E` |
| Rojo sombra | `#8A0A1F` |

**No hay otros colores.** Ni marrones, ni azules, ni verdes, ni
amarillos, ni naranjas, ni grises azulados. Si el prompt o el modelo
introducen alguno, la imagen NO sirve.

## 4. Anchors visuales (referencia obligada antes de generar)

Antes de pedir cualquier imagen nueva, **mira estas que YA están en
estilo correcto**:

- `assets_anchors_historicos/madre_ferruginosa_v2.png` — NPC mujer.
  (Histórico: fuera del bundle Flutter; sólo referencia visual.)
- `assets_anchors_historicos/capitan_vassiliev_v3.png` — NPC hombre
  sentado. (Histórico: fuera del bundle Flutter.)
- `assets/svg/ostrog.png` — NPC hombre con pipa.
- `assets/svg/archivador.png` — mueble alto.
- `assets/svg/samovar_oficial.png` — mueble industrial.
- `assets/svg/compuerta.png` — puerta acorazada.
- `assets/svg/mesa_cantina.png` — mueble bajo.
- `assets/svg/radio_cantina.png` — objeto pequeño.

Si el asset que vas a generar es un NPC, **incluye una de las dos
primeras como image input en la llamada al modelo de imágenes**, no sólo
como mención de texto. Si es un mueble, idem con archivador/samovar.
Sin anchor visual, el resultado se desvía siempre.

## 5. Palabras que el filtro de seguridad rechaza

Estos términos disparan el safety filter de OpenAI y devuelven un
fallback genérico (perro feliz, paisaje, retrato neutro). **Evítalos
o sustitúyelos** por las alternativas seguras:

| Palabra que dispara filtro | Alternativa segura |
|---|---|
| `Soviet propaganda` | `1960s constructivist poster art` |
| `Soviet`, `KGB`, `comunista` | `bureaucratic`, `ministerial`, `institutional` |
| `rifle`, `gun`, `weapon` | `inspection baton`, `ceremonial pole`, `office tool` |
| `stamp` (en contexto agresivo) | `seal mark`, `ink press` |
| `attack`, `kill`, `wound` | `inspect`, `confront`, `summon` |
| `Brigada del Sello` | `Office of Inspection inspectors` |
| `antirrevolucionario` | `non-compliant`, `irregular` |
| `Comité` (con KGB connotation) | `Bureau`, `Ministry`, `Council` |

El tono temático del juego SE PUEDE mantener describiéndolo como
**absurdo burocrático con estética de papel envejecido y propaganda
constructivista de los 60**, sin nombrar directamente la URSS.

## 6. Estructura de carpetas de salida

| Tipo de asset | Carpeta | Formato |
|---|---|---|
| Portada / cinemática / fondo planetario | `assets/images/` | PNG 1280×720 o 1920×1080, fondo papel #F5F1E8 |
| NPCs (personaje completo) | `assets/svg/` o `assets/images/` | PNG transparente 600×900 |
| Muebles / decorados | `assets/svg/` | PNG transparente 400×400 a 800×800 |
| Sellos / iconos / insignias | `assets/svg/` | PNG transparente 256×256 |
| Frames de animación (set §10) | mismo lugar que el estático | mismo lienzo, mismo anclaje pixel a pixel |

**Nombres**: respeta los del briefing (`BRIEFING_ARTE.md`). El cableado
en el código ya espera esos nombres exactos; si los cambias, hay que
re-cablear a mano.

## 7. Flujo correcto antes de generar una imagen

1. Abrir `BRIEFING_ARTE.md` y localizar la sección de ese asset (1.x,
   2.x, 3.x, 7.x.x, 10.x…). El prompt completo ya está redactado allí.
2. Listar `assets/images/` y `assets/svg/` y ver cuál ya está hecho —
   no regenerar lo que existe. La sección "Estado actual" al final del
   briefing dice qué hay hecho y qué falta.
3. Elegir uno o dos anchors visuales (sección 4) del mismo "tipo"
   (NPC, mueble, fondo) que el asset nuevo.
4. Construir el prompt: copiar literalmente la "Línea base" del
   briefing §0 + el prompt específico de la sección correspondiente +
   sustituir palabras peligrosas según tabla §5 + adjuntar los
   anchors como image input.
5. Generar.
6. Revisar: ¿se sale de la paleta? ¿hay detalle realista? ¿hay
   degradados? Si sí — descarta y vuelve a 4 ajustando el prompt.

## 8. Cuando falla (saber descartar)

Si recibes una imagen que es:
- Una foto realista de un perro/persona/paisaje → **fallback de
  seguridad activado**. El prompt original tenía palabras de la
  tabla §5. Reescríbelo y vuelve a intentar.
- Renderizada en estilo cómic moderno, Pixar, anime, óleo digital
  → el modelo ignoró el estilo. Aumenta peso de "minimalist doodle
  pen-stroke" y baja peso/elimina menciones de detalles internos del
  personaje.
- Con colores fuera de paleta → añade al final del prompt: "STRICTLY
  two-color: black ink + single red (#C8102E). No browns, blues,
  greens, yellows. Hard fail if any other color appears."

## 9. NO HACER

- No regenerar imágenes que ya existen en `assets/`. Cada PNG ya
  cableado costó iteraciones; tirarlo a la basura es un retroceso.
- No inventar nombres de archivo. Usa los que dicta el briefing.
- No saltarse el paso de mirar las imágenes anchor antes de generar.
- No subir imágenes "para ver si encaja". Si no encaja claramente con
  los anchors, no subir.

Para todo lo demás, consulta `BRIEFING_ARTE.md` (es el documento
canónico de arte; este AGENTS.md es sólo el resumen ejecutivo).
