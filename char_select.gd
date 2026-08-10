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
# --- pantalla VS de transición / carga ---
var loading := false
var load_t := 0.0
const VS_MIN_SHOW := 1.6     # tiempo mínimo que se ve la pantalla VS (aunque cargue antes)
var vs_overlay: Control
var vs_bg: ColorRect
var vs_p1: TextureRect
var vs_p2: TextureRect
var vs_label: Label
var vs_name1: Label
var vs_name2: Label
var vs_loading: Label

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
	_build_vs_overlay()
	_refresh()

# ---------- PANTALLA VS (transición + carga) ----------
func _build_vs_overlay() -> void:
	vs_overlay = Control.new()
	vs_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	vs_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vs_overlay.visible = false
	add_child(vs_overlay)
	vs_bg = ColorRect.new()
	vs_bg.color = Color(0.04, 0.01, 0.04, 0.0)
	vs_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	vs_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vs_overlay.add_child(vs_bg)
	# pósters grandes de los dos elegidos (entran deslizando)
	vs_p1 = TextureRect.new()
	vs_p1.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vs_p1.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	vs_p1.clip_contents = true
	vs_p1.size = Vector2(760, 1080)
	vs_p1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vs_overlay.add_child(vs_p1)
	vs_p2 = TextureRect.new()
	vs_p2.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vs_p2.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	vs_p2.clip_contents = true
	vs_p2.size = Vector2(760, 1080)
	vs_p2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vs_overlay.add_child(vs_p2)
	# capa fx del VS (diagonal + destello), encima de los pósters
	var vfx := Control.new()
	vfx.set_anchors_preset(Control.PRESET_FULL_RECT)
	vfx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vs_overlay.add_child(vfx)
	vfx.draw.connect(_draw_vs_fx)
	# nombres
	vs_name1 = _vs_text(48, RED, HORIZONTAL_ALIGNMENT_LEFT, 88)
	vs_name2 = _vs_text(-48, BLU, HORIZONTAL_ALIGNMENT_RIGHT, 88)
	vs_name1.position.y = 880
	vs_name2.position.y = 880
	# "VS" gigante
	vs_label = Label.new()
	vs_label.add_theme_font_override("font", big_font)
	vs_label.add_theme_font_size_override("font_size", 260)
	vs_label.add_theme_constant_override("outline_size", 22)
	vs_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	vs_label.add_theme_color_override("font_color", GOLD)
	vs_label.text = "VS"
	vs_label.position = Vector2(0, 380); vs_label.size = Vector2(1920, 300)
	vs_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vs_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vs_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vs_overlay.add_child(vs_label)
	# NOW LOADING
	vs_loading = Label.new()
	vs_loading.add_theme_font_override("font", big_font)
	vs_loading.add_theme_font_size_override("font_size", 30)
	vs_loading.add_theme_constant_override("outline_size", 5)
	vs_loading.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	vs_loading.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	vs_loading.position = Vector2(0, 1010); vs_loading.size = Vector2(1920, 40)
	vs_loading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vs_loading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vs_overlay.add_child(vs_loading)

func _vs_text(x: float, col: Color, align: int, size: int) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", big_font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_constant_override("outline_size", 12)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_color_override("font_color", col)
	if align == HORIZONTAL_ALIGNMENT_LEFT:
		l.position = Vector2(x, 0); l.size = Vector2(700, 110)
	else:
		l.position = Vector2(1920 - 700 + x, 0); l.size = Vector2(700, 110)
	l.horizontal_alignment = align
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vs_overlay.add_child(l)
	return l

func _draw_vs_fx() -> void:
	if not loading:
		return
	var vfx: Control = vs_overlay.get_child(3)
	var a: float = clampf(load_t / 0.3, 0.0, 1.0)
	# franja diagonal central (donde va el VS)
	vfx.draw_colored_polygon(PackedVector2Array([Vector2(760, 0), Vector2(1160, 0), Vector2(1160, 1080), Vector2(760, 1080)]),
			Color(0.5, 0.06, 0.06, 0.5 * a))
	vfx.draw_line(Vector2(820, 0), Vector2(700, 1080), Color(RED.r, RED.g, RED.b, a), 5.0)
	vfx.draw_line(Vector2(1100, 0), Vector2(1220, 1080), Color(BLU.r, BLU.g, BLU.b, a), 5.0)

