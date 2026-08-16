extends Control
# PANTALLA PRINCIPAL (main_scene = title.tscn). Fondo = póster de roster a pantalla
# completa (res://imagen-action/ui/menu-poster.png), recorte sesgado a las caras.
# Menú en COLUMNA IZQUIERDA sobre un velo con degradado (oscuro->transparente), con la
# tipografía pesada del juego y placa dorada en el seleccionado. VS CPU / TRAINING /
# COMBOS / VS ONLINE. El panel de COMBOS y la navegación se conservan igual.

const OPTS := ["VS CPU", "VS 2P", "TRAINING", "VS ONLINE"]
const MODES := ["vs_cpu", "vs_2p", "practice", ""]   # "" = deshabilitado
const RED := Color(0.95, 0.24, 0.20)
const GOLD := Color(0.74, 0.52, 1.0)     # acento morado (paleta del logo)
const POSTER := "res://imagen-action/ui/menu-poster.png"
const LOGO := "res://imagen-action/ui/title-logo.png"   # logo FG FIGHTER (croma recortado)
# caja del logo arriba-izquierda (se respeta la proporción de la textura)
const LOGO_X := 56.0
const LOGO_Y := 40.0
const LOGO_W := 680.0

# --- recorte del póster (cuadrado) hacia una franja 16:9 sesgada arriba, para que se
# vean las caras de los 4 sin cortar cabezas. src_y0 = borde superior de la franja. ---
const POSTER_SRC_Y0 := 70.0

var sel := 0
var has_bg := false
var poster_tex: Texture2D
var logo_tex: Texture2D
var big_font: SystemFont
var opt_labels := []
var fx: Control
var t := 0.0

# --- layout del menú (columna izquierda) ---
const MENU_X := 108.0               # margen izquierdo del texto de opciones
const OPT_W := 600.0                # ancho de la caja de cada opción (placa dentro del panel)
const OPT_Y0 := 452.0
const OPT_DY := 96.0
const DIV_X := 760.0                 # DIVISIÓN: izq [0..DIV_X] = panel de menú oscuro; der = póster

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	Sel.play_menu_music()   # canción del menú (loop, persiste al pasar al char-select)
	big_font = SystemFont.new()
	big_font.font_names = PackedStringArray(["Arial Black", "Impact", "Helvetica Neue", "Arial"])
	big_font.font_weight = 900
	# FONDO: póster de roster. Se dibuja a mano (draw_texture_rect_region) para controlar
	# el recorte y que no corte cabezas ni deforme.
	if ResourceLoader.exists(POSTER):
		poster_tex = load(POSTER)
	has_bg = poster_tex != null
	if ResourceLoader.exists(LOGO):
		logo_tex = load(LOGO)
	# capa fx: velo + placa del seleccionado (encima del fondo, debajo de los labels)
	fx = Control.new()
	fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fx)
	fx.draw.connect(_draw_fx)
	# opciones (columna izquierda) con la fuente pesada + outline
	for i in OPTS.size():
		var o := Label.new()
		o.add_theme_font_override("font", big_font)
		o.add_theme_font_size_override("font_size", 56)
		o.add_theme_constant_override("outline_size", 12)
		o.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		o.position = Vector2(MENU_X, OPT_Y0 + i * OPT_DY); o.size = Vector2(OPT_W, 84)
		o.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		o.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
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
	hint.position = Vector2(MENU_X, 1004); hint.size = Vector2(960, 40)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint)
	_refresh()

func _refresh() -> void:
	for i in OPTS.size():
		var disabled: bool = MODES[i] == ""
		var base := Color(0.55, 0.55, 0.6) if disabled else Color(0.92, 0.92, 0.96)
		opt_labels[i].add_theme_color_override("font_color", GOLD if i == sel else base)
		# solo el nombre (la etiqueta "COMING SOON" se dibuja pequeña aparte, para no
		# alargar la opción y que cruce a la zona del póster)
		opt_labels[i].text = OPTS[i]
	queue_redraw()

