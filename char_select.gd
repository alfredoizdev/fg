extends Control
# PANTALLA DE SELECCIÓN DE PERSONAJE (escena separada, estilo UNI/BlazBlue) — versión ÉPICA:
# fondo en capas con diagonales, paneles inclinados P1(rojo)/P2(azul), cartas con marco y
# glow, tipografía PESADA (Arial Black 900) con outline. El jugador elige PRIMERO su
# personaje (1P) y luego el de la CPU (2P). Al confirmar 2P guarda en Sel y entra a la pelea.

var roster: Array = []
var picking := 0            # 0 = eligiendo 1P, 1 = eligiendo 2P
var sel1 := 0
var sel2 := 1
var t := 0.0

var big_font: SystemFont    # fuente pesada del juego (la del combo)
var fx: Control             # capa de cursores/glow (encima de las cartas)
var cards := []             # [{x, y, w, h, av}]
var stand_l: TextureRect    # imagen del cuadro-póster izquierdo (P1)
var stand_r: TextureRect    # imagen del cuadro-póster derecho (P2)
# marco del cuadro-póster (mismo para ambos lados)
const FRAME_L := Rect2(48, 176, 432, 748)
const FRAME_R := Rect2(1440, 176, 432, 748)
var appear_l := 0.0         # animación de aparición del cuadro P1 (0→1 al hacer hover)
var appear_r := 0.0         # animación de aparición del cuadro P2
var shown1 := -1            # último personaje mostrado en el cuadro P1 (para detectar hover)
var shown2 := -1
var name_l: Label
var name_r: Label
var data_l: Label
var data_r: Label
var prompt: Label
# --- pantalla de carga (transición) ---
var loading := false
var load_t := 0.0
const VS_MIN_SHOW := 1.2     # tiempo mínimo que se ve la pantalla de carga (aunque cargue antes)
# --- paso SELECT STAGE (picking == 2) — CARRUSEL ---
var sel_stage := 0
var stage_scroll := 0.0     # posición animada del carrusel (ease hacia sel_stage)
var stage_overlay: Control
var stage_fx: Control
var stage_cards := []       # TextureRects de cada stage (se reposicionan cada frame)
# geometría del carrusel (la tarjeta CENTRAL es la elegida)
const ST_CW := 520.0
const ST_CH := 293.0
const ST_CX := 960.0
const ST_CY := 430.0        # borde superior de la tarjeta central
const ST_SPACING := 560.0   # separación entre centros de tarjetas
# --- pantalla de CARGA (logo FG FIGHTER + spinner) tras elegir stage ---
var load_overlay: Control
var load_logo: TextureRect
var load_spin: Control

