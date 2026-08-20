# Sistema de Orbes de Aye-2 — Plan de Implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Darle a Aye-2 su mecánica firma: 3 orbes de color que orbitan y se usan como boomerang (tap), se plantan (←→+botón) y se llaman de vuelta (recall R), aplicando efectos por color.

**Architecture:** El **árbitro** (`main.gd`, referenciado desde `fighter.gd` como `_mb`) posee un **OrbManager** — por cada fighter `fx_floral` (aye2) crea 3 sprites de orbe y mantiene su estado, los actualiza cada frame y resuelve sus colisiones contra el rival. `fighter.gd` (rama `fx_floral`) solo detecta el input (tap / ←→+botón / R) y llama a métodos del árbitro (`_orb_launch`, `_orb_recall`). Los efectos se aplican con la infra que ya existe: daño por el path de golpes, congelar vía `frozen_t`, maná vía `mana[idx]`.

**Tech Stack:** Godot 4.7, GDScript. Sin framework de tests. `fx_floral` == aye2 (nadie más lo usa).

## Estrategia de verificación (NO hay pytest)

Este proyecto es un juego Godot sin harness de tests y el agente **NO puede lanzar el juego** (regla del usuario: [[no-relanzar-juego]]). Por eso, en cada tarea el "test" son **dos** cosas:
1. **Compila limpio:** `godot --headless --import --quit-after 40` sin `SCRIPT ERROR` ni `Parse Error`. Esto lo corre el agente.
2. **Checkpoint EN JUEGO (usuario):** un punto concreto de la checklist que el usuario prueba y confirma. El agente presenta el checkpoint y espera OK antes de seguir.

Cada tarea termina con: compila limpio → commit → checkpoint del usuario.

## Global Constraints

- `fx_floral` == aye2. TODA la lógica nueva va en ramas `if fx_floral:` (fighter.gd) o gateada por "el fighter es aye2" (main.gd). NO tocar el comportamiento de DAM/Fe/Zetma/Roum.
- El árbitro se accede desde el fighter como `_mb` (ej. `_mb._orb_launch(...)`). Los dos fighters del árbitro son `player` (main.gd:31) y `dummy` (main.gd:32); cada uno tiene su índice de lado 0/1 (el mismo que indexa `mana[idx]`).
- Input por `act(n)` (fighter.gd:549) = `n + input_suffix` (soporta P2). Botones: `act("attack")`, `act("kick")`, `act("spin_kick")`, `act("weak_punch")`. Direcciones: `act("ui_left")`, `act("ui_right")`.
- Los orbes van SIEMPRE como sprite APARTE (no dibujados en los clips del cuerpo). Reusar el arte: `imagen-action/aye-2/orbs-yellow|orbs-pink|orbs-blue` (o `orb_yellow`/`orb_pink`/`orb_blue`). El cuerpo solo hace el gesto (`orb_throw`/`orb_jab`/`orb_e` al lanzar, `orb_push` al recall).
- Cadencia: al sobrescribir/agregar assets, reimportar con `godot --headless --import`.
- Spec de referencia: `docs/superpowers/specs/2026-08-20-aye-orb-system-design.md`.

## Definiciones compartidas (van en main.gd; TODAS las tareas dependen de esto)

Constantes y forma de datos que usan todas las tareas. Se crean en la **Tarea 1** y NO cambian de nombre después:

```gdscript
# --- ORBES DE AYE-2 (mecánica firma) ---
enum { ORB_YELLOW, ORB_PINK, ORB_BLUE }            # índice de color
const ORB_TINT := [Color(1.0, 0.85, 0.25), Color(1.0, 0.45, 0.72), Color(0.4, 0.62, 1.0)]  # 🟡🩷🔵
enum { OST_ORBIT, OST_FLIGHT, OST_PLANT_OUT, OST_PLANTED, OST_RECALL }   # estado del orbe
enum { OMODE_BOOMERANG, OMODE_PLANT }              # modo de un lanzamiento
# tuneables (ver tabla del spec)
const ORB_ORBIT_R := 90.0
const ORB_SPEED := 1400.0
const ORB_RANGE := 1050.0        # boomerang: alcance máx si no toca (~55% de 1920)
const PLANT_DIST := 860.0        # plantar: distancia fija de aterrizaje (~45%)
const PLANT_TIMEOUT := 8.0
const RECALL_HOLD := 0.25
const ORB_DMG_YELLOW := 100
const PLANT_CHIP := 18
const ORB_DMG_BLUE := 45
const ORB_FREEZE_T := 0.8
const MANA_PER_BLUE := 0.12

# un "set" por fighter aye2 (lista global). Forma de cada elemento:
#   { "owner": Node2D, "idx": int, "sprites": Array,   # 3 Sprite2D/AnimatedSprite2D
#     "orbs": Array,                                    # 3 dicts (ver abajo), índice = color
#     "plant_order": Array,                             # colores plantados, viejo->nuevo (FIFO)
#     "recall_held_t": float }
# forma de cada orb dict (orbs[color]):
#   { "state": int, "pos": Vector2, "vel": Vector2, "world_pos": Vector2,
#     "age": float, "hit_done": bool, "orbit_ang": float, "mode": int }
var orb_sets := []
```

