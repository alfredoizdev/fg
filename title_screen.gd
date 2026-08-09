extends Control
# PANTALLA PRINCIPAL (escena separada, es el main_scene). Banner + modos:
# VS CPU / TRAINING / VS ONLINE. Al confirmar pasa a la escena de char-select con el
# modo elegido (guardado en el singleton Sel). VS ONLINE está deshabilitado (coming soon).

const OPTS := ["VS CPU", "TRAINING", "VS ONLINE"]
const MODES := ["vs_cpu", "practice", ""]   # "" = deshabilitado
var sel := 0
var opt_labels := []
var t := 0.0

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	# fondo oscuro con degradado rojo (tema DAM)
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.02, 0.05)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var glow := ColorRect.new()
	glow.color = Color(0.35, 0.05, 0.06, 0.5)
	glow.position = Vector2(0, 300); glow.size = Vector2(1920, 480)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glow)
	# BANNER (placeholder): usa res://imagen-action/ui/banner.png si existe
	if ResourceLoader.exists("res://imagen-action/ui/banner.png"):
		var bn := TextureRect.new()
		bn.texture = load("res://imagen-action/ui/banner.png")
		bn.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bn.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		bn.position = Vector2(360, 70); bn.size = Vector2(1200, 320)
		bn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bn)
	else:
		_banner_label("FG FIGHTER", Vector2(16, 132), Color(0.07, 0.0, 0.0, 0.9), 200)  # sombra
		_banner_label("FG FIGHTER", Vector2(0, 116), Color(0.88, 0.16, 0.13), 200)       # frente
		_banner_label("F I G H T E R", Vector2(0, 350), Color(0.85, 0.78, 0.35), 40)     # subtítulo
	# opciones
	for i in OPTS.size():
		var o := Label.new()
		o.add_theme_font_size_override("font_size", 66)
		o.position = Vector2(0, 500 + i * 120); o.size = Vector2(1920, 96)
		o.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		o.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(o)
		opt_labels.append(o)
	var hint := Label.new()
	hint.text = "↑ ↓  seleccionar        ENTER / Z  confirmar"
	hint.add_theme_font_size_override("font_size", 28)
	hint.add_theme_color_override("font_color", Color(0.7, 0.7, 0.78))
	hint.position = Vector2(0, 980); hint.size = Vector2(1920, 40)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint)
	_refresh()

func _banner_label(txt: String, pos: Vector2, col: Color, size: int) -> void:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.position = pos; l.size = Vector2(1920, 260)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)

func _refresh() -> void:
	for i in OPTS.size():
		var disabled: bool = MODES[i] == ""
		var base := Color(0.4, 0.4, 0.46) if disabled else Color(0.62, 0.62, 0.7)
		opt_labels[i].modulate = Color(1.0, 0.85, 0.25) if i == sel else base
		var txt: String = OPTS[i]
		if disabled:
			txt += "   (coming soon)"
		opt_labels[i].text = ("▶  " if i == sel else "") + txt

func _process(delta: float) -> void:
	t += delta
	# el resaltado del seleccionado late suavemente
	opt_labels[sel].modulate.a = 0.75 + 0.25 * sin(t * 6.0)

func _unhandled_input(_e: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_up"):
		sel = posmod(sel - 1, OPTS.size()); _refresh()
	elif Input.is_action_just_pressed("ui_down"):
		sel = posmod(sel + 1, OPTS.size()); _refresh()
	elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack"):
		if MODES[sel] == "":
			return   # VS ONLINE deshabilitado
		Sel.mode = MODES[sel]
		get_tree().change_scene_to_file("res://char_select.tscn")