const RED := Color(0.95, 0.24, 0.20)
const BLU := Color(0.36, 0.56, 1.0)
const GOLD := Color(0.98, 0.84, 0.32)

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	Sel.play_menu_music()   # sigue la canción del menú (NO se reinicia: ya venía del título)
	_sfx_sel = AudioStreamPlayer.new()
	add_child(_sfx_sel)
	_voz_name = AudioStreamPlayer.new()
	_voz_name.volume_db = 2.0
	add_child(_voz_name)
	roster = Sel.ROSTER
	sel2 = 1 % roster.size()
	big_font = SystemFont.new()
	big_font.font_names = PackedStringArray(["Arial Black", "Impact", "Helvetica Neue", "Arial"])
	big_font.font_weight = 900
	# cuadros-póster enmarcados (imagen -2 con fondo artístico), debajo de las cartas
	stand_l = _mk_portrait(FRAME_L)
	stand_r = _mk_portrait(FRAME_R)
	# ---- CARTAS (grid central) ----
	var n := roster.size()
	var cw := 176.0
	var ch := 224.0
	var gap := 26.0
	var total := n * cw + (n - 1) * gap
	var x0 := 960.0 - total / 2.0
	var gy := 268.0
	for i in n:
		var cx := x0 + i * (cw + gap)
		var av := TextureRect.new()
		var apath := String(roster[i]["avatar"])
		if ResourceLoader.exists(apath):
			av.texture = load(apath)
		av.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		av.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		av.position = Vector2(cx + 7, gy + 7); av.size = Vector2(cw - 14, ch - 14)
		av.clip_contents = true
		av.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(av)
		cards.append({"x": cx, "y": gy, "w": cw, "h": ch, "av": av})
	# ---- CAPA FX (cursores + glow, encima de las cartas) ----
	fx = Control.new()
	fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fx)
	fx.draw.connect(_draw_fx)
	# ---- TEXTOS (encima de todo) ----
	_hdr_big("CHARACTER SELECT", 24, GOLD, 56)
	_hdr("1 PLAYER CHARACTER", Vector2(34, 30), RED, HORIZONTAL_ALIGNMENT_LEFT, 28)
	_hdr("2 PLAYER CHARACTER", Vector2(-34, 30), BLU, HORIZONTAL_ALIGNMENT_RIGHT, 28)
	# nombres grandes abajo (fuente pesada + outline)
	name_l = _big_name(true)
	name_r = _big_name(false)
	# nombres de cada carta
	for i in cards.size():
		var nm := Label.new()
		nm.add_theme_font_override("font", big_font)
		nm.add_theme_font_size_override("font_size", 22)
		nm.add_theme_constant_override("outline_size", 6)
		nm.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		nm.text = String(roster[i]["name"])
		nm.position = Vector2(cards[i]["x"], cards[i]["y"] + cards[i]["h"] + 4)
		nm.size = Vector2(cards[i]["w"], 30)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(nm)
	# character data
	data_l = _data_label(Vector2(560, 560))
	data_r = _data_label(Vector2(1040, 560))
	# prompt
	prompt = Label.new()
	prompt.add_theme_font_override("font", big_font)
	prompt.add_theme_font_size_override("font_size", 26)
	prompt.add_theme_constant_override("outline_size", 6)
	prompt.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	prompt.add_theme_color_override("font_color", GOLD)
	prompt.position = Vector2(0, 1024); prompt.size = Vector2(1920, 40)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(prompt)
	_build_loading_overlay()
	_build_stage_overlay()
	_refresh()

# ---------- PANTALLA DE CARGA (logo FG FIGHTER + spinner) ----------
func _build_loading_overlay() -> void:
	load_overlay = Control.new()
	load_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	load_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	load_overlay.visible = false
	load_overlay.z_index = 6                       # por ENCIMA del overlay de stage (z=4)
	add_child(load_overlay)
	# fondo oscuro opaco
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.025, 0.06, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	load_overlay.add_child(bg)
	# LOGO FG FIGHTER (croma ya recortado), centrado
	load_logo = TextureRect.new()
	if ResourceLoader.exists("res://imagen-action/ui/title-logo.png"):
		load_logo.texture = load("res://imagen-action/ui/title-logo.png")
	load_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	load_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	load_logo.size = Vector2(820, 458); load_logo.position = Vector2(550, 250)
	load_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	load_overlay.add_child(load_logo)
	# SPINNER (se dibuja girando en _update_loading)
	load_spin = Control.new()
	load_spin.set_anchors_preset(Control.PRESET_FULL_RECT)
	load_spin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	load_overlay.add_child(load_spin)
	load_spin.draw.connect(_draw_spinner)

func _draw_spinner() -> void:
	# spinner de puntos girando (estela que se desvanece), centrado bajo el logo
	var purple := Color(0.62, 0.35, 1.0)           # morado (a juego con el logo)
	var c := Vector2(960, 860)
	var n := 12
	var head := fmod(load_t * 2.4, 1.0)            # posición de la cabeza (0..1) girando
	for i in n:
		var f := float(i) / float(n)
		var ang := f * TAU - PI * 0.5
		# distancia angular DETRÁS de la cabeza -> más tenue cuanto más atrás (estela)
		var d := fmod(head - f + 1.0, 1.0)
		var a := 0.15 + 0.85 * d
		var pos := c + Vector2(cos(ang), sin(ang)) * 42.0
		load_spin.draw_circle(pos, 7.0, Color(purple.r, purple.g, purple.b, a))

