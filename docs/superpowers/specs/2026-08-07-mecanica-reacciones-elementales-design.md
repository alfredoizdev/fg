# Mecánica firma: Reacciones Elementales — Diseño (v1)

> **Estado:** diseño aprobado sección por sección, pendiente de revisión final del spec.
> **Fecha:** 2026-08-07
> **Autor:** Alfredo + Claude (brainstorm)

## Contexto y encaje en el roadmap

El juego (fighting game 2D en Godot 4, estilo KOF, con DAM y Favi jugables) ya
tiene una base técnica avanzada (escala por ancho de cabeza, anclaje de pies,
screenshake, estelas, sombras fantasma). Lo que le falta para no verse "amateur"
frente a 2XKO se atacó en cuatro frentes:

- **Frente 0 — Mecánica única (ESTE documento):** lo que diferencia el juego en
  el market. Elegido: **cruce de géneros = reacciones elementales tipo RPG
  (Genshin/Divinity) dentro de un fighting game.**
- **Frente 1 — Game feel / peso:** hitstop, hold de impacto, sync de contacto.
- **Frente 2 — Look unificado:** shaders de paleta bloqueada + rim/contorno +
  color grade.
- **Frente 3 — Biblia de proporciones para GPT-4o:** model sheet con grid de
  cabezas + flujo editar-no-regenerar.

**Sinergia clave:** el *freeze* de cada reacción elemental ES el hitstop del
Frente 1. Esta mecánica y el game feel se construyen juntos: cada reacción es a
la vez un momento de peso y un momento de espectáculo. Por eso el Frente 0 va
primero — define qué feel hay que hacer espectacular.

## Visión (una frase)

Un fighting game donde los elementos de los personajes (fuego, agua, naturaleza)
crean **química**: pintas estados sobre el rival y sobre el escenario, y
combinarlos dispara **reacciones** con peso y espectáculo. Nadie en el market
tiene esto en versus.

## Objetivos

- Una mecánica que **destaque** y sea **legible** (el jugador siempre entiende
  qué estado tiene y qué reacción viene).
- **Emerger de lo que ya existe**: DAM=fuego, Favi=agua, fire-patches del
  escenario, géiser de agua, humo. Casi cero animación nueva de personaje.
- **Ejecución, no matchup:** las reacciones se preparan y se disparan; no es "tu
  elemento le gana al suyo".
- **Identidad de combate = mix balanceado:** algunas reacciones abren combo,
  otras controlan espacio.
- **Escalable:** cada personaje futuro entra en un slot del triángulo (Aye ya
  encaja como Naturaleza).

## No-objetivos (YAGNI para la v1)

- NO triángulo completo de 3 elementos en v1 (solo Fuego vs Agua).
- NO nubes de vapor con oclusión de visión en v1 (queda para v2).
- NO reacción CONDUCE ni INCENDIO en v1.
- NO savia / Aye en v1 (entra cuando Aye exista).
- NO rebalanceo global del moveset: las reacciones se montan ENCIMA del combate
  actual, no lo reemplazan.

## Sección 1 — Estructura: el triángulo elemental

Tres elementos, uno por personaje:

- 🔥 **Fuego** — DAM (katana incandescente)
- 💧 **Agua** — Favi (agujas / géiser)
- 🌿 **Naturaleza** — Aye (Bloom Staff, floral — personaje ya planeado)

Triángulo: **Fuego quema Naturaleza · Naturaleza bebe Agua · Agua apaga Fuego.**
El triángulo **solo define qué reacciones existen**, NO crea hard-counters entre
personajes. Favi puede mojarte, pero sin el golpe de fuego a tiempo no pasa nada:
el resultado depende del jugador, no del matchup.

## Sección 2 — Bucle central: estados + reacciones

**Estados** (un icono claro sobre la cabeza del rival):

- 💧 **MOJADO** — lo aplica Favi (y los charcos del escenario)
- 🔥 **ARDIENDO** — lo aplica DAM (y los fire-patches)
- 🌿 **CON SAVIA** — lo aplica Aye (v2): pegajoso, frena

**Reacciones** (cuando un estado recibe el disparador correcto → VFX + callout +
freeze de impacto):

| Estado | Disparador | Reacción | Rol (mix) |
|---|---|---|---|
| 💧 Mojado | golpe de 🔥 | **VAPOR** — estallido que lanza | Ofensiva (abre combo) |
| 🔥 Ardiendo | golpe de 💧 | **APAGÓN** — chip fuerte + apaga tu buff | Control / reset |
| mismo elemento | apila | **SOBRECARGA** — 🔥+🔥 = COMBUSTIÓN (auto-daño si no te despegas) | Resuelve espejos |
| 🌿 Savia | golpe de 🔥 | **INCENDIO** — daño en el tiempo | *(v2)* |
| 💧 Mojado | golpe de 🌿 | **CONDUCE** — propaga daño + stun | *(v2)* |

