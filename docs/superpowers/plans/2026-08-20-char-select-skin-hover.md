# Char-select skin hover + lock (Aye-2) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** En el char-select, sobre Aye se elige la skin con ↑/↓ en HOVER (viendo un avatar animado por skin) y ENTER lockea con esa skin; se elimina el sub-paso de skin post-confirm.

**Architecture:** Todo el cambio vive en `char_select.gd` + procesar 2 clips. El preview del lado (`side_spr`) pasa a ser skin-aware para Aye: en hover reproduce la animación `select_char` de la skin actual (loop), y se recarga al togglear. El flujo secuencial gana ↑/↓ en hover y ENTER-lock directo; el sub-paso `skin_picking` se borra.

**Tech Stack:** Godot 4.7 / GDScript; `proc-aye2-clip.py` (Python) para procesar clips; `godot --headless --import` para compilar/importar.

## Global Constraints

- **NO relanzar el juego** por nuestra cuenta: la verificación en-juego la hace el usuario. Nosotros: `godot --headless --import` para compilar/importar y chequear que no haya `SCRIPT ERROR`.
- **Solo Aye** tiene skins; los demás personajes NO se tocan.
- `skin_sel := [0, 0]` (0=skin-1 tutú, 1=skin-2 overol) es el estado que ya viaja a `Sel.p1_skin`/`p2_skin` — **conservarlo**.
- Sin framework de tests: cada tarea = cambio → import headless sin errores → checklist de verificación EN JUEGO para el usuario → commit.
- Bajar N→M frames deja `.png.import` huérfanos: borrar sidecars sin `.png` y reimportar (`[[anim-fewer-frames-orphan-import]]`).
- El editor de Godot abierto puede pisar `.gd`: verificar el cambio EN DISCO tras cada edit.

---

### Task 1: Procesar los avatares animados `select_char` por skin

**Files:**
- Create: `imagen-action/aye-2/skin-1/select_char/aye2-select_char-*.png` (procesado)
- Create: `imagen-action/aye-2/skin-2/select_char/aye2-select_char-*.png` (procesado)
- Source: `imagen-action/aye-2/sheets/skin-1/select-animation.mp4` (skin-1) · `imagen-action/aye-2/sheets/skin-2/select-character_1.mp4` (skin-2) — naming inconsistente, confirmado.

**Interfaces:**
- Produces: carpetas `imagen-action/aye-2/<skin>/select_char/` con frames `aye2-select_char-N.png` (1..N), full-body croma, para que Task 2 las cargue.

- [ ] **Step 1: Procesar skin-1**

```bash
cd /Users/alfredoizquierdo/Desktop/fg
python3 proc-aye2-clip.py imagen-action/aye-2/sheets/skin-1/select-animation.mp4 --action select_char --skin skin-1 --uniform --stand --stand-pct 99 --target-h 760
```
(Full-body, escala uniforme calibrada al frame parado; `--target-h 760` = render grande para el preview; el char-select lo re-escala por `SIDE_BODY_K`. NO `--airborne`.)

- [ ] **Step 2: Procesar skin-2**

```bash
python3 proc-aye2-clip.py imagen-action/aye-2/sheets/skin-2/select-character_1.mp4 --action select_char --skin skin-2 --uniform --stand --stand-pct 99 --target-h 760
```

- [ ] **Step 3: Importar y verificar conteos**

```bash
godot --headless --import --quit-after 2000 2>&1 | grep -iE "SCRIPT ERROR|DONE.*reimport" | tail -1
for s in skin-1 skin-2; do echo "$s: $(ls imagen-action/aye-2/$s/select_char/*.png|grep -v import|wc -l|tr -d ' ') png / $(ls imagen-action/aye-2/$s/select_char/*.png.import|wc -l|tr -d ' ') import"; done
```
Expected: png == import (sin huérfanos) para ambas skins; sin `SCRIPT ERROR`.

- [ ] **Step 4: Ojear un frame (calidad/croma)**

Leer `imagen-action/aye-2/skin-1/select_char/aye2-select_char-1.png` — debe verse Aye full-body limpia (sin borde verde), tamaño grande.

- [ ] **Step 5: Commit**