**Interfaz del OrbManager** (métodos en main.gd que consume fighter.gd y las tareas siguientes):
- `_orb_setup_for(owner: Node2D, idx: int) -> void` — crea el set (3 sprites + 3 orbs en OST_ORBIT).
- `_orb_set_for(owner: Node2D) -> Dictionary` — devuelve el set de ese fighter (o `{}` si no tiene).
- `_orb_update(delta: float) -> void` — avanza todos los sets un frame.
- `_orb_launch(owner: Node2D, color: int, mode: int) -> void` — si `orbs[color].state == OST_ORBIT`, lo pone en FLIGHT (boomerang) o PLANT_OUT (plant).
- `_orb_recall(owner: Node2D, count: int) -> void` — pasa los `count` plantados más viejos a OST_RECALL.

---

### Task 1: OrbManager base — los 3 orbes orbitan a Aye

**Files:**
- Modify: `main.gd` — agregar el bloque "Definiciones compartidas" (arriba), `_orb_setup_for`, `_orb_set_for`, `_orb_update` (solo estados ORBIT por ahora), y las llamadas de setup + update.

**Interfaces:**
- Produces: `orb_sets`, `_orb_setup_for`, `_orb_set_for`, `_orb_update` (con las firmas de "Definiciones compartidas").

- [ ] **Step 1: Pegar las Definiciones compartidas** (constantes + `var orb_sets := []`) cerca de las otras vars de estado de main.gd (p.ej. después de la sección de MANA, main.gd:~72).

- [ ] **Step 2: `_orb_setup_for`** — crea 3 sprites tintados y el estado en órbita.

```gdscript
func _orb_setup_for(owner: Node2D, idx: int) -> void:
    if _orb_set_for(owner):
        return
    var sprites := []
    var orbs := []
    for c in 3:
        var s := Sprite2D.new()
        # arte del orbe (1 esfera neutra; el tinte lo da modulate). Usa el 1er frame de la hoja.
        var tex_path := "res://imagen-action/aye-2/orb_%s/aye2-orb_%s-1.png" % [_orb_name(c), _orb_name(c)]
        if ResourceLoader.exists(tex_path):
            s.texture = load(tex_path)
        s.modulate = ORB_TINT[c]
        s.z_index = 5
        add_child(s)
        sprites.append(s)
        orbs.append({ "state": OST_ORBIT, "pos": Vector2.ZERO, "vel": Vector2.ZERO,
            "world_pos": Vector2.ZERO, "age": 0.0, "hit_done": false,
            "orbit_ang": TAU * float(c) / 3.0, "mode": OMODE_BOOMERANG })
    orb_sets.append({ "owner": owner, "idx": idx, "sprites": sprites, "orbs": orbs,
        "plant_order": [], "recall_held_t": 0.0 })

func _orb_name(c: int) -> String:
    return ["yellow", "pink", "blue"][c]

func _orb_set_for(owner: Node2D) -> Dictionary:
    for st in orb_sets:
        if st["owner"] == owner:
            return st
    return {}
```

- [ ] **Step 3: `_orb_update` (solo ORBIT)** — orbitan alrededor del owner; mostrar/posicionar sprites.

```gdscript
func _orb_update(delta: float) -> void:
    for st in orb_sets:
        var owner: Node2D = st["owner"]
        var center: Vector2 = owner.global_position + Vector2(0, -120)   # a la altura del torso
        for c in 3:
            var o: Dictionary = st["orbs"][c]
            var spr: Sprite2D = st["sprites"][c]
            match o["state"]:
                OST_ORBIT:
                    o["orbit_ang"] += delta * 1.4
                    o["pos"] = center + Vector2(cos(o["orbit_ang"]), sin(o["orbit_ang"]) * 0.5) * ORB_ORBIT_R
                    spr.visible = true
                _:
                    pass   # otros estados: Tareas 2-4
            spr.global_position = o["pos"]
```

