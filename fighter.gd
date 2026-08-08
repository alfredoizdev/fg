class_name Fighter
extends Node2D

# Peleador reutilizable: jugador o muneco de practica (is_player = false).
# Siempre mira al rival (facing lo asigna main.gd); nunca usa flip por movimiento.

# escala visual del personaje: debe coincidir con scale de Player/Dummy en
# main.tscn; velocidades y alcances se derivan de ella para conservar el feel
const CHAR_SCALE := 0.65

const WALK_SPEED := 620.0 * CHAR_SCALE      # mas rapido: que no patinen los pies
const WALK_BACK_SPEED := 470.0 * CHAR_SCALE
const JUMP_SPEED := 1850.0 * CHAR_SCALE
const GRAVITY := 4200.0 * CHAR_SCALE
const KNOCKBACK_X := 650.0 * CHAR_SCALE
const KNOCKBACK_Y := 2200.0 * CHAR_SCALE

const SHADOW_FEET_OFFSET := 500.0
const SHADOW_RADIUS := 125.0
const SHADOW_SQUASH := 0.3
const SHADOW_ALPHA := 0.3

# estela del corte: arco creciente que sigue a la hoja (se dibuja en _draw).
# Por animacion: base = primer frame con estela, c = centro del arco (px del
# lienzo), r = radio, w = grosor maximo, flat = achatado vertical (0.38 para
# barridos horizontales vistos de lado, 1.0 para tajos verticales en el plano
# de la pantalla), stages = [angulo inicio, angulo fin, alpha, multiplicador
# de radio opcional] por frame — el multiplicador deja crecer el abanico a lo
# largo del swing cuando el brazo se va estirando (ej. kick).
# Angulos: 0 = al frente, -90 = arriba, 180 = atras (y crece hacia abajo).
const SWING_FX := {
	# punch (Q) = EMPUJE horizontal al FRENTE: la estela sigue la hoja hacia adelante a la
	# altura del filo (NO un arco sobre la cabeza) y va sincronizada con el empuje (frames 1-4).
	"punch": {"base": 1, "c": Vector2(10, 150), "r": 610.0, "w": 320.0, "flat": 0.20,
		"stages": [[110.0, 5.0, 0.7], [120.0, -25.0, 1.0], [125.0, -35.0, 0.55], [95.0, -35.0, 0.25]]},
	"punch2": {"base": 1, "c": Vector2(10, 150), "r": 610.0, "w": 320.0, "flat": 0.20,
		"stages": [[110.0, 5.0, 0.7], [120.0, -25.0, 1.0], [125.0, -35.0, 0.55], [95.0, -35.0, 0.25]]},
	"kick": {"base": 2, "c": Vector2(30, -40), "r": 640.0, "w": 380.0, "flat": 1.0,
		"stages": [[-130.0, -95.0, 0.45, 0.85], [-120.0, -40.0, 0.9, 0.93], [-110.0, 20.0, 1.0, 1.0]]},
	"jump_punch": {"base": 1, "c": Vector2(20, 0), "r": 540.0, "w": 310.0, "flat": 0.38,
		"stages": [[215.0, 290.0, 0.8], [220.0, 350.0, 1.0], [260.0, 355.0, 0.4]]},
	"jump_kick": {"base": 1, "c": Vector2(0, 0), "r": 490.0, "w": 310.0, "flat": 1.0,
		"stages": [[-90.0, -10.0, 0.9], [-70.0, 45.0, 1.0]]},
	"crouch_kick": {"base": 1, "c": Vector2(20, 60), "r": 560.0, "w": 340.0, "flat": 1.0,
		"stages": [[70.0, 25.0, 0.5, 0.75], [60.0, -50.0, 1.0, 0.95], [-10.0, -125.0, 0.8, 1.0]]},
	"spin_kick": {"base": 1, "c": Vector2(0, 120), "r": 500.0, "w": 300.0, "flat": 0.38,
		"stages": [[150.0, 220.0, 0.5], [200.0, 340.0, 1.0], [340.0, 460.0, 0.7], [460.0, 560.0, 0.7], [560.0, 700.0, 1.0]]},
	"weak_punch": {"base": 1, "c": Vector2(20, 40), "r": 520.0, "w": 180.0, "flat": 0.38,
		"stages": [[325.0, 358.0, 0.9], [335.0, 358.0, 0.35]]},
	# air_spin_kick = DOBLE PATADA (sin estela de blade: la katana va quieta)
	"crouch_jab": {"base": 1, "c": Vector2(20, 300), "r": 560.0, "w": 170.0, "flat": 0.38,
		"stages": [[325.0, 358.0, 0.9], [335.0, 358.0, 0.35]]},
	"sweep": {"base": 1, "c": Vector2(10, 380), "r": 620.0, "w": 300.0, "flat": 0.38,
		"stages": [[195.0, 120.0, 0.6, 0.8], [150.0, 5.0, 1.0, 1.0], [60.0, -15.0, 0.7, 1.0], [25.0, -35.0, 0.35, 0.95]]},
}

# frame que conecta, alcance y dano de cada ataque (alcances en px de pantalla)
# daño por TIER:  flojo (R) = 50 · medio (Q) = 90 · fuerte (W/E) = 100
const ATTACKS := {
	"punch":        {"hit_frame": 2, "reach": 600.0 * CHAR_SCALE, "low": false, "damage": 90},
	"punch2":       {"hit_frame": 4, "reach": 600.0 * CHAR_SCALE, "low": false, "damage": 90},
	"kick":         {"hit_frame": 4, "reach": 600.0 * CHAR_SCALE, "low": false, "damage": 100},
	"crouch_punch": {"hit_frame": 1, "reach": 620.0 * CHAR_SCALE, "low": true,  "damage": 90},
	"crouch_jab":   {"hit_frame": 1, "reach": 640.0 * CHAR_SCALE, "low": true,  "damage": 50},
	"sweep":        {"hit_frame": 2, "reach": 700.0 * CHAR_SCALE, "low": true,  "trip": true, "damage": 100},
	"crouch_kick":  {"hit_frame": 2, "reach": 640.0 * CHAR_SCALE, "low": false, "strong": true, "damage": 100},
	"jump_punch":   {"hit_frame": 2, "reach": 550.0 * CHAR_SCALE, "low": false, "damage": 90},
	"jump_kick":    {"hit_frame": 2, "reach": 500.0 * CHAR_SCALE, "low": false, "damage": 100},
	"spin_kick":    {"hit_frame": 2, "reach": 520.0 * CHAR_SCALE, "low": false, "strong": true, "damage": 100, "impact_sfx": "kick_impact"},
	"air_spin_kick": {"hit_frame": 4, "reach": 580.0 * CHAR_SCALE, "low": false, "strong": true, "damage": 100, "impact_sfx": "kick_impact"},
	"weak_punch":   {"hit_frame": 1, "reach": 480.0 * CHAR_SCALE, "low": false, "damage": 50},
}

const FLY_TILT_DEG := 34.0   # inclinación del cuerpo al salir volando (se ladea hacia el empujón)
const SPIN_TRAVEL := 600.0 * CHAR_SCALE  # avance de la patada giratoria (px/s)
const SPIN_HOVER := 130.0 * CHAR_SCALE   # elevacion durante el giro
const SPECIAL_SPEED := 1500.0 * CHAR_SCALE  # embestida del EMBER DASH (px/s)
const SPECIAL_TIME := 0.34                  # duracion del dash
const HIT_ANIMS := ["take_hit", "take_hit_low", "block", "block_low"]

# sonidos por animacion: al entrar una animacion suena su efecto (si existe)
const SFX_FILES := {
	"weak_punch": "res://imagen-action/sound-effect/weak-sound-sword.mp3",
	"crouch_jab": "res://imagen-action/sound-effect/weak-sound-sword.mp3",
	"block": "res://imagen-action/sound-effect/sword-block.mp3",
	"block_low": "res://imagen-action/sound-effect/sword-block.mp3",
	"punch": "res://imagen-action/sound-effect/sword-slash-and-swing.mp3",
	"punch2": "res://imagen-action/sound-effect/sword-slash-and-swing.mp3",
	"kick": "res://imagen-action/sound-effect/sword-slash-and-swing.mp3",
	"crouch_punch": "res://imagen-action/sound-effect/sword-slash-and-swing.mp3",
	"crouch_kick": "res://imagen-action/sound-effect/sword-slash-and-swing.mp3",
	"sweep": "res://imagen-action/sound-effect/sword-slash-and-swing.mp3",
	"jump_punch": "res://imagen-action/sound-effect/sword-slash-and-swing.mp3",
	"jump_kick": "res://imagen-action/sound-effect/sword-slash-and-swing.mp3",
	"spin_kick": "res://imagen-action/sound-effect/sword-slash-and-swing.mp3",
	"take_hit": "res://imagen-action/sound-effect/kick-impact.mp3",
	"take_hit_low": "res://imagen-action/sound-effect/kick-impact.mp3",
	"hit_fly": "res://imagen-action/sound-effect/kick-impact.mp3",
	"fly_straight": "res://imagen-action/sound-effect/kick-impact.mp3",
	"kick_impact": "res://imagen-action/sound-effect/kick-impact.mp3",
	"hit_down": "res://imagen-action/sound-effect/impact-sword.mp3",
	"wall_bounce": "res://imagen-action/sound-effect/hard-impact-2.mp3",
}
var sfx := {}
# arranque por sonido (medido): salta silencio/aire para que el golpe caiga al instante
const SFX_START := {
	"weak_punch": 0.12, "crouch_jab": 0.12,
	"block": 0.20, "block_low": 0.20,
	"take_hit": 0.62, "take_hit_low": 0.62, "hit_fly": 0.62, "kick_impact": 0.62,
	"fly_straight": 0.62,
	"hit_down": 0.05, "wall_bounce": 0.0,
	"punch": 0.10, "punch2": 0.10, "kick": 0.10, "crouch_punch": 0.10,
	"crouch_kick": 0.10, "jump_punch": 0.10, "jump_kick": 0.10,
	"spin_kick": 0.10, "air_spin_kick": 0.10, "sweep": 0.10,
}
# volumen por sonido: los swings de fondo, los impactos al frente
const SFX_VOL := {
	"weak_punch": -7.0, "crouch_jab": -7.0,
	"punch": -7.0, "punch2": -7.0, "kick": -7.0, "crouch_punch": -7.0,
	"crouch_kick": -7.0, "jump_punch": -7.0, "jump_kick": -7.0,
	"spin_kick": -7.0, "air_spin_kick": -7.0, "sweep": -7.0,
	"block": -2.0, "block_low": -2.0,
}
# swings que el impacto interrumpe al conectar
const SWING_SFX := ["weak_punch", "crouch_jab", "punch", "punch2", "kick", "crouch_punch",
	"crouch_kick", "jump_punch", "jump_kick", "spin_kick", "air_spin_kick", "sweep"]
