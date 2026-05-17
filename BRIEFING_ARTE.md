# Briefing de Arte — Camarada del Vacío

Documento de referencia para encargar imágenes a generadores tipo ChatGPT/DALL·E,
Midjourney, Imagen-3, Flux, etc. Cada apartado lleva **prompt completo
listo para copiar-pegar**, dimensiones recomendadas y dónde se usaría en el juego.

## 0. Pautas generales (incluir SIEMPRE en cada prompt)

### Paleta exacta del juego

| Rol | Nombre | Hex |
|-----|--------|-----|
| Papel viejo (fondo principal) | `papelViejo` | `#F2EDE0` |
| Papel sombra | `papelSombra` | `#E3DCC8` |
| Tinta negra (todos los trazos) | `tintaNegra` | `#15110D` |
| Tinta tenue / diluida | `tintaTenue` | `#5A4F3F` |
| Rojo oficial (único color de acento) | `rojoOficial` | `#C8102E` |
| Rojo sombra | `rojoSombra` | `#8A0A1F` |
| Verde archivo (uso muy puntual) | `verdeArchivo` | `#6B6B3A` |

**Regla absoluta**: B/N + 1 rojo. **No grises** (sólo papel + tinta). **No otros colores**.

### Estilo

> ⚠️ **REGLA #1 ABSOLUTA — vale para CADA elemento de este briefing**:
> **ilustración manual de tinta sobre papel envejecido**, con herencia
> de garabato naïf y cartel retrofuturista burocrático. Silueta
> clarísima, línea temblorosa, relleno crema y accesorios reconocibles.
> Si dudas entre "más detalle" o "más lectura", siempre gana la lectura.

- **Referente declarado**: la economía expresiva de *West of Loathing*
  cruzada con **cartelismo constructivista de los 60** y humor
  burocrático. No copiar el acabado de un stickman desnudo: el canon
  visual real es el de la portada principal y el cadete aprobado.
- **Técnica visual**: marker / rotulador a mano sobre papel envejecido,
  trazo grueso ligeramente tembloroso, contornos negros sólidos. Sin
  degradados, sin sombreado por degradado, sin volumen pintado. Sólo
  cross-hatching mínimo (4-6 líneas paralelas) cuando hace falta sombra.
- **Densidad de detalle**: priorizar silueta y lectura antes que
  acumulación ornamental. Un personaje debe sentirse vestido y con
  identidad; un mueble puede llevar 1–3 detalles internos clave (un
  cajón, un sello, una etiqueta cirílica) y rayado manual moderado si
  aporta carácter. **Nunca convertirlo en render ni en esquema vectorial
  sin vida.**
- **Tono narrativo**: humor burocrático absurdo cosmo-soviético.
  Cualquier objeto puede tener un sello rojo encima.

### Texto / tipografía si aparece en la imagen

- Etiquetas burocráticas en **monospace** tipo máquina de escribir
  (Special Elite). Texto en mayúsculas con espaciado generoso.
- Títulos en **serif italic** (EB Garamond). Bigotes tipográficos cuidados.
- Carteles a mano en **rotulador** (Permanent Marker).
- Cirílico permitido como elemento decorativo (fragmentos, palabras
  sueltas tipo КОМИТЕТ, ПРАВДА, ИНСПЕКТОР, КАМРАД, КОСМОС).

### Especificaciones técnicas

| Uso | Dimensiones | Formato | Fondo |
|-----|-------------|---------|-------|
| Portada / key art | 1920×1080 o 1280×720 | PNG | Sólido papel `#F2EDE0` |
| NPCs full body (in-game) | 600×900 | PNG transparente | Sin fondo |
| Retratos cabeza (combate) | 400×400 | PNG transparente | Sin fondo |
| Muebles y decorados | 400×400 a 800×800 | PNG transparente | Sin fondo |
| Iconos / sellos | 256×256 | PNG transparente | Sin fondo |
| Ilustraciones de transición | 1280×720 | PNG | Papel `#F2EDE0` |

### Línea base — copia esto al principio de CADA prompt

```
Hand-drawn black-ink illustration on aged cream paper (#F2EDE0):
clear naive silhouettes, dressed characters, recognizable accessories,
slightly trembling contour lines, no realistic rendering, no painted
textures, no shading by gradient.
Strictly two-color palette: black ink (#15110D) and Soviet red (#C8102E).
No greys, no other colors, no gradients beyond the natural paper texture.
Bold, slightly trembling outline strokes. Sparse cross-hatching (4-6
parallel lines) only when shadow is essential.
Retro-bureaucratic space aesthetic with 1960s constructivist poster
influence and absurd institutional humor. The finish must feel like
ink drawn by hand on paper — never a glossy render, never a lifeless
vector diagram.
```

---

## 1. Key art / Portadas (alta prioridad)

### 1.1 Pantalla de título principal

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Splash / title screen. `assets/images/portada_principal.png`.
**Dimensiones**: 1920×1080.

```
Hand-drawn ink marker illustration on aged cream paper (#F2EDE0).
Strictly two-color palette: black ink (#15110D) and Soviet red (#C8102E).
No greys, no other colors, no gradients beyond the natural paper texture.

Composition: A massive Soviet bureaucratic space station "PRAVDA-12"
orbiting a red dwarf star. The station is a brutalist constructivist
geometry — overlapping cylinders, antennas, hammer-and-sickle motifs
welded to the hull. Bottom foreground: silhouette of a cosmonaut cadet
seen from behind, helmet glass reflecting the red star. Top corners:
overlapping rubber-stamp marks (КОМИТЕТ, F-447, СОВ. СЕКРЕТНО) in red.

Title text "CAMARADA DEL VACÍO" in serif italic at the top in black ink,
subtitle "Prólogo: F-447" in monospace red below.

Hand-sketched look, bold contour lines, cross-hatching shadows on the
station. The cadet silhouette is a clear stick figure with a giant
helmet bubble. Slightly trembling lines as if drawn in a worn notebook.
```

### 1.2 Transición entre planetas (4 variantes)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Carga al entrar a cada planeta. `assets/images/transicion_<planeta>.png`.
**Dimensiones**: 1280×720. **Cada planeta tiene la suya.**

#### Planeta Sol Camarada
```
[Línea base] Composition: A red dwarf star labeled "SOL CAMARADA" in
serif italic with concentric solar flares drawn as ink-marker arcs.
A small Soviet probe-rocket approaching from the right, trailing a
dotted line. Bureaucratic stamp "VISA SOLAR · F-447" at bottom right.
Hand-drawn poster look.
```

#### Planeta Gélida-9
```
[Línea base] Composition: A frozen moon "GELIDA-9" covered in cracked
ice patterns drawn as zigzag ink lines. Soviet flag planted on the
surface, the flag flapping despite the no atmosphere. Snowflakes
falling everywhere as small six-pointed asterisks. Cyrillic text
"ХОЛОДНО" (cold) at the top in trembling marker letters.
```

#### Planeta Zovnak-4
```
[Línea base] Composition: A desert planet with cracked clay terrain,
rusted ironwork pyramids in the background. A small cosmonaut silhouette
walking with a portfolio. Two suns drawn in red ink high in the sky.
Caption "ZOVNAK-4 · POLVO Y RUTINA" in monospace black.
```

#### Planeta Pravda-7
```
[Línea base] Composition: A derelict orbital station with no lights,
an ominous silhouette. Broken antennas, drifting papers in the void.
A red blinking light on one of the modules — the only color in the
piece. Caption "PRAVDA-7 · ESTACIÓN PERDIDA" in serif italic black.
```

### 1.3 Pantalla de final / créditos

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Cuando el cadete completa el acto 1. `assets/images/final_acto1.png`.
**Dimensiones**: 1920×1080.

```
[Línea base] Composition: The cosmonaut cadet stick figure standing on
top of a mountain of bureaucratic forms (F-447 stamped papers piled
high), arms raised in V-shape victory pose. Red star explosion behind
him. A small Laika-dog figure with helmet sitting at his feet, looking
up at him. Sky filled with floating ink-stamped forms drifting upward.
Title "ACTO 1 · DEPURADO" at the top in serif italic red. Bottom:
"continuará..." in handwritten marker.
```

---

## 2. NPCs / Personajes (muy alta prioridad)

> **Formato común**: PNG transparente 600×900, personaje centrado, pies
> tocando el borde inferior, cabeza con cierta holgura arriba.

### 2.0 Cadete protagonista (jugador) — set de poses

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Uso**: NO sustituye al `PintorStickFigure` procedimental (que sigue
siendo la base in-game porque soporta sombrero/arma/torso equipables y
animaciones de combate). Estos PNGs se usan en **cinemáticas, retratos
de diálogo a media altura y key art secundario**.

**Dimensiones por pose**: 600×900 PNG transparente.

**Identidad obligatoria del cadete** (repítelo en cada prompt):

- Cadete joven, complexión sencilla, hombros estrechos, proporciones
  ingenuas de dibujo a tinta.
- Casco esférico de cosmonauta con visera curva (no rejilla, no
  detalle de tornillos: sólo silueta de pecera).
- Traje espacial de manga larga, sin guantes detallados; sólo silueta.
- Una banda roja diagonal en el pecho (única traza de color rojo).
- Insignia circular en la manga izquierda — círculo con estrella
  pequeña dentro, dibujado con dos trazos.
- Brazos finos, piernas finas, botas grandes desproporcionadas
  (acentúan la estética de garabato).
- NUNCA cara realista. Boca = una línea o un punto. Ojos = dos puntos
  detrás del visor (apenas visibles).

#### 2.0.1 Cadete idle / saludo (`assets/images/cadete_idle.png`)
```
[Línea base]
Composition: The cadet stick figure standing front-facing, feet
slightly apart, right hand raised in a slow salute, left arm relaxed.
Helmet visor reflects a single white dot. Red diagonal sash across the
chest is the ONLY red element. Background fully transparent. The whole
character must fit comfortably centered, feet touching the bottom edge,
helmet near the top with breathing room.
Use the cadet identity rules from briefing section 2.0.
```

#### 2.0.2 Cadete sentado / leyendo expediente (`assets/images/cadete_sentado.png`)
```
[Línea base]
Composition: The cadet stick figure sitting on an invisible stool,
knees bent at 90°, holding an F-447 form with both hands in front of
the helmet. The form is a rectangle with two red stamp marks. Helmet
visor reflects the form. Bored, slightly slumped shoulders.
Use the cadet identity rules from briefing section 2.0.
```

#### 2.0.3 Cadete combate / pose lista (`assets/images/cadete_combate.png`)
```
[Línea base]
Composition: The cadet stick figure in a wide combat stance, knees
bent, weight slightly forward. Right hand grips a generic stamp-tool
weapon (silhouette only, no detail). Left hand free, fingers spread.
Helmet visor has a small red glint. Stronger trembling lines for the
intensity. Feet planted firmly.
Use the cadet identity rules from briefing section 2.0.
```

#### 2.0.4 Cadete bola / rodando (`assets/images/cadete_bola.png`)
```
[Línea base]
Composition: The cadet curled into a ball, knees against chest, arms
hugging legs, helmet down. The whole figure is roughly circular. A
few short trailing motion lines behind to suggest rolling. The red
diagonal sash is partially visible curving around the ball. This is
how the cadete looks while in "modo bola" exploring cracks.
Use the cadet identity rules from briefing section 2.0.
```

---

> **NOTA — el cadete tiene tres clases jugables.** §2.0 describe la
> silueta neutra del cadete. §2.0a/§2.0b/§2.0c añaden la identidad
> obligatoria de cada clase y los prompts específicos de sus poses.
> Las habilidades en combate ya tienen sus frames propios (ver §10.13).
> Cuando generes el sprite de una clase concreta, hereda la identidad
> base de §2.0 **y encima** suma los rasgos de la clase elegida.
>
> **Corrección editorial importante**: las clases deben conservar el
> acabado del cadete canónico ya aprobado: personaje vestido, relleno
> crema, accesorios simples pero reconocibles, línea de tinta manual y
> detalle suficiente para personalidad. **No reducirlas a monigotos
> geométricos ni a stickmen desnudos.**

### 2.0a Cadete clase GIMNASTA OLÍMPICA DEL ESPACIO

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Concepto**: cadete atlética, gestos amplios, siempre lista para
saltar. Sus habilidades son corporales: Pulso Cardiovascular, Patada
Olímpica, Salto Mortal.

**Identidad obligatoria de la Gimnasta** (suma a §2.0):
- Stick figure femenino, alto y delgado, hombros estrechos.
- Casco esférico de cosmonauta IGUAL al base, sin variación.
- En lugar del traje de manga larga: **leotardo deportivo soviético**
  (silueta de maillot con cuello alto, manga corta o sin manga). Sólo
  silueta — no detalle del tejido.
- El leotardo debe seguir pareciendo **uniforme reglamentario de
  academia espacial**, no traje de superhéroe ni ropa deportiva moderna.
- **Cinturilla con una estrella roja pequeña** centrada en el ombligo.
- **Coleta o moño** asomando por la nuca, dibujado con tres trazos
  rectos (no rizos).
- Calzas largas hasta los tobillos (más estrechas que las botas del
  cadete base). Botas más ligeras que el cadete genérico.
- La banda roja diagonal se mantiene cruzando el pecho.
- Postura: peso siempre en una pierna ligeramente flexionada; nunca
  rígida.

#### 2.0a.1 Gimnasta idle (`assets/images/cadete_gimnasta_idle.png`)
```
[Línea base]
Composition: The Gymnast cadet standing front-facing in athletic
ready stance. Right leg slightly forward, weight on left, both arms
relaxed at sides. Ponytail visible behind the helmet. Red sash + red
star on the waist visible. Background transparent.
Use the cadet identity from §2.0 AND the Gymnast identity from §2.0a.
```

#### 2.0a.2 Gimnasta sentada (`assets/images/cadete_gimnasta_sentada.png`)
```
[Línea base]
Composition: The Gymnast cadet sitting in a stretched position, one
leg extended forward, the other folded, reading an F-447 form. Visible
flexibility through the silhouette of the legs. Same red sash + waist
star.
Use §2.0 + §2.0a identity rules.
```

#### 2.0a.3 Gimnasta combate (`assets/images/cadete_gimnasta_combate.png`)
```
[Línea base]
Composition: The Gymnast cadet in a low fighting stance with both
fists at chest level, weight forward, one knee raised and lower leg
angled forward so the pose clearly reads as a prepared kick. Tense
trembling lines around the figure to suggest coiled energy. No weapon
(her body is the weapon).
Use §2.0 + §2.0a identity rules.
```

#### 2.0a.4 Gimnasta bola (`assets/images/cadete_gimnasta_bola.png`)
```
[Línea base]
Composition: The Gymnast curled into a tight ball, more compact than
the generic cadet — she folds tighter thanks to her flexibility. Red
sash visible curving across. Two trailing motion lines behind.
Use §2.0 + §2.0a identity rules.
```

### 2.0b Cadete clase INGENIERA DE CINTA ADHESIVA

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Concepto**: cadete técnica, siempre con herramientas en las manos.
Sus habilidades son técnicas: Sabotaje, Parche de Urgencia, Caja
Inversa, Cinta Inmovilizante. Basada en el personaje Vostrikova.

**Identidad obligatoria de la Ingeniera** (suma a §2.0):
- Stick figure femenino, complexión normal, hombros un poco más
  anchos que la Gimnasta (lleva mono).
- Casco esférico estándar pero con **una pequeña lámpara de soldador
  montada en la sien derecha**, dibujada con dos trazos.
- **Mono de trabajo gris-tinta** (silueta de overol con tirantes
  cruzados). Cinturón de herramientas en la cadera, con tres bultos
  pequeños sugiriendo destornillador / cinta / llave.
- En la mano derecha, casi siempre, **un rollo de cinta adhesiva
  blanco con franja roja** (un cilindro con un trazo rojo).
- **Gafas de soldadura** sobre la frente, visibles dentro del casco:
  dos óvalos pequeños unidos por un trazo horizontal y claramente
  separados de la lámpara lateral del casco.
- La banda roja diagonal se mantiene pero parcialmente tapada por el
  tirante del mono.

#### 2.0b.1 Ingeniera idle (`assets/images/cadete_ingeniera_idle.png`)
```
[Línea base]
Composition: The Engineer cadet standing, right hand holding the roll
of red-striped adhesive tape, left hand wiping the helmet visor with
an oily rag. Welder lens on the sien visible. Tool belt with three
small lumps at the waist.
Use §2.0 + §2.0b identity rules.
```

#### 2.0b.2 Ingeniera sentada (`assets/images/cadete_ingeniera_sentada.png`)
```
[Línea base]
Composition: The Engineer cadet sitting cross-legged on the floor,
roll of tape between her knees, soldering iron in her right hand
working on an open metal panel in front of her. Welder lens lowered
over the visor.
Use §2.0 + §2.0b identity rules.
```

#### 2.0b.3 Ingeniera combate (`assets/images/cadete_ingeniera_combate.png`)
```
[Línea base]
Composition: The Engineer cadet in defensive stance, holding the tape
roll forward like a shield, left hand brandishing a wrench. Tool belt
clinking — three motion lines from the belt suggesting the tools
swinging. Welder lens flipped down over the visor for combat.
Use §2.0 + §2.0b identity rules.
```

#### 2.0b.4 Ingeniera bola (`assets/images/cadete_ingeniera_bola.png`)
```
[Línea base]
Composition: The Engineer curled into a ball, but with strips of red
adhesive tape WRAPPING the ball as if she had taped herself together.
The tape strips are the most distinctive feature — three curved red
lines around the spherical figure.
Use §2.0 + §2.0b identity rules.
```

### 2.0c Cadete clase COMISARIA POETA

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Concepto**: cadete formal, oradora, autoridad burocrática. Sus
habilidades son verbales/morales: Decreto de Realidad, Soneto
Demoledor, Cita Reglamentaria, Discurso Tedioso.

**Identidad obligatoria de la Comisaria** (suma a §2.0):
- Stick figure femenino, postura erguida, hombros rectos.
- Casco esférico estándar pero con una **estrella roja grande
  pintada en el frontal** (sobre la frente, dentro del visor).
- **Uniforme de comisaria**: chaqueta militar de cuello alto con
  **doble fila de botones** (cuatro puntos negros a cada lado).
  Pantalón recto hasta la bota.