- [ ] **Step 4: Llamar setup cuando arranca una Aye-2** — donde el árbitro termina de aplicar los personajes (busca dónde se setean `player`/`dummy` con su char; cerca de `hp_max[0] = ...`, main.gd:~398). Para cada fighter cuyo flag `fx_floral` sea true:

```gdscript
if player.fx_floral:
    _orb_setup_for(player, 0)
if dummy.fx_floral:
    _orb_setup_for(dummy, 1)
```

- [ ] **Step 5: Llamar `_orb_update(delta)`** desde el `_physics_process`/`_process` del árbitro (donde ya corre la lógica de combate por frame). Añadir `_orb_update(delta)`.

- [ ] **Step 6: Compila limpio**

Run: `godot --headless --import --quit-after 40 2>&1 | grep -iE "SCRIPT ERROR|Parse Error"`
Expected: sin salida.

- [ ] **Step 7: Commit**

```bash
git add main.gd
git commit -m "aye orbs: OrbManager base — 3 orbes color orbitan a Aye"
```

- [ ] **Step 8: CHECKPOINT (usuario)** — En juego con Aye: se ven **3 orbes 🟡🩷🔵 orbitando** su torso, siguiéndola. No afecta a otros personajes.

---

### Task 2: Boomerang (tap color) + efectos

**Files:**
- Modify: `main.gd` — extender `_orb_update` con OST_FLIGHT; agregar `_orb_launch`, `_orb_apply_effect`, `_orb_hits_target`.
- Modify: `fighter.gd` — en la rama `fx_floral`, detectar el tap de botón de color y llamar `_mb._orb_launch(self, color, OMODE_BOOMERANG)` en el `hit_frame` del gesto; y NEUTRALIZAR el golpe melee de esos gestos (el orbe es quien pega).

**Interfaces:**
- Consumes: `_orb_set_for`, estados/constantes de Task 1.
- Produces: `_orb_launch(owner, color, mode)`, `_orb_apply_effect(st, color, full)`, `_orb_hits_target(st, o) -> Node2D`.

- [ ] **Step 1: Mapeo botón→color→gesto** (referencia, no es código): `attack`→🟡`orb_throw` · `kick`→🩷`orb_jab` · `spin_kick`→🔵`orb_e` · `weak_punch`→recall`orb_push`. (Coincide con el atk_map actual.)

- [ ] **Step 2: `_orb_launch`** (main.gd) — arranca el viaje si el orbe está en órbita.

```gdscript
func _orb_launch(owner: Node2D, color: int, mode: int) -> void:
    var st := _orb_set_for(owner)
    if st.is_empty():
        return
    var o: Dictionary = st["orbs"][color]
    if o["state"] != OST_ORBIT:
        return   # ese color no está disponible (en vuelo o plantado)
    var dir := 1.0 if owner.facing > 0 else -1.0
    o["state"] = OST_FLIGHT
    o["mode"] = mode
    o["hit_done"] = false
    o["vel"] = Vector2(dir * ORB_SPEED, 0.0)
    o["age"] = 0.0
    # arranca desde la posición actual (órbita)
```

- [ ] **Step 3: `_orb_update` OST_FLIGHT** — viaja hasta ORB_RANGE y vuelve; golpea una vez a la ida.

```gdscript
OST_FLIGHT:
    o["pos"] += o["vel"] * delta
    o["age"] += delta
    if not o["hit_done"]:
        var tgt := _orb_hits_target(st, o)
        if tgt != null:
            _orb_apply_effect(st, c, true)   # boomerang = efecto FULL
            o["hit_done"] = true
    # a ORB_RANGE del owner, invierte hacia Aye; al reencontrarse, vuelve a órbita
    var out_dist: float = absf(o["pos"].x - center.x)
    if o["vel"].x != 0.0 and sign(o["vel"].x) == sign(o["pos"].x - center.x) and out_dist >= ORB_RANGE:
        o["vel"] = -o["vel"]                 # empieza a volver
    elif sign(o["vel"].x) != sign((o["pos"].x - center.x)) and absf(o["pos"].x - center.x) < 40.0:
        o["state"] = OST_ORBIT               # llegó de vuelta -> re-orbita
    spr.global_position = o["pos"]
```

