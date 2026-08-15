# Guía COMÚN de sprites — para TODOS los personajes

Todos los personajes del juego comparten el MISMO moveset (las mismas hojas,
los mismos conteos de frames y los mismos timings). Lo ÚNICO que cambia entre
personajes es el **aspecto** y el **arma** (la animación se ve distinta, pero
mecánicamente el golpe es el mismo). El ULTRA también es igual para todos.

**Para crear un personaje nuevo:**

1. Escribe su **BLOQUE DE IDENTIDAD** (abajo hay una plantilla).
2. Genera las mismas hojas del **ROSTER** (abajo), pegando ese bloque en cada prompt.
3. Guárdalas en `imagen-action/<personaje>/sheets/` y me dices — yo las proceso
   y conecto igual que DAM. Los efectos y sonidos ya están hechos y se comparten.

La guía específica de cada personaje (identidad + descripción detallada de cada
movimiento con su arma) va en su propio archivo, ej. `GUIA-SPRITES.md` es la de DAM.

---

## Reglas de producción (van en TODOS los prompts)

Pega esto al final de cada prompt, junto con la **imagen de referencia del
personaje** adjunta:

> Vista lateral de juego de pelea 2D (estilo KOF), personaje mirando a la
> DERECHA en TODOS los frames — nunca de frente a la cámara, nunca de espaldas,
> nunca volteado al otro lado. Mismo personaje exacto de la referencia, misma
> paleta de colores exacta y mismo estilo de línea.
> ANATOMÍA correcta: exactamente DOS brazos, DOS piernas, DOS manos con 5 dedos,
> UNA sola arma. NADA de manos, dedos, brazos, piernas ni armas de más.
> Los frames van en UNA o DOS filas, ordenados de izquierda a derecha (la fila
> de ARRIBA primero). Todos los frames a la MISMA escala; dentro de cada fila
> los pies en la MISMA línea. Si hay dos filas, deja una franja horizontal VACÍA
> entre ellas: nada de la fila de arriba toca la de abajo. Personaje completo en
> cada frame con margen (nada cortado por el borde). Deja espacio VACÍO claro
> entre personaje y personaje: las armas de frames vecinos NUNCA se tocan ni
> traslapan (ojo con las armas EXTENDIDAS al frente: mínimo medio cuerpo de
> espacio libre entre la punta y el siguiente personaje).
> El arma es UNA sola pieza continua sujeta en las manos: nunca fragmentada,
> duplicada, ni tirada en el piso. Cada frame es UN solo personaje completo —
> jamás dos poses pegadas dentro del mismo frame. La ropa mantiene su forma
> normal y limpia (NO rasgada ni hecha jirones).
> Fondo VERDE PURO #00FF00 completamente plano y SIN NINGUNA marca: no pongas
> números, letras, rótulos ni líneas guía — solo el personaje sobre el verde.
> Sin sombra en el piso. Sin desenfoque ni líneas de velocidad.

**Nitidez:** menos frames por FILA = más grande y nítido cada personaje. Para
animaciones largas usa DOS FILAS en la misma hoja (mi procesador las lee solas),
o divide en dos hojas — también las une.

**Conteo PAR de frames (dividen limpio en dos filas/hojas iguales):** preferí
SIEMPRE un total PAR de frames — 8 = 4+4, 10 = 5+5, 6 = 3+3, 4 = 2+2. Podés
ponerlos todos en UNA hoja de dos filas, o en DOS hojas separadas (yo las uno).
Si un movimiento hoy tiene conteo IMPAR, el frame que sobra para volverlo par es
el lugar IDEAL para meter el keyframe que falta (un OVERSHOOT o el SMEAR de contacto).

**Frames rebeldes:** si un frame sale mal una y otra vez, pídelo SOLO en su
propia hoja de UN personaje con descripción hiperdetallada. Nómbrala
`<accion>-f<numero>-sheet.png`; yo lo empalmo con los buenos (escalo por masa
corporal para que encaje).

---

## Capa de PROPORCIONES — misma estatura y cabeza SIEMPRE (va en TODO prompt)

Esto evita que el personaje "wobblee" de tamaño entre frames y entre movimientos.
Mi procesador ya iguala la ESTATURA midiendo la CABEZA; si la IA además dibuja
proporciones consistentes, el resultado queda clavado.