# ---------- paso SELECT STAGE (overlay a pantalla completa) ----------
func _build_stage_overlay() -> void:
	stage_overlay = Control.new()
	stage_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_overlay.visible = false
	stage_overlay.z_index = 4
	add_child(stage_overlay)
	# fondo oscuro casi opaco (tapa el char-select detrás)
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.03, 0.08, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_overlay.add_child(bg)
	# título
	var title := Label.new()
	title.add_theme_font_override("font", big_font)
	title.add_theme_font_size_override("font_size", 68)
	title.add_theme_constant_override("outline_size", 10)
	title.add_theme_color_override("font_outline_color", Color(0.15, 0.0, 0.0))
	title.add_theme_color_override("font_color", GOLD)
	title.text = "SELECT STAGE"
	title.position = Vector2(0, 54); title.size = Vector2(1920, 80)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_overlay.add_child(title)
	# capa de marcos (debajo de los thumbs para que el borde asome; el arrow va encima)
	stage_fx = Control.new()
	stage_fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_overlay.add_child(stage_fx)
	stage_fx.draw.connect(_draw_stage_fx)
	# tarjetas (thumbnails) — se reposicionan cada frame en _layout_stage_carousel().
	# El nombre de cada stage se dibuja en _draw_stage_fx (así sigue al carrusel).
	stage_cards.clear()
	for i in Sel.STAGES.size():
		var th := TextureRect.new()
		var tp := String(Sel.STAGES[i]["thumb"])
		if ResourceLoader.exists(tp):
			th.texture = load(tp)
		th.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		th.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		th.clip_contents = true
		th.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stage_overlay.add_child(th)
		stage_cards.append(th)
	# hint
	var hint := Label.new()
	hint.add_theme_font_override("font", big_font)
	hint.add_theme_font_size_override("font_size", 28)
	hint.add_theme_constant_override("outline_size", 6)
	hint.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	hint.add_theme_color_override("font_color", Color(0.85, 0.85, 0.92))
	hint.text = "← →   ELIGE ESCENARIO        ENTER  CONFIRMAR        ESC  ATRÁS"
	hint.position = Vector2(0, 902); hint.size = Vector2(1920, 40)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_overlay.add_child(hint)

# geometría de la tarjeta i según la posición animada del carrusel
func _stage_geom(i: int) -> Dictionary:
	var rel := float(i) - stage_scroll
	var scale := lerpf(1.0, 0.78, minf(absf(rel), 1.0))
	var w := ST_CW * scale
	var h := ST_CH * scale
	var cx := ST_CX + rel * ST_SPACING
	var center_y := ST_CY + ST_CH * 0.5
	var rect := Rect2(cx - w * 0.5, center_y - h * 0.5, w, h)
	var alpha := clampf(1.32 - absf(rel) * 0.42, 0.0, 1.0)
	return {"rect": rect, "rel": rel, "alpha": alpha}

# reposiciona/escala/atenúa las tarjetas según el scroll (llamado cada frame)
func _layout_stage_carousel() -> void:
	for i in stage_cards.size():
		var g := _stage_geom(i)
		var r: Rect2 = g["rect"]
		var al: float = g["alpha"]
		var seld := (i == sel_stage)
		var card: TextureRect = stage_cards[i]
		card.position = r.position
		card.size = r.size
		var b := 1.0 if seld else 0.85     # los no elegidos, un poco más apagados
		card.modulate = Color(b, b, b, al)
		card.visible = al > 0.02

