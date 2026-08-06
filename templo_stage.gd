extends Node2D
# Templo al Atardecer — base pintada (templo-base.png) + ambiente por codigo:
# niebla calida derivando entre las montanas, bruma al ras del piso, motas de
# polvo dorado flotando y rayos de sol suaves. Las llamas de los faroles se
# agregan cuando llegue su hoja (templo-llama-sheet).

var t := 0.0
var tex: Texture2D = null

func _ready() -> void:
	z_index = -1
	# base con el CIELO recortado (transparente): dibujamos un cielo vivo detras.
	# si aun no esta importada, cae a la base con cielo pintado.
	if ResourceLoader.exists("res://imagen-action/stage/templo-base-cielo.png"):
		tex = load("res://imagen-action/stage/templo-base-cielo.png")
	elif ResourceLoader.exists("res://imagen-action/stage/templo-base.png"):
		tex = load("res://imagen-action/stage/templo-base.png")
	# motas de polvo dorado a contraluz
	var motas := CPUParticles2D.new()
	motas.position = Vector2(960, 700)
	motas.amount = 80
	motas.lifetime = 8.0
	motas.preprocess = 8.0
	motas.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	motas.emission_rect_extents = Vector2(950, 320)
	motas.direction = Vector2(-0.4, -1)
	motas.spread = 70.0
	motas.gravity = Vector2(-6, -8)
	motas.initial_velocity_min = 4.0
	motas.initial_velocity_max = 14.0
	motas.scale_amount_min = 1.2
	motas.scale_amount_max = 2.6
	motas.color = Color(1.3, 1.0, 0.55, 0.55)
	add_child(motas)
	# hojas otonales cayendo despacio
	var hojas := CPUParticles2D.new()
	hojas.position = Vector2(960, -30)
	hojas.amount = 26
	hojas.lifetime = 12.0
	hojas.preprocess = 12.0
	hojas.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	hojas.emission_rect_extents = Vector2(1100, 10)
	hojas.direction = Vector2(-0.35, 1)
	hojas.spread = 25.0
	hojas.gravity = Vector2(-18, 22)
	hojas.initial_velocity_min = 10.0
	hojas.initial_velocity_max = 26.0
	hojas.angular_velocity_min = -120.0
	hojas.angular_velocity_max = 120.0
	hojas.scale_amount_min = 2.0
	hojas.scale_amount_max = 3.4
	hojas.color = Color(0.9, 0.45, 0.2, 0.6)
	add_child(hojas)
	# NOTA: los faroles de piedra ya vienen ENCENDIDOS pintados en la base nueva;
	# no montamos llamas de codigo encima (sus posiciones eran de la pintura vieja).
	# chispitas calidas subiendo desde las filas de faroles (ambos lados)
	for lado in [Vector2(330, 730), Vector2(1620, 700)]:
		var chispas := CPUParticles2D.new()
		chispas.position = lado
		chispas.amount = 26
		chispas.lifetime = 4.5
		chispas.preprocess = 4.5
		chispas.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		chispas.emission_rect_extents = Vector2(300, 60)
		chispas.direction = Vector2(0, -1)
		chispas.spread = 35.0
		chispas.gravity = Vector2(0, -26)
		chispas.initial_velocity_min = 10.0
		chispas.initial_velocity_max = 30.0
		chispas.scale_amount_min = 1.0
		chispas.scale_amount_max = 2.2
		chispas.color = Color(1.4, 0.85, 0.35, 0.7)
		add_child(chispas)
	# polen a la deriva cruzando la pantalla despacio
	var polen := CPUParticles2D.new()
	polen.position = Vector2(2000, 600)
	polen.amount = 20
	polen.lifetime = 16.0
	polen.preprocess = 16.0
	polen.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	polen.emission_rect_extents = Vector2(60, 380)
	polen.direction = Vector2(-1, 0.08)
	polen.spread = 12.0
	polen.gravity = Vector2(-4, 3)
	polen.initial_velocity_min = 90.0
	polen.initial_velocity_max = 150.0
	polen.scale_amount_min = 1.0
	polen.scale_amount_max = 1.8
	polen.color = Color(1.2, 1.05, 0.7, 0.45)
	add_child(polen)

func _process(delta: float) -> void:
	t += delta
	queue_redraw()

func _elipse(pos: Vector2, rx: float, ry: float, col: Color) -> void:
	draw_set_transform(pos, 0.0, Vector2(1.0, ry / rx))
	draw_circle(Vector2.ZERO, rx, col)
	draw_set_transform(Vector2.ZERO)

# color del gradiente de atardecer segun altura f (0 arriba, 1 al horizonte)
func _cielo_grad(f: float) -> Color:
	var stops := [
		[0.0, Color(0.55, 0.24, 0.30)],   # cenit: violeta-rojizo profundo
		[0.35, Color(0.92, 0.42, 0.22)],  # naranja intenso
		[0.65, Color(1.15, 0.62, 0.28)],  # dorado
		[1.0, Color(1.35, 0.85, 0.45)],   # brillante junto a las montanas
	]
	for i in range(stops.size() - 1):
		var a: Array = stops[i]
		var b: Array = stops[i + 1]
		if f <= float(b[0]):
			var k: float = (f - float(a[0])) / maxf(0.0001, float(b[0]) - float(a[0]))
			return (a[1] as Color).lerp(b[1] as Color, clampf(k, 0.0, 1.0))
	return stops[-1][1]

