# Sistema de Anillos — Mecánica Firma (5 personajes)

**Fecha:** 2026-08-25
**Meta del proyecto:** comercial (Steam/itch). El sistema de anillos es el **gancho de venta**.
**Estado:** Cambios 1 (Fe) y 2 (Zetma) + color de Aye **IMPLEMENTADOS**. **DESACOPLE de Fe aplicado en build MF** (2026-08-25): las marcas se plantan libres cada 3 golpes; el crítico exige 3 marcas + instinto lleno. Valores iniciales pendientes de playtest.

## Gancho / pitch de una frase

> *"5 peleadores, 5 anillos de poder — cada uno se CARGA de una forma completamente distinta."*

Cada personaje tiene un anillo secundario (aparte de la barra verde de súper). Lo único que hace a cada personaje sentirse único no es el color ni los golpes: es **el VERBO con el que cargás su anillo**. El anillo te enseña a jugar al personaje.

## El sistema: 5 verbos distintos

| Personaje | Anillo | Se LLENA por (VERBO) | Se GASTA en | Fantasía |
|---|---|---|---|---|
| **DAM** 🔴 | Rabia | **SUFRIR** — recibir daño (perder 60% vida) | Berserk (×1.35 daño, ~6s) | remontada |
| **Roum** 🟥 | Vacío | **AGREDIR** — hacer 40% de daño al rival | portales (warp/pit grab) | presión de grappler |
| **Aye** 🟣 | Maná | **PACIENCIA** — tiempo/zoneo (+orbe azul) | hechizos (gasta % por casteo) | maga zoner |
| **Fe** 🔵 | Instinto | **COMBEAR** — conectar golpes encadenados | 3 marcas → crítico 300 | asesina que se gana el kill |
| **Zetma** 🟪 | Orbe | **CASTIGAR** — counter-hits (pegar al rival mientras ataca) | orbe de vacío (atrapa) | ninja que lee y castiga |

Verbos: **sufrir · agredir · paciencia · combear · castigar.** Ninguno se repite.

## Estado actual vs objetivo

Confirmado en código: los 5 **ya tienen anillo** (HUD: `is_mage or rage_side or orb_side or void_side`), y 3 verbos ya son únicos. El problema: **Aye, Fe y Zetma hoy se llenan los tres por TIEMPO**. El trabajo es cambiar SOLO 2 llenados (Fe y Zetma) para que cada uno sea distinto.

- **DAM (sufrir), Roum (agredir), Aye (paciencia):** ✅ ya están, no se tocan.
- **Fe:** hoy tiempo (~15s) → cambiar a **conectar combos**.
- **Zetma:** hoy tiempo (~18s) → cambiar a **counter-hits**.

## Cambio 1 — Fe: Instinto por CONECTAR COMBOS

**Mecánica:** el instinto ya no carga por tiempo. Carga **cada golpe que Fe conecta** (aggression). El resto de su kit queda igual: con instinto lleno, cada 3 golpes encadenados planta una marca; 3 marcas → el golpe es crítico de 300; el crítico VACÍA el instinto.

**Loop:** presionás → el instinto sube golpeando → al llenarse empezás a plantar marcas → 3 marcas → crítico → instinto vacío → volvés a presionar para recargar. **Pura agresión, cero campear.**

**Implementación:**
- Quitar a Fe (`fx_blue`) del regen por tiempo (borrar la rama `elif mf2.fx_blue: mg = FE_INSTINCT_REGEN` agregada en build MB, y la constante).
- En `_combo_hit(idx, ...)`: si el atacante es `fx_blue`, sumar `mana[idx] += FE_INSTINCT_PER_HIT` (plano, sin escalado anti-infinito).
- **Valor inicial (tunable):** `FE_INSTINCT_PER_HIT = 0.10` → ~10 golpes para llenar. Ajustar en playtest.
- **Opcional (recomendado):** decaimiento lento del instinto si no conecta golpes por ~3s ("úsalo o piérdelo"), reforzando que debe seguir presionando. Empezar SIN decay; agregar si se banca demasiado fácil.