> **La CABEZA es la unidad y es INVARIANTE a la pose.** Mide LO MISMO en TODOS los
> frames — parado, agachado, saltando, atacando. Si el personaje se agacha, la
> cabeza NO se achica ni se agranda: solo se ACERCA al piso. Nunca cabeza "chibi"
> en un frame y realista en otro.
> **Estatura fija en cabezas:** el personaje mide **[N] cabezas** de alto en TODOS
> los frames de pie. Puntos de referencia (unidades de cabeza desde la coronilla):
> hombros ≈1.3, cintura/codo ≈3, cadera ≈3.5, rodilla ≈5, pies = [N]. El brazo
> relajado llega a mitad del muslo. Mantén estos largos entre frames.
> **Masa y línea constantes:** el MISMO grosor de cuerpo (torso, brazos, piernas),
> el MISMO grosor de línea y la MISMA paleta exacta en todos los frames — nada de
> un frame más "flaco" o "gordo" que otro.
> **El arma no cambia de tamaño:** la katana / las agujas miden LO MISMO (largo y
> grosor) en todos los frames (salvo el leve estirón del frame de contacto).
> **Pies en la misma línea** dentro de cada fila (piso común).

**Lo que MÁS ayuda con GPT-4o (no tiene `--cref` para clavar el personaje):**

- **EDITA, no regeneres:** cuando puedas, parte de un frame BUENO ya hecho y pide
  _"mantén IDÉNTICO el personaje (misma cabeza, misma estatura, mismos colores,
  misma línea), cambia SOLO la pose a X"_. Mucho más consistente que generar de cero.
- **Adjunta SIEMPRE** la referencia / model-sheet del personaje.
- **Medidas > adjetivos:** "6.5 cabezas de alto, hombros a 1.3" obedece mejor que
  "alto y esbelto".
- **Model sheet con grilla:** ten UNA imagen del personaje con la grilla de cabezas
  encima y adjúntala — es la regla que la IA copia. (Rangos típicos: adulto
  esbelto ≈6.5–7 cabezas · joven/adolescente ≈5.5–6 · niño ≈4–5.)

---

## Capa de KEYFRAME — poses PRO (pégala en TODO prompt de ATAQUE)

Va **además** de las reglas de producción. Convierte frames "neutros" en poses
clave de animación profesional. Referencia mental: un **bateo de béisbol pro**
(carga coiled → SMEAR del swing → estirón de follow-through → overshoot → asentar).

> **Piensa cada frame como una POSE CLAVE, no un dibujo neutro:**
>
> - **SILUETA:** cada pose de ataque con silueta CLARAMENTE distinta de la
>   guardia y de las demás. Test: tápalo en negro y aún se reconoce qué hace.
>   Mete TODO el cuerpo (hombros, cadera, piernas), nunca solo el brazo.
> - **CARGA COMPRIMIDA:** el frame de anticipación va encogido/coiled, como
>   resorte cargado (torso torcido, peso atrás).
> - **IMPACTO ESTIRADO:** el frame de contacto va estirado al máximo en la
>   dirección del golpe, más allá de lo natural (squash & stretch). Cuerpo
>   volcado, cara de esfuerzo. Es el frame que se SOSTIENE.
> - **OVERSHOOT:** tras el impacto el cuerpo se pasa de largo y queda
>   DESBALANCEADO/sobre-extendido; recién el ÚLTIMO frame recupera la guardia.
> - **ACCIÓN SECUNDARIA:** la ropa y el pelo SIEMPRE trazan el movimiento — la
>   capa de DAM / la gabardina de Favi / la coleta vuelan y ondean en CADA frame,
>   nunca quietas. Es lo que da vida (mira cualquier referencia pro).
> - **Golpe fuerte = carga fuerte:** a más daño, anticipación más grande.
>
> **ESTELA / ARCO de corte = LO PONE EL MOTOR, NO la AI.** GPT-4o no dibuja bien el
> arco deformado (deforma el arma, corta brazos), así que el SPRITE lleva el arma
> SIEMPRE NÍTIDA (misma forma y tamaño en todos los frames) y el JUEGO agrega el
> arco/estela de corte por código (`_draw_swing_trail`), sincronizado al swing y
> fluido. Tú solo dibujas el MOVIMIENTO sólido del cuerpo (windup → swing →
> follow-through); nada de deformar el arma ni dibujar líneas de velocidad.