func _draw_stage_fx() -> void:
	var pulse := 0.55 + 0.45 * sin(t * 6.0)
	for i in stage_cards.size():
		var g := _stage_geom(i)
		var al: float = g["alpha"]
		if al < 0.05:
			continue
		var r: Rect2 = g["rect"]
		var seld := (i == sel_stage)
		# nombre bajo la tarjeta
		var nm := String(Sel.STAGES[i]["name"])
		var fs := 30
		var nmw := big_font.get_string_size(nm, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var ncol := Color(1, 1, 1, al) if seld else Color(0.6, 0.6, 0.68, al)
		stage_fx.draw_string(big_font, Vector2(r.position.x + r.size.x * 0.5 - nmw * 0.5, r.end.y + 46.0),
				nm, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ncol)
		if seld:
			# glow + marco dorado grueso + flecha
			for k in range(4, 0, -1):
				var e := k * 5.0
				stage_fx.draw_rect(r.grow(e), Color(GOLD.r, GOLD.g, GOLD.b, 0.10 * pulse), false, 3.0)
			stage_fx.draw_rect(r.grow(6.0), Color(GOLD.r, GOLD.g, GOLD.b, 0.95), false, 7.0)
			var cxm := r.position.x + r.size.x * 0.5
			stage_fx.draw_colored_polygon(PackedVector2Array([
					Vector2(cxm - 18, r.position.y - 34), Vector2(cxm + 18, r.position.y - 34), Vector2(cxm, r.position.y - 8)]),
					Color(GOLD.r, GOLD.g, GOLD.b, pulse))
		else:
			stage_fx.draw_rect(r.grow(3.0), Color(0.5, 0.5, 0.58, 0.6 * al), false, 3.0)

func _start_loading() -> void:
	loading = true
	load_t = 0.0
	set_process_unhandled_input(false)
	# carga la escena de pelea EN SEGUNDO PLANO (no congela la pantalla de carga)
	ResourceLoader.load_threaded_request("res://main.tscn")
	# ocultar el overlay de stage (evita que tape la carga -> ya no parece bug)
	if stage_overlay != null:
		stage_overlay.visible = false
	load_overlay.visible = true

# ---------- construcción de nodos ----------
func _mk_portrait(box: Rect2) -> TextureRect:
	# cuadro-póster: la imagen (con su fondo) llena el marco (COVER) y se recorta al cuadro
	var s := TextureRect.new()
	s.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	s.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	s.clip_contents = true
	s.position = box.position; s.size = box.size
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(s)
	return s

func _hdr_big(txt: String, y: float, col: Color, size: int) -> void:
	var l := Label.new()
	l.add_theme_font_override("font", big_font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_constant_override("outline_size", 10)
	l.add_theme_color_override("font_outline_color", Color(0.15, 0.0, 0.0))
	l.add_theme_color_override("font_color", col)
	l.text = txt
	l.position = Vector2(0, y); l.size = Vector2(1920, 70)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)

func _hdr(txt: String, pos: Vector2, col: Color, align: int, size: int) -> void:
	var l := Label.new()
	l.add_theme_font_override("font", big_font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_constant_override("outline_size", 6)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_color_override("font_color", col)
	l.text = txt
	if align == HORIZONTAL_ALIGNMENT_LEFT:
		l.position = Vector2(pos.x, pos.y); l.size = Vector2(700, 40)
	else:
		l.position = Vector2(1920 - 700 - 34, pos.y); l.size = Vector2(700, 40)
	l.horizontal_alignment = align
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)

func _big_name(left: bool) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", big_font)
	l.add_theme_font_size_override("font_size", 92)
	l.add_theme_constant_override("outline_size", 12)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_color_override("font_color", RED if left else BLU)
	if left:
		l.position = Vector2(40, 906); l.size = Vector2(600, 120)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	else:
		l.position = Vector2(1280, 906); l.size = Vector2(600, 120)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l

func _data_label(pos: Vector2) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", big_font)
	l.add_theme_font_size_override("font_size", 20)
	l.add_theme_constant_override("outline_size", 5)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_color_override("font_color", Color(0.9, 0.9, 0.94))
	l.position = pos; l.size = Vector2(320, 200)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l

# ---------- FONDO (capas con diagonales) ----------
func _draw() -> void:
	var w := 1920.0
	var h := 1080.0
	# base
	draw_rect(Rect2(0, 0, w, h), Color(0.06, 0.03, 0.07))
	# glow radial central (vino)
	for i in range(9, 0, -1):
		var r := 115.0 * i
		draw_circle(Vector2(960, 560), r, Color(0.34, 0.05, 0.13, 0.055))
	# líneas de acción diagonales FINAS y sutiles (speedlines), no bandas anchas
	for i in range(-2, 22):
		var x := i * 96.0
		draw_line(Vector2(x, 0), Vector2(x - 210, h), Color(0.85, 0.3, 0.3, 0.05), 2.0)
	# PANEL DIAGONAL izquierdo (P1 rojo) y derecho (P2 azul)
	var pl_active: float = 1.0 if picking == 0 else 0.55
	var pr_active: float = 1.0 if picking == 1 else 0.55
	draw_colored_polygon(PackedVector2Array([Vector2(0, 0), Vector2(560, 0), Vector2(470, h), Vector2(0, h)]),
			Color(0.35, 0.05, 0.08, 0.55 * pl_active + 0.2))
	draw_colored_polygon(PackedVector2Array([Vector2(w, 0), Vector2(1360, 0), Vector2(1450, h), Vector2(w, h)]),
			Color(0.06, 0.10, 0.36, 0.55 * pr_active + 0.2))
	# borde interno de cada panel (línea de color)
	draw_line(Vector2(560, 0), Vector2(470, h), RED, 4.0)
	draw_line(Vector2(1360, 0), Vector2(1450, h), BLU, 4.0)
	# BARRA superior e inferior (negras con filo dorado, en diagonal)
	draw_colored_polygon(PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, 96), Vector2(0, 78)]), Color(0.03, 0.02, 0.04, 0.92))
	draw_line(Vector2(0, 78), Vector2(w, 96), GOLD, 3.0)
	draw_colored_polygon(PackedVector2Array([Vector2(0, 890), Vector2(w, 872), Vector2(w, h), Vector2(0, h)]), Color(0.03, 0.02, 0.04, 0.92))
	draw_line(Vector2(0, 890), Vector2(w, 872), Color(0.6, 0.1, 0.12), 3.0)
	# marco de cada carta (bisel oscuro) — el glow/cursor va en la capa fx
	for c in cards:
		var x: float = c["x"]; var y: float = c["y"]; var cw: float = c["w"]; var chh: float = c["h"]
		draw_rect(Rect2(x - 3, y - 3, cw + 6, chh + 6), Color(0, 0, 0, 0.85))
		draw_rect(Rect2(x, y, cw, chh), Color(0.10, 0.10, 0.14))

