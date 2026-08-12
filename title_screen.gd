extends Control
# PANTALLA PRINCIPAL (main_scene). Fondo = póster DAM vs FE a pantalla completa
# (res://imagen-action/ui/menu-bg.png). Menú abajo-centro sobre un velo oscuro, con la
# tipografía pesada del juego. Sin título (el póster manda). VS CPU / TRAINING / VS ONLINE.

const OPTS := ["VS CPU", "TRAINING", "COMBOS", "VS ONLINE"]
const MODES := ["vs_cpu", "practice", "combos", ""]   # "" = deshabilitado; "combos" = abre el panel de combos
const RED := Color(0.95, 0.24, 0.20)
const GOLD := Color(0.98, 0.84, 0.32)
# FRAMES FINALES del título ya compuestos (tormenta + personajes fusionados). Ciclarlos =
# relámpagos animados, sin depender de transparencia ni de la caché de importación.
const STORM_FRAMES := [
	"res://imagen-action/ui/title-storm-1.png", "res://imagen-action/ui/title-storm-2.png",
	"res://imagen-action/ui/title-storm-3.png", "res://imagen-action/ui/title-storm-4.png",
	"res://imagen-action/ui/title-storm-5.png", "res://imagen-action/ui/title-storm-6.png",
]

var sel := 0
var has_bg := false
var big_font: SystemFont
var body_font: SystemFont          # fuente del panel de combos (mono, para alinear las flechas)
var combos_root: Control = null    # panel de COMBOS (overlay a pantalla completa)
var opt_labels := []
var fx: Control
var t := 0.0
# --- RELÁMPAGOS: un solo fondo que cicla los frames de tormenta con destellos ---
var sky_node: TextureRect
var flash_node: ColorRect
var light_frames: Array = []
var strike_t := 0.0        # tiempo restante del destello en curso
var strike_dur := 0.0      # duración total del destello en curso
var next_strike := 1.4     # cuenta atrás hasta el próximo relámpago
const SKY_BASE := Color(1.0, 1.0, 1.0, 1.0)   # brillo base del fondo (la tormenta ya viene apagada)

# posición del menú (abajo-centro)
const OPT_Y0 := 706.0
const OPT_DY := 96.0

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	Sel.play_menu_music()   # canción del menú (loop, persiste al pasar al char-select)
	big_font = SystemFont.new()
	big_font.font_names = PackedStringArray(["Arial Black", "Impact", "Helvetica Neue", "Arial"])
	big_font.font_weight = 900
	body_font = SystemFont.new()
	body_font.font_names = PackedStringArray(["Menlo", "Consolas", "Courier New", "Arial"])
	# FONDO: frames de tormenta ya compuestos (DAM vs Fe + relámpagos). Se ciclan para animar.
	for p in STORM_FRAMES:
		if ResourceLoader.exists(p):
			light_frames.append(load(p))
	has_bg = not light_frames.is_empty()
	if has_bg:
		var sky := TextureRect.new()
		sky.texture = light_frames[0]
		sky.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sky.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		sky.set_anchors_preset(Control.PRESET_FULL_RECT)
		sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sky.modulate = SKY_BASE
		add_child(sky)
		sky_node = sky
		# DESTELLO del rayo: ilumina toda la escena (sobre el fondo, debajo del menú).
		var fl := ColorRect.new()
		fl.color = Color(0.82, 0.9, 1.0, 0.0)      # blanco-azulado, como un flash de tormenta
		fl.set_anchors_preset(Control.PRESET_FULL_RECT)
		fl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(fl)
		flash_node = fl
	# capa fx: velo + placa del seleccionado (encima del fondo, debajo de los labels)
	fx = Control.new()
	fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fx)
	fx.draw.connect(_draw_fx)
	# opciones (abajo-centro) con la fuente pesada + outline
	for i in OPTS.size():
		var o := Label.new()
		o.add_theme_font_override("font", big_font)
		o.add_theme_font_size_override("font_size", 60)
		o.add_theme_constant_override("outline_size", 12)
		o.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		o.position = Vector2(0, OPT_Y0 + i * OPT_DY); o.size = Vector2(1920, 84)
		o.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		o.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(o)
		opt_labels.append(o)
	var hint := Label.new()
	hint.add_theme_font_override("font", big_font)
	hint.add_theme_font_size_override("font_size", 24)
	hint.add_theme_constant_override("outline_size", 6)
	hint.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	hint.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	hint.text = "↑ ↓  SELECCIONAR      ENTER / Z  CONFIRMAR"
	hint.position = Vector2(0, 1012); hint.size = Vector2(1920, 40)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint)
	# PANEL DE COMBOS (overlay, oculto hasta que se elige "COMBOS")
	combos_root = Control.new()
	combos_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	combos_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	combos_root.z_index = 5
	combos_root.visible = false
	combos_root.draw.connect(_draw_combos)
	add_child(combos_root)
	_refresh()