# boton al que pertenece cada golpe: el mismo boton NO encadena consigo mismo
const BTN_FAMILY := {
	"punch": "attack", "punch2": "attack", "jump_punch": "attack", "crouch_punch": "attack",
	"kick": "kick", "jump_kick": "kick", "crouch_kick": "kick",
	"spin_kick": "spin_kick", "air_spin_kick": "spin_kick", "sweep": "spin_kick",
	"weak_punch": "weak_punch", "crouch_jab": "weak_punch",
}
# escalera de fuerza: solo se cancela hacia golpes mas fuertes (R→Q→W→E)
const BTN_LEVEL := {"weak_punch": 1, "attack": 2, "kick": 3, "spin_kick": 4}
const ANIM_LEVEL := {
	"weak_punch": 1, "crouch_jab": 1,
	"punch": 2, "punch2": 2, "crouch_punch": 2, "jump_punch": 2,
	"kick": 3, "crouch_kick": 3, "jump_kick": 3,
	"spin_kick": 4, "air_spin_kick": 4, "sweep": 4,
}
var sfx_key := ""

@export var is_player := true
@export var archetype := "assassin"   # define la vida: assassin 1200 · wizard 1000 · warrior 1500

var input_enabled := true
# EMBER DASH (↓→+Q): estado del especial
var special_t := 0.0
var dash_border_on := false   # borde rojo eléctrico activo durante el EMBER DASH
var ghost_timer := 0.0
var down_recent_t := 0.0
# DASH DE AGUJAS de Fe (←→+Q): embestida que NO levanta; si conecta, 3 golpes en el sitio
const FE_DASH_SPEED := 1350.0 * CHAR_SCALE   # velocidad de la embestida (px/s)
const FE_DASH_TIME := 0.28                   # cuánto persigue antes de rendirse
var fe_dash_t := 0.0        # >0 = embistiendo hacia adelante (mueve el cuerpo)
var fe_dash_active := false # true toda la secuencia (embestida + 3 golpes): el árbitro pega, no la anim
var back_recent_t := 0.0   # memoria de ATRÁS reciente (para el motion ←→ del dash)
var dash_voz_sfx: AudioStream = null   # voz "water way" al arrancar el dash (carga perezosa)
var spin_voz_sfx: AudioStream = null   # voz "Power Twister" al girar (peonza, carga perezosa)
var fire_trail: CPUParticles2D
var wall_squash_t := 0.0  # aplaston contra la pared/piso: compresion breve del sprite
var squash_horizontal := true  # true = contra pared (comprime ancho); false = piso
const SQUASH_DUR := 0.15
# breaker con movimiento (↑↑+E): doble toque arriba reciente + sombras del mortal
var up_tap_t := 0.0
var double_up_t := 0.0
var down_tap_t := 0.0
var double_down_t := 0.0
var breaker_fx_t := 0.0
var debris_frames: SpriteFrames = null  # escombros del estrellon (carga perezosa)
# comando del ULTRA (→ R R): cuenta las R con adelante reciente
var ultra_r_t := 0.0
var ultra_r_n := 0
var fwd_recent_t := 0.0
var hard_fall := false   # remate del ULTRA: caida acelerada y estrellon fuerte
var ultra_hover := false # juggle aereo durante el ULTRA: se sostiene flotando
var dash_smoke_cd := 0.0 # enfriamiento del humo en golpes fuertes
# combos de la IA: cadenas validas de la escalera (debil→fuerte, sin repetir boton)
const AI_COMBOS := [
	["weak_punch", "punch", "kick"],
	["weak_punch", "crouch_punch", "crouch_kick", "spin_kick"],
	["punch", "kick", "spin_kick"],
	["weak_punch", "punch", "sweep"],
	["crouch_jab", "crouch_punch", "crouch_kick"],
]
var ai_combo := []

# IA del oponente (solo cuando is_player = false)
var ai_enabled := false
var ai_target: Node2D = null
var ai_timer := 0.0
var ai_action := "idle"
var ai_break_drill := false   # modo BREAK PRACTICE: se lanza a encadenar combos sin parar

var facing := 1
var crouching := false
var koed := false
var airborne := false
var hit_flying := false
var walk_dir := 0
var spd := 1.0   # multiplicador de velocidad de desplazamiento por personaje (Favi = ágil)
var base_scale := Vector2.ONE   # escala base del sprite por personaje (Favi = nena, más chica)
var swing_layer: Node2D   # capa POR DELANTE del sprite para la estela del arma (z alto)
var fly_lean := 0.0   # dirección del empujón al salir volando (para inclinar el cuerpo en el aire)
var vel_y := 0.0
var vel_x := 0.0
var floor_y := 0.0
var punch_followup := false  # →+Q: segundo corte encadenado pendiente
var buffer_action := ""      # boton guardado esperando ventana de cancel
var buffer_t := 0.0
var breaker_ready := true    # combo breaker disponible (uno por ronda)
var breaker_inv_t := 0.0     # invencibilidad tras romper

# destello de impacto: chispas radiales al recibir un golpe
const BURST_TIME := 0.22
var burst_t := 0.0
var water_flash_t := 0.0   # tinte AZUL marino al ser golpeado por el poder de agua de Fe
var water_bg := false       # true = víctima volando por el agua: suelta sombras fantasma AZULES (hasta caer)
var burst_seed := 0
var burst_scale := 1.0
var burst_block := false   # true = flash de escudo (bloqueo), false = estallido de dano
var impact_sfx_override := ""  # sonido de impacto que pide el ataque entrante
var wall_bounced := false      # ya reboto contra la pared en este combo
var juggle_hits := 0           # lanzamientos seguidos: cada uno eleva menos

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var sfx_player: AudioStreamPlayer
var voz_player: AudioStreamPlayer   # voz/grito propio (SEPARADO del de impactos: suenan a la vez)

# efectos de impacto dibujados (hojas fx-hit / fx-block procesadas); si aun
# no estan importados se usa el destello de codigo como respaldo
var fx_sprite: AnimatedSprite2D
var fx_anims := {}
var fx_blue := false   # true = chispas de impacto AZULES (Favi); false = naranja (DAM)
var fx_floral := false  # true = estela MORADA+ROSA floral (Aye); tiene prioridad sobre fx_blue

func _ready() -> void:
	floor_y = position.y
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	# player de VOZ aparte: el grito de Fe (cast/dash/spin/whirlpool) no debe cortarse
	# cuando llega un golpe (que suena en sfx_player). Los dos se oyen a la vez.
	voz_player = AudioStreamPlayer.new()
	add_child(voz_player)
	for k in SFX_FILES:
		if ResourceLoader.exists(SFX_FILES[k]):
			sfx[k] = load(SFX_FILES[k])
	fx_sprite = AnimatedSprite2D.new()
	var ff := SpriteFrames.new()
	var fx_defs := {
		"hit": ["res://imagen-action/impact-effect/chispas-impact-3/chispas-impact-3-%d.png", 8, 30.0],
		"hit_blue": ["res://imagen-action/impact-effect/chispas-impat-hit-favi/chispas-impat-hit-%d.png", 7, 26.0],
		# bloqueo: anillo de barrera AZUL de la hoja fx-block (nueva, 5 frames). Si
		# existe, _draw_hit_burst se salta el destello de codigo (no hay doble efecto).
		"block": ["res://imagen-action/impact-effect/fx-block/fx-block-%d.png", 5, 24.0],
	}
	for k in fx_defs:
		var d: Array = fx_defs[k]
		ff.add_animation(k)
		ff.set_animation_speed(k, d[2])
		ff.set_animation_loop(k, false)
		var completos := true
		for i in range(1, d[1] + 1):
			var ruta: String = d[0] % i
			if ResourceLoader.exists(ruta):
				ff.add_frame(k, load(ruta))
			else:
				completos = false
		if completos:
			fx_anims[k] = true
	fx_sprite.sprite_frames = ff
	fx_sprite.visible = false
	fx_sprite.z_index = 6
	add_child(fx_sprite)
	fx_sprite.animation_finished.connect(func() -> void: fx_sprite.visible = false)
	# brasas del EMBER DASH: solo emiten durante la embestida
	fire_trail = CPUParticles2D.new()
	fire_trail.emitting = false
	fire_trail.amount = 40
	fire_trail.lifetime = 0.4
	fire_trail.local_coords = false
	fire_trail.spread = 30.0
	fire_trail.gravity = Vector2(0, -160)
	fire_trail.initial_velocity_min = 150.0
	fire_trail.initial_velocity_max = 340.0
	fire_trail.scale_amount_min = 3.0
	fire_trail.scale_amount_max = 6.5
	fire_trail.color = Color(1.5, 0.7, 0.25, 0.9)
	add_child(fire_trail)
	# capa de la estela del arma: hija con z alto para dibujar POR DELANTE del cuerpo
	# (el sprite es hijo y tapa el _draw del peleador; la estela iba detrás del cuerpo)
	swing_layer = SwingLayer.new()
	swing_layer.z_index = 4   # delante del sprite (z 0), detrás de los impactos (fx_sprite z 6)
	add_child(swing_layer)
	sprite.play("pose")
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.animation_changed.connect(_on_animation_changed)

# golpes fuertes/lanzados que sueltan una rafaga de humo al ejecutarse
const SMOKE_MOVES := ["kick", "crouch_kick", "spin_kick", "air_spin_kick", "sweep"]

func _on_animation_changed() -> void:
	var nombre := String(sprite.animation)
	var es_impacto := nombre in ["take_hit", "take_hit_low", "hit_fly", "fly_straight"]
	if es_impacto and impact_sfx_override != "" and sfx.has(impact_sfx_override):
		nombre = impact_sfx_override
	_play_sfx_key(nombre)
	# humo de dash en golpes fuertes (con cooldown para no saturar en el ultra).
	# sale atras del personaje (extremo trasero), no adelante
	# ...pero NO durante el ULTRA de Fe (aéreo o en el suelo): sin humo en su combo cinemático
	var _mb := get_parent()
	var _en_ultra_fe: bool = fx_blue and _mb != null and bool(_mb.get("ultra_active"))
	if nombre in SMOKE_MOVES and dash_smoke_cd <= 0.0 and special_t <= 0.0 and not ultra_hover and not _en_ultra_fe:
		_spawn_dash_smoke(0.5, 200.0)
		dash_smoke_cd = 0.28

func _play_sfx_key(k: String) -> void:
	if sfx.has(k):
		sfx_key = k
		sfx_player.stream = sfx[k]
		sfx_player.pitch_scale = randf_range(0.94, 1.06)  # variacion natural
		sfx_player.volume_db = SFX_VOL.get(k, 0.0)
		sfx_player.play(SFX_START.get(k, 0.0))

# al conectar un golpe, el impacto del rival corta nuestro whoosh
func duck_swing() -> void:
	if sfx_player.playing and sfx_key in SWING_SFX:
		sfx_player.stop()

