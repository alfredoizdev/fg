extends Node2D
# Noche de Luna — escenario 100% por codigo, en capas para profundidad:
# nebula, estrellas (algunas con destello en cruz), estrellas fugaces, nubes
# a la deriva (una cruza la luna), luna grande con halo y crateres, TRES
# capas de montanas con niebla entre ellas y picos nevados a la luz de la
# luna, pagodas/edificios en silueta con luz de borde y ventanas calidas,
# reflejo de luna en el piso, luciernagas y petalos.

var t := 0.0
var estrellas := []       # [x, y, radio, fase, vel, brillante]
var nubes := []           # {x, y, vel, partes:[dx,dy,rx,ry]}
var meteoro := []         # [pos, dir, vida] (vacio = ninguno)
var prox_meteoro := 3.0
var picos_lejos := PackedVector2Array()
var picos_medio := PackedVector2Array()
var picos_cerca := PackedVector2Array()
var nevados := []         # cimas [Vector2]
var siluetas := []        # {poly: PackedVector2Array, x0, x1}
var ventanas := []        # [rect, fase, vel]

func _ready() -> void:
	z_index = -1
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260804
	for i in 130:
		estrellas.append([rng.randf_range(0, 1920), rng.randf_range(0, 640),
				rng.randf_range(1.0, 2.6), rng.randf_range(0, TAU),
				rng.randf_range(0.4, 1.6), rng.randf() < 0.12])
	# nubes: racimos de elipses
	for i in 4:
		var partes := []
		for j in 5:
			partes.append([rng.randf_range(-160, 160), rng.randf_range(-30, 30),
					rng.randf_range(90, 180), rng.randf_range(26, 48)])
		nubes.append({"x": rng.randf_range(0, 1920), "y": rng.randf_range(120, 420),
				"vel": rng.randf_range(6.0, 14.0), "partes": partes})
	# tres cordilleras (cuanto mas cerca, mas baja y oscura)
	picos_lejos = _cordillera(rng, 500, 660, 130, 240)
	picos_medio = _cordillera(rng, 620, 760, 150, 280)
	picos_cerca = _cordillera(rng, 740, 850, 190, 330)
	# cimas nevadas de la cordillera lejana (las puntas mas altas)
	for i in range(1, picos_lejos.size() - 3):
		var p := picos_lejos[i]
		if p.y < 580 and rng.randf() < 0.7:
			nevados.append(p)
	# horizonte urbano: pagodas y torres en silueta a los lados
	for lado in [[40.0, 700.0], [1220.0, 1880.0]]:
		var x: float = lado[0]
		while x < lado[1]:
			if rng.randf() < 0.35:
				x += _pagoda(rng, x)
			else:
				x += _torre(rng, x)
			x += rng.randf_range(14, 50)
	# luciernagas
	var fl := CPUParticles2D.new()
	fl.position = Vector2(960, 840)
	fl.amount = 24
	fl.lifetime = 6.0
	fl.preprocess = 6.0
	fl.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fl.emission_rect_extents = Vector2(920, 90)
	fl.direction = Vector2(0, -1)
	fl.spread = 80.0
	fl.gravity = Vector2(0, -4)
	fl.initial_velocity_min = 6.0
	fl.initial_velocity_max = 18.0
	fl.scale_amount_min = 1.5
	fl.scale_amount_max = 3.0
	fl.color = Color(1.2, 1.05, 0.45, 0.8)
	add_child(fl)
	# petalos cayendo a la deriva
	var pt := CPUParticles2D.new()
	pt.position = Vector2(960, -30)
	pt.amount = 18
	pt.lifetime = 11.0
	pt.preprocess = 11.0
	pt.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	pt.emission_rect_extents = Vector2(1100, 10)
	pt.direction = Vector2(-0.3, 1)
	pt.spread = 20.0
	pt.gravity = Vector2(-14, 26)
	pt.initial_velocity_min = 12.0
	pt.initial_velocity_max = 30.0
	pt.angular_velocity_min = -90.0
	pt.angular_velocity_max = 90.0
	pt.scale_amount_min = 2.0
	pt.scale_amount_max = 3.6
	pt.color = Color(0.95, 0.62, 0.72, 0.55)
	add_child(pt)