# cielo animado: gradiente que respira + sol con halo + nubes en capas + aves
func _draw_sky() -> void:
	# el cielo cubre desde arriba hasta bajo el horizonte del templo (~y=560)
	var alto := 560.0
	var pasos := 36
	var pulso := 0.04 * sin(t * 0.3)
	for i in pasos:
		var f := float(i) / float(pasos)
		var y0 := f * alto
		var col := _cielo_grad(f)
		col = Color(col.r + pulso, col.g + pulso * 0.6, col.b, 1.0)
		draw_rect(Rect2(0.0, y0, 1920.0, alto / float(pasos) + 1.0), col)
	# SOL: nucleo HDR que florece con el bloom + halo que respira
	var sol := Vector2(1430.0, 360.0)
	var resp := 1.0 + 0.06 * sin(t * 0.7)
	for capa in [[240.0, 0.10], [170.0, 0.14], [110.0, 0.22]]:
		draw_circle(sol, float(capa[0]) * resp, Color(1.5, 1.0, 0.55, float(capa[1])))
	draw_circle(sol, 70.0 * resp, Color(1.8, 1.35, 0.85, 0.85))
	draw_circle(sol, 52.0 * resp, Color(2.2, 1.8, 1.2, 1.0))
	# NUBES en 3 capas horizontales derivando a ritmos distintos (envuelven la luz)
	var capas_nube := [
		[150.0, 18.0, 320.0, 60.0, 0.22, Color(1.25, 0.7, 0.45)],
		[250.0, 11.0, 400.0, 74.0, 0.20, Color(0.85, 0.4, 0.35)],
		[380.0, 7.0, 500.0, 90.0, 0.16, Color(0.6, 0.28, 0.32)],
	]
	for c in capas_nube:
		var y: float = c[0]
		var vel: float = c[1]
		var rx: float = c[2]
		var ry: float = c[3]
		var al: float = c[4]
		var col: Color = c[5]
		for j in 4:
			var base_x := fposmod(t * vel + j * 620.0, 2560.0) - 320.0
			var yy := y + 20.0 * sin(t * 0.2 + j * 1.5)
			_elipse(Vector2(base_x, yy), rx, ry, Color(col.r, col.g, col.b, al))
			_elipse(Vector2(base_x + rx * 0.5, yy + ry * 0.3), rx * 0.6, ry * 0.7,
					Color(col.r, col.g, col.b, al * 0.8))
	# AVES lejanas cruzando muy despacio: silueta pequena de gaviota (puntas
	# caidas hacia un piquito central) para que no parezcan dos palos
	for k in 5:
		var bx := fposmod(t * 26.0 + k * 430.0, 2300.0) - 200.0
		var by := 150.0 + 55.0 * sin(t * 0.5 + k * 2.1) + k * 12.0
		var flap := 2.4 + 1.8 * sin(t * 5.0 + k)
		var col_ave := Color(0.22, 0.11, 0.13, 0.45)
		draw_polyline(PackedVector2Array([
			Vector2(bx - 6.0, by + 1.0),
			Vector2(bx - 2.5, by - flap),
			Vector2(bx, by - flap * 0.35),
			Vector2(bx + 2.5, by - flap),
			Vector2(bx + 6.0, by + 1.0)]), col_ave, 1.4, true)

func _draw() -> void:
	# CIELO VIVO detras del templo (el cielo de la base esta recortado)
	_draw_sky()
	# base pintada con cielo transparente encima
	if tex:
		draw_texture_rect(tex, Rect2(0, 0, 1920, 1080), false)
	else:
		draw_rect(Rect2(0, 0, 1920, 1080), Color(0.35, 0.18, 0.1))
	# niebla calida derivando entre las montanas (dos bandas a ritmos distintos)
	var d1: float = fposmod(t * 12.0, 600.0) - 300.0
	var d2: float = fposmod(t * 7.0, 500.0) - 250.0
	_elipse(Vector2(700 + d1, 640), 640, 46, Color(0.95, 0.8, 0.7, 0.06 + 0.02 * sin(t * 0.5)))
	_elipse(Vector2(1350 - d2, 600), 540, 40, Color(0.95, 0.82, 0.72, 0.05 + 0.02 * sin(t * 0.4 + 2.0)))
	# bruma al ras del piso
	_elipse(Vector2(960 + 40.0 * sin(t * 0.25), 940), 1000, 34, Color(0.9, 0.75, 0.6, 0.05 + 0.015 * sin(t * 0.6)))
	# rayos de sol suaves desde el sol (lado derecho)
	var sol := Vector2(1815, 430)
	for i in 3:
		var ang: float = PI + 0.35 + i * 0.22 + 0.03 * sin(t * 0.3 + i)
		var dirv := Vector2(cos(ang), sin(ang))
		var perp := Vector2(-dirv.y, dirv.x) * (26.0 + i * 14.0)
		var a: float = 0.035 + 0.015 * sin(t * 0.45 + i * 1.7)
		draw_colored_polygon(PackedVector2Array([
			sol + perp * 0.2, sol - perp * 0.2,
			sol + dirv * 1500.0 - perp, sol + dirv * 1500.0 + perp]),
			Color(1.2, 0.9, 0.5, a))