```bash
git add imagen-action/aye-2/skin-1/select_char imagen-action/aye-2/skin-2/select_char
git commit -m "aye-2: avatares animados select_char por skin (char-select)"
```

---

### Task 2: Preview del lado skin-aware + animado para Aye

**Files:**
- Modify: `char_select.gd` (agregar builder `_aye_sel_frames`; ramas para Aye en `_set_side`; cache; constante de ruta)

**Interfaces:**
- Consumes: frames de Task 1 en `res://imagen-action/aye-2/<skin>/select_char/aye2-select_char-N.png`.
- Produces: `_aye_sel_frames(skin: String) -> SpriteFrames` (anim "idle", **loop=true**, 24fps); `_set_side(s, id)` muestra el avatar animado de la skin `skin_sel[s]` cuando `id == "aye"`.

- [ ] **Step 1: Agregar el builder + cache (cerca de `_frames_for_lite`, ~línea 306)**

En `char_select.gd`, agregar la variable de cache junto a `sel_frames_lite` (~línea 135):
```gdscript
var aye_sel_frames := {}   # "skin-1"/"skin-2" -> SpriteFrames del select_char (avatar animado, loop)
```
Y la función (después de `_frames_for_lite`):
```gdscript
# AYE-2: avatar animado del char-select por skin (loop). Frames en aye-2/<skin>/select_char/.
func _aye_sel_frames(skin: String) -> SpriteFrames:
	if aye_sel_frames.has(skin):
		return aye_sel_frames[skin]
	var sf := SpriteFrames.new()
	sf.add_animation("idle")
	sf.set_animation_loop("idle", true)     # HOVER = anim en loop (a diferencia de los demás)
	sf.set_animation_speed("idle", 24.0)
	var i := 1
	while true:
		var p := "res://imagen-action/aye-2/%s/select_char/aye2-select_char-%d.png" % [skin, i]
		if not ResourceLoader.exists(p):
			break
		sf.add_frame("idle", load(p))
		i += 1
	aye_sel_frames[skin] = sf
	return sf
```

- [ ] **Step 2: Rama de Aye en `_set_side` (línea ~308-315)**

Reemplazar el cuerpo de `_set_side(s, id)` para que, si es Aye, use el avatar animado de la skin del lado y lo reproduzca en LOOP (no congelado):
```gdscript
func _set_side(s: int, id: String) -> void:
	var spr: AnimatedSprite2D = side_spr[s]
	if id == "aye":
		var skin := "skin-2" if int(skin_sel[s]) == 1 else "skin-1"
		spr.sprite_frames = _aye_sel_frames(skin)
		spr.speed_scale = 1.0
		spr.play("idle")                     # avatar animado en loop
	else:
		spr.sprite_frames = _frames_for_lite(id)
		spr.speed_scale = 0.0
		spr.play("idle")
		spr.frame = 0
	# (mantener debajo la lógica de escala/posición existente sin cambios)
```

- [ ] **Step 3: Compilar (import headless)**

```bash
godot --headless --import --quit-after 1500 2>&1 | grep -iE "SCRIPT ERROR|Parse Error" | head; echo ok
```
Expected: sin errores. Confirmar en disco: `grep -n "_aye_sel_frames" char_select.gd`.

- [ ] **Step 4: Verificar EN JUEGO (usuario)**

- Entrar al char-select, posar el cursor sobre Aye → se ve el avatar **animado** (loop) de skin-1 (tutú).
- Los demás personajes en hover → siguen con su pose congelada de siempre.

- [ ] **Step 5: Commit**

```bash
git add char_select.gd
git commit -m "char-select: preview de Aye = avatar animado por skin (loop)"
```

---

### Task 3: ↑/↓ en hover cambia skin + recarga el avatar (ambos modos)

**Files:**
- Modify: `char_select.gd` (`_toggle_color`; rama ↑/↓ en `_unhandled_input`)

**Interfaces:**
- Consumes: `_set_side(s, id)` de Task 2, `_toggle_color(side)` existente.
- Produces: al tocar ↑/↓ sobre Aye (2P y secuencial), `skin_sel[side]` alterna y el avatar del preview cambia tutú↔overol.

- [ ] **Step 1: `_toggle_color` recarga el avatar (línea ~330-337)**

