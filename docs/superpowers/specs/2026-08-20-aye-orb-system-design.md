# Sistema de Orbes de Aye-2 — diseño

Fecha: 2026-08-20 · Estado: aprobado (diseño)

## Objetivo

Implementar la **mecánica firma de Aye-2**: 3 orbes de energía que orbitan a Aye y son su kit
ofensivo/de control de espacio (es ZONER). Cada orbe es un COLOR con efecto fijo. El jugador los
usa de dos formas — **boomerang** (tap: golpea y vuelve) y **plantar** (motion: viaja, golpea leve y
se queda flotando) — y luego los **llama de vuelta** (recall: vuelan hacia Aye atravesando al rival
con su efecto full). Es un bucle de "sembrar y cosechar" que rodea al rival y lo cruza al recall.

## Fuera de alcance

- El **SÚPER** (la red/línea de energía que conecta los orbes). El maná lo carga, pero el súper se
  diseña y codea aparte. Acá solo: el 🔵 suma maná y hay una barra que se llena.
- HUD de victoria/súper/ultra de medio cuerpo (`vs-pose`) — feature aparte.
- Netcode / rollback de los orbes.
- IA avanzada: la CPU-Aye usa **boomerangs** (poke) en esta entrega; plantar+recall por IA queda como
  comportamiento básico/opcional (ver §10), no es criterio de éxito bloqueante.

## Los 3 orbes (identidad)

| Orbe | Botón | Efecto al GOLPEAR (boomerang o recall) | Sprite |
|------|-------|----------------------------------------|--------|
| 🟡 Amarilla | Q | **+daño** (golpe fuerte) | `orbs-yellow` |
| 🩷 Rosa | W | **congela** al rival (`frozen_t`) | `orbs-pink` |
| 🔵 Azul | E | **+maná** a Aye (daño chico o nulo) | `orbs-blue` |

Producción: **1 esfera neutra que el motor tiñe ×3** (ya está el arte por color en
`imagen-action/aye-2/orbs-*` / `orb_*`). Los clips del CUERPO solo muestran el GESTO, sin esferas
dibujadas: `orb_throw`=🟡, `orb_jab`=🩷, `orb_e`=🔵 (lanzar) y `orb_push`=**gesto de recall**
(2 manos tirando de vuelta). El sprite de cada esfera va SIEMPRE aparte.

## Máquina de estados por orbe

Cada uno de los 3 orbes está en exactamente 1 estado:

- **ORBIT** — orbitando a Aye (reposo). Disponible para lanzar.
- **FLIGHT** — boomerang en curso: viaja recto hasta el alcance máx y VUELVE a la órbita.
- **PLANT_OUT** — plantar en curso: viaja hasta `PLANT_DIST` (atravesando al rival con chip); al llegar → PLANTED.
- **PLANTED** — flotando fijo en el mundo. Fuera de la órbita (ese color NO se puede lanzar).
- **RECALL** — volviendo desde su punto plantado hacia Aye; al llegar → ORBIT.

```
ORBIT --tap color--> FLIGHT --(alcance)--> ORBIT      (boomerang)
ORBIT --←→+color--> PLANT_OUT --(PLANT_DIST)--> PLANTED  (plantar)
PLANTED --recall--> RECALL --(llega a Aye)--> ORBIT   (cosechar)
PLANTED --(timeout ~8s)--> RECALL                     (auto-vuelve, sin input)
```

## Acciones

### Boomerang — `tap Q/W/E`
El orbe de ese color sale recto desde Aye, viaja hasta `ORB_RANGE`, y vuelve solo a la órbita.
**Golpea a la IDA** (una vez) aplicando su efecto full. Poke/zoning básico, **sin costo**.
Si ese color está PLANTED (o no está en ORBIT) → el botón **no hace nada** (whiff corto), hasta
que se recupere con recall. (Detalle ⚙️ confirmado.)