**Ritmo — DESACOPLE APLICADO (build MF):** las marcas se plantan LIBRES cada 3 golpes (sin requerir instinto lleno); el instinto se llena en paralelo golpeando; el crítico exige **3 marcas + instinto lleno** (`fe_crit = fx_blue and fe_marks>=3 and mana>=0.999`). Así ambos recursos suben juntos combeando y el crítico es alcanzable en una secuencia de ~10 golpes, sin la rampa lenta de "llenar instinto antes de plantar". `_fe_add_mark` ya no gatea por instinto ni hace el blink rojo.

## Cambio 2 — Zetma: Orbe por CASTIGAR (counter-hits)

**Mecánica:** el orbe ya no carga por tiempo. Carga cuando Zetma pega al rival **mientras el rival está atacando** (counter-hit / castigo a un whiff o a un botón comprometido). Rueda la fantasía ninja: "golpeo cuando te comprometés."

**Loop:** baiteás/leés el ataque del rival → lo castigás → el orbe carga fuerte → 3-4 castigos → orbe listo → orbe de vacío (atrapa). Premia defensa/lectura, no spam.

**Implementación:**
- Quitar el llenado por tiempo (`orb_charge += delta / ORB_CHARGE_TIME`).
- En `_process_attacker`, cuando el atacante es `fx_dark` (Zetma) y conecta: si `not def.current_attack().is_empty()` (el defensor estaba atacando) → `orb_charge[zidx] += ZETMA_ORB_PER_PUNISH`.
- **Valor inicial (tunable):** `ZETMA_ORB_PER_PUNISH = 0.30` → ~3-4 castigos para llenar (un castigo es una lectura, vale mucho).
- **Piso pasivo (como Roum):** un chorrito mínimo `ZETMA_ORB_REGEN ≈ 0.010/s` para que **nunca quede del todo trabado** si el rival no ataca nunca.
- **Opcional:** también sumar un poco al aterrizar su jalón/`ground_grab` (también es una lectura).

## Sin cambios

**DAM (Rabia), Roum (Vacío), Aye (Maná)** quedan exactamente igual. Sus verbos ya son únicos.

## Diferenciación visual

- Colores: DAM rojo-naranja, Roum carmesí, Fe azul. **RESUELTO (2026-08-25):** Zetma = **morado OSCURO** (queda como está, `Color(0.78,0.12,2.05)`), Aye = **morado ROSADO** (virada a `Color(2.40,0.55,1.90)` lleno / `Color(1.65,0.38,1.35)` cargando — más roja/rosa, R>B). Ya no se confunden.
- **Ritmo del anillo** (ya hecho para Fe en build MB): el anillo de Fe PULSA cuando está lleno ("arma lista"). Aplicar un ritmo propio a cada uno en una pasada de polish posterior (fuera de este spec): Aye fluctúa, Zetma "carga y descarga", DAM late al sufrir, Roum se llena a golpes.

## Criterios de éxito

1. Cada uno de los 5 anillos se llena por un verbo **distinto y legible**.
2. Jugar cada personaje se **siente** distinto por cómo administrás su anillo, no solo por los golpes.
3. Fe ya no carga campeando; Zetma ya no carga por tiempo muerto.
4. Ningún anillo queda **trabado sin salida** (Zetma tiene piso pasivo).
5. Se puede resumir el juego en la frase-gancho de arriba.

## Riesgos / decisiones abiertas

- **Tuning de valores** (`FE_INSTINCT_PER_HIT`, `ZETMA_ORB_PER_PUNISH`, piso de Zetma): son puntos de arranque; requieren playtest.
- **Rampa de Fe** (llenar instinto antes de plantar marcas): puede sentirse lento; plan B = desacoplar (arriba).
- **Detección de counter-hit** de Zetma vía `current_attack()`: cubre "pegar mientras el rival tiene un ataque activo". No distingue whiff puro de trade; alcanza para la fantasía.
- ~~**Color Aye vs Zetma** (ambos morados)~~ **RESUELTO:** Zetma morado oscuro, Aye morado rosado.

## Fuera de alcance (para después)

- Ritmo/animación visual propia de cada anillo (polish).
- Rediseñar los verbos de DAM/Roum/Aye (ya funcionan).
- El sistema de reacciones entre personajes (idea descartada esta sesión).