func set_facing(f: int) -> void:
	if f != 0 and f != facing and not airborne:
		facing = f
		sprite.flip_h = f < 0

func current_attack() -> Dictionary:
	# el mortal del breaker no es un golpe real (el impacto lo aplica on_breaker)
	if breaker_inv_t > 0.0:
		return {}
	# el DASH DE AGUJAS no pega por la animación: el árbitro (main._fe_dash_attack) mete los 3 golpes
	if fe_dash_active:
		return {}
	# durante el EMBER DASH el golpe es el especial (reusa el corte como pose)
	if special_t > 0.0 and sprite.is_playing():
		return {"name": "ember_dash", "frame": int(sprite.frame), "hit_frame": 1,
			"reach": 520.0 * CHAR_SCALE, "low": false, "strong": true,
			"damage": 130, "wall_launch": true, "impact_sfx": "kick_impact"}
	# PEONZA de Fe (E en el suelo): golpea DOS veces y NO levanta (el rival se queda en el
	# sitio). Dos ventanas con NOMBRES distintos para que el árbitro registre 2 impactos;
	# strong=false para no lanzar por los aires. SOLO Fe (DAM conserva su patada que levanta).
	if sprite.animation == "spin_kick" and sprite.is_playing() \
			and sprite.sprite_frames.has_animation("water_cast"):
		var fr := int(sprite.frame)
		if fr < 4:
			return {"name": "spin_kick", "frame": fr, "hit_frame": 2,
				"reach": 520.0 * CHAR_SCALE, "low": false, "strong": false,
				"damage": 60, "impact_sfx": "kick_impact"}
		return {"name": "spin_kick_2", "frame": fr, "hit_frame": 5,
			"reach": 520.0 * CHAR_SCALE, "low": false, "strong": false,
			"damage": 60, "impact_sfx": "kick_impact"}
	# PATADA AÉREA DOBLE de Fe (salto+R): 2 golpes ligeros que NO levantan. Dos ventanas con
	# NOMBRES distintos; hit_frame al ARRANQUE de cada ventana (0 y 2) para que ambos peguen
	# aunque la animación sea rápida (no depende de acertar un frame intermedio exacto).
	if sprite.animation == "air_jab" and sprite.is_playing():
		var afr := int(sprite.frame)
		if afr < 2:
			return {"name": "air_jab", "frame": afr, "hit_frame": 0,
				"reach": 460.0 * CHAR_SCALE, "low": false, "strong": false,
				"damage": 35, "impact_sfx": "kick_impact"}
		return {"name": "air_jab_2", "frame": afr, "hit_frame": 2,
			"reach": 460.0 * CHAR_SCALE, "low": false, "strong": false,
			"damage": 35, "impact_sfx": "kick_impact"}
	if sprite.animation in ATTACKS and sprite.is_playing():
		var a: Dictionary = ATTACKS[sprite.animation].duplicate()
		a["name"] = sprite.animation
		a["frame"] = sprite.frame
		return a
	return {}

func do_ko() -> void:
	koed = true
	crouching = false
	hit_flying = false
	airborne = false
	water_bg = false
	fe_dash_t = 0.0
	fe_dash_active = false
	vel_x = 0.0
	vel_y = 0.0
	position.y = floor_y
	sprite.play("ko")

func do_breaker() -> bool:
	if not breaker_ready or koed:
		return false
	breaker_ready = false
	hit_flying = false
	crouching = false
	punch_followup = false
	buffer_t = 0.0
	vel_x = 0.0
	breaker_inv_t = 0.7
	# DAM rompe con su mortal: brinco + patada giratoria envuelta en sombras
	if sprite.sprite_frames.has_animation("air_spin_kick"):
		if not airborne:
			airborne = true
			vel_y = -JUMP_SPEED * 0.55
		else:
			vel_y = minf(vel_y, -JUMP_SPEED * 0.45)
		sprite.play("air_spin_kick")
		breaker_fx_t = 2.2  # sombras fantasma varios segundos tras el break
	elif airborne:
		vel_y = maxf(vel_y, 0.0)
		sprite.play("jump")
		sprite.frame = sprite.sprite_frames.get_frame_count("jump") - 2
	else:
		sprite.play("pose")
	# sin destello de bloqueo en el que rompe: solo el mortal con sombras.
	# el impacto (chispas + sonido) sale sobre el atacante via on_breaker.
	_play_sfx_key("block")
	return true

func revive() -> void:
	koed = false
	crouching = false
	hit_flying = false
	airborne = false
	water_bg = false
	fe_dash_t = 0.0
	fe_dash_active = false
	punch_followup = false
	juggle_hits = 0
	wall_bounced = false
	hard_fall = false
	ultra_hover = false
	breaker_ready = true
	breaker_inv_t = 0.0
	vel_x = 0.0
	vel_y = 0.0
	position.y = floor_y
	sprite.play("pose")

func celebrate() -> void:
	crouching = false
	sprite.play("victory")
	var m := get_parent()          # el ganador dice su frase de victoria (boca sincronizada)
	if m and m.has_method("_play_victory_line"):
		m._play_victory_line(self)

func is_downed() -> bool:
	return hit_flying or (sprite.animation == "hit_down" and sprite.is_playing())

func _burst(escala: float, block := false, lado := 1, blue := false, alto := 0.0) -> void:
	burst_t = BURST_TIME
	burst_seed = randi()
	burst_scale = escala
	burst_block = block
	var anim := "block" if block else ("hit_blue" if (blue and fx_anims.has("hit_blue")) else "hit")
	if fx_anims.has(anim):
		fx_sprite.position = Vector2(float(facing) * 150.0 * float(lado), alto)
		fx_sprite.flip_h = facing < 0
		fx_sprite.rotation = 0.0 if block else randf_range(-0.25, 0.25)
		fx_sprite.flip_v = false if block else randf() < 0.5
		var esc := (1.2 if block else 0.75) * escala * randf_range(0.9, 1.12)
		fx_sprite.scale = Vector2(esc, esc)
		fx_sprite.visible = true
		fx_sprite.play(anim)

# EMBER DASH (↓→+Q): embestida ardiente que lanza al rival muy alto
func _start_special() -> void:
	special_t = SPECIAL_TIME
	down_recent_t = 0.0
	punch_followup = false
	crouching = false
	_spawn_dash_smoke()   # ráfaga de humo al arrancar el dash
	sprite.play("punch")

# DASH DE AGUJAS de Fe (←→+Q): embiste hacia adelante SIN levantar al rival; si conecta,
# el árbitro (main._fe_dash_attack) aplica 3 golpes seguidos y lo deja en el sitio (sigue combo).
func _start_fe_dash() -> void:
	fe_dash_t = FE_DASH_TIME
	fe_dash_active = true
	back_recent_t = 0.0
	down_recent_t = 0.0
	punch_followup = false
	crouching = false
	_spawn_dash_smoke()
	# usa "dash" si ya hay frames reales, si no "punch" de placeholder
	sprite.play("dash" if sprite.sprite_frames.has_animation("dash") else "punch")
	# voz del dash (Fe grita "water way" al arrancar — versión enérgica, como el cast)
	var ruta := "res://imagen-action/favi/Fe-sound-effect/dash-fe-energetica.wav"
	if dash_voz_sfx == null and ResourceLoader.exists(ruta):
		dash_voz_sfx = load(ruta)
	if dash_voz_sfx != null:
		voz_player.stream = dash_voz_sfx
		voz_player.play()
	var mb := get_parent()
	if mb and mb.has_method("_fe_dash_attack"):
		mb._fe_dash_attack(self)

# humo de dash DIBUJADO (dash-dust, 6 frames): brota en el punto de arranque y se
# queda fijo; la cola se espeja segun la direccion del dash
var dashsmoke_frames: SpriteFrames = null
func _spawn_dash_smoke(escala := 0.75, atras := 0.0) -> void:
	if dashsmoke_frames == null:
		if not ResourceLoader.exists("res://imagen-action/dust-effect/dash-dust/dash-dust-1.png"):
			return
		dashsmoke_frames = SpriteFrames.new()
		dashsmoke_frames.add_animation("puff")
		dashsmoke_frames.set_animation_speed("puff", 22.0)
		dashsmoke_frames.set_animation_loop("puff", false)
		for i in range(1, 7):
			dashsmoke_frames.add_frame("puff", load("res://imagen-action/dust-effect/dash-dust/dash-dust-%d.png" % i))
	var ds := AnimatedSprite2D.new()
	ds.sprite_frames = dashsmoke_frames
	ds.animation = "puff"
	ds.z_index = 1
	ds.flip_h = facing < 0   # la cola apunta hacia la direccion del dash
	var tex: Texture2D = dashsmoke_frames.get_frame_texture("puff", 0)
	var s := escala * absf(scale.x)
	# desplaza el humo hacia ATRÁS (extremo trasero del personaje) a los pies
	var pies := to_global(Vector2(-float(facing) * atras, SHADOW_FEET_OFFSET))
	get_parent().add_child(ds)
	ds.global_position = pies - Vector2(0.0, tex.get_height() * s * 0.5)
	ds.scale = Vector2(s, s)
	ds.animation_finished.connect(ds.queue_free)
	ds.play("puff")

# escombros al estrellarse contra la pared: piedras y polvo dibujados por la IA
# (el borde derecho del lienzo es la pared; para la pared izquierda se espeja)
func _spawn_wall_debris(lado: int) -> void:
	if debris_frames == null:
		if not ResourceLoader.exists("res://imagen-action/impact-effect/wall-debris/wall-debris-1.png"):
			return
		debris_frames = SpriteFrames.new()
		debris_frames.add_animation("boom")
		debris_frames.set_animation_speed("boom", 13.0)
		debris_frames.set_animation_loop("boom", false)
		for i in range(1, 9):
			debris_frames.add_frame("boom", load("res://imagen-action/impact-effect/wall-debris/wall-debris-%d.png" % i))
	var d := AnimatedSprite2D.new()
	d.sprite_frames = debris_frames
	d.z_index = -1
	d.scale = Vector2(0.55, 0.55)
	var tex: Texture2D = debris_frames.get_frame_texture("boom", 0)
	# anclado al borde REAL de la pantalla (un poco enterrado para tapar margen)
	if lado > 0:
		d.position = Vector2(1935.0, 950.0)
		d.offset = Vector2(-tex.get_width() / 2.0, -tex.get_height() / 2.0)
	else:
		d.position = Vector2(-15.0, 950.0)
		d.flip_h = true
		d.offset = Vector2(tex.get_width() / 2.0, -tex.get_height() / 2.0)
	d.animation_finished.connect(d.queue_free)
	get_parent().add_child(d)
	d.play("boom")