- [ ] **Step 4: `_orb_hits_target` + `_orb_apply_effect`** — colisión AABB contra el rival y aplicación de efecto.

```gdscript
func _orb_hits_target(st: Dictionary, o: Dictionary) -> Node2D:
    var owner: Node2D = st["owner"]
    var tgt: Node2D = dummy if owner == player else player   # el rival
    if tgt == null or tgt.get("koed"):
        return null
    var hw: float = float(tgt.get("body_halfw"))
    var cx: float = tgt.global_position.x
    var cy: float = tgt.global_position.y
    if absf(o["pos"].x - cx) <= hw + 40.0 and o["pos"].y >= cy - 300.0 and o["pos"].y <= cy + 20.0:
        return tgt
    return null

func _orb_apply_effect(st: Dictionary, color: int, full: bool) -> void:
    var owner: Node2D = st["owner"]
    var tgt: Node2D = dummy if owner == player else player
    if tgt == null:
        return
    if not full:
        tgt.receive_hit(PLANT_CHIP, owner)   # golpe de ida al plantar: chip, SIN efecto
        return
    match color:
        ORB_YELLOW: tgt.receive_hit(ORB_DMG_YELLOW, owner)
        ORB_PINK:   tgt.receive_hit(ORB_DMG_BLUE, owner); tgt.frozen_t = ORB_FREEZE_T   # congela
        ORB_BLUE:   tgt.receive_hit(ORB_DMG_BLUE, owner); mana[st["idx"]] = minf(1.0, mana[st["idx"]] + MANA_PER_BLUE)
```

> **Nota de integración:** `receive_hit(dmg, atacante)` y `frozen_t` deben coincidir con la API real. Verificá la firma real de cómo se aplica daño (buscá cómo el árbitro pega los golpes melee que salen de `current_attack`, fighter.gd:1212) y cómo se setea el congelado (`frozen_t`, fighter.gd:487). Si `receive_hit` no existe con esa firma, usá el mismo método que usa el árbitro para el daño melee. Ajustá estas 4 líneas a la API real ANTES de seguir.

- [ ] **Step 5: Hook del input en fighter.gd (rama fx_floral)** — al reproducir el gesto de color, disparar el orbe UNA vez en su `hit_frame`. Buscá dónde se lee el tap de ataque para aye2 (los botones `act("attack")`/`act("kick")`/`act("spin_kick")` que hoy lanzan orb_throw/orb_jab/orb_e). Cuando la anim del gesto llega a su hit_frame y aún no disparó este ciclo:

```gdscript
# dentro de la lógica por-frame de fx_floral, cuando toca disparar el gesto de color:
if fx_floral and _mb != null and not _orb_fired and sprite.frame >= _orb_hit_frame_for(sprite.animation):
    var col := _orb_color_for(sprite.animation)   # orb_throw->0, orb_jab->1, orb_e->2, else -1
    if col >= 0:
        var mode := OMODE_PLANT if _orb_plant_buffered() else OMODE_BOOMERANG
        _mb._orb_launch(self, col, mode)
        _orb_fired = true
```
Con helpers en fighter.gd:
```gdscript
var _orb_fired := false   # resetear a false en _on_animation_changed cuando entra un gesto de orbe
func _orb_color_for(anim: String) -> int:
    return {"orb_throw": 0, "orb_jab": 1, "orb_e": 2}.get(anim, -1)
func _orb_hit_frame_for(anim: String) -> int:
    return 6   # tuneable: el frame del gesto donde "suelta" el orbe
func _orb_plant_buffered() -> bool:
    return false   # Tarea 3 lo implementa (por ahora siempre boomerang)
```
Resetear `_orb_fired = false` en `_on_animation_changed` cuando `nombre` es un gesto de orbe.

- [ ] **Step 6: Neutralizar el melee de los gestos de orbe** — en la rama `if fx_floral and sprite.animation in ATTACKS` (fighter.gd:1212), para `orb_throw`/`orb_jab`/`orb_e` el árbitro NO debe pegar melee (el orbe pega). Devolver un dict con `reach` 0 o `damage` 0 para esos gestos (o saltarlos), así no hay doble golpe.