# ---------- CURSORES + GLOW (capa fx, encima de las cartas) ----------
func _draw_fx() -> void:
	# marcos de los cuadros-póster (siguen la animación de aparición)
	_portrait_frame(FRAME_L, appear_l, -1.0, RED)
	_portrait_frame(FRAME_R, appear_r, 1.0, BLU)
	var pulse := 0.6 + 0.4 * sin(t * 7.0)
	_cursor(sel1, RED, "1P", picking == 0, pulse, -1)
	_cursor(sel2, BLU, "2P", picking == 1, pulse, 1)

func _portrait_frame(box: Rect2, ap: float, dir: float, col: Color) -> void:
	var e := _ease_out(ap)
	var off := (1.0 - e) * 46.0 * dir
	var r := Rect2(box.position.x + off, box.position.y, box.size.x, box.size.y)
	# sombra/base del marco
	fx.draw_rect(Rect2(r.position.x - 5, r.position.y - 5, r.size.x + 10, r.size.y + 10), Color(0, 0, 0, 0.7 * e), false, 8.0)
	# borde de color; con FLASH extra mientras aparece (e<1)
	var flash := 1.0 + (1.0 - e) * 1.4
	fx.draw_rect(r.grow(2.0), Color(col.r * flash, col.g * flash, col.b * flash, e), false, 6.0)
	# esquinas doradas (brackets en L): cada una abraza SU esquina (apunta hacia adentro)
	var gc := Color(GOLD.r, GOLD.g, GOLD.b, e)
	var cs := 30.0
	var th := 6.0
	var x1 := r.position.x
	var y1 := r.position.y
	var x2 := r.end.x
	var y2 := r.end.y
	# superior-izquierda
	fx.draw_rect(Rect2(x1 - th, y1 - th, cs, th), gc)
	fx.draw_rect(Rect2(x1 - th, y1 - th, th, cs), gc)
	# superior-derecha
	fx.draw_rect(Rect2(x2 - cs + th, y1 - th, cs, th), gc)
	fx.draw_rect(Rect2(x2, y1 - th, th, cs), gc)
	# inferior-izquierda
	fx.draw_rect(Rect2(x1 - th, y2, cs, th), gc)
	fx.draw_rect(Rect2(x1 - th, y2 - cs + th, th, cs), gc)
	# inferior-derecha
	fx.draw_rect(Rect2(x2 - cs + th, y2, cs, th), gc)
	fx.draw_rect(Rect2(x2, y2 - cs + th, th, cs), gc)