- **Faja roja ceñida a la cintura** (silueta gruesa horizontal). La
  banda diagonal del cadete base queda subordinada y sólo asoma
  parcialmente por debajo de la faja.
- **Libreta de tapa roja** en la mano izquierda casi siempre.
- **Pluma estilográfica** en la mano derecha, dibujada como un trazo
  fino negro; la punta roja sólo aparece cuando ayude a leer una acción
  concreta.
- Bota militar más alta y más rígida que las del cadete base
  (silueta hasta la rodilla).
- No lleva pelo visible (todo dentro del casco).

#### 2.0c.1 Comisaria idle (`assets/images/cadete_comisaria_idle.png`)
```
[Línea base]
Composition: The Commissar cadet standing strictly upright, heels
together, libreta clutched against the chest with the left hand,
pluma raised in the right hand mid-sentence as if dictating. Red star
on the helmet front, red waist sash visible. Stern military posture.
Use §2.0 + §2.0c identity rules.
```

#### 2.0c.2 Comisaria sentada (`assets/images/cadete_comisaria_sentada.png`)
```
[Línea base]
Composition: The Commissar cadet sitting bolt upright on an invisible
chair, knees together, libreta open on the lap, pluma writing a
verdict. No slouching. Disapproving expression suggested by the
slight downward tilt of the helmet.
Use §2.0 + §2.0c identity rules.
```

#### 2.0c.3 Comisaria combate (`assets/images/cadete_comisaria_combate.png`)
```
[Línea base]
Composition: The Commissar cadet in oratory combat stance: one foot
forward, libreta held high in the left hand as if reciting a decree,
pluma in the right hand pointing at an imaginary adversary like a
sabre. Two short red ink waves emerging from the pluma tip toward
the enemy. Authority posture.
Use §2.0 + §2.0c identity rules.
```

#### 2.0c.4 Comisaria bola (`assets/images/cadete_comisaria_bola.png`)
```
[Línea base]
Composition: The Commissar curled into a ball, but visibly stiff and
formal even rolling. Libreta peeking out from one side, pluma from
the other. The red waist sash and the red helmet star visible curving
across the ball.
Use §2.0 + §2.0c identity rules.
```

### 2.0.5 Laika (mascota narrativa) — set de poses

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Uso**: NO sustituye a `MascotaNarrativa` (procedimental, con frames
de tail-wag y caminado). Estos PNGs se usan en **escenas narrativas
estáticas, retratos de adopción, cinemática §5.3 (Laika perdida)**.

**Dimensiones por pose**: 400×400 PNG transparente.

**Identidad obligatoria de Laika** (repítelo en cada prompt):

- Perro pequeño tipo terrier callejero, garabato minimalista.
- Casco esférico de cosmonauta proporcionalmente enorme para su
  cabeza — más grande que su propio cuerpo. Visera curva.
- Cuerpo = una elipse alargada con cuatro patas finas. Cola fina
  curvada hacia arriba.
- UN solo detalle rojo: una pequeña insignia triangular roja
  cosida al collar (visible bajo el casco).
- Manchas del pelaje: un par de áreas sólidas de tinta negra
  irregulares, NO realistas — sólo silueta. No pintar pelo.
- Sin ojos detallados: dos puntos pequeños detrás del visor.
- Ninguna textura ni sombreado interior. Sólo silueta + collar.

#### 2.0.6 Laika sentada (`assets/images/laika_sentada.png`)
```
[Línea base]
Composition: Laika sitting in profile, tail curved upward, helmet
proportionally huge. The single red triangle on her collar is the
only red element. Two ink blots on her flank as fur markings.
Use the Laika identity rules from briefing section 2.0.5.
```

#### 2.0.7 Laika ladrando (`assets/images/laika_ladrando.png`)
```
[Línea base]
Composition: Laika standing on all fours, front legs slightly raised,
head tilted up, mouth open (a small triangular gap inside the helmet).
Two tiny red marker lines suggest sound waves coming from the helmet.
Use the Laika identity rules from briefing section 2.0.5.
```

#### 2.0.8 Laika perdida en el vacío (`assets/images/laika_perdida.png`)
```
[Línea base]
Composition: Laika curled up floating in zero-gravity, helmet visor
reflecting a faint red star far in the distance. Tail tucked against
body. Cyrillic text "ЛАЙКА" small in black above her. Background must
be transparent — the floating effect comes only from her posture.
Use the Laika identity rules from briefing section 2.0.5.
```

#### 2.0.9 Laika con expediente en la boca (`assets/images/laika_expediente.png`)
```
[Línea base]
Composition: Laika seen from the side, standing, carrying a tiny
F-447 form in her teeth. The form has one visible red stamp. Tail
wagging (suggested by two curved motion arcs). Used as the moment
she becomes useful and finds documents the cadet missed.
Use the Laika identity rules from briefing section 2.0.5.
```

### 2.1 Comandante Ostrog (cantina, ya existe pero muy geométrico)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Reemplaza el painter `_PintorOstrog` en `canteen_screen.dart`.
**Dimensiones**: 600×900.

```
[Línea base]
Full body portrait of "COMANDANTE OSTROG", a Soviet bureaucratic
station officer. Stocky build, tall hat with red star, thick mustache.
Wears a heavy gray-ink overcoat with two red stripes on the sleeves.
Holds a small chipped tea cup in the right hand, looks slightly bored
with eyebrow raised. Stands behind an implied counter (foreshortened
hint). Three medals on the left chest, two of them in red ink, one
all-black. Boots heavy and over-large. Mustache is the dominant feature
— huge bushy mustache covering half the face.
Style: West-of-Loathing stick figure with massive accessories, soviet
poster line work, two-color palette, no fill greys.
```

### 2.2 Madre Ferruginosa (cantina, ya existe)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Reemplaza `_PintorMadreFerruginosa`.
**Dimensiones**: 600×900.

```
[Línea base]
Full body portrait of "MADRE FERRUGINOSA", a sentient samovar-android.
Tall cylindrical metallic body with rivets, four spider-like thin legs,
a brass faucet at the front-bottom dripping a single bubbly red drop.
Top crowned with a Soviet star and a curved pipe emitting three little
heart-shaped steam puffs (red). Two round porthole-eyes glowing red on
the body. Three medals welded to the front. Hand-drawn rivet pattern,
cross-hatching shadows on the curved body. Slightly tilted to the left
like a worn old machine. No facial expression — just eye-portholes.
```

### 2.3 Inspector Central (ya existe SVG, opcionalmente quieres versión render)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Antagonista principal del acto 1. Si quieres una versión PNG
detallada en lugar del SVG. `assets/images/inspector_central.png`.
**Dimensiones**: 600×900.

```
[Línea base]
Full body portrait of "INSPECTOR CENTRAL DEL COMITÉ". Tall, gaunt,
authoritarian figure. Wears an enormous cosmonaut helmet with red star
on the forehead, antenna with a red bulb. Long black overcoat reaching
the floor with four red buttons vertically centered, leather belt with
red buckle. Holds a brown leather briefcase labeled "F-447" in the left
hand, dangling red wax seal from the briefcase. Right arm extended,
index finger pointing accusingly. Stern face with huge regulation
mustache, small angry eyes, frowning eyebrows. Etiqueta "INSPECTOR"
above the helmet in serif italic red on cream paper rectangle. Pose
intimidating, slightly leaning forward. West-of-Loathing exaggeration.
```

### 2.4 Capitán Vassiliev (NPC nuevo, mencionado en bumper VAS del Pinball)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: NPC nuevo de cápsula o cantina. `assets/images/capitan_vassiliev.png`.
**Dimensiones**: 600×900.

```
[Línea base]
Full body portrait of "CAPITÁN VASSILIEV". Old Soviet space captain,
thin, slightly stooped. Wears a stained white space-suit cardigan over
pajama-like trousers. Large round wired spectacles, a single hair tuft
on top of the head, two-day stubble. Pipe in mouth emitting three red
puffs. Holds an open paper file labeled "REPORTE F-447" reading
glasses over his eyes. Pose: leaning over the file, half-turned to
the viewer like he just looked up because someone interrupted him.
Boots untied. Patch on the shoulder: red five-pointed star.
West-of-Loathing exaggeration: massive spectacles, tiny eyes behind them.
```

### 2.5 Camarada Directorskov (jefe del Pinball Cripta)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Antagonista del minijuego Pinball del Comité. Imagen para diálogo
y/o transición. `assets/images/directorskov.png`.
**Dimensiones**: 600×900.

```
[Línea base]
Full body portrait of "CAMARADA DIRECTORSKOV", a deceased Soviet
director risen as bureaucratic specter. Translucent ink lines outlining
a stocky body in a tightly-buttoned overcoat. Large mortician medals,
red star on the chest. Bald with three hair strands flying upward.
Holds a giant rubber stamp in the right hand, marked "VETO". Floats
half a meter off the ground, ink-puddle below instead of feet. Eyes
solid red (no pupils). Background: faint sarcophagus outline.
Pose: arm raised about to stamp something invisible. Slightly tilted,
ghostly, ink lines trailing off into wisps at the edges.
```

### 2.6 Karenina Archivera (NPC nuevo sugerido — escenario reactor)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Archivera del reactor, opción de NPC narrativo nuevo.
`assets/images/karenina_archivera.png`.
**Dimensiones**: 600×900.

```
[Línea base]
Full body portrait of "KARENINA ARCHIVERA", a Soviet female file clerk.
Slim and tall, hair tied in a strict bun, square glasses. Wears a long
straight skirt and a buttoned blouse with red bow at the neck. Holds
a stack of seven paper files balanced precariously in both arms. The
top file has a red wax seal. Pose: serious, half-walking like she's
about to deliver them. Behind her, two rubber stamps stuck in a holder
on her belt (small detail). Cross-hatching shadow under the bun.
West-of-Loathing line economy: face barely two dots and a flat mouth.
```

### 2.7 Brigada del Sello (enemigos genéricos de combate)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Enemigo común. Necesitamos 3 variantes (puños, garrote, rifle-sellador).
`assets/images/brigada_sello_<variante>.png`.
**Dimensiones**: 400×600 cada uno.

```
[Línea base]
Full body of a "Brigadista del Sello": Soviet enforcer, simple uniform.
Variant 1 — PUÑOS: Bare hands, fists raised, peaked cap with red star,
generic boots, slight crouch. Burly silhouette.
Variant 2 — GARROTE: Same body type, holding a wooden truncheon with
red leather grip, swinging back. More aggressive pose.
Variant 3 — RIFLE-SELLADOR: Holds a rifle modified with a rubber stamp
at the muzzle. The "barrel" is a giant red ink-loaded stamp. Pose:
aiming forward.
All three: same face (two dots + line mouth, peaked cap), exaggerated
boots and hands, West-of-Loathing economy of line.
```

### 2.8 Burócratas-Zombi (enemigos de Cosmoom Doom)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Enemigos del minijuego DOOM. Sprite frontal y de perfil.
`assets/images/burocrata_zombi_<vista>.png`.
**Dimensiones**: 400×600.

```
[Línea base]
Soviet bureaucrat zombie. Crumpled gray suit (drawn in black ink),
torn red tie, slightly hunched. Pale glassy eyes, mouth open showing
two teeth. Holds a stamped form in one hand reading "F-447 SELLADO"
that drags behind him. The other hand outstretched, fingernails long.
Slight ink-blood trail dripping from the corner of the mouth (red).
A red rubber-stamp wound mark on the forehead. Two views needed:
front-facing for the in-game sprite, and 3/4 side for the portrait.
Cross-hatching on the crumpled suit.
```

---

## 3. Muebles y decorados (alta prioridad)

> **Formato común**: PNG transparente 400×400 a 800×800. Vistas frontales
> o 3/4 perspectiva isométrica suave.

### 3.1 Archivador del Comité

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Mueble central de cápsula y reactor. `assets/svg/archivador.png`.

```
[Línea base]
A tall Soviet filing cabinet, four drawers. Slightly trembling vertical
lines, rivets visible on the sides. Each drawer has a paper label:
"A-K", "L-Q", "R-Z", "F-447 (PROHIBIDO)". The bottom drawer is half
open and ink-stained papers stick out. Three red wax seals stuck on
the side. A small Soviet star at the top center. Heavy shadow under
the cabinet drawn with cross-hatching.
```

### 3.2 Mesa de cantina con manchas

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Cantina del Olvido. `assets/svg/mesa_cantina.png`.

```
[Línea base]
A worn round metallic cantina table seen from a slight 3/4 angle. Three
spindly metal legs with rivets. Tabletop covered in: a tipped vodka
glass with the contents pooling (black ink stain), a partially eaten
sandwich, a checkered red napkin, a half-burned cigarette in a tin ash
tray, and one playing card lying upside down. Strong cross-hatching
under the table for shadow.
```

### 3.3 Samovar oficial (más grande que la Madre)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Decoración cantina. `assets/svg/samovar_oficial.png`.

```
[Línea base]
A large brass Soviet samovar, ornate. Wide cylindrical belly with
relief patterns drawn as ink curls. Chimney coming out the top with
steam (three red wisps). Spigot at the front with a small red leaking
drop. Two curved handles. Star-shaped medallion on the front. Standing
on a small tea table covered by an embroidered cloth (red pattern).
Cross-hatching for metallic shadow.
```

### 3.4 Cápsula de llegada (interior)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Mueble principal de la cápsula (room_screen). `assets/svg/capsula.png`.

```
[Línea base]
Interior of a small Soviet space landing capsule. Single pilot chair
covered in straps. Control panel with seven analog dials and three
glowing red bulbs. Round porthole window showing a black starfield
with red stars. Ventilation grates on the floor. Walls reinforced
with rivets and metal plates. Soviet propaganda poster pinned to the
wall reading "GLORIA AL CAMARADA" in Cyrillic. Cross-hatching shadows
in the corners, papers strewn on the floor.
```

### 3.5 Compuerta acorazada (puertas que conectan escenarios)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Hotspots de salida en cápsula/cantina/reactor. `assets/svg/compuerta.png`.

```
[Línea base]
A heavy circular Soviet airlock door, riveted around the perimeter.
Center has a large wheel-handle and a small porthole window showing
red emergency light inside. Above the door, a red sign in monospace
text "ACCESO RESTRINGIDO · F-447". Below, hazard chevrons in black
and red. Cross-hatching shadows around the rivets.
```

### 3.6 Radio de la cantina (existe pero geométrica)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Reemplaza `_PintorRadioMesa`. `assets/svg/radio_cantina.png`.

```
[Línea base]
A 1960s Soviet shortwave radio with worn wooden case. Dial in the
center with a red needle pointing between two frequencies. Three
knobs below: VOL, TONO, ONDA. A frayed cable trailing off the side.
On top: a chipped tea cup leaving a brown ring. Antenna telescoping
upward at a slight angle. Three little radio waves emanating from
the dial drawn as red curves. The radio looks recently kicked.
```

### 3.7 Sarcófago de Directorskov (Cripta del Pinball)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Decoración central del 3er tablero del Pinball. `assets/svg/sarcofago.png`.

```
[Línea base]
A grim Soviet mausoleum sarcophagus. Heavy stone block, hammer and
sickle carved on the lid, a single large red star painted center-lid.
Four corners marked with iron studs. Around it, six smaller candles
with red flames. Bureaucratic forms scattered at the base, several
stamped "PROHIBIDO". Cross-hatching shadow making the stone look
heavy. Dust particles around (small ink specks).
```

### 3.8 Bolos burocráticos (mueble del modo bola)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Decoración para los pinos de bowling de la cápsula.
`assets/svg/bolo_burocratico.png`.

```
[Línea base]
A single Soviet-style bowling pin shaped like a small bureaucrat.
Cylindrical body with a tiny peaked cap on top, two beady eyes drawn
on the front, mustache, red star on the chest band. Looks like a
miniature commissar. Eight pins arranged in a row will be needed
in-game; provide one canonical pin centered.
```

### 3.9 Caja F-447 empujable

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Objeto empujable de la cápsula. `assets/svg/caja_f447.png`.

```
[Línea base]
A cardboard storage box, worn corners. Brown packing tape forming an
X over the lid. Label on the front in monospace: "F-447 / ARCHIVO 12".
Red wax seal stuck on the side (broken in half). Small Soviet star
stamp at the corner of the lid. Crumpled appearance with cross-hatching
shadows.
```

### 3.10 Trampilla del congelador (cantina)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Reemplaza `_PintorTrampillaCongelador`. `assets/svg/trampilla_congelador.png`.

```
[Línea base]
A square metal floor trapdoor, frost rim around it, three latches
on the visible side. Pull-ring in the center, slightly tilted as if
just used. Cold steam wisps escaping through the cracks (white-ish
papelViejo color outlines suggesting cold air). Sign next to it:
"CONGELADOR · NO TOCAR" in monospace red.
```

---

## 4. Iconos / Insignias / Sellos

> **Formato común**: PNG transparente 256×256, centrado.

### 4.1 Sellos burocráticos rojos (set de 10)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Decoración omnipresente en escenarios. Necesitamos VARIOS sellos
distintos para no repetir el mismo. `assets/svg/sello_<nombre>.png`.

```
[Línea base]
A circular Soviet rubber stamp in red ink, slightly worn and uneven.
Each stamp must look hand-pressed (not perfectly aligned). Provide
10 different stamps, one per file, each on transparent background:

1. "VISADO" – Cyrillic version: "ВИЗИРОВАНО"
2. "F-447"
3. "PROHIBIDO" – Cyrillic: "ЗАПРЕЩЕНО"
4. "INSPECTOR"
5. "TRAMITAR"
6. "PRAVDA"
7. "COMITÉ"
8. "ARCHIVO"
9. "URGENTE"
10. "NO LEER"

All in red ink (#C8102E), slightly rotated, with double border (one
inner thin ring + outer thicker ring). Five-pointed star in the center
when there's room. Hand-pressed imperfections: faded patches, ink
bleeds. No background.
```

### 4.2 Insignias del cadete (logros)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Galería de insignias del jugador.
`assets/svg/insignia_<id>.png`.

