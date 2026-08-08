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
  *"mantén IDÉNTICO el personaje (misma cabeza, misma estatura, mismos colores,
  misma línea), cambia SOLO la pose a X"*. Mucho más consistente que generar de cero.
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

**Glosario para hablarle a la IA:** *pose clave/extremo* = las poses que cuentan
el golpe (carga, impacto, remate) · *silueta* = test del contorno en negro ·
*squash/stretch* = aplastar en carga, estirar en impacto · *smear* = frame de
estela sólida del arma en el golpe rápido · *overshoot* = pasarse de la pose
antes de asentar.

---

## Bloque de IDENTIDAD (esto es lo único que cambia por personaje)

Plantilla — llénala para cada personaje nuevo y úsala como primer párrafo de
CADA prompt (más la imagen de referencia):

> Mismo personaje exacto de la referencia: [ROPA — prendas, capucha, etc.],
> [COLORES/PALETA], [PELO], [OJOS], [DETALLES: guantes, accesorios]. Su arma es
> [ARMA — descripción, material, color, brillo]. [Prohibiciones del arma si
> aplica: sin fuego, sin partículas, etc.].

Ejemplo (DAM): abrigo rojo con capucha, ropa negra, tenis negros con detalles
rojos, guantes sin dedos, pelo negro despeinado, ojos rojos; arma = katana de
metal INCANDESCENTE al rojo vivo (sin llamas ni brasas).

---

## ROSTER de movimientos (igual para TODOS los personajes)

Cada personaje genera ESTAS hojas. El conteo de frames y el ritmo son fijos;
solo cambia cómo se ve el golpe con su arma. La descripción detallada de la
animación de cada uno va en la guía específica del personaje.

### Básicas
| Hoja | Frames | Filas | Función en el juego |
|---|---|---|---|
| `pose-sheet` | 4 (loop) | 1 | Guardia idle, respiración sutil |
| `walk-sheet` | 8 | 2×4 | Ciclo de caminata de combate |
| `crouch-sheet` | 3 | 1 | Se agacha progresivamente |
| `jump-sheet` | 3-4 | 1 | Salto (subida/ápice/caída) |

### Golpes de pie
| Hoja | Frames | Botón | Función |
|---|---|---|---|
| `weak-punch-sheet` | 4 | R | Golpe suave rápido (jab, dmg 4) |
| `punch-sheet` | 10 | Q | Golpe horizontal (dmg 8; →Q = doble) |
| `kick-sheet` | 10 (usa fila 1) | W | Golpe pesado (dmg 12) |
| `spin-kick-sheet` | 8 | E | Giratoria que viaja y lanza (dmg 13) |

### Golpes agachados
| Hoja | Frames | Botón | Función |
|---|---|---|---|
| `crouch-jab-sheet` | 4 | ↓R | Pinchazo bajo rápido (bajo, dmg 4) |
| `crouch-punch-sheet` | 3 | ↓Q | Golpe agachado (bajo, dmg 6) |
| `crouch-kick-sheet` | 5 | ↓W | GANCHO lanzador que manda al aire (dmg 9) |
| `sweep-sheet` | 6 | ↓E | Barrido que derriba (bajo, dmg 12) |

### Aéreos
| Hoja | Frames | Botón | Función |
|---|---|---|---|
| `jump-punch-sheet` | — | salto+Q | Golpe aéreo (dmg 9) |
| `jump-kick-sheet` | — | salto+W | Patada en picada (dmg 10) |
| `air-spin-kick-sheet` | 8 | salto+E | Mortal con patada, lanza (dmg 13) |

### Reacciones y especiales
| Hoja | Frames | Función |
|---|---|---|
| `take-hit-sheet` | — | Recibe golpe de pie |
| `take-hit-low-sheet` | — | Recibe golpe agachado |
| `pummeled-sheet` | 4 (loop) | Machacado de pie durante el ULTRA |
| `wall-bounce-sheet` | 4 | Vuelo recto noqueado + estrellón en pared |
| `block-sheet` / `block-low-sheet` | — | Bloqueo alto / bajo |
| `ko-sheet` | — | Noqueado, tendido |
| `victory-sheet` | — | Celebración de victoria |

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

## Chispas de impacto ÉPICAS (estilo 2XKO) — prompt para la AI

Para reemplazar las chispas actuales por un DESTELLO DE IMPACTO grande y
dramático (el que sale al conectar un golpe). Archivo: `impact-hit-sheet.png`
en `imagen-action/impact-effect/`.

**Formato técnico (OBLIGATORIO para que entre al juego):**
- 1 hoja, **4 frames en UNA fila** de izquierda a derecha (o 6 en 2 filas de 3,
  fila de arriba primero) = el efecto avanzando en el tiempo.
- Fondo **VERDE puro #00FF00** (se recorta a transparente; el verde NO puede
  tocar el efecto — deja aire verde alrededor de cada frame).