**Más keyframes, pero los correctos:** no es "más inbetweens tibios". Es agregar
las 2 poses que casi siempre faltan — un **frame de SMEAR de contacto** y un
**frame de OVERSHOOT** — que son las que dan velocidad y peso.

**Glosario para hablarle a la IA:** _pose clave/extremo_ = las poses que cuentan
el golpe (carga, impacto, remate) · _silueta_ = test del contorno en negro ·
_squash/stretch_ = aplastar en carga, estirar en impacto · _smear_ = frame de
estela sólida del arma en el golpe rápido · _overshoot_ = pasarse de la pose
antes de asentar.

---

## Bloque de IDENTIDAD (esto es lo único que cambia por personaje)

Plantilla — llénala para cada personaje nuevo y úsala como primer párrafo de
CADA prompt (más la imagen de referencia):

> Mismo personaje exacto de la referencia: [ROPA — prendas, capucha, etc.],
> [COLORES/PALETA], [PELO], [OJOS], [DETALLES: guantes, accesorios]. Su arma es
> [ARMA — descripción, material, color, brillo]. [Prohibiciones del arma si
>
> > aplica: sin fuego, sin partículas, etc.].

Ejemplo (DAM): abrigo rojo con capucha, ropa negra, tenis negros con detalles
rojos, guantes sin dedos, pelo negro despeinado, ojos rojos; arma = katana de
metal INCANDESCENTE al rojo vivo (sin llamas ni brasas).

---

## ROSTER de movimientos (igual para TODOS los personajes)

Cada personaje genera ESTAS hojas. El conteo de frames y el ritmo son fijos;
solo cambia cómo se ve el golpe con su arma. La descripción detallada de la
animación de cada uno va en la guía específica del personaje.

### Básicas

| Hoja           | Frames   | Filas | Función en el juego             |
| -------------- | -------- | ----- | ------------------------------- |
| `pose-sheet`   | 4 (loop) | 1     | Guardia idle, respiración sutil |
| `walk-sheet`   | 8        | 2×4   | Ciclo de caminata de combate    |
| `crouch-sheet` | 3        | 1     | Se agacha progresivamente       |
| `jump-sheet`   | 3-4      | 1     | Salto (subida/ápice/caída)      |

### Golpes de pie

| Hoja               | Frames          | Botón | Función                              |
| ------------------ | --------------- | ----- | ------------------------------------ |
| `weak-punch-sheet` | 4               | R     | Golpe suave rápido (jab, dmg 4)      |
| `punch-sheet`      | 10              | Q     | Golpe horizontal (dmg 8; →Q = doble) |
| `kick-sheet`       | 10 (usa fila 1) | W     | Golpe pesado (dmg 12)                |
| `spin-kick-sheet`  | 8               | E     | Giratoria que viaja y lanza (dmg 13) |

### Golpes agachados

| Hoja                 | Frames | Botón | Función                                   |
| -------------------- | ------ | ----- | ----------------------------------------- |
| `crouch-jab-sheet`   | 4      | ↓R    | Pinchazo bajo rápido (bajo, dmg 4)        |
| `crouch-punch-sheet` | 3      | ↓Q    | Golpe agachado (bajo, dmg 6)              |
| `crouch-kick-sheet`  | 5      | ↓W    | GANCHO lanzador que manda al aire (dmg 9) |
| `sweep-sheet`        | 6      | ↓E    | Barrido que derriba (bajo, dmg 12)        |

### Aéreos

| Hoja                  | Frames | Botón   | Función                           |
| --------------------- | ------ | ------- | --------------------------------- |
| `jump-punch-sheet`    | —      | salto+Q | Golpe aéreo (dmg 9)               |
| `jump-kick-sheet`     | —      | salto+W | Patada en picada (dmg 10)         |
| `air-spin-kick-sheet` | 8      | salto+E | Mortal con patada, lanza (dmg 13) |

### Reacciones y especiales

| Hoja                              | Frames   | Función                                   |
| --------------------------------- | -------- | ----------------------------------------- |
| `take-hit-sheet`                  | —        | Recibe golpe de pie                       |
| `take-hit-low-sheet`              | —        | Recibe golpe agachado                     |
| `pummeled-sheet`                  | 4 (loop) | Machacado de pie durante el ULTRA         |
| `wall-bounce-sheet`               | 4        | Vuelo recto noqueado + estrellón en pared |
| `block-sheet` / `block-low-sheet` | —        | Bloqueo alto / bajo                       |
| `ko-sheet`                        | —        | Noqueado, tendido                         |
| `victory-sheet`                   | —        | Celebración de victoria                   |