```
[Línea base]
A round Soviet military medal, 256x256, transparent background. Each
medal has:
- Red ribbon at the top
- Round metallic disk (drawn as ink contour with cross-hatching)
- Central emblem (varies per medal)
- Cyrillic or Spanish text on the bottom rim

Provide one design per insignia identifier:
- "primer_combate": Two crossed stamps, "PRIMER SELLO"
- "te_sin_sufrimiento": Tea cup with star, "TÉ SIN SUFRIMIENTO"
- "chiste_prohibido": Mustache silhouette, "CHISTE PROHIBIDO"
- "cadete_traidor": Star upside down, "CADETE TRAIDOR" (in disgrace)
- "madre_te_ve": Eye-shaped, "MADRE TE VE"
- "strike_burocratico": Three knocked-over pins, "STRIKE BUROCRÁTICO"
- "laika_adoptada": Cat-dog with helmet, "LAIKA ADOPTADA"

Black ink contours + red details. Old worn paper texture behind disk.
```

### 4.3 Cartas de propaganda (uso en menús)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Botones de los menús principales y de cartas de habilidad.
`assets/svg/carta_<nombre>.png`. **Formato**: PNG transparente 400×600.

```
[Línea base]
A small Soviet propaganda card. Vertical, rectangle, with rounded
corners and decorative border (alternating black-red dashes). Inside,
a hand-drawn ink illustration of a single concept + a propaganda
slogan in serif italic.

Cards needed:
- "INVENTARIO": A clenched fist holding a stamped folder
- "DIARIO": An open book with a red bookmark
- "CLASE: TÉCNICO": A wrench crossed with a soldering iron
- "CLASE: COMISARIO": A red megaphone
- "CLASE: BURÓCRATA": A typewriter with a star
- "MAPA": A folded paper map with red pin

Each ~400x600, slight tilt, paper texture in the background, slogans
in Spanish and Cyrillic (small caption underneath).
```

---

## 5. Pantallas de transición / Ilustraciones narrativas

> Imágenes a pantalla completa para momentos clave. 1280×720.

### 5.1 Cinemática de apertura: el aterrizaje

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Al empezar la partida, primer modal narrativo de la cápsula.
`assets/images/cine_aterrizaje.png`.

```
[Línea base]
Wide-shot ink illustration. A small Soviet landing capsule slammed
into the docking port of station Pravda-12. The capsule is slightly
crooked, smoke curling from one side. A speaker grille pointing at
the viewer with two motion-lines indicating someone is yelling. Through
the capsule's porthole, the silhouette of the cosmonaut cadet (just
arrived) is visible. Background: the curved hull of the station with
multiple red blinking lights and Cyrillic labels. Cross-hatching on
the curves. Dust particles from the impact (small black specks).
Caption "AÑO 1962 · CUADRANTE SIGMA" at the bottom in serif italic.
```

### 5.2 Cinemática: la llegada del Inspector

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Aparece tras X horas de juego o al activarse un evento.
`assets/images/cine_inspector_llega.png`.

```
[Línea base]
A massive Soviet inspection shuttle docking with the Pravda-12. From
the open airlock emerges the Inspector Central (massive helmeted
silhouette) flanked by four smaller Brigada del Sello figures. The
floor lights up red where the Inspector steps. Above them, a banner
unfurling reading in Cyrillic "ИНСПЕКЦИЯ" (Inspection). On the side,
small bureaucrat silhouettes flee in panic with arms raised.
Composition: dramatic, low angle looking up at the Inspector. Cross-
hatching shadows everywhere. Captions in serif italic Spanish.
```

### 5.3 Cinemática: Laika perdida en el espacio (lore)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Cinemática opcional tras adoptarla, profundiza su historia.
`assets/images/cine_laika_origen.png`.

```
[Línea base]
A flashback illustration. A small dog-cat cosmonaut hybrid floating
alone in deep space, helmet slightly cracked, the bubble showing her
sleeping face. Stars around her drawn as red and black asterisks. In
the distance, the rusted hulk of an abandoned Soviet probe with the
hatch open. A single red wax seal still attached to her collar reading
"LAIKA-7". Composition: melancholic, soft floating pose, paws curled
in. The cracked helmet has tiny stars escaping through the crack.
Caption "ANTES DE LA CANTINA · 19??" in handwritten marker.
```

### 5.4 Cinemática: el bigote de Brezhnev (huevo de pascua)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


**Uso**: Si el jugador desbloquea la insignia "chiste prohibido".
`assets/images/cine_bigote.png`.

```
[Línea base]
A surreal illustration. An enormous bushy black mustache floating in
zero gravity, made of swirling ink lines. Around it, three cosmonauts
(stick figures) chasing it with butterfly nets. The mustache has its
own tiny red star clinging to it. Background: deep space with floating
Soviet papers. Caption "EL BIGOTE QUE NUNCA TUVO DUEÑO" in serif italic
across the top.
```

---

## 6. Generadores recomendados y consejos prácticos

### ChatGPT / DALL·E 3
- Pega la **línea base** + el bloque específico.
- DALL·E suele meter colores extra. Insiste con "ONLY two colors: black
  ink and Soviet red. No greens, no blues, no purples, no yellows".
- Pide siempre "transparent background" cuando sea NPC/mueble.

### Midjourney v6+
- Añade al final: `--ar 2:3 --style raw --stylize 250 --no green blue
  purple yellow gradient`.
- Para portadas: `--ar 16:9`.
- Para iconos: `--ar 1:1 --stylize 50`.

### Imagen-3 (Google)
- Suele seguir mejor las restricciones de paleta.
- Útil para iconos y sellos.

### Flux Schnell / Dev (local)
- Si tienes GPU buena: gratis y rápido.
- Mete los prompts tal cual.

### Cuando me pases las imágenes

1. Mete los PNG en `assets/images/` (key art, cinemáticas) o `assets/svg/`
   (NPCs como SVG vectorizado si es posible).
2. Mantén los nombres tal como aparecen en este documento (ej.
   `assets/svg/archivador.png`, `assets/images/portada_principal.png`).
3. Dime cuándo hay material nuevo y yo lo cableo en el código.

### Prioridades para empezar
Si vas a generar pocas:
1. **Portada principal** (1.1) — abre el juego, máximo impacto.
2. **Ostrog y Madre Ferruginosa** (2.1, 2.2) — están en la primera media
   hora de juego.
3. **Sellos burocráticos** (4.1) — se usan en todas partes como decoración.
4. **Inspector Central** (2.3) — antagonista del acto 1.
5. **Cinemática del aterrizaje** (5.1) — primera impresión del juego.

El resto puede esperar.

---

## 7. CATÁLOGO EXHAUSTIVO de painters por escenario

> Lista completa de **todos los `CustomPainter` actualmente dibujados a
> trazo geométrico** que conviene sustituir por arte generado. Cada
> entrada lleva el archivo y la línea donde está hoy el painter, el
> nombre del PNG que YO buscaré automáticamente cuando lo metas, y un
> prompt listo para usar.

### Convención de nombres de archivo

| Tipo | Carpeta | Patrón |
|------|---------|--------|
| Muebles, objetos de escenario, NPCs interactivos | `assets/svg/` | `<nombre>.png` (transparente) |
| Fondos de escenario completos | `assets/images/` | `fondo_<escenario>.png` |
| Sprites de combate | `assets/svg/` | `combate_<id>.png` (transparente) |
| Ilustraciones de transición y cinemáticas | `assets/images/` | `cine_<id>.png` |

### 7.1 Cápsula de llegada (`room_screen.dart`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


#### 7.1.1 Archivador del Comité (`_PintorArchivador`, línea 871)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/archivador.png` (transparente, 800×1200). **Nombre canónico ya cableado en código.**

```
[Línea base]
A tall Soviet four-drawer filing cabinet seen from a slight 3/4 angle.
Rivets running down both vertical edges. Each drawer labeled in
monospace: "A-K", "L-Q", "R-Z", and the bottom one labeled "F-447 ·
PROHIBIDO" in red. The bottom drawer half open, papers sticking out
chaotically. Three red wax seals stuck to the side, one with a crack.
A small red star riveted at the top center. Heavy cross-hatching
shadows under the cabinet. Floor not drawn (transparent background).
Aged ink-marker hand-drawing.
```

#### 7.1.2 Samovar pequeño (`_PintorSamovarPequeno`, línea 1110)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/mueble_samovar_pequeno.png` (transparente, 500×700).

```
[Línea base]
A small brass tabletop samovar with rivets. Round belly, narrow
chimney spouting two thin red steam wisps. Front spigot with one
red drop hanging. Sits on a tiny embroidered cloth showing a red
five-pointed star pattern. The samovar is slightly dented on one
side. Cross-hatching for metallic curvature shadow.
```

#### 7.1.3 Cápsula de llegada (`_PintorCapsulaLlegada`, línea 1375)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/capsula.png` (transparente, 900×900). **Nombre canónico ya cableado en código.**

```
[Línea base]
A small Soviet landing capsule seen from 3/4 front angle. Spherical
cabin with a single round porthole window showing a black starfield
with red stars inside. Three thrust nozzles at the base, scorched
black. Crooked from a rough landing. Red number "12" stencilled on
the side with hammer and sickle. Open hatch with handle dangling.
Cross-hatching for sphere shading.
```

#### 7.1.4 Compuerta acorazada (`_PintorCompuerta`, línea 1619)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/compuerta.png` (transparente, 500×800). **Nombre canónico ya cableado en código.**

```
[Línea base]
A heavy circular Soviet airlock door, riveted perimeter. Center
shows a large wheel-handle (six spokes) and a small porthole
window glowing red inside. Above the door: a rectangular metal
sign in monospace red text "ACCESO RESTRINGIDO · F-447". Below:
hazard chevrons alternating black and red. Cross-hatching shadows
around rivets.
```

#### 7.1.5 Rejilla de ventilación (`_PintorRejillaVentilacion`, línea 1835)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/mueble_rejilla_ventilacion.png` (transparente, 400×400).

```
[Línea base]
A square wall ventilation grate with horizontal slats. Four screws
in the corners, slightly tilted (one screw missing). A thin streak
of dust forming a small trail below the grate. Cross-hatching for
metal depth. Slight rust spots in red ink near the screws.
```

#### 7.1.6 Tubo de fontanería (`_PintorTuboFontaneria`, línea 1903)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/mueble_tubo.png` (transparente, 200×600).

```
[Línea base]
A vertical Soviet industrial pipe, narrow, with three flange joints
showing bolts. A small red valve handle protruding from the middle
joint. A single drop of red liquid forming at the bottom flange.
Light cross-hatching for cylindrical shadow.
```

#### 7.1.7 Almohada (`_PintorAlmohada`, línea 1974)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/mueble_almohada.png` (transparente, 500×300).

```
[Línea base]
A worn Soviet barracks pillow, dented in the middle, stitched edge,
small red star embroidered on one corner. Light cross-hatching for
fabric folds.
```

### 7.2 Cantina del Olvido (`canteen_screen.dart`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


#### 7.2.1 Radio de mesa (`_PintorRadioMesa`, línea 805)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/radio_cantina.png` (transparente, 600×400). **Nombre canónico ya cableado en código.**

```
[Línea base]
A 1960s Soviet shortwave radio with a worn wooden case. Round dial
in the center with a red needle pointing between two marks. Three
black knobs below labeled in Cyrillic. A frayed cable trailing off
the side. On top: a chipped tea cup leaving a brown ring. Antenna
telescoping up at a slight tilt. Three small red wave-curves
emanating from the dial. The radio looks recently kicked.
```

#### 7.2.2 Barril del almacén (`_PintorBarrilAlmacen`, línea 848)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/mueble_barril.png` (transparente, 500×600).

```
[Línea base]
A wooden Soviet storage barrel, two iron bands around the body.
Stencilled label in red "ВОДКА · ОПЫТНОЕ" (vodka, experimental).
Small red star burned into the lid. A drop of red liquid escaping
from a tiny crack in the side. Cross-hatching for wood grain.
```

#### 7.2.3 Compuerta simple (`_PintorCompuertaSimple`, línea 919)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/mueble_compuerta_simple.png` (transparente, 500×700).

```
[Línea base]
A simpler airlock door than the capsule one: rectangular metal with
rivets at the corners, a single round handle, a small label
"COMPUERTA · CANTINA" in monospace. Vertical red strip down the
side as ID code. Cross-hatching shadow on rivets.
```

#### 7.2.4 Trampilla del congelador (`_PintorTrampillaCongelador`, línea 966)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/mueble_trampilla_congelador.png` (transparente, 500×500).

```
[Línea base]
A square metal floor trapdoor. Frost rim around it (drawn as little
spike-icicles in ink). Three latches on one side. Pull-ring in the
center, slightly tilted. Cold steam wisps escaping through the
cracks. Sign next to it: "CONGELADOR · NO TOCAR" in red monospace.
```

#### 7.2.5 Laika perdida (`_PintorLaikaPerdida`, línea 1093)  ⚠️ HOTSPOT

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/laika_perdida.png` (transparente, 400×400).
> Sólo aparece antes de adoptar a la mascota.

```
[Línea base]
A small cat-dog creature curled up under a table, fast asleep.
Has a tiny crooked cosmonaut helmet on its head, slightly askew.
A red collar with a hanging brass tag reading "ЛАЙКА". A red
question mark floating above her head (signaling adoptability).
Eyes closed (two short curved lines). One paw twitching mid-dream.
Cross-hatching shadow under her body.
```

### 7.3 Reactor (`reactor_screen.dart`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


#### 7.3.1 Vela (`_PintorVela`, línea 806)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/mueble_vela.png` (transparente, 200×400).

```
[Línea base]
A short Soviet votive candle. White wax body with melted drips
flowing down. Red flame (no other color in the flame). Tiny puff
of smoke escaping above. Cross-hatching for wax curve. Small puddle
of melted wax at the base.
```

#### 7.3.2 Caja sin etiqueta (`_PintorCajaSinEtiqueta`, línea 985)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/mueble_caja_anonima.png` (transparente, 500×500).

```
[Línea base]
A cardboard storage box, worn corners. NO labels visible (a missing
label scraped off, only torn tape residue showing). Brown packing
tape forming an X over the lid. A single small red "?" hand-written
on one corner. Cross-hatching for surface shadow.
```

#### 7.3.3 Rejilla de conducto (`_PintorRejillaConducto`, línea 1022)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/mueble_rejilla_conducto.png` (transparente, 600×400).

```
[Línea base]
A wide horizontal industrial duct grate, vertical slats. Eight
rivets around the perimeter. One slat is bent at an angle as if
something pushed through. Dust falling from inside in two thin
trails. Red caution band above reading "CONDUCTO 7" in monospace.
Cross-hatching for metal depth.
```

#### 7.3.4 Monitor de propaganda (`_PintorMonitorPropaganda`, línea 1105)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/mueble_monitor_propaganda.png` (transparente, 600×500).

```
[Línea base]
A 1970s Soviet CRT television, deep cathode body, two control knobs
on the front, a single red blinking dot on the upper right. The
screen shows a hammer-and-sickle silhouette with the text "ГЛОРИЯ"
(glory) in red Cyrillic. Cracks running across the screen, slight
screen-burn lines visible. Cross-hatching for plastic curvature.
```

#### 7.3.5 Compuerta del ministerio (`_PintorCompuertaMinisterio`, línea 1217)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/mueble_compuerta_ministerio.png` (transparente, 700×900).

```
[Línea base]
An ornate ministerial door, much grander than the airlock variant.
Two double doors with brass-style trim drawn as ink scrollwork. Red
sash hanging across the middle. Marble-style framing around the
arch (cross-hatching pattern). A large rubber-stamp "MINISTERIO"
in red across the top. Two ceremonial guards-stick figures with
peaked caps flanking the door (small, in the corners).
```

### 7.4 Planetas (4 escenarios, cada uno con su painter de fondo + decoraciones)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


#### 7.4.1 Sol Camarada fondo (`PintorEscenarioSolCamarada`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/images/fondo_sol_camarada.png` (1920×1080, fondo papel).

```
[Línea base]
Wide-shot illustration of a Soviet space colony on a red dwarf planet.
Foreground: cracked dusty terrain with stencilled propaganda signs.
Mid-ground: a series of geodesic dome habitats with hammer-and-sickle
banners, antennas pointing skyward. Background: an enormous red sun
hanging low, solar flares as concentric ink arcs. Sky is paper-cream
with red stars peppered. No green, no blue. Slight isometric tilt.
Aged hand-drawn ink poster.
```

#### 7.4.2 Delegado sindical (`PintorDelegadoSindical`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/npc_delegado_sindical.png` (transparente, 600×900).

```
[Línea base]
Full body NPC: A weary Soviet union delegate. Cylindrical body shape,
tall fur hat (ushanka), thick mustache, holds a red flag in the
right hand, a clipboard with stamped pages in the left. Round
spectacles. Wears a heavy gray-ink uniform with three rows of small
red medals. Pose: leaning slightly forward, mouth open as if mid-
speech. West-of-Loathing exaggeration.
```

#### 7.4.3 Altavoz solar (`PintorAltavozSolar`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/mueble_altavoz_solar.png` (transparente, 500×800).

```
[Línea base]
A tall pylon-mounted megaphone-style loudspeaker, brass cone wide
at one end. Red speaker mesh inside. Mounted on a triangular metal
post. Three sound-waves drawn as red arcs emanating from the cone.
Small placard on the post: "VOZ DEL PARTIDO". Cross-hatching on the
brass curves.
```

#### 7.4.4 Gélida-9 fondo (`PintorEscenarioGelida9`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/images/fondo_gelida9.png` (1920×1080, fondo papel).

```
[Línea base]
A frozen moon landscape. Foreground: cracked ice patterns drawn as
zigzag ink lines, footprints leading away. Mid-ground: a Soviet
weather station half buried in snow, antenna sticking up with a
red flag. Background: black sky with red stars and Aurora Borealis
drawn as red ink waves. Snowflakes scattered as small asterisks.
Cyrillic letter ХОЛОДНО (cold) at the top in trembling marker.
```

#### 7.4.5 Burócrata congelado (`PintorBurocrataCongelado`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/npc_burocrata_congelado.png` (transparente, 600×900).

```
[Línea base]
A Soviet bureaucrat frozen mid-stride, suit covered in frost
patches (drawn as little ink crystals). Mouth open in surprise,
hands raised. Holding a fully iced briefcase. The frost grows in
tendrils across the body in white-paper highlights. Cross-hatching
shadow underneath. West-of-Loathing exaggeration.
```