func _cordillera(rng: RandomNumberGenerator, y_min: float, y_max: float, paso_min: float, paso_max: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	pts.append(Vector2(0, y_max))
	var x := 0.0
	var sube := true
	while x < 1920.0:
		x += rng.randf_range(paso_min, paso_max)
		var y := rng.randf_range(y_min, y_min + 40) if sube else rng.randf_range(y_max - 40, y_max)
		pts.append(Vector2(minf(x, 1920), y))
		sube = not sube
	pts.append(Vector2(1920, y_max))
	pts.append(Vector2(1920, 960))
	pts.append(Vector2(0, 960))
	return pts

func _pagoda(rng: RandomNumberGenerator, x: float) -> float:
	var w := rng.randf_range(110, 160)
	var pisos := rng.randi_range(2, 3)
	var base_y := 950.0
	var alto_piso := rng.randf_range(52, 70)
	var poly := PackedVector2Array()
	var cx := x + w * 0.5
	# construye el contorno subiendo por la izquierda y bajando por la derecha
	var izq := []
	var der := []
	for p in pisos:
		var pw: float = w * (1.0 - 0.22 * p)
		var techo_y := base_y - alto_piso * (p + 1)
		var alero: float = pw * 0.18
		izq.append(Vector2(cx - pw * 0.5 - alero, techo_y + 14))
		izq.append(Vector2(cx - pw * 0.5, techo_y))
		der.append(Vector2(cx + pw * 0.5 + alero, techo_y + 14))
		der.append(Vector2(cx + pw * 0.5, techo_y))
	poly.append(Vector2(x, base_y))
	for v in izq:
		poly.append(v)
	poly.append(Vector2(cx - 6, base_y - alto_piso * pisos - 26))
	poly.append(Vector2(cx, base_y - alto_piso * pisos - 44))
	poly.append(Vector2(cx + 6, base_y - alto_piso * pisos - 26))
	der.reverse()
	for v in der:
		poly.append(v)
	poly.append(Vector2(x + w, base_y))
	siluetas.append({"poly": poly, "x0": x, "x1": x + w})
	# ventanas del primer piso
	for i in rng.randi_range(1, 3):
		ventanas.append([Rect2(x + rng.randf_range(14, w - 30), base_y - alto_piso + rng.randf_range(10, 26), 11, 14),
				rng.randf_range(0, TAU), rng.randf_range(0.2, 2.0)])
	return w

func _torre(rng: RandomNumberGenerator, x: float) -> float:
	var w := rng.randf_range(80, 150)
	var h := rng.randf_range(200, 430)
	var poly := PackedVector2Array()
	poly.append(Vector2(x, 950))
	poly.append(Vector2(x, 950 - h))
	# remate: azotea con caseta o antena
	if rng.randf() < 0.5:
		poly.append(Vector2(x + w * 0.25, 950 - h))
		poly.append(Vector2(x + w * 0.25, 950 - h - 18))
		poly.append(Vector2(x + w * 0.55, 950 - h - 18))
		poly.append(Vector2(x + w * 0.55, 950 - h))
	else:
		poly.append(Vector2(x + w * 0.45, 950 - h))
		poly.append(Vector2(x + w * 0.48, 950 - h - rng.randf_range(24, 60)))
		poly.append(Vector2(x + w * 0.52, 950 - h))
	poly.append(Vector2(x + w, 950 - h))
	poly.append(Vector2(x + w, 950))
	siluetas.append({"poly": poly, "x0": x, "x1": x + w})
	var wy := 950.0 - h + 26.0
	while wy < 916.0:
		if rng.randf() < 0.45:
			ventanas.append([Rect2(x + rng.randf_range(8, w - 22), wy, 11, 14),
					rng.randf_range(0, TAU), rng.randf_range(0.2, 2.2)])
		wy += 42.0
	return w

func _process(delta: float) -> void:
	t += delta
	# estrellas fugaces de vez en cuando
	if meteoro.is_empty():
		prox_meteoro -= delta
		if prox_meteoro <= 0.0:
			var mr := RandomNumberGenerator.new()
			mr.seed = int(t * 997.0)
			meteoro = [Vector2(mr.randf_range(200, 1700), mr.randf_range(40, 260)),
					Vector2(mr.randf_range(-1.0, 1.0), 0.55).normalized(), 0.8]
			prox_meteoro = mr.randf_range(4.0, 9.0)
	else:
		meteoro[0] += meteoro[1] * 900.0 * delta
		meteoro[2] -= delta
		if meteoro[2] <= 0.0:
			meteoro = []
	queue_redraw()

func _elipse(pos: Vector2, rx: float, ry: float, col: Color) -> void:
	draw_set_transform(pos, 0.0, Vector2(1.0, ry / rx))
	draw_circle(Vector2.ZERO, rx, col)
	draw_set_transform(Vector2.ZERO)

func _draw() -> void:
	# cielo: degradado de tres paradas
	var arriba := Color(0.012, 0.02, 0.07)
	var medio := Color(0.07, 0.05, 0.18)
	var horizonte := Color(0.21, 0.11, 0.27)
	for y in range(0, 950, 10):
		var f := float(y) / 950.0
		var c: Color
		if f < 0.55:
			c = arriba.lerp(medio, f / 0.55)
		else:
			c = medio.lerp(horizonte, (f - 0.55) / 0.45)
		draw_rect(Rect2(0, y, 1920, 10), c)
	# nebula: banda diagonal de brumas de color
	_elipse(Vector2(420, 200), 420, 130, Color(0.35, 0.2, 0.6, 0.05))
	_elipse(Vector2(700, 320), 360, 110, Color(0.2, 0.3, 0.65, 0.05))
	_elipse(Vector2(260, 90), 260, 90, Color(0.5, 0.25, 0.55, 0.04))
	_elipse(Vector2(1000, 150), 300, 80, Color(0.3, 0.2, 0.6, 0.035))
	# estrellas (las brillantes con destello en cruz)
	for e in estrellas:
		var a: float = 0.3 + 0.45 * (0.5 + 0.5 * sin(t * e[4] + e[3]))
		var p := Vector2(e[0], e[1])
		draw_circle(p, e[2], Color(0.9, 0.95, 1.08, a))
		if e[5]:
			var L: float = e[2] * 4.5
			draw_line(p + Vector2(-L, 0), p + Vector2(L, 0), Color(1.0, 1.0, 1.15, a * 0.5), 1.2)
			draw_line(p + Vector2(0, -L), p + Vector2(0, L), Color(1.0, 1.0, 1.15, a * 0.5), 1.2)
	# estrella fugaz
	if not meteoro.is_empty():
		var vida: float = meteoro[2] / 0.8
		var cola: Vector2 = meteoro[0] - meteoro[1] * 220.0 * vida
		draw_line(cola, meteoro[0], Color(0.7, 0.8, 1.1, 0.35 * vida), 2.0)
		draw_line(meteoro[0] - meteoro[1] * 70.0, meteoro[0], Color(1.3, 1.35, 1.5, 0.9 * vida), 3.0)
	# luna: halos, cuerpo, crateres
	var luna := Vector2(1520, 230)
	var resp: float = 1.0 + 0.035 * sin(t * 0.7)
	draw_circle(luna, 230 * resp, Color(0.5, 0.55, 0.9, 0.06))
	draw_circle(luna, 175 * resp, Color(0.55, 0.6, 0.95, 0.09))
	draw_circle(luna, 138 * resp, Color(0.6, 0.65, 1.0, 0.12))
	draw_circle(luna, 108, Color(1.14, 1.16, 1.06))
	draw_circle(luna + Vector2(-30, -22), 17, Color(0.9, 0.92, 0.87))
	draw_circle(luna + Vector2(24, 30), 12, Color(0.92, 0.94, 0.89))
	draw_circle(luna + Vector2(38, -34), 8, Color(0.91, 0.93, 0.88))
	draw_circle(luna + Vector2(-8, 42), 7, Color(0.93, 0.95, 0.9))
	draw_circle(luna + Vector2(-48, 20), 6, Color(0.92, 0.94, 0.89))
	# nubes a la deriva (translucidas; las que pasan frente a la luna la tapan)
	for n in nubes:
		var nx: float = fposmod(n["x"] + t * n["vel"], 2400.0) - 240.0
		for p in n["partes"]:
			_elipse(Vector2(nx + p[0], n["y"] + p[1]), p[2], p[3], Color(0.10, 0.10, 0.22, 0.35))
	# cordillera lejana con cimas nevadas a la luz de la luna
	draw_colored_polygon(picos_lejos, Color(0.10, 0.10, 0.23))
	for cima in nevados:
		draw_colored_polygon(PackedVector2Array([
			cima + Vector2(-26, 26), cima + Vector2(0, -2), cima + Vector2(26, 26)]),
			Color(0.55, 0.6, 0.85, 0.35))
	# niebla 1
	_elipse(Vector2(560, 700), 700, 60, Color(0.35, 0.35, 0.6, 0.05 + 0.02 * sin(t * 0.4)))
	_elipse(Vector2(1500, 690), 600, 55, Color(0.35, 0.35, 0.6, 0.05 + 0.02 * sin(t * 0.5 + 2.0)))
	# cordillera media
	draw_colored_polygon(picos_medio, Color(0.06, 0.06, 0.16))
	# niebla 2
	_elipse(Vector2(960, 800), 900, 65, Color(0.3, 0.3, 0.55, 0.06 + 0.02 * sin(t * 0.33 + 1.0)))
	# colinas cercanas
	draw_colored_polygon(picos_cerca, Color(0.035, 0.035, 0.105))
	# horizonte urbano en silueta con luz de borde lunar (lado derecho)
	for s in siluetas:
		draw_colored_polygon(s["poly"], Color(0.022, 0.022, 0.065))
		var poly: PackedVector2Array = s["poly"]
		for i in range(poly.size() - 1):
			var a2: Vector2 = poly[i]
			var b2: Vector2 = poly[i + 1]
			# borde iluminado: caras que miran hacia la luna (derecha/arriba)
			if b2.x >= a2.x and (b2.y < a2.y or absf(b2.y - a2.y) < 2.0) and a2.y < 948:
				draw_line(a2, b2, Color(0.38, 0.42, 0.7, 0.4), 2.0)
	# ventanas calidas parpadeando
	for v in ventanas:
		var a3: float = 0.5 + 0.35 * (0.5 + 0.5 * sin(t * v[2] + v[1]))
		draw_rect(v[0], Color(1.1, 0.75, 0.3, a3))
	# bruma al ras del piso
	_elipse(Vector2(960, 945), 1000, 40, Color(0.3, 0.32, 0.55, 0.07 + 0.02 * sin(t * 0.6)))
	# piso de piedra
	for y in range(950, 1080, 10):
		var f2 := float(y - 950) / 130.0
		draw_rect(Rect2(0, y, 1920, 10), Color(0.05, 0.045, 0.1).lerp(Color(0.025, 0.022, 0.06), f2))
	# reflejo de la luna sobre el piso
	draw_colored_polygon(PackedVector2Array([
		Vector2(1470, 950), Vector2(1570, 950), Vector2(1640, 1080), Vector2(1400, 1080)]),
		Color(0.5, 0.55, 0.95, 0.05))
	# borde del piso iluminado por la luna + juntas de losas
	draw_rect(Rect2(0, 948, 1920, 3), Color(0.3, 0.32, 0.6, 0.55))
	for x in range(140, 1920, 178):
		draw_line(Vector2(x, 956), Vector2(x - 14, 1080), Color(0.0, 0.0, 0.0, 0.25), 2.0)
