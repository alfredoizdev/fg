extends Control
# PANTALLA PRINCIPAL (main_scene). Fondo = póster DAM vs FE a pantalla completa
# (res://imagen-action/ui/menu-bg.png). Menú abajo-centro sobre un velo oscuro, con la
# tipografía pesada del juego. Sin título (el póster manda). VS CPU / TRAINING / VS ONLINE.

const OPTS := ["VS CPU", "TRAINING", "VS ONLINE"]
const MODES := ["vs_cpu", "practice", ""]   # "" = deshabilitado
const RED := Color(0.95, 0.24, 0.20)
const GOLD := Color(0.98, 0.84, 0.32)
const BG_PATH := "res://imagen-action/ui/posetr-ui.png"

var sel := 0
var has_bg := false
var big_font: SystemFont
var opt_labels := []
var fx: Control
var t := 0.0

# posición del menú (abajo-centro)
const OPT_Y0 := 706.0
const OPT_DY := 96.0

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	big_font = SystemFont.new()
	big_font.font_names = PackedStringArray(["Arial Black", "Impact", "Helvetica Neue", "Arial"])
	big_font.font_weight = 900
	has_bg = ResourceLoader.exists(BG_PATH)
	# FONDO: póster a pantalla completa (cover). Si no está, el _draw pone el logo temporal.
	if has_bg:
		var bg := TextureRect.new()
		bg.texture = load(BG_PATH)
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bg)
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

func _unhandled_input(_e: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_up"):
		sel = posmod(sel - 1, OPTS.size()); _refresh()
	elif Input.is_action_just_pressed("ui_down"):
		sel = posmod(sel + 1, OPTS.size()); _refresh()
	elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack"):
		if MODES[sel] == "":
			return
		Sel.mode = MODES[sel]
		get_tree().change_scene_to_file("res://char_select.tscn")