# sombra fantasma del dash: copia del frame actual que se desvanece en rojo
# polvo de salto/aterrizaje: anillo de humo anime DIBUJADO (jump-dust, 6 frames)
var jumpdust_frames: SpriteFrames = null
func _spawn_jump_dust(escala := 0.7) -> void:
	if jumpdust_frames == null:
		if not ResourceLoader.exists("res://imagen-action/dust-effect/jump-dust/jump-dust-1.png"):
			return
		jumpdust_frames = SpriteFrames.new()
		jumpdust_frames.add_animation("puff")
		jumpdust_frames.set_animation_speed("puff", 20.0)
		jumpdust_frames.set_animation_loop("puff", false)
		for i in range(1, 7):
			jumpdust_frames.add_frame("puff", load("res://imagen-action/dust-effect/jump-dust/jump-dust-%d.png" % i))
	var jd := AnimatedSprite2D.new()
	jd.sprite_frames = jumpdust_frames
	jd.animation = "puff"
	jd.z_index = 1   # delante del escenario (que esta en z -1)
	var tex: Texture2D = jumpdust_frames.get_frame_texture("puff", 0)
	# el polvo va al MUNDO en la posicion global de los pies: se queda FIJO en el
	# piso aunque el personaje salte o se mueva (no es hijo del personaje)
	var s := escala * absf(scale.x)
	var pies := to_global(Vector2(0.0, SHADOW_FEET_OFFSET))
	get_parent().add_child(jd)
	jd.global_position = pies - Vector2(0.0, tex.get_height() * s * 0.5)
	jd.scale = Vector2(s, s)
	jd.animation_finished.connect(jd.queue_free)
	jd.play("puff")

# textura suave (circulo difuminado) para el fuego del INFIERNO
var soft_tex: Texture2D = null
func _soft_texture() -> Texture2D:
	if soft_tex != null:
		return soft_tex
	var s := 40
	var img := Image.create(s, s, false, Image.FORMAT_RGBA8)
	for y in s:
		for x in s:
			var d := Vector2(x - s / 2.0, y - s / 2.0).length() / (s / 2.0)
			img.set_pixel(x, y, Color(1, 1, 1, clampf(1.0 - d, 0.0, 1.0)))
	soft_tex = ImageTexture.create_from_image(img)
	return soft_tex

# PROYECTIL de fuego del INFIERNO: vórtice giratorio que sale del frente de DAM.
# Devuelve el nodo (main.gd lo mueve hacia el rival). null si no está importado.
var firewave_frames: SpriteFrames = null
func spawn_fire_wave() -> Node2D:
	if firewave_frames == null:
		if not ResourceLoader.exists("res://imagen-action/impact-effect/fire-wave/fire-wave-2.png"):
			return null
		firewave_frames = SpriteFrames.new()
		firewave_frames.add_animation("spin")
		firewave_frames.set_animation_speed("spin", 40.0)   # giro muy veloz
		firewave_frames.set_animation_loop("spin", true)
		# loop de los 6 vórtices (mismo tamaño, girando)
		for i in range(1, 7):
			firewave_frames.add_frame("spin", load("res://imagen-action/impact-effect/fire-wave/fire-wave-%d.png" % i))
	var w := AnimatedSprite2D.new()
	w.sprite_frames = firewave_frames
	w.animation = "spin"
	w.z_index = 5
	w.flip_h = facing < 0
	var s := 0.95 * absf(scale.x)   # vórtice grande
	w.scale = Vector2(s, s)
	get_parent().add_child(w)
	var tex: Texture2D = firewave_frames.get_frame_texture("spin", 0)
	# RUEDA por el suelo: su base queda apoyada al ras del piso
	var base := to_global(Vector2(float(facing) * 90.0, SHADOW_FEET_OFFSET))
	w.global_position = base - Vector2(0.0, tex.get_height() * s * 0.42)
	w.play("spin")
	return w

# EXPLOSIÓN de impacto del INFIERNO (6 frames dibujados): estalla UNA vez sobre el
# rival cuando el vórtice conecta y luego se apaga sola
var fireimpact_frames: SpriteFrames = null
func spawn_fire_impact() -> Node2D:
	if fireimpact_frames == null:
		if not ResourceLoader.exists("res://imagen-action/impact-effect/fire-wave-impact/fire-wave-impact-1.png"):
			return null
		fireimpact_frames = SpriteFrames.new()
		fireimpact_frames.add_animation("boom")
		fireimpact_frames.set_animation_speed("boom", 22.0)   # estallido rápido
		fireimpact_frames.set_animation_loop("boom", false)
		for i in range(1, 7):
			fireimpact_frames.add_frame("boom", load("res://imagen-action/impact-effect/fire-wave-impact/fire-wave-impact-%d.png" % i))
	var e := AnimatedSprite2D.new()
	e.sprite_frames = fireimpact_frames
	e.animation = "boom"
	e.z_index = 6   # por delante del vórtice
	var s := 0.85 * absf(scale.x)
	e.scale = Vector2(s, s)
	get_parent().add_child(e)
	# centrado en el torso del rival
	e.global_position = to_global(Vector2(0.0, SHADOW_FEET_OFFSET - 200.0))
	e.animation_finished.connect(e.queue_free)
	e.play("boom")
	return e

# ESPECIAL DE AGUA de Fe (medialuna + Q/W/E): clava la aguja al piso y grita; el géiser
# brota a 1/2/3 CUERPOS adelante (según el botón) — el jugador adivina dónde está el rival.
var water_cast_sfx: AudioStream = null
func _start_water_special(bodies: int) -> void:
	crouching = false
	airborne = false
	walk_dir = 0
	sprite.play("water_cast")
	# audio del cast (Fe llama el poder — versión enérgica/gritada)
	var ruta := "res://imagen-action/favi/Fe-sound-effect/water-cast-fe-energetica.wav"
	if water_cast_sfx == null and ResourceLoader.exists(ruta):
		water_cast_sfx = load(ruta)
	if water_cast_sfx != null:
		voz_player.stream = water_cast_sfx
		voz_player.play()
	var mb := get_parent()
	if mb and mb.has_method("_fe_water_special"):
		mb._fe_water_special(self, bodies)

# GÉISER de agua: brota del suelo en la x dada (bajo el rival), sube y se apaga solo.
var water_geyser_frames: SpriteFrames = null
func spawn_water_geyser(gx: float) -> Node2D:
	if water_geyser_frames == null:
		if not ResourceLoader.exists("res://imagen-action/impact-effect/water-geyser-fe/geyser-1.png"):
			return null
		water_geyser_frames = SpriteFrames.new()
		water_geyser_frames.add_animation("erupt")
		water_geyser_frames.set_animation_speed("erupt", 26.0)
		water_geyser_frames.set_animation_loop("erupt", false)
		for i in range(1, 9):
			water_geyser_frames.add_frame("erupt", load("res://imagen-action/impact-effect/water-geyser-fe/geyser-%d.png" % i))
	var g := AnimatedSprite2D.new()
	g.sprite_frames = water_geyser_frames
	g.animation = "erupt"
	g.z_index = 6
	var s := 0.62 * absf(scale.x)   # tamaño del géiser (~1.5x la nena)
	g.scale = Vector2(s, s)
	get_parent().add_child(g)
	# frames 760x1000 anclados abajo (base del agua ~y=980, centro=500 -> base 480px bajo el centro)
	var ground_y := to_global(Vector2(0.0, SHADOW_FEET_OFFSET)).y
	g.global_position = Vector2(gx, ground_y - 480.0 * s)
	g.animation_finished.connect(g.queue_free)
	g.play("erupt")
	# SFX de CHAPOTEO al brotar el agua del suelo. En un player PROPIO para no cortar la
	# voz del cast (que suena en sfx_player). loop=false -> se libera solo al terminar.
	if ResourceLoader.exists("res://imagen-action/favi/Fe-sound-effect/water-splahs.mp3"):
		var strm := load("res://imagen-action/favi/Fe-sound-effect/water-splahs.mp3")
		if strm is AudioStreamMP3:
			strm.loop = false
		var sp := AudioStreamPlayer.new()
		sp.stream = strm
		sp.volume_db = -1.0
		get_parent().add_child(sp)
		sp.finished.connect(sp.queue_free)
		sp.play()
	return g

# PILAR DE FUEGO del INFIERNO: columna VERTICAL de llamas que se alza del piso
func _spawn_fire_pillar(escala := 1.0) -> void:
	var f := CPUParticles2D.new()
	f.texture = _soft_texture()
	f.z_index = 4
	f.position = Vector2(0.0, SHADOW_FEET_OFFSET - 30.0)   # brota del piso
	f.one_shot = true
	f.emitting = true
	f.explosiveness = 0.45
	f.amount = 30
	f.lifetime = 0.55
	f.direction = Vector2(0, -1)     # sube derecho
	f.spread = 14.0
	f.gravity = Vector2(0, -300)
	f.initial_velocity_min = 200.0 * CHAR_SCALE
	f.initial_velocity_max = 460.0 * CHAR_SCALE
	f.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	f.emission_rect_extents = Vector2(55.0 * escala, 18.0)
	f.scale_amount_min = 2.2 * escala
	f.scale_amount_max = 4.5 * escala
	var grad := Gradient.new()
	grad.set_color(0, Color(1.35, 1.1, 0.55, 0.9))    # amarillo cálido (bloom suave)
	grad.add_point(0.4, Color(1.35, 0.55, 0.15, 0.85))  # naranja
	grad.set_color(1, Color(0.85, 0.12, 0.04, 0.0))   # rojo humo -> se apaga
	f.color_ramp = grad
	add_child(f)
	f.finished.connect(f.queue_free)

func _spawn_ghost(blue := false) -> void:
	var tex: Texture2D = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	if tex == null:
		return
	var g := Sprite2D.new()
	g.texture = tex
	g.flip_h = sprite.flip_h
	g.z_index = -1
	# copia el offset del sprite (Fe ancla los pies con sprite.offset; NO va en el transform)
	g.offset = sprite.offset
	# nace CLARO (HDR) y se apaga hacia OSCURO/transparente: estela clara junto al cuerpo,
	# oscura en la cola. AZUL agua para la víctima del poder de Fe / ROJO fuego para el dash.
	if blue:
		g.modulate = Color(0.42, 0.78, 1.9, 0.62)
	else:
		g.modulate = Color(1.7, 0.42, 0.38, 0.62)
	get_parent().add_child(g)
	g.global_transform = sprite.global_transform
	var tw := g.create_tween()
	var fin := Color(0.03, 0.09, 0.34, 0.0) if blue else Color(0.34, 0.03, 0.05, 0.0)
	tw.tween_property(g, "modulate", fin, 0.55)   # perdura más (fade lento)
	tw.tween_callback(g.queue_free)

func _launch(push_dir: int, mult := 1.0) -> void:
	crouching = false
	airborne = true
	hit_flying = true
	punch_followup = false
	# decaimiento de juggle: cada lanzamiento seguido eleva menos (anti-infinito)
	vel_y = -KNOCKBACK_Y * mult * pow(0.86, float(juggle_hits))
	vel_x = push_dir * KNOCKBACK_X
	fly_lean = float(push_dir)   # el cuerpo se ladea hacia donde sale despedido
	juggle_hits += 1
	var ya_volaba := String(sprite.animation) == "hit_fly"
	sprite.play("hit_fly")
	if ya_volaba:
		var k := impact_sfx_override if (impact_sfx_override != "" and sfx.has(impact_sfx_override)) else "hit_fly"
		_play_sfx_key(k)