```gdscript
if fx_floral and sprite.animation in ATTACKS and sprite.is_playing():
    if sprite.animation in ["orb_throw", "orb_jab", "orb_e"]:
        return {}   # el ORBE hace el daño, no el melee
    # ... (resto igual)
```
> Verificá que devolver `{}` = "sin golpe activo" en el consumidor de `current_attack`. Si no, usá el patrón que ya exista para "gesto sin hit".

- [ ] **Step 7: Compila limpio** (`godot --headless --import --quit-after 40 | grep -iE "SCRIPT ERROR|Parse Error"` → sin salida).

- [ ] **Step 8: Commit**

```bash
git add main.gd fighter.gd
git commit -m "aye orbs: boomerang (tap color) + efectos 🟡daño/🩷congela/🔵maná"
```

- [ ] **Step 9: CHECKPOINT (usuario)** — Tap Q/W/E: el orbe del color SALE, cruza al rival golpeando (🟡 daño, 🩷 congela ~0.8s, 🔵 +maná) y VUELVE a la órbita. El gesto del cuerpo acompaña. No hay doble golpe (melee+orbe).

---

### Task 3: Plantar (←→ + color)

**Files:**
- Modify: `main.gd` — `_orb_update` OST_PLANT_OUT y OST_PLANTED (con timeout).
- Modify: `fighter.gd` — implementar `_orb_plant_buffered()` con la detección ←→ (reusa `back_recent_t`).

**Interfaces:**
- Consumes: `_orb_launch(owner, color, OMODE_PLANT)`, estados de Task 1-2.
- Produces: estados PLANT_OUT/PLANTED en `_orb_update`; `plant_order` poblado.

- [ ] **Step 1: `_orb_plant_buffered()` en fighter.gd** — true si hubo un ←→ reciente (atrás y luego adelante) en la ventana. Reusa `back_recent_t` (fighter.gd:397, memoria de "atrás reciente"):

```gdscript
func _orb_plant_buffered() -> bool:
    # back_recent_t > 0 = tocó ATRÁS hace poco; si AHORA mantiene/tocó ADELANTE => motion ←→
    var fwd := Input.is_action_pressed(act("ui_right")) if facing > 0 else Input.is_action_pressed(act("ui_left"))
    return back_recent_t > 0.0 and fwd
```
> Confirmá que `back_recent_t` se setea al tocar atrás (ya lo usa el dash de Fe/DAM). Si la ventana es muy corta, subí su duración donde se setea (tuneable).

- [ ] **Step 2: `_orb_update` OST_PLANT_OUT** (main.gd) — viaja PLANT_DIST, chip a la ida, se planta.

```gdscript
OST_PLANT_OUT:
    o["pos"] += o["vel"] * delta
    o["age"] += delta
    if not o["hit_done"]:
        if _orb_hits_target(st, o) != null:
            _orb_apply_effect(st, c, false)   # ida al plantar = CHIP, sin efecto
            o["hit_done"] = true
    if absf(o["pos"].x - center.x) >= PLANT_DIST:
        o["state"] = OST_PLANTED
        o["world_pos"] = o["pos"]
        o["age"] = 0.0
        if not st["plant_order"].has(c):
            st["plant_order"].append(c)     # FIFO para el recall de a 1
    spr.global_position = o["pos"]
```

- [ ] **Step 3: `_orb_update` OST_PLANTED** — flota fijo con bob; a PLANT_TIMEOUT auto-recall.

```gdscript
OST_PLANTED:
    o["age"] += delta
    o["pos"] = o["world_pos"] + Vector2(0, sin(o["age"] * 3.0) * 8.0)   # bob leve
    spr.global_position = o["pos"]
    if o["age"] >= PLANT_TIMEOUT:
        _orb_recall(owner, 1)   # auto-vuelve el más viejo (este entra en la cola)
```
> `_orb_launch` en modo PLANT: reusa el Step 2 de Task 2 pero setea `o["state"] = OST_PLANT_OUT` en vez de OST_FLIGHT cuando `mode == OMODE_PLANT`. Ajustar `_orb_launch`:
```gdscript
o["state"] = OST_PLANT_OUT if mode == OMODE_PLANT else OST_FLIGHT
```

- [ ] **Step 4: Compila limpio.**

- [ ] **Step 5: Commit**

```bash
git add main.gd fighter.gd
git commit -m "aye orbs: plantar (←→+color) — viaja PLANT_DIST, chip, se queda plantado + timeout"
```

