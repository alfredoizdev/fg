extends Node2D
# Santuario Dorado — plaza del templo al atardecer (stage 4). Dos keyframes del
# video generado: base = luz TENUE (faroles siempre encendidos), encima la capa
# BRILLANTE con alfa pulsante. La luz "respira" tenue -> dorada -> tenue en loop
# perfecto (~2.4s, mismo ritmo del clip), sin frames de video: casi cero VRAM.

var t := 0.0
var dim: Texture2D = null
var bright: Texture2D = null

func _ready() -> void:
	z_index = -1
	if ResourceLoader.exists("res://imagen-action/stage/santuario-dim.png"):
		dim = load("res://imagen-action/stage/santuario-dim.png")
	if ResourceLoader.exists("res://imagen-action/stage/santuario-bright.png"):
		bright = load("res://imagen-action/stage/santuario-bright.png")
	# motas de polvo dorado a contraluz (mas sutiles que en el templo)
	var motas := CPUParticles2D.new()
	motas.position = Vector2(960, 680)
	motas.amount = 50
	motas.lifetime = 9.0
	motas.preprocess = 9.0
	motas.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	motas.emission_rect_extents = Vector2(950, 300)
	motas.direction = Vector2(-0.3, -1)
	motas.spread = 70.0
	motas.gravity = Vector2(-5, -7)
	motas.initial_velocity_min = 3.0
	motas.initial_velocity_max = 12.0
	motas.scale_amount_min = 1.1
	motas.scale_amount_max = 2.4
	motas.color = Color(1.35, 1.05, 0.55, 0.45)
	add_child(motas)

func _process(delta: float) -> void:
	t += delta
	queue_redraw()

func _draw() -> void:
	if dim != null:
		draw_texture_rect(dim, Rect2(0, 0, 1920, 1080), false)
	if bright != null:
		# respiracion de la luz: nunca se apaga (el minimo es la base tenue). Ritmo del
		# clip aprobado (~5.3s): sube -> pico -> baja -> PAUSA calma (el pow acentua la
		# pausa en tenue y afila el pico). Parpadeo secundario leve anti-metronomo.
		var a := 0.5 - 0.5 * cos(TAU * t / 5.3)
		a = pow(a, 1.6)
		a = clampf(a + 0.04 * sin(t * 9.3) * sin(t * 3.1), 0.0, 1.0)
		draw_texture_rect(bright, Rect2(0, 0, 1920, 1080), false, Color(1, 1, 1, a))