# push_dir: hacia donde empuja el golpe (+1 derecha / -1 izquierda)
func receive_hit(low: bool, strong: bool, push_dir: int, impact_key := "", trip := false, launch_mult := 1.0, wall := false, atk_blue := false) -> String:
	impact_sfx_override = impact_key
	if breaker_inv_t > 0.0:
		return "ignored"
	if koed or (is_downed() and not hit_flying):
		return "ignored"
	special_t = 0.0  # un golpe recibido corta el dash especial
	fe_dash_t = 0.0  # ...y también el dash de agujas de Fe
	fe_dash_active = false
	# encara al ATACANTE al recibir (push_dir = empuje del golpe; el atacante está
	# del lado contrario). Así el escudo de bloqueo (flip_h = facing<0) mira al golpe.
	set_facing(-push_dir)
	# en el aire cualquier golpe lo derriba
	if airborne:
		_burst(1.2, false, 1, atk_blue)
		_launch(push_dir, launch_mult)
		return "launched"
	# la IA bloquea por instinto de vez en cuando
	if not is_player and ai_enabled and randf() < 0.22:
		if low:
			sprite.play("block_low")
		else:
			sprite.play("block")
		_burst(0.6, true)
		position.x += push_dir * 13
		return "blocked"
	# bloqueo: reteniendo la direccion contraria al rival en el momento del impacto
	if is_player:
		var away := Input.is_action_pressed("ui_left") if facing > 0 else Input.is_action_pressed("ui_right")
		if away:
			if low and crouching:
				sprite.play("block_low")
				_burst(0.6, true)
				position.x += push_dir * 13
				return "blocked"
			if not low and not crouching:
				sprite.play("block")
				_burst(0.6, true)
				position.x += push_dir * 13
				return "blocked"
	# EMBER DASH: sale disparado RECTO hacia la pared (vuelo plano y veloz)
	if wall:
		_burst(1.2, false, 1, atk_blue)
		crouching = false
		airborne = true
		hit_flying = true
		punch_followup = false
		vel_y = -KNOCKBACK_Y * 0.55
		vel_x = push_dir * KNOCKBACK_X * 3.2
		juggle_hits += 1
		if sprite.sprite_frames.has_animation("fly_straight"):
			sprite.play("fly_straight")
		else:
			sprite.play("hit_fly")
		return "launched"
	# barrido: derriba al piso con un vuelo corto y rasante (no lanza alto)
	if trip:
		_burst(1.1, false, 1, atk_blue)
		crouching = false
		airborne = true
		hit_flying = true
		punch_followup = false
		vel_y = -KNOCKBACK_Y * 0.32
		vel_x = push_dir * KNOCKBACK_X * 1.25
		juggle_hits += 1
		sprite.play("hit_fly")
		return "launched"
	# golpe fuerte (gancho lanzador): si no fue bloqueado, sale por los aires
	if strong:
		_burst(1.2, false, 1, atk_blue)
		_launch(push_dir, launch_mult)
		return "launched"
	if low:
		crouching = true
		sprite.play("take_hit_low")
	else:
		crouching = false
		sprite.play("take_hit")
	# la chispa se pone a la altura del origen (pecho de DAM). Para Favi (nena, escala
	# base < 1) el origen queda por encima de su cabeza, así que la bajamos hacia su
	# cuerpo — más aún en golpe bajo (agachada). DAM (base 1.0) => 0, sin cambio.
	# base_corr sigue el PECHO al cambiar de escala (Favi baja, DAM sube un poco);
	# luego la ZONA baja la chispa a las piernas si el golpe fue BAJO (+ = hacia abajo).
	var base_corr := 500.0 * (1.0 - base_scale.y)
	var zona := (220.0 if low else 0.0) * base_scale.y
	var chispa_y := base_corr + zona
	_burst(1.0, false, 1, atk_blue, chispa_y)
	buffer_t = 0.0
	punch_followup = false  # un golpe recibido corta el combo pendiente
	position.x += push_dir * 20
	return "hit"

func _physics_process(delta: float) -> void:
	queue_redraw()
	if swing_layer:
		swing_layer.queue_redraw()   # la estela se dibuja por delante del cuerpo
	# inclinación al salir volando: el cuerpo se ladea hacia la dirección del empujón (no vertical)
	if hit_flying and String(sprite.animation) == "hit_fly":
		sprite.rotation = deg_to_rad(FLY_TILT_DEG) * fly_lean
	elif sprite.rotation != 0.0:
		sprite.rotation = 0.0
	burst_t = maxf(0.0, burst_t - delta)
	breaker_inv_t = maxf(0.0, breaker_inv_t - delta)
	if water_bg:
		# volando por el poder del agua: cuerpo teñido de AZUL todo el vuelo (no se desvanece aún)
		sprite.modulate = Color(0.5, 0.75, 1.6, 1)
	elif water_flash_t > 0.0:
		# ya cayó: la capa azul se desvanece a normal
		water_flash_t = maxf(0.0, water_flash_t - delta)
		var wk := water_flash_t / 0.45
		sprite.modulate = Color(1, 1, 1, 1).lerp(Color(0.5, 0.75, 1.6, 1), wk)
	elif breaker_inv_t > 0.0:
		sprite.modulate = Color(1, 1, 1, 0.5 + 0.5 * absf(sin(breaker_inv_t * 30.0)))
	elif sprite.modulate != Color(1, 1, 1, 1):
		sprite.modulate = Color(1, 1, 1, 1)

	# squash del estrellon: conserva el volumen (comprime un eje, estira el otro)
	if wall_squash_t > 0.0:
		wall_squash_t = maxf(0.0, wall_squash_t - delta)
		var c := 0.7 + 0.3 * (1.0 - wall_squash_t / SQUASH_DUR)   # 0.7 -> 1.0
		var e := 2.0 - c                                          # 1.3 -> 1.0
		# pared: comprime ancho y estira alto; piso: al reves (relativo a la escala base)
		var sc := Vector2(c, e) if squash_horizontal else Vector2(e, c)
		sprite.scale = Vector2(base_scale.x * sc.x, base_scale.y * sc.y)
	elif sprite.scale != base_scale:
		sprite.scale = base_scale

	# memoria del ↓ para detectar el cuarto adelante (↓ luego →+Q)
	if is_player and input_enabled and Input.is_action_pressed("ui_down"):
		down_recent_t = 0.3
	else:
		down_recent_t = maxf(0.0, down_recent_t - delta)
	# memoria de ADELANTE (hacia el rival) para el comando del ULTRA (→ R R)
	var _fwd := Input.get_axis("ui_left", "ui_right")
	if is_player and input_enabled and _fwd != 0.0 and int(signf(_fwd)) == facing:
		fwd_recent_t = 0.5
	else:
		fwd_recent_t = maxf(0.0, fwd_recent_t - delta)
	# memoria de ATRÁS (lejos del rival) para el motion ←→ del DASH DE AGUJAS de Fe
	if is_player and input_enabled and _fwd != 0.0 and int(signf(_fwd)) == -facing:
		back_recent_t = 0.35
	else:
		back_recent_t = maxf(0.0, back_recent_t - delta)
	# DASH DE AGUJAS de Fe en curso: embiste hacia adelante y deja estela azul
	if fe_dash_t > 0.0:
		fe_dash_t = maxf(0.0, fe_dash_t - delta)
		position.x += float(facing) * FE_DASH_SPEED * delta
	# EMBER DASH en curso: avanza ardiendo y suelta sombras
	if special_t > 0.0:
		special_t = maxf(0.0, special_t - delta)
		position.x += float(facing) * SPECIAL_SPEED * delta
		fire_trail.direction = Vector2(-float(facing), -0.3)
		fire_trail.emitting = true
		if not dash_border_on:                 # borde rojo eléctrico al arrancar el dash
			dash_border_on = true
			var mb := get_parent()
			if mb and mb.has_method("_dash_border"):
				mb._dash_border(self, true)
	else:
		if fire_trail != null and fire_trail.emitting:
			fire_trail.emitting = false
		if dash_border_on:                      # el dash terminó -> quita el borde
			dash_border_on = false
			var mb := get_parent()
			if mb and mb.has_method("_dash_border"):
				mb._dash_border(self, false)
	# sombras fantasma: dash especial / mortal del breaker (rojas), volando por el agua o
	# el DASH DE AGUJAS de Fe (AZULES)
	breaker_fx_t = maxf(0.0, breaker_fx_t - delta)
	if special_t > 0.0 or breaker_fx_t > 0.0 or water_bg or fe_dash_t > 0.0:
		ghost_timer -= delta
		if ghost_timer <= 0.0:
			ghost_timer = 0.038
			# Fe (fx_blue) SIEMPRE deja sombras AZULES (dash, agua, breaker, ultra); DAM rojas
			_spawn_ghost(water_bg or fe_dash_t > 0.0 or fx_blue)
	up_tap_t = maxf(0.0, up_tap_t - delta)
	double_up_t = maxf(0.0, double_up_t - delta)
	down_tap_t = maxf(0.0, down_tap_t - delta)
	double_down_t = maxf(0.0, double_down_t - delta)
	ultra_r_t = maxf(0.0, ultra_r_t - delta)
	dash_smoke_cd = maxf(0.0, dash_smoke_cd - delta)

	# noqueado: tendido, no responde a nada
	if koed:
		return

	# juggle aereo del ULTRA: se queda flotando donde lo pusieron (sin gravedad
	# ni pegarse al piso); el ultra controla su pose y posicion desde main.gd
	if ultra_hover:
		return

	# combo →+Q: cerca del final del primer corte encadena el segundo
	if punch_followup and sprite.animation == "punch" and sprite.frame >= 8:
		punch_followup = false
		sprite.play("punch2")

	# patada giratoria: viaja hacia adelante y se eleva un poco mientras gira
	if sprite.animation == "spin_kick" and sprite.is_playing() and not airborne:
		position.x += facing * SPIN_TRAVEL * delta
		var hover := 0.0
		if sprite.frame >= 1 and sprite.frame <= 5:
			hover = SPIN_HOVER
		elif sprite.frame == 6:
			hover = SPIN_HOVER * 0.35
		position.y = lerpf(position.y, floor_y - hover, minf(14.0 * delta, 1.0))
	elif not airborne and not hit_flying and position.y != floor_y:
		position.y = floor_y  # al terminar (o si lo interrumpen) vuelve al piso

	# en el aire: gravedad; con control solo si es jugador y no va despedido
	if airborne:
		var air_spin: bool = sprite.animation in ["spin_kick", "air_spin_kick"] and sprite.is_playing()
		# TODOS los ataques aéreos flotan: mientras golpeas en el aire, bajas
		# poco a poco (feel de combo aéreo de fighting game), no caes en picada.
		var air_atk: bool = air_spin or (sprite.animation in ["jump_punch", "jump_kick", "air_jab"] and sprite.is_playing())
		position.y += vel_y * delta
		# atacando en el aire cae flotando y (el giro) avanza solo
		var g_mult := 0.35 if air_atk else 1.0
		# caida BRUSCA del remate del ULTRA: al pasar el ápice se desploma
		if hard_fall and hit_flying and vel_y > 0.0:
			g_mult = 2.6
		# lanzado normal: una vez que YA va cayendo, cae más rápido (menos flote)
		elif hit_flying and vel_y > 0.0:
			g_mult = 1.7
		vel_y += GRAVITY * g_mult * delta
		if air_atk:
			vel_y = minf(vel_y, 300.0 * CHAR_SCALE)   # descenso lento y parejo mientras golpea
			if air_spin:
				position.x += facing * SPIN_TRAVEL * 0.8 * delta
		elif hit_flying:
			position.x += vel_x * delta
			# rebote contra el limite del escenario (una vez por vuelo)
			if not wall_bounced and ((position.x <= 115.0 and vel_x < 0.0) \
					or (position.x >= 1805.0 and vel_x > 0.0)):
				wall_bounced = true
				position.x = clampf(position.x, 115.0, 1805.0)
				# rebota hacia ADELANTE (lejos de la pared) con buen empuje
				vel_x = -vel_x * 0.9
				if absf(vel_x) < 320.0 * CHAR_SCALE:   # rebote mínimo garantizado
					vel_x = signf(vel_x) * 320.0 * CHAR_SCALE
				vel_y = minf(vel_y, -520.0 * CHAR_SCALE)
				if sprite.sprite_frames.has_animation("wall_splat"):
					sprite.play("wall_splat")
				wall_squash_t = SQUASH_DUR
				squash_horizontal = true   # choca de lado: comprime el ancho
				# efecto de escombros QUITADO (el usuario hará su propio frame de impacto)
				_play_sfx_key("wall_bounce")
		elif is_player:
			var air_dir := Input.get_axis("ui_left", "ui_right")
			if air_dir != 0.0:
				position.x += air_dir * WALK_SPEED * spd * delta
		if position.y >= floor_y:
			position.y = floor_y
			airborne = false
			vel_y = 0.0
			water_bg = false   # tocó el suelo: dejan de salir las sombras azules
			if hit_flying:
				hit_flying = false
				vel_x = 0.0
				if hard_fall:
					hard_fall = false
					wall_squash_t = SQUASH_DUR
					squash_horizontal = false   # cae al piso: comprime el alto
					_burst(1.3)
					_play_sfx_key("wall_bounce")
				_spawn_jump_dust(0.9)   # estrellon: polvo grande (los escombros son solo de PARED)
				sprite.play("hit_down")  # se estrella y se levanta
			else:
				_spawn_jump_dust(0.6)   # aterrizaje de salto: polvito
				sprite.play("pose")
		return

	# estrellandose / levantandose: no responde
	if sprite.animation == "hit_down" and sprite.is_playing():
		return

	# celebrando: quieto hasta que se le ordene volver
	if sprite.animation == "victory":
		return

	if not is_player:
		_ai_process(delta)
		return
	if not input_enabled:
		return

	# buffer de entrada: el boton guardado sale apenas se abre la ventana
	if buffer_t > 0.0:
		buffer_t -= delta
		if _try_attack(buffer_action):
			buffer_t = 0.0

	# jump-cancel del lanzador: tras conectar el gancho puedes saltar de una
	if Input.is_action_just_pressed("ui_up") and not airborne \
			and sprite.animation == "crouch_kick" and sprite.frame > 2:
		airborne = true
		crouching = false
		vel_y = -JUMP_SPEED
		_spawn_jump_dust(0.6)   # polvo de despegue
		sprite.play("jump")
		return

	# DASH DE AGUJAS de Fe en curso: bloquea locomoción/salto/agacharse para que "walk"
	# NO pise la animación "dash" (el jugador mantiene ADELANTE durante el comando ←→+Q)
	if fe_dash_active or special_t > 0.0:
		return

	# ocupado: golpeando, recibiendo dano o bloqueando
	if sprite.animation in ["punch", "punch2", "kick", "spin_kick", "air_spin_kick", "weak_punch", "crouch_punch", "crouch_jab", "crouch_kick", "sweep", "take_hit", "take_hit_low", "block", "block_low", "water_cast"] \
			and sprite.is_playing():
		return

	# salto
	if Input.is_action_just_pressed("ui_up") and not crouching:
		airborne = true
		vel_y = -JUMP_SPEED
		_spawn_jump_dust(0.6)   # polvo de despegue
		# salto hacia ADELANTE (hacia el rival) = MORTAL (neutral_spin); neutro/atrás = jump normal
		var jdir := Input.get_axis("ui_left", "ui_right")
		if jdir != 0.0 and int(signf(jdir)) == facing and sprite.sprite_frames.has_animation("neutral_spin"):
			sprite.play("neutral_spin")
		else:
			sprite.play("jump")
		return

	# agacharse: mantener abajo; al soltar se levanta en reversa
	var down_held := Input.is_action_pressed("ui_down")
	if down_held and not crouching:
		crouching = true
		sprite.play("crouch")
	elif not down_held and crouching:
		crouching = false
		sprite.play_backwards("crouch")
	if crouching:
		return
	if sprite.animation == "crouch" and sprite.is_playing():
		return  # levantandose

	# caminar: hacia el rival = avance, alejandose = retroceso en reversa
	var dir := Input.get_axis("ui_left", "ui_right")
	if dir != 0.0:
		var forward := signi(int(dir)) == facing
		position.x += dir * (WALK_SPEED if forward else WALK_BACK_SPEED) * spd * delta
		var want := 1 if forward else -1
		if sprite.animation != "walk" or walk_dir != want:
			if forward:
				sprite.play("walk")
			else:
				sprite.play_backwards("walk")
		walk_dir = want
	else:
		walk_dir = 0
		if sprite.animation == "walk":
			sprite.play("pose")