func _refresh() -> void:
	for i in OPTS.size():
		var disabled: bool = MODES[i] == ""
		var base := Color(0.55, 0.55, 0.6) if disabled else Color(0.92, 0.92, 0.96)
		opt_labels[i].add_theme_color_override("font_color", GOLD if i == sel else base)
		var txt: String = OPTS[i]
		if disabled:
			txt += "   ( COMING SOON )"
		opt_labels[i].text = txt
	queue_redraw()

# ---------- fondo (velo + logo temporal si no hay póster) ----------
func _draw() -> void:
	var w := 1920.0
	var h := 1080.0
	if not has_bg:
		# sin póster: fondo oscuro + speedlines + logo temporal
		draw_rect(Rect2(0, 0, w, h), Color(0.06, 0.02, 0.06))
		for i in range(-2, 24):
			var x := i * 92.0
			draw_line(Vector2(x, 0), Vector2(x - 230, h), Color(0.85, 0.3, 0.3, 0.05), 2.0)
		draw_rect(Rect2(500, 120, 920, 240), Color(0.75, 0.13, 0.11, 0.16))
		draw_line(Vector2(500, 120), Vector2(1420, 120), RED, 6.0)
		draw_line(Vector2(500, 360), Vector2(1420, 360), RED, 6.0)
		for cx in [500.0, 1414.0]:
			for cy in [120.0, 350.0]:
				draw_rect(Rect2(cx, cy, 6, 10), GOLD)
		_draw_center("FG FIGHTER", 300.0, 150, Color(0.06, 0.0, 0.0, 0.85), 14.0)
		_draw_center("FG FIGHTER", 286.0, 150, RED, 0.0)
		_draw_center("— T E M P L E   D U E L —", 350.0, 30, GOLD, 0.0)
	# VELO degradado abajo (para que el menú se lea sobre el póster)
	var top := 540.0
	var steps := 40
	for i in steps:
		var y := top + (h - top) * float(i) / float(steps)
		var a: float = lerpf(0.0, 0.82, float(i) / float(steps))
		draw_rect(Rect2(0, y, w, (h - top) / float(steps) + 1.0), Color(0.02, 0.01, 0.03, a))
	# filos rojos que enmarcan la franja del menú (como tu boceto)
	draw_line(Vector2(0, OPT_Y0 - 26), Vector2(w, OPT_Y0 - 26), Color(0.85, 0.1, 0.1, 0.85), 3.0)
	draw_line(Vector2(0, OPT_Y0 + OPTS.size() * OPT_DY - 8), Vector2(w, OPT_Y0 + OPTS.size() * OPT_DY - 8), Color(0.85, 0.1, 0.1, 0.85), 3.0)

func _draw_center(txt: String, baseline_y: float, size: int, col: Color, off: float) -> void:
	var tw := big_font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_string(big_font, Vector2(960 - tw / 2 + off, baseline_y + off), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)