- El efecto **CENTRADO**, con el **MISMO centro y el MISMO tamaño** en todos los
  frames (si salta de posición o tamaño, se ve mal).
- **SIN personaje, sin escenario, sin barras, sin texto, sin números.** Solo el
  efecto flotando sobre el verde.
- Estilo **cel-shaded PLANO, alto contraste, bordes NÍTIDOS y duros, colores
  saturados. NADA borroso, NADA de glow suave difuso tipo Photoshop.**

**CONCEPTO CLAVE (leer primero):** esto es un **DIBUJO GRÁFICO PLANO 2D estilo
manga/anime hit-spark** (como Guilty Gear / 2XKO), **NO una explosión realista
ni una bola de fuego renderizada**. Piensa en TINTA y PAPEL: formas planas de
color liso recortadas con filo, no volumen ni humo ni fuego 3D. Los tres errores
a evitar SÍ o SÍ:
- ❌ **NO circular / NO simétrico:** la silueta es DESBALANCEADA e IRREGULAR —
  más grande y con más púas de un lado, torcida, como una SALPICADURA de pintura,
  NUNCA una rueda de fuegos artificiales redonda ni un óvalo.
- ❌ **NO sólido / NO relleno:** entre las púas y los rayos queda **AIRE (fondo
  verde) visible** — son lengüetas y esquirlas SEPARADAS con huecos entre ellas,
  NO una masa naranja rellena y continua. Se debe poder "ver a través" en varios
  puntos.
- ❌ **NO sombreado interno / NO volumen:** colores en **3-4 capas planas duras**
  (blanco → amarillo → naranja), sin degradados suaves, sin sombras adentro, sin
  aspecto de esfera 3D. Es plano como una calcomanía.

**Qué dibujar (el look de la referencia 2XKO), por capas:**
1. **Estrella de choque ASIMÉTRICA:** un destello de MUCHAS púas afiladas,
   largas y de LARGOS DISTINTOS, saliendo torcidas en direcciones IRREGULARES
   (unas cortas, otras larguísimas) — bordes en ZIGZAG agresivo, silueta
   lopsided (desbalanceada), con **huecos de fondo verde entre las púas**.
2. **Núcleo incandescente EN FORMA DE ESTRELLA (no bola):** el centro es una
   estrella filosa BLANCA cegadora → un aro AMARILLO brillante → puntas y bordes
   finos en NARANJA. Todo en CAPAS planas de color, cero difuminado. El centro es
   puntiagudo/irregular, NO un círculo blanco.
3. **Tinta negra sumi-e (LA FIRMA del look):** una o dos MANCHAS grandes de
   tinta NEGRA sólida, con forma irregular tipo salpicadura de pincel, colocadas
   DESCENTRADAS (arriba y a un costado, comiéndose parte de la estrella) — esto
   crea el "hueco" negro que rompe la simetría. El negro le da peso; sin él se ve
   "barato". La tinta va NEGRA sólida (sobrevive al recorte del verde).
4. **Esquirlas de luz:** varias lanzas MUY FINAS y LARGAS blanco-amarillas
   disparadas en diagonal hacia afuera, SEPARADAS del cuerpo de la estrella
   (aisladas, con verde alrededor), a distintos largos.
5. **Escombros:** trocitos negros angulares + motitas/puntos volando hacia
   afuera, y unas pocas gotas de tinta salpicando lejos.
6. (Opcional, más pop) **chispitas eléctricas CIAN** finas cerca del centro.

**Ciclo por frames (un impacto es INSTANTÁNEO: estalla temprano y se disipa):**
- **f1 — NACE:** núcleo blanco chico ultra-brillante, 3-4 púas cortas asomando,
  1-2 flecos de tinta.
- **f2 — ESTALLA:** la estrella explota a casi el tamaño máximo: muchas púas,
  primeras esquirlas diagonales, manchones de tinta arriba, escombros saliendo.
- **f3 — PICO:** lo más grande y caótico: estrella completa, esquirlas largas,
  vacíos de tinta, escombros y (opcional) chispas cian.
- **f4 — SE DISIPA:** las púas se acortan, la tinta y los escombros se alejan y
  adelgazan, queda un destello tenue.
  *(Con 6 frames: alarga el pico — f3 y f4 = pico, f5-f6 = disipación.)*

**Variantes de color (MISMO diseño, solo cambia el tinte del núcleo/púas; la
tinta negra y los escombros quedan negros en las tres):**
- **DAM (fuego):** blanco → AMARILLO → naranja (igual que la referencia).
- **Favi (agua):** blanco → CIAN → azul marino.
- **Aye (naturaleza/floral):** blanco → ROSA → magenta/lavanda.

Cuando tengas la hoja, dime "**ya está impact-hit-sheet**" y la proceso (recorte
verde + centrado) y la conecto como efecto de impacto de golpes de todos.