func _ai_process(delta: float) -> void:
	if not ai_enabled or koed or ai_target == null or airborne:
		return
	# combo en curso: encadena el siguiente golpe al abrirse la ventana de cancel
	if ai_combo.size() > 0:
		var anim := String(sprite.animation)
		if anim in ["take_hit", "take_hit_low", "block", "block_low", "hit_down"]:
			ai_combo.clear()  # se lo interrumpieron
		elif anim in ATTACKS and sprite.is_playing():
			if sprite.frame > int(ATTACKS[anim]["hit_frame"]):
				sprite.play(ai_combo.pop_front())
			return
		else:
			sprite.play(ai_combo.pop_front())
			return
	if sprite.animation in ["punch", "punch2", "kick", "spin_kick", "air_spin_kick", "weak_punch", "crouch_punch", "crouch_jab", "crouch_kick", "sweep", "jump_punch", "jump_kick", "take_hit", "take_hit_low", "block", "block_low", "hit_down", "ko", "victory", "crouch"] \
			and sprite.is_playing():
		return
	var dist := absf(ai_target.position.x - position.x)
	ai_timer -= delta
	if ai_timer <= 0.0:
		ai_timer = randf_range(0.4, 0.9)
		var r := randf()
		if ai_break_drill:
			# DRILL de BREAK: persigue y encadena combos casi siempre (para practicar romper)
			if dist > 430.0 * CHAR_SCALE:
				ai_action = "advance"
			else:
				ai_action = "combo_start" if r < 0.8 else "punch"
		elif dist > 620.0 * CHAR_SCALE:
			ai_action = "advance" if r < 0.75 else "idle"
		elif dist > 430.0 * CHAR_SCALE:
			if r < 0.35: ai_action = "advance"
			elif r < 0.5: ai_action = "kick"
			elif r < 0.62: ai_action = "spin_kick"
			elif r < 0.72: ai_action = "crouch_kick"
			elif r < 0.85: ai_action = "retreat"
			else: ai_action = "idle"
		else:
			if r < 0.22: ai_action = "combo_start"
			elif r < 0.38: ai_action = "weak_punch"
			elif r < 0.52: ai_action = "punch"
			elif r < 0.64: ai_action = "kick"
			elif r < 0.74: ai_action = "crouch_punch"
			elif r < 0.86: ai_action = "retreat"
			else: ai_action = "idle"
	match ai_action:
		"advance":
			position.x += facing * WALK_SPEED * 0.75 * spd * delta
			if sprite.animation != "walk" or walk_dir != 1:
				sprite.play("walk")
			walk_dir = 1
		"retreat":
			position.x -= facing * WALK_BACK_SPEED * 0.75 * spd * delta
			if sprite.animation != "walk" or walk_dir != -1:
				sprite.play_backwards("walk")
			walk_dir = -1
		"punch", "kick", "spin_kick", "crouch_punch", "crouch_kick":
			walk_dir = 0
			if ai_action == "punch":
				punch_followup = randf() < 0.35  # la IA tambien encadena el doble
			sprite.play(ai_action)
			ai_action = "idle"
			ai_timer = randf_range(0.5, 1.0)
		"combo_start":
			walk_dir = 0
			ai_combo = AI_COMBOS[randi() % AI_COMBOS.size()].duplicate()
			sprite.play(ai_combo.pop_front())
			ai_action = "idle"
			ai_timer = randf_range(0.9, 1.5)
		_:
			walk_dir = 0
			if sprite.animation == "walk":
				sprite.play("pose")