# ---------- placa/glow del seleccionado ----------
func _draw_fx() -> void:
	if opt_labels.is_empty():
		return
	var pulse := 0.55 + 0.45 * sin(t * 6.0)
	var cy := OPT_Y0 + sel * OPT_DY + 42.0
	fx.draw_colored_polygon(PackedVector2Array([Vector2(470, cy - 46), Vector2(1450, cy - 50), Vector2(1450, cy + 50), Vector2(470, cy + 46)]),
			Color(GOLD.r, GOLD.g, GOLD.b, 0.16 * pulse))
	fx.draw_line(Vector2(470, cy - 46), Vector2(1450, cy - 50), Color(GOLD.r, GOLD.g, GOLD.b, 0.85 * pulse), 3.0)
	fx.draw_line(Vector2(470, cy + 46), Vector2(1450, cy + 50), Color(GOLD.r, GOLD.g, GOLD.b, 0.85 * pulse), 3.0)
	fx.draw_string(big_font, Vector2(510, cy + 18), "▶", HORIZONTAL_ALIGNMENT_LEFT, -1, 40, Color(GOLD.r, GOLD.g, GOLD.b, pulse))
	fx.draw_string(big_font, Vector2(1370, cy + 18), "◀", HORIZONTAL_ALIGNMENT_LEFT, -1, 40, Color(GOLD.r, GOLD.g, GOLD.b, pulse))

func _process(delta: float) -> void:
	t += delta
	if fx:
		fx.queue_redraw()
	_lightning(delta)

# RELÁMPAGOS intermitentes: el cielo de tormenta descansa apagado y, cada cierto tiempo,
# CAE un rayo -> cambia el patrón (otro claude-N), el cielo se ILUMINA con parpadeo y un
# destello a pantalla completa; luego se asienta hasta el próximo.
func _lightning(delta: float) -> void:
	if sky_node == null or light_frames.is_empty():
		return
	if strike_t > 0.0:
		strike_t -= delta
		var prog := 1.0 - strike_t / strike_dur                 # 0 -> 1
		var env := sin(prog * PI)                               # 0 -> 1 -> 0 (envolvente)
		var flick := 1.0 if (int(prog * 38.0) % 2 == 0) else 0.55   # parpadeo eléctrico
		var b := 1.0 + 0.85 * env * flick                      # el fogonazo ilumina la escena
		sky_node.modulate = Color(b, b, minf(b * 1.05, 2.2), 1.0)
		if flash_node:
			flash_node.color.a = 0.26 * env * flick
	else:
		sky_node.modulate = sky_node.modulate.lerp(SKY_BASE, minf(delta * 5.0, 1.0))
		if flash_node and flash_node.color.a > 0.0:
			flash_node.color.a = maxf(0.0, flash_node.color.a - delta * 3.5)
		next_strike -= delta
		if next_strike <= 0.0:
			sky_node.texture = light_frames[randi() % light_frames.size()]   # nuevo patrón de rayo
			strike_dur = randf_range(0.26, 0.5)                # dura el fogonazo
			strike_t = strike_dur
			next_strike = randf_range(1.4, 3.6)                # pausa hasta el siguiente

func _unhandled_input(_e: InputEvent) -> void:
	# PANEL DE COMBOS abierto: cualquier tecla lo cierra (no navega el menú)
	if combos_root != null and combos_root.visible:
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel") \
				or Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("kick") \
				or Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
			combos_root.visible = false
		return
	if Input.is_action_just_pressed("ui_up"):
		sel = posmod(sel - 1, OPTS.size()); _refresh()
	elif Input.is_action_just_pressed("ui_down"):
		sel = posmod(sel + 1, OPTS.size()); _refresh()
	elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack"):
		if MODES[sel] == "":
			return
		if MODES[sel] == "combos":            # abre el panel de combos (no cambia de escena)
			combos_root.visible = true
			combos_root.queue_redraw()
			return
		Sel.mode = MODES[sel]
		get_tree().change_scene_to_file("res://char_select.tscn")

