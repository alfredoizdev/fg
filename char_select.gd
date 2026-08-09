extends Control
# PANTALLA DE SELECCIÓN DE PERSONAJE (escena separada, estilo UNI/BlazBlue).
# El jugador elige PRIMERO su personaje (1P, cursor rojo) y luego el del rival/CPU
# (2P, cursor azul). Retratos de pie a los lados, grid central, nombres grandes.
# Al confirmar 2P guarda en Sel y entra a la pelea (main.tscn).

var roster: Array = []
var picking := 0            # 0 = eligiendo 1P, 1 = eligiendo 2P
var sel1 := 0
var sel2 := 1
var t := 0.0

# nodos
var cards := []             # [{border, av, name}]
var stand_l: TextureRect
var stand_r: TextureRect
var name_l: Label
var name_r: Label
var data_l: Label
var data_r: Label
var prompt: Label

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	roster = Sel.ROSTER
	sel2 = 1 % roster.size()
	# ---- FONDO ----
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.03, 0.06)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	# medios teñidos: izquierda rojo (1P), derecha azul (2P)
	var half_l := ColorRect.new()
	half_l.color = Color(0.28, 0.04, 0.06, 0.55)
	half_l.position = Vector2(0, 0); half_l.size = Vector2(560, 1080)
	half_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(half_l)
	var half_r := ColorRect.new()
	half_r.color = Color(0.05, 0.08, 0.30, 0.55)
	half_r.position = Vector2(1360, 0); half_r.size = Vector2(560, 1080)
	half_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(half_r)
	# ---- RETRATOS DE PIE A LOS LADOS ----
	stand_l = _mk_stand(Vector2(-40, 210), false)
	stand_r = _mk_stand(Vector2(1500, 210), true)
	# ---- CABECERAS ----
	_hdr("1 PLAYER CHARACTER", Vector2(30, 22), Color(0.95, 0.3, 0.28), HORIZONTAL_ALIGNMENT_LEFT, 30)
	_hdr("2 PLAYER CHARACTER", Vector2(-30, 22), Color(0.4, 0.6, 1.0), HORIZONTAL_ALIGNMENT_RIGHT, 30)
	_hdr("CHARACTER SELECT", Vector2(0, 20), Color(0.95, 0.85, 0.35), HORIZONTAL_ALIGNMENT_CENTER, 52)
	# ---- GRID DE CARTAS (centrado) ----
	var n := roster.size()
	var cw := 200.0
	var gap := 34.0
	var total := n * cw + (n - 1) * gap
	var x0 := 960.0 - total / 2.0
	for i in n:
		var cx := x0 + i * (cw + gap)
		var border := ColorRect.new()
		border.color = Color(0, 0, 0)
		border.position = Vector2(cx, 300); border.size = Vector2(cw, cw * 1.3)
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(border)
		var inner := ColorRect.new()
		inner.color = Color(0.1, 0.1, 0.14)
		inner.position = Vector2(cx + 6, 306); inner.size = Vector2(cw - 12, cw * 1.3 - 12)
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(inner)
		var av := TextureRect.new()
		var apath := String(roster[i]["avatar"])
		if ResourceLoader.exists(apath):
			av.texture = load(apath)
		av.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		av.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		av.position = Vector2(cx + 8, 308); av.size = Vector2(cw - 16, cw * 1.3 - 16)
		av.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(av)
		var nm := Label.new()
		nm.text = String(roster[i]["name"])
		nm.add_theme_font_size_override("font_size", 26)
		nm.position = Vector2(cx, 300 + cw * 1.3 + 6); nm.size = Vector2(cw, 34)
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(nm)
		cards.append({"border": border, "av": av, "name": nm, "x": cx})
	# ---- NOMBRES GRANDES ABAJO ----
	name_l = _big_name(Vector2(40, 900), Color(0.95, 0.3, 0.28), HORIZONTAL_ALIGNMENT_LEFT)
	name_r = _big_name(Vector2(-40, 900), Color(0.45, 0.62, 1.0), HORIZONTAL_ALIGNMENT_RIGHT)
	# ---- DATA ----
	data_l = _data_label(Vector2(600, 640), HORIZONTAL_ALIGNMENT_LEFT)
	data_r = _data_label(Vector2(1020, 640), HORIZONTAL_ALIGNMENT_RIGHT)
	# ---- PROMPT ----
	prompt = Label.new()
	prompt.add_theme_font_size_override("font_size", 30)
	prompt.add_theme_color_override("font_color", Color(0.95, 0.85, 0.35))
	prompt.position = Vector2(0, 1030); prompt.size = Vector2(1920, 40)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(prompt)
	_refresh()