func _cursor(idx: int, col: Color, tag: String, active: bool, pulse: float, side: int) -> void:
	if idx < 0 or idx >= cards.size():
		return
	var c: Dictionary = cards[idx]
	var x: float = c["x"]; var y: float = c["y"]; var cw: float = c["w"]; var chh: float = c["h"]
	var a := 1.0 if active else 0.7
	var gl := (pulse if active else 0.5)
	# glow exterior
	for k in range(4, 0, -1):
		var e := k * 4.0
		fx.draw_rect(Rect2(x - e, y - e, cw + e * 2, chh + e * 2), Color(col.r, col.g, col.b, 0.08 * gl * a), false, 3.0)
	# borde grueso
	fx.draw_rect(Rect2(x - 4, y - 4, cw + 8, chh + 8), Color(col.r, col.g, col.b, a), false, 5.0)
	# etiqueta 1P/2P sobre una plaquita
	var tx := x - 6 if side < 0 else x + cw - 44
	fx.draw_rect(Rect2(tx, y - 40, 50, 34), Color(col.r * 0.7, col.g * 0.7, col.b * 0.7, a))
	fx.draw_rect(Rect2(tx, y - 40, 50, 34), Color(0, 0, 0, a), false, 2.0)
	fx.draw_string(big_font, Vector2(tx + 8, y - 14), tag, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(1, 1, 1, a))

# ---------- estado ----------
func _refresh() -> void:
	var c1: Dictionary = roster[sel1]
	var c2: Dictionary = roster[sel2]
	# al cambiar de personaje (hover), reinicia la animación de aparición del cuadro
	if sel1 != shown1:
		shown1 = sel1
		_set_stand(stand_l, c1)
		appear_l = 0.0
	if sel2 != shown2:
		shown2 = sel2
		_set_stand(stand_r, c2)
		appear_r = 0.0
	name_l.text = String(c1["name"])
	name_r.text = String(c2["name"])
	data_l.text = "CHARACTER DATA\nCLASS:  %s\nWEAPON: %s\nPOWER:  %s" % [c1["arch"], c1["weapon"], c1["power"]]
	data_r.text = "CHARACTER DATA\nCLASS:  %s\nWEAPON: %s\nPOWER:  %s" % [c2["arch"], c2["weapon"], c2["power"]]
	if picking == 0:
		prompt.text = "1P:  ELIGE TU PERSONAJE   ( ← →   ENTER  ·  ESC )"
	elif picking == 1:
		prompt.text = "2P:  ELIGE EL RIVAL (CPU)   ( ← →   ENTER  ·  ESC )"
	else:
		prompt.text = ""
	# overlay de SELECT STAGE visible solo en el 3er paso
	if stage_overlay != null:
		stage_overlay.visible = (picking == 2)
	queue_redraw()

func _set_stand(node: TextureRect, c: Dictionary) -> void:
	# usa el retrato-póster CON FONDO (portrait / -2); cae a stand / pose si no existe
	var path := Sel.portrait_of(String(c["id"]))
	node.texture = load(path) if ResourceLoader.exists(path) else null

func _ease_out(x: float) -> float:
	return 1.0 - pow(1.0 - clampf(x, 0.0, 1.0), 3.0)

func _process(delta: float) -> void:
	t += delta
	if loading:
		_update_loading(delta)
		return
	# avanza la animación de aparición de los cuadros (hover)
	appear_l = minf(1.0, appear_l + delta * 5.0)   # ~0.2s
	appear_r = minf(1.0, appear_r + delta * 5.0)
	_anim_portrait(stand_l, FRAME_L, appear_l, -1.0, picking == 0)
	_anim_portrait(stand_r, FRAME_R, appear_r, 1.0, picking == 1)
	if fx:
		fx.queue_redraw()
	if picking == 2 and stage_fx != null:
		stage_scroll = lerpf(stage_scroll, float(sel_stage), minf(delta * 12.0, 1.0))
		_layout_stage_carousel()
		stage_fx.queue_redraw()