# ---------- PANEL DE COMBOS ----------
func _draw_combos() -> void:
	var cr := combos_root
	var PURPLE := Color(0.75, 0.55, 1.0)
	var WHITE := Color(0.95, 0.95, 1.0)
	var GRAY := Color(0.72, 0.72, 0.8)
	# velo casi opaco + panel con marco dorado
	cr.draw_rect(Rect2(0, 0, 1920, 1080), Color(0.02, 0.01, 0.04, 0.92))
	var px := 230.0; var py := 66.0; var pw := 1460.0; var ph := 948.0
	cr.draw_rect(Rect2(px, py, pw, ph), Color(0.07, 0.05, 0.11, 0.98))
	var gline := Color(GOLD.r, GOLD.g, GOLD.b, 0.85)
	cr.draw_line(Vector2(px, py), Vector2(px + pw, py), gline, 3.0)
	cr.draw_line(Vector2(px, py + ph), Vector2(px + pw, py + ph), gline, 3.0)
	cr.draw_line(Vector2(px, py), Vector2(px, py + ph), gline, 3.0)
	cr.draw_line(Vector2(px + pw, py), Vector2(px + pw, py + ph), gline, 3.0)
	# título
	cr.draw_string(big_font, Vector2(px + 50, py + 86), "COMBOS", HORIZONTAL_ALIGNMENT_LEFT, -1, 58, GOLD)
	var x := px + 56.0
	var y := py + 156.0
	# escalera (todos)
	cr.draw_string(big_font, Vector2(x, y), "LADDER  (all fighters):   R  →  Q  →  W  →  E", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, WHITE); y += 40.0
	cr.draw_string(body_font, Vector2(x, y), "weak → medium → heavy → special.  Cancel UP only, one button per rung —", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, GRAY); y += 30.0
	cr.draw_string(body_font, Vector2(x, y), "never repeat a button, never go down.  Max 4 hits.  Cancel FAST (buffer the next button).", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, GRAY); y += 54.0
	# AYE
	cr.draw_string(big_font, Vector2(x, y), "AYE  — crystal witch (slow casts, wider combo window)", HORIZONTAL_ALIGNMENT_LEFT, -1, 32, PURPLE); y += 46.0
	cr.draw_string(body_font, Vector2(x, y), "R   Q   W   E          poke → thrust → ice pillar → crystal shot", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, WHITE); y += 38.0
	cr.draw_string(body_font, Vector2(x, y), "R   Q   W   ↓E         ...  → ice-spikes  FREEZE", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, WHITE); y += 38.0
	cr.draw_string(body_font, Vector2(x, y), "↓R  ↓Q  ↓W  ↓E         full crouch chain (hold ↓)", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, WHITE); y += 38.0
	cr.draw_string(body_font, Vector2(x, y), "↓E  →  E               freeze, then projectile  (zoner 2-hit)", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, WHITE); y += 38.0
	cr.draw_string(body_font, Vector2(x, y), "SUPER   ↓ ← Q          needs a live 3-hit combo + 1.5 meter bars", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, GOLD); y += 54.0
	# DAM / FE
	cr.draw_string(big_font, Vector2(x, y), "DAM / FE", HORIZONTAL_ALIGNMENT_LEFT, -1, 32, RED); y += 46.0
	cr.draw_string(body_font, Vector2(x, y), "R   Q   W   E          same ladder;  E (spin kick) launches → air juggle", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, WHITE); y += 38.0
	cr.draw_string(body_font, Vector2(x, y), "specials:  DAM ↓→Q dash · →E/→R ultra · FE ↓←E whirlpool · Q+W parry (both together)", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, GRAY); y += 54.0
	# tips + cerrar
	cr.draw_string(body_font, Vector2(x, y), "Tip: END on E / ↓E — nothing chains after a special.  Buttons:  Q W E R = attack/kick/spin/weak.", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, GRAY)
	var closes := "ENTER  /  ESC   —   close"
	var cw := big_font.get_string_size(closes, HORIZONTAL_ALIGNMENT_LEFT, -1, 26).x
	cr.draw_string(big_font, Vector2(px + pw * 0.5 - cw * 0.5, py + ph - 26.0), closes, HORIZONTAL_ALIGNMENT_LEFT, -1, 26, GOLD)