#### 7.4.6 Zovnak-4 fondo (`PintorEscenarioZovnak4`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/images/fondo_zovnak4.png` (1920×1080, fondo papel).

```
[Línea base]
A desert-clay planet. Foreground: cracked clay terrain, two suns
high in the sky drawn in red. Mid-ground: rusted iron pyramidal
structures with hammer-and-sickle motifs welded on. Background:
dust storms drawn as horizontal ink waves. A small Soviet flag
planted in the foreground, flapping. Caption "ZOVNAK-4" at top
in monospace red.
```

#### 7.4.7 Marciano votante (`PintorMarcianoVotante`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/npc_marciano_votante.png` (transparente, 600×900).

```
[Línea base]
A spindly alien NPC: tall and thin, four arms total, oval head with
three vertical eye-slits. Wears a Soviet voting sash diagonally with
text "ВОЛЯ" (will). Holds a paper ballot in two of the hands and a
hammer-and-sickle in another. Wide flat feet. Cross-hatching for
alien skin texture. West-of-Loathing economy of line.
```

#### 7.4.8 Puerto de esclusa (`PintorPuertoEsclusa`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/mueble_puerto_esclusa.png` (transparente, 800×600).

```
[Línea base]
A circular industrial airlock port set into a wall. Heavy ring with
8 rivets, central wheel handle, red emergency light flashing on
top. Status panel beside it reading "ESCLUSA · NIVEL 7" in red
monospace. Hazard chevrons below. Cross-hatching on the metal ring.
```

#### 7.4.9 Pravda-7 fondo (`PintorEscenarioPravda7`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/images/fondo_pravda7.png` (1920×1080, fondo papel).

```
[Línea base]
The interior of a derelict orbital station: dim corridors, dangling
broken pipes, sparking cables drawn as zigzag ink lines, papers
floating in zero gravity. A red emergency light bathes one corner.
Hammer-and-sickle banner half torn. A frozen cosmonaut silhouette
visible in the distance, immobile. Cross-hatching everywhere for
shadow. Mood: ominous, abandoned, slightly haunted.
```

#### 7.4.10 Cosmonauta congelado (`PintorCosmonautaCongelado`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/npc_cosmonauta_congelado.png` (transparente, 600×900).

```
[Línea base]
A Soviet cosmonaut frozen mid-floating, helmet cracked, one arm
extended forward. Frost crystals growing across the suit. Visor
glass showing two small star reflections inside. A small red flag
patch on the shoulder, also frosted. Holds a clipboard with frozen
papers. Cross-hatching for ice texture. Pose: drifting, weightless.
```

#### 7.4.11 Espectro de Directorskov (`PintorEspectroDirectorskov`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/npc_directorskov_espectro.png` (transparente, 600×900).

```
[Línea base]
A Soviet director risen as bureaucratic ghost. Translucent ink
outlines showing a stocky body in a tight overcoat. Bald with three
hair strands flying upward. Holds a giant rubber stamp marked "VETO"
in the right hand. Floats half a meter off the ground (no feet, just
ink-puddle below). Solid red eyes, no pupils. Ink lines trailing
off into wisps at the edges of the figure. Pose: arm raised about
to stamp something. Background: faint sarcophagus silhouette.
```

### 7.5 Combate (`combat_screen.dart`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


#### 7.5.1 Rata mutada (`_PintorRataMutada`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/combate_rata_mutada.png` (transparente, 400×400).

```
[Línea base]
A mutated Soviet sewer rat. Three eyes on the head (two red, one
black). Patches of fur missing showing pink skin. Long curved tail
with a small red star tattoo at the tip. Hunched aggressive pose,
teeth bared. Cross-hatching for fur texture. Small ink trails of
saliva drooling. West-of-Loathing exaggeration.
```

#### 7.5.2 Auxiliar burocrático (`_PintorAuxiliarBurocratico`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/combate_auxiliar_burocratico.png` (transparente, 400×600).

```
[Línea base]
A low-rank Soviet bureaucrat in combat pose: rolled-up shirtsleeves,
clip-on red tie skewed, ink-stained fingers, a sharpened pencil held
like a knife in one hand, a clipboard as shield in the other. Round
spectacles slipping down the nose. Pose: lunging forward. Small red
star pin on the shirt. Cross-hatching for shirt folds.
```

#### 7.5.3 Madre Ferruginosa portátil (`_PintorMadreFerruginosaPortatil`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/combate_madre_portatil.png` (transparente, 400×500).

```
[Línea base]
A shrunken portable version of Madre Ferruginosa for combat: small
samovar (about hand-sized) with four short spider-legs, single
porthole-eye glowing red, tiny chimney puffing one red heart. Three
medals welded to the front. Drips one drop of red tea. She looks
proud despite being tiny.
```

### 7.6 Otros painters genéricos (baja prioridad)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.


#### 7.6.1 Sello oficial (`_PintorSelloOficial`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

Ya cubierto en sección 4.1. Genera el conjunto de 10 sellos.

#### 7.6.2 Cabo de inspección (`PintorCaboInspeccion`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/npc_cabo_inspeccion.png` (transparente, 600×900).

```
[Línea base]
A junior inspection officer. Wears a slightly oversized uniform
coat with cuffs rolled up, peaked cap that keeps slipping down to
his eyebrows. Holds a clipboard. Pose: trying to look authoritative
but slumped shoulders. Three small medals on the chest, one of them
upside down. West-of-Loathing exaggeration.
```

#### 7.6.3 Marco propaganda (`PintorMarcoPropaganda`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/marco_propaganda.png` (transparente, 1000×600).

```
[Línea base]
A decorative ink frame for in-game text panels. Rectangular outer
border with double trembling lines. Each corner has a small red
five-pointed star with hammer-and-sickle motif. Top center: a
banner that wraps around saying "ESTADO MAYOR". Bottom center: a
small empty rubber-stamp circle (for content to be placed inside).
```

#### 7.6.4 Suelo de tablero (`PintorSueloTablero`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/images/fondo_tablero_combate.png` (1920×1080).

```
[Línea base]
An isometric 8x6 grid floor for turn-based combat. Each cell drawn
as a worn cement tile with subtle ink hatching. Some tiles have
faint red painted markings (arrows, numbers, propaganda fragments).
A larger central tile with a red star. Edges of the grid frayed
into rough sketch lines.
```

#### 7.6.5 Mapa overworld (`PintorMapaOverworld`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/images/fondo_overworld.png` (1920×1080).

```
[Línea base]
A hand-drawn galactic map of the Sigma Quadrant. Five planet
silhouettes connected by dotted travel routes (Pravda-12 station
central, Sol Camarada, Gélida-9, Zovnak-4, Pravda-7). Each planet
labelled in serif italic. Red rubber-stamp marks scattered ("VISADO",
"NO ENTRAR"). A large red compass rose in one corner. Paper texture
visible.
```

#### 7.6.6 Cuadrante Sigma (`PintorCuadranteSigma`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/images/fondo_cuadrante_sigma.png` (1920×1080).

Mismo prompt que el mapa overworld pero centrado en el cuadrante.

#### 7.6.7 Urna de Zovnak (`_PintorUrnaZovnak`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/mueble_urna_zovnak.png` (transparente, 500×700).

```
[Línea base]
A Soviet ballot urn from Zovnak-4. Square iron box with a slot
on top, slightly dented. Red star embossed on the front. Padlock
hanging from the side, broken. A handful of paper ballots
overflowing through the slot, some with red marks. Cross-hatching
for metal texture.
```

#### 7.6.8 Transformación ataque (`PintorTransformacionAtaque`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

Esto es un VFX, no un asset estático. **Saltar**.

---

## 8. Cinemáticas + UI adicionales

### 8.1 Modal de transición burocrática (`_PintorSelloOficial`)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

**Archivo destino**: `assets/svg/sello_oficial_gigante.png` (transparente, 800×800).

```
[Línea base]
A massive ceremonial rubber stamp imprint in red ink. Circular
double border, central hammer and sickle, Cyrillic text around the
rim "ОФИЦИАЛЬНО · ПОДТВЕРЖДЕНО" (officially confirmed). Slightly
worn edges, ink fade in patches. Slight rotation -8 degrees.
```

### 8.2 Marco propaganda combate

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

Ver 7.6.3.

### 8.3 Cartel "CONGELADOR · NO TOCAR" / "ACCESO RESTRINGIDO"

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

Pueden ir como PNGs sueltos en `assets/svg/cartel_<nombre>.png` para
intercambio rápido. Mismo estilo que el resto.

**Estado**: decorado ya completado. Existen y están cableados
`cartel_congelador_no_tocar.png`, `cartel_acceso_restringido.png`
y `cartel_gloria_al_camarada.png`.

---

## 9. Cómo va a funcionar el reemplazo

Cuando metas un PNG en su carpeta correcta con el nombre del
**Archivo destino** indicado en este briefing, yo lo sustituyo en el
código eliminando el painter geométrico correspondiente. El cableo
sigue siempre este patrón:

Ya está implementado un helper [`IconoHotspotImagen`] en
`lib/widgets/free_scene.dart` que hace el `Stack` + sombra
automáticamente. El cambio es de una sola línea:

```dart
// ANTES (painter geométrico):
representacion: const IconoHotspotGenerico(
  painter: _PintorXXX(),
),
// línea 871: class _PintorXXX extends CustomPainter { ... }  → ELIMINAR
// (y borrar el import si nadie más lo usaba)

// DESPUÉS (PNG):
representacion: const IconoHotspotImagen(
  rutaAsset: 'assets/svg/<archivo>.png',
),
// Para muebles anchos pasar anchoSombra: 48; para algo muy pequeño 20.
```

Para fondos de escenario completos (en `lib/painters/`), el cableo
es:

```dart
// ANTES:
pintorFondo: PintorEscenarioXXX(fase: ...),

// DESPUÉS:
pintorFondo: PintorImagenEscenario(
  ruta: 'assets/images/fondo_xxx.png',
),
```
(Para fondos completos te creo `PintorImagenEscenario` el día que
entregues el primer planeta en PNG; muebles ya están cubiertos por
`IconoHotspotImagen`).

### Orden de prioridad de sustitución (más visible primero)
1. **Cantina del Olvido**: barril almacén, radio mesa, compuertas (lo
   primero que pisa el jugador).
2. **Cápsula**: archivador, samovar pequeño, compuerta.
3. **Reactor**: monitor propaganda, compuerta ministerio.
4. **Combate**: rata mutada, auxiliar burocrático.
5. **Planetas (fondos completos)**: Sol Camarada → Gélida-9 → Zovnak-4
   → Pravda-7.
6. **NPCs de planetas**: delegado sindical, marciano votante,
   espectros, congelados.
7. El resto.

### Estado actual (qué ya está cableado y qué falta)

> Auditoría realizada 2026-05-16 contra `assets/` y `lib/`. Marca
> "cableado" significa que aparece en algún `.dart` de `lib/`
> (incluyendo interpolación de strings tipo `cadete_${clase}_$estado.png`).

✅ **Hecho — NPCs estáticos**: Portada principal · Ostrog ·
Karenina Archivera · Directorskov (en Pinball Cripta) · Brigada
del Sello (3 variantes: puños, garrote, rifle) · Burócratas-Zombi
(2 frames, walk-cycle en Cosmoom Doom) · Cabo del Cuerpo de
Inspección · Delegado sindical (Sol Camarada) · Burócrata
congelado y Pingüino burocrático (Gélida-9) · Marciano votante
(Zovnak-4) · Cosmonauta congelado · Funcionario espectral ·
Directorskov espectro.

✅ **Hecho — muebles cápsula**: archivador del Comité, cápsula de
llegada, samovar oficial, compuerta acorazada.

✅ **Hecho — muebles cantina**: mesa central, radio de mesa,
barril almacén, compuertas simples, trampilla congelador, carteles
(`cartel_congelador_no_tocar.png`, `cartel_acceso_restringido.png`,
`cartel_gloria_al_camarada.png`).

✅ **Hecho — muebles reactor**: monitor propaganda
(`mueble_monitor_propaganda.png`), compuerta ministerio, vela,
caja anónima, rejilla del conducto, samovar pequeño, mueble tubo,
puerto esclusa, urna Zovnak, almohada, rejilla ventilación.

✅ **Hecho — Pinball Cripta**: sarcófago de Directorskov,
auxiliar burocrático estático y animado (2 frames), bolo
burocrático, rata mutada (2 frames).

✅ **Hecho — fondos completos**: cantina, cápsula, reactor,
overworld, cuadrante sigma, tablero combate y los 4 planetas
(Sol Camarada · Gélida-9 · Pravda-7 · Zovnak-4).

✅ **Hecho — sprite atlas del cadete por clase** (3 clases × 4
estados = 12 PNGs, vía `rutaSpriteClaseCadete` en
`sprite_clase_cadete.dart`): gimnasta/ingeniera/comisaria en
idle/combate/sentada/bola. Cabezas: cadete, ingeniera, comisaria,
krilov, vostrikova.

✅ **Hecho — animaciones multi-frame** (vía `CicloDeFrames` o
interpolación):
- §10.1 Walk cycle cadete (4 frames) en `free_scene.dart`.
- §10.4 Madre Ferruginosa humo (3 frames) — reemplaza el sprite
  estático en la cantina.
- §10.5 Vassiliev humo (3 frames) — reemplaza al estático.
- §10.6 Directorskov flicker (3 frames) en Pinball Cripta.
- §10.8 Cadete daño (2 frames) en combat_screen.
- §10.8 bis Cadete celebración (3 frames) en overlay_celebracion.
- §10.8 ter Cadete grito marcial / sabotaje / decreto (3 frames
  cada una) en `animacion_cadete_combate.dart`.
- §10.9 Llama de vela (3 frames) en hotspot `vela` del reactor.
- §10.10 Estrella roja pulso (4 frames) sobre la portada del menú.
- §10.11 Cadete bola rodando (4 frames) en modo bola.
- §10.12 Cadete bola impacto (2 frames) sobre paredes rotas.
- §10.13.1 Cadete Decreto Burocrático (3 frames) en habilidad
  `comisaria_decreto_realidad`.
- Vapor del samovar (3 frames) en la cápsula.

✅ **Hecho (segunda pasada — auditoría 2026-05-16) — Laika
animada y de papeleo**:
- `laika_mordisco_f01..f03.png`: overlay sincronizado al viaje
  de ataque cuando se ejecuta `accionLaikaMordisco` en combate
  (`combat_screen.dart`, patrón `prefijoFramesHabilidad`).
- `laika_olfato_f01..f02.png`: pista contextual en exploración.
  Laika alterna estos frames cuando acompaña al cadete cerca de un
  secreto físico aún no resuelto en `EscenarioLibre` (grieta, pared
  débil, placa o revelación bajo objeto empujable).
- `laika_ladrando.png`: retrato protagonista de la celebración
  de adopción (`OverlayCelebracion.rutaImagenPersonalizada`,
  invocado desde `_adoptarLaika` en `canteen_screen.dart`).
- `laika_expediente.png`: viñeta opcional dentro del bocadillo de
  la mascota (`_BocadilloMascota` en `free_scene.dart`) cuando la
  frase contiene palabras clave de papeleo (F-447, expediente,
  formulario, comité, sello, papel, anota).

✅ **Hecho — Hotspots de la cápsula (§12)** (auditoría 2026-05-17):
los 9 hotspots invisibles tienen ya su sprite dedicado en
`assets/svg/capsula_*.png` y están cableados con `IconoHotspotImagen`
en `room_screen.dart`. Cubre: retrato familiar, catre, mesilla con
vela, espejo y lavabo, estante de libros, uniforme colgado,
calendario, intercomunicador, manguera de combustible.

✅ **Hecho — Inspector Central**:
- `assets/svg/inspector_central.svg`: cableado en
  `epilogo_screen.dart` como retrato decorativo bajo el título
  cuando el final elegido es `FinalPrototipo.partido` (donde el
  Inspector Krilov recibe la bitácora). Renderizado con
  `SvgPicture.asset` del paquete `flutter_svg ^2.0.10+1` añadido
  al `pubspec.yaml`. Además, generado un respaldo PNG en
  `assets/svg/inspector_central.png` (Inkscape, 512 px de ancho)
  por si en el futuro se prefiere homogeneizar el resto de
  assets SVG-malnombrados.

🗄 **Reemplazados (huellas históricas fuera del bundle)**: estos
PNGs ya están sustituidos por sus series animadas. Se han movido
a `assets_anchors_historicos/` (fuera de `assets/` para no
hinchar el bundle) como **anchors visuales** para futuras
generaciones (ver §4 de `AGENTS.md`):
- `madre_ferruginosa.png`, `madre_ferruginosa_v2.png` →
  reemplazado por `madre_humo_f01..f03`.
- `capitan_vassiliev_v2.png`, `capitan_vassiliev_v3.png` →
  reemplazado por `vassiliev_humo_f01..f03`.

🗄 **Legado archivado fuera del bundle**: assets que ya no se cargan
desde `lib/` y han quedado sustituidos por fondos compuestos, nombres
canónicos nuevos o recursos no usados. Se conservan en
`assets_legacy_historicos/` para recuperación manual, pero dejan de
viajar en el bundle Flutter:
- `compuerta.png`
- `mesa_cantina.png`
- `mueble_compuerta_simple.png`
- `trampilla_congelador.png`
- `sello_tramitar.png`

---

## 10. Sets multi-frame para animación in-game (GIFs internos)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*. Stick figure plano, silueta clarísima, **muy pocas líneas**, cero detalle realista, cero textura pintada. Si dudas entre detalle y simplicidad, simplicidad gana.

Esto NO son GIFs: son **sets de 2–4 PNGs alternables**. El juego los
anima en runtime con `AnimatedSwitcher` o ciclo manual, lo cual da más
calidad (60fps reales, sin compresión GIF) y permite escalado limpio.

### Convención obligatoria de nombres

- `<id>_f01.png`, `<id>_f02.png`, … con padding a dos cifras.
- Todos los frames del mismo set DEBEN tener:
  - Mismo tamaño exacto en píxeles.
  - Misma posición/anclaje del personaje dentro del lienzo (no se
    mueve la silueta entre frames, sólo cambian los miembros que se
    mueven; el resto queda IDÉNTICO pixel-a-pixel).
  - Mismo fondo transparente (PNG con canal alfa real).