func _start_vs_transition() -> void:
	loading = true
	load_t = 0.0
	set_process_unhandled_input(false)
	# carga la escena de pelea EN SEGUNDO PLANO (no congela la pantalla VS)
	ResourceLoader.load_threaded_request("res://main.tscn")
	# pósters de los elegidos
	var p1path := Sel.portrait_of(String(roster[sel1]["id"]))
	var p2path := Sel.portrait_of(String(roster[sel2]["id"]))
	if ResourceLoader.exists(p1path):
		vs_p1.texture = load(p1path)
	if ResourceLoader.exists(p2path):
		vs_p2.texture = load(p2path)
	vs_name1.text = String(roster[sel1]["name"])
	vs_name2.text = String(roster[sel2]["name"])
	vs_p1.position = Vector2(-760, 0)     # entran desde afuera
	vs_p2.position = Vector2(1920, 0)
	vs_label.scale = Vector2(3.0, 3.0)    # "VS" hace pop (de grande a normal)
	vs_label.pivot_offset = Vector2(960, 150)
	vs_label.modulate.a = 0.0
	vs_overlay.visible = true

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
	prompt.text = "1P:  ELIGE TU PERSONAJE   ( ← →   ENTER  ·  ESC )" if picking == 0 \
		else "2P:  ELIGE EL RIVAL (CPU)   ( ← →   ENTER  ·  ESC )"
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
		_update_vs(delta)
		return
	# avanza la animación de aparición de los cuadros (hover)
	appear_l = minf(1.0, appear_l + delta * 5.0)   # ~0.2s
	appear_r = minf(1.0, appear_r + delta * 5.0)
	_anim_portrait(stand_l, FRAME_L, appear_l, -1.0, picking == 0)
	_anim_portrait(stand_r, FRAME_R, appear_r, 1.0, picking == 1)
	if fx:
		fx.queue_redraw()

func _update_vs(delta: float) -> void:
	load_t += delta
	var e := _ease_out(minf(1.0, load_t / 0.45))
	vs_bg.color.a = clampf(load_t / 0.25, 0.0, 1.0) * 0.96
	vs_p1.position.x = lerpf(-760.0, 60.0, e)
	vs_p2.position.x = lerpf(1920.0, 1100.0, e)
	# "VS" hace POP tras 0.35s (de grande a normal + fade)
	var vp := clampf((load_t - 0.35) / 0.3, 0.0, 1.0)
	var vs_sc := lerpf(3.0, 1.0, _ease_out(vp))
	vs_label.scale = Vector2(vs_sc, vs_sc)
	vs_label.modulate.a = vp
	# puntos animados del loading
	vs_loading.text = "NOW LOADING" + ".".repeat(1 + int(load_t * 2.0) % 3)
	if vs_overlay.get_child_count() > 3:
		vs_overlay.get_child(3).queue_redraw()   # capa vfx del VS
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
		else:
			sel2 = posmod(sel2 + dc, roster.size())
		if _sfx_sel != null and ResourceLoader.exists(HOVER_SFX):   # campana al pasar por un personaje
			_sfx_sel.stream = load(HOVER_SFX)
			_sfx_sel.play()
		_refresh()
		return
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack"):
		if picking == 0:
			_play_select(String(roster[sel1]["id"]))   # on-select + voz del nombre (1P)
			picking = 1
			_refresh()
		else:
			_play_select(String(roster[sel2]["id"]))   # on-select + voz del nombre (2P/CPU)
			Sel.p1 = String(roster[sel1]["id"])
			Sel.p2 = String(roster[sel2]["id"])
			Sel.configured = true
			_start_vs_transition()   # pantalla VS mientras carga la pelea
	elif Input.is_action_just_pressed("ui_cancel"):
		if picking == 1:
			picking = 0
			_refresh()
		else:
			get_tree().change_scene_to_file("res://title.tscn")