- [ ] **Step 6: CHECKPOINT (usuario)** — `←→+Q/W/E`: el orbe viaja, pega LIGERO (sin congelar), y se **queda plantado** flotando (podés plantarlo pasado el rival). Ese color ya no sale con tap. A los ~8s auto-vuelve a la órbita.

---

### Task 4: Recall (R tap = 1 FIFO / hold = 3)

**Files:**
- Modify: `main.gd` — `_orb_recall`; `_orb_update` OST_RECALL.
- Modify: `fighter.gd` — leer `weak_punch` (R): tap = recall 1, hold ≥ RECALL_HOLD = recall 3.

**Interfaces:**
- Consumes: `plant_order`, estados PLANTED de Task 3.
- Produces: `_orb_recall(owner, count)`; OST_RECALL en `_orb_update`.

- [ ] **Step 1: `_orb_recall`** (main.gd) — pasa los `count` plantados más viejos a RECALL.

```gdscript
func _orb_recall(owner: Node2D, count: int) -> void:
    var st := _orb_set_for(owner)
    if st.is_empty():
        return
    var n := 0
    while n < count and not st["plant_order"].is_empty():
        var c: int = st["plant_order"].pop_front()   # FIFO: el más viejo
        var o: Dictionary = st["orbs"][c]
        if o["state"] == OST_PLANTED:
            o["state"] = OST_RECALL
            o["hit_done"] = false
        n += 1
```

- [ ] **Step 2: `_orb_update` OST_RECALL** — vuela desde world_pos hacia Aye, golpe FULL al cruzar, re-orbita al llegar.

```gdscript
OST_RECALL:
    var to_owner: Vector2 = center - o["pos"]
    o["pos"] += to_owner.normalized() * ORB_SPEED * delta
    if not o["hit_done"] and _orb_hits_target(st, o) != null:
        _orb_apply_effect(st, c, true)   # recall = efecto FULL
        o["hit_done"] = true
    if o["pos"].distance_to(center) < 40.0:
        o["state"] = OST_ORBIT            # llegó -> disponible de nuevo
    spr.global_position = o["pos"]
```

- [ ] **Step 3: Input R en fighter.gd (rama fx_floral)** — tap vs hold de `weak_punch`.

```gdscript
# en la lógica por-frame de fx_floral:
if fx_floral and _mb != null:
    if Input.is_action_pressed(act("weak_punch")):
        _orb_recall_held += get_physics_process_delta_time()
    elif _orb_recall_held > 0.0:
        # se soltó: si fue hold largo ya se llamaron los 3 abajo; si fue tap, llamar 1
        if _orb_recall_held < 0.0:   # marcado como ya-disparado el hold
            pass
        else:
            _mb._orb_recall(self, 1)
        _orb_recall_held = 0.0
    if _orb_recall_held >= 0.25 and _orb_recall_held > 0.0:   # RECALL_HOLD
        _mb._orb_recall(self, 3)
        _orb_recall_held = -1.0      # marca "ya disparó los 3", evita el tap al soltar
```
Con `var _orb_recall_held := 0.0` en fighter.gd. Reproducir el gesto `orb_push` (recall) al disparar cualquiera de los dos recalls.
> Ajustá si `weak_punch` ya hace otra cosa para aye2: el recall tiene prioridad SOLO si hay orbes plantados (`_mb._orb_set_for(self)["plant_order"]` no vacío); si no hay plantados, dejá el comportamiento normal de `weak_punch`.

- [ ] **Step 4: Compila limpio.**

- [ ] **Step 5: Commit**

```bash
git add main.gd fighter.gd
git commit -m "aye orbs: recall (R tap=1 FIFO / hold=3) — vuelan y golpean full al volver"
```

- [ ] **Step 6: CHECKPOINT (usuario)** — Con orbes plantados: `R tap` llama al **más viejo** (vuela hacia Aye cruzando al rival con efecto full) y re-orbita; `R hold` llama **los 3**. Sin plantados, R no molesta el juego normal.

---

### Task 5: HUD de orbes + carga de maná

**Files:**
- Modify: `main.gd` — dibujar 3 chips de estado de orbe cerca del retrato de Aye (en la capa/rutina de HUD donde ya se dibuja el anillo de maná, main.gd:~3793/3896). El maná del 🔵 ya lo suma `_orb_apply_effect` (Task 2).

**Interfaces:**
- Consumes: `orb_sets`, estados de Task 1-4, `mana`.