func _update_loading(delta: float) -> void:
	load_t += delta
	if load_spin != null:
		load_spin.queue_redraw()
	# cuando la escena de pelea terminó de cargar Y ya se vio el mínimo -> entrar
	var st := ResourceLoader.load_threaded_get_status("res://main.tscn")
	if st == ResourceLoader.THREAD_LOAD_LOADED and load_t >= VS_MIN_SHOW:
		var packed = ResourceLoader.load_threaded_get("res://main.tscn")
		get_tree().change_scene_to_packed(packed)
	elif st == ResourceLoader.THREAD_LOAD_FAILED or st == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		get_tree().change_scene_to_file("res://main.tscn")   # fallback

func _anim_portrait(node: TextureRect, box: Rect2, ap: float, dir: float, active: bool) -> void:
	if node == null:
		return
	var e := _ease_out(ap)
	# entra deslizando desde afuera (dir) + fade-in; atenuado si NO es el lado activo
	var off := (1.0 - e) * 46.0 * dir
	node.position = Vector2(box.position.x + off, box.position.y)
	node.modulate = Color(1, 1, 1, e * (1.0 if active else 0.6))

# --- sonidos del char-select: al confirmar suena "on-select" + la VOZ (épica) del nombre ---
const SEL_SFX := "res://imagen-action/sound-effect/on-select.mp3"
const HOVER_SFX := "res://imagen-action/sound-effect/hover-selection.mp3"   # campana al pasar por un personaje
const NAME_VOZ := {
	"dam": "res://imagen-action/sound-effect/dam-name.mp3",
	"favi": "res://imagen-action/sound-effect/fe-name.mp3",
	"aye": "res://imagen-action/sound-effect/aye.mp3",
}
var _sfx_sel: AudioStreamPlayer
var _voz_name: AudioStreamPlayer

func _play_select(char_id: String) -> void:
	if _sfx_sel != null and ResourceLoader.exists(SEL_SFX):
		_sfx_sel.stream = load(SEL_SFX)
		_sfx_sel.play()
	var ruta: String = NAME_VOZ.get(char_id, "")
	if _voz_name != null and ruta != "" and ResourceLoader.exists(ruta):
		_voz_name.stream = load(ruta)
		_voz_name.play()

func _unhandled_input(_e: InputEvent) -> void:
	var dc := 0
	if Input.is_action_just_pressed("ui_left"):
		dc = -1
	elif Input.is_action_just_pressed("ui_right"):
		dc = 1
	if dc != 0:
		if picking == 0:
			sel1 = posmod(sel1 + dc, roster.size())
		elif picking == 1:
			sel2 = posmod(sel2 + dc, roster.size())
		else:                                            # picking == 2: elegir stage (carrusel, sin wrap)
			sel_stage = clampi(sel_stage + dc, 0, Sel.STAGES.size() - 1)
		if _sfx_sel != null and ResourceLoader.exists(HOVER_SFX):   # campana al pasar
			_sfx_sel.stream = load(HOVER_SFX)
			_sfx_sel.play()
		_refresh()
		return
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack"):
		if picking == 0:
			_play_select(String(roster[sel1]["id"]))   # on-select + voz del nombre (1P)
			picking = 1
			_refresh()
		elif picking == 1:
			_play_select(String(roster[sel2]["id"]))   # on-select + voz del nombre (2P/CPU)
			Sel.p1 = String(roster[sel1]["id"])
			Sel.p2 = String(roster[sel2]["id"])
			picking = 2                                 # -> SELECT STAGE
			_refresh()
		else:                                           # confirmar STAGE -> a la pelea
			Sel.stage = int(Sel.STAGES[sel_stage]["code"])
			Sel.configured = true
			if _sfx_sel != null and ResourceLoader.exists(SEL_SFX):
				_sfx_sel.stream = load(SEL_SFX)
				_sfx_sel.play()
			_start_loading()   # pantalla de carga (logo) mientras carga la pelea
	elif Input.is_action_just_pressed("ui_cancel"):
		if picking == 2:
			picking = 1
			_refresh()
		elif picking == 1:
			picking = 0
			_refresh()
		else:
			get_tree().change_scene_to_file("res://title.tscn")