Dentro de `_toggle_color`, tras `skin_sel[side] = 1 - int(skin_sel[side])` y antes de `_refresh()`, agregar la recarga del preview:
```gdscript
		_set_side(side, "aye")   # recarga el avatar de la nueva skin
```

- [ ] **Step 2: ↑/↓ en el flujo secuencial (`_unhandled_input`, tras la rama de ←→, antes de la de ENTER, ~línea 1259)**

Agregar:
```gdscript
	# ↑/↓ en HOVER sobre Aye: cambia la SKIN (mismo mecanismo que 2P). Otros personajes: nada.
	if picking < 2:
		var side := picking   # 0=P1, 1=rival
		var id_hover := String(roster[sel1 if side == 0 else sel2]["id"])
		if id_hover == "aye" and (Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down")):
			_toggle_color(side)
			return
```

- [ ] **Step 3: Compilar**

```bash
godot --headless --import --quit-after 1500 2>&1 | grep -iE "SCRIPT ERROR|Parse Error" | head; echo ok
```

- [ ] **Step 4: Verificar EN JUEGO (usuario)**

- Secuencial: hover Aye → ↑/↓ alterna tutú↔overol (el avatar cambia).
- 2P: cada lado ↑/↓ cambia su skin y su avatar.

- [ ] **Step 5: Commit**

```bash
git add char_select.gd
git commit -m "char-select: ↑/↓ en hover cambia skin de Aye (secuencial + 2P)"
```

---

### Task 4: ENTER lockea directo + borrar el sub-paso `skin_picking`

**Files:**
- Modify: `char_select.gd` (`_unhandled_input`: ramas ENTER/←→/ESC; borrar `skin_picking`)

**Interfaces:**
- Consumes: `skin_sel[side]` seteado por Task 3.
- Produces: ENTER sobre Aye avanza directo (P1→rival, rival→stage) con la skin del hover; sin `skin_picking`.

- [ ] **Step 1: ENTER sobre Aye avanza directo (líneas ~1262-1285)**

En la rama ENTER: BORRAR el `if skin_picking >= 0:` completo (líneas ~1262-1270). En la rama `elif picking == 0:` cambiar el bloque de Aye a avanzar directo:
```gdscript
		elif picking == 0:
			_play_anim(0)
			_play_select(String(roster[sel1]["id"]))
			picking = 1                 # avanza al rival (la skin ya está en skin_sel[0])
			_refresh()
		elif picking == 1:
			_play_anim(1)
			_play_select(String(roster[sel2]["id"]))
			_goto_stage_after_hold()    # avanza al stage (skin ya en skin_sel[1])
```
(Quitar los `if ... == "aye": skin_picking = 0/1`.)

- [ ] **Step 2: Sacar el toggle de skin por ←→ (líneas ~1247-1248)**

En la rama de `dc != 0`, borrar el `if skin_picking >= 0: skin_sel[...] = ...` y su `elif` que lo precede; dejar solo la navegación del roster/stage:
```gdscript
	if dc != 0:
		if picking == 0:
			sel1 = posmod(sel1 + dc, roster.size())
		elif picking == 1:
			sel2 = posmod(sel2 + dc, roster.size())
		else:
			sel_stage = clampi(sel_stage + dc, 0, Sel.STAGES.size() - 1)
		if _sfx_sel != null and ResourceLoader.exists(HOVER_SFX):
			_sfx_sel.stream = load(HOVER_SFX)
			_sfx_sel.play()
		_refresh()
		return
```

- [ ] **Step 3: Sacar el ESC-cancela-skin (líneas ~1294-1296)**

En la rama `ui_cancel`, borrar el `if skin_picking >= 0: skin_picking = -1; _refresh()`; dejar el resto (cancelar stage, etc.).

- [ ] **Step 4: Borrar la variable + referencias restantes**

- Borrar `var skin_picking := -1` (línea ~11).
- Grep de control: `grep -n "skin_picking" char_select.gd` → debe quedar SOLO en Task 5 (panel), que se ajusta ahí.

- [ ] **Step 5: Compilar**

```bash
godot --headless --import --quit-after 1500 2>&1 | grep -iE "SCRIPT ERROR|Parse Error" | head; echo ok
```

