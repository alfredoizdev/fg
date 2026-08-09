extends Control
# PANTALLA PRINCIPAL (escena separada, es el main_scene) — versión ÉPICA con la
# tipografía pesada del juego (Arial Black 900), fondo en capas con speedlines y
# diagonales, y opciones con placa/glow. VS CPU / TRAINING / VS ONLINE (esta última
# coming soon). Al confirmar pasa al char-select con el modo elegido (Sel.mode).

const OPTS := ["VS CPU", "TRAINING", "VS ONLINE"]
const MODES := ["vs_cpu", "practice", ""]   # "" = deshabilitado
const RED := Color(0.95, 0.24, 0.20)
const GOLD := Color(0.98, 0.84, 0.32)

var sel := 0
var big_font: SystemFont
var opt_labels := []
var fx: Control
var t := 0.0

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	big_font = SystemFont.new()
	big_font.font_names = PackedStringArray(["Arial Black", "Impact", "Helvetica Neue", "Arial"])
	big_font.font_weight = 900
	# BANNER: usa res://imagen-action/ui/banner.png si existe; si no, logo temporal por _draw
	if ResourceLoader.exists("res://imagen-action/ui/banner.png"):
		var bn := TextureRect.new()
		bn.texture = load("res://imagen-action/ui/banner.png")
		bn.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bn.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		bn.position = Vector2(360, 70); bn.size = Vector2(1200, 320)
		bn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bn)
	# opciones (labels con la fuente pesada + outline)
	for i in OPTS.size():
		var o := Label.new()
		o.add_theme_font_override("font", big_font)
		o.add_theme_font_size_override("font_size", 64)
		o.add_theme_constant_override("outline_size", 10)
		o.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		o.position = Vector2(0, 512 + i * 122); o.size = Vector2(1920, 96)
		o.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		o.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(o)
		opt_labels.append(o)
	# capa fx: placa/glow del seleccionado. Se añade y se mueve al frente del árbol (índice 0)
	# para que quede DETRÁS de los labels de opciones (que se dibujan después).
	fx = Control.new()
	fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fx)
	move_child(fx, 0)
	fx.draw.connect(_draw_fx)
	var hint := Label.new()
	hint.add_theme_font_override("font", big_font)
	hint.add_theme_font_size_override("font_size", 26)
	hint.add_theme_constant_override("outline_size", 5)
	hint.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	hint.add_theme_color_override("font_color", Color(0.7, 0.7, 0.78))
	hint.text = "↑ ↓  SELECCIONAR      ENTER / Z  CONFIRMAR"
	hint.position = Vector2(0, 980); hint.size = Vector2(1920, 40)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint)
	_refresh()

func _refresh() -> void:
	for i in OPTS.size():
		var disabled: bool = MODES[i] == ""
		var base := Color(0.42, 0.42, 0.48) if disabled else Color(0.78, 0.78, 0.85)
		opt_labels[i].add_theme_color_override("font_color", GOLD if i == sel else base)
		var txt: String = OPTS[i]
		if disabled:
			txt += "   ( COMING SOON )"
		opt_labels[i].text = txt
	queue_redraw()

# ---------- FONDO ÉPICO ----------
func _draw() -> void:
	var w := 1920.0
	var h := 1080.0
	draw_rect(Rect2(0, 0, w, h), Color(0.06, 0.02, 0.06))
	# glow radial superior (donde va el banner/título)
	for i in range(9, 0, -1):
		var r := 130.0 * i
		draw_circle(Vector2(960, 250), r, Color(0.36, 0.06, 0.10, 0.05))
	# speedlines finas diagonales
	for i in range(-2, 24):
		var x := i * 92.0
		draw_line(Vector2(x, 0), Vector2(x - 230, h), Color(0.85, 0.3, 0.3, 0.05), 2.0)
	# franja diagonal central (marco de las opciones)
	draw_colored_polygon(PackedVector2Array([Vector2(0, 470), Vector2(w, 452), Vector2(w, 940), Vector2(0, 922)]), Color(0.03, 0.01, 0.04, 0.55))
	draw_line(Vector2(0, 470), Vector2(w, 452), Color(0.7, 0.12, 0.13), 3.0)
	draw_line(Vector2(0, 940), Vector2(w, 922), Color(0.7, 0.12, 0.13), 3.0)
	# LOGO temporal si no hay banner PNG
	if not ResourceLoader.exists("res://imagen-action/ui/banner.png"):
		# marco del logo
		draw_rect(Rect2(500, 96, 920, 300), Color(0.75, 0.13, 0.11, 0.16))
		draw_line(Vector2(500, 96), Vector2(1420, 96), RED, 6.0)
		draw_line(Vector2(500, 396), Vector2(1420, 396), RED, 6.0)
		for cx in [500.0, 1414.0]:
			for cy in [96.0, 386.0]:
				draw_rect(Rect2(cx, cy, 6, 10), GOLD)
		# título con sombra + outline (dibujado con la fuente)
		_draw_center("FG FIGHTER", 300.0, 168, Color(0.06, 0.0, 0.0, 0.85), 16.0)
		_draw_center("FG FIGHTER", 286.0, 168, RED, 0.0)
		_draw_center("— T E M P L E   D U E L —", 356.0, 34, GOLD, 0.0)

func _draw_center(txt: String, baseline_y: float, size: int, col: Color, off: float) -> void:
	var tw := big_font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_string(big_font, Vector2(960 - tw / 2 + off, baseline_y + off), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)

# ---------- placa/glow del seleccionado ----------
func _draw_fx() -> void:
	if opt_labels.is_empty():
		return
	var pulse := 0.55 + 0.45 * sin(t * 6.0)
	var y := 512.0 + sel * 122.0
	# placa diagonal detrás del texto seleccionado
	var cy := y + 44.0
	fx.draw_colored_polygon(PackedVector2Array([Vector2(430, cy - 52), Vector2(1490, cy - 58), Vector2(1490, cy + 52), Vector2(430, cy + 58)]),
			Color(GOLD.r, GOLD.g, GOLD.b, 0.12 * pulse))
	fx.draw_line(Vector2(430, cy - 52), Vector2(1490, cy - 58), Color(GOLD.r, GOLD.g, GOLD.b, 0.8 * pulse), 3.0)
	fx.draw_line(Vector2(430, cy + 58), Vector2(1490, cy + 52), Color(GOLD.r, GOLD.g, GOLD.b, 0.8 * pulse), 3.0)
	# flechas ▶ ◀ a los lados
	fx.draw_string(big_font, Vector2(470, cy + 20), "▶", HORIZONTAL_ALIGNMENT_LEFT, -1, 44, Color(GOLD.r, GOLD.g, GOLD.b, pulse))
	fx.draw_string(big_font, Vector2(1410, cy + 20), "◀", HORIZONTAL_ALIGNMENT_LEFT, -1, 44, Color(GOLD.r, GOLD.g, GOLD.b, pulse))

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
