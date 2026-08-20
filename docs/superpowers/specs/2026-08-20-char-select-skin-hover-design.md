# Char-select: elegir skin en HOVER + lock (Aye-2) con avatar animado

Fecha: 2026-08-20 · Estado: aprobado (diseño)

## Objetivo

En la pantalla de selección de personaje, cuando el cursor está sobre **Aye** (único personaje con skins), el jugador puede **elegir la skin con ↑/↓ durante el hover** —viendo un **avatar animado** de cada skin— y **ENTER lockea** el personaje ya con esa skin. Hoy el skin se elige en un **sub-paso posterior** al confirmar (con ←→); eso se reemplaza.

Aplica a **los dos modos**: VS 2P local y VS CPU/secuencial.

## Fuera de alcance

- HUD de victoria/súper/ultra (`vs-pose`) y su uso en la pantalla de carga. (Diseño aparte.)
- Retratos grandes de la pantalla VS.
- Otros personajes: no se tocan (no tienen skins).

## Assets

Avatar animado full-body de Aye por skin (croma verde, en `imagen-action/aye-2/sheets/`):

- **skin-1 (tutú):** `select-animation.mp4` (animado) · `select-character_1.png` (estático, fallback).
- **skin-2 (overol):** `select-character_1.mp4` (animado) · `select-character_2.png` (estático, fallback).

> Naming inconsistente: el archivo animado se llama distinto por skin. La implementación identifica el mp4 por skin (o cae al `.png` estático si falta).

**Procesado:** cada mp4 → secuencia de frames en `imagen-action/aye-2/<skin>/select_char/aye2-select_char-N.png` (croma + calibrado full-body anclado a pies, al tamaño que espera el preview del char-select). Reglas del pipeline: `proc-aye2-clip.py` (mismo criterio que las anims de personaje; NO `--airborne`). Loop.

## Flujo

### VS CPU / secuencial (`char_select.gd::_unhandled_input`)

1. Hover del roster con **←→** (igual que hoy).
2. Sobre Aye: **↑/↓ cambia la skin** (`_toggle_color(side)`) → el avatar del preview y el indicador cambian tutú↔overol. *(Hoy ↑/↓ no hace nada en hover secuencial.)*
3. **ENTER = lock directo** con `skin_sel[side]` → avanza (P1→rival, rival→stage). **Sin** el sub-paso `skin_picking`.
4. Personaje sin skins: hover→ENTER como hoy (nada de skin).

### VS 2P local (`char_select.gd::_input_vs2p`)

- El **↑/↓ por lado ya existe** (`_toggle_color`). Solo se suma que el avatar del preview cambie con la skin (mismo mecanismo del preview skin-aware). El confirm lockea con la skin del hover.

## Componentes (todo en `char_select.gd`, salvo el procesado)

1. **Preview skin-aware (`side_spr` de Aye):** helper `_load_aye_avatar(side)` que carga las `SpriteFrames` de `select_char` de `skin_sel[side]` y las asigna a `side_spr[side]`. Se llama al posarse sobre Aye y al togglear skin. Cachea las 2 skins.
2. **`_toggle_color(side)`:** ya alterna `skin_sel`; se le agrega llamar a `_load_aye_avatar(side)` (recarga el avatar).
3. **`_unhandled_input` (secuencial):** agregar rama **↑/↓** en hover (picking 0/1) que, si el personaje actual es Aye, llama `_toggle_color(side)`. En la rama **ENTER** sobre Aye: lockear directo (avanzar) en vez de `skin_picking = side`.
4. **Indicador de skin en hover:** el `_skin_panel` deja de depender de `skin_picking`; pasa a mostrarse mientras se hace hover sobre Aye, con la skin actual (chip "TUTÚ / OVEROL · ↑↓").
5. **Limpieza:** eliminar la variable/lógica de `skin_picking` (toggle por ←→ en el sub-paso, ENTER-confirma-skin, ESC-cancela-skin, y la activación del panel por `skin_picking`).

## Datos

- `skin_sel := [0, 0]` — skin por lado (0=tutú, 1=overol). **Se conserva** (es el estado que ya viaja a `Sel.p1_skin`/`p2_skin` en `_goto_stage_after_hold`). El hover ↑/↓ lo setea; el lock lo commitea.
- `side_spr[side]` — `AnimatedSprite2D` del preview; para Aye se le intercambia el `SpriteFrames` por skin.

## Criterios de éxito (verificar EN JUEGO — drivear el char-select)

1. Hover sobre Aye → se ve el avatar **animado** de la skin actual.
2. ↑/↓ → alterna tutú↔overol (avatar **y** indicador cambian) en ambos lados/modos.
3. ENTER sobre Aye → lockea con la skin mostrada, **sin** sub-paso extra; la pelea carga esa skin (`Sel.p1_skin`/`p2_skin` correctos).
4. Otro personaje → hover→ENTER normal, sin paso de skin.
5. VS 2P → cada lado elige su skin en hover; entran las dos skins correctas.
6. No quedan restos del sub-paso viejo (ni panel, ni ←→ de skin, ni ESC-cancela-skin).