**Espejos resueltos (DAM vs DAM, Favi vs Favi):**
1. El **escenario da el 2º elemento**: en un espejo de fuego, empujas al rival a
   un charco (queda mojado) y ahí disparas VAPOR.
2. **Mismo elemento apila → SOBRECARGA**: acumular fuego lleva a COMBUSTIÓN
   (estallido de auto-daño). El mirror también tiene química.

## Sección 3 — Escenario elemental

El piso guarda elementos; ambos jugadores interactúan con ellos:

- 💧 **Charco** — donde cae el agua/géiser de Favi. **Resbaloso** (deslizas al
  frenar/dashear) y **fuente de MOJADO**. *Arte: sprite de agua plano (nuevo,
  simple) o recolor del splash existente.*
- 🔥 **Fire-patch** — DAM ya los deja; **ya existe `stage-firepatch` en el
  escenario**. **Quema al pisar** (aplica ARDIENDO), fuente de 🔥. *Arte: ya
  existe.*
- 💨 **Nube de vapor** — nace de VAPOR; tapa visión un instante *(v2)*. *Arte:
  humo (`stage-smoke`) recoloreado.*
- **Regla de limpieza:** agua y fuego en el piso **se cancelan** (charco apaga
  fire-patch); todo **auto-expira** en unos segundos. El escenario nunca se
  satura ni se vuelve ilegible.

## Sección 4 — Feedback / UX

- **Icono de estado** flotando sobre la cabeza del afectado (3 sprites chicos).
- **VFX de reacción** reusando arte existente: VAPOR = `water-geyser-fe` +
  `stage-smoke` recoloreados a blanco/gris; APAGÓN = chispas + vapor tenue.
- **Callout** de texto corto ("¡VAPOR!") al dispararse.
- **Freeze de impacto** (hitstop): al conectar la reacción, se congelan ambos
  peleadores unos frames. Es la primitiva nueva de game-feel (comparte destino
  con el Frente 1).
- Se apoya en el **screenshake ya existente** (`_shake` en `main.gd`).

## Alcance de la v1 (MVP apretado)

- **DAM (🔥) vs Favi (💧)** — 2 elementos.
- **2 estados:** MOJADO, ARDIENDO.
- **3 reacciones:** VAPOR, APAGÓN, SOBRECARGA.
- **2 terrenos:** charco + fire-patch (reusan arte).
- **Feedback completo:** icono + VFX reusado + callout + freeze.
- **Todo el arte de personaje reusado** (0 hojas nuevas de DAM/Favi).

## v2 / futuro (no ahora)

- Aye + Naturaleza → triángulo completo.
- Reacciones INCENDIO y CONDUCE.
- Nube de vapor con oclusión de visión.
- Savia (parche pegajoso que frena).
- Nuevos elementos para personajes futuros (hielo, rayo, viento) = nuevos slots.

## Tunables (para balancear sin tocar código)

- Duración de cada estado (arranque ~3 s).
- Ventana en la que el disparador cuenta como reacción.
- Cooldown de VAPOR (evitar spam del lanzador).
- Daño/stun/launch de cada reacción.
- Duración y radio de charcos / fire-patches; tiempo de auto-expiración.
- Frames de freeze por reacción.

## Integración con lo existente (archivos)

- `fighter.gd` — estado por peleador (mojado/ardiendo), aplicar estado al
  golpear, chequear disparador, ya tiene `fire_trail` y sombras reusables.
- `main.gd` — `_shake` (screenshake) ya existe; añadir la primitiva de **freeze**
  global y el manejo de terrenos del escenario.
- `fighter_frames.tres` — sin cambios de animación en v1 (reacciones = VFX +
  freeze sobre moves actuales).
- Assets reusados: `imagen-action/stage/stage-firepatch*`, `stage-smoke`,
  `imagen-action/impact-effect/water-geyser-fe`, `chispas-impat-hit*`,
  `Fe-sound-effect/water-splahs.mp3`.

## Riesgos y mitigaciones

- **Legibilidad** (demasiada info en pantalla): iconos claros + limpieza del
  escenario + solo 2 estados en v1.
- **Balance / spam de VAPOR:** cooldown + ventana de reacción acotada.
- **Espejos sin química:** resuelto con fuentes de escenario + SOBRECARGA.
- **Arte nuevo inesperado:** v1 reusa todo; el único asset posiblemente nuevo es
  un sprite plano de charco (simple).

## Preguntas abiertas

- ¿El VAPOR **lanza** (juggle aéreo) o **aturde de pie** (stun)? — decidir en el
  plan de implementación probando el feel.
- ¿Los estados se muestran también en la barra de vida (HUD) además del icono
  flotante? — opcional, evaluar en implementación.