func _mk_stand(pos: Vector2, flip: bool) -> TextureRect:
	var s := TextureRect.new()
	s.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	s.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	s.flip_h = flip
	s.position = pos; s.size = Vector2(500, 820)
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(s)
	return s

func _hdr(txt: String, pos: Vector2, col: Color, align: int, size: int) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.position = Vector2(pos.x, pos.y); l.size = Vector2(1920 - abs(pos.x) if align != HORIZONTAL_ALIGNMENT_CENTER else 1920, 64)
	if align == HORIZONTAL_ALIGNMENT_CENTER:
		l.position = Vector2(0, pos.y); l.size = Vector2(1920, 64)
	l.horizontal_alignment = align
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l

func _big_name(pos: Vector2, col: Color, align: int) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", 88)
	l.add_theme_color_override("font_color", col)
	if align == HORIZONTAL_ALIGNMENT_LEFT:
		l.position = Vector2(pos.x, pos.y); l.size = Vector2(560, 110)
	else:
		l.position = Vector2(1920 - 560 - 40, pos.y); l.size = Vector2(560, 110)
	l.horizontal_alignment = align
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l

func _data_label(pos: Vector2, align: int) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", 24)
	l.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	l.position = pos; l.size = Vector2(320, 180)
	l.horizontal_alignment = align
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l

func _refresh() -> void:
	# cartas: cursor 1P (rojo) sobre sel1, 2P (azul) sobre sel2; el activo late
	for i in cards.size():
		var col := Color(0.0, 0.0, 0.0)
		if i == sel1:
			col = Color(0.95, 0.25, 0.22)
		if i == sel2:
			col = Color(0.35, 0.55, 1.0) if i != sel1 else Color(0.7, 0.4, 0.7)  # ambos = morado
		cards[i]["border"].color = col
	# retratos de pie + nombres + data
	var c1: Dictionary = roster[sel1]
	var c2: Dictionary = roster[sel2]
	_set_stand(stand_l, c1)
	_set_stand(stand_r, c2)
	name_l.text = String(c1["name"])
	name_r.text = String(c2["name"])
	data_l.text = "CHARACTER DATA\nCLASS:  %s\nWEAPON: %s\nPOWER:  %s" % [c1["arch"], c1["weapon"], c1["power"]]
	data_r.text = "CHARACTER DATA\nCLASS:  %s\nWEAPON: %s\nPOWER:  %s" % [c2["arch"], c2["weapon"], c2["power"]]
	prompt.text = "1P: elige TU personaje   (← →  ·  ENTER confirmar  ·  ESC atrás)" if picking == 0 \
		else "2P: elige el personaje de la CPU   (← →  ·  ENTER confirmar  ·  ESC atrás)"

func _set_stand(node: TextureRect, c: Dictionary) -> void:
	# usa el retrato de pie DEDICADO del char-select; si no existe, cae al pose full-body
	var path := String(c.get("stand", ""))
	if not ResourceLoader.exists(path):
		path = String(c.get("stand_fallback", ""))
	if ResourceLoader.exists(path):
		node.texture = load(path)
	else:
		node.texture = null

func _process(delta: float) -> void:
	t += delta
	var pulse := 0.65 + 0.35 * sin(t * 7.0)
	# el cursor ACTIVO late
	var active := sel1 if picking == 0 else sel2
	if active < cards.size():
		cards[active]["border"].modulate.a = pulse
	# el retrato activo resalta un poco
	stand_l.modulate = Color(1, 1, 1, 1.0 if picking == 0 else 0.55)
	stand_r.modulate = Color(1, 1, 1, 1.0 if picking == 1 else 0.55)

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
		_refresh()
		return
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack"):
		if picking == 0:
			picking = 1
			_refresh()
		else:
			Sel.p1 = String(roster[sel1]["id"])
			Sel.p2 = String(roster[sel2]["id"])
			Sel.configured = true
			get_tree().change_scene_to_file("res://main.tscn")
	elif Input.is_action_just_pressed("ui_cancel"):
		if picking == 1:
			picking = 0
			_refresh()
		else:
			get_tree().change_scene_to_file("res://title.tscn")