- [ ] **Step 6: Verificar EN JUEGO (usuario)**

- Secuencial: hover Aye, elegir skin con ↑/↓, ENTER → **lockea directo** con esa skin (sin sub-paso ←→). Sigue al rival, luego stage.
- La pelea carga la skin elegida (P1 y rival). Otro personaje: hover→ENTER normal.

- [ ] **Step 7: Commit**

```bash
git add char_select.gd
git commit -m "char-select: ENTER lockea Aye directo con la skin del hover; borra sub-paso skin_picking"
```

---

### Task 5: Indicador de skin en hover (repurpose `_skin_panel`)

**Files:**
- Modify: `char_select.gd` (`_draw` gating del panel ~líneas 954-957; `_skin_panel` ~959; sacar refs a `skin_picking`)

**Interfaces:**
- Consumes: `skin_sel[side]`, hover del roster (`sel1`/`sel2`, `picking`).
- Produces: chip "TUTÚ / OVEROL · ↑↓" visible mientras el cursor está sobre Aye (en vez de solo durante el sub-paso).

- [ ] **Step 1: Gating por HOVER en vez de `skin_picking` (líneas ~954-957)**

Reemplazar las condiciones que activaban el panel por hover sobre Aye:
```gdscript
	if picking < 2 and picking == 0 and String(roster[sel1]["id"]) == "aye":
		_skin_panel(CX_L, 0, RED)
	if picking < 2 and picking == 1 and String(roster[sel2]["id"]) == "aye":
		_skin_panel(CX_R, 1, BLU)
```
(En 2P ambos lados hacen hover a la vez: usar `_vs2p()` para mostrar los dos —seguir el patrón existente de `a1/a2` del código.)

- [ ] **Step 2: Sacar `skin_picking` de `_skin_panel` (línea ~961)**

En `_skin_panel`, cambiar `var active := (skin_picking == side)` por `var active := true` (siempre "activo" en hover) o quitar el resaltado de "eligiendo ahora". Ajustar el texto a incluir "↑↓".

- [ ] **Step 3: Compilar + grep de limpieza**

```bash
godot --headless --import --quit-after 1500 2>&1 | grep -iE "SCRIPT ERROR|Parse Error" | head
grep -n "skin_picking" char_select.gd || echo "skin_picking eliminado del todo ✓"
```
Expected: sin errores y sin `skin_picking` restante.

- [ ] **Step 4: Verificar EN JUEGO (usuario)**

- Hover sobre Aye → aparece el chip con la skin actual y "↑↓"; cambia al togglear. Sobre otro personaje → no aparece.

- [ ] **Step 5: Commit**

```bash
git add char_select.gd
git commit -m "char-select: indicador de skin en hover (reemplaza panel del sub-paso)"
```

---

### Task 6: Verificación integral EN JUEGO (usuario)

- [ ] Checklist (drivea el char-select):
  1. Hover Aye → avatar **animado** de la skin actual.
  2. ↑/↓ → tutú↔overol (avatar **y** chip) en P1, rival y en 2P por lado.
  3. ENTER sobre Aye → lock directo con la skin mostrada, sin sub-paso; entra a la pelea con esa skin.
  4. Otro personaje → hover→ENTER normal, sin paso de skin.
  5. VS 2P → cada lado su skin; entran las dos correctas.
  6. Sin restos del flujo viejo (panel, ←→ de skin, ESC-cancela-skin).

---

## Self-Review

- **Cobertura del spec:** A) avatar animado por skin → Tasks 1-2. B) flujo secuencial (↑/↓ hover + ENTER-lock, sin sub-paso) → Tasks 3-4. C) 2P avatar → Tasks 2-3. Indicador → Task 5. Limpieza → Tasks 4-5. Fuera de alcance (HUD/carga) → no hay tareas (correcto).
- **Placeholders:** ninguno; código real en cada step. La calibración `--target-h 760` de Task 1 puede necesitar 1 ajuste tras ver el tamaño en juego (Step 4 de Task 1 lo chequea).
- **Consistencia de tipos:** `_aye_sel_frames(skin)`, `_set_side(s, id)`, `skin_sel`, `_toggle_color(side)` usados igual en todas las tareas.