- **Por qué importa**: si los frames "saltan" porque el centro del
  personaje se mueve entre uno y otro, el ciclo se ve roto y feo. La
  cabeza no debe moverse. Sólo brazos, piernas, humo, etc.

### 10.1 Cadete protagonista — walk cycle (4 frames)

**Uso**: walk-cycle del cadete cuando recorre escenarios libres
(actualmente procedimental). Permite migrar el escenario libre a sprite.

**Archivos**: `cadete_walk_f01.png`, `cadete_walk_f02.png`,
`cadete_walk_f03.png`, `cadete_walk_f04.png` en `assets/images/`.
**Dimensiones**: 400×600 cada uno.

```
[Línea base] Use the cadet identity rules from briefing section 2.0.
4-frame walking cycle, side view, facing right:
- f01: contact pose, right leg fully extended forward heel down, left
  leg straight back, arms swinging opposite to legs.
- f02: pass pose, left leg straight under body, right leg passing
  forward in air, slight upward bob of the helmet (1-2 px max).
- f03: contact pose mirrored, left leg fully extended forward, right
  leg back, arms swinging the other way.
- f04: pass pose mirrored.
CRITICAL: the helmet center stays in EXACTLY the same x,y across all
4 frames (only the legs and arms differ). Background fully transparent.
```

### 10.2 Cadete combate — golpe (3 frames)

**Uso**: animación rápida cuando el cadete usa una habilidad melee
en combat_screen.dart (actualmente sólo un Transform).

**Archivos**: `cadete_golpe_f01.png` (preparación, brazo atrás),
`cadete_golpe_f02.png` (impacto, brazo extendido al frente),
`cadete_golpe_f03.png` (recuperación, brazo a media altura).
**Dimensiones**: 600×900.

```
[Línea base] Use the cadet identity rules from briefing section 2.0.
3-frame melee attack, frontal 3/4 view:
- f01: weight on back leg, weapon arm pulled back behind head.
- f02: weight forward, weapon arm fully extended toward viewer, motion
  lines (2-3 short ink streaks) trailing behind the weapon.
- f03: neutral stance, weapon arm coming back down to hip height.
Helmet center identical in all 3 frames.
```

### 10.3 Laika — cola moviéndose (2 frames)

**Uso**: reemplaza el wag procedimental cuando Laika acompaña al
cadete en la cantina.

**Archivos**: `laika_idle_f01.png`, `laika_idle_f02.png`.
**Dimensiones**: 400×400.

```
[Línea base] Use the Laika identity rules from briefing section 2.0.5.
Laika sitting, profile view:
- f01: tail curved upward and to the right.
- f02: tail curved upward and slightly to the left (same length, just
  a few degrees of rotation).
Body, head and helmet IDENTICAL across both frames; only the tail
silhouette changes. Background transparent.
```

### 10.4 Madre Ferruginosa — humo del cigarrillo (3 frames)

**Uso**: animación ambiental cuando el cadete habla con la Madre.
Crea sensación de vida sin redibujar el personaje entero.

**Archivos**: `madre_humo_f01.png`, `madre_humo_f02.png`,
`madre_humo_f03.png`.
**Dimensiones**: 800×1100 (mismo lienzo que `madre_ferruginosa_v2.png`,
fondo transparente; el personaje IDÉNTICO al PNG actual).

```
[Línea base]
Same exact composition as madre_ferruginosa_v2.png (the iron-rusted
matron with cigarette). The figure must be pixel-identical across all
3 frames. ONLY the cigarette smoke differs:
- f01: a single short curl of smoke rising 30 px above the cigarette.
- f02: smoke now a longer curl, ~80 px, with one secondary wisp.
- f03: smoke faded, only a thin tail remaining, with two separated
  small puffs floating higher.
Smoke drawn with thin trembling ink lines, no fill.
```

### 10.5 Vassiliev — humo de la pipa (3 frames)

**Uso**: idéntico patrón que Madre. Tres aros rojos del briefing
original (§2.4) se animan dispersándose.

**Archivos**: `vassiliev_humo_f01.png`, `_f02.png`, `_f03.png`.
**Dimensiones**: igual al `capitan_vassiliev_v3.png` actual, transparente.

```
[Línea base]
Same exact composition as capitan_vassiliev_v3.png. Figure pixel-
identical across all 3 frames. ONLY the smoke rings differ:
- f01: one small red ring 40 px above the pipe.
- f02: ring grown and risen, plus a second smaller red ring just
  emerging from the pipe.
- f03: first ring barely visible at top, second ring midway, third
  ring just leaving the pipe.
Rings are simple red ink ellipses, no fill.
```

### 10.6 Directorskov — flicker espectral (3 frames)

**Uso**: en el Pinball Cripta, donde ahora sólo se desvanece por vidas.
Con tres frames el fantasma "parpadea" como un espectro auténtico.

**Archivos**: `directorskov_f01.png`, `_f02.png`, `_f03.png`.
**Dimensiones**: igual al `directorskov.png` actual, transparente.

```
[Línea base]
Same exact silhouette as directorskov.png (the ghost of Director
Directorskov). Figure positionally identical across all 3 frames:
- f01: full silhouette, normal opacity.
- f02: silhouette slightly translated 4 px to the right with a
  trailing duplicate ghost-image at the original position at 30%
  opacity (drawn as a second outline behind).
- f03: silhouette translated 4 px to the left with the same trailing
  duplicate at the original position.
Effect goal: the ghost appears to shudder/shake without breaking
identity. Only translation + opacity change; no redrawing.
```

### 10.7 Burócrata-zombi — ya implementado (2 frames)

**Ya entregado**: `burocrata_zombi_frente.png` + `burocrata_zombi_perfil.png`
funcionan como walk-cycle de 2 frames en Cosmoom Doom.

**Mejora opcional**: añadir `burocrata_zombi_ataque.png` (3.er frame
con los brazos extendidos hacia delante, boca abierta) para disparar
cuando el zombi golpea al jugador. Mismo lienzo, mismas dimensiones.

### 10.8 Brigada del Sello — frame de ataque (3 archivos opcionales)

**Uso**: 1 frame de ataque por variante, para alternarlo con el actual
cuando el enemigo golpea.

**Archivos opcionales**:
- `brigada_sello_garrote_ataque.png` (mismo lienzo, garrote en alto
  golpeando hacia delante).
- `brigada_sello_punos_ataque.png` (mismo lienzo, puño derecho
  extendido al frente).
- `brigada_sello_rifle_ataque.png` (mismo lienzo, fogonazo rojo en
  la boca del rifle).

Mismo tamaño y posición central que las versiones idle ya entregadas.

### 10.9 Llamas de velas — set ambiental (3 frames)

**Uso**: tanto en la Cripta del Pinball como en el Reactor (vela
oficiosa). Hoy son procedimentales.

**Archivos**: `vela_llama_f01.png`, `_f02.png`, `_f03.png`.
**Dimensiones**: 64×96 transparente.

```
[Línea base]
Just the flame of a candle. Three small frames showing the same flame
shape with subtle variation:
- f01: flame tip slightly leaning right.
- f02: flame vertical and slightly taller.
- f03: flame slightly leaning left, shorter.
All three: pure red ink contour, hollow inside, no fill. Background
transparent. The base of the flame stays at the same y-coordinate in
all 3 frames.
```

### 10.10 Estrella roja del título — pulso (4 frames)

**Uso**: estrella central de la portada respira con un pulso lento.

**Archivos**: `estrella_pulso_f01.png` … `_f04.png`.
**Dimensiones**: 256×256 transparente.

```
[Línea base]
A five-pointed Soviet star, red ink contour, hollow inside.
- f01: star at base size.
- f02: star at 105% size with a faint red ring 4 px outside the
  contour.
- f03: star at 100% size again but ring now further out, fainter.
- f04: star at 95% size, no ring (resting phase).
Same center across all 4 frames. Used as a slow pulse cycle (~2s).
```

### 10.11 Cadete bola — rolling cycle (4 frames)

**Uso**: cuando el cadete entra en MODO BOLA para recorrer grietas y
empujar objetos. Hoy se dibuja un círculo procedimental con un
indicador.

**Archivos**: `cadete_bola_f01.png` … `_f04.png` en `assets/images/`.
**Dimensiones**: 400×400 transparente. **Mismo centro exacto** en
todos los frames — sólo cambia la rotación interna.

```
[Línea base] Use the cadet identity rules from briefing section 2.0.
The cadet curled into a ball (helmet inside, knees against chest, arms
hugging legs). Roughly circular silhouette. 4-frame rotation cycle:
- f01: red diagonal sash visible across the top-right of the ball.
- f02: sash rotated 90° clockwise — now on the bottom-right.
- f03: sash rotated 180° — bottom-left.
- f04: sash rotated 270° — top-left.
Across all 4 frames the OUTLINE of the ball is pixel-identical (same
ball, same diameter, same center). Only the interior rotates. Two
short trailing motion lines (small ink streaks) on the back side of
the ball, shifting per frame to suggest motion direction.
```

### 10.12 Cadete bola — impacto / rompe pared (2 frames)

**Uso**: cuando la bola revienta una pared débil o un interruptor
de presión. Da feedback visual de "golpe".

**Archivos**: `cadete_bola_impacto_f01.png`, `_f02.png`.
**Dimensiones**: 500×400 transparente.

```
[Línea base] Use the cadet identity rules from briefing section 2.0.
- f01: the ball compressed horizontally (squashed against an implied
  wall to the right), red sash visible. 3-4 short red impact spikes
  shooting out to the right.
- f02: the ball back to round, surrounded by 6-8 short black ink
  fragments (debris) flying outward, plus one big red ink splash
  behind it.
Same center for the ball across both frames; the explosion expands
outward from the right side.
```

### 10.13 Cadete combate — habilidades por tipo

Tres frames por habilidad. El sufijo del nombre identifica la
habilidad para que el código pueda mapearla directamente.

**Lienzo común**: 600×900 transparente, cadete centrado, pies abajo.

#### 10.13.1 `cadete_sello_decreto_f01..f03.png` (Decreto Burocrático)
```
[Línea base] Use the cadet identity rules from briefing section 2.0.
3-frame casting of a "burocratic decree":
- f01: cadet drawing a giant invisible stamp in the air, arm at chest
  height, an F-447 form materializing in mid-air in front of him as
  ink-line silhouette.
- f02: the cadet stamps the form forward, the stamp face filled in
  red, the form flying away from the cadet toward the right with
  motion lines.
- f03: cadet in follow-through pose, the form gone, three small red
  ink drops where the stamp landed in mid-air.
Helmet position identical in all 3 frames. Only arm + form change.
```

#### 10.13.2 `cadete_grito_marcial_f01..f03.png` (Grito Marcial)
```
[Línea base] Use the cadet identity rules from briefing section 2.0.
3-frame shout/morale ability:
- f01: cadet inhaling, chest puffed up, arms slightly out.
- f02: cadet shouting toward viewer, mouth (a small triangle inside
  the visor) wide open, 4-6 expanding red concentric ink arcs in
  front of the helmet.
- f03: cadet straightening up, arcs dissipated, only 2 thin red
  trails remaining at the edges.
Same helmet center across all 3.
```

#### 10.13.3 `cadete_sabotaje_f01..f03.png` (Sabotaje Técnico)
```
[Línea base] Use the cadet identity rules from briefing section 2.0.
3-frame technical sabotage cast:
- f01: cadet kneels, one hand on the floor placing a small metal
  device (a circle with a red dot in the center).
- f02: cadet rising, device on the floor now showing red lines
  spreading outward like cracks.
- f03: cadet stepping back, device gone, small red explosion mark
  on the floor where it was.
Helmet center: f01 lower (kneeling), f02 mid-height, f03 standing.
That movement is intentional and acceptable here because the cadet
is also rising — but feet must stay at the same y-coordinate.
```

### 10.14 Cadete daño / impacto (2 frames)

**Uso**: cuando un enemigo conecta con el cadete en combate, en
lugar del simple flash rojo actual.

**Archivos**: `cadete_dano_f01.png`, `cadete_dano_f02.png`.
**Dimensiones**: 600×900 transparente.

```
[Línea base] Use the cadet identity rules from briefing section 2.0.
- f01: cadet recoiling backward, torso leaning back ~15°, arms thrown
  forward to defend, helmet jolted. A red splash mark on the chest
  where the hit landed.
- f02: cadet half-recovered, leaning back forward, head down, one
  hand on the chest. Splash mark faded to a fainter outline.
Background transparent. Use to play a brief animation on every hit.
```

### 10.15 Cadete celebración / victoria (3 frames)

**Uso**: tras ganar un combate o resolver un puzzle importante.

**Archivos**: `cadete_celebra_f01.png`, `_f02.png`, `_f03.png`.
**Dimensiones**: 600×900 transparente.

```
[Línea base] Use the cadet identity rules from briefing section 2.0.
3-frame victory cycle:
- f01: cadet standing relaxed, one arm starting to rise.
- f02: both arms above head in V-shape, feet slightly off the floor
  (small jump), 3 short red sparkle marks around the helmet.
- f03: cadet landing, arms still up but lower, helmet centered, 1-2
  fading sparkle marks.
Feet at the same y across f01 and f03; f02 may be ~30 px higher.
```

### 10.16 Cadete idle / respira (2 frames opcionales)

**Uso**: subtle breathing in static dialogue scenes para que el
cadete no parezca un cartón.

**Archivos**: `cadete_idle_breath_f01.png`, `_f02.png`.
**Dimensiones**: 600×900 transparente (mismo lienzo que §10.14/§10.15
para alinearse pixel a pixel con el cadete de combate).

```
[Línea base] Use the cadet identity rules from briefing section 2.0.
- f01: cadet standing neutral, chest at base height.
- f02: same exact pose with the chest line raised 3-4 px (slight
  inhale). Helmet may bob up 1-2 px.
Subtle — must look like the cadete is alive, not posing.
```

### 10.17 Laika en combate — mordisco (3 frames)

**Uso**: cuando el cadete invoca a Laika con `accionLaikaMordisco`.
Hoy es un efecto procedimental simple.

**Archivos**: `laika_mordisco_f01.png`, `_f02.png`, `_f03.png`.
**Dimensiones**: 500×400 transparente.

```
[Línea base] Use the Laika identity rules from briefing section 2.0.5.
3-frame attack:
- f01: Laika crouched, ears back, mouth opening (small triangular
  gap inside helmet), tail straight out behind her.
- f02: Laika lunging forward, mouth fully open with a red bite mark
  shape protruding to the right, body stretched, hind legs pushing.
- f03: Laika returning to neutral, mouth closed, a small red ink
  splash hanging in mid-air where the bite landed.
Same vertical anchor (feet line) across all 3 frames.
```

### 10.18 Laika rastreo / olfateo (2 frames)

**Uso**: cuando Laika ayuda a encontrar un objeto oculto en
escenarios. Reemplaza el ladrido procedimental.

**Archivos**: `laika_olfato_f01.png`, `_f02.png`.

```
[Línea base] Use the Laika identity rules from briefing section 2.0.5.
- f01: Laika with nose to the ground, body crouched low, tail straight.
- f02: same pose, but with 3 small dotted-line "smell" arcs emerging
  from the visor of the helmet up to a small red triangular icon
  (the scent trail).
Body identical between frames; only the dotted arcs and triangle
appear in f02.
```

### 10.19 Lista corta de "estaría bien tener" (no urgentes)

- **Rata mutada**: idle 2 frames (cola moviéndose). Lienzo de la
  futura `rata_mutada.png`.
- **Auxiliar burocrático**: 2 frames de sellado (brazo arriba/abajo).
- **Inspector Central SVG**: ya animable en código sin frames extra.
- **Goteo del reactor**: ya implementado con `EfectoGoteoIntermitente`.
- **Vapor del samovar**: 3 frames de vapor saliendo. Lienzo de la
  futura `samovar_oficial.png`.
- **Banderas de la portada**: 2 frames de flameo. Para versión
  animada de la portada (no urgente — la imagen actual ya funciona).

### ¿Cuándo te conviene encargar un set frente a un PNG suelto?

- **Encarga un set** cuando el elemento esté en pantalla mucho rato
  (cadete protagonista, Laika de cantina, velas siempre visibles).
- **Encarga sólo un PNG** cuando el elemento aparezca en flash
  rápido o en escenas estáticas (sellos, retratos burocráticos, NPCs
  que sólo aparecen al hablar).
- **Regla del 80/20**: si vas justo de tiempo, prioriza el walk-cycle
  del cadete (§10.1) y el humo de Madre (§10.4) — son los que más
  cambian la sensación del juego con menos trabajo.

---

## 11. Pinball del Comité (alta prioridad)