func _unhandled_input(event: InputEvent) -> void:
	if not is_player or not input_enabled:
		return
	# tecla de prueba U: celebracion de victoria / volver a guardia
	if event.is_action_pressed("victory_test") and not airborne and not koed:
		crouching = false
		if sprite.animation == "victory":
			sprite.play("pose")
		else:
			celebrate()   # incluye la frase de victoria
		return
	# tecla de prueba Y: cae noqueado / revivir
	if event.is_action_pressed("ko_test") and not airborne:
		koed = not koed
		crouching = false
		sprite.play("ko" if koed else "pose")
		return
	# doble toque ↑: habilita el breaker con movimiento (↑↑+E)
	if event.is_action_pressed("ui_up"):
		if up_tap_t > 0.0:
			double_up_t = 0.3
		up_tap_t = 0.35
	# doble toque ↓: habilita el INFIERNO (↓↓+E)
	if event.is_action_pressed("ui_down"):
		if down_tap_t > 0.0:
			double_down_t = 0.35
		down_tap_t = 0.4
	# combo breaker (↑+E, o S de respaldo): rompe el castigo, una vez por ronda
	var quiere_break := event.is_action_pressed("combo_break") \
		or (event.is_action_pressed("spin_kick") and up_tap_t > 0.0)
	if quiere_break and not koed \
			and (hit_flying or (String(sprite.animation) in ["take_hit", "take_hit_low"] and sprite.is_playing())):
		var mb := get_parent()
		if mb and mb.has_method("meter_can_break") and not mb.meter_can_break(self):
			return   # sin ½ barra no se puede romper
		if do_breaker():
			if mb and mb.has_method("on_breaker"):
				mb.on_breaker(self)
		return
	if event.is_action_pressed("combo_break"):
		return
	if koed or is_downed():
		return
	# teclas de prueba de dano sobre uno mismo (E/R/T); el golpe llega de frente
	if event.is_action_pressed("take_hit") and not airborne:
		receive_hit(false, false, -facing)
		return
	if event.is_action_pressed("take_hit_low") and not airborne:
		crouching = true
		receive_hit(true, false, -facing)
		return
	if event.is_action_pressed("take_hit_strong") and not airborne:
		receive_hit(false, true, -facing)
		return
	if sprite.sprite_frames.has_animation("water_cast"):
		# --- FE: sus propios especiales/ultra. NO hereda los ultras de fuego de DAM. ---
		# WHIRLPOOL (↓←+E): finisher tras combo (cuesta 1 barra).
		if event.is_action_pressed("spin_kick") and down_recent_t > 0.0 and back_recent_t > 0.0:
			var mw := get_parent()
			if mw and mw.has_method("try_whirlpool") and mw.try_whirlpool(self):
				return
		# ULTRA CORTO (↑+E): combo aéreo tras combo de 3 (cuesta 2 barras). El breaker ↑+E
		# se revisó antes y solo entra si te están pegando, así que el ofensivo queda libre.
		if event.is_action_pressed("spin_kick") and up_tap_t > 0.0:
			var mfu := get_parent()
			if mfu and mfu.has_method("try_fe_ultra") and mfu.try_fe_ultra(self):
				return
		# ULTRA LARGO (↓→ + R = cuarto adelante + R): APOCALYPSE (3 barras + combo + rival rojo)
		if event.is_action_pressed("weak_punch") and down_recent_t > 0.0:
			var _fd := Input.get_axis("ui_left", "ui_right")
			if _fd != 0.0 and int(signf(_fd)) == facing:
				var mfl := get_parent()
				if mfl and mfl.has_method("try_fe_ultra_long") and mfl.try_fe_ultra_long(self):
					return
	else:
		# --- DAM: sus finishers de fuego ---
		# comando ANIQUILACIÓN: → R (adelante reciente + R)
		if event.is_action_pressed("weak_punch") and fwd_recent_t > 0.0:
			var mu := get_parent()
			if mu and mu.has_method("try_ultra") and mu.try_ultra(self):
				return
		# comando INFIERNO (crítico de fuego): ↓↓ + E
		if event.is_action_pressed("spin_kick") and double_down_t > 0.0:
			var mc := get_parent()
			if mc and mc.has_method("try_critical") and mc.try_critical(self):
				return
		# comando APOCALIPSIS: → E (version larga)
		if event.is_action_pressed("spin_kick") and fwd_recent_t > 0.0:
			var mu2 := get_parent()
			if mu2 and mu2.has_method("try_ultra") and mu2.try_ultra(self, true):
				return
	var accion := ""
	for a in ["attack", "kick", "spin_kick", "weak_punch"]:
		if event.is_action_pressed(a):
			accion = a
			break
	if accion == "":
		return
	if not _try_attack(accion):
		# aun no se abre la ventana: se guarda y dispara solo en cuanto abra
		buffer_action = accion
		buffer_t = 0.3

# intenta ejecutar un boton de ataque respetando ventana, familia y escalera
func _try_attack(accion: String) -> bool:
	var anim_actual := String(sprite.animation)
	if special_t > 0.0 or fe_dash_active:
		return false  # ni el dash especial ni el dash de agujas se cancelan
	if anim_actual in ["take_hit", "take_hit_low", "block", "block_low", "water_cast"] and sprite.is_playing():
		return false
	if anim_actual in ATTACKS and sprite.is_playing():
		if sprite.frame <= int(ATTACKS[anim_actual]["hit_frame"]):
			return false
		if BTN_FAMILY.get(anim_actual, "") == accion:
			return false
		if BTN_LEVEL.get(accion, 0) < ANIM_LEVEL.get(anim_actual, 0):
			return false
	if crouching or Input.is_action_pressed("ui_down"):
		if accion == "attack":
			sprite.play("crouch_punch")
			return true
		if accion == "kick":
			sprite.play("crouch_kick")
			return true
		if accion == "weak_punch" and sprite.sprite_frames.has_animation("crouch_jab"):
			sprite.play("crouch_jab")
			return true
		if accion == "spin_kick" and sprite.sprite_frames.has_animation("sweep"):
			sprite.play("sweep")
			return true
		return false
	match accion:
		"attack":
			if airborne:
				sprite.play("jump_punch")
			else:
				var dir := Input.get_axis("ui_left", "ui_right")
				var adelante := dir != 0.0 and int(signf(dir)) == facing
				# cuarto adelante (↓ reciente y ya suelto) + Q:
				#   Fe = ESPECIAL DE AGUA a 1 CUERPO · DAM = EMBER DASH
				if adelante and down_recent_t > 0.0:
					if sprite.sprite_frames.has_animation("water_cast"):
						_start_water_special(1)
					else:
						_start_special()
					return true
				# ←→+Q (atrás luego adelante) = DASH DE AGUJAS de Fe: embiste, si conecta 3 golpes
				if adelante and back_recent_t > 0.0 and sprite.sprite_frames.has_animation("water_cast"):
					_start_fe_dash()
					return true
				# →+Q (hacia el rival): doble corte encadenado
				punch_followup = adelante
				sprite.play("punch")
			return true
		"kick":
			if not airborne:
				var kdir := Input.get_axis("ui_left", "ui_right")
				var kade := kdir != 0.0 and int(signf(kdir)) == facing
				# ↓↘→+W (medialuna adelante) = ESPECIAL DE AGUA de Fe a 2 CUERPOS
				if kade and down_recent_t > 0.0 and sprite.sprite_frames.has_animation("water_cast"):
					_start_water_special(2)
					return true
			sprite.play("jump_kick" if airborne else "kick")
			return true
		"spin_kick":
			if not airborne:
				var edir := Input.get_axis("ui_left", "ui_right")
				var eade := edir != 0.0 and int(signf(edir)) == facing
				# ↓↘→+E (medialuna adelante) = ESPECIAL DE AGUA de Fe a 3 CUERPOS
				if eade and down_recent_t > 0.0 and sprite.sprite_frames.has_animation("water_cast"):
					_start_water_special(3)
					return true
			if airborne and sprite.sprite_frames.has_animation("air_spin_kick"):
				sprite.play("air_spin_kick")
				return true
			if sprite.sprite_frames.has_animation("spin_kick"):
				sprite.play("spin_kick")
				if sprite.sprite_frames.has_animation("water_cast"):
					# Fe grita "Power Twister" al girar (voz furiosa/energética)
					var ruta := "res://imagen-action/favi/Fe-sound-effect/spin-fe-furiosa.wav"
					if spin_voz_sfx == null and ResourceLoader.exists(ruta):
						spin_voz_sfx = load(ruta)
					if spin_voz_sfx != null:
						voz_player.stream = spin_voz_sfx
						voz_player.play()
				else:
					var mk := get_parent()          # DAM grita al lanzar la patada giratoria (→E)
					if mk and mk.has_method("_play_kick_voz"):
						mk._play_kick_voz()
				return true
			return false
		"weak_punch":
			# salto + R = PATADA AÉREA DOBLE de Fe (air_jab), exclusiva (DAM no la tiene)
			if airborne and sprite.sprite_frames.has_animation("air_jab"):
				sprite.play("air_jab")
				return true
			if not airborne and sprite.sprite_frames.has_animation("weak_punch"):
				sprite.play("weak_punch")
				return true
			return false
	return false

func _on_animation_finished() -> void:
	if sprite.animation == "hit_down":
		# ya se levanto: el castigo termino, se reinician los frenos de combo
		juggle_hits = 0
		wall_bounced = false
	if sprite.animation == "ko":
		return  # se queda tendido
	if sprite.animation == "victory":
		return  # sostiene la pose final
	if sprite.animation == "jump_kick" and airborne:
		sprite.stop()
		sprite.frame = sprite.sprite_frames.get_frame_count("jump_kick") - 1  # sostiene la picada
		return
	if sprite.animation == "jump_punch" and airborne:
		sprite.play("jump")
		sprite.frame = sprite.sprite_frames.get_frame_count("jump") - 2
		return
	if sprite.animation in ["spin_kick", "air_spin_kick", "air_jab", "neutral_spin"] and airborne:
		# al terminar el golpe/mortal aéreo pasa a un frame de CAÍDA del salto normal (más natural)
		sprite.play("jump")
		sprite.frame = sprite.sprite_frames.get_frame_count("jump") - 2
		return
	if sprite.animation == "jump" and airborne:
		return  # mantiene el ultimo frame mientras cae
	if sprite.animation == "hit_fly" and hit_flying:
		sprite.stop()
		sprite.frame = sprite.sprite_frames.get_frame_count("hit_fly") - 1
		return  # sigue volando con la pose de despedido
	if sprite.animation == "wall_splat" and hit_flying:
		sprite.stop()
		sprite.frame = sprite.sprite_frames.get_frame_count("wall_splat") - 1
		return  # cae del rebote con la pose suelta del f4
	if sprite.animation in ["crouch_punch", "crouch_jab", "crouch_kick", "sweep", "take_hit_low", "block_low"]:
		if is_player and (crouching or Input.is_action_pressed("ui_down")):
			crouching = true
			sprite.stop()
			sprite.animation = &"crouch"
			sprite.frame = sprite.sprite_frames.get_frame_count("crouch") - 1
		else:
			crouching = false
			sprite.play("pose")
		return
	if sprite.animation == "crouch" and crouching:
		return  # se queda abajo mientras mantengas la tecla
	sprite.play("pose")

func _draw() -> void:
	# sombra en el piso: sigue al peleador y se encoge al saltar
	var height := floor_y - position.y
	var t: float = clampf(1.0 - height / 1280.0, 0.35, 1.0)
	var ground_local := Vector2(0.0, (floor_y - position.y) + SHADOW_FEET_OFFSET)
	draw_set_transform(ground_local, 0.0, Vector2(1.0, SHADOW_SQUASH))
	draw_circle(Vector2.ZERO, SHADOW_RADIUS * t, Color(0, 0, 0, SHADOW_ALPHA * t))
	draw_set_transform(Vector2.ZERO)
	_draw_hit_burst()   # la estela del arma la dibuja swing_layer (por delante del cuerpo)