**Comandos compartidos** (mismos para todos): →R = jab, →Q = doble golpe,
↓↘→+Q = EMBER DASH (embestida a la pared), ↑+E = COMBO BREAKER,
→R = ANIQUILACIÓN (16 hits), →E = APOCALIPSIS (31 hits). El ULTRA es idéntico.

---

## Efectos compartidos (YA hechos — sirven para TODOS los personajes)

Estos NO dependen del personaje (son humo, chispas, etc.), así que se hacen UNA
sola vez y todos los usan. Ya están en el juego:

- `jump-dust` (6f) — anillo de polvo al saltar/aterrizar
- `dash-dust` (6f) — ráfaga de humo al hacer dash / golpes fuertes
- `chispas-impat-hit` (7f) — chispas de impacto al golpear
- `fx-block` — escudo azul de bloqueo (o el de código)
- `wall-debris` (8f) — escombros al chocar contra la pared
- Estelas de corte, sombras del dash, squash de impacto — todo por código

Si un personaje nuevo quiere un efecto propio (ej. otro color de chispa), se
genera aparte; si no, reutiliza estos tal cual.

---

## EPIC hit-spark (2XKO style) — prompt for the AI

The big dramatic FLASH that pops when a hit connects. Animated as VIDEO over green
(NOT a frame sheet).

**Rules:** pure GREEN background #00FF00 (flat, static); **NO character, no scenery,
no bars, no text**; effect CENTERED on the same point (born and expanding from there,
the center does NOT move); plenty of green margin so the most-expanded moment never
touches the edge; FLAT cel-shaded, high contrast, SHARP hard edges, saturated colors,
NOTHING blurry, no soft diffuse glow.

**KEY CONCEPT (read first):** this is a FLAT 2D GRAPHIC manga/anime hit-spark (like
Guilty Gear / 2XKO), NOT a realistic explosion or a rendered fireball. Think INK and
PAPER: flat shapes of solid color cut with a sharp edge — no volume, no smoke, no 3D
fire. The three must-avoid mistakes:

- ❌ **NOT circular / NOT symmetric:** the silhouette is UNBALANCED and IRREGULAR —
  bigger and spikier on one side, crooked, like a PAINT SPLATTER, never a round
  firework wheel or an oval.
- ❌ **NOT solid / NOT filled:** between the spikes and rays there is AIR (green
  background) VISIBLE — separated tongues and shards with gaps between them, NOT a
  filled continuous mass. You must be able to "see through" it in places.
- ❌ **NO inner shading / NO volume:** colors in 3-4 HARD FLAT layers (white →
  yellow → orange), no soft gradients, no inner shadows, no 3D-sphere look. Flat
  like a sticker.

**What to draw (the 2XKO reference look), in layers:**

1. **ASYMMETRIC shock-star:** a burst of MANY sharp spikes, long and of DIFFERENT
   lengths, shooting out crooked in IRREGULAR directions (some short, some very
   long) — aggressive ZIG-ZAG edges, a lopsided silhouette, with GREEN GAPS between
   the spikes.
2. **Star-shaped incandescent core (not a ball):** the center is a sharp blinding
   WHITE star → a bright YELLOW ring → thin ORANGE tips and edges. All flat color
   layers, zero blur. The center is pointy/irregular, NOT a white circle.
3. **Sumi-e black ink (THE SIGNATURE of the look):** one or two big blobs of solid
   BLACK ink, irregular brush-splatter shapes, placed OFF-CENTER (top and to one
   side, eating into part of the star) — this makes the black "hole" that breaks the
   symmetry. The black gives it weight; without it it looks "cheap." Solid black
   (survives the green key).
4. **Light shards:** several VERY THIN, LONG white-yellow lances shot out diagonally,
   SEPARATED from the star body (isolated, green around them), at different lengths.
5. **Debris:** small black angular chips + specks/dots flying outward, and a few ink
   droplets splattering far.
6. (Optional, extra pop) **thin CYAN electric sparks** near the center.

**Animated as VIDEO** (not frames): the impact BURSTS fast and, to vanish, it COMES
APART BY EXPANDING AND EMPTYING FROM THE CENTER (it does NOT shrink: it opens like a
hollow jagged wave that grows and fades).

**Prompt (paste as-is):**