- [ ] **Step 1: `_orb_hud_draw`** — 3 chips por lado que hace hover Aye: lleno=órbita, contorno=plantado, parpadeo=en vuelo.

```gdscript
func _orb_hud_draw(ci: CanvasItem) -> void:
    for st in orb_sets:
        var base: Vector2 = Vector2(70, 150) if st["idx"] == 0 else Vector2(1920 - 70 - 3 * 34, 150)
        for c in 3:
            var o: Dictionary = st["orbs"][c]
            var p := base + Vector2(c * 34, 0)
            var col: Color = ORB_TINT[c]
            match o["state"]:
                OST_ORBIT:   ci.draw_circle(p, 12, col)                       # lleno
                OST_PLANTED: ci.draw_arc(p, 12, 0, TAU, 20, col, 2.0)         # contorno
                _:           ci.draw_circle(p, 12, Color(col.r, col.g, col.b, 0.4 + 0.4 * sin(_hud_t * 8.0)))  # parpadeo
```
Llamar `_orb_hud_draw(<el CanvasItem del HUD>)` desde el `_draw` del HUD (donde se dibuja el anillo de maná). `_hud_t` = un acumulador de tiempo que ya exista, o sumar `delta` a una var.

- [ ] **Step 2: Verificar que el maná sube** — ya se suma en `_orb_apply_effect` (ORB_BLUE). Confirmar que `mana[idx]` es el mismo índice que lee el anillo (main.gd:3896). Sin cambios si ya coincide.

- [ ] **Step 3: Compila limpio.**

- [ ] **Step 4: Commit**

```bash
git add main.gd
git commit -m "aye orbs: HUD de estado de los 3 orbes (órbita/plantado/vuelo)"
```

- [ ] **Step 5: CHECKPOINT (usuario)** — El HUD muestra los 3 orbes 🟡🩷🔵 y su estado (lleno=órbita, contorno=plantado, parpadeo=vuelo). El 🔵 al golpear sube la barra de maná.

---

### Task 6 (OPCIONAL): IA mínima — la CPU-Aye tira boomerangs

**Files:**
- Modify: `fighter.gd` — en la rama de IA (`ai_enabled`) de aye2, tirar boomerangs de color a media distancia.

**Interfaces:**
- Consumes: `_mb._orb_launch(self, color, OMODE_BOOMERANG)`.

- [ ] **Step 1:** En la lógica de IA de aye2 (buscá la rama `if ai_enabled` / el árbol de decisión de la CPU), cuando el rival está a distancia media y hay cooldown listo, elegir un color al azar por índice (variar por `int(age*7) % 3`, NO `randi`) y `_mb._orb_launch(self, color, OMODE_BOOMERANG)` reproduciendo el gesto. Plantar+recall por IA queda fuera (no bloqueante).

- [ ] **Step 2: Compila limpio → Commit → CHECKPOINT** — La CPU-Aye tira boomerangs de vez en cuando; no rompe la IA existente.

---

## Self-Review (contra el spec)

**1. Cobertura del spec:**
- 3 orbes color orbitando → Task 1 ✓ · HUD de estado → Task 5 ✓
- Boomerang (tap) + efectos 🟡🩷🔵 → Task 2 ✓
- Plantar (←→+color), chip sin efecto, timeout 8s, sale de órbita → Task 3 ✓
- Recall (R tap=1 FIFO / hold=3), golpe full al volver → Task 4 ✓
- Maná: 🔵 carga, alimenta súper (fuera de alcance) → Task 2 (suma) + Task 5 (barra) ✓
- Súper / victory-HUD / netcode → fuera de alcance (no hay tareas) ✓
- IA: boomerangs → Task 6 (opcional, como dice el spec) ✓
- Rama `fx_floral` aislada → Global Constraints + cada task ✓

**2. Placeholders:** los `> Nota/Verificá` son puntos de integración con la API real (receive_hit/frozen_t/current-attack consumer/back_recent_t/IA), no placeholders vagos — cada uno dice qué anclaje mirar y qué ajustar. Valores tuneables tienen número concreto de arranque.

**3. Consistencia de tipos:** `_orb_launch(owner,color,mode)`, `_orb_recall(owner,count)`, `_orb_set_for(owner)`, `_orb_apply_effect(st,color,full)`, `_orb_hits_target(st,o)`, forma del orb dict y del set — idénticos en todas las tareas. Estados OST_*/OMODE_* y constantes definidos una vez en Task 1. ✓