### Plantar — `←→ + Q/W/E`
Input: un **atrás→adelante rápido** (buffer corto, ~12 frames, como un dash-command — reusa la
detección de dash/motion que ya existe) seguido del botón de color. NO es carga sostenida.
Mismo gesto de lanzar, pero el orbe viaja **una distancia fija hacia adelante** (`PLANT_DIST`) y se
**queda plantado ahí**, ATRAVESANDO al rival si está en el camino (no se frena al tocarlo — así podés
plantar PASADO o detrás del rival). El **golpe de ida es LIGERO** (`PLANT_CHIP` de daño, SIN aplicar
el efecto de color — para no abusar del congelar). Pasa a PLANTED (flota con un bob leve). Sale de la
órbita → ese color deja de estar disponible para boomerang. Persiste hasta recall o **`PLANT_TIMEOUT`
(~8s)**; el rival puede pasar al lado (no bloquea, no colisiona estando quieto). **Sin costo.**

Para **rodear** al rival, Aye se reposiciona (camina/dashea) entre plantados, así los 3 caen en
puntos distintos; no hay que apuntar la distancia (siempre `PLANT_DIST` desde donde estás).

### Recall — `R`
- `R tap` → llama **1** orbe: el **plantado más viejo** (FIFO). (Detalle ⚙️ confirmado.)
- `R hold` (≥ `RECALL_HOLD` s) → llama **los 3** plantados.
Cada orbe llamado pasa a RECALL: vuela en línea desde su punto plantado hacia la posición de Aye,
**atravesando al rival** en el camino → golpe con **efecto FULL** del color (🟡 daño / 🩷 congela /
🔵 maná). Al llegar a Aye → ORBIT (disponible otra vez). Si no hay orbes plantados, `R` no hace nada.

## Maná / Súper (hook mínimo)

Barra de maná de mago para Aye-2. El **🔵 al golpear** (boomerang o recall) suma `MANA_PER_BLUE`.
Boomerang y plantar son **gratis**; el límite del kit es "tenés 3 orbes". La barra llena **habilita el
SÚPER** (fuera de alcance). En esta entrega: solo mostrar la barra y que el 🔵 la cargue. Reusa el
anillo/medidor de maná del sistema de mago si aplica (ver [[aye-mana-system]]); si no existe para
aye2, crear una barra simple.

## HUD de orbes

Indicador chico de los **3 orbes** cerca del retrato de Aye (esquina de su lado): muestra el estado de
cada color — **en órbita** (lleno/brillante), **plantado** (contorno/apagado) o **en vuelo**
(parpadeo). Sirve para saber qué te queda disponible. Colores 🟡🩷🔵.

## Arquitectura / componentes

Sigue el patrón existente "**el árbitro (main.gd / `mb`) maneja los proyectiles**" (como
`_spawn_frost_orb`, fighter.gd:2104). Los orbes son **persistentes** (orbitan siempre que exista una
Aye-2 en pantalla), no spawn-por-golpe.

1. **OrbManager (en el árbitro / main.gd)** — por cada fighter `fx_floral` (aye2), crea y posee **3
   sprites de orbe** (AnimatedSprite2D o Sprite2D con glow) + su estado. Cada frame:
   - ORBIT: los ubica orbitando alrededor del owner (ángulos separados 120°, radio `ORB_ORBIT_R`,
     rotación lenta; siguen al owner y respetan su `facing`).
   - FLIGHT / PLANT_OUT / RECALL: integra `pos += vel*dt`; chequea colisión con el RIVAL (AABB contra
     `body_halfw`/alto del rival) → aplica efecto según color y modo (ida-boomerang y recall = full;
     ida-plant = `PLANT_CHIP` sin efecto).
   - PLANTED: queda en su `world_pos` (bob), cuenta `age`; a `PLANT_TIMEOUT` → RECALL.
   - Tinta cada esfera por color (mismo shader de tinte que ya se usa para las 3 esferas).