```
SEPARATE EFFECT CLIP, no character, no person, no scenery — only the effect over a PURE GREEN screen
#00FF00 (flat, static camera). A flat 2D anime/manga HIT-SPARK (Guilty Gear / 2XKO), NOT a realistic
explosion, NOT 3D fire — ink-and-paper flat shapes with sharp cut edges. A big ASYMMETRIC shock-star:
many sharp spikes of DIFFERENT lengths shooting out crooked in irregular directions, aggressive
zig-zag edges, a lopsided off-balance silhouette with GREEN GAPS between the spikes (never a solid
filled mass). Core: a jagged blinding WHITE star → bright YELLOW ring → thin ORANGE tips, in 3-4 hard
flat color layers (no gradients, no inner shading). SIGNATURE: one or two big irregular blobs of solid
BLACK sumi-e INK placed off-center (eating into part of the star), plus small black angular debris and
stray ink droplets flung outward. Animation: it bursts into existence fast, a small blinding white core,
then the spikes shoot out fast to full size, a big chaotic star at the peak with ink and debris at max.
Then it fades away by getting THINNER: the spikes shrink down to fine sharp needles and the whole star
dims and dissolves in place, the debris and ink scatter a little and fade out. It does NOT expand
outward, and it does NOT open a hole or hollow out the middle. The bright center stays solid the whole
time and simply gets thinner and fades. It stays centered. Fast, snappy. No character.
```

**Color variants (same design; the black ink and debris stay black):**
DAM fire (white→YELLOW→orange), Favi water (white→CYAN→blue), Aye floral
(white→PINK→magenta).

When you have it, tell me "**impact-hit is ready**" and I'll process it (green key +
centered) and wire it as everyone's hit-impact effect.

---

## CLEAN 4-POINT STAR hit-flash (blue/white, ref #191) — prompt for the AI