# flash de bloqueo: arco de escudo azul-blanco frente al cuerpo + chispas
# cortas resbalando por el borde — frio y contenido, lo opuesto al dano
func _draw_block_flash(p: float, expand: float, rng: RandomNumberGenerator) -> void:
	var grow := 0.6 + 0.4 * expand
	var base_ang := 0.0 if facing > 0 else PI
	var centro := Vector2(0.0, 20.0)
	# banda curva doble: borde exterior frio y filo interior brillante
	draw_arc(centro, 200.0 * grow, base_ang - 1.0, base_ang + 1.0, 26,
			Color(0.55, 1.05, 1.9, 0.65 * p), 20.0)
	draw_arc(centro, 192.0 * grow, base_ang - 0.85, base_ang + 0.85, 24,
			Color(1.4, 1.7, 2.1, 0.85 * p), 8.0)
	# nucleo del contacto
	draw_circle(Vector2(float(facing) * 150.0, 0.0), 28.0 * grow,
			Color(1.5, 1.8, 2.2, 0.55 * p))
	# chispitas resbalando por el borde del escudo (agujas tangentes)
	for i in 5:
		var a := base_ang + rng.randf_range(-0.85, 0.85)
		var borde := centro + Vector2(cos(a), sin(a)) * 200.0 * grow
		var tang := Vector2(-sin(a), cos(a)) * (1.0 if rng.randf() < 0.5 else -1.0)
		var perp := Vector2(cos(a), sin(a)) * rng.randf_range(3.0, 5.5)
		draw_colored_polygon(PackedVector2Array([
			borde + perp, borde - perp, borde + tang * rng.randf_range(35.0, 80.0)]),
			Color(1.6, 1.4, 0.75, 0.85 * p))

# poligono afilado a lo largo de una polilinea: ancho w0 en la base que se
# adelgaza hasta punta de aguja (los rayos rellenos del estilo 2XKO)
func _bolt_poly(path: Array, w0: float) -> PackedVector2Array:
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	var n := path.size()
	for i in n:
		var t := float(i) / float(n - 1)
		var dirv: Vector2
		if i == 0:
			dirv = (path[1] - path[0]).normalized()
		elif i == n - 1:
			dirv = (path[i] - path[i - 1]).normalized()
		else:
			dirv = (path[i + 1] - path[i - 1]).normalized()
		var perp := Vector2(-dirv.y, dirv.x) * w0 * (1.0 - t) * 0.5
		left.append(path[i] + perp)
		right.append(path[i] - perp)
	right.reverse()
	left.append_array(right)
	return left

# destello de impacto estilo anime: relampago principal dentado + rayos
# afilados + estrella de agujas + esquirlas, todo naranja con corazon blanco
func _draw_hit_burst() -> void:
	if burst_t <= 0.0:
		return
	if fx_anims.has("block" if burst_block else "hit"):
		return  # el efecto dibujado de la hoja fx lo cubre
	var p := burst_t / BURST_TIME          # 1 -> 0
	var expand := 1.0 - p                  # crece mientras se apaga
	var rng := RandomNumberGenerator.new()
	rng.seed = burst_seed
	if burst_block:
		_draw_block_flash(p, expand, rng)
		return
	var origin := Vector2(float(facing) * 150.0, 0.0)   # el frente, donde llego el golpe
	var grow := (0.5 + 0.5 * expand) * burst_scale
	var naranja := Color(1.6, 0.8, 0.15, 0.8 * p)
	var blanco := Color(1.9, 1.7, 1.0, 0.9 * p)

	# relampago principal: flash dentado alargado continuando el golpe
	var sx := -float(facing)
	var ang := deg_to_rad(rng.randf_range(-38.0, 8.0))
	var path := [origin]
	var tramo := rng.randf_range(150.0, 210.0) * grow
	for i in 3:
		ang += deg_to_rad(rng.randf_range(16.0, 34.0)) * (1.0 if i % 2 == 0 else -1.0)
		path.append(path[path.size() - 1] + Vector2(cos(ang) * sx, sin(ang)) * tramo)
		tramo *= rng.randf_range(0.7, 0.95)
	draw_colored_polygon(_bolt_poly(path, 62.0 * grow), naranja)
	draw_colored_polygon(_bolt_poly(path, 30.0 * grow), blanco)

	# rayos secundarios afilados con quiebre
	for i in 5:
		var rsx := -float(facing) if rng.randf() < 0.7 else float(facing)
		var ra := deg_to_rad(rng.randf_range(-70.0, 30.0))
		var d1 := Vector2(cos(ra) * rsx, sin(ra))
		var l1 := rng.randf_range(120.0, 300.0) * grow
		var quiebre := deg_to_rad(rng.randf_range(15.0, 32.0)) * (1.0 if rng.randf() < 0.5 else -1.0)
		var d2 := Vector2(cos(ra + quiebre) * rsx, sin(ra + quiebre))
		var codo := origin + d1 * (20.0 + l1)
		var rpath := [origin + d1 * 20.0, codo, codo + d2 * l1 * rng.randf_range(0.4, 0.7)]
		draw_colored_polygon(_bolt_poly(rpath, rng.randf_range(16.0, 26.0) * burst_scale), naranja)
		draw_colored_polygon(_bolt_poly(rpath, rng.randf_range(7.0, 11.0) * burst_scale), blanco)

	# estrella central de agujas (triangulos finos y largos)
	for i in 6:
		var sa := rng.randf_range(0.0, TAU)
		var sd := Vector2(cos(sa), sin(sa) * 0.85)
		var sperp := Vector2(-sd.y, sd.x)
		var sl := rng.randf_range(70.0, 135.0) * grow
		var base_w := rng.randf_range(9.0, 16.0) * burst_scale
		draw_colored_polygon(PackedVector2Array([
			origin + sperp * base_w, origin - sperp * base_w, origin + sd * sl]), naranja)
		draw_colored_polygon(PackedVector2Array([
			origin + sperp * base_w * 0.5, origin - sperp * base_w * 0.5, origin + sd * sl * 0.6]), blanco)

	# esquirlas triangulares sueltas volando lejos
	for i in 5:
		var ea := rng.randf_range(0.0, TAU)
		var ed := Vector2(cos(ea), sin(ea) * 0.7)
		var base := origin + ed * rng.randf_range(240.0, 430.0) * grow
		var eperp := Vector2(-ed.y, ed.x) * rng.randf_range(3.0, 6.0)
		draw_colored_polygon(PackedVector2Array([
			base + eperp, base - eperp, base + ed * rng.randf_range(18.0, 40.0)]),
			Color(1.7, 1.2, 0.4, 0.85 * p))

# punto del arco de la estela (achatado y espejado segun facing)
func _swing_pt(a_deg: float, r: float, c: Vector2, flat: float) -> Vector2:
	var rad := deg_to_rad(a_deg)
	return Vector2(float(facing) * (c.x + cos(rad) * r), c.y + sin(rad) * r * flat)

# radio con cola enroscada: la punta delantera (t=1) va a radio pleno y la
# cola (t=0) se curva hacia adentro, como una coma
func _swing_r(r: float, t: float) -> float:
	return r * (1.0 - 0.22 * pow(1.0 - t, 1.6))

# coma de corte: gruesa en la punta delantera (donde va el arma) y
# adelgazando hacia la cola enroscada
func _swing_poly(a0: float, a1: float, w: float, r: float, c: Vector2, flat: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var n := 24
	for i in n + 1:
		var t := float(i) / n
		pts.append(_swing_pt(lerpf(a0, a1, t), _swing_r(r, t), c, flat))
	for i in range(n, -1, -1):
		var t := float(i) / n
		var grosor: float = maxf(w * pow(t, 0.65), 2.0)
		pts.append(_swing_pt(lerpf(a0, a1, t), _swing_r(r, t) - grosor, c, flat))
	return pts

func _draw_swing_trail_on(ci: CanvasItem) -> void:
	if not sprite.is_playing():
		return
	var anim := String(sprite.animation)
	if not SWING_FX.has(anim):
		return
	var fx: Dictionary = SWING_FX[anim]
	var stages: Array = fx["stages"]
	var stage: int = sprite.frame - int(fx["base"])
	if stage < 0 or stage >= stages.size():
		return
	var a0: float = stages[stage][0]
	var a1: float = stages[stage][1]
	var al: float = stages[stage][2]
	var c: Vector2 = fx["c"]
	var r: float = fx["r"]
	var w: float = fx["w"]
	var flat: float = fx["flat"]
	if stages[stage].size() > 3:
		r *= float(stages[stage][3])
	# escalar y reposicionar la estela al tamaño/offset del sprite del personaje:
	# tuneada para DAM (escala 1.0, offset 0), para Favi (nena, escala < 1 y sprite
	# corrido hacia abajo) hay que achicarla y bajarla para que siga sus agujas.
	# DAM queda idéntico (base_scale 1, offset 0).
	var bs: float = base_scale.y
	c = Vector2(c.x * bs, (c.y + sprite.offset.y) * bs)
	r *= bs
	w *= bs
	# color de la estela: MORADO+ROSA floral (Aye) · AZUL-blanco marino (Favi) · naranja de fuego (DAM)
	var c_out: Color
	var c_core: Color
	var c_edge: Color
	if fx_floral:
		c_out = Color(0.75, 0.20, 1.15, 0.32 * al)   # violeta suave (cuerpo del arco)
		c_core = Color(1.7, 0.45, 1.25, 0.55 * al)   # rosa magenta caliente (nucleo)
		c_edge = Color(1.95, 0.95, 1.8, 0.75 * al)   # borde rosa claro/lavanda que florece
	elif fx_blue:
		c_out = Color(0.12, 0.42, 1.0, 0.32 * al)
		c_core = Color(0.5, 0.85, 1.7, 0.55 * al)
		c_edge = Color(0.7, 1.2, 1.9, 0.75 * al)
	else:
		c_out = Color(1.0, 0.42, 0.12, 0.32 * al)
		c_core = Color(1.0, 0.85, 0.4, 0.55 * al)
		c_edge = Color(1.6, 1.2, 0.55, 0.75 * al)
	# capa suave exterior, nucleo caliente y borde de ataque que florece
	ci.draw_colored_polygon(_swing_poly(a0, a1, w, r, c, flat), c_out)
	ci.draw_colored_polygon(_swing_poly(a0 + 6.0, a1 - 2.0, w * 0.5, r, c, flat), c_core)
	# el borde brillante va en la punta delantera del arco, venga de donde venga
	var dirn := signf(a1 - a0)
	var edge := PackedVector2Array()
	for i in 13:
		edge.append(_swing_pt(lerpf(a1 - 30.0 * dirn, a1, float(i) / 12.0), r, c, flat))
	ci.draw_polyline(edge, c_edge, 7.0)


# Capa hija que dibuja la estela del arma POR DELANTE del sprite del cuerpo.
# (el sprite es hijo del peleador y tapa su _draw; por eso la estela iba detrás)
class SwingLayer extends Node2D:
	func _draw() -> void:
		var p := get_parent()
		if p and p.has_method("_draw_swing_trail_on"):
			p._draw_swing_trail_on(self)