> **Estilo**: garabato minimalista inspirado en *West of Loathing*,
> aplicado a una **mesa de pinball burocrática**. El tablero entero
> debe leerse como **rotulador sobre papel viejo**, no como pinball
> realista metálico. Sellos rojos como inserts, flechas a tinta como
> guías de tiro, ornamentos constructivistas en los bordes. Paleta
> estricta (papel #F5F1E8, tinta #15110D, rojo #C8102E, gris tenue
> #625E58).

El minijuego `pantalla_pinball_comite.dart` tiene **3 tableros
encadenados** y todos los elementos son actualmente procedurales
(CustomPainter). Reemplazar los tableros y piezas clave por PNGs
eleva el minijuego de "boceto técnico" a "máquina de pinball
burocrática que vibra de presencia". El cableado sigue el patrón
de `sarcofago.png` (carga única con `rootBundle.load` en
`initState`, paso al painter como `ui.Image?`, `drawImageRect` si
está disponible, fallback procedural si falta).

### 11.1 Fondo del tablero — Antecámara (`pinball_tablero_antecamara.png`)

**Archivo destino**: `assets/svg/pinball_tablero_antecamara.png`
(transparente, 1000×1500 — proporción 2:3 igual que la mesa del
juego con `anchoMesa: 1.0` y `altoMesa: 1.5`).

```
[Línea base] Hand-drawn ink-marker style on aged cream paper
(#F5F1E8). Strictly two-color: black ink (#15110D) and one official
red (#C8102E). No browns, blues, greens, yellows.

A vertical pinball table playfield labeled "ANTECÁMARA DEL COMITÉ"
in a big constructivist title at the top edge. Background art only
— no flippers, bumpers, slingshots, targets, ramps or balls (those
are overlaid at runtime). The background includes:
- Two slanted red arrows pointing toward the upper lanes.
- A circular red star-stamp insert at each future bumper position
  (three slots: upper-left, upper-center, upper-right).
- A red rectangular stamp area at the saucer position (top-center)
  with the text "F-447 RETENIDO".
- A bottom arc with hand-drawn dashed line marking the outhole.
- Two diagonal red arrows on the lower flanks marking the
  slingshot zones.
- A vertical red dotted lane on the right marking the plunger
  channel.
- Hand-trembling double-pass ink frame around the whole table.

Cross-hatching only for shadows, 4-6 lines max.
```

### 11.2 Fondo del tablero — Salón de Trámites (`pinball_tablero_salon.png`)

**Archivo destino**: `assets/svg/pinball_tablero_salon.png` (1000×1500).

```
[Línea base] Same paper + two-color rules as 11.1.

Vertical pinball playfield titled "SALÓN DE TRÁMITES". Background
art only. Visual elements:
- A bureaucratic chandelier silhouette at the top center, hand-drawn
  in thin trembling ink — three samovar-shaped pendants hanging.
- Three round red stamp circles arranged in a triangle in the
  upper half (future bumper positions for samovars).
- Two long vertical red dashed targets on each side of the middle
  (future drop-target banks).
- A horizontal hand-drawn shelf with hand-lettered "PAPELERA",
  "URGENTE", "FIRMAR" labels.
- Same trembling ink frame and plunger channel on the right.
```

### 11.3 Fondo del tablero — Cripta de Directorskov (`pinball_tablero_cripta.png`)

**Archivo destino**: `assets/svg/pinball_tablero_cripta.png` (1000×1500).

```
[Línea base] Same rules as 11.1.

Vertical pinball playfield titled "CRIPTA DEL DIRECTOR". Solemn
and ceremonial. Background art only:
- A central red mandorla-shape (vesica piscis) at the upper third
  marking the boss-sarcophagus drop zone, with the hand-stenciled
  word "DIREKTOR" in constructivist style.
- Two flanking red banners with crossed-hammer-and-quill marks.
- A bottom arc of small red star-stamps along the outhole rim.
- Hand-drawn bureaucratic runes (random F-447 fragments, sealed
  numbers, stamp marks) scattered across the lower half as floor
  decoration.
- Same trembling ink frame and plunger channel.
```

### 11.4 Bumper retrato (`pinball_bumper.png`)

**Archivo destino**: `assets/svg/pinball_bumper.png` (transparente,
240×240).

```
[Línea base] Hand-drawn ink doodle, two-color (black + red).

Top-down view of a circular pinball bumper. Outer ring: thick black
ink circle with double trembling pass. Inner ring: thin red ink
circle. Center: a tiny stamped bureaucratic face — round head,
nose-bumper, hand-lettered "K." on the forehead. Three short red
exclamation lines radiating outward at 120° intervals to suggest
impact. No metal sheen, no plastic gloss — just ink + red stamp.
```

### 11.5 Slingshots izquierdo / derecho (`pinball_slingshot_izq.png` / `_der.png`)

**Archivos destino**: `assets/svg/pinball_slingshot_izq.png` y
`pinball_slingshot_der.png` (transparentes, 220×220 cada uno; el
derecho es espejo del izquierdo).

```
[Línea base] Hand-drawn ink, two-color.

Triangular pinball slingshot, top-down view. Right triangle with
the hypotenuse facing inward (toward table center). Thick black
ink stroke, double-pass trembling. Inside the triangle:
- A red lightning-bolt symbol indicating kicker activation.
- Two short red arrows along the hypotenuse pointing outward.
- A hand-stamped red "SELLADO" label at the base of the triangle.
The hypotenuse must stay clean (no ornaments overlapping it) since
that's where the ball bounces. The "_der" version is the mirror
image of "_izq".
```

### 11.6 Flippers (`pinball_flipper_izq.png` / `_der.png`)

**Archivos destino**: `assets/svg/pinball_flipper_izq.png` y
`pinball_flipper_der.png` (transparentes, 320×100 cada uno).

```
[Línea base] Hand-drawn ink, two-color.

Pinball flipper paddle, top-down view, in resting position
(horizontal). Stylized as a hand-lettered ruler/baton:
- Black ink outline of an elongated rounded rectangle, narrower at
  the pivot end and wider at the tip.
- A red round rivet at the pivot end (left side for "_izq",
  right side for "_der").
- A red hand-lettered "F-447" stamp in the middle of the paddle.
- Two short red impact lines at the tip suggesting the strike zone.
The pivot must be at the inner edge of the canvas — that's the
anchor point Flutter will rotate around. The paddle extends
outward from the pivot to the tip.
```

### 11.7 Target vertical (`pinball_target_activo.png` / `pinball_target_caido.png`)

**Archivos destino**: `assets/svg/pinball_target_activo.png` (80×260) y
`pinball_target_caido.png` (mismo tamaño, target tumbado).

```
[Línea base] Hand-drawn ink, two-color.

A pinball drop target rendered as a vertical bureaucratic placard:
- "_activo": tall hand-drawn placard standing upright, black ink
  outline, red title at the top reading "PROHIBIDO", red stamp at
  the center, base hatched with 3-4 ink lines for shadow.
- "_caido": same placard but tilted ~75° forward as if just knocked
  down, the red stamp now visibly crossed out with two red strokes,
  small red impact lines around the base.
Same dimensions for both so they swap seamlessly in place.
```

### 11.8 Lane superior insert (`pinball_lane_apagado.png` / `_encendido.png`)

**Archivos destino**: `assets/svg/pinball_lane_apagado.png` y
`pinball_lane_encendido.png` (90×160 cada uno).

```
[Línea base] Hand-drawn ink, two-color.

A pinball lane insert seen from above — vertical rectangular
"runway" with an arrow pointing downward:
- "_apagado": thin black ink rectangle outline, faded red arrow
  inside (thin dashed strokes, low presence).
- "_encendido": same rectangle, but the arrow now filled solid red
  with two short red exclamation marks at the bottom suggesting
  the lane has been triggered.
Both PNGs share the exact same outline so swapping doesn't shift
the visual.
```

### 11.9 Spinner (`pinball_spinner.png`)

**Archivo destino**: `assets/svg/pinball_spinner.png` (transparente,
160×160).

```
[Línea base] Hand-drawn ink, two-color.

Top-down view of a pinball spinner — a thin rectangular paddle that
rotates around a vertical axis. Black ink stroke outline of a
horizontal rectangle (~140 px wide, ~30 px tall), centered in the
canvas. Inside: a tiny red star-stamp at one tip and a hand-lettered
"GIRA" label at the other. The center has a tiny black dot marking
the rotation axis. Flutter rotates the whole PNG around the canvas
center, so anchor exactly there.
```

### 11.10 Lanzador-resorte (`pinball_lanzador_resorte.png`)

**Archivo destino**: `assets/svg/pinball_lanzador_resorte.png`
(transparente, 110×320).

```
[Línea base] Hand-drawn ink, two-color.

A vertical pinball plunger drawn as a hand-stamped office paper-clip
spring:
- Tall black ink rectangle outline forming the channel.
- Inside the channel, a hand-drawn helical spring (six loops) in
  black ink, slightly trembling.
- At the bottom, a red round knob (the player grip).
- Two small red arrows pointing upward at the top suggesting the
  spring will launch upward.
The spring portion will be vertically squeezed at runtime to suggest
charging, so keep all six loops evenly spaced.
```

### 11.11 Saucer (`pinball_saucer.png`)

**Archivo destino**: `assets/svg/pinball_saucer.png` (transparente,
240×240).

```
[Línea base] Hand-drawn ink, two-color.

Top-down view of a pinball saucer hole (a circular pit where the
ball is captured briefly). A thick black ink circle, double-pass
trembling, with a smaller black circle inside suggesting depth.
Inside the inner circle:
- A bold red hand-lettered "F-447 RETENIDO" curving around the
  top half.
- A red sealed stamp mark at the bottom half.
- Two small red dotted lines around the outer rim suggesting
  flashing alarm lights.
```

### Estado actual del cableado del pinball

✅ **Hecho — set visual completo §11**:
- Fondos: `pinball_tablero_antecamara.png`,
  `pinball_tablero_salon.png`, `pinball_tablero_cripta.png`.
- Piezas: `pinball_bumper.png`,
  `pinball_slingshot_izq.png` / `_der.png`,
  `pinball_flipper_izq.png` / `_der.png`,
  `pinball_target_activo.png` / `_caido.png`,
  `pinball_lane_apagado.png` / `_encendido.png`,
  `pinball_spinner.png`, `pinball_lanzador_resorte.png`,
  `pinball_saucer.png`.

El minijuego ya puede cargar todo el paquete opcional de PNGs vía
`pantalla_pinball_comite.dart`; si alguno faltase en el futuro,
mantiene su fallback procedural.

✅ **Mejoras visuales ya aplicadas (auditoría 2026-05-16)**:
- Radio de la bola subido de 0.028 a 0.040 (+43 %) — la bola se
  lee claramente y el cadete-bola tiene presencia.
- Bola animada con los 4 frames `cadete_bola_f01..f04` cicleando
  según distancia recorrida (antes sólo se renderizaba f01).

---

## 12. Cápsula del Cadete · hotspots invisibles (alta prioridad)

> **Estilo**: garabato minimalista West of Loathing, paleta papel
> +tinta+rojo. Vista 3/4 — el cadete camina por una pasarela que
> muestra cada elemento de perfil o frontal. Trazo grueso, doble
> pasada temblorosa, mínimas líneas internas.

Estos 9 hotspots ya existen en `room_screen.dart` como zonas
interactivas con texto y consecuencias, pero su representación
visual es `SizedBox.shrink()` — dependen del fondo
`fondo_capsula.png` para que el jugador los vea, y ese fondo no
los pinta con suficiente detalle para identificarlos. Añadir un
PNG dedicado por hotspot resuelve el problema sin tocar lógica:
basta con sustituir `SizedBox.shrink()` por `IconoHotspotImagen(...)`
con la ruta correspondiente en `lib/screens/room_screen.dart`.

`IconoHotspotImagen` ya tolera PNGs ausentes silenciosamente
(`errorBuilder` interno), pero hasta que lleguen los assets
conviene mantener `SizedBox.shrink()` en el código para evitar
sombras-fantasma.

### 12.1 Retrato familiar (`capsula_retrato_familiar.png`, 240×400)

```
[Línea base] Hand-drawn ink doodle, paper+ink+red palette.

A small framed family portrait hanging vertically on a metal
bulkhead. Inside the frame: two stick figures in cosmonaut suits
holding a tiny baby stick figure between them. All three smile
politely. A red star stamped in the upper-right corner of the
frame. Slight tilt to the right (~3°) to suggest the bulkhead
vibrates from a distant reactor. Trembling double-pass black ink
outline around the frame. Background fully transparent.
```

### 12.2 Catre (`capsula_catre.png`, 400×260)

```
[Línea base] Hand-drawn ink doodle, paper+ink+red palette.

A bureaucratic military cot, 3/4 perspective: thin black metal
frame with crossed-tube legs, sagging mattress with two horizontal
ink lines suggesting compression, a folded grey blanket at one
end, a single tiny red "ОФК" ink-stamp on the foot of the
mattress. No pillows (the pillow is a separate hotspot). Cross-
hatched shadow underneath. Narrow, austere, slept-in.
```

### 12.3 Mesilla con vela (`capsula_mesilla_vela.png`, 220×320)

> Substituye al `mueble_vela.png` cableado hoy — incluye la vela
> y la mesilla en un solo asset mejor compuesto.

```
[Línea base] Hand-drawn ink doodle, paper+ink+red palette.

A small metal nightstand seen from 3/4 perspective. On top: a
single thick candle in a brass holder, lit, with a tiny red flame
(two strokes max). Beside the candle: a folded paper labeled
"F-447" in hand-stenciled red letters, and a ring of metal keys
hanging from one edge. The nightstand has one drawer half-open
showing a folded undergarment. Trembling double-pass ink outline.
```

### 12.4 Espejo y lavabo (`capsula_espejo_lavabo.png`, 260×440)

```
[Línea base] Hand-drawn ink doodle, paper+ink+red palette.

A small metal wall-mounted basin under a rectangular mirror,
3/4 perspective. The mirror is empty (no reflection — just crossed
lines suggesting glass) with a single horizontal red crack across
it. The basin has a single tap and a tiny bar of state-issued
soap (red rectangle with one ink "СПТ" stamp). Below: a metal
drainpipe disappearing into the wall.
```

### 12.5 Estante de libros (`capsula_estante_libros.png`, 300×220)

```
[Línea base] Hand-drawn ink doodle, paper+ink+red palette.

A short wall shelf (3/4 perspective) holding seven thick
bureaucratic ring-binders standing upright. Each binder is a
plain rectangle with a different red stamp on its spine ("F-447",
"K-12", "STAT", "PRAVDA-7", "OFK", "FECHA", "CONFIDENCIAL"). One
binder leans diagonally as if recently consulted. The shelf
itself is held by two trembling L-brackets. No actual books —
only binders, which is the joke.
```

### 12.6 Uniforme colgado (`capsula_uniforme_colgado.png`, 260×440)

```
[Línea base] Hand-drawn ink doodle, paper+ink+red palette.

A full cosmonaut uniform hanging from a hook on the bulkhead,
3/4 perspective. Empty — no body inside. Stiff fabric (drawn with
straight short ink strokes), a red star sewn on the chest, a row
of three red medals pinned above the heart, and a hand-stenciled
name tag "CADETE" near the collar. The trousers hang from the
same hook below the jacket, slightly creased.
```

### 12.7 Calendario (`capsula_calendario.png`, 220×280)

```
[Línea base] Hand-drawn ink doodle, paper+ink+red palette.

A wall-mounted bureaucratic calendar, frontal view. A 6×5 grid of
small squares, hand-drawn trembling ink, with the title
"MIÉRCOLES" in big red letters at the top — every single square
on the calendar is labeled "MIÉRCOLES" too (joke: it's always
Wednesday since the Pravda-7 incident). One square is circled in
red marker — the one corresponding to the day the cadet arrived.
Slight curl at the corners of the paper.
```

### 12.8 Intercomunicador (`capsula_intercomunicador.png`, 220×340)

```
[Línea base] Hand-drawn ink doodle, paper+ink+red palette.

A wall-mounted bureaucratic intercom, frontal view. Metal box
with rounded corners, a perforated speaker grille (small dots in
a 6×4 grid), a single red push-button at the bottom labeled
"AVISO", a curly black cable hanging down on one side ending in a
detached handset (the handset rests on a small hook). A tiny red
"L-12" plate at the top corner indicating channel number.
```

### 12.9 Manguera de combustible (`capsula_manguera_combustible.png`, 180×320)

```
[Línea base] Hand-drawn ink doodle, paper+ink+red palette.

A coiled fuel hose hanging on the floor near the docking port,
3/4 perspective. Black trembling ink coil with about 5 visible
loops, a heavy metal nozzle at the free end (red triangle hazard
sticker on its side), and a thicker grey segment where it meets
the wall connector. The hose looks coiled but not perfectly —
a slight slump suggesting recent use. Small red drip stain on the
floor under the nozzle.
```

### Cableado completado (2026-05-17)

Los 9 hotspots ya están cableados en `lib/screens/room_screen.dart`
con `IconoHotspotImagen(rutaAsset: 'assets/svg/capsula_<id>.png',
anchoSombra: …)`. `IconoHotspotImagen` tolera ausencia silenciosa
del PNG via `errorBuilder`, así que el cableado es seguro incluso
si más adelante alguno de los assets se sustituye.

Caso especial: `mesilla_vela` se migró del antiguo
`mueble_vela.png` (sólo vela) al `capsula_mesilla_vela.png` (§12.3,
mesilla + vela en un único asset mejor compuesto). El primero queda
huérfano pero útil como anchor visual para otras escenas que
necesiten sólo la vela.

Anchos de sombra aplicados (tabla canónica para futuras revisiones):

| Hotspot | `anchoSombra` |
|---|---|
| `retrato_familiar` | 20 (cuelga de la pared) |
| `catre` | 56 (mueble ancho a ras de suelo) |
| `mesilla_vela` | 32 |
| `espejo_lavabo` | 32 |
| `estante_libros` | 36 (cuelga) |
| `uniforme_colgado` | 20 (cuelga) |
| `calendario` | 20 |
| `intercomunicador` | 20 |
| `manguera_combustible` | 40 (suelo) |

---

## 13. Cosmoom Doom · sprites pseudo-3D (alta prioridad)

> **Estilo**: garabato West of Loathing aplicado a un FPS estilo
> Wolfenstein 3D. Sprites planos, frontal y perfil. Paleta papel +
> tinta + rojo. **Crucial**: los sprites se renderizan a escala
> grande sobre un mundo pseudo-3D, así que cada PNG necesita ser
> claro a distancia y consistente con el burócrata-zombi existente
> (`burocrata_zombi_frente.png`, `burocrata_zombi_perfil.png`).

El minijuego `pantalla_cosmoom_doom.dart` (1814 líneas) es el más
gráfico-pesado del juego: ~1071 líneas de painter raycasting. Hoy
sólo carga 2 sprites (los burócratas-zombi en frente/perfil). El
resto — paredes, suelo, sellos volantes, HUD del cadete — es
geometría procedural. Estos 5 PNGs nuevos cubrirían los elementos
con más superficie en pantalla.

### 13.1 Pared de Ministerio (`doom_pared_ministerio.png`, 512×512)

Textura tileable que se aplica a cada cara de pared en raycasting.

```
[Línea base] Hand-drawn ink doodle on aged cream paper.

A 512×512 tileable wall texture in the West of Loathing style.
Paper cream background (#F5F1E8). Vertical motif: hand-drawn
square panel with a red official seal in the center (a stylized
hammer-and-quill mark, no Cyrillic), thin double-pass black ink
lines forming the panel frame, four small black rivets at the
corners. The pattern must tile horizontally — the right edge
must connect seamlessly to the left edge so the wall doesn't
show seams when repeated across a long corridor. Vertically it
does NOT need to tile (walls are not stacked).
```

### 13.2 Suelo de baldosa burocrática (`doom_suelo_baldosa.png`, 512×512)

Textura tileable que se aplica al "suelo" del raycaster.

```
[Línea base] Hand-drawn ink doodle on aged cream paper.

A 512×512 fully tileable floor pattern. Repeating 4×4 grid of
ink-stenciled squares with alternating motifs: half show a small
red star, half show a hand-stamped "F-447" in faded red. Thin
black ink borders between tiles, trembling. The pattern must tile
both horizontally AND vertically without visible seams (the floor
extends in all directions under the camera). No 3D shading — flat
top-down doodle.
```

### 13.3 Mesa burocrática (`doom_mesa_burocratica.png`, 320×440)

Sprite plano (billboard) para mesas en mitad del corredor — obstáculo
estático.

```
[Línea base] Hand-drawn ink doodle, paper+ink+red palette.

A front view of a bureaucratic desk, drawn as a flat doodle for
billboard rendering. Rectangular desk top, four straight legs,
a single drawer on the front with a red knob. On top: a stack of
3-4 folders, an inkwell with a quill sticking up, a desk lamp
with a tiny red bulb. No perspective — completely flat front view.
Trembling double-pass ink outline so the silhouette is unmistakable
when scaled up.
```

### 13.4 Sello rojo proyectil (`doom_sello_proyectil.png`, 160×160)

Sprite del proyectil que dispara el cadete (o el zombie) hacia
delante. Pequeño, leíble en movimiento rápido.

```
[Línea base] Hand-drawn ink doodle, paper+ink+red palette.

A frontal view of a red bureaucratic ink stamp imprint flying
toward the camera. A bold red circular seal with the cyrillic-look
text "ОФК" (OFK) curved around the top half, a red hammer-and-quill
in the center, and two short red motion lines trailing diagonally
behind to suggest speed. Slightly tilted (-12°) for dynamic feel.
Transparent background; the sprite should read clearly even at
small sizes.
```

### 13.5 HUD del cadete (`doom_hud_cadete.png`, 800×260)

Marco inferior fijo de la pantalla — donde van la vida, munición
y el sello equipado.

```
[Línea base] Hand-drawn ink doodle, paper+ink+red palette.

A horizontal HUD frame for the bottom of an FPS screen. Wide
rectangular strip (800×260) with three sections:
- Left third: small portrait window with the cadet's helmet (just
  the helmet, frontal, with red star) and a red heart icon plus
  numeric placeholders [_ _ _] (the actual values are painted at
  runtime by Flutter, so leave the heart with a blank space next
  to it).
- Center third: a large red stamp-shaped placeholder labeled
  "SELLO EQUIPADO" with a blank circle inside for the runtime
  icon.
- Right third: a stack of three small horizontal red bars labeled
  "F-447 · MUNICIÓN" (the actual bar fill is painted at runtime).
Thick black ink border around the whole HUD, double-pass trembling.
Internal dividers between the three sections.
```

### Cableado pendiente

`pantalla_cosmoom_doom.dart` ya tiene el patrón de `_cargarImagenDesdeAsset`
para los burócratas-zombi (línea 122). Replicar para estos 5 nuevos:

```dart
ui.Image? imagenParedMinisterio;
ui.Image? imagenSueloBaldosa;
ui.Image? imagenMesaBurocratica;
ui.Image? imagenSelloProyectil;
ui.Image? imagenHudCadete;

// En initState (paralelo a las dos llamadas existentes):
final pared = await _cargarImagenDesdeAsset('assets/svg/doom_pared_ministerio.png');
final suelo = await _cargarImagenDesdeAsset('assets/svg/doom_suelo_baldosa.png');
// ...etc
```

En el painter (`_PintorVistaDoom`), donde se pintan las paredes
con `canvas.drawRect` por columna, sustituir por
`canvas.drawImageRect` consultando la columna correspondiente de
la textura. El suelo es procedimental por filas — mismo patrón.
Esto convierte el minijuego de "boceto técnico" a "pasillo
ministerial reconocible" con cinco assets.

---

## 14. Snow Kamarada · plataforma soviética (alta prioridad)

> **Estilo**: garabato West of Loathing aplicado a un plataformas
> nieve/Guerra Fría. Paleta papel + tinta + rojo. Sprites planos,
> silueta clarísima. El cadete recorre una colina nevada lanzando
> formularios F-447 mientras invasores capitalistas le acechan.

`pantalla_snow_kamarada.dart` (1791 líneas, 100 % procedural) es
el 2º minijuego en peso de painter. Estos 5 PNGs sustituyen los
elementos que ocupan más superficie en pantalla.

### 14.1 Cadete con ushanka — caminando (`snow_cadete_ushanka_walk_f01..f04.png`, 240×360 c/u)

Set de 4 frames para walk-cycle lateral, mismo principio que
`cadete_walk_f0X.png` pero con ushanka y abrigo soviético.

```
[Línea base] Hand-drawn ink, two-color (black + red).

4-frame walking cycle of a Cosmo-Soviet cadet, side view, facing
right, wearing a thick ushanka (winter fur hat with ear-flaps)
and a heavy buttoned coat down to the knees. The silhouette is
boxier than the regular cadet (winter clothing). Mandatory red
star on the front of the ushanka. The hat must stay PIXEL-PERFECT
identical across all 4 frames — only legs and arms swing.

- f01: contact pose, right leg fully extended forward heel-down.
- f02: pass pose, left leg straight under body, right passing
  forward in air, slight upward bob of the ushanka (1-2 px max).
- f03: contact pose mirrored.
- f04: pass pose mirrored.
Background fully transparent.
```

### 14.2 Capitalista espacial — invasor base (`snow_capitalista.png`, 220×340)

Sprite estático del enemigo principal — empresario con sombrero
de copa y maletín.

```
[Línea base] Hand-drawn ink, two-color (black + red).

Front view of a capitalist invader. Tall thin stick figure in
business suit with hand-stenciled red dollar sign on the chest,
black top hat, oversized briefcase in one hand (red "$$$" mark on
the side), bulging eyes drawn as two small "$" shapes. Standing
on a small puff of red anti-gravity exhaust (3-4 short ink
strokes at the feet) suggesting he hovers. No legs visible —
floats. Trembling double-pass ink outline.
```

### 14.3 Formulario F-447 disparado (`snow_formulario_proyectil.png`, 120×120)

Proyectil que el cadete lanza. Pequeño, debe leerse en movimiento.

```
[Línea base] Hand-drawn ink, two-color.

A small folded paper labeled "F-447" in red hand-stenciled
letters, flying upward through the air. The paper is creased into
a paper airplane shape with a single sharp tip pointing forward.
Two short red motion lines trail behind. The sheet has a tiny red
seal stamp on its body. The PNG is square (120×120) but the plane
only occupies the diagonal, leaving transparent corners for
rotation at runtime.
```

### 14.4 Bola de papel sellada (`snow_bola_papel.png`, 220×220)

Power-up / mecánica especial: el cadete puede meterse en una bola
de papel sellada y rodar (mismo vocabulario que el "modo bola"
del cadete en escenarios libres).

```
[Línea base] Hand-drawn ink, two-color.

Top-down circular view of a cosmonaut curled into a ball of
crumpled bureaucratic paper. Black ink outline of a slightly
irregular circle with several creased fold lines inside (hand-
drawn trembling diagonals). On the outside surface: three red
official seals stamped at uneven angles ("F-447", "ОФК",
"VISADO"), as if the cadet rolled himself through a Comité
inspection. Tiny crossed legs and arms peek out from two openings
at top and bottom. Transparent background.
```

### 14.5 Fondo paisaje gélido (`snow_fondo_paisaje.png`, 1920×1080)

Reemplaza la aurora boreal procedural (paths ondulados) y la luna
con un PNG estático. Las partículas de nieve siguen siendo
runtime.

```
[Línea base] Hand-drawn ink doodle on aged cream paper.

Wide horizontal landscape (1920×1080) for the back layer of a
side-scrolling platformer. Hand-drawn snow horizon at the bottom
third (white-paper hills with trembling ink contour lines), three
distant Soviet broadcast antennas on the hills (each just two
straight vertical lines with a red star on top), a single huge
red star — the moon-substitute — high in the sky upper-right
(no shading, flat red disc with a small black "СССР" 2-letter
inscription in the center). Two faint red ink ribbons across the
sky suggesting aurora; not too detailed since runtime particles
will overlay.
```

### Cableado pendiente

En `pantalla_snow_kamarada.dart` añadir 8 campos `ui.Image?`
(4 frames cadete + capitalista + proyectil + bola + fondo), cargar
en `initState` con el patrón `_cargarSpritesPinballOpcionales` ya
usado en pinball (try/catch silencioso + `Future.wait`), pasar al
painter y dibujar con `drawImageRect` cuando estén disponibles.
Mantener fallback procedural.

---

## 15. Camarada Invasors · invasión capitalista (alta prioridad)

> **Estilo**: garabato West of Loathing aplicado a Space Invaders
> de la Guerra Fría. Cuatro tipos de invasor caen en oleadas. El
> cadete dispara desde un cañón bureaucrático en la base. Paleta
> estricta paper+ink+red.

`pantalla_camarada_invasors.dart` (1300 líneas, painter 580) tiene
4 tipos de invasor (`tioSam`, `soldadoUsa`, `hamburguesa`,
`cocaCola`) más bunkers, disparos y el cañón. Estos 7 PNGs cubren
toda la pantalla.

### 15.1 Tío Sam invasor (`invasors_tio_sam.png`, 180×220)

Invasor más alto en la pantalla — fila superior, vale más puntos.

```
[Línea base] Hand-drawn ink, two-color (black + red).

Front view of a stylized Uncle Sam head + shoulders flying as
an alien invader. Tall striped top hat (vertical alternating
black-ink and red-fill stripes, 5-6 stripes), star-band around
the base of the hat (4-5 small red stars), exaggerated long beard
(downward hand-drawn ink strokes), bulging eyes pointing forward,
mouth shaped into a wide hostile grin showing two big teeth.
Both arms extended sideways pointing accusatorial fingers. Below
the shoulders: a small red puff suggesting jet propulsion (no
body needed).
```

### 15.2 Soldado USA invasor (`invasors_soldado_usa.png`, 160×200)

Fila intermedia, valor medio.

```
[Línea base] Hand-drawn ink, two-color.

Front view of a cartoon American GI soldier flying as alien
invader. Round helmet with red star sticker, square jaw, military
uniform with two red chest pockets, hands gripping a small rifle
held horizontally across the chest. Below the waist: red exhaust
puff (no legs). Slightly menacing eyes (two angled ink lines for
brows). Smaller than Tío Sam, similar silhouette but more compact.
```

### 15.3 Hamburguesa flotante (`invasors_hamburguesa.png`, 160×140)

Fila inferior-media, valor más bajo. Visual cómico.

```
[Línea base] Hand-drawn ink, two-color.

Top-down 3/4 view of a flying hamburger with cartoon eyes. Bun
top + bun bottom (two ovals with ink-stippled "seeds" pattern on
the top), red meat patty visible between them (hand-drawn red
fill), two lettuce leaves sticking out (drawn as two trembling
curved ink shapes). Two googly cartoon eyes (white circles with
black dots) at the front of the bun. Two tiny red wings on the
sides — they flap at runtime (this asset is the static base).
```

### 15.4 Coca-Cola invasora (`invasors_coca_cola.png`, 140×220)

Fila inferior, mayor cantidad.

```
[Línea base] Hand-drawn ink, two-color.

Front view of a classic glass cola bottle flying as alien invader.
Contoured silhouette of a hand-drawn glass bottle, label area
covered with a hand-stenciled red curved word that reads
"KAMARADA" instead of the brand (the joke is that the West cannot
even spell the Soviet word right). Tiny red bubbles escaping from
the open top forming a propulsion plume. Two simple cartoon eyes
on the upper third of the bottle.
```

### 15.5 Cañón burocrático del cadete (`invasors_canon.png`, 240×140)

Sprite estático en la base de la pantalla.

```
[Línea base] Hand-drawn ink, two-color.

Front view of a small bureaucratic cannon. A trembling ink outlined
box-shape on two heavy wheels, with a thick vertical barrel
sticking up from the center. The barrel ends in a flared mouth
stamped with a red "F-447" mark. On the side of the cannon body:
a hand-stenciled "OFK" red plate. A small Soviet flag stuck on
top of the barrel (rectangular flag with hammer-and-quill, three
strokes max). The cadet's helmet just peeks above the cannon
behind the barrel.
```

### 15.6 Bunker defensivo F-447 (`invasors_bunker_f447.png`, 200×140)

Hay 3-4 de éstos protegiendo el cañón. Se degradan por impactos
(idealmente entregar 3 versiones: intacto / dañado / casi
destruido). Si se entrega sólo uno, runtime aplica máscara para
los daños.

```
[Línea base] Hand-drawn ink, two-color.

Front view of a bureaucratic paper-stack bunker. A dome-shaped
stack of folded paper labeled "F-447" in red hand-stenciled
letters on each visible layer. Heavy black ink outline, double-
pass trembling. The dome has three small viewing slits at the
front. On top: a tiny red flag with hammer-and-quill. Sturdy and
absurd, in the spirit of "paperwork as armor".

[Variantes opcionales]:
- `invasors_bunker_f447_dano1.png`: con dos grietas en zig-zag y
  papeles arrugados saliendo por arriba.
- `invasors_bunker_f447_dano2.png`: media estructura derrumbada,
  papeles sueltos volando, slogan "F-447" parcialmente borrado.
```

### 15.7 Proyectil del cadete (`invasors_proyectil_rojo.png`, 60×100) y 15.8 Proyectil yanki (`invasors_proyectil_dollar.png`, 60×100)

```
[Línea base] Hand-drawn ink, two-color.

15.7 — A vertical red ink stamp imprint moving upward. Rectangle
shape with the hand-stenciled red word "VISADO" rotated 90°.
Short red motion lines trailing downward.

15.8 — A vertical green-substituted-by-red dollar sign "$" moving
downward. Bold hand-drawn "$" symbol filled with red ink, two
short red motion lines trailing upward, slight wobble suggesting
careless capitalism.
```

### Cableado pendiente

Mismo patrón que pinball y Doom: cargar los 7+ PNGs en `initState`
con try/catch (`Future.wait`), pasar al painter como `ui.Image?`,
y en `_PintorMundoInvasors` (línea 703) sustituir cada `_dibujar*`
procedural por `drawImageRect` cuando exista, fallback a la
geometría actual cuando no. Para los invasores, la animación de
patas oscilantes (campo `_animacionPatasInvasores`) puede
eliminarse o aplicarse como sutil `Transform.translate` vertical
del sprite estático.

---

## 16. Inspektor Pac-Man · laberinto burocrático (prioridad media)

> **Estilo**: garabato West of Loathing aplicado a Pac-Man. Vista
> cenital, paleta paper+ink+red. El Inspektor recorre los pasillos
> del Comité comiendo expedientes mientras cuatro Komisarios le
> persiguen. Paleta limita los "colores" de los fantasmas —
> distinguidos por SILUETA (sombrero, bigote, lentes, gorra),
> no por color.

`pantalla_inspektor_pacman.dart` (1428 líneas, painter 470).
Estos 5 PNGs sustituyen los elementos de mayor visibilidad.

### 16.1 Inspektor (jugador) (`pacman_inspektor.png`, 200×200)

```
[Línea base] Hand-drawn ink doodle, two-color (black + red).

Top-down view of the Inspektor as a circular head with a wide
hand-drawn mouth wedge open to the right (Pac-Man style). The
head wears a Soviet visor cap with a red star on the front, a
thin trembling-ink mustache below the mouth wedge, and a single
red monocle over one eye. The mouth wedge is an empty triangular
cut-out (transparent), so at runtime the engine can rotate the
sprite to point in the direction of movement. Thick double-pass
black ink outline. No body — just the head.
```

### 16.2 Cuatro Komisarios — fantasmas burocráticos

> Cada uno comparte la silueta base (cuerpo redondeado con borde
> festoneado, dos ojos), pero se distingue por **un accesorio
> único** en lugar de por color (la paleta es estricta).

**Archivos**: `pacman_komisario_gorro.png`, `_monoculo.png`,
`_bigote.png`, `_pipa.png` (180×220 c/u).

```
[Línea base] Hand-drawn ink doodle, two-color (black + red).

A "ghost" silhouette in the Soviet bureaucracy style — rounded
top, vertical body with a wavy festooned bottom (3-4 humps),
two simple ink-dot eyes. The body is hand-drawn paper-cream
(transparent inside the outline, just the outline visible).

Each of the four variants adds ONE distinctive accessory at the
top of the head, in red ink:
- `_gorro.png`: a small red Soviet officer cap with star above
  the silhouette.
- `_monoculo.png`: a red monocle on one eye + tiny red ribbon
  hanging down.
- `_bigote.png`: a wide red handlebar mustache below the eyes.
- `_pipa.png`: a small red smoking pipe sticking out from the
  side, with three trembling smoke curls rising above.

All four PNGs share the EXACT same body silhouette so they swap
identities cleanly at runtime.
```

### 16.3 Expediente (pellet pequeño) (`pacman_expediente.png`, 80×80)

```
[Línea base] Hand-drawn ink doodle, two-color.

A tiny folded form-F-447 stamp, top-down view. A small rectangle
(approx 60% of the canvas) tilted -8°, with a hand-stenciled red
"F" letter in the center and four small black ink corners.
Transparent background. Should read as a "pickup" element even
when scaled down to 16×16 on screen.
```

### 16.4 Tinta power-up (pellet grande) (`pacman_tinta_power.png`, 140×140)

```
[Línea base] Hand-drawn ink doodle, two-color.

A small open inkwell seen from top with a splash of red ink
spilling out of the rim. Black ink outline of a round bottle
mouth, thick red splash shape (irregular, 4-5 lobes) covering
70% of the canvas. Three tiny red drops floating around the
splash. Pulses at runtime to attract attention — keep silhouette
strong.
```

### 16.5 Fondo laberinto (`pacman_fondo_laberinto.png`, 880×1100)

Reemplaza la cuadrícula procedural del laberinto entero.

```
[Línea base] Hand-drawn ink doodle on aged cream paper.

A full top-down view of a bureaucratic maze — a single PNG that
maps 1:1 to the game's grid (22 cols × 27.5 rows scaled). Walls
drawn as thick double-pass trembling black ink corridors with
the cream paper showing through as walkable space. Decorations
inside the walls: tiny hand-stenciled red "OFK" stamps repeated
every 4-5 cells, occasional small red star at corners. The
central "ghost house" is a clearly framed rectangle with a red
banner reading "ADMINISTRACIÓN" above its entrance. No pellets
drawn — those are runtime sprites.
```

---

## 17. Pixel Perdido · plataformas 8-bit (prioridad media)

> **Estilo**: garabato minimalista pero **a propósito pixelado** —
> el minijuego homenajea a los plataformas 8-bit. Paleta estricta
> paper+ink+red. Cada elemento debe leerse como "garabato pixel-
> art": misma estética que el resto del juego pero con bordes
> recortados a 90° en lugar de curvas trémulas.

`pantalla_pixel_perdido.dart` (934 líneas, painter 368). El mapa
ASCII (`#`, `.`, `*`, `X`, `F`) define qué dibujar; cada tile
necesita su sprite.

### 17.1 Cadete pixel (`pixel_cadete_idle.png`, 64×96 — pixel art)

```
[Línea base] 64×96 pixel-art style sprite, two-color (black ink +
red) on transparent background. NO antialiasing — every pixel is
crisp.

A tiny cosmonaut cadet in idle pose, front view. Round helmet
(half the height of the sprite) with red star on the front,
square body with red star pin on chest, two stick legs, two
stick arms hanging. Outline drawn pixel-by-pixel as black 2-pixel-
thick strokes. No anti-aliased curves; everything orthogonal.
The sprite must remain recognizable when scaled up 4x at runtime.
```

### 17.2 Kopek (estrella recogible) (`pixel_kopek.png`, 48×48)

```
[Línea base] 48×48 pixel-art star, two-color.

A 5-point red star drawn pixel-by-pixel, filled red with a 2-pixel
black outline. Centered in the canvas. Slight pulse animation
can be applied at runtime via Transform.scale — the asset itself
is static. Transparent background. Should glow even at 12×12 on
screen.
```

### 17.3 Charco de tinta (obstáculo) (`pixel_charco_tinta.png`, 96×48)

```
[Línea base] 48-tall pixel-art ink puddle, two-color.

A horizontal puddle of black ink with red highlights, ~96 wide
and 48 tall. Irregular blob silhouette drawn with stepped pixel
edges (NOT smooth curves). The inside of the puddle has 3-4
small red drips falling into it (animated at runtime via offset).
The character dies on contact with this — the silhouette must
read as DANGEROUS at a glance.
```

### 17.4 Bloque sólido (tile) (`pixel_bloque_tile.png`, 64×64)

```
[Línea base] 64×64 tileable pixel-art block, two-color.

A square brick tile that tiles seamlessly with itself in both
directions. The brick is paper-cream colored with a 4-pixel
black ink border around the edges, and inside: a hand-stenciled
red "K" letter in the center, slightly tilted (-6°) so the
pattern looks hand-stamped. The right edge must match the left
edge exactly for clean horizontal tiling. Same for top/bottom.
```

### 17.5 Bandera meta (`pixel_bandera_meta.png`, 64×128)

```
[Línea base] 64×128 pixel-art finish flag, two-color.

A vertical pole on the left side of the canvas (4 pixels wide,
black) with a red rectangular flag waving out to the right. The
flag has a small hand-stenciled black hammer-and-quill mark in
the center. Above the pole: a tiny red star. The flag must be
clearly the "GOAL" element when seen at the end of a 8-bit level.
```

---

## 18. Frecuencia 747 · radio analógica (prioridad media)

> **Estilo**: garabato minimalista West of Loathing aplicado a una
> radio analógica burocrática vista de frente. Marco de papel
> envejecido, perillas y dial hand-drawn. La aguja del dial es lo
> único que se mueve en runtime — todo lo demás puede ser un
> único PNG estático.

`pantalla_frecuencia_747.dart` (1011 líneas, painter 375). Cinco
PNGs cubren el 100 % del minijuego.

### 18.1 Marco completo de la radio (`radio_marco_completo.png`, 1100×750)

> Una sola pieza para todo el chasis de la radio — más eficiente
> que componer perillas individuales.

```
[Línea base] Hand-drawn ink doodle on aged cream paper.

A frontal view of a Soviet analog radio receiver, full chassis.
Wide rectangular frame with rounded corners, double-pass trembling
black ink outline. Layout:
- Top center: a large rectangular dial window (~70% width, ~25%
  height) showing horizontal frequency tick marks every 5 mm
  with red labels "3", "5", "7", "9", "11" and small red marks
  at the secret stations (3.47, 4.21, 5.62, 6.84, 7.47, 9.13,
  11.05) — leave a horizontal slot in the middle empty for the
  runtime needle to slide.
- Below the dial, left: a circular VU meter window (radial scale
  in red, label "SEÑAL").
- Below the dial, right: a circular tuning knob (hand-drawn dial
  with knurling marks), and a smaller volume knob next to it.
- Bottom: a horizontal speaker grille — small black ink dots in a
  6×30 grid.
- Top-left: a hand-stenciled red "ПРАВДА-7" plate.
- Top-right: a red ON/OFF switch with two states.

Leave the needle position and VU meter pointer position EMPTY in
the PNG — those are painted at runtime. The PNG provides the
chassis and all the static decoration.
```

### 18.2 Aguja del dial (`radio_aguja_dial.png`, 40×140)

```
[Línea base] Hand-drawn ink, two-color.

A vertical thin needle pointer, drawn as a tapered black ink
triangle with a red tip and a red round base. The needle is
slightly trembling (hand-drawn double-pass). 40 wide and 140
tall — anchored at the bottom (the base) so Flutter can rotate
or translate it across the dial slot.
```

### 18.3 Indicador VU señal (`radio_aguja_vu.png`, 100×100)

```
[Línea base] Hand-drawn ink, two-color.

A thin radial needle for the VU meter, anchored at one end. A
straight black ink stroke 90 pixels long with a tiny red drop at
the free tip. Anchored at one short edge of the canvas so
Flutter can rotate it around that pivot to indicate signal
strength.
```

### 18.4 Pulso de sintonía correcta (`radio_pulso_sintonizado.png`, 240×240)

> Asset opcional pero muy útil — overlay que pulsa cuando el
> cadete encuentra una estación secreta.

```
[Línea base] Hand-drawn ink, two-color.

A concentric ring of dashed red ink emanating outward — three
rings at radii 60, 90, 120 px (centered in the canvas). Each
ring is drawn as 16 short red dashes around the circumference.
The PNG is a single static frame; runtime pulses it with
Transform.scale + Opacity to fake animation. Transparent center.
```

### 18.5 Texto secreto recibido (`radio_panel_mensaje.png`, 600×220)

> Aparece cuando se descubre una estación: un panelito superpuesto
> con el mensaje. El texto en sí lo pinta Flutter — este PNG es
> el marco.

```
[Línea base] Hand-drawn ink doodle on aged cream paper.

A horizontal rectangular paper panel that hangs over the radio,
suggesting a recently-received telegram. Hand-drawn trembling
black ink frame, double-pass. Top-left corner: a single red
official seal stamped with hand-stenciled "RECIBIDO". Top-right:
a small red rotating telegraph icon. Inside: leave a large empty
rectangular area where Flutter will paint the text content. The
bottom edge has 5-6 short dashed ink lines suggesting "to be
continued..." for serial transmissions.
```

### Cableado pendiente

Igual que en los demás: añadir `ui.Image?` por sprite, cargar en
`initState` con try/catch + `Future.wait`, pasar al painter y
sustituir el dibujo procedural por `drawImageRect` con fallback.

En `_PintorDialRadio` (línea 637 de `pantalla_frecuencia_747.dart`)
la lógica del chasis completo puede colapsarse a una sola línea
si llega el `radio_marco_completo.png`. La aguja del dial y la
del VU meter siguen siendo runtime (rotación / translación
geométricas).

---

## 19. Dokumentris · tetris burocrático (prioridad baja)

> **Estilo**: garabato West of Loathing aplicado a Tetris. Las 7
> piezas canónicas (I, O, T, S, Z, J, L) son formularios F-447 con
> sello rojo en cada celda. La paleta limitada obliga a
> diferenciarlas por **sello / motivo / ralladura**, no por color.

`pantalla_dokumentris.dart` (1292 líneas, painter 366). Sólo 7
sprites son necesarios — uno por tipo de tetromino — más el marco
del escritorio.

### 19.1 Set de 7 celdas-sello (`dokumentris_celda_<id>.png`, 80×80 c/u)

Cada celda es una pieza de un tetromino. La pieza completa se
ensambla en runtime colocando varias celdas adyacentes en el
grid. Esto significa que con 7 PNGs cubrimos las 7 piezas
canónicas (Flutter las apila).

```
[Línea base] Hand-drawn ink doodle, paper+ink+red palette.

Set of 7 square stamp tiles (80×80 each, transparent background),
one per tetromino type. All seven share:
- A trembling double-pass black ink border around the square.
- A faint paper-cream fill so they stack without merging visually.
- A small red hand-stenciled label in the center, 2-letter code.

Each variant has its OWN label + hatching pattern:
- `dokumentris_celda_i.png`: label "F-1", four vertical red lines
  inside (matching the I-piece's vertical orientation).
- `dokumentris_celda_o.png`: label "F-2", a single red square
  inside (the 2×2 block).
- `dokumentris_celda_t.png`: label "F-3", a red T-shape inside.
- `dokumentris_celda_s.png`: label "F-4", two diagonal red lines
  rising right.
- `dokumentris_celda_z.png`: label "F-5", two diagonal red lines
  rising left.
- `dokumentris_celda_j.png`: label "F-6", a red L-shape mirrored.
- `dokumentris_celda_l.png`: label "F-7", a red L-shape.

The visual differences must be readable at small grid scale
(20×20 px). At runtime, multiple cells of the same type adjoin
to form the full tetromino.
```

### 19.2 Marco del escritorio (`dokumentris_escritorio.png`, 1000×1400)

Reemplaza la geometría de la zona de juego — escritorio
burocrático con cuadrícula recortada para que el tetris caiga
dentro.

```
[Línea base] Hand-drawn ink doodle on aged cream paper.

A frontal view of a bureaucratic office desk seen as the
playfield for Tetris. The center of the canvas (approx 60% wide
× 85% tall) is a transparent rectangular slot — that's where the
tetris grid is rendered at runtime. Around the slot:
- Top: a hand-stenciled red "BANDEJA DE ENTRADA" sign.
- Left edge: a vertical stack of incoming-form folders, hand-
  drawn trembling rectangles.
- Right edge: a vertical scoreboard with hand-lettered labels
  "LÍNEAS / NIVEL / PUNTOS" leaving the numeric area empty for
  runtime text.
- Bottom: a hand-drawn metal desk edge with a single red
  bureaucratic pen lying flat.

The wood-grain of the desk is suggested with 3-4 horizontal
trembling ink lines, NO fills (paper cream shows through).
Trembling double-pass ink frame around the whole canvas.
```

### Cableado pendiente

Cargar las 7 celdas en `initState` como un `Map<int, ui.Image?>`
indexado por tipo de pieza. En `_PintorTableroDokumentris` y
`_PintorPiezaPreview`, en lugar de pintar el `Rect` del bloque
con `drawRect`, hacer `drawImageRect(imagenes[tipo]!, Rect.fromLTWH(...))`
si la imagen está disponible.

---

## 20. Transformaciones del cadete (prioridad baja)

> **Estilo**: garabato West of Loathing. Estos sprites son las
> SEIS metamorfosis del cadete entre minijuegos (cadete normal,
> bola-pinball, pieza-tetris, comecocos, aguja-radio, bola-nieve).
> Algunos ya tienen asset (cadete normal con clases, bola-pinball)
> o están cableados a otros sprites — esta sección sólo cubre los
> dos pendientes.

`pantalla_transformacion.dart` (501 líneas, painter 396). El
painter dibuja procedimentalmente la forma destino en su pose
canónica para que el jugador vea en qué se va a convertir.

### 20.1 Cadete como pieza-tetris (`transform_cadete_pieza_tetris.png`, 240×360)

```
[Línea base] Hand-drawn ink doodle, paper+ink+red palette.

The cadet curled into a T-tetromino shape, front view. Black
ink outlined silhouette of the T-tetromino, paper-cream fill,
with a tiny cadet face (helmet with red star, two eye dots,
small horizontal mouth) drawn inside the central cell of the T.
Three trembling red "F-447" stamps on the other three cells.
The whole shape sits anchored at its bottom-center so the
transition animation can rotate it as a single block.
```

### 20.2 Cadete como aguja de radio (`transform_cadete_aguja_radio.png`, 80×280)

```
[Línea base] Hand-drawn ink doodle, paper+ink+red palette.

The cadet stretched into a long vertical radio needle. Thick
black ink tapered triangle pointing UP, with a tiny cadet face
embedded in the upper tip (just the helmet+star recognizable),
and a thick red round base at the bottom (the pivot). Two tiny
arms drawn as ink stubs near the top, half-absorbed into the
needle silhouette. Anchored at the bottom of the canvas.
```

### Otros estados ya cableados

| Forma | Asset existente |
|---|---|
| `cadete` | Sprite de clase (`cadete_<clase>_idle.png`) |
| `bolaPinball` | `cadete_bola_f01..f04.png` |
| `piezaTetris` | **§20.1 pendiente** |
| `comecocos` | Se puede reutilizar `pacman_inspektor.png` (§16.1) |
| `agujaRadio` | **§20.2 pendiente** |
| `bolaNieve` | Se puede reutilizar `snow_bola_papel.png` (§14.4) |

### Cableado pendiente

En `_PintorTransformacion.paint` (línea 256), donde el `switch
(formaDestino)` despacha al dibujo procedural, sustituir cada
caso por `drawImageRect` apuntando al PNG correspondiente cuando
la imagen esté cargada, con fallback procedural. Reutiliza los
sprites de §16.1 y §14.4 para `comecocos` y `bolaNieve` para
mantener consistencia visual entre transición y minijuego.

---

## 21. Super Pang Galáctico · globos burocráticos (prioridad baja)

> **Estilo**: garabato West of Loathing aplicado al clásico
> Pang/Super Pang. El cadete dispara verticalmente contra globos
> que se subdividen al impactar. Aquí los globos son **expedientes
> inflados** con sello F-447.

`pantalla_super_pang.dart` (846 líneas, painter 196). El painter
es relativamente pequeño — sólo 4-5 sprites son necesarios.

### 21.1 Globo F-447 — 3 tamaños (`pang_globo_grande.png` 280×280, `pang_globo_medio.png` 200×200, `pang_globo_pequeno.png` 120×120)

```
[Línea base] Hand-drawn ink doodle, paper+ink+red palette.

A circular hand-drawn bureaucratic balloon. Trembling double-pass
black ink outline forming a slightly irregular sphere (not a
perfect circle), with paper-cream fill. Inside: a hand-stenciled
red "F-447" stamp at the center, slightly tilted -8°. A small
red knot at the bottom of the balloon with a short trembling
ink string hanging down 20-30 px. Three sizes (grande / medio /
pequeño) share the SAME composition — just different scales — so
that splitting at runtime gives visual continuity.
```

### 21.2 Arpón vertical del cadete (`pang_arpon.png`, 40×500)

```
[Línea base] Hand-drawn ink doodle, paper+ink+red palette.

A vertical hand-drawn harpoon spear shooting upward. A thick
trembling black ink line ~480 px tall, with a small red barbed
tip at the top (three short red ink strokes forming an arrow
head) and a wider red gripped handle at the bottom (a small
rectangle filled red, 20×40). The shaft has 3-4 tiny red hand-
stenciled "OFK" marks at irregular intervals. Anchored at the
bottom of the canvas; runtime scales the height to grow as it
extends.
```

### 21.3 Banner de nivel (`pang_banner_nivel.png`, 700×200)

Aparece al iniciar cada nivel ("NIVEL X · GLOBOS F-447").

```
[Línea base] Hand-drawn ink doodle on aged cream paper.

A horizontal red banner with a hand-stenciled hammer-and-quill in
each corner, trembling black ink outline. The center of the
banner is a clean rectangular area where Flutter paints the level
text at runtime (do NOT include text in the PNG — only the frame
and decorations). Three small red star marks along the bottom
edge as separator decoration.
```

### Cableado pendiente

En `_PintorSuperPang.paint`, donde se dibuja cada globo con
`canvas.drawCircle`, sustituir por `drawImageRect` consultando el
PNG según el tamaño (grande/medio/pequeño). El arpón sigue siendo
un único sprite escalado en altura por runtime. El banner es
overlay aparte (no parte del painter).

---

## Resumen del briefing completo

Tras los seis sprints de documentación, el briefing incluye los
prompts para **~70 sprites** distribuidos en 19 secciones:

| § | Área | Estado |
|---|---|---|
| 1-9 | Key art, NPCs, muebles, iconos, transiciones, painters por escenario, cinemáticas, cómo se hace el reemplazo | Catalogado |
| 10 | Sets multi-frame del cadete y NPCs | Mayoritariamente entregado |
| **11** | **Pinball del Comité (15 sprites)** | **Cableado en código ✓** |
| 12 | Hotspots invisibles cápsula (9) | Documentado |
| 13 | Cosmoom Doom (5) | Documentado |
| 14 | Snow Kamarada (5) | Documentado |
| 15 | Camarada Invasors (8) | Documentado |
| 16 | Inspektor Pac-Man (8) | Documentado |
| 17 | Pixel Perdido (5) | Documentado |
| 18 | Frecuencia 747 (5) | Documentado |
| 19 | Dokumentris (8) | Documentado |
| 20 | Transformaciones del cadete (2 nuevos + 4 reusables) | Documentado |
| 21 | Super Pang Galáctico (5) | Documentado |

Todos los PNGs documentados respetan: paleta paper+ink+red
estricta, trazo trembling double-pass, silueta clara, dimensiones
exactas, transparencia donde corresponde, anclajes para rotación/
escalado runtime y cableado mediante el patrón
`rootBundle.load → ui.Image? → drawImageRect con fallback
procedural` ya implementado en pinball y verificado en producción.