A THIRD kind of impact, more ELEGANT and clean than the chaotic star: a **sharp
FOUR-POINTED star flash** (blinding white with a jagged CYAN/BLUE edge), like the
shine of an energy or crystal hit. Starts compact (exactly like #191), then **EXPANDS
opening a HOLE from the center and comes apart** as it grows. Animated as VIDEO over
green (NOT a frame sheet).

**Rules:** pure GREEN background #00FF00 (flat, static); **NO character, no scenery,
no bars, no text**; effect CENTERED on the same point (born and expanding from there,
the center does not move); plenty of green margin so the most-expanded moment never
touches the edge; FLAT cel-shaded, high contrast, SHARP hard edges, saturated colors,
NOTHING blurry, no soft diffuse glow.

**Prompt (paste as-is):**

```
SEPARATE EFFECT CLIP, no character, no person, no scenery — only the effect over a PURE GREEN screen
#00FF00 (flat, static camera). A 2D anime/manga hit-flash: a sharp FOUR-POINTED STAR BURST shaped
EXACTLY like the reference — a blinding WHITE star core with a jagged CYAN-to-BLUE spiky outline, four
long thin needle-like points shooting diagonally out (up-left, up-right, down-left, down-right) at
slightly different lengths, edges in a crisp electric zig-zag, with a few thin cyan/white electric
sparks near the tips. Flat cel-shaded hard-edged color layers (white core → bright cyan → darker blue
rim), NO soft blur, NO fuzzy glow. Animation: it pops into existence small and blinding, the four
points shoot out fast to full size, a bright sharp four-pointed star at the peak. Then it fades away by
getting THINNER: the four points and the star shrink down to fine sharp needles and the whole thing
dims and dissolves in place. It does NOT expand outward, and it does NOT open a hole or hollow out the
middle. The bright center stays solid the whole time and simply gets thinner and fades. It stays
centered. Fast, snappy impact. No character.
```

**Color variants (SAME design, only the edge tint changes; the core stays white in
all of them):**

- **Generic / Favi (water):** white → CYAN → blue (like reference #191).
- **DAM (fire):** white → yellow → orange.
- **Aye (crystal/floral):** white → lavender → magenta/purple.

When you have it, tell me "**impact-flash is ready**" and I'll process it (green key +
centered anchor) and wire it as an impact effect.

---

## SLASH streak for low hits (2XKO style) — prompt for the AI

A long SLASH (cut trail) that gets THINNER until it disappears. For low hits /
sweeps. Animated as VIDEO over green (NOT a frame sheet).

**Rules:** pure GREEN background #00FF00; **NO character, no scenery, no text**;
CENTERED on the same point (the thickness changes, not the position); plenty of green
margin (the slash is long); FLAT cel-shaded, SHARP edges, NOTHING blurry.

**IMPORTANT — it's a SWORD CUT, NOT fire:** it must read as a clean sharp SLASH that
rips the air, NOT a flame, torch, jet of fire or plasma. NO fire fringes, no flame
tongues, no color explosion at the tips.

**What to draw:**

- **ONE CRESCENT-shaped SLASH:** a CURVED cutting blade (a smooth arc, NOT a straight
  line), thin, running from one tip to the other. THICK/bright ONLY in the middle and
  tapering to **VERY FINE, sharp, CLEAN points** at both ends (like crescent-moon
  horns). Diagonal (lower-left → upper-right). (The engine rotates it randomly.)
- CONTAINED color (little color, especially at the tips): a thin incandescent
  WHITE core/edge, a thin yellow→orange rim hugging the center, and just a hair of
  RED on the outer edge. Flat layers. The TIPS are almost only the fine white line —
  NO big orange halo, NO flare. The body of the slash is THIN, not a thick jet.
- **ANGULAR/sharp edges** (graphic, razor edge), NOT soft, NOT rounded, NOT feathery.
- **MINIMAL extras:** a few small BLACK debris chips near the center and a stray
  spark or two. NO ember cloud, no fire particles.

**Animated as VIDEO** (not frames): the slash stays LONG but gets THINNER and thinner
until it disappears (it does NOT shrink in length, it thins out).

**Prompt (paste as-is):**

```
SEPARATE EFFECT CLIP, no character, no person, no scenery — only the effect over a PURE GREEN screen
#00FF00 (flat, static camera). A flat 2D anime/manga SLASH streak (Guilty Gear / 2XKO style) — a clean
sharp SWORD CUT that rips the air, NOT fire, NOT a flame, NOT plasma. ONE curved CRESCENT-shaped slash
blade: a smooth arc (NOT a straight line), THIN, thick and bright only in the middle and tapering to
VERY FINE, sharp, clean points at both ends (like crescent-moon horns), running diagonally (lower-left
to upper-right). Color CONTAINED and minimal: a thin incandescent WHITE core/edge, a thin yellow→orange
rim hugging the center, and just a hair of RED on the outer edge — flat hard color layers; the tips are
almost only the fine white line (NO big orange halo, NO flare). Angular razor-sharp edges, NOT soft,
NOT rounded, NOT feathery. A few small BLACK debris chips near the center. Animation: the slash SWIPES
into existence fast and thin (a bright line forming), peaks THICKEST and brightest for an instant, then
stays LONG but gets THINNER and thinner (never shortens in length), fading to a faint semi-transparent
thread that dissipates. Key: it thins out to vanish, it does NOT shrink in length. Stays centered. Fast,
snappy. NO character.
```

**Color variants:** DAM fire (orange/red), Favi water (cyan/blue), Aye floral
(pink/magenta).

When you have it, tell me "**impact-slash is ready**" and I'll process it and wire it
as the **low-hit** effect (sweeps, crouching hits, take_hit_low).

---

## CONGELADO (`frozen`) — estado estándar para TODOS los personajes

La CONGELACIÓN es mecánica global del juego (las púas ↓E de Aye y su Prism Orb congelan a
cualquier rival ~0.5–1s, y vendrán más hielos/elementos). Hoy, si el personaje NO tiene esta
animación, el juego PAUSA el frame en el que quedó + tinte morado — funciona, pero una pose
propia se ve pro.

**Especificación:** clip corto en LOOP (o 2–3 frames): pose RÍGIDA de "atrapado en el hielo" —
cuerpo tenso y un poco encogido, hombros subidos, brazos apretados contra el pecho, puños
cerrados, rodillas juntas y algo flexionadas, ojos APRETADOS, mueca de frío con dientes
apretados. El ÚNICO movimiento es un TIRITÓN sutil de todo el cuerpo (vibración de 2–3 px),
pelo y ropa temblando apenas. **SIN bloque de hielo, SIN escarcha, SIN partículas, SIN brillos**
— el hielo y el tinte los pone el juego encima (overlay común para todos).

**Guardar como** `imagen-action/<personaje>/sheets/frozen.mp4` → yo lo proceso a
`imagen-action/<personaje>/frozen/<personaje>-frozen-N.png`. **El juego ya está cableado:**
si existe la carpeta con frames, usa esta anim (con el tiritón corriendo) en vez de pausar
el frame; si no existe, sigue el comportamiento actual. Nada que tocar en código.

**Prompt (100% inglés, copy-paste TAL CUAL con la imagen de referencia del personaje;
opcional: pegar antes su bloque de identidad — p. ej. el WEAPONS LOCKED de Fe):**

> The character from the reference image, holding their signature weapon — the weapon
> stays RIGID and IDENTICAL to the reference in every frame, it never changes shape,
> never grows parts, never disappears. STRICT SIDE VIEW facing RIGHT, flat pure green
> #00FF00 background, fixed camera, the character stays the SAME SIZE and on the SAME
> SPOT the whole clip.
>
> The character is STANDING, FROZEN STIFF as if caught by extreme sudden cold: body tense
> and hunched slightly inward, shoulders raised, arms pulled tight against the chest, fists
> clenched (weapon still gripped), knees together and slightly bent, eyes SQUEEZED shut,
> teeth gritted in a cold grimace. The pose HOLDS the entire clip — the ONLY motion is a
> tiny rapid SHIVER of the whole body, hair and clothes quivering slightly. Seamless LOOP:
> last frame identical to the first. No ice, no frost, no snow, no particles, no glow —
> only the character shivering in place.

## ELECTROCUTADO (`electrocuted`) — reacción estándar para TODOS los personajes

El ELECTROCUTAMIENTO es mecánica global: el THUNDER de Fe (↓↘→) electrocuta a la víctima
(y vendrán más golpes eléctricos). Hoy el juego pone la silueta blanca intermitente detrás
del personaje — funciona, pero la pose propia de convulsión estilo **Street Fighter** (la
clásica: cuerpo arqueado rígido, brazos tiesos abiertos, pelo erizado) se ve pro.

Especificación: clip corto en LOOP: convulsión violenta EN EL SITIO — el cuerpo se
arquea RÍGIDO, brazos disparados a los lados tiesos con los dedos abiertos como garras
(el arma sigue agarrada), rodillas flexionadas hacia adentro, pelo ERIZADO hacia afuera
como cargado de estática, ojos muy abiertos, dientes apretados en mueca de dolor. La pose
se SOSTIENE todo el clip — el único movimiento es la SACUDIDA violenta y rápida de todo el
cuerpo (más fuerte que un tiritón), pelo y ropa azotándose con cada sacudida. **SIN rayos,
SIN chispas, SIN electricidad, SIN glow, SIN humo** — la silueta blanca intermitente y el
flash los pone el juego encima (overlay común para todos).

**Guardar como** `imagen-action/<personaje>/sheets/electrocuted.mp4` → yo lo proceso a
`imagen-action/<personaje>/electrocuted/<personaje>-electrocuted-N.png`. **El juego ya
está cableado (DAM, Fe y Aye):** si existe la carpeta con frames, la víctima del rayo hace
ESTA anim en loop mientras dura la descarga (con la silueta blanca parpadeando encima) y
vuelve a su pose al terminar; si no existe, se queda el comportamiento actual. Nada que
tocar en código.

**Prompt (100% inglés, copy-paste TAL CUAL con la imagen de referencia del personaje;
opcional: pegar antes su bloque de identidad — p. ej. el WEAPONS LOCKED de Fe):**

> The character from the reference image, holding their signature weapon — the weapon
> stays RIGID and IDENTICAL to the reference in every frame, it never changes shape,
> never grows parts, never disappears. STRICT SIDE VIEW facing RIGHT, flat pure green
> #00FF00 background, fixed camera, the character stays the SAME SIZE and on the SAME
> SPOT the whole clip.
>
> The character is STANDING and being violently JOLTED in place: body arched stiff and
> RIGID, both arms flung OUT to the sides locked stiff with fingers spread like claws
> (weapon still gripped), knees bent inward, head tipped slightly back, hair BRISTLING
> outward as if charged with static. The pose HOLDS the entire clip — the ONLY motion
> is a VIOLENT rapid full-body SHAKE (much stronger than a shiver), hair and clothes
> whipping with each jolt. The character stays ON ONE SPOT the whole clip — no walking,
> no falling, no turning. Seamless LOOP: last frame identical to the first. No
> lightning, no sparks, no electricity, no glow, no smoke — only the character
> convulsing in place (the game engine draws all electric effects on top).
>
> CAMERA HARD-LOCKED — this is STATIC WIDE footage, like a fixed security camera on a
> tripod bolted to the floor: the framing of the FIRST frame is the framing of EVERY
> frame. WIDE FULL-BODY SHOT the ENTIRE clip: the whole body from the top of the head
> to the soles of the shoes visible in every frame, with clear green margin ABOVE the
> head and BELOW the feet at least ONE HEAD TALL — that empty green space is CORRECT
> and REQUIRED, do NOT reframe, crop or move closer to fill it, and the SAME margin
> must still be there in the MIDDLE of the clip and in the LAST frame. Absolutely NO
> zoom in, NO zoom out, NO push-in, NO pan, NO tilt, NO drift, NO slow creep toward
> the character for drama — the shake is violent but the camera does NOT react to it.
> The head must be the SAME SIZE in pixels in the first frame, the middle frame and
> the last frame — if the character gets bigger at ANY point, the clip is WRONG. This
> is a SIMPLE hold-and-shake animation — do NOT invent extra action or camera drama.

## PASO CORTO (`step`) y BACKDASH (`backdash`) — doble-tap para Fe y DAM

El doble toque de dirección ya está cableado: **→→ = paso corto adelante** y **←← =
backdash** (estilo Street Fighter; Aye conserva su BLINK de maná). Hoy usan `walk`
acelerado de placeholder + polvo de dash — con clips propios se ven pro. El motor mueve
al personaje (~110-130px con decaimiento): el clip debe ser el gesto EN EL SITIO.

**Especificación `step` (→→):** brinquito RÁPIDO hacia adelante: desde la guardia, ambos
pies dejan el piso un instante en un salto BAJO y rasante (nunca un salto alto), el cuerpo
se inclina adelante con impulso, y aterriza YA en su guardia. Corto y explosivo (~0.3s de
acción útil).

**Especificación `backdash` (←←):** el espejo hacia atrás: empuje seco alejándose, cuerpo
inclinado atrás, un brinquito bajo rasante hacia atrás, aterriza en guardia. Mismo largo.

**Guardar como** `imagen-action/<personaje>/sheets/step.mp4` y `backdash.mp4` → yo los
proceso a `<personaje>/step/` y `<personaje>/backdash/`. **El juego ya está cableado
(Fe y DAM):** si existen los frames, el doble-tap usa la anim propia; si no, el placeholder.

**Prompt `step` (100% inglés, copy-paste TAL CUAL con la imagen de referencia del
personaje; opcional: pegar antes su bloque de identidad):**

> The character from the reference image, holding their signature weapon — the weapon
> stays RIGID and IDENTICAL to the reference in every frame, it never changes shape,
> never grows parts, never disappears. STRICT SIDE VIEW facing RIGHT, flat pure green
> #00FF00 background, fixed camera, the character stays the SAME SIZE and on the SAME
> SPOT the whole clip.
>
> From their fighting guard, the character does ONE quick LOW forward hop-step: both feet
> leave the ground for a brief instant in a LOW skimming hop (never a high jump — the feet
> barely clear the ground), body leaning forward with momentum, hair and clothes snapping
> with the burst, and they land ALREADY back in the exact same fighting guard (hold it a
> beat). The whole action is FAST and explosive. The character stays in the CENTER of the
> frame — the hop happens ON ONE SPOT (the game engine moves them across the stage). No
> effects, no dust, no motion lines — only the character.

**Prompt `backdash` (100% inglés, copy-paste TAL CUAL con la imagen de referencia):**

> The character from the reference image, holding their signature weapon — the weapon
> stays RIGID and IDENTICAL to the reference in every frame, it never changes shape,
> never grows parts, never disappears. STRICT SIDE VIEW facing RIGHT, flat pure green
> #00FF00 background, fixed camera, the character stays the SAME SIZE and on the SAME
> SPOT the whole clip.
>
> From their fighting guard, the character does ONE quick LOW hop BACKWARD (away from
> where they are facing): a sharp push off the front foot, body leaning BACK, both feet
> leaving the ground for a brief instant in a LOW skimming backward hop (never a high
> jump), hair and clothes snapping forward with the recoil, and they land ALREADY back in
> the exact same fighting guard (hold it a beat). The whole action is FAST and explosive.
> The character stays in the CENTER of the frame — the hop happens ON ONE SPOT (the game
> engine moves them across the stage). No effects, no dust, no motion lines — only the
> character.