# ---------- fondo: PANTALLA DIVIDIDA (izq = panel de menú, der = póster) ----------
func _draw() -> void:
	var w := 1920.0
	var h := 1080.0
	# 1) PÓSTER solo en la MITAD DERECHA [DIV_X..w], recortado a esa caja (cover, sin deformar).
	if has_bg:
		var sw := float(poster_tex.get_width())
		var sh := float(poster_tex.get_height())
		var dest_w := w - DIV_X
		var ratio := dest_w / h                                     # proporción de la caja derecha
		var src_h := minf(sh, sw / ratio)                           # franja fuente que la cubre
		var src_w := minf(sw, src_h * ratio)
		var y0 := clampf(POSTER_SRC_Y0, 0.0, sh - src_h)            # sesgo a las caras
		var x0 := (sw - src_w) * 0.5
		draw_texture_rect_region(poster_tex, Rect2(DIV_X, 0, dest_w, h), Rect2(x0, y0, src_w, src_h))
	# 2) PANEL IZQUIERDO SÓLIDO [0..DIV_X]: sin arte detrás, degradado vertical para profundidad.
	var psteps := 40
	for i in psteps:
		var y := h * float(i) / float(psteps)
		var top := Color(0.07, 0.05, 0.10)
		var bot := Color(0.02, 0.015, 0.035)
		draw_rect(Rect2(0, y, DIV_X, h / float(psteps) + 1.0), top.lerp(bot, float(i) / float(psteps)))
	# 3) COSTURA: fundido corto del panel hacia el póster (el borde izq del póster se difumina).
	var seam := 110.0
	var ss := 28
	for i in ss:
		var x := DIV_X + seam * float(i) / float(ss)
		var a: float = lerpf(0.95, 0.0, float(i) / float(ss))
		draw_rect(Rect2(x, 0, seam / float(ss) + 1.0, h), Color(0.04, 0.03, 0.06, a))
	# 4) oscurecido inferior SOLO en el panel (para el hint)
	var bsteps := 20
	for i in bsteps:
		var y := (h - 150.0) + 150.0 * float(i) / float(bsteps)
		var a2: float = lerpf(0.0, 0.5, float(i) / float(bsteps))
		draw_rect(Rect2(0, y, DIV_X, 150.0 / float(bsteps) + 1.0), Color(0.02, 0.01, 0.03, a2))
	# 5) LOGO arriba-izquierda (dentro del panel).
	if logo_tex != null:
		var lw := float(logo_tex.get_width())
		var lh := float(logo_tex.get_height())
		var dh := LOGO_W * (lh / lw)
		draw_texture_rect(logo_tex, Rect2(LOGO_X, LOGO_Y, LOGO_W, dh), false)
	else:
		_draw_left(big_font, "FG FIGHTER", MENU_X, 168.0, 78, RED, 0.0)
	# 6) etiqueta "COMING SOON" pequeña junto a las opciones deshabilitadas (queda en el panel).
	for i in OPTS.size():
		if MODES[i] == "":
			var nmw := big_font.get_string_size(OPTS[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 56).x
			var ty := OPT_Y0 + i * OPT_DY + 56.0
			draw_string(big_font, Vector2(MENU_X + nmw + 20.0, ty), "COMING SOON", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.68, 0.68, 0.76))

func _draw_left(font: SystemFont, txt: String, x: float, baseline_y: float, size: int, col: Color, off: float) -> void:
	draw_string(font, Vector2(x + off, baseline_y + off), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)

# ---------- placa/glow del seleccionado ----------
func _draw_fx() -> void:
	if opt_labels.is_empty():
		return
	var pulse := 0.55 + 0.45 * sin(t * 6.0)
	var cy := OPT_Y0 + sel * OPT_DY + 42.0
	var x0 := MENU_X - 28.0
	var x1 := MENU_X + OPT_W + 20.0
	fx.draw_colored_polygon(PackedVector2Array([Vector2(x0, cy - 46), Vector2(x1, cy - 50), Vector2(x1, cy + 50), Vector2(x0, cy + 46)]),
			Color(GOLD.r, GOLD.g, GOLD.b, 0.16 * pulse))
	fx.draw_line(Vector2(x0, cy - 46), Vector2(x1, cy - 50), Color(GOLD.r, GOLD.g, GOLD.b, 0.85 * pulse), 3.0)
	fx.draw_line(Vector2(x0, cy + 46), Vector2(x1, cy + 50), Color(GOLD.r, GOLD.g, GOLD.b, 0.85 * pulse), 3.0)
	fx.draw_string(big_font, Vector2(x0 - 42.0, cy + 18), "▶", HORIZONTAL_ALIGNMENT_LEFT, -1, 40, Color(GOLD.r, GOLD.g, GOLD.b, pulse))

func _process(delta: float) -> void:
	t += delta
	if fx:
		fx.queue_redraw()

func _unhandled_input(_e: InputEvent) -> void:
	# el MANDO (acciones _p2) también navega el título: las ui_* globales ya no traen
	# joypad (Sel._map_pad_p2 se lo quita para que el D-pad no mueva a P1 en la pelea)
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_up_p2"):
		sel = posmod(sel - 1, OPTS.size()); _refresh()
	elif Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_down_p2"):
		sel = posmod(sel + 1, OPTS.size()); _refresh()
	elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack") \
			or Input.is_action_just_pressed("kick_p2") or Input.is_action_just_pressed("attack_p2"):
		if MODES[sel] == "":
			return
		Sel.mode = MODES[sel]
		get_tree().change_scene_to_file("res://char_select.tscn")