2. **Input + gestos (fighter.gd, rama `fx_floral`)** — detecta:
   - `tap Q/W/E` (color en ORBIT) → reproduce el gesto (`orb_throw`/`orb_jab`/`orb_e`), y en su
     `hit_frame` llama `mb._orb_launch(self, color, BOOMERANG)`.
   - `←→+Q/W/E` (motion, color en ORBIT) → mismo gesto, `mb._orb_launch(self, color, PLANT)`.
   - `R tap` → `mb._orb_recall(self, 1)`; `R hold` → `mb._orb_recall(self, 3)`.
   Reusa la detección de MOTION/carga que ya usan los otros specials (roum `←←→`, aye vieja `→↓←`);
   `fx_floral` es exclusivo de aye2 (nadie más lo usa), así que estas ramas no afectan a otros chars.
3. **Efectos al impactar** — 🟡 `receive_hit` daño `ORB_DMG_YELLOW`; 🩷 `receive_hit` con
   `frozen_t = FREEZE_T` (mismo parámetro de congelar que ya existe); 🔵 daño `ORB_DMG_BLUE` (chico) +
   `owner.mana += MANA_PER_BLUE`. Un mismo orbe golpea **una vez por tramo** (ida, o recall).
4. **HUD de orbes (main.gd / capa HUD)** — dibuja los 3 chips de estado por color.

### Datos (por fighter aye2, en el árbitro)
```
orbs = [
  { color: YELLOW|PINK|BLUE, state: ORBIT|FLIGHT|PLANT_OUT|PLANTED|RECALL,
    pos: Vector2, vel: Vector2, world_pos: Vector2 (plantado), age: float,
    hit_done: bool (ya golpeó este tramo) },
  x3
]
plant_order = []   # ids de los plantados, en orden → FIFO para R tap
```

## Números tuneables (arranque; ajustar en juego)

| Constante | Valor inicial | Qué es |
|-----------|---------------|--------|
| `ORB_ORBIT_R` | 90 px | radio de la órbita alrededor de Aye |
| `ORB_SPEED` | ~1400 px/s | velocidad de viaje (ida/recall) |
| `ORB_RANGE` | ~55% del ancho de pantalla | alcance máx del boomerang si no toca |
| `PLANT_DIST` | ~45% del ancho de pantalla | distancia fija a la que aterriza el plantado |
| `PLANT_TIMEOUT` | 8.0 s | vida de un orbe plantado antes de auto-volver |
| `RECALL_HOLD` | 0.25 s | mantener R para llamar los 3 (vs tap = 1) |
| `ORB_DMG_YELLOW` | ~= un kick medio (referencia: normales de aye2) | daño del 🟡 |
| `PLANT_CHIP` | ~1/3 de un jab | daño del golpe de IDA al plantar (sin efecto) |
| `FREEZE_T` | 0.8 s | congelado del 🩷 (reusa `frozen_t`) |
| `ORB_DMG_BLUE` | ~= un jab (chico) | daño del 🔵 |
| `MANA_PER_BLUE` | +12% de la barra | maná que suma el 🔵 al golpear |

## Criterios de éxito (verificar EN JUEGO)

1. Aye tiene 3 orbes 🟡🩷🔵 orbitando en reposo; el HUD muestra su estado.
2. `tap Q/W/E` → boomerang del color: sale, golpea con su efecto (🟡 daño, 🩷 congela, 🔵 +maná), vuelve.
3. `←→+Q/W/E` → el orbe viaja, pega LIGERO y se **queda plantado**; ese color ya no está para boomerang.
4. `R tap` → vuelve el plantado más viejo, atravesando al rival con **efecto full**, y re-orbita.
5. `R hold` → vuelven **los 3** plantados a la vez.
6. Plantado sin recall → **auto-vuelve** a los ~8s.
7. Botón de un color plantado → no hace nada hasta recuperarlo.
8. La barra de maná sube con los golpes de 🔵.
9. Nada de esto afecta a los otros personajes (rama `fx_floral` aislada).
