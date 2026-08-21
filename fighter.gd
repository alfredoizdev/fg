class_name Fighter
extends Node2D

# Peleador reutilizable: jugador o muneco de practica (is_player = false).
# Siempre mira al rival (facing lo asigna main.gd); nunca usa flip por movimiento.

# escala visual del personaje: debe coincidir con scale de Player/Dummy en
# main.tscn; velocidades y alcances se derivan de ella para conservar el feel
const CHAR_SCALE := 0.65

const WALK_SPEED := 620.0 * CHAR_SCALE      # mas rapido: que no patinen los pies
const WALK_BACK_SPEED := 470.0 * CHAR_SCALE
const JUMP_SPEED := 2270.0 * CHAR_SCALE   # +22% junto al g_mult 1.5 de saltos: MISMA altura, arco ~20% más corto (se sentían lentos/pesados)
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
	# altura del filo (NO un arco sobre la cabeza). v2 (clip 48 frames): el TAJO smear corre
	# en los frames 12-16 -> base 12. (Fe y Aye tienen entrada propia con base 1.)
	"punch": {"base": 12, "c": Vector2(10, 150), "r": 610.0, "w": 320.0, "flat": 0.20,
		"stages": [[110.0, 5.0, 0.7], [120.0, -25.0, 1.0], [125.0, -35.0, 0.55], [95.0, -35.0, 0.25], [85.0, -35.0, 0.15]]},
	"punch2": {"base": 1, "c": Vector2(10, 150), "r": 610.0, "w": 320.0, "flat": 0.20,
		"stages": [[110.0, 5.0, 0.7], [120.0, -25.0, 1.0], [125.0, -35.0, 0.55], [95.0, -35.0, 0.25]]},
	# kick (W) v3 de DAM = MACHETAZO (43 frames): estela en la DESCARGA (f19-22, de arriba
	# hacia abajo-adelante). (Aye tiene entrada propia de "kick" en su tabla.)
	"kick": {"base": 27, "c": Vector2(30, -40), "r": 640.0, "w": 380.0, "flat": 1.0,
		"stages": [[-130.0, -95.0, 0.45, 0.85], [-120.0, -40.0, 0.9, 0.93], [-110.0, 20.0, 1.0, 1.0], [-100.0, 50.0, 0.6, 1.0]]},
	"jump_punch": {"base": 2, "c": Vector2(20, 0), "r": 540.0, "w": 310.0, "flat": 0.38,
		"stages": [[215.0, 290.0, 0.8], [220.0, 350.0, 1.0], [260.0, 355.0, 0.4]]},
	# MOLINETE aéreo de DAM: la estela GIRA en círculos con la espada (loop_stages cicla
	# los 3 segmentos de 120° durante todo el giro)
	# hélice FINA: segmentos cortos (~65°) que avanzan 60° por frame -> el arco delgado
	# persigue a la espada en vez de quedar como una banana gorda sobre el torso
	"jump_kick": {"base": 5, "c": Vector2(0, -60), "r": 465.0, "w": 130.0, "flat": 0.8,
		"loop_stages": true,
		"stages": [[-90.0, -25.0, 0.8], [-30.0, 35.0, 0.7], [30.0, 95.0, 0.8],
			[90.0, 155.0, 0.7], [150.0, 215.0, 0.8], [210.0, 275.0, 0.7]]},
	# crouch_kick (↓W) v2 de DAM (74 frames): estela del gancho en la SUBIDA (f29-31).
	# (Aye tiene copia con base 1 en su tabla: su ↓W es el cast de la LUNA.)
	"crouch_kick": {"base": 29, "c": Vector2(20, 60), "r": 560.0, "w": 340.0, "flat": 1.0,
		"stages": [[70.0, 25.0, 0.5, 0.75], [60.0, -50.0, 1.0, 0.95], [-10.0, -125.0, 0.8, 1.0]]},
	# spin_kick de DAM (E = TORBELLINO): helice de fuego para el clip del giro de 71 frames
	# (f8-62, endf corta en el frenado). DORMIDA mientras el E cae al tatsumaki viejo de 6
	# frames (base 8 > 6: no dibuja) — revive sola cuando vuelva el clip del giro.
	"spin_kick": {"base": 8, "endf": 62, "c": Vector2(0, 60), "r": 500.0, "w": 130.0, "flat": 0.45,
		"loop_stages": true,
		"stages": [[-90.0, -25.0, 0.8], [-30.0, 35.0, 0.7], [30.0, 95.0, 0.8],
			[90.0, 155.0, 0.7], [150.0, 215.0, 0.8], [210.0, 275.0, 0.7]]},
	# weak_punch (R) v2 de DAM = PATADA apoyada en la espada (15 frames): estela corta en
	# la extension (f4-5). (Fe y Aye tienen entrada propia en sus tablas.)
	"weak_punch": {"base": 4, "c": Vector2(20, 40), "r": 520.0, "w": 180.0, "flat": 0.38,
		"stages": [[325.0, 358.0, 0.9], [335.0, 358.0, 0.35]]},
	# air_spin_kick = DOBLE PATADA (sin estela de blade: la katana va quieta)
	# crouch_jab (↓R) v3 de DAM (60 frames): estela de la estocada (f20-21) + DESTELLO del
	# GIRO DE HOJA (base2 f39-41) para que el 2o golpe se LEA. (Aye: copia base 1 en su tabla.)
	"crouch_jab": {"base": 20, "c": Vector2(20, 300), "r": 560.0, "w": 170.0, "flat": 0.38,
		"stages": [[325.0, 358.0, 0.9], [335.0, 358.0, 0.35]],
		"base2": 39, "stages2": [[330.0, 15.0, 0.85], [335.0, 8.0, 0.5], [340.0, 2.0, 0.25]]},
	# sweep (↓E) v2 de DAM (62 frames): estela del barrido a ras en f31-34.
	# (Fe y Aye tienen copia base 1 en sus tablas.)
	"sweep": {"base": 31, "c": Vector2(10, 380), "r": 620.0, "w": 300.0, "flat": 0.38,
		"stages": [[195.0, 120.0, 0.6, 0.8], [150.0, 5.0, 1.0, 1.0], [60.0, -15.0, 0.7, 1.0], [25.0, -35.0, 0.35, 0.95]]},
	# VOLADORA de DAM (salto+E): rastro OSCURO que sigue la PIERNA extendida (efecto de
	# patada, no de espada) — "dark": humo carmesí oscuro en vez del fuego naranja
	"air_spin_kick": {"base": 10, "c": Vector2(30, 180), "r": 440.0, "w": 200.0, "flat": 0.30, "dark": true,
		"stages": [[150.0, 60.0, 0.5], [70.0, 10.0, 0.9], [20.0, -8.0, 1.0], [8.0, -10.0, 0.7], [0.0, -10.0, 0.45], [0.0, -10.0, 0.3]]},
}

# OVERRIDE por-personaje para FAVI (fx_blue): su jump_punch NUEVO es una ESTOCADA al frente
# con la aguja (no el tajo overhead de DAM cuyo arco quedaba flotando en el CIELO).
# Estela fina y plana que sigue el pinchazo (frames 2-5 de la anim de 8).
const FAVI_SWING_FX := {
	# Q (patada alta girada NUEVA): estela corta que sigue el BARRIDO de la pierna
	# (vertical -> frente). base=10: el pie llega arriba y empieza a barrer.
	"punch": {"base": 10, "c": Vector2(30, -40), "r": 330.0, "w": 140.0, "flat": 0.55,
		"stages": [[-80.0, -20.0, 0.6], [-30.0, 30.0, 0.9], [20.0, 70.0, 0.7], [50.0, 85.0, 0.4]]},
	# sweep (barrida de Fe, 87 frames): COPIA de la entrada compartida vieja (base 1) —
	# la compartida paso a base 31 para el barrido v2 de DAM
	"sweep": {"base": 1, "c": Vector2(10, 380), "r": 620.0, "w": 300.0, "flat": 0.38,
		"stages": [[195.0, 120.0, 0.6, 0.8], [150.0, 5.0, 1.0, 1.0], [60.0, -15.0, 0.7, 1.0], [25.0, -35.0, 0.35, 0.95]]},
	# punch2 (tijera vieja del →Q): streak corto al frente — SIN esto heredaba el arcazo
	# de katana de DAM (r 610) que barría el piso entero
	"punch2": {"base": 1, "c": Vector2(20, 0), "r": 260.0, "w": 120.0, "flat": 0.25,
		"stages": [[110.0, 40.0, 0.6], [50.0, 5.0, 1.0], [10.0, -10.0, 0.7], [0.0, -12.0, 0.35]]},
	# R jab v2 (estocada de esgrima): streak fino al frente EN LA EXTENSIÓN (base 20) —
	# el arco de DAM (base 1) disparaba en la guardia, antes de que el brazo saliera
	"weak_punch": {"base": 20, "c": Vector2(30, 20), "r": 280.0, "w": 100.0, "flat": 0.22,
		"stages": [[115.0, 45.0, 0.55], [50.0, 5.0, 1.0], [12.0, -8.0, 0.75], [2.0, -10.0, 0.4]]},
	# W (doble patada NUEVA): DOS estelas — streak a la CINTURA en la 1ª patada (base 3)
	# y MEDIA LUNA ascendente siguiendo la patada ALTA (base2 37, boceto del usuario #310)
	"kick": {"base": 3, "c": Vector2(10, -20), "r": 380.0, "w": 150.0, "flat": 0.8,
		"stages": [[100.0, 40.0, 0.5, 0.6], [50.0, 0.0, 0.85, 0.65], [10.0, -15.0, 0.6, 0.62], [0.0, -18.0, 0.3, 0.6]],
		"base2": 37,
		"stages2": [[95.0, 35.0, 0.5, 0.95], [60.0, -5.0, 0.8, 1.0], [25.0, -50.0, 1.0, 1.0],
			[-15.0, -80.0, 0.8, 1.0], [-50.0, -92.0, 0.5, 1.0], [-70.0, -95.0, 0.3, 1.0]]},
	# E (peonza NUEVA): ANILLO giratorio a la altura de las agujas extendidas — segmentos
	# finos que CICLAN durante todo el molinillo (frames 16-60), como el disco del trompo
	"spin_kick": {"base": 16, "c": Vector2(0, 30), "r": 350.0, "w": 110.0, "flat": 0.30,
		"loop_stages": true,
		"stages": [[-90.0, -30.0, 0.7], [-30.0, 30.0, 0.55], [30.0, 90.0, 0.7],
			[90.0, 150.0, 0.55], [150.0, 210.0, 0.7], [210.0, 270.0, 0.55]]},
	"jump_punch": {"base": 1, "c": Vector2(20, -30), "r": 235.0, "w": 110.0, "flat": 0.25,
		"stages": [[120.0, 40.0, 0.6], [50.0, 5.0, 1.0], [10.0, -10.0, 0.8], [0.0, -12.0, 0.4]]},
	# jump W (estocada aérea): mismo streak fino al frente (el arco overhead de DAM con
	# r=490 flat=1.0 quedaba como una MEDIA LUNA gigante en el cielo)
	"jump_kick": {"base": 5, "c": Vector2(20, -20), "r": 235.0, "w": 110.0, "flat": 0.25,
		"stages": [[120.0, 40.0, 0.6], [50.0, 5.0, 1.0], [10.0, -10.0, 0.8], [0.0, -12.0, 0.4]]},
}

# OVERRIDE por-personaje del arco de swing SOLO para Aye (fx_floral): su jump_punch barre el báculo
# en un ARCO GRANDE de abajo→arriba→sobre la cabeza (ref #171), distinto a la katana de DAM.
# Mismos campos que SWING_FX. Si Aye no tiene override para una anim, cae al SWING_FX normal.
const AYE_SWING_FX := {
	# punch: COPIA de la entrada compartida VIEJA (base 1) — la compartida se movió a
	# base 12 para el punch v2 de DAM (48 frames) y el jab de Aye seguía usando base 1.
	"punch": {"base": 1, "c": Vector2(10, 150), "r": 610.0, "w": 320.0, "flat": 0.20,
		"stages": [[110.0, 5.0, 0.7], [120.0, -25.0, 1.0], [125.0, -35.0, 0.55], [95.0, -35.0, 0.25]]},
	"punch2": {"base": 1, "c": Vector2(10, 150), "r": 610.0, "w": 320.0, "flat": 0.20,
		"stages": [[110.0, 5.0, 0.7], [120.0, -25.0, 1.0], [125.0, -35.0, 0.55], [95.0, -35.0, 0.25]]},
	# sweep (↓E de Aye = cast de PUAS): COPIA de la entrada compartida vieja (base 1)
	"sweep": {"base": 1, "c": Vector2(10, 380), "r": 620.0, "w": 300.0, "flat": 0.38,
		"stages": [[195.0, 120.0, 0.6, 0.8], [150.0, 5.0, 1.0, 1.0], [60.0, -15.0, 0.7, 1.0], [25.0, -35.0, 0.35, 0.95]]},
	# crouch_jab (↓R de Aye = poke bajo): COPIA de la entrada compartida vieja (base 1)
	"crouch_jab": {"base": 1, "c": Vector2(20, 300), "r": 560.0, "w": 170.0, "flat": 0.38,
		"stages": [[325.0, 358.0, 0.9], [335.0, 358.0, 0.35]]},
	# crouch_kick (↓W de Aye = cast de la LUNA): COPIA de la entrada compartida vieja
	# (base 1) — la compartida paso a base 29 para el gancho v2 de DAM.
	"crouch_kick": {"base": 1, "c": Vector2(20, 60), "r": 560.0, "w": 340.0, "flat": 1.0,
		"stages": [[70.0, 25.0, 0.5, 0.75], [60.0, -50.0, 1.0, 0.95], [-10.0, -125.0, 0.8, 1.0]]},
	# kick (W de Aye = cast del PILAR, 44 frames): COPIA de la entrada compartida vieja
	# (base 2, arquito breve al alzar el baculo) — la compartida paso a base 25 para el
	# tajo v2 de DAM y a Aye le salia el arco a MITAD del casteo.
	"kick": {"base": 2, "c": Vector2(30, -40), "r": 640.0, "w": 380.0, "flat": 1.0,
		"stages": [[-130.0, -95.0, 0.45, 0.85], [-120.0, -40.0, 0.9, 0.93], [-110.0, 20.0, 1.0, 1.0]]},
	# ↑Q: gran barrido ascendente del báculo (abajo-frente → frente → arriba-sobre la cabeza).
	# Ángulos: 0=frente, 90=abajo, 180=atrás, 270/-90=arriba. base=1 (14 frames de anim).
	"jump_punch": {"base": 1, "c": Vector2(30, -10), "r": 660.0, "w": 300.0, "flat": 0.68,
		"stages": [[110.0, 45.0, 0.55], [55.0, -20.0, 0.85], [-15.0, -85.0, 1.0],
			[-70.0, -135.0, 0.85], [-120.0, -175.0, 0.5]]},
	# ↑W (jump_kick): golpe AÉREO overhead — la estela barre de ARRIBA hacia ABAJO siguiendo el
	# báculo (además de dar impacto, ayuda a tapar frames donde la IA corta el báculo). base=3
	# (donde empieza el strike hacia abajo en la anim de 10 frames).
	"jump_kick": {"base": 3, "c": Vector2(20, -30), "r": 560.0, "w": 260.0, "flat": 0.72,
		"stages": [[-85.0, -20.0, 0.55], [-25.0, 40.0, 0.9], [45.0, 95.0, 1.0], [80.0, 110.0, 0.45]]},
	# R (weak_punch): ESTOCADA — estela ANCHA y BAJA que sigue el báculo al frente (ref #173).
	# arco bajo/plano (flat 0.28) y radio grande (llega tan lejos como la estocada). base=9 (donde
	# el báculo dispara al frente en la anim de 20 frames).
	"weak_punch": {"base": 13, "c": Vector2(10, 50), "r": 470.0, "w": 130.0, "flat": 0.28,
		"stages": [[140.0, 60.0, 0.5], [65.0, 10.0, 0.85], [15.0, -12.0, 1.0], [0.0, -15.0, 0.55]]},
	# SÚPER crystal_flurry: estela NEÓN morada que barre ARRIBA↔ABAJO al frente siguiendo las estocadas.
	# "neon":true -> glow brillante + bloom ancho. "loop_stages":true -> las 12 etapas CICLAN durante toda
	# la ráfaga (la anim tiene 145 frames fluidos). base=23 (donde arrancan las estocadas). 0=frente,-=arriba,+=abajo.
	"crystal_flurry": {"base": 23, "c": Vector2(35, 15), "r": 540.0, "w": 250.0, "flat": 0.85,
		"neon": true, "loop_stages": true,
		"stages": [[-62.0, 28.0, 0.85], [30.0, -60.0, 0.9], [-58.0, 34.0, 1.0], [34.0, -58.0, 1.0],
			[-62.0, 28.0, 0.95], [30.0, -60.0, 1.0], [-58.0, 34.0, 1.0], [34.0, -58.0, 0.95],
			[-60.0, 30.0, 0.9], [30.0, -60.0, 0.85], [-50.0, 22.0, 0.7], [22.0, -50.0, 0.55]]},
}

# OVERRIDE por-personaje para ZETMA (fx_dark): sus clips NUEVOS (punch 91f / kick 79f /
# weak_punch 61f) tienen otro timing que los de DAM, así que la estela iba desincronizada.
# Aquí las bases van al apex REAL de cada golpe (medido): jab daga apex f23, brazo mecánico
# estirado apex f84, patada ALTA pie arriba apex f35. Estelas CORTAS (no el arcazo de katana
# de DAM) porque pelea con puño/pierna/daga; color VOID violeta oscuro (ver _draw).
const ZETMA_SWING_FX := {
	# R (weak_punch) = DOS golpes (estocada de daga al frente + patada alta). Clip recortado a
	# 54f: estela 1 sigue la ESTOCADA (~f3-8), estela 2 sigue la PATADA que sube (~f34-44).
	"weak_punch": {"c": Vector2(20, 10), "r": 500.0, "w": 170.0, "flat": 0.5,
		"base": 3, "stages": [[100.0, 8.0, 0.5], [55.0, -8.0, 0.95], [15.0, -15.0, 0.7], [0.0, -18.0, 0.4], [0.0, -18.0, 0.2]],
		"base2": 34, "stages2": [[40.0, -20.0, 0.5, 1.2], [5.0, -70.0, 0.95, 1.28], [-35.0, -105.0, 1.0, 1.3], [-58.0, -118.0, 0.55, 1.3], [-70.0, -125.0, 0.3, 1.25]]},
	# Q (punch) = ESTOCADA con daga al frente (clip nuevo 38f, apex baked f24): streak que
	# sigue la punta de la daga hacia adelante.
	"punch": {"base": 20, "c": Vector2(20, 20), "r": 470.0, "w": 160.0, "flat": 0.28,
		"stages": [[100.0, 8.0, 0.6], [50.0, -10.0, 1.0], [10.0, -16.0, 0.7], [0.0, -18.0, 0.4], [0.0, -18.0, 0.2]]},
	# W (kick) = PATADA ALTA: la estela BARRE de abajo→ARRIBA siguiendo la pierna que sube.
	"kick": {"base": 20, "c": Vector2(20, 40), "r": 640.0, "w": 330.0, "flat": 1.0,
		"stages": [[35.0, -30.0, 0.5, 0.85], [0.0, -85.0, 0.95, 0.95], [-40.0, -118.0, 1.0, 1.0], [-62.0, -128.0, 0.6, 1.0], [-72.0, -132.0, 0.3, 1.0]]},
	# E (spin_kick) = BRAZO MECÁNICO que se dispara LARGO al frente (apex baked f10): estela
	# larga y baja que persigue el puño extendido (poke de largo alcance que empuja).
	"spin_kick": {"base": 6, "c": Vector2(30, 0), "r": 660.0, "w": 200.0, "flat": 0.22,
		"stages": [[95.0, 5.0, 0.55], [50.0, -12.0, 0.9], [15.0, -18.0, 1.0], [2.0, -20.0, 0.7], [0.0, -20.0, 0.4], [0.0, -20.0, 0.2]]},
	# ↑Q (jump_punch) = ESTOCADA AÉREA: ARCO por DEBAJO de la daga, barre de atrás-abajo a la
	# punta al frente (base al extenderse ~f28). [ARCOS tuneables: ángulos 90°=abajo, -90=arriba]
	"jump_punch": {"c": Vector2(30, 20), "r": 540.0, "w": 190.0, "flat": 0.95,
		"base": 26, "stages": [[150.0, 10.0, 0.5], [145.0, 0.0, 0.95], [140.0, -8.0, 1.0], [138.0, -12.0, 0.6], [136.0, -15.0, 0.3]]},
	# ↑W (jump_kick) = PATADA VOLADORA: ARCO GRANDE por debajo de la pierna (pie de atrás -> pie
	# de adelante), base al extender ~f13.
	"jump_kick": {"c": Vector2(20, 30), "r": 660.0, "w": 300.0, "flat": 1.0,
		"base": 12, "stages": [[165.0, 5.0, 0.5], [160.0, -5.0, 0.95], [155.0, -12.0, 1.0], [152.0, -16.0, 0.6], [150.0, -18.0, 0.3]]},
	# jump E (air_spin_kick) = DOBLE PATADA: un ARCO grande por patada (kick1 ~f11, kick2 ~f57).
	"air_spin_kick": {"c": Vector2(20, 20), "r": 640.0, "w": 290.0, "flat": 1.0,
		"base": 8, "stages": [[160.0, 0.0, 0.5], [155.0, -10.0, 0.95], [150.0, -18.0, 1.0], [148.0, -22.0, 0.5]],
		"base2": 52, "stages2": [[160.0, 0.0, 0.5], [155.0, -12.0, 0.95], [150.0, -20.0, 1.0], [148.0, -24.0, 0.5]]},
	# jump R (air_jab) = DOBLE jab de cuchillo: ARCO grande en C (de arriba-atras por la derecha
	# hacia abajo y a la izquierda), sigue el barrido del cuchillo. Dos golpes -> dos arcos.
	"air_jab": {"c": Vector2(20, 10), "r": 600.0, "w": 250.0, "flat": 1.0,
		"base": 12, "stages": [[-40.0, 150.0, 0.5], [-30.0, 155.0, 0.95], [-20.0, 160.0, 1.0], [-15.0, 162.0, 0.5]],
		"base2": 55, "stages2": [[-40.0, 150.0, 0.5], [-30.0, 155.0, 0.95], [-20.0, 160.0, 1.0], [-15.0, 162.0, 0.5]]},
}

# OVERRIDE por-personaje para ROUM (fx_warrior): tanque PESADO de vendas oscuras. Su punch es un
# clip de 145 frames y el puño se ESTIRA a full recién en ~f82 (hit_frame 82), pero heredaba
# SWING_FX["punch"] con base 12 -> la estela salía en plena CARGA. Aquí la estela va retimada al
# frame de la extensión (base 74) y con SU color (carmesí-negro, ver _draw). Solo su tabla: las
# anims que no estén aquí NO dibujan estela (no hereda arcos de katana de DAM). Geometría del punch
# = la horizontal de DAM (posicionaba bien a la cintura), solo se corrige el timing y el color.
const ROUM_SWING_FX := {
	# Q (punch) = RECTO pesado. base 74 (arranca al estirar el brazo), pico ~f79-80, cola hasta f85.
	# c.y=-60 MEDIDO: el puño extendido está en la textura a Y≈580 (c.y = 580-640). Estela horizontal
	# al frente a la ALTURA DEL PUÑO (antes en 150 = cintura, salía muy abajo).
	"punch": {"base": 74, "c": Vector2(10, -60), "r": 640.0, "w": 360.0, "flat": 0.20,
		"stages": [[110.0, 25.0, 0.35], [116.0, 8.0, 0.55], [121.0, -8.0, 0.72], [124.0, -20.0, 0.86],
			[126.0, -28.0, 0.95], [127.0, -33.0, 1.0], [126.0, -36.0, 1.0], [120.0, -37.0, 0.85],
			[110.0, -37.0, 0.62], [99.0, -37.0, 0.40], [90.0, -37.0, 0.22], [84.0, -37.0, 0.10]]},
	# W (kick) = PATADA ALTA (clip 145f): la pierna BARRE de abajo-frente → ARRIBA-frente, el pie llega
	# a lo alto ~f80-84. MEDIDO: pivote en la cadera (Y≈850 -> c.y≈200), pie apex a Y≈338 (arriba-frente,
	# ~-48° desde la cadera). Antes estaba horizontal a ras del suelo (mal). Aquí: ARCO ASCENDENTE en el
	# plano vertical (flat 1.0) que persigue la pierna hacia arriba, pico ~f76-77, cola hasta f82.
	# Ángulos: 0=frente, negativo=ARRIBA, positivo=abajo. r grande = alcanza el pie en lo alto.
	"kick": {"base": 64, "c": Vector2(10, 200), "r": 700.0, "w": 340.0, "flat": 1.0,
		"stages": [[30.0, 6.0, 0.30], [24.0, -1.0, 0.40], [17.0, -8.0, 0.50], [10.0, -15.0, 0.58],
			[3.0, -21.0, 0.66], [-3.0, -27.0, 0.72], [-9.0, -32.0, 0.78], [-15.0, -37.0, 0.83],
			[-20.0, -42.0, 0.88], [-25.0, -46.0, 0.92], [-30.0, -49.0, 0.95], [-34.0, -52.0, 0.98],
			[-38.0, -54.0, 1.0], [-42.0, -56.0, 1.0], [-45.0, -57.0, 0.90], [-48.0, -58.0, 0.72],
			[-50.0, -59.0, 0.52], [-52.0, -60.0, 0.34], [-53.0, -61.0, 0.18]]},
	# E (spin_kick) = CABEZAZO: la cabeza sube (f77) y RAMEA abajo-adelante hasta conectar (~f93). La
	# estela sigue la cabeza ARRIBA→ADELANTE-abajo (arco sobre la cabeza, ref #536). c en el pecho-alto
	# (pivote del cuello), r alcanza la cabeza. Ángulos: -=arriba, 0=frente, +=abajo. base 80, pico ~f88.
	"spin_kick": {"base": 80, "c": Vector2(20, -120), "r": 500.0, "w": 300.0, "flat": 0.42,
		"stages": [[-150.0, -115.0, 0.30], [-138.0, -100.0, 0.42], [-126.0, -86.0, 0.54], [-113.0, -72.0, 0.65],
			[-100.0, -58.0, 0.75], [-87.0, -44.0, 0.84], [-73.0, -30.0, 0.91], [-60.0, -17.0, 0.96],
			[-47.0, -5.0, 1.0], [-35.0, 6.0, 1.0], [-24.0, 15.0, 0.90], [-15.0, 22.0, 0.75],
			[-7.0, 28.0, 0.58], [-1.0, 33.0, 0.40], [4.0, 36.0, 0.24], [8.0, 39.0, 0.12]]},
	# R (weak_punch) = EMPUJÓN a dos manos: los brazos se DISPARAN al frente (~f57-69). Estela HORIZONTAL
	# al frente a la altura del pecho/brazo (ref #537), como el punch pero al timing del empujón. base 58.
	"weak_punch": {"base": 58, "c": Vector2(10, -40), "r": 620.0, "w": 330.0, "flat": 0.20,
		"stages": [[112.0, 25.0, 0.35], [118.0, 6.0, 0.55], [123.0, -12.0, 0.72], [126.0, -24.0, 0.86],
			[127.0, -31.0, 0.95], [126.0, -35.0, 1.0], [120.0, -37.0, 1.0], [110.0, -38.0, 0.82],
			[99.0, -38.0, 0.60], [90.0, -38.0, 0.40], [84.0, -38.0, 0.22], [80.0, -38.0, 0.10]]},
	# ↓Q (crouch_punch) = puño agachado (hand f26-36, hit 32, altura pecho-agachado): estela horizontal
	# al frente (ref #538). base 26, pico ~f29.
	"crouch_punch": {"base": 26, "c": Vector2(10, 20), "r": 640.0, "w": 320.0, "flat": 0.20,
		"stages": [[112.0, 22.0, 0.4], [120.0, -2.0, 0.7], [125.0, -20.0, 0.95], [126.0, -31.0, 1.0],
			[121.0, -36.0, 0.88], [110.0, -38.0, 0.6], [98.0, -38.0, 0.38], [88.0, -38.0, 0.2]]},
	# ↓R (crouch_jab) = DOBLE poke bajo (hits ~f22 y ~f40): dos streaks cortos al frente.
	"crouch_jab": {"base": 18, "c": Vector2(10, 90), "r": 500.0, "w": 190.0, "flat": 0.22,
		"stages": [[116.0, 40.0, 0.5], [122.0, 6.0, 0.9], [102.0, -12.0, 0.6], [88.0, -16.0, 0.3]],
		"base2": 36, "stages2": [[116.0, 40.0, 0.5], [122.0, 6.0, 0.95], [102.0, -12.0, 0.65], [88.0, -16.0, 0.35]]},
	# ↓W (crouch_kick) = DOBLE patada baja (hits ~f68 y ~f110): arco abajo-adelante (pie que baja).
	"crouch_kick": {"base": 60, "c": Vector2(10, 120), "r": 560.0, "w": 230.0, "flat": 0.55,
		"stages": [[-25.0, 8.0, 0.4], [0.0, 35.0, 0.8], [30.0, 58.0, 0.95], [50.0, 68.0, 0.55], [58.0, 70.0, 0.25]],
		"base2": 102, "stages2": [[-25.0, 8.0, 0.4], [0.0, 35.0, 0.8], [30.0, 58.0, 0.95], [50.0, 68.0, 0.55], [58.0, 70.0, 0.25]]},
	# ↓E (sweep) = BARRIDA a ras (f76-96, pie al suelo): estela BAJA horizontal cerca del piso.
	"sweep": {"base": 72, "c": Vector2(10, 400), "r": 660.0, "w": 260.0, "flat": 0.28,
		"stages": [[150.0, 95.0, 0.4], [120.0, 40.0, 0.7], [80.0, 5.0, 1.0], [45.0, -15.0, 0.7], [20.0, -30.0, 0.4], [8.0, -40.0, 0.2]]},
	# aire+Q (jump_punch) = puño aéreo adelante-abajo (brazo f36-56, mano baja ~c.y 300): streak al frente-abajo.
	"jump_punch": {"base": 32, "c": Vector2(10, 300), "r": 520.0, "w": 220.0, "flat": 0.35,
		"stages": [[110.0, 40.0, 0.4], [120.0, 10.0, 0.8], [105.0, -8.0, 0.9], [88.0, -18.0, 0.6], [78.0, -22.0, 0.3]]},
	# aire+W (jump_kick) = DOBLE patada aérea (kicks ~f34 y ~f68): dos streaks al frente (2º más largo).
	"jump_kick": {"base": 26, "c": Vector2(10, 250), "r": 560.0, "w": 230.0, "flat": 0.40,
		"stages": [[100.0, 30.0, 0.4], [120.0, 0.0, 0.85], [100.0, -15.0, 0.6], [85.0, -22.0, 0.3]],
		"base2": 58, "stages2": [[110.0, 40.0, 0.4], [125.0, 5.0, 0.9], [105.0, -12.0, 0.65], [88.0, -20.0, 0.35]]},
	# aire+R (air_jab) = DOBLE jab aéreo alto (jabs ~f34 y ~f70): dos streaks cortos al frente (altura pecho/cabeza).
	"air_jab": {"base": 24, "c": Vector2(10, -100), "r": 560.0, "w": 200.0, "flat": 0.25,
		"stages": [[110.0, 30.0, 0.4], [122.0, 0.0, 0.85], [100.0, -15.0, 0.6], [85.0, -20.0, 0.3]],
		"base2": 60, "stages2": [[110.0, 35.0, 0.4], [125.0, 5.0, 0.9], [105.0, -12.0, 0.65], [88.0, -18.0, 0.35]]},
	# aire+E (air_spin_kick) = DOBLE patada aérea (kicks ~f48 y ~f88): dos streaks al frente (1º más largo).
	"air_spin_kick": {"base": 40, "c": Vector2(10, 120), "r": 620.0, "w": 240.0, "flat": 0.45,
		"stages": [[100.0, 25.0, 0.4], [120.0, -5.0, 0.85], [100.0, -20.0, 0.6], [85.0, -26.0, 0.3]],
		"base2": 80, "stages2": [[105.0, 30.0, 0.4], [122.0, 0.0, 0.9], [102.0, -15.0, 0.65], [86.0, -22.0, 0.35]]},
}

# frame que conecta, alcance y dano de cada ataque (alcances en px de pantalla)
# daño por TIER:  flojo (R) = 50 · medio (Q) = 90 · fuerte (W/E) = 100
const ATTACKS := {
	"punch":        {"hit_frame": 2, "reach": 600.0 * CHAR_SCALE, "low": false, "damage": 90},
	"punch2":       {"hit_frame": 4, "reach": 600.0 * CHAR_SCALE, "low": false, "damage": 90},
	"kick":         {"hit_frame": 4, "reach": 620.0 * CHAR_SCALE, "low": false, "damage": 100},
	"crouch_punch": {"hit_frame": 1, "reach": 600.0 * CHAR_SCALE, "low": true,  "damage": 90},
	"crouch_jab":   {"hit_frame": 1, "reach": 550.0 * CHAR_SCALE, "low": true,  "damage": 50},
	"sweep":        {"hit_frame": 2, "reach": 660.0 * CHAR_SCALE, "low": true,  "trip": true, "damage": 100},
	"crouch_kick":  {"hit_frame": 2, "reach": 620.0 * CHAR_SCALE, "low": false, "strong": true, "damage": 100},
	"jump_punch":   {"hit_frame": 2, "reach": 600.0 * CHAR_SCALE, "low": false, "damage": 90},
	"jump_kick":    {"hit_frame": 2, "reach": 600.0 * CHAR_SCALE, "low": false, "damage": 100},
	"spin_kick":    {"hit_frame": 2, "reach": 600.0 * CHAR_SCALE, "low": false, "strong": true, "damage": 100, "impact_sfx": "kick_impact"},
	"air_spin_kick": {"hit_frame": 4, "reach": 620.0 * CHAR_SCALE, "low": false, "strong": true, "damage": 100, "impact_sfx": "kick_impact"},
	"weak_punch":   {"hit_frame": 1, "reach": 550.0 * CHAR_SCALE, "low": false, "damage": 50},
	"uppercut":     {"hit_frame": 5, "reach": 500.0 * CHAR_SCALE, "low": false, "strong": true, "damage": 100, "impact_sfx": "kick_impact"},   # ROUM ↓→W (los valores reales los da current_attack del warrior)
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
	"air_spin_kick": "res://imagen-action/sound-effect/dam-kick-shout.wav",
	"air_jab": "res://imagen-action/sound-effect/weak-sound-sword.mp3",
	"take_hit": "res://imagen-action/sound-effect/kick-impact.mp3",
	"take_hit_low": "res://imagen-action/sound-effect/kick-impact.mp3",
	"hit_fly": "res://imagen-action/sound-effect/kick-impact.mp3",
	"fly_straight": "res://imagen-action/sound-effect/kick-impact.mp3",
	"kick_impact": "res://imagen-action/sound-effect/kick-impact.mp3",
	"hit_down": "res://imagen-action/sound-effect/impact-sword.mp3",
	"wall_bounce": "res://imagen-action/sound-effect/hard-impact-2.mp3",
	"kick_effect": "res://imagen-action/impact-effect/kick-effect.mp3",
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
	"spin_kick": "spin_kick", "air_spin_kick": "spin_kick", "sweep": "spin_kick", "jump_kick_cast": "spin_kick",
	"weak_punch": "weak_punch", "crouch_jab": "weak_punch",
}
# escalera de fuerza: solo se cancela hacia golpes mas fuertes (R→Q→W→E)
const BTN_LEVEL := {"weak_punch": 1, "attack": 2, "kick": 3, "spin_kick": 4}
const ANIM_LEVEL := {
	"weak_punch": 1, "crouch_jab": 1,
	"punch": 2, "punch2": 2, "crouch_punch": 2, "jump_punch": 2,
	"kick": 3, "crouch_kick": 3, "jump_kick": 3,
	"spin_kick": 4, "air_spin_kick": 4, "sweep": 4, "jump_kick_cast": 4,
}
var sfx_key := ""

@export var is_player := true
@export var archetype := "assassin"   # define la vida (ver ARCH_HP en main.gd): assassin 1050 · wizard 1150 · warrior 1500
# --- VS 2P LOCAL: el "dummy" puede ser un humano con su propio set de teclas ---
@export var input_suffix := ""   # "" = P1 (flechas + QWER) · "_p2" = jugador 2 (IJKL + 7890)
var human_2p := false            # true = este peleador lo controla un humano aunque is_player = false
var debug_keys := true           # teclas de prueba (Z/X/T/Y/I/U): main.gd las apaga en VS 2P

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
var back_tap_win := 0.0    # ventana del DOBLE-TOQUE atrás (←← = blink de Aye / backdash Fe-DAM)
var fwd_tap_win := 0.0     # ventana del DOBLE-TOQUE adelante (→→ = blink de Aye / paso Fe-DAM)
# PASO CORTO (doble-tap de Fe/DAM, estilo SF): deslizamiento breve con decaimiento
var step_t := 0.0
var step_vx := 0.0
const STEP_DUR := 0.16   # SECO y veloz (0.22 se leía lento)
var dash_voz_sfx: AudioStream = null   # voz "water way" al arrancar el dash (carga perezosa)
var spin_voz_sfx: AudioStream = null   # voz "Power Twister" al girar (peonza, carga perezosa)
var dam_spin_voz_sfx: AudioStream = null   # voz "Dancing Sword" del torbellino E de DAM (carga perezosa)
var _roum_hya_sfx: AudioStream = null      # grito "YHAAAAA" GRAVE del cabezazo (E) de ROUM (carga perezosa)
var fire_trail: CPUParticles2D
var wall_squash_t := 0.0  # aplaston contra la pared/piso: compresion breve del sprite
var squash_horizontal := true  # true = contra pared (comprime ancho); false = piso
const SQUASH_DUR := 0.15
# breaker con movimiento (↑↑+E): doble toque arriba reciente + sombras del mortal
var up_tap_t := 0.0
var double_up_t := 0.0
var down_tap_t := 0.0
var double_down_t := 0.0
var back_tap_t := 0.0      # tap reciente de ATRÁS (para el ←←→ del VOID LASH de ROUM)
var double_back_t := 0.0   # doble-atrás reciente (← ←) para exigir ←←→ + W
var _r_press_ms := 0       # ROUM: ms en que se apretó R (para el ULTRA = mantener R ~½s y soltar)
var fwd_tap_t := 0.0       # tap reciente de ADELANTE (para el →→ del UPPERCUT de ROUM)
var double_fwd_t := 0.0    # doble-adelante reciente (→ →) para exigir →→ + Q
var pq_tap_t := 0.0   # instante reciente del tap de Q (para exigir Q+W SIMULTÁNEOS en el parry)
var pw_tap_t := 0.0   # instante reciente del tap de W
var pe_tap_t := 0.0   # tap reciente de E (para la RABIA de DAM: E+R simultáneas)
var pr_tap_t := 0.0   # tap reciente de R
var rage_mode := false   # BERSERK de DAM activo (lo prende/apaga main): oscuro + sombras + más rápido/fuerte
var breaker_fx_t := 0.0
var debris_frames: SpriteFrames = null  # escombros del estrellon (carga perezosa)
# comando del ULTRA (→ R R): cuenta las R con adelante reciente
var ultra_r_t := 0.0
var ultra_r_n := 0
var fwd_recent_t := 0.0
var hcb_t := 0.0        # HCB (→↓←) reciente: media luna atrás para el FROST ORB de Aye (+R)
var _hcb_stage := 0     # máquina: 0=idle, 1=vio ADELANTE, 2=vio ABAJO (tras adelante)
var _hcb_win := 0.0     # ventana para completar el motion antes de reiniciar
var hard_fall := false   # remate del ULTRA: caida acelerada y estrellon fuerte
var ultra_hover := false # juggle aereo durante el ULTRA: se sostiene flotando
var dash_smoke_cd := 0.0 # enfriamiento del humo en golpes fuertes
var _ko_dust_done := false   # dust del AZOTE del KO de pie (una vez por caída)
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
var ko_facedown := false   # KO recibido EN EL AIRE: cae y queda TENDIDO BOCA ABAJO (ko_air)
var airborne := false
var hit_flying := false
var walk_dir := 0
var body_halfw := 112.5    # medio ANCHO de cuerpo para el empuje al caminar (main lo setea
						   # por personaje: DAM ancho, Fe media, Aye chiquita — la separacion
						   # minima entre dos peleadores = suma de sus medios anchos)
var spd := 1.0   # multiplicador de velocidad de desplazamiento por personaje (Favi = ágil)
var jump_mult := 1.0   # multiplicador de ALTURA de salto por personaje (Aye salta un poco más alto)
var base_scale := Vector2.ONE   # escala base del sprite por personaje (Favi = nena, más chica)
# Ajuste fino del KO TENDIDO (px de pantalla). El frame ancla su pixel más bajo al piso, pero en
# poses acostadas ese pixel es una mano/katana y el CUERPO flota. Se corrige por personaje:
#   up   = KO boca ARRIBA ("ko")     (+ baja el cuerpo, - lo sube)
#   down = KO boca ABAJO ("ko_air")  (+ baja, - sube)
var ko_lie_drop_up := 0.0
var ko_lie_drop_down := 0.0
var has_super_armor := false   # TANK (DAM): aguanta golpes NO-lanzadores en el arranque de su pesado
var swing_layer: Node2D   # capa POR DELANTE del sprite para la estela del arma (z alto)
var fly_lean := 0.0   # dirección del empujón al salir volando (para inclinar el cuerpo en el aire)
var vel_y := 0.0
var vel_x := 0.0
var shove_vx := 0.0   # EMPUJÓN en SUELO (ROUM weak_punch): desliza al rival hacia atrás sin lanzarlo; decae con fricción
var shove_t := 0.0    # timer del empujón: desliza mientras dure (indep. del take_hit/hitstop y de la DIRECCIÓN)
const SHOVE_FRICTION := 1000.0   # px/s^2 de frenado del empujón (más bajo = desliza MÁS lejos)
var floor_bounce_pending := false   # REBOTE contra el suelo (ROUM E/cabezazo): al tocar el piso rebota ARRIBA una vez
var hitstop_t := 0.0   # HITSTOP: frames de congelamiento en el impacto (peso del golpe)
const FREEZE_DUR := 1.0   # Aye ↓E (ice-spikes): tiempo que el rival queda CONGELADO en su frame (tinte morado)
var frozen_t := 0.0       # >0 = inmóvil, sprite pausado en su pose, teñido de morado (poder de hielo)
const SLOW_DUR := 0.5     # ESFERA AZUL de Aye (E): tiempo que el rival queda AZUL y LENTO
const SLOW_FACTOR := 0.45 # multiplicador de movimiento mientras dura el slow (se mueve lento, no inmóvil)
var slow_t := 0.0         # >0 = rival AZUL y LENTO (esfera azul); tinte azul + walk a SLOW_FACTOR
func apply_orb_slow() -> void:   # lo llama el árbitro cuando la esfera azul impacta
	slow_t = SLOW_DUR
var orb_trap_t := 0.0        # ESFERA de Zetma: >0 = rival en CÁMARA LENTA, no actúa, teñido morado (sí recibe golpes)
var orb_trap_top_y := -640.0 # cima de la esfera en espacio LOCAL: la barra de tiempo se le pega justo encima
var orb_trap_sprite_home := Vector2.ZERO  # pos normal del sprite: para HALARLO al centro del orb y luego restaurarlo
var orb_trap_max := 2.0      # duración total de la esfera (para la barra que se vacía)
var orb_trap_was_input := true
var orb_trap_was_ai := false
var orb_haste_t := 0.0       # Zetma: >0 = velocidad de movimiento aumentada (mientras el rival está en la esfera)
var air_float_t := 0.0 # flote aéreo SOLO tras conectar un golpe en el aire (juggle)
var juggle_hold_t := 0.0   # SOSTÉN de juggle (víctima): tras cada rebote, la caída es LENTA un rato para que el combo aéreo la alcance
var air_move_used := false   # ya se hizo UN golpe aéreo este salto (hasta caer o conectar)
const AIR_MOVES := ["jump_punch", "jump_kick", "jump_kick_cast", "air_jab", "air_jab_2", "air_spin_kick"]
var base_material: Material = null   # material base del sprite (color alterno del P2, etc.)
var body_k := 1.0   # ALTURA real del cuerpo vs DAM (Fe 0.71, Aye 0.65): escala alcances verticales y chispas — un modelo bajito NO pega a alturas de DAM

# HITSTOP: al conectar un golpe, este peleador se CONGELA 'dur' segundos (no se mueve
# ni avanza su animación). Le da PESO al golpe y esa pausa entre golpe y golpe pro.
func apply_hitstop(dur: float) -> void:
	hitstop_t = maxf(hitstop_t, dur)
	sprite.speed_scale = 0.0   # congela la animación en el frame del impacto
var floor_y := 0.0
var punch_followup := false  # →+Q: segundo corte encadenado pendiente
var buffer_action := ""      # boton guardado esperando ventana de cancel
var buffer_t := 0.0
var buffer_air := false      # el boton se apreto EN EL AIRE: al replay NO abre golpes agachados
var breaker_ready := true    # combo breaker disponible (uno por ronda)
var breaker_inv_t := 0.0     # invencibilidad tras romper
var parry_t := 0.0           # ventana del PARRY (Q+W): si te pegan mientras >0 → COUNTER
const PARRY_WINDOW := 0.5    # medio segundo de ventana de parry
const PARRY_SIMUL := 0.09    # Q y W deben pulsarse dentro de esta ventana (~simultáneas), no una mantenida

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
var swing_y_off := 0.0  # corrimiento Y de las ESTELAS: el cuerpo de Fe va ~144px más ABAJO en el lienzo que el de DAM (para el que están tuneadas)
var fx_floral := false  # true = estela MORADA+ROSA floral (Aye); tiene prioridad sobre fx_blue
var fx_dark := false    # true = ZETMA (ninja oscuridad): estelas VERDE/void; usa audio propio por anim
var fx_warrior := false # true = ROUM (tanque de vendas oscuras): estela SMOKY carmesí-negra, tabla propia (ROUM_SWING_FX)
var roum_super_t := 0.0 # >0 = ROUM está en su SÚPER ↓W (cabezazo+onda): la ONDA hace el daño, el cuerpo NO golpea
var dust_tint := Color(1, 1, 1)   # color del POLVO segun el stage (main lo setea: azul oscuro en stages oscuros)
var _zetma_snd := {}    # cache de audios de Zetma por anim (imagen-action/zetma/sound-effect/<anim>.wav)

# nombre de acción de ESTE peleador: P1 usa las acciones tal cual ("attack"),
# el jugador 2 local las versiones con sufijo ("attack_p2"). Ver [input] en project.godot.
func act(n: String) -> String:
	return n + input_suffix

# ¿lo controla un humano? (P1 siempre; el dummy solo en VS 2P via human_2p)
func _es_humano() -> bool:
	return is_player or human_2p

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
		# PRUEBA del usuario (2026-08-15): impacto NUEVO impact-2. REVERTIR = comentar la
		# linea de impact-2-fx y descomentar la de chispas-impact-3.
		"hit": ["res://imagen-action/impact-effect/impact-2-fx/impact-2-fx-%d.png", 8, 30.0],
		# "hit": ["res://imagen-action/impact-effect/chispas-impact-3/chispas-impact-3-%d.png", 8, 30.0],
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
	# ORBES DE AYE-2: al empezar un gesto de lanzar (punch/kick/spin_kick), rearma el disparo del
	# orbe y captura el modo (boomerang vs plantar por el motion ←→, buffered al inicio del gesto).
	if fx_floral and _orb_color_for(nombre) >= 0:
		_orb_fired = false
		_orb_pending_mode = 1 if _orb_plant_buffered() else 0
		_cast_border_on(0.45, _orb_outline_col(nombre))   # BORDE del color del orbe usado
	# AYE-2: el "levantarse de agachado" corre acelerado (speed_scale=1.5). Al cambiar a CUALQUIER
	# otra anim (pose/golpe/take_hit/…) se restaura la velocidad normal. Se respeta un congelado
	# activo (hitstop/frozen/orb_trap manejan speed_scale por su cuenta).
	if fx_floral and nombre != "crouch" and sprite.speed_scale != 1.0 \
			and hitstop_t <= 0.0 and frozen_t <= 0.0 and orb_trap_t <= 0.0:
		sprite.speed_scale = 1.0
	# ZETMA: cada clip suyo trae su propio sonido. Al cambiar de anim, si existe
	# imagen-action/zetma/sound-effect/<anim>.wav, se reproduce (pedido: usar el audio de
	# los clips). Se cachea por anim. La POSE tambien suena al asentarse en guardia (pedido).
	if fx_dark:
		# corta el sonido de CAMINAR al dejar de caminar (si no, quedaba pegado sonando)
		if nombre != "walk" and sfx_key == "walk" and sfx_player.playing:
			sfx_player.stop()
		_play_zetma_snd(nombre)   # incluye "pose": usa el audio que trae el clip de idle
	var es_impacto := nombre in ["take_hit", "take_hit_low", "hit_fly", "fly_straight"]
	if es_impacto and impact_sfx_override != "" and sfx.has(impact_sfx_override):
		nombre = impact_sfx_override
	# quejido de DOLOR al recibir un golpe (Aye "UGH!" / Fe Ugh-Agh / DAM Agh-Ugh;
	# es_impacto se calcula ANTES del remap del sonido)
	if es_impacto:
		_play_ugh()
	# Fe en ARRIBA+E (air_spin_kick): NO usa el grito de DAM (dam-kick-shout); usa SU voz de
	# giratoria ("Power Twister" furiosa) + un swoosh, igual que su spin_kick de suelo.
	if fx_blue and nombre == "air_spin_kick":
		var ruta := "res://imagen-action/favi/Fe-sound-effect/spin-fe-furiosa.wav"
		if spin_voz_sfx == null and ResourceLoader.exists(ruta):
			spin_voz_sfx = load(ruta)
		if spin_voz_sfx != null:
			voz_player.stream = spin_voz_sfx
			voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
			voz_player.play()
		_play_sfx_key("spin_kick")   # swoosh de swing (no la voz de DAM)
	elif fx_blue and nombre == "air_jab":
		# Fe ARRIBA+R = PATADA AÉREA DOBLE: DOS kicks. El 1º en sfx_player y el 2º en voz_player
		# (canal APARTE) ~0.14s después, así se oyen las DOS patadas sin cortarse (doble claro).
		# NO el "weak-sound-sword" (blade), que no le va a las agujas.
		_play_sfx_key("kick_effect")
		get_tree().create_timer(0.14).timeout.connect(_play_kick2, CONNECT_ONE_SHOT)
	elif fx_blue and nombre == "spin_kick":
		# PEONZA de Fe: WHOOSH giratorio (sound-effect/whoosh.mp3) en vez del slash de
		# espada — su voz ("Power Twister") va APARTE por voz_player, se mantienen ambas
		_play_aye_swoosh("res://imagen-action/sound-effect/whoosh.mp3", -4.0)
	elif not fx_blue and not fx_floral and not fx_dark and nombre == "jump_kick":
		# MOLINETE de DAM (salto+W): el MISMO whoosh giratorio de la peonza — la espada
		# girando en círculos suena a remolino, no al slash de un tajo
		_play_aye_swoosh("res://imagen-action/sound-effect/whoosh.mp3", -4.0)
	elif not fx_blue and not fx_floral and not fx_dark and not fx_warrior and nombre == "spin_kick":
		# E de DAM (torbellino): whoosh giratorio + SU VOZ "Dancing Sword" (fórmula inferno).
		# NO Zetma (fx_dark): su E usa su propio audio (_play_zetma_snd), sin la voz de DAM.
		# NO ROUM (fx_warrior): su E es un CABEZAZO -> cae a su rama de whoosh pesado, sin la voz de DAM.
		# aparte por voz_player — como la peonza de Fe, se oyen ambas
		_play_aye_swoosh("res://imagen-action/sound-effect/whoosh.mp3", -4.0)
		var dsw := "res://imagen-action/sound-effect/voz-dancing-sword.wav"
		if dam_spin_voz_sfx == null and ResourceLoader.exists(dsw):
			dam_spin_voz_sfx = load(dsw)
		if dam_spin_voz_sfx != null:
			voz_player.stream = dam_spin_voz_sfx
			voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
			voz_player.play()
	elif not fx_blue and not fx_floral and not fx_dark and not fx_warrior and nombre == "air_spin_kick":
		# salto+E de DAM: FUERA el "dam-kick-shout.wav" (SU VOZ — se va a cambiar, pedido);
		# mientras tanto el mismo whoosh del molinete, cortado al terminar la anim.
		# NO ROUM (fx_warrior): cae a su rama de whoosh pesado propio.
		_play_aye_swoosh("res://imagen-action/sound-effect/whoosh.mp3", -4.0)
	elif fx_dark and nombre == "air_spin_kick":
		_play_sfx_key("kick")   # ZETMA: swing de golpe (sword-slash), NO la voz dam-kick-shout de DAM
	elif fx_floral and nombre == "jump_kick_cast":
		# AYE gira el báculo (molinete): WHOOSH del giro (el sonido que va creando al rotar el báculo)
		_play_aye_swoosh("res://imagen-action/aye/sound-effect/whoosh.mp3", -5.0)
	elif fx_floral and nombre in SWING_SFX:
		# AYE blande un BÁCULO, no una espada: swoosh simple en vez del "sword-slash-and-swing"
		_play_aye_swoosh("res://imagen-action/aye/sound-effect/simple-whoosh.mp3", -7.0)
	elif fx_warrior and nombre == "spin_kick" and not ultra_hover:
		# ROUM CABEZAZO (E): SIN swoosh (el whoosh.mp3 sonaba al molinete de espada de DAM, pedido quitar).
		# (durante su ULTRA, ultra_hover=true: NO re-dispara la voz/borde por cada cabezazo de la ráfaga)
		# Solo su GRITO grave "YHAAAAA" (canal de voz aparte). El impacto suena al conectar (~f93).
		var hyap := "res://imagen-action/roum/sound-effect/voz-hya-roum.wav"
		if _roum_hya_sfx == null and ResourceLoader.exists(hyap):
			_roum_hya_sfx = load(hyap)
		if _roum_hya_sfx != null:
			voz_player.stream = _roum_hya_sfx
			voz_player.pitch_scale = 1.0   # ya viene procesada grave (-3 st): no re-pitchear
			voz_player.play()
		# E (cabezazo) = SEMI-súper: BORDE + SHADE carmesí en ROUM (su color de poder). Solo el E NORMAL
		# (roum_super_t<=0); el ↓W (súper) ya pone su propio borde/shade en _roum_super, no duplicar.
		if roum_super_t <= 0.0:
			var mbe := get_parent()
			if mbe and mbe.has_method("_roum_border"):
				mbe._roum_border(self, true)
				mbe._roum_shade(0.4)
				get_tree().create_timer(1.05).timeout.connect(_roum_border_off_self, CONNECT_ONE_SHOT)
	elif fx_warrior and nombre in SWING_SFX:
		# ROUM: SIN sonido de swing (pedido: el whoosh.mp3 sonaba al molinete de espada de DAM).
		# Sus puños/patadas suenan al IMPACTO (kick_impact) cuando conectan; el windup va mudo.
		pass
	else:
		_play_sfx_key(nombre)
	# grito de ATAQUE en golpes físicos (canal de voz, aparte del swoosh; con cooldown):
	# "HYA!" de Aye / "HAA!" de Fe — misma lista de movimientos
	if (fx_floral or fx_blue) and nombre in AYE_HYA_MOVES:
		_maybe_hya()
	# humo de dash en golpes fuertes (con cooldown para no saturar en el ultra).
	# sale atras del personaje (extremo trasero), no adelante
	# ...pero NO durante el ULTRA de Fe (aéreo o en el suelo): sin humo en su combo cinemático
	var _mb := get_parent()
	var _en_ultra_fe: bool = fx_blue and _mb != null and bool(_mb.get("ultra_active"))
	# ROUM (fx_warrior): sus golpes FUERTES (R empujón, Q recto, ↓Q agachado) también sueltan POLVO (pedido)
	var _humo_move: bool = nombre in SMOKE_MOVES or (fx_warrior and nombre in ["weak_punch", "punch", "crouch_punch"])
	if _humo_move and not airborne and dash_smoke_cd <= 0.0 and special_t <= 0.0 and not ultra_hover and not _en_ultra_fe:
		if fx_warrior:
			_spawn_dash_smoke(0.6, 150.0, false, 0.08)   # ROUM: MÁS ATRÁS (atras 150) y PEGADO a los pies (lift 0.08, pedido)
		elif fx_floral:
			_spawn_dash_smoke(0.5, 60.0, false, 0.12)   # AYE: su ancla queda alto -> lift bajo para que salga PEGADO al piso
		else:
			_spawn_dash_smoke(0.5, 60.0)   # JUSTO al pie (no en el aire: el polvo es de suelo)
		dash_smoke_cd = 0.28

# quita el BORDE carmesí del E (semi-súper) al terminar su ventana (conectado por timer one-shot)
func _roum_border_off_self() -> void:
	var mb := get_parent()
	if mb and mb.has_method("_roum_border"):
		mb._roum_border(self, false)

func _play_sfx_key(k: String) -> void:
	if sfx.has(k):
		sfx_key = k
		sfx_player.stream = sfx[k]
		sfx_player.pitch_scale = randf_range(0.94, 1.06)  # variacion natural
		sfx_player.volume_db = SFX_VOL.get(k, 0.0)
		sfx_player.play(SFX_START.get(k, 0.0))

# swoosh propio de Aye (báculo): reutiliza el canal de swing (sfx_key sigue en SWING_SFX para que
# el impacto lo corte con duck_swing). Cachea el stream por ruta.
var _aye_swoosh_cache := {}
func _play_aye_swoosh(path: String, vol := -6.0, pitch := 1.0) -> void:
	if not _aye_swoosh_cache.has(path):
		_aye_swoosh_cache[path] = load(path) if ResourceLoader.exists(path) else null
	var st = _aye_swoosh_cache[path]
	if st == null:
		return
	sfx_key = String(sprite.animation)   # queda en SWING_SFX -> duck_swing lo corta al conectar
	sfx_player.stream = st
	sfx_player.pitch_scale = randf_range(0.94, 1.06) * pitch   # pitch<1 = whoosh más grave/pesado (ROUM)
	sfx_player.volume_db = vol
	sfx_player.play(0.05)

# AYE: grito de batalla "HYA!" en sus golpes FÍSICOS. Va en el canal de VOZ (aparte del swoosh) y con
# COOLDOWN para no gritar en cada jab. NO se usa en sus casteos (esos ya gritan "prism-bolt").
const AYE_HYA_MOVES := ["weak_punch", "crouch_jab", "punch", "punch2", "crouch_punch",
	"kick", "crouch_kick", "sweep", "jump_punch", "jump_kick", "spin_kick"]
# dos gritos: ALTERNA al azar HYA / HA para que no suene siempre igual
const AYE_SHOUT_PATHS := [
	"res://imagen-action/aye/sound-effect/HYA_Cupcake_Eleven_v3_019ff608-43d5-75e6-b159-945504a28baf.mp3",
	"res://imagen-action/aye/sound-effect/HA_Cupcake_Eleven_v3_019ff60b-3e2b-7b14-9081-ebbf542f7f79.mp3",
]
# FE: su "HAA!" de ataque (haa-fe.wav, procesado); un solo archivo — la variedad la pone
# el pitch aleatorio más amplio
const FE_SHOUT_PATHS := ["res://imagen-action/favi/Fe-sound-effect/haa-fe.wav"]
var _aye_shout_sfx := []   # streams cacheados (mismo orden que AYE_SHOUT_PATHS)
var _fe_shout_sfx := []
var _hya_ms := 0
func _maybe_hya() -> void:
	var now := Time.get_ticks_msec()
	if now - _hya_ms < 600:   # cooldown: no gritar en CADA golpe (rápidos no se solapan)
		return
	_hya_ms = now
	var lista: Array
	if fx_floral:
		if _aye_shout_sfx.is_empty():
			for p in AYE_SHOUT_PATHS:
				_aye_shout_sfx.append(load(p) if ResourceLoader.exists(p) else null)
		lista = _aye_shout_sfx
	else:
		if _fe_shout_sfx.is_empty():
			for p in FE_SHOUT_PATHS:
				_fe_shout_sfx.append(load(p) if ResourceLoader.exists(p) else null)
		lista = _fe_shout_sfx
	var st = lista[randi() % lista.size()]
	if st != null:
		voz_player.stream = st
		voz_player.pitch_scale = randf_range(0.92, 1.08)
		voz_player.play()

# AYE: quejido "UGH!" al RECIBIR un golpe (take_hit / hit_fly / etc.). Canal de voz, con cooldown para
# que en un multi-hit no se solape en cada golpe.
const AYE_UGH_PATH := "res://imagen-action/aye/sound-effect/UGH_Cupcake_Eleven_v3_019ff60c-aa95-7ebd-8938-234fc599960e.mp3"
# FE: sus quejidos de dolor — DOS ("Ugh!" y "Agh!"), alterna al azar como los gritos
const FE_UGH_PATHS := [
	"res://imagen-action/favi/Fe-sound-effect/ugh-fe.wav",
	"res://imagen-action/favi/Fe-sound-effect/agh-fe.wav",
]
# DAM: sus quejidos — "Agh!" y "Ugh!" (procesados con la fórmula inferno), alterna al azar
const DAM_UGH_PATHS := [
	"res://imagen-action/sound-effect/voz-agh-dam.wav",
	"res://imagen-action/sound-effect/voz-ugh-dam.wav",
]
var _aye_ugh_sfx: AudioStream = null
var _fe_ugh_sfx := []
var _dam_ugh_sfx := []
var _ugh_ms := 0
func _play_ugh() -> void:
	var now := Time.get_ticks_msec()
	if now - _ugh_ms < 350:   # cooldown corto (deja oír golpes distintos, no cada frame de un multi-hit)
		return
	_ugh_ms = now
	var st: AudioStream = null
	if fx_floral:
		if _aye_ugh_sfx == null:
			_aye_ugh_sfx = load(AYE_UGH_PATH) if ResourceLoader.exists(AYE_UGH_PATH) else null
		st = _aye_ugh_sfx
	elif fx_blue:
		if _fe_ugh_sfx.is_empty():
			for p in FE_UGH_PATHS:
				if ResourceLoader.exists(p):
					_fe_ugh_sfx.append(load(p))
		if not _fe_ugh_sfx.is_empty():
			st = _fe_ugh_sfx[randi() % _fe_ugh_sfx.size()]   # Ugh o Agh al azar
	else:
		if _dam_ugh_sfx.is_empty():
			for p in DAM_UGH_PATHS:
				if ResourceLoader.exists(p):
					_dam_ugh_sfx.append(load(p))
		if not _dam_ugh_sfx.is_empty():
			st = _dam_ugh_sfx[randi() % _dam_ugh_sfx.size()]   # Agh o Ugh al azar
	if st != null:
		voz_player.stream = st
		voz_player.pitch_scale = randf_range(0.68, 0.78) if fx_warrior else randf_range(0.95, 1.06)   # ROUM tanque: quejido GRAVE
		voz_player.play()

# AYE: grito "NOOOOOO!" cuando PIERDE (recibe el último golpe -> KO). Suena UNA sola vez.
const AYE_NO_PATH := "res://imagen-action/aye/sound-effect/NOOOOOO_Cupcake_Eleven_v3_019ff60e-c81b-7b9b-a55b-c0ce8fe29dcc.mp3"
var _ko_cry_done := false
func _play_ko_cry() -> void:
	# grito de DERROTA (una vez): Aye "NOOOOO!", Fe el suyo, DAM "HAAAA!" (fórmula inferno)
	if _ko_cry_done:
		return
	var ruta := ""
	if fx_floral:
		ruta = AYE_NO_PATH
	elif fx_blue:
		ruta = "res://imagen-action/favi/Fe-sound-effect/nooo-fe-derrota.wav"
	else:
		ruta = "res://imagen-action/sound-effect/voz-ko-dam.wav"
	if ruta == "" or not ResourceLoader.exists(ruta):
		return
	_ko_cry_done = true
	voz_player.stream = load(ruta)
	voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
	voz_player.play()

# BERSERK: chispas ROJAS tipo ascua saliendo de los OJOS mientras dura la rabia
# (como las particulas del cut-in pero rojas). Cuadraditos que vuelan hacia atras y suben.
var rage_eyes: CPUParticles2D = null
func _update_rage_eyes() -> void:
	if rage_mode and rage_eyes == null:
		rage_eyes = CPUParticles2D.new()
		rage_eyes.amount = 16
		rage_eyes.lifetime = 0.65
		rage_eyes.local_coords = false          # la estela queda flotando en el mundo al moverse
		rage_eyes.spread = 22.0
		rage_eyes.gravity = Vector2(0, -70)     # ascuas: flotan hacia ARRIBA levemente
		rage_eyes.initial_velocity_min = 70.0
		rage_eyes.initial_velocity_max = 190.0
		rage_eyes.scale_amount_min = 3.5
		rage_eyes.scale_amount_max = 7.0        # cuadraditos pixel (sin textura = cuadrado)
		var g := Gradient.new()
		g.colors = PackedColorArray([Color(2.2, 0.55, 0.25, 1.0), Color(1.6, 0.12, 0.08, 0.85), Color(0.7, 0.03, 0.02, 0.0)])
		g.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
		rage_eyes.color_ramp = g
		sprite.add_child(rage_eyes)
	if rage_eyes == null:
		return
	rage_eyes.emitting = rage_mode and not koed and frozen_t <= 0.0
	# nacen AL FRENTE de la cara (voltean con el facing) y vuelan hacia ATRÁS
	rage_eyes.position = Vector2(42.0 * float(facing), -95.0)
	rage_eyes.direction = Vector2(-float(facing), -0.35)

# ZETMA: reproduce el sonido propio del clip de esta anim (si existe), en el canal SFX.
func _play_zetma_snd(anim: String) -> void:
	if anim == "walk":
		return   # sin sonido de pasos de Zetma (pedido)
	if not _zetma_snd.has(anim):
		var p := "res://imagen-action/zetma/sound-effect/%s.wav" % anim
		_zetma_snd[anim] = load(p) if ResourceLoader.exists(p) else null
	var st = _zetma_snd[anim]
	if st != null:
		# RESPIRACIÓN de la pose: más BAJA y SIN pitch-shift (el pitch la hacía "robótica"), y no
		# la reinicies si ya suena (evita el entrecortado al volver a idle tras cada acción).
		if anim == "pose":
			if sfx_key == "pose" and sfx_player.playing:
				return
			sfx_key = anim
			sfx_player.stream = st
			sfx_player.pitch_scale = 1.0
			sfx_player.volume_db = -8.0
			sfx_player.play()
			return
		sfx_key = anim
		sfx_player.stream = st
		sfx_player.pitch_scale = randf_range(0.96, 1.05)
		sfx_player.volume_db = 0.0
		sfx_player.play()

# 2ª patada del air_jab DOBLE de Fe: suena en el canal de VOZ (aparte) para no cortar la 1ª
func _play_kick2() -> void:
	if sfx.has("kick_effect"):
		voz_player.stream = sfx["kick_effect"]
		voz_player.pitch_scale = randf_range(0.94, 1.06)
		voz_player.play()

# al conectar un golpe, el impacto del rival corta nuestro whoosh
func duck_swing() -> void:
	if sfx_player.playing and sfx_key in SWING_SFX:
		sfx_player.stop()

func set_facing(f: int) -> void:
	if f != 0 and f != facing and not airborne:
		facing = f
		sprite.flip_h = f < 0

# ORBES DE AYE-2 (fx_floral): estado del disparo del orbe desde el gesto de PIE.
var _orb_fired := false        # ya se lanzó el orbe en este gesto (rearmado en _on_animation_changed)
var _orb_pending_mode := 0     # 0=boomerang, 1=plantar (main.OMODE_*); se fija al iniciar el gesto
func _orb_color_for(anim: String) -> int:
	# 🟡🩷🔵 por FAMILIA de botón (de pie / agachado / en el aire) — main.ORB_YELLOW/PINK/BLUE
	return {"punch": 0, "crouch_punch": 0, "jump_punch": 0,
		"kick": 1, "crouch_kick": 1, "jump_kick": 1,
		"spin_kick": 2, "sweep": 2, "air_spin_kick": 2}.get(anim, -1)
func _orb_outline_col(anim: String) -> Color:
	match _orb_color_for(anim):
		0: return Color(1.6, 1.3, 0.35, 1.0)      # 🟡
		1: return Color(1.7, 0.6, 1.15, 1.0)      # 🩷
		2: return Color(0.5, 0.95, 1.8, 1.0)      # 🔵
	return Color(1.45, 0.35, 2.0, 1.0)
func _orb_plant_buffered() -> bool:
	# ←→ (ATRÁS y luego ADELANTE): back_recent_t quedó armado al tocar atrás; ahora vamos adelante.
	var fwd := Input.get_axis(act("ui_left"), act("ui_right"))
	return back_recent_t > 0.0 and fwd != 0.0 and int(signf(fwd)) == facing

# RECALL (R = weak_punch): tap = 1 (más viejo, FIFO) · hold = los 3. Solo si hay plantados.
const ORB_RECALL_HOLD := 0.25
var _orb_recall_held := 0.0
var _orb_recall_hold_done := false
var _orb_antiair_done := false   # ↓R disparó el anti-aéreo este press (se rearma al soltar R)
func _has_planted_orbs() -> bool:
	var mb := get_parent()
	if mb == null or not mb.has_method("_orb_set_for"):
		return false
	var st: Dictionary = mb._orb_set_for(self)
	return not st.is_empty() and not (st["plant_order"] as Array).is_empty()
func _do_recall(n: int) -> void:
	var mb := get_parent()
	if mb != null and mb.has_method("_orb_recall"):
		mb._orb_recall(self, n)
func _do_antiair() -> void:   # ↓R: las 3 esferas barren un arco amplio hacia arriba (anti-aéreo)
	var mb := get_parent()
	if mb != null and mb.has_method("_orb_antiair"):
		mb._orb_antiair(self)
func _do_spin() -> void:   # salto+R: las 3 esferas giran en círculo alrededor de Aye (escudo, levanta al tocar)
	var mb := get_parent()
	if mb != null and mb.has_method("_orb_spin"):
		mb._orb_spin(self)
func _do_throw_all() -> void:   # R de pie: tira las 3 hacia adelante una por una (boomerang volley)
	var mb := get_parent()
	if mb != null and mb.has_method("_orb_throw_all"):
		mb._orb_throw_all(self)

func current_attack() -> Dictionary:
	# el mortal del breaker no es un golpe real (el impacto lo aplica on_breaker)
	if breaker_inv_t > 0.0:
		return {}
	# el DASH DE AGUJAS no pega por la animación: el árbitro (main._fe_dash_attack) mete los 3 golpes
	if fe_dash_active:
		return {}
	# ROUM (TANQUE, archetype warrior, sin fx flag): sus golpes son clips PROPIOS de 145 frames.
	# hit_frame MEDIDO (el puño/pie llega a full extensión ~f82/f76) — antes usaba el de DAM (~f2)
	# y pegaba en la CARGA. reach de tanque (brazo largo). El impacto/streak lo pone el árbitro.
	if archetype == "warrior" and sprite.is_playing():
		if roum_super_t > 0.0:
			return {}   # SÚPER ↓W en curso: la ONDA expansiva hace el daño (main._roum_nova), no el cuerpo
		if sprite.animation == "punch":
			return {"name": "punch", "frame": int(sprite.frame), "hit_frame": 82,
				"reach": 600.0 * CHAR_SCALE, "low": false, "strong": false,
				"damage": 90, "impact_sfx": "kick_impact"}
		if sprite.animation == "kick":
			return {"name": "kick", "frame": int(sprite.frame), "hit_frame": 76,
				"reach": 560.0 * CHAR_SCALE, "low": false, "strong": true,
				"damage": 100, "impact_sfx": "kick_impact"}
		# R (weak_punch) = EMPUJÓN a dos manos (clip 145f): las manos se disparan al pecho ~f57-69 y
		# SOSTIENEN f69-93 (MEDIDO). Poco daño pero EMPUJA al rival deslizándolo hacia atrás (shove) —
		# no lo lanza. hit_frame 66 (extensión), shove = px/s de deslizamiento en suelo.
		if sprite.animation == "weak_punch":
			return {"name": "weak_punch", "frame": int(sprite.frame), "hit_frame": 66,
				"reach": 540.0 * CHAR_SCALE, "low": false, "strong": false,
				"damage": 40, "shove": 500.0, "impact_sfx": "kick_impact"}
		# E (spin_kick) = CABEZAZO (clip 145f): se recoge (f13-73) y hace LUNGE con la cabeza al frente,
		# clavándola a full ~f93-97 (MEDIDO). Golpe FUERTE que LANZA (top de la escalera R→Q→W→E, cierra
		# combos). Sin vendas -> sin estela. hit_frame 93.
		if sprite.animation == "spin_kick":
			return {"name": "spin_kick", "frame": int(sprite.frame), "hit_frame": 93,
				"reach": 540.0 * CHAR_SCALE, "low": false, "strong": true,
				"damage": 110, "impact_sfx": "kick_impact"}
		# ↓↑W (uppercut) = puño ASCENDENTE (13f ida-y-vuelta): golpea en la subida (~f5) y LANZA al aire.
		if sprite.animation == "uppercut":
			return {"name": "uppercut", "frame": int(sprite.frame), "hit_frame": 5,
				"reach": 500.0 * CHAR_SCALE, "low": false, "strong": true,
				"damage": 100, "impact_sfx": "kick_impact"}
		# ↓R (crouch_jab) = DOBLE poke bajo (clip 145f): 1er golpe ~f22 (xmax 1077), 2º ~f40 (extensión
		# full xmax 1148). Nombres DISTINTOS = el árbitro cuenta 2 impactos. Bajo (block agachado).
		if sprite.animation == "crouch_jab":
			var wcj := int(sprite.frame)
			if wcj < 32:
				return {"name": "crouch_jab", "frame": wcj, "hit_frame": 22,
					"reach": 500.0 * CHAR_SCALE, "low": true, "strong": false,
					"damage": 40, "impact_sfx": "kick_impact"}
			return {"name": "crouch_jab_2", "frame": wcj, "hit_frame": 40,
				"reach": 530.0 * CHAR_SCALE, "low": true, "strong": false,
				"damage": 40, "impact_sfx": "kick_impact"}
		# ↓Q (crouch_punch) = puñetazo agachado FUERTE (clip 145f): sale f26-36 y SOSTIENE largo
		# (xmax 1279, el brazo más largo). Golpe MEDIO (block de pie o agachado). hit_frame 32.
		if sprite.animation == "crouch_punch":
			return {"name": "crouch_punch", "frame": int(sprite.frame), "hit_frame": 32,
				"reach": 590.0 * CHAR_SCALE, "low": false, "strong": false,
				"damage": 85, "impact_sfx": "kick_impact"}
		# ↓W (crouch_kick) = patada baja de UN solo golpe (pedido). Ventana ACOTADA f60-96 (1ª patada del
		# clip) para garantizar un impacto único. Baja (block agachado). (↓W normal = super; esto es respaldo.)
		if sprite.animation == "crouch_kick" and int(sprite.frame) >= 60 and int(sprite.frame) <= 96:
			return {"name": "crouch_kick", "frame": int(sprite.frame), "hit_frame": 68,
				"reach": 530.0 * CHAR_SCALE, "low": true, "strong": false,
				"damage": 90, "impact_sfx": "kick_impact"}
		# ↓E (sweep) = BARRIDA baja (clip 145f): el pie barre a ras ~f76-96 (xmax 1175, footY ~1050 =
		# suelo). DERRIBA al rival (trip). Baja (block agachado). hit_frame 78. VENTANA ACOTADA a f<=90:
		# el clip es LARGO (145f) y quedaba "activo" toda la anim -> si el árbitro reseteaba 'done'
		# pegaba 2 veces. Fuera de la ventana devuelve {} (catch-all) = UN solo golpe garantizado.
		if sprite.animation == "sweep" and int(sprite.frame) >= 72 and int(sprite.frame) <= 86:
			return {"name": "sweep", "frame": int(sprite.frame), "hit_frame": 78,
				"reach": 580.0 * CHAR_SCALE, "low": true, "strong": false, "trip": true,
				"damage": 80, "impact_sfx": "kick_impact"}
		# aire+Q (jump_punch) = puño AÉREO adelante-abajo (clip 145f): el brazo sale ~f36-56 (xmax 990,
		# mano baja). Golpe de salto (jump-in). hit_frame 42.
		if sprite.animation == "jump_punch":
			return {"name": "jump_punch", "frame": int(sprite.frame), "hit_frame": 42,
				"reach": 490.0 * CHAR_SCALE, "low": false, "strong": false,
				"damage": 85, "impact_sfx": "kick_impact"}
		# aire+W (jump_kick) = DOBLE patada aérea (clip 145f): 1ª ~f34 (xmax 1118, pie abajo-adelante),
		# 2ª ~f68 (xmax 1299, largo). Nombres distintos = 2 impactos. hit_frames 34 y 68.
		if sprite.animation == "jump_kick":
			var jkfr := int(sprite.frame)
			if jkfr < 50:
				return {"name": "jump_kick", "frame": jkfr, "hit_frame": 34,
					"reach": 520.0 * CHAR_SCALE, "low": false, "strong": false,
					"damage": 55, "impact_sfx": "kick_impact"}
			return {"name": "jump_kick_2", "frame": jkfr, "hit_frame": 68,
				"reach": 600.0 * CHAR_SCALE, "low": false, "strong": false,
				"damage": 60, "impact_sfx": "kick_impact"}
		# aire+R (air_jab) = DOBLE jab aéreo (clip 145f): 1º ~f34 (xmax 1186, alto) y 2º ~f70 (xmax 1229).
		# Nombres distintos = 2 impactos. Ligero (jab). hit_frames 34 y 70.
		if sprite.animation == "air_jab":
			var ajfr := int(sprite.frame)
			if ajfr < 52:
				return {"name": "air_jab", "frame": ajfr, "hit_frame": 34,
					"reach": 500.0 * CHAR_SCALE, "low": false, "strong": false,
					"damage": 40, "impact_sfx": "kick_impact"}
			return {"name": "air_jab_2", "frame": ajfr, "hit_frame": 70,
				"reach": 540.0 * CHAR_SCALE, "low": false, "strong": false,
				"damage": 45, "impact_sfx": "kick_impact"}
		# aire+E (air_spin_kick) = DOBLE patada aérea giratoria (clip 145f): 1ª ~f48 (xmax 1299, larga) y
		# 2ª ~f88 (xmax 1147). Ventanas ACOTADas = 2 impactos limpios (sin re-hit del árbitro viajero).
		if sprite.animation == "air_spin_kick":
			var asfr := int(sprite.frame)
			if asfr >= 42 and asfr <= 60:
				return {"name": "air_spin_kick", "frame": asfr, "hit_frame": 48,
					"reach": 620.0 * CHAR_SCALE, "low": false, "strong": false,
					"damage": 60, "impact_sfx": "kick_impact"}
			if asfr >= 80 and asfr <= 120:
				return {"name": "air_spin_kick_2", "frame": asfr, "hit_frame": 88,
					"reach": 560.0 * CHAR_SCALE, "low": false, "strong": false,
					"damage": 60, "impact_sfx": "kick_impact"}
		# cualquier OTRO golpe que ROUM aún no tiene clip (crouch_kick, aéreos...) NO pega:
		# muestra su pose de placeholder pero NO hereda el golpe FANTASMA de DAM.
		if sprite.animation in ATTACKS:
			return {}
	# durante el EMBER DASH el golpe es el especial (reusa el corte como pose)
	# OJO: el casteo del BERSERK también usa special_t como candado — NO es un golpe
	if special_t > 0.0 and sprite.is_playing() and String(sprite.animation) != "berserk_cast":
		return {"name": "ember_dash", "frame": int(sprite.frame), "hit_frame": 1,
			"reach": 520.0 * CHAR_SCALE, "low": false, "strong": true,
			"damage": 130, "wall_launch": true, "impact_sfx": "kick_impact"}
	# PEONZA de Fe (E en el suelo): golpea DOS veces y NO levanta (el rival se queda en el
	# sitio). Dos ventanas con NOMBRES distintos para que el árbitro registre 2 impactos;
	# strong=false para no lanzar por los aires. SOLO Fe (DAM conserva su patada que levanta).
	if sprite.animation == "spin_kick" and sprite.is_playing() \
			and sprite.sprite_frames.has_animation("water_cast"):
		var fr := int(sprite.frame)
		# ventanas para la PEONZA NUEVA de video (85 frames, molinillo en 16-60):
		# hits en plena vuelta (20 y 40). La vieja del sheet usaba 4 frames (hits 2 y 5).
		var sp_v2 := sprite.sprite_frames.get_frame_count("spin_kick") > 12
		if fr < (35 if sp_v2 else 4):
			return {"name": "spin_kick", "frame": fr, "hit_frame": (20 if sp_v2 else 2),
				"reach": 520.0 * CHAR_SCALE, "low": false, "strong": false,
				"damage": 60, "impact_sfx": "kick_impact"}
		return {"name": "spin_kick_2", "frame": fr, "hit_frame": (40 if sp_v2 else 5),
			"reach": 520.0 * CHAR_SCALE, "low": false, "strong": false,
			"damage": 60, "impact_sfx": "kick_impact"}
	# ↓R de DAM v3 (clip crouch-jab, 60 frames): DOS golpes — ESTOCADA baja (hit en ~21)
	# y GIRO DE HOJA que la atornilla (hit en ~40). Nombres distintos = cuentan 2.
	if not fx_blue and not fx_floral and sprite.animation == "crouch_jab" and sprite.is_playing() \
			and sprite.sprite_frames.get_frame_count("crouch_jab") > 8:
		var cjfr := int(sprite.frame)
		if fx_dark:
			# ZETMA: ↓R = UN poke bajo RÁPIDO (clip 28f recortado): conecta ~f10, el más ligero.
			return {"name": "crouch_jab", "frame": cjfr, "hit_frame": 10,
				"reach": 500.0 * CHAR_SCALE, "low": true, "damage": 40}
		if cjfr < 32:
			return {"name": "crouch_jab", "frame": cjfr, "hit_frame": 21,
				"reach": 640.0 * CHAR_SCALE, "low": true, "damage": 50}
		return {"name": "crouch_jab_2", "frame": cjfr, "hit_frame": 40,
			"reach": 640.0 * CHAR_SCALE, "low": true, "damage": 40}
	# R de DAM = PATADAS POGO (clip hit-r, 43 frames): las TRES patadas — cada una LEVANTA
	# RECTO al rival (vertical, sin empuje lateral) y la siguiente lo recoge al caer
	# (pedido). 3 ventanas con nombres distintos (cuentan 3 hits en el combo).
	if not fx_blue and not fx_floral and sprite.animation == "weak_punch" and sprite.is_playing() \
			and sprite.sprite_frames.get_frame_count("weak_punch") > 8:
		var wfr := int(sprite.frame)
		if fx_dark:
			# ZETMA: weak_punch = DOS golpes (estocada de daga + patada alta). Clip recortado a su
			# ventana activa (54f): la estocada extiende ~f6, la patada alta ~f39. Rápido (assassin).
			# Dos ventanas con NOMBRES distintos para que el árbitro cuente ambos impactos.
			if wfr < 17:
				return {"name": "weak_punch", "frame": wfr, "hit_frame": 6, "reach": 640.0 * CHAR_SCALE,
					"low": false, "damage": 40, "impact_sfx": "kick_impact"}
			return {"name": "weak_punch_2", "frame": wfr, "hit_frame": 39, "reach": 660.0 * CHAR_SCALE,
				"low": false, "damage": 50, "impact_sfx": "kick_impact"}
		if wfr < 10:
			return {"name": "weak_punch", "frame": wfr, "hit_frame": 5, "reach": 520.0 * CHAR_SCALE,
				"low": false, "strong": true, "vertical": true, "launch_mult": 0.75,
				"damage": 40, "impact_sfx": "kick_impact"}
		if wfr < 22:
			return {"name": "weak_punch_2", "frame": wfr, "hit_frame": 17, "reach": 520.0 * CHAR_SCALE,
				"low": false, "strong": true, "vertical": true, "launch_mult": 0.75,
				"damage": 40, "impact_sfx": "kick_impact"}
		return {"name": "weak_punch_3", "frame": wfr, "hit_frame": 29, "reach": 520.0 * CHAR_SCALE,
			"low": false, "strong": true, "vertical": true, "launch_mult": 0.75,
			"damage": 40, "impact_sfx": "kick_impact"}
	# TORBELLINO de DAM (E, clip hit-e, 71 frames): golpea DOS veces (una por vuelta) y NO
	# levanta — dos ventanas con nombres distintos; spin_kick_2 YA esta en ATK_LEVEL (antes
	# faltaba y el 2o hit reseteaba el contador: "quitaba doble contando uno").
	if not fx_blue and not fx_floral and sprite.animation == "spin_kick" and sprite.is_playing() \
			and sprite.sprite_frames.get_frame_count("spin_kick") > 12:
		var tfr := int(sprite.frame)
		if fx_dark:
			# ZETMA: E = BRAZO MECÁNICO que telescopea LARGO al frente (NO el torbellino de DAM). UN
			# golpe de LARGO ALCANCE: el puño llega a FULL extensión ~f11 y el hit cae AHÍ (antes
			# pegaba en f20, ya retraído, desde cerca). reach mayor -> conecta desde más lejos.
			return {"name": "spin_kick", "frame": tfr, "hit_frame": 11, "reach": 680.0 * CHAR_SCALE,
				"low": false, "strong": false, "damage": 90, "impact_sfx": "kick_impact"}
		if tfr < 38:
			return {"name": "spin_kick", "frame": tfr, "hit_frame": 20,
				"reach": 540.0 * CHAR_SCALE, "low": false, "strong": false,
				"damage": 60, "impact_sfx": "kick_impact"}
		return {"name": "spin_kick_2", "frame": tfr, "hit_frame": 44,
			"reach": 540.0 * CHAR_SCALE, "low": false, "strong": false,
			"damage": 60, "impact_sfx": "kick_impact"}
	# ZETMA salto+E = DOBLE PATADA al frente (no un giro pese al nombre). Clip fluido (77f):
	# patada 1 extiende ~f11, patada 2 ~f57. Dos ventanas con NOMBRES distintos = cuentan dos.
	if fx_dark and sprite.animation == "air_spin_kick" and sprite.is_playing():
		var asfr := int(sprite.frame)
		if asfr < 35:
			return {"name": "air_spin_kick", "frame": asfr, "hit_frame": 11, "reach": 520.0 * CHAR_SCALE,
				"low": false, "strong": false, "damage": 50, "impact_sfx": "kick_impact"}
		return {"name": "air_spin_kick_2", "frame": asfr, "hit_frame": 57, "reach": 540.0 * CHAR_SCALE,
			"low": false, "strong": true, "damage": 60, "impact_sfx": "kick_impact"}
	# PATADA AÉREA DOBLE de Fe (salto+R): 2 golpes ligeros que NO levantan. Dos ventanas con
	# NOMBRES distintos; hit_frame al ARRANQUE de cada ventana (0 y 2) para que ambos peguen
	# aunque la animación sea rápida (no depende de acertar un frame intermedio exacto).
	if sprite.animation == "air_jab" and sprite.is_playing():
		var afr := int(sprite.frame)
		if fx_dark:
			# ZETMA salto+R = DOBLE jab de cuchillo: jab BAJO (~f18) + jab al FRENTE (~f78). Clip
			# apurado (85f, sin la pausa del re-cock). Dos ventanas con nombres distintos = 2 hits.
			if afr < 35:
				return {"name": "air_jab", "frame": afr, "hit_frame": 18, "reach": 500.0 * CHAR_SCALE,
					"low": false, "strong": false, "damage": 40, "impact_sfx": "kick_impact"}
			return {"name": "air_jab_2", "frame": afr, "hit_frame": 60, "reach": 540.0 * CHAR_SCALE,
				"low": false, "strong": false, "damage": 45, "impact_sfx": "kick_impact"}
		if fx_blue:
			# Favi: PATADA AÉREA DOBLE v2 (42 frames armados del clip: patada→recoge→patada).
			# hit_frame en cada EXTENSIÓN real (índices 8 y 28); ventana 2 arranca en el 24
			# (donde la 2ª patada dispara). Alcance de la 2ª mayor: el 1er golpe empuja.
			if afr < 24:
				return {"name": "air_jab", "frame": afr, "hit_frame": 8,
					"reach": 460.0 * CHAR_SCALE, "low": false, "strong": false,
					"damage": 35, "impact_sfx": "kick_impact"}
			return {"name": "air_jab_2", "frame": afr, "hit_frame": 28,
				"reach": 470.0 * CHAR_SCALE, "low": false, "strong": false,
				"damage": 35, "impact_sfx": "kick_impact"}
		# DAM: salto+R = MORTAL de DOS golpes — el filo pasa abajo dos veces en el giro
		# (ventanas con NOMBRES distintos para que el árbitro cuente ambos impactos)
		if afr < 24:
			return {"name": "air_jab", "frame": afr, "hit_frame": 12,
				"reach": 470.0 * CHAR_SCALE, "low": false, "strong": false,
				"damage": 35, "impact_sfx": "kick_impact"}
		return {"name": "air_jab_2", "frame": afr, "hit_frame": 26,
			"reach": 500.0 * CHAR_SCALE, "low": false, "strong": false,
			"damage": 35, "impact_sfx": "kick_impact"}
	# AYE: sus animaciones son MÁS LARGAS que las de DAM (el báculo se extiende a MITAD de la
	# animación, no en el frame 1). Con el hit_frame global (tuneado para el jab corto de DAM) el
	# golpe registra en el WINDUP y el hitstop congela a Aye en la pose inicial -> "el golpe no
	# sale completo / se queda a mitad". Reubica el hit_frame al frame donde el báculo está
	# EXTENDIDO para que impacto+hitstop caigan en la extensión y la animación se lea completa.
	# override de hit_frame Y reach para Aye: weak_punch es una ESTOCADA LARGA con báculo -> el
	# hit cae en la extensión (no en el windup) y ALCANZA a media distancia (el báculo llega lejos,
	# el reach chico de DAM la obligaba a estar pegada). reach en unidades ya×CHAR_SCALE del ATTACKS.
	const AYE_ATK_OVERRIDE := {
		"weak_punch": {"hit_frame": 15, "reach": 520.0},   # ~largo del báculo (no lejísimo, no pegado)
		"crouch_jab": {"hit_frame": 5, "reach": 500.0},    # poke bajo: hit en la EXTENSIÓN (#6), no en la guardia (#1)
		# ↓E de Aye = CASTEO ICE-SPIKES: NO derriba (trip), CONGELA. hit en el RELEASE (#6, púas erupcionan).
		# reach amplio para que ALCANCE a donde aparecen las púas (offset 240 + ancho del cluster).
		"sweep": {"hit_frame": 5, "reach": 700.0, "trip": false, "freeze": true},
		# W de Aye = PILAR ice-grow: tambien CONGELA (pedido) — el remolino atrapa al rival
		# en la estatua de hielo (si esta en el aire queda suspendido el freeze y luego cae).
		# reach = el SOBRE VISUAL COMPLETO del pilar: tope de casteo 1250 + medio remolino
		# 170 + pierna delantera del rival 250 => contacto visual hasta ~1670. El arbitro
		# multiplica reach por body_k del ATACANTE (Aye 0.65): 2600*0.65 = 1690 reales.
		# REGLA DE ORO: si el remolino TOCA cualquier parte del rival -> congela; si brota
		# corto y no lo toca -> no congela. (Antes: tocaba la pierna sin congelar.)
		"kick": {"freeze": true, "reach": 2600.0},
		# ↓W de Aye = LUNA DE HIELO (lanzador): lanza al rival un POCO más ALTO para encadenar el
		# combo aéreo (salto+E). Tuneable (1.0 = normal; sube el número = más alto).
		# reach = el SOBRE VISUAL de la LUNA, no el del báculo (la luna del piso pega SOLA,
		# Aye no tiene que estar pegada): nodo a +190 + creciente ~600 + pierna del rival
		# ~250 => contacto real ~850. El árbitro multiplica por body_k de Aye (0.65):
		# 1300*0.65 = 845 reales. (Igual que la regla de oro del pilar.)
		"crouch_kick": {"launch_mult": 1.15, "reach": 1300.0},
	}
	if fx_floral and sprite.animation in ATTACKS and sprite.is_playing():
		var aa: Dictionary = ATTACKS[sprite.animation].duplicate()
		aa["name"] = sprite.animation
		aa["frame"] = sprite.frame
		if AYE_ATK_OVERRIDE.has(sprite.animation):
			for k in AYE_ATK_OVERRIDE[sprite.animation]:
				aa[k] = AYE_ATK_OVERRIDE[sprite.animation][k]
		# ORBES: los 3 golpes de PIE (punch🟡/kick🩷/spin_kick🔵) NO pegan melee — lanzan un ORBE
		# a su hit_frame; el orbe hace el daño. (crouch/aire siguen normales.)
		if _orb_color_for(String(sprite.animation)) >= 0:
			# TODOS los golpes de color (de pie / agachado / aire) lanzan su ORBE y NO pegan melee.
			if not _orb_fired and int(sprite.frame) >= int(aa["hit_frame"]):
				var mb := get_parent()
				if mb != null and mb.has_method("_orb_launch"):
					mb._orb_launch(self, _orb_color_for(String(sprite.animation)), _orb_pending_mode)
				_orb_fired = true
			return {}
		if sprite.animation in ["weak_punch", "crouch_jab", "air_jab"]:
			return {}   # gesto de RECALL: no pega melee; el recall lo dispara el input de R (weak_punch)
		return aa
	# MOLINETE de DAM (salto+W): hasta 3 GOLPES si agarra al rival en el aire — una pasada
	# del círculo por golpe (ventanas con nombres distintos, como la peonza de Fe)
	if not fx_blue and not fx_floral and sprite.animation == "jump_kick" and sprite.is_playing():
		var jkfr := int(sprite.frame)
		if fx_dark:
			# ZETMA: salto+W = UNA patada AÉREA voladora (no el molinete de 3 golpes de DAM). Clip
			# recortado (90f): la pierna se extiende ~f15.
			return {"name": "jump_kick", "frame": jkfr, "hit_frame": 15, "reach": 500.0 * CHAR_SCALE,
				"low": false, "strong": true, "damage": 90, "impact_sfx": "kick_impact"}
		if jkfr < 24:
			return {"name": "jump_kick", "frame": jkfr, "hit_frame": 8,
				"reach": 500.0 * CHAR_SCALE, "low": false, "strong": true,
				"damage": 55, "impact_sfx": "kick_impact"}
		elif jkfr < 44:
			return {"name": "jump_kick_h2", "frame": jkfr, "hit_frame": 26,
				"reach": 500.0 * CHAR_SCALE, "low": false, "strong": true,
				"damage": 55, "impact_sfx": "kick_impact"}
		return {"name": "jump_kick_h3", "frame": jkfr, "hit_frame": 46,
			"reach": 500.0 * CHAR_SCALE, "low": false, "strong": true,
			"damage": 55, "impact_sfx": "kick_impact"}
	# DAM: sus anims NUEVAS de video son MÁS LARGAS que las viejas de 3-4 frames del .tres.
	# El hit_frame global registraba el golpe ANTES del swing (jump_kick: con la espada aún
	# ARRIBA -> el hitstop lo congelaba ahí y "el golpe parecía hacia arriba"). Reubica el
	# hit al momento del TAJO real.
	const DAM_ATK_OVERRIDE := {
		"jump_punch": {"hit_frame": 3},   # la estocada se extiende en el frame 3 (anim de 8)
		"air_spin_kick": {"hit_frame": 12},   # la patada voladora EXTIENDE en el frame ~12 (anim de 53)
		"punch": {"hit_frame": 15},   # v2 (48 frames): el TAJO smear barre en 12-16, extension plena en 16
		"kick": {"hit_frame": 32},    # W v3 MACHETAZO (51 frames): alza 0-16 + puente 17-24 + descarga ~32-36
		"crouch_punch": {"hit_frame": 22},   # ↓Q v3 (62 frames): carga 0-18, TAJO 19-24, extension 25+
		"crouch_kick": {"hit_frame": 30},    # ↓W v2 GANCHO (74 frames): carga 0-24, el corte SUBE en ~30-36
		"sweep": {"hit_frame": 32, "reach": 640.0},   # ↓E v2 BARRIDO (62 frames): cruza a ras en ~32-38; reach = punta real de la hoja
		# (crouch_jab tiene bloque propio de DOS ventanas arriba: estocada + giro de hoja)
		# (weak_punch y spin_kick tienen bloques propios multi-ventana arriba)
	}
	# ZETMA (fx_dark): cae en la rama de DAM (no-blue, no-floral) pero sus clips de video van
	# recortados a OTRA ventana -> hit_frame propio. Hereda los overrides de DAM y corrige
	# crouch_punch/sweep (clips 39f/38f: el golpe conecta ~f15, no en el 22/32 de DAM).
	if fx_dark and sprite.animation in ATTACKS and sprite.is_playing():
		var za: Dictionary = ATTACKS[sprite.animation].duplicate()
		za["name"] = sprite.animation
		za["frame"] = sprite.frame
		if DAM_ATK_OVERRIDE.has(sprite.animation):
			for k in DAM_ATK_OVERRIDE[sprite.animation]:
				za[k] = DAM_ATK_OVERRIDE[sprite.animation][k]
		if sprite.animation == "crouch_punch":
			za["hit_frame"] = 15   # daga baja arrodillado: conecta ~f15
		elif sprite.animation == "sweep":
			za["hit_frame"] = 15   # barrida baja de daga: cruza ~f15
		elif sprite.animation == "kick":
			za["hit_frame"] = 23   # patada ALTA (clip 59f recortado): golpea ~f23
		elif sprite.animation == "crouch_kick":
			za["hit_frame"] = 13   # patada/daga ascendente arrodillado (clip 28f): golpea ~f13
		elif sprite.animation == "jump_punch":
			za["hit_frame"] = 30   # estocada AÉREA de daga (clip 130f): extiende ~f30
		return za
	if not fx_floral and not fx_blue and sprite.animation in ATTACKS and sprite.is_playing():
		var da: Dictionary = ATTACKS[sprite.animation].duplicate()
		da["name"] = sprite.animation
		da["frame"] = sprite.frame
		if DAM_ATK_OVERRIDE.has(sprite.animation):
			for k in DAM_ATK_OVERRIDE[sprite.animation]:
				da[k] = DAM_ATK_OVERRIDE[sprite.animation][k]
		return da
	# ↓R de Fe v2 = CAST del tigre (señala al frente): la anim NO golpea — el daño lo
	# pondrá el TIGRE de energía blanca cuando exista su clip (proyectil que arrastra)
	if fx_blue and sprite.animation == "crouch_jab" \
			and sprite.sprite_frames.get_frame_count("crouch_jab") > 8:
		return {}
	# W de SUELO de Fe (clip kick.mp4): DOBLE PATADA con la MISMA pierna — a la CINTURA y
	# luego ALTA a la CARA. 2 ventanas con nombres distintos (el árbitro cuenta ambas);
	# la ALTA es LANZADOR (si te da, te levanta). Guard por frame_count: solo la anim nueva.
	if fx_blue and sprite.animation == "kick" and sprite.is_playing() \
			and sprite.sprite_frames.get_frame_count("kick") > 12:
		var kfr := int(sprite.frame)
		if kfr < 29:
			return {"name": "kick", "frame": kfr, "hit_frame": 5,
				"reach": 500.0 * CHAR_SCALE, "low": false, "strong": false,
				"damage": 55, "impact_sfx": "kick_impact"}
		return {"name": "kick_h2", "frame": kfr, "hit_frame": 41,
			"reach": 520.0 * CHAR_SCALE, "low": false, "strong": true,
			"damage": 70, "impact_sfx": "kick_impact"}
	# FE: overrides de sus anims NUEVAS de video (las del sheet eran de 3-10 frames; el
	# hit_frame global caía en la CARGA y el hitstop congelaba el golpe sin extender).
	const FAVI_ATK_OVERRIDE := {
		# salto+E voladora: EXTIENDE en el frame ~14; recortado más (pegaba desde lejos, pedido)
		"air_spin_kick": {"hit_frame": 14, "reach": 430.0 * CHAR_SCALE},
		# Q patada alta girada: el BARRIDO adelante de la pierna cae en los frames 11-15
		# (v2 arranca 2 frames antes: entrada plantándose f56-57 del clip)
		"punch": {"hit_frame": 12},
		# W doble patada alta: usaba el reach base 600 de DAM (pierna larga) -> con su cuerpo chico
		# pegaba de LEJOS. Recortado a la punta REAL de su patada (pedido).
		"kick": {"reach": 490.0 * CHAR_SCALE},
		# salto+W clavado v2 (22 frames): la aguja APUÑALA en los frames 6-12. Reach base 600 era
		# muy largo para su cuerpo -> recortado.
		"jump_kick": {"hit_frame": 7, "reach": 470.0 * CHAR_SCALE},
		# R jab de aguja v2 (35 frames): la estocada EXTIENDE en el frame ~22 (la punta de
		# la aguja llega lejos: reach un pelín mayor que el jab de DAM)
		"weak_punch": {"hit_frame": 22, "reach": 560.0 * CHAR_SCALE},
		# ↓Q doble estocada v2 (40 frames): brazos disparan JUNTOS, extensión en el ~13.
		# Las dos agujas al frente llegan LEJOS (medido 425px de arte): reach acorde.
		# NOTA: el arte de la familia agachada se trasladó a los pies PLANTADOS de la pose
		# (dx canvas: punch -85, kick -89, sweep -98) => reach reducido dx/body_k(0.71)
		# para que el golpe siga conectando EXACTO en la punta visible.
		"crouch_punch": {"hit_frame": 13, "reach": 660.0 * CHAR_SCALE},
		# ↓W lanzador v2 (48 frames): la aguja SUBE clavando en los frames 8-16 (pico 16)
		"crouch_kick": {"hit_frame": 13, "reach": 515.0 * CHAR_SCALE},
		# ↓E barrida v2 (87 frames): la pierna BARRE el piso en los frames 10-38
		"sweep": {"hit_frame": 20, "reach": 562.0 * CHAR_SCALE},
	}
	if fx_blue and sprite.animation in FAVI_ATK_OVERRIDE and sprite.is_playing():
		var fa: Dictionary = ATTACKS[sprite.animation].duplicate()
		fa["name"] = sprite.animation
		fa["frame"] = sprite.frame
		for k in FAVI_ATK_OVERRIDE[sprite.animation]:
			fa[k] = FAVI_ATK_OVERRIDE[sprite.animation][k]
		return fa
	if sprite.animation in ATTACKS and sprite.is_playing():
		var a: Dictionary = ATTACKS[sprite.animation].duplicate()
		a["name"] = sprite.animation
		a["frame"] = sprite.frame
		return a
	return {}

func do_ko() -> void:
	koed = true
	_ko_dust_done = false
	_play_ko_cry()   # AYE: "NOOOOOO!" al perder (una vez)
	crouching = false
	water_bg = false
	fe_dash_t = 0.0
	fe_dash_active = false
	# KO EN EL AIRE: no teletransporta ni activa la anim de KO todavía; deja que CAIGA
	# por su arco y quede TENDIDO al tocar el piso (lo maneja el aterrizaje).
	if airborne or hit_flying:
		return
	# KO en el suelo: cae de espaldas con la animación completa (boca ARRIBA)
	ko_facedown = false
	hit_flying = false
	airborne = false
	vel_x = 0.0
	vel_y = 0.0
	position.y = floor_y
	sprite.play("ko")

# MUERTE (llamado por _end_round). NO corta el vuelo: si el golpe mortal lo lanzó,
# COMPLETA su arco por los aires; al empezar a bajar se pone BOCA ABAJO (ko_air) y al
# aterrizar queda tendido boca abajo (sin levantarse). Si muere PARADO en el suelo,
# cae de espaldas (boca arriba) con la animación normal de "ko".
func die_ko() -> void:
	koed = true
	_ko_dust_done = false
	_play_ko_cry()   # AYE: "NOOOOOO!" al perder (una vez)
	crouching = false
	water_bg = false
	fe_dash_t = 0.0
	fe_dash_active = false
	ultra_hover = false   # libera el hover del ultra para que CAIGA de verdad (no flote)
	if airborne or hit_flying:
		# muerte EN EL AIRE: deja que complete el vuelo y caiga. hard_fall = baja decidido.
		# AYE: nunca boca abajo — completa el vuelo (hit_fly) y aterriza con su hit_down
		ko_facedown = not fx_floral
		hit_flying = true
		hard_fall = true
		wall_bounced = true   # sin rebote de pared en la muerte
		vel_x = 0.0
		# NO se toca vel_y: que complete el vuelo por los aires
	else:
		# muerte PARADO en el suelo: cae de espaldas (boca arriba), animación completa
		ko_facedown = false
		hit_flying = false
		airborne = false
		vel_x = 0.0
		vel_y = 0.0
		position.y = floor_y
		sprite.play("ko")

# fuerza el estado TENDIDO en el piso (red de seguridad del cinematográfico del KO
# aéreo: garantiza que quede boca abajo en el suelo si la caída no terminó a tiempo).
func force_grounded_ko() -> void:
	koed = true
	_play_ko_cry()   # AYE: "NOOOOOO!" al perder (una vez)
	airborne = false
	hit_flying = false
	hard_fall = false
	crouching = false
	vel_x = 0.0
	vel_y = 0.0
	position.y = floor_y
	if frozen_t > 0.0:
		return   # KO CONGELADO: se queda en la ESTATUA (sin offset de tendido — evitaba
				 # el "modelo hundido"); al descongelarse cae con "ko" (ver release del freeze)
	if (fx_floral or fx_dark) and String(sprite.animation) != "ko" and sprite.sprite_frames.has_animation("hit_down"):
		# AYE: SOLO para el KO VOLADOR (venía en hit_fly/hit_down). Si está en su anim "ko"
		# (KO de golpe normal en el suelo) NO tocarla: cae al else y conserva su ko de siempre.
		sprite.play("hit_down")
		sprite.frame = maxi(0, sprite.sprite_frames.get_frame_count("hit_down") - 1)
	elif ko_facedown and sprite.sprite_frames.has_animation("ko_air"):
		var _kaf := sprite.sprite_frames.get_frame_count("ko_air")
		if _kaf > 100:
			# v2: choque/tendido YA anclados a la línea del piso — SIN offset (el -95 del
			# arte viejo lo dejaba FLOTANDO); si el estrellón corre o ya quedó tendido, no tocar
			sprite.position.y = 0.0
			if String(sprite.animation) != "ko_air" or sprite.frame < 73:
				sprite.play("ko_air")
				sprite.frame = 73
		else:
			sprite.play("ko_air")   # arte viejo: tendido directo + su offset calibrado
			sprite.frame = maxi(0, _kaf - 1)
			sprite.position.y = ko_lie_drop_down
	else:
		var _koc := sprite.sprite_frames.get_frame_count("ko")
		if String(sprite.animation) == "ko" and _koc > 100 and sprite.is_playing():
			return   # v2: el desplome ya corre y termina tendido SOLO (frames anclados al piso)
		sprite.play("ko")
		sprite.frame = maxi(0, _koc - 1)
		# el offset de tendido era del arte VIEJO (5 frames, tendido alto en el canvas);
		# el v2 ya trae el tendido clavado en la línea del piso — sin offset
		sprite.position.y = (0.0 if _koc > 100 else ko_lie_drop_up)

func do_breaker() -> bool:
	if not breaker_ready or koed or orb_trap_t > 0.0:   # atrapado en la esfera: NO puede romper
		return false
	breaker_ready = false
	hit_flying = false
	crouching = false
	punch_followup = false
	buffer_t = 0.0
	vel_x = 0.0
	breaker_inv_t = 0.7
	# DAM rompe con su mortal: brinco + patada giratoria envuelta en sombras
	if fx_floral and sprite.sprite_frames.has_animation("jump_kick"):
		# AYE rompe con su golpe aéreo (jump_kick overhead) + sombras MORADAS (fx_floral) + borde morado
		if not airborne:
			airborne = true
			vel_y = -JUMP_SPEED * 0.55
		else:
			vel_y = minf(vel_y, -JUMP_SPEED * 0.45)
		sprite.play("jump_kick")
		breaker_fx_t = 2.2
		_cast_border_on(0.9)
	elif sprite.sprite_frames.has_animation("air_spin_kick"):
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

# PARRY (↓+E): entra al CONTRAATAQUE. Acá solo pone al peleador en pose de counter e
# invulnerable; la secuencia (desvío + 3 golpes + "COUNTER" + pantalla oscura + borde)
# la maneja main.on_parry.
func do_parry() -> bool:
	if koed or orb_trap_t > 0.0:   # atrapado en la esfera: NO puede hacer parry
		return false
	hit_flying = false
	airborne = false
	crouching = false
	punch_followup = false
	buffer_t = 0.0
	vel_x = 0.0
	vel_y = 0.0
	position.y = floor_y
	parry_t = PARRY_WINDOW                                  # ventana ~0.5s: si te pegan acá → COUNTER
	breaker_fx_t = maxf(breaker_fx_t, PARRY_WINDOW + 0.15)  # sombras MORADAS (Aye) / AZUL (Fe) / ROJO (DAM)
	if fx_floral:
		_cast_border_on(PARRY_WINDOW + 0.15)   # BORDE outline MORADO de Aye durante el parry
	sprite.speed_scale = 1.0
	if sprite.sprite_frames.has_animation("parry") and sprite.sprite_frames.get_frame_count("parry") > 8:
		sprite.play("parry")        # v2: SNAP a la pose de desvío + HOLD (clip dedicado)
	elif sprite.sprite_frames.has_animation("counter"):
		sprite.play("counter")
		sprite.frame = 0            # POSE de desvío = PRIMER frame del counter, congelado
		sprite.stop()
	else:
		sprite.play("block")
	_play_sfx_key("block")
	return true

func revive() -> void:
	koed = false
	ko_facedown = false
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
	sprite.position.y = 0.0   # deshace el ajuste del KO tendido
	sprite.play("pose")

func celebrate() -> void:
	crouching = false
	# el GANADOR encara al rival caído y NO se cambia de lado (facing estable durante la victoria)
	var m := get_parent()
	if m != null and m.get("player") != null and m.get("dummy") != null:
		var opp: Node2D = m.dummy if self == m.player else m.player
		if is_instance_valid(opp):
			set_facing(1 if opp.position.x >= position.x else -1)
	sprite.play("victory")
	if m and m.has_method("_play_victory_line"):   # el ganador dice su frase (boca sincronizada)
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
		# chispa PEGADA al cuerpo (pedido): 95 en vez de 150 — revienta sobre el pecho/torso
		fx_sprite.position = Vector2(float(facing) * 95.0 * float(lado), alto)
		fx_sprite.flip_h = facing < 0
		fx_sprite.rotation = 0.0 if block else randf_range(-0.25, 0.25)
		fx_sprite.flip_v = false if block else randf() < 0.5
		var esc := (1.2 if block else 1.15) * escala * randf_range(0.9, 1.12)   # golpe MAS GRANDE aun (0.75 -> 0.95 -> 1.15, pedido)
		fx_sprite.scale = Vector2(esc, esc)
		fx_sprite.visible = true
		fx_sprite.play(anim)

# EMBER DASH (↓→+Q): embestida ardiente que lanza al rival muy alto
func _start_special() -> void:
	special_t = SPECIAL_TIME
	down_recent_t = 0.0
	punch_followup = false
	crouching = false
	_spawn_dash_smoke(0.75, 60.0)   # ráfaga de humo JUSTO al pie al arrancar el dash
	sprite.play("punch")

# TELEPORT de Aye (↓→Q, reemplaza el dash de fuego): se DESVANECE en glitch morado y reaparece
# ~1.5 cuerpos adelante. Deja una after-imagen morada donde estaba + sombras + borde morado, y es
# invulnerable un instante (esquiva). Cuando exista imagen-action/aye/teleport/ usa esa animación.
# ¿hay mana para este hechizo? Los no-magos siempre pueden. Si alcanza, lo COBRA y devuelve true;
# si no, hace el feedback (parpadeo del anillo) y devuelve false (el hechizo no debe salir).
func _spell_afford(cost: float) -> bool:
	var mb := get_parent()
	if mb == null or not mb.has_method("_mana_ok"):
		return true
	if mb._mana_ok(self, cost):
		mb._mana_spend(self, cost)
		return true
	if mb.has_method("_mana_denied"):
		mb._mana_denied(self)
	_deny_flash()   # aviso universal: GRIS = no pudo castear por falta de recurso
	return false

# aviso universal "NO PUDO CASTEAR" (sin barra / sin maná): el personaje se tiñe GRIS
# medio segundo. Va por TIMER (deny_t) porque la cadena de tintes de _physics_process
# resetea modulate a blanco CADA frame — un set directo moría en 1/60s (invisible).
var deny_t := 0.0
# ELECTROCUTADO por el THUNDER de Fe: SILUETA BLANCA intermitente DETRÁS de la figura
# (la figura en sí NO cambia). Ghost con shader de silueta que copia el frame actual.
var electro_t := 0.0
var electro_ghost: AnimatedSprite2D = null

func _electro_ghost_update() -> void:
	if electro_ghost == null:
		electro_ghost = AnimatedSprite2D.new()
		var sh := Shader.new()
		# silueta plana: pinta TODO el alpha del frame de un color sólido
		sh.code = "shader_type canvas_item;\nuniform vec4 fill_color : source_color = vec4(1.0,1.0,1.0,0.6);\nvoid fragment(){ vec4 t = texture(TEXTURE, UV); COLOR = vec4(fill_color.rgb, t.a * fill_color.a); }"
		var mat := ShaderMaterial.new()
		mat.shader = sh
		mat.set_shader_parameter("fill_color", Color(1.0, 1.0, 1.0, 0.62))
		electro_ghost.material = mat
		add_child(electro_ghost)
		move_child(electro_ghost, 0)   # mismo z que el sprite pero ANTES en el árbol => detrás
	# espeja el frame actual del personaje, un 8% más grande (halo que SOBRESALE) con
	# los pies alineados (compensa el crecimiento hacia abajo)
	var rim := 1.08
	electro_ghost.sprite_frames = sprite.sprite_frames
	electro_ghost.animation = sprite.animation
	electro_ghost.frame = sprite.frame
	electro_ghost.flip_h = sprite.flip_h
	electro_ghost.offset = sprite.offset
	electro_ghost.scale = sprite.scale * rim
	electro_ghost.position = sprite.position + Vector2(0.0, -499.0 * (rim - 1.0) * sprite.scale.y)
	electro_ghost.visible = fmod(electro_t, 0.09) > 0.045   # INTERMITENTE
func _deny_flash() -> void:
	deny_t = 0.5

# AYE canaleo de mana: nombre de la anim (usa mana_charge si existe; si no, 'pose' como placeholder)
func _channel_anim() -> String:
	return "mana_charge" if sprite.sprite_frames.has_animation("mana_charge") else "pose"

func _start_channel() -> void:
	channeling = true
	crouching = false
	walk_dir = 0
	buffer_t = 0.0
	sprite.play(_channel_anim())
	_cast_border_on(0.3)   # aura MORADA de casteo mientras canaliza
	var _scr := "res://imagen-action/aye/sound-effect/spell-charge-mana.mp3"
	if ResourceLoader.exists(_scr):
		sfx_player.stream = load(_scr)
		sfx_player.play()

func _stop_channel() -> void:
	if not channeling:
		return
	channeling = false
	if sfx_player.playing:
		sfx_player.stop()   # corta el sonido de carga
	if sprite.animation == _channel_anim():
		sprite.play("pose")

func _start_teleport() -> void:
	# TELEPORT cuesta MANA (caro): si no alcanza, NO se ejecuta (feedback + no compromete el movimiento)
	if not _spell_afford(0.35):
		return
	var was_air := airborne   # si teleporta EN EL AIRE, se queda en el aire (combo aéreo)
	crouching = false
	walk_dir = 0
	vel_x = 0.0
	vel_y = 0.0
	buffer_t = 0.0
	down_recent_t = 0.0
	if not was_air:
		airborne = false
	# lo orquesta main (sabe dónde está el rival): glitch out + tiembla + sonido + reaparece AL FRENTE
	# del rival con un golpe + borde/sombras moradas que se desvanecen si no combea.
	var mb := get_parent()
	if mb and mb.has_method("_aye_teleport"):
		mb._aye_teleport(self, was_air)
	else:
		position.x = clampf(position.x + float(facing) * 430.0, 150.0, 1770.0)
		if sprite.sprite_frames.has_animation("teleport"):
			sprite.play("teleport")

# BLINK de Aye: glitch corto y reaparece ~CUERPO Y MEDIO hacia ATRÁS (←←, escape) o
# hacia ADELANTE (→→, avance; frena a un cuerpo del rival). Sin golpe. Gasta MANA
# (más barato que el teleport ofensivo).
func _start_blink(adelante := false) -> void:
	if special_t > 0.0 or fe_dash_active or hit_flying or airborne or koed:
		return
	var _ba := String(sprite.animation)
	if _ba in ATTACKS and sprite.is_playing():
		return   # no cancela golpes en curso
	if _ba in ["take_hit", "take_hit_low", "hit_down", "get_up", "counter"] and sprite.is_playing():
		return   # tampoco estados de castigo/recuperación
	if channeling:
		_stop_channel()
	if not _spell_afford(0.20):
		return
	crouching = false
	walk_dir = 0
	vel_x = 0.0
	buffer_t = 0.0
	var mb := get_parent()
	if mb and mb.has_method("_aye_blink"):
		mb._aye_blink(self, adelante)
	else:
		var _bs := 1.0 if adelante else -1.0
		position.x = clampf(position.x + _bs * float(facing) * 340.0, 115.0, 1805.0)
		if sprite.sprite_frames.has_animation("teleport"):
			sprite.play("teleport")

# DASH DE AGUJAS de Fe (←→+Q): embiste hacia adelante SIN levantar al rival; si conecta,
# el árbitro (main._fe_dash_attack) aplica 3 golpes seguidos y lo deja en el sitio (sigue combo).
func _start_fe_dash() -> void:
	fe_dash_t = FE_DASH_TIME
	fe_dash_active = true
	back_recent_t = 0.0
	down_recent_t = 0.0
	punch_followup = false
	crouching = false
	_spawn_dash_smoke(0.75, 60.0)   # JUSTO al pie
	# usa "dash" si ya hay frames reales, si no "punch" de placeholder
	sprite.play("dash" if sprite.sprite_frames.has_animation("dash") else "punch")
	# voz del dash (Fe grita "water way" al arrancar — versión enérgica, como el cast)
	var ruta := "res://imagen-action/favi/Fe-sound-effect/dash-fe-energetica.wav"
	if dash_voz_sfx == null and ResourceLoader.exists(ruta):
		dash_voz_sfx = load(ruta)
	if dash_voz_sfx != null:
		voz_player.stream = dash_voz_sfx
		voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
		voz_player.play()
	var mb := get_parent()
	if mb and mb.has_method("_fe_dash_attack"):
		mb._fe_dash_attack(self)

# humo de dash DIBUJADO (dash-dust, 6 frames): brota en el punto de arranque y se
# queda fijo; la cola se espeja segun la direccion del dash
var dashsmoke_frames: SpriteFrames = null
func _spawn_dash_smoke(escala := 0.75, atras := 0.0, flip_extra := false, lift := 0.5) -> void:
	if dashsmoke_frames == null:
		if not ResourceLoader.exists("res://imagen-action/dust-effect/dash-dust/dash-dust-1.png"):
			return
		dashsmoke_frames = SpriteFrames.new()
		dashsmoke_frames.add_animation("puff")
		# DUST v3 (nubes cartoon del usuario, 10 frames): brote -> nubarrón -> se disipa
		dashsmoke_frames.set_animation_speed("puff", 18.0)   # ~0.56s: es POLVO, flota lento
		dashsmoke_frames.set_animation_loop("puff", false)
		var di := 1
		while ResourceLoader.exists("res://imagen-action/dust-effect/dash-dust/dash-dust-%d.png" % di):
			dashsmoke_frames.add_frame("puff", load("res://imagen-action/dust-effect/dash-dust/dash-dust-%d.png" % di))
			di += 1
	var ds := AnimatedSprite2D.new()
	ds.sprite_frames = dashsmoke_frames
	ds.animation = "puff"
	ds.z_index = 1
	ds.flip_h = (facing > 0) != flip_extra   # v3 INVERTIDO; flip_extra lo espeja (RETROCESO del orb sale al otro lado)
	var tex: Texture2D = dashsmoke_frames.get_frame_texture("puff", 0)
	# el arte v3 (1561px de ancho) es ~2x el viejo (808px): normaliza al mismo tamaño en
	# pantalla, y ×base_scale.y: el polvo PROPORCIONAL al cuerpo (Aye chica, DAM grande)
	var s := escala * absf(scale.x) * 0.52 * base_scale.y
	# desplaza el humo hacia ATRÁS (extremo trasero del personaje) a los pies
	# ((500+offset)×base_scale = línea de pies REAL: Aye ancla con sprite.offset 194)
	var pies := to_global(Vector2(-float(facing) * atras * base_scale.y, (SHADOW_FEET_OFFSET + sprite.offset.y + swing_y_off) * base_scale.y))
	get_parent().add_child(ds)
	ds.global_position = pies - Vector2(0.0, tex.get_height() * s * lift)   # lift bajo = pegado a los pies
	ds.scale = Vector2(s, s)
	ds.modulate = dust_tint   # color del polvo segun el stage
	ds.animation_finished.connect(ds.queue_free)
	ds.play("puff")

# AZOTE contra el SUELO (knockdown de juggle / caída KO): cuña de polvo barrida
# (dust-effect/slam-dust, la cuña gris del usuario) que revienta a los pies del que cae
var slamdust_frames: SpriteFrames = null
func _spawn_slam_dust(dir: int, escala := 0.9) -> void:
	if slamdust_frames == null:
		if not ResourceLoader.exists("res://imagen-action/dust-effect/slam-dust/slam-dust-1.png"):
			return
		slamdust_frames = SpriteFrames.new()
		slamdust_frames.add_animation("puff")
		slamdust_frames.set_animation_speed("puff", 16.0)   # es POLVO: flota lento (~0.44s)
		slamdust_frames.set_animation_loop("puff", false)
		var si := 1
		while ResourceLoader.exists("res://imagen-action/dust-effect/slam-dust/slam-dust-%d.png" % si):
			slamdust_frames.add_frame("puff", load("res://imagen-action/dust-effect/slam-dust/slam-dust-%d.png" % si))
			si += 1
	var ds := AnimatedSprite2D.new()
	ds.sprite_frames = slamdust_frames
	ds.animation = "puff"
	ds.z_index = 1
	ds.flip_h = dir < 0   # el barrido apunta hacia donde venía deslizando el cuerpo
	var tex: Texture2D = slamdust_frames.get_frame_texture("puff", 0)
	# arte 1189px -> ~250px de pantalla: acompaña el cuerpo tendido, no lo tapa;
	# ×base_scale.y = proporcional al cuerpo del que cae
	var s := escala * absf(scale.x) * 0.36 * base_scale.y
	var pies := to_global(Vector2(0.0, (SHADOW_FEET_OFFSET + sprite.offset.y + swing_y_off) * base_scale.y))
	get_parent().add_child(ds)
	ds.global_position = pies - Vector2(0.0, tex.get_height() * s * 0.5)
	ds.scale = Vector2(s, s)
	ds.modulate = dust_tint   # color del polvo segun el stage
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
func _spawn_jump_dust(escala := 0.7, at_x := NAN, tint := Color(1, 1, 1, 1)) -> void:
	# at_x: x GLOBAL opcional (p.ej. el punto de impacto del THUNDER); por defecto los pies
	if jumpdust_frames == null:
		if not ResourceLoader.exists("res://imagen-action/dust-effect/jump-dust/jump-dust-1.png"):
			return
		jumpdust_frames = SpriteFrames.new()
		jumpdust_frames.add_animation("puff")
		# JUMP-DUST v2 (10 frames del usuario): burst simétrico beige. Lento: es polvo.
		jumpdust_frames.set_animation_speed("puff", 18.0)
		jumpdust_frames.set_animation_loop("puff", false)
		var ji := 1
		while ResourceLoader.exists("res://imagen-action/dust-effect/jump-dust/jump-dust-%d.png" % ji):
			jumpdust_frames.add_frame("puff", load("res://imagen-action/dust-effect/jump-dust/jump-dust-%d.png" % ji))
			ji += 1
	var jd := AnimatedSprite2D.new()
	jd.sprite_frames = jumpdust_frames
	jd.animation = "puff"
	jd.z_index = 1   # delante del escenario (que esta en z -1)
	var tex: Texture2D = jumpdust_frames.get_frame_texture("puff", 0)
	# el polvo va al MUNDO en la posicion global de los pies: se queda FIJO en el
	# piso aunque el personaje salte o se mueva (no es hijo del personaje)
	# el arte v2 (1571px) es ~1.7x el viejo (929px): normaliza al mismo tamaño en pantalla,
	# ×base_scale.y para que el burst sea PROPORCIONAL al cuerpo de cada personaje
	var s := escala * absf(scale.x) * 0.59 * base_scale.y
	# (500+offset)×base_scale = línea de pies REAL por personaje (Aye ancla con offset)
	var pies := to_global(Vector2(0.0, (SHADOW_FEET_OFFSET + sprite.offset.y + swing_y_off) * base_scale.y))
	if not is_nan(at_x):
		pies.x = at_x
	get_parent().add_child(jd)
	# la LÍNEA DE SUELO del arte v2 (crescent del frame 1) queda 169px sobre el borde del
	# recorte (los mechones tardíos estiran la caja): se baja para clavarla a los pies
	jd.global_position = pies - Vector2(0.0, tex.get_height() * s * 0.5 - 169.0 * s)
	jd.scale = Vector2(s, s)
	# si el llamador NO pasó un color explícito (blanco), usa el tinte del STAGE
	jd.modulate = dust_tint if tint == Color(1, 1, 1, 1) else tint
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

# INFIERNO v2 (arte "faller" del usuario): el FUEGO se junta y crece en DOMO fundido
# frente a DAM ("build" 22f), explota (los 2 impact-frames de pantalla los pone main
# con _inferno_boom_overlay) y deja escombros ("out" 7f, se libera solo al terminar).
var inferno_dome_frames: SpriteFrames = null
func spawn_inferno_dome(dir: int) -> AnimatedSprite2D:
	if inferno_dome_frames == null:
		if not ResourceLoader.exists("res://imagen-action/impact-effect/faller-fx/build-1.png"):
			return null
		inferno_dome_frames = SpriteFrames.new()
		inferno_dome_frames.add_animation("build")
		inferno_dome_frames.set_animation_speed("build", 26.0)   # 22f ≈ 0.85s de carga
		inferno_dome_frames.set_animation_loop("build", false)
		var bi := 1
		while ResourceLoader.exists("res://imagen-action/impact-effect/faller-fx/build-%d.png" % bi):
			inferno_dome_frames.add_frame("build", load("res://imagen-action/impact-effect/faller-fx/build-%d.png" % bi))
			bi += 1
		inferno_dome_frames.add_animation("out")
		inferno_dome_frames.set_animation_speed("out", 18.0)     # escombros flotando
		inferno_dome_frames.set_animation_loop("out", false)
		var oi := 1
		while ResourceLoader.exists("res://imagen-action/impact-effect/faller-fx/out-%d.png" % oi):
			inferno_dome_frames.add_frame("out", load("res://imagen-action/impact-effect/faller-fx/out-%d.png" % oi))
			oi += 1
	var e := AnimatedSprite2D.new()
	e.sprite_frames = inferno_dome_frames
	e.animation = "build"
	e.frame = 0
	e.z_index = 6
	e.flip_h = dir < 0
	var s := 0.55
	e.scale = Vector2(s, s)
	get_parent().add_child(e)
	# lienzo 1800x1200 con la base del fuego en y=1150 (550 bajo el centro): base al piso,
	# el domo crece ADELANTE de DAM engullendo la zona del rival
	var ground_y := to_global(Vector2(0.0, SHADOW_FEET_OFFSET * base_scale.y)).y
	# +70: el fuego ABRAZA el piso (con la base exacta al suelo se veía flotando alto).
	# clamp: en la esquina el domo NO se sale de pantalla (medio domo ≈ 340)
	var gx := clampf(position.x + float(dir) * 520.0, 340.0, 1580.0)
	# PEGADO A LA PARED (pedido): el clamp de pantalla traia el domo ENCIMA de DAM.
	# El fuego SIEMPRE brota al menos ~390 ADELANTE del caster aunque asome por el borde
	if absf(gx - position.x) < 390.0:
		gx = position.x + float(dir) * 390.0
	e.global_position = Vector2(gx, ground_y - 550.0 * s + 70.0)
	e.animation_finished.connect(func() -> void:
		if String(e.animation) == "out":
			e.queue_free())
	return e

# SUPER combinado del INFIERNO: DAM + la GRAN OLA de fuego en una sola animación
# (5 frames). Se muestra ocultando el sprite normal de DAM; los pies de DAM del
# super (local 80,219) se anclan a los pies reales del fighter. La ola sale al
# frente y se espeja según el lado.
# Frames NUEVOS (inferno-1..5): DAM de espaldas casteando + la ola creciendo. Se
# NORMALIZAN a un lienzo comun 2934x1110 con DAM del MISMO tamaño en los 5 (pies en
# local (612,1078)); solo el FUEGO crece de la mano hacia el rival. A esta escala
# DAM queda ~igual que su tamaño real (imponente, no encogido).
const INFERNO_SUPER_SCALE := 0.65   # DAM a su tamaño NORMAL de pelea (~416px en pantalla)
const INFERNO_FEET := Vector2(559.0, 978.0)   # pies de DAM dentro del frame (lienzo 2663x1010)
var inferno_super_frames: SpriteFrames = null
func spawn_inferno_super() -> AnimatedSprite2D:
	if inferno_super_frames == null:
		if not ResourceLoader.exists("res://imagen-action/dam/inferno-full/dam-inferno-full-1.png"):
			return null
		inferno_super_frames = SpriteFrames.new()
		inferno_super_frames.add_animation("cast")
		inferno_super_frames.set_animation_speed("cast", 5.0)   # 5 frames ~1s
		inferno_super_frames.set_animation_loop("cast", false)
		for i in range(1, 6):
			inferno_super_frames.add_frame("cast", load("res://imagen-action/dam/inferno-full/dam-inferno-full-%d.png" % i))
	var e := AnimatedSprite2D.new()
	e.sprite_frames = inferno_super_frames
	e.animation = "cast"
	e.centered = false
	e.z_index = 6
	var s := INFERNO_SUPER_SCALE
	e.scale = Vector2(float(facing) * s, s)   # espeja por el signo de x
	get_parent().add_child(e)
	var feet := to_global(Vector2(0.0, SHADOW_FEET_OFFSET))
	# anclar los pies del super a los pies reales del fighter (espejo incluido)
	e.global_position = Vector2(feet.x - float(facing) * INFERNO_FEET.x * s, feet.y - INFERNO_FEET.y * s)
	e.play("cast")
	return e

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

# ===== MARCAS de Fe sobre ESTE personaje (la víctima marcada) =====
# 1-3 diamantes finos azules (como sus agujas) flotando sobre la cabeza, PULSANDO:
# el player ve cuántas marcas lleva y que está marcado. Con 3, se encienden al blanco
# (crítico listo). El conteo lo maneja main (fe_marks); acá solo el visual.
var fe_mark_count := 0
var fe_marks_node: Node2D = null

func set_fe_marks(n: int) -> void:
	fe_mark_count = clampi(n, 0, 3)
	if fe_marks_node == null:
		if fe_mark_count == 0:
			return
		fe_marks_node = Node2D.new()
		fe_marks_node.z_index = 6
		for k in 3:
			var d := Polygon2D.new()
			# diamante FINO tipo aguja de Fe
			d.polygon = PackedVector2Array([Vector2(0, -30), Vector2(11, 0), Vector2(0, 30), Vector2(-11, 0)])
			d.position = Vector2(-56.0 + 56.0 * float(k), 0.0)
			fe_marks_node.add_child(d)
		add_child(fe_marks_node)
	# sobre la CABEZA: pies (500·bs) menos el alto real del cuerpo (~715·body_k) menos aire
	fe_marks_node.position = Vector2(0.0, 500.0 * base_scale.y - 715.0 * body_k - 85.0)
	var listo := fe_mark_count >= 3
	for k in 3:
		var d: Polygon2D = fe_marks_node.get_child(k)
		d.visible = k < fe_mark_count
		# con 3: BLANCO caliente (crítico cargado); si no, azul aguja
		d.color = Color(1.3, 1.6, 2.5, 0.95) if listo else Color(0.55, 0.9, 2.0, 0.9)
	fe_marks_node.visible = fe_mark_count > 0

# PASO CORTO de Fe y DAM (doble-tap ←←/→→, estilo SF): brinquito veloz con polvo.
# Usa las anims "step"/"backdash" si el personaje las tiene; si no, walk de placeholder.
func _start_quick_step(adelante: bool) -> void:
	if airborne or koed or hit_flying or crouching or parry_t > 0.0 or step_t > 0.0:
		return
	if sprite.is_playing() and not _is_locomotion_anim() and String(sprite.animation) != "pose":
		return   # ocupado (atacando, casteando, reaccionando)
	# el dash CUESTA media barra (gris + blink si no hay)
	var mbs := get_parent()
	if mbs and mbs.has_method("try_meter_cost") and not mbs.try_meter_cost(self, 0.5):
		return
	step_t = STEP_DUR
	var dirx := float(facing) * (1.0 if adelante else -1.0)
	step_vx = dirx * (1150.0 if adelante else 1250.0)   # atrás un pelín más lejos (escape)
	# CUÑA de polvo (slam-dust): el pico barre hacia ATRÁS del movimiento del paso
	_spawn_slam_dust(-signi(int(dirx)), 0.7)
	# ESTELA de sombras del color del personaje: se LEE como dash, no como caminar
	breaker_fx_t = maxf(breaker_fx_t, 0.28)
	var anim := "step" if adelante else "backdash"
	if sprite.sprite_frames.has_animation(anim) and sprite.sprite_frames.get_frame_count(anim) > 0:
		sprite.play(anim)
	else:
		# placeholder: SE DESLIZA en una zancada CONGELADA del walk (nada de caminar rápido)
		sprite.play("walk")
		sprite.pause()
		sprite.frame = mini(6, sprite.sprite_frames.get_frame_count("walk") - 1)

# ESPECIAL DE AGUA de Fe (medialuna + Q/W/E): clava la aguja al piso y grita; el géiser
# brota a 1/2/3 CUERPOS adelante (según el botón) — el jugador adivina dónde está el rival.
var water_cast_sfx: AudioStream = null
func _start_water_special(bodies: int) -> void:
	var mbc := get_parent()
	if mbc and mbc.has_method("try_thunder_cost") and not mbc.try_thunder_cost(self):
		return   # sin MEDIA barra: ni cast ni rayo (gris + blink de la barra)
	crouching = false
	airborne = false
	walk_dir = 0
	sprite.play("water_cast")
	# audio del cast: "THUNDER POWER!" (voz nueva, enérgica); fallback a la de agua vieja
	var ruta := "res://imagen-action/favi/Fe-sound-effect/thunder-power-fe-energetica.wav"
	if not ResourceLoader.exists(ruta):
		ruta = "res://imagen-action/favi/Fe-sound-effect/water-cast-fe-energetica.wav"
	if water_cast_sfx == null and ResourceLoader.exists(ruta):
		water_cast_sfx = load(ruta)
	if water_cast_sfx != null:
		voz_player.stream = water_cast_sfx
		voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
		voz_player.play()
	var mb := get_parent()
	if mb and mb.has_method("_fe_water_special"):
		mb._fe_water_special(self, bodies)

# AYE (E): CRYSTAL CAST a distancia. Por ahora SOLO reproduce la animación (guardia→alza→grito #181);
# el proyectil que viaja (crystal_shard) + el impacto se cablean cuando exista ese efecto.
func _start_crystal_cast() -> void:
	crouching = false
	airborne = false
	walk_dir = 0
	sprite.play("crystal_cast")
	# TODO(proyectil): cuando exista imagen-action/aye/crystal_shard/, spawnear el cristal que
	# viaja hacia el rival + voz/SFX del cast (como spawn_ice_grow pero horizontal y en movimiento).

# FROST ORB (→↓←+R): usa la MISMA pose de casteo (crystal_cast) pero SUPRIME el proyectil normal
# (crystal_fired=true) y en su lugar el árbitro spawnea la orbe congelante que se desplaza.
func _start_frost_orb() -> void:
	crouching = false
	airborne = false
	walk_dir = 0
	crystal_fired = true   # evita que el hook de crystal_cast dispare el proyectil recto normal
	sprite.play("crystal_cast")
	var mb := get_parent()
	if mb and mb.has_method("_spawn_frost_orb"):
		mb._spawn_frost_orb(self)

# BACKSTAB (↓→W): lo orquesta main (sabe dónde está el rival): teleport DETRÁS + golpe + empujón ~3 cuerpos.
func _start_backstab() -> void:
	crouching = false
	airborne = false
	walk_dir = 0
	vel_x = 0.0
	vel_y = 0.0
	down_recent_t = 0.0
	var mb := get_parent()
	if mb and mb.has_method("_aye_backstab"):
		mb._aye_backstab(self)

# VIGILANTE del PILAR de hielo (W de Aye): chequea el contacto TODA la vida del remolino
# (~0.7s), no una sola foto — el rival puede ENTRAR CAMINANDO despues de la erupcion (asi
# se perdia el freeze en partidas reales con DAM avanzando). Zona de impacto MEDIDA por
# cuerpo: 330 (medio remolino + margen) + 1.5*medio_ancho del rival (el pie delantero de
# DAM sobresale ~250 de su centro).
func _pilar_freeze_watch(rv: Node2D, px: float) -> void:
	for _i in 14:
		await get_tree().create_timer(0.05).timeout
		if not is_instance_valid(rv) or rv.koed or rv.frozen_t > 0.0:
			return
		if absf(rv.position.x - px) < 330.0 + rv.body_halfw * 1.5:
			var _r: String = rv.receive_hit(false, false, facing, "", false, 1.0, false, false, true)
			if _r != "armored":
				return   # frozen o blocked (bloqueo legitimo) — el armor del TANK reintenta

# GÉISER de agua: brota del suelo en la x dada (bajo el rival), sube y se apaga solo.
var ice_grow_frames: SpriteFrames = null
var ice_cast_spawned := false
var cast_border_t := 0.0   # temporizador del BORDE MORADO durante los cast de hielo (W / ↓W)
# Aye W (ice-grow): pilar de HIELO morado que erupciona del piso (RÁPIDO). Efecto aparte + SFX.
func spawn_ice_grow(gx: float) -> Node2D:
	if ice_grow_frames == null:
		if not ResourceLoader.exists("res://imagen-action/aye/ice_grow/aye-ice_grow-1.png"):
			return null
		ice_grow_frames = SpriteFrames.new()
		ice_grow_frames.add_animation("erupt")
		ice_grow_frames.set_animation_speed("erupt", 30.0)   # rápido pero que corra un poco (sale y se va)
		ice_grow_frames.set_animation_loop("erupt", false)
		var i := 1
		while ResourceLoader.exists("res://imagen-action/aye/ice_grow/aye-ice_grow-%d.png" % i):
			ice_grow_frames.add_frame("erupt", load("res://imagen-action/aye/ice_grow/aye-ice_grow-%d.png" % i))
			i += 1
	var g := AnimatedSprite2D.new()
	g.sprite_frames = ice_grow_frames
	g.animation = "erupt"
	g.z_index = 6
	var s := 0.62 * absf(scale.x)
	g.scale = Vector2(s, s)
	get_parent().add_child(g)
	var ground_y := to_global(Vector2(0.0, SHADOW_FEET_OFFSET)).y
	g.global_position = Vector2(gx, ground_y - 499.0 * s)
	g.animation_finished.connect(g.queue_free)
	g.play("erupt")
	var ruta := "res://imagen-action/sound-effect/ice-growing.mp3"
	if ResourceLoader.exists(ruta):
		var sfx := AudioStreamPlayer.new()
		get_parent().add_child(sfx)
		sfx.stream = load(ruta)
		sfx.play()
		sfx.finished.connect(sfx.queue_free)
	return g

# Aye ↓W (crouch_kick): LUNA CRECIENTE de hielo morado que erupciona del piso (anti-aéreo, RÁPIDO).
# Misma geometría de canvas que ice-grow (base en FEET_Y=1139) -> reusa offset 499 y escala 0.62.
var ice_moon_frames: SpriteFrames = null
var moon_cast_spawned := false
var crystal_fired := false   # Aye E (crystal_cast): dispara el proyectil una sola vez por cast
var jp_shots := 0            # Aye jump_punch (aéreo): cuántos de los 3 proyectiles ya salieron
var channeling := false      # AYE (wizard): canaleo de mana (doble-tap abajo); recarga rapido, VULNERABLE
var down_tap_win := 0.0      # ventana para detectar el DOBLE-TAP abajo (~0.28s)
func spawn_ice_moon(gx: float) -> Node2D:
	if ice_moon_frames == null:
		if not ResourceLoader.exists("res://imagen-action/aye/ice_moon/aye-ice_moon-1.png"):
			return null
		ice_moon_frames = SpriteFrames.new()
		ice_moon_frames.add_animation("erupt")
		ice_moon_frames.set_animation_speed("erupt", 20.0)   # crece rápido, AGUANTA estática un rato, luego estalla
		ice_moon_frames.set_animation_loop("erupt", false)
		var i := 1
		while ResourceLoader.exists("res://imagen-action/aye/ice_moon/aye-ice_moon-%d.png" % i):
			ice_moon_frames.add_frame("erupt", load("res://imagen-action/aye/ice_moon/aye-ice_moon-%d.png" % i))
			i += 1
	var g := AnimatedSprite2D.new()
	g.sprite_frames = ice_moon_frames
	g.animation = "erupt"
	g.z_index = 6
	var s := 0.62 * absf(scale.x)
	# la luna es ASIMÉTRICA (creciente): se ESPEJA con el facing de Aye (source mira a la DERECHA).
	# El efecto cuelga del arena (no del fighter), así que el flip va en su propia escala.x.
	g.scale = Vector2(s * float(facing), s)
	get_parent().add_child(g)
	var ground_y := to_global(Vector2(0.0, SHADOW_FEET_OFFSET)).y
	g.global_position = Vector2(gx, ground_y - 499.0 * s)
	g.animation_finished.connect(g.queue_free)
	g.play("erupt")
	var ruta := "res://imagen-action/sound-effect/ice-growing.mp3"
	if ResourceLoader.exists(ruta):
		var sfx := AudioStreamPlayer.new()
		get_parent().add_child(sfx)
		sfx.stream = load(ruta)
		sfx.play()
		sfx.finished.connect(sfx.queue_free)
	return g

# Aye ↓E (sweep): PÚAS DE HIELO morado que erupcionan del piso cerca de ella. Misma geometría de
# canvas que ice-grow/ice-moon (base en FEET_Y=1139 -> offset 499, escala 0.62). Al golpear CONGELA
# al rival (frozen_t) — la reacción la maneja receive_hit; acá sólo el VISUAL + SFX.
var ice_spikes_frames: SpriteFrames = null
var spikes_cast_spawned := false
func spawn_ice_spikes(gx: float) -> Node2D:
	if ice_spikes_frames == null:
		if not ResourceLoader.exists("res://imagen-action/aye/ice_spikes/aye-ice_spikes-1.png"):
			return null
		ice_spikes_frames = SpriteFrames.new()
		ice_spikes_frames.add_animation("erupt")
		ice_spikes_frames.set_animation_speed("erupt", 28.0)   # erupta rápido y estalla en esquirlas
		ice_spikes_frames.set_animation_loop("erupt", false)
		var i := 1
		while ResourceLoader.exists("res://imagen-action/aye/ice_spikes/aye-ice_spikes-%d.png" % i):
			ice_spikes_frames.add_frame("erupt", load("res://imagen-action/aye/ice_spikes/aye-ice_spikes-%d.png" % i))
			i += 1
	var g := AnimatedSprite2D.new()
	g.sprite_frames = ice_spikes_frames
	g.animation = "erupt"
	g.z_index = 6
	var s := 0.50 * absf(scale.x)   # un poco más pequeño que la luna/pilar
	g.scale = Vector2(s * float(facing), s)   # las púas SE INCLINAN a la derecha en source -> espeja con el facing
	get_parent().add_child(g)
	var ground_y := to_global(Vector2(0.0, SHADOW_FEET_OFFSET)).y
	g.global_position = Vector2(gx, ground_y - 499.0 * s)
	g.animation_finished.connect(g.queue_free)
	g.play("erupt")
	var ruta := "res://imagen-action/sound-effect/ice-growing.mp3"
	if ResourceLoader.exists(ruta):
		var sfx := AudioStreamPlayer.new()
		get_parent().add_child(sfx)
		sfx.stream = load(ruta)
		sfx.play()
		sfx.finished.connect(sfx.queue_free)
	return g

# enciende el BORDE MORADO de cast (Aye) durante `dur` seg; se apaga solo en _physics_process.
func _cast_border_on(dur: float, col := Color(1.45, 0.35, 2.0, 1.0)) -> void:
	cast_border_t = maxf(cast_border_t, dur)
	var mb := get_parent()
	if mb and mb.has_method("_cast_border"):
		mb._cast_border(self, true, col)

var water_geyser_frames: SpriteFrames = null
func spawn_water_geyser(gx: float) -> Node2D:
	if water_geyser_frames == null:
		if not ResourceLoader.exists("res://imagen-action/impact-effect/water-geyser-fe/geyser-1.png"):
			return null
		water_geyser_frames = SpriteFrames.new()
		water_geyser_frames.add_animation("erupt")
		# THUNDER (reemplazo del géiser): 60 frames — copa crepitando + flare, disolución
		# PODADA. 240fps => ~0.25s: un DESTELLO, el rayo no se queda. Conteo DINÁMICO.
		water_geyser_frames.set_animation_speed("erupt", 240.0)
		water_geyser_frames.set_animation_loop("erupt", false)
		var gi := 1
		while ResourceLoader.exists("res://imagen-action/impact-effect/water-geyser-fe/geyser-%d.png" % gi):
			water_geyser_frames.add_frame("erupt", load("res://imagen-action/impact-effect/water-geyser-fe/geyser-%d.png" % gi))
			gi += 1
	var g := AnimatedSprite2D.new()
	g.sprite_frames = water_geyser_frames
	g.animation = "erupt"
	g.z_index = 6
	var s := 0.62 * absf(scale.x)
	# RAYO ESTIRADO: 1.5x vertical (viene del CIELO, mucho más alto que Fe) y un pelín
	# más ancho. La base sigue clavada al piso: el offset vertical usa la escala Y.
	var sy := s * 1.5
	g.scale = Vector2(s * 1.08, sy)
	get_parent().add_child(g)
	# frames 760x1000 anclados abajo (base del impacto ~y=980, centro=500 -> 480px bajo el centro)
	var ground_y := to_global(Vector2(0.0, SHADOW_FEET_OFFSET)).y
	g.global_position = Vector2(gx, ground_y - 480.0 * sy)
	g.animation_finished.connect(g.queue_free)
	g.play("erupt")
	# DUST de impacto clavado al piso en el punto del rayo (el mismo de caer un player)
	_spawn_jump_dust(1.05, gx)
	# HUMO de CHAMUSCADO (las DOS capas del quemado de DAM: oscura + clara) en el punto
	# del impacto: NACE en la base donde cayó el rayo (anclado por la base, no el centro),
	# se queda un momento sobre el suelo y se disipa. Escalas de MUNDO (sin el 0.65 del
	# nodo): 0.9 quedaba gigante y 345px enterrado bajo el piso.
	if ResourceLoader.exists("res://imagen-action/impact-effect/humo/humo-1.png"):
		var hs := 0.55
		var sm := _make_smoke("res://imagen-action/impact-effect/humo/humo-%d.png", 5, 7.0,
				Vector2.ZERO, hs, Color(0.38, 0.36, 0.38, 0.0))
		sm.z_index = 5
		get_parent().add_child(sm)
		sm.global_position = Vector2(gx, ground_y - 768.0 * hs * 0.5 + 20.0)   # base al suelo
		sm.play("humo")
		var tw := sm.create_tween()
		tw.tween_interval(0.22)                          # espera a que el rayo se deshaga
		tw.tween_property(sm, "modulate:a", 0.6, 0.18)   # brota el humo oscuro
		tw.tween_interval(0.9)                           # se queda un momento
		tw.tween_property(sm, "modulate:a", 0.0, 0.7)    # se disipa
		tw.tween_callback(sm.queue_free)
	if ResourceLoader.exists("res://imagen-action/impact-effect/humo2/humo2-1.png"):
		var hs2 := 0.48
		var sm2 := _make_smoke("res://imagen-action/impact-effect/humo2/humo2-%d.png", 6, 8.0,
				Vector2.ZERO, hs2, Color(0.62, 0.60, 0.62, 0.0))
		sm2.z_index = 6
		get_parent().add_child(sm2)
		sm2.global_position = Vector2(gx + 24.0, ground_y - 866.0 * hs2 * 0.5 + 20.0)
		sm2.play("humo")
		var tw2 := sm2.create_tween()
		tw2.tween_interval(0.24)
		tw2.tween_property(sm2, "modulate:a", 0.38, 0.18)  # capa CLARA tenue delante
		tw2.tween_interval(0.85)
		tw2.tween_property(sm2, "modulate:a", 0.0, 0.65)
		tw2.tween_callback(sm2.queue_free)
	# SFX del TRUENO al caer el rayo (thunder-crack.wav: sintetizado, se puede REEMPLAZAR
	# el archivo por uno mejor sin tocar código). Fallback al chapoteo viejo. En un player
	# PROPIO para no cortar la voz del cast (sfx_player). loop=false -> se libera solo.
	var geyser_sfx := "res://imagen-action/favi/Fe-sound-effect/thunder-crack.wav"
	if not ResourceLoader.exists(geyser_sfx):
		geyser_sfx = "res://imagen-action/favi/Fe-sound-effect/water-splahs.mp3"
	if ResourceLoader.exists(geyser_sfx):
		var strm := load(geyser_sfx)
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

func _spawn_ghost(blue := false, blanco := false) -> void:
	# blanco: estela de ENERGÍA PURA BLANCA (whirlpool nuevo de Fe)
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
	if blanco:
		g.modulate = Color(1.85, 1.95, 2.2, 0.6)     # BLANCO energía pura (whirlpool Fe)
	elif fx_floral:
		g.modulate = Color(1.25, 0.45, 1.75, 0.62)   # MORADO (Aye)
	elif blue:
		g.modulate = Color(0.42, 0.78, 1.9, 0.62)
	elif fx_dark:
		g.modulate = Color(0.62, 0.20, 1.25, 0.62)   # MORADO OSCURO (Zetma)
	else:
		g.modulate = Color(1.7, 0.42, 0.38, 0.62)
	get_parent().add_child(g)
	g.global_transform = sprite.global_transform
	var tw := g.create_tween()
	var fin := Color(0.03, 0.09, 0.34, 0.0) if blue else (Color(0.14, 0.02, 0.26, 0.0) if fx_dark else Color(0.34, 0.03, 0.05, 0.0))
	if fx_floral:
		fin = Color(0.22, 0.03, 0.34, 0.0)
	tw.tween_property(g, "modulate", fin, 0.55)   # perdura más (fade lento)
	tw.tween_callback(g.queue_free)

func _launch(push_dir: int, mult := 1.0) -> void:
	crouching = false
	airborne = true
	var en_juggle := hit_flying   # ¿ya venía VOLANDO de un golpe anterior?
	hit_flying = true
	punch_followup = false
	if en_juggle and mult <= 1.0:
		# JUGGLE PRO: al que YA vuela, cada golpe normal le da un REBOTE CHICO hacia arriba
		# que lo SUSPENDE a la altura del combo (el re-lanzamiento full lo mandaba a la luna
		# y el combo aéreo era imposible de seguir). Los lanzadores fuertes (launch_mult>1,
		# ultras/finishers) SÍ re-lanzan a full. El decaimiento es SUAVE (0.96): con el
		# 0.92 anterior al 5º golpe del combo el rebote ya era invisible ("se va cayendo").
		vel_y = -1400.0 * CHAR_SCALE * pow(0.96, float(juggle_hits))
		vel_x = push_dir * KNOCKBACK_X * 0.45
		juggle_hold_t = 0.55   # y tras el rebote cae LENTO un rato (sostén de combo)
	else:
		# decaimiento de juggle: cada lanzamiento seguido eleva menos (anti-infinito)
		vel_y = -KNOCKBACK_Y * mult * pow(0.86, float(juggle_hits))
		vel_x = push_dir * KNOCKBACK_X
	fly_lean = float(push_dir)   # el cuerpo se ladea hacia donde sale despedido
	# ESQUINA: lanzado CERCA de la pared -> el vuelo es RECTO hacia ARRIBA (no viaja a la pared)
	if (push_dir < 0 and position.x - 115.0 < 300.0) or (push_dir > 0 and 1805.0 - position.x < 300.0):
		vel_y -= absf(vel_x) * 0.5
		vel_x = 0.0
	juggle_hits += 1
	var ya_volaba := String(sprite.animation) == "hit_fly"
	sprite.play("hit_fly")
	if ya_volaba:
		var k := impact_sfx_override if (impact_sfx_override != "" and sfx.has(impact_sfx_override)) else "hit_fly"
		_play_sfx_key(k)

# push_dir: hacia donde empuja el golpe (+1 derecha / -1 izquierda)
func receive_hit(low: bool, strong: bool, push_dir: int, impact_key := "", trip := false, launch_mult := 1.0, wall := false, atk_blue := false, freeze := false, shove := 0.0, bounce := false) -> String:
	impact_sfx_override = impact_key
	_stop_channel()   # recibir golpe CANCELA el canaleo (+ corta el sonido de carga)
	if breaker_inv_t > 0.0:
		return "ignored"
	if koed or (is_downed() and not hit_flying):
		return "ignored"
	# SUPER ARMOR (TANK): durante el ARRANQUE de su golpe pesado (kick) aguanta golpes
	# NO-lanzadores sin trastabillar ni frenar su golpe -> mata el mash del assassin. Recibe
	# CHIP (lo aplica main._process_attacker). Los LANZADORES (strong/wall/trip) SÍ lo atraviesan.
	if has_super_armor and not airborne and String(sprite.animation) == "kick" \
			and sprite.is_playing() and sprite.frame <= 4 \
			and not strong and not wall and not trip:
		_burst(0.7, false, 1, atk_blue)   # chispa de aguante
		return "armored"
	special_t = 0.0  # un golpe recibido corta el dash especial
	fe_dash_t = 0.0  # ...y también el dash de agujas de Fe
	fe_dash_active = false
	# ...y la voz "Power Twister" si la peonza fue interrumpida (que no quede colgada)
	if spin_voz_sfx != null and voz_player.playing and voz_player.stream == spin_voz_sfx:
		voz_player.stop()
	# encara al ATACANTE al recibir (push_dir = empuje del golpe; el atacante está
	# del lado contrario). Así el escudo de bloqueo (flip_h = facing<0) mira al golpe.
	set_facing(-push_dir)
	# CONGELADO (🩷) EN EL AIRE: prioridad sobre el derribo — se queda EXACTO donde está (su pose aérea) +
	# morado. El pilar NO sale en el aire (lo decide el árbitro). El freeze en SUELO sigue más abajo (tras bloqueo).
	if freeze and airborne:
		_burst(0.9, false, 1, atk_blue)
		vel_x = 0.0
		vel_y = 0.0
		frozen_t = FREEZE_DUR
		return "frozen"
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
	if _es_humano():
		var away := Input.is_action_pressed(act("ui_left")) if facing > 0 else Input.is_action_pressed(act("ui_right"))
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
	# AYE ↓E (púas de hielo): CONGELA al rival en su pose actual ~0.5s (inmóvil + tinte morado).
	# NO reproduce take_hit: se queda EXACTO en el frame en que estaba (idle, caminando, atacando...).
	# El daño/hitstop del atacante los aplica main._process_attacker (result "frozen").
	if freeze:
		_burst(0.9, false, 1, atk_blue)
		vel_x = 0.0
		vel_y = 0.0
		frozen_t = FREEZE_DUR
		return "frozen"
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
		if bounce:
			floor_bounce_pending = true   # E de ROUM: al caer REBOTA contra el suelo (sube y vuelve a caer)
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
	# EMPUJÓN (ROUM weak_punch): nudge inmediato GRANDE + slide con timer propio (0.6s). Ambos usan
	# push_dir (+derecha / -izquierda) -> empuja IGUAL a los dos lados. El nudge grande garantiza que
	# se VEA de una aunque el hitstop se coma el arranque del slide.
	if shove > 0.0:
		position.x = clampf(position.x + float(push_dir) * 70.0, 115.0, 1805.0)
		shove_vx = float(push_dir) * shove
		shove_t = 0.45
		vel_x = 0.0        # mata el impulso de caminar del rival: si no, su vel_x hacia ROUM
		buffer_t = 0.0     # cancelaba el empuje en el facing en que se acercaba (bug asimétrico)
	else:
		position.x += push_dir * 20
	return "hit"

const BURN_DUR := 5.0
var burned_t := 0.0
var burn_smoke: AnimatedSprite2D = null          # DETRÁS del cuerpo (humo-1..5)
var burn_smoke_front: AnimatedSprite2D = null    # DELANTE del pecho, tenue (humo2-1..6)
# estado QUEMADO: el cuerpo se ve oscuro/carbonizado y se recupera de a poco.
# General: cualquier poder de fuego (inferno de DAM, etc.) lo puede aplicar.
func start_burn(dur := BURN_DUR) -> void:
	burned_t = maxf(burned_t, dur)
	_ensure_burn_smoke()
	if burn_smoke != null:
		burn_smoke.visible = true
	if burn_smoke_front != null:
		burn_smoke_front.visible = true

func _make_smoke(path_fmt: String, n: int, speed: float, pos: Vector2, scl: float, col: Color) -> AnimatedSprite2D:
	var sf := SpriteFrames.new()
	sf.add_animation("humo")
	sf.set_animation_speed("humo", speed)
	sf.set_animation_loop("humo", true)
	for i in range(1, n + 1):
		sf.add_frame("humo", load(path_fmt % i))
	var sm := AnimatedSprite2D.new()
	sm.sprite_frames = sf
	sm.animation = "humo"
	sm.modulate = col
	sm.position = pos
	sm.scale = Vector2(scl, scl)
	return sm

# HUMO de ropa quemada: DOS capas grises en loop mientras arde, que se desvanecen al
# recuperarse. (1) DETRÁS del cuerpo (sube por el torso). (2) DELANTE del pecho, MÁS
# TENUE, para que no tape al personaje.
func _ensure_burn_smoke() -> void:
	if burn_smoke != null or burn_smoke_front != null:
		return
	# El humo se UBICA y se ACHICA según el cuerpo (DAM alto vs Fe más chica). Los pies caen
	# a +500 del centro en TODOS, así que anclamos el humo al PECHO: 500 - alto_pecho*base_scale.y.
	# Calibrado a DAM (base_scale.y≈1.10 -> y=90/120, escala 0.8/0.55 EXACTO). Sin esto, en Fe
	# el humo quedaba MUY ARRIBA (fuera del cuerpo) y solo se veía al caer tendida (al final).
	var bs := base_scale.y
	if ResourceLoader.exists("res://imagen-action/impact-effect/humo/humo-1.png"):
		burn_smoke = _make_smoke("res://imagen-action/impact-effect/humo/humo-%d.png", 5, 7.0,
				Vector2(0.0, 500.0 - 372.7 * bs), 0.727 * bs, Color(0.42, 0.40, 0.42, 0.0))
		add_child(burn_smoke)
		move_child(burn_smoke, sprite.get_index())    # DETRÁS del cuerpo
		burn_smoke.play("humo")
	if ResourceLoader.exists("res://imagen-action/impact-effect/humo2/humo2-1.png"):
		burn_smoke_front = _make_smoke("res://imagen-action/impact-effect/humo2/humo2-%d.png", 6, 8.0,
				Vector2(0.0, 500.0 - 345.5 * bs), 0.5 * bs, Color(0.52, 0.50, 0.52, 0.0))
		burn_smoke_front.z_index = 1                  # DELANTE del cuerpo (sobre el pecho)
		add_child(burn_smoke_front)
		burn_smoke_front.play("humo")

func _physics_process(delta: float) -> void:
	queue_redraw()
	if swing_layer:
		swing_layer.queue_redraw()   # la estela se dibuja por delante del cuerpo
	# HITSTOP: mientras dure, el cuerpo queda CONGELADO (frame del impacto). Solo
	# redibuja; no avanza física, animación ni timers. Los efectos (chispas, temblor)
	# y el buffer de input sí siguen (van por su cuenta).
	if hitstop_t > 0.0:
		hitstop_t -= delta
		if hitstop_t <= 0.0:
			sprite.speed_scale = 1.0   # reanuda la animación
		else:
			return
	# ESFERA de Zetma (orb_trap_t): CÁMARA LENTA — el rival no puede actuar ~2s, teñido morado, la
	# anim corre LENTA; PERO SÍ recibe golpes (Zetma lo combea). input_enabled=false bloquea su input.
	if orb_trap_t > 0.0:
		orb_trap_t -= delta
		vel_x = 0.0
		vel_y = 0.0
		sprite.speed_scale = 0.16   # cámara MUY lenta (bien lento, pedido) mientras dura la esfera
		var _tk := 0.5 + 0.5 * absf(sin(orb_trap_t * 10.0))
		sprite.modulate = Color(1, 1, 1, 1).lerp(Color(1.25, 0.5, 2.0, 1.0), _tk)
		# el atrapado JUEGA su anim de "halado" (get_pull, lanzada en _zetma_orb_hit); NO se escala
		if orb_trap_t <= 0.0:
			sprite.speed_scale = 1.0
			sprite.modulate = Color(1, 1, 1, 1)
			sprite.scale = base_scale
			sprite.position = orb_trap_sprite_home
			input_enabled = orb_trap_was_input
			ai_enabled = orb_trap_was_ai
			if not koed and sprite.sprite_frames.has_animation("pose"):
				sprite.play("pose")
		queue_redraw()
		return
	if orb_haste_t > 0.0:
		orb_haste_t -= delta   # Zetma: haste de movimiento (el boost se aplica en el walk)
	# CONGELADO por las púas de hielo de Aye (↓E): INMÓVIL ~0.5s, pausado en el FRAME/pose en que
	# quedó, teñido de MORADO pulsante (como atrapado en hielo). No corre física ni input mientras dura.
	if frozen_t > 0.0:
		frozen_t -= delta
		vel_x = 0.0
		vel_y = 0.0
		# CONGELADO SIMPLE (pedido): NO se reproduce la anim "frozen" (el tiritón/pose de Dam y Fe).
		# El personaje se PAUSA en el frame EXACTO en que quedó + tinte morado (abajo).
		if frozen_t > 0.0:
			sprite.speed_scale = 0.0   # congela el frame ACTUAL (no avanza la animación)
			sprite.position.y = 0.0   # anula el offset de "tendido" si algo lo aplico (el modelo NO baja)
			var fk := 0.55 + 0.45 * absf(sin((FREEZE_DUR - frozen_t) * 20.0))
			sprite.modulate = Color(1, 1, 1, 1).lerp(Color(1.35, 0.45, 2.0, 1.0), fk)
			queue_redraw()
			return
		else:
			sprite.speed_scale = 1.0   # se libera: reanuda
			sprite.modulate = Color(1, 1, 1, 1)
			if String(sprite.animation) == "frozen":
				if koed:
					# KO recibido CONGELADO (pedido): al acabarse el hielo CAE tendido
					sprite.position.y = 0.0
					sprite.play("ko")
				else:
					sprite.play("pose")   # sale del congelado a idle
	# EMPUJÓN de ROUM (weak_punch): desliza al rival por el SUELO mientras encaja el golpe (take_hit),
	# decayendo con fricción y frenando en las paredes. Se corta al salir de take_hit o si despega.
	if shove_t > 0.0:
		shove_t -= delta
		if airborne or koed:
			shove_t = 0.0
			shove_vx = 0.0
		else:
			vel_x = 0.0   # mientras dura el empujón, NADA de velocidad de caminar propia (que lo pisaba)
			# desliza en la dirección del empujón (shove_vx ya trae el signo: + derecha / - izquierda)
			position.x = clampf(position.x + shove_vx * delta, 115.0, 1805.0)
			shove_vx = move_toward(shove_vx, 0.0, SHOVE_FRICTION * delta)
			if shove_t <= 0.0:
				shove_vx = 0.0
	# inclinación al salir volando: el cuerpo se ladea hacia la dirección del empujón (no vertical)
	if hit_flying and String(sprite.animation) == "hit_fly":
		# ZETMA (fx_dark) y ROUM (fx_warrior): su clip de vuelo YA trae la orientación del tumbo
		# (ROUM termina TENDIDO horizontal), así que NO se les suma el tilt de 34° (se sobre-rotaba).
		sprite.rotation = 0.0 if (fx_dark or fx_warrior or sprite.sprite_frames.get_frame_count("hit_fly") > 100) else deg_to_rad(FLY_TILT_DEG) * fly_lean   # clips de TUMBO (>100f: ROUM/DAM) ya traen orientación → sin tilt
	elif sprite.rotation != 0.0:
		sprite.rotation = 0.0
	burst_t = maxf(0.0, burst_t - delta)
	air_float_t = maxf(0.0, air_float_t - delta)
	juggle_hold_t = maxf(0.0, juggle_hold_t - delta)
	breaker_inv_t = maxf(0.0, breaker_inv_t - delta)
	slow_t = maxf(0.0, slow_t - delta)   # ESFERA AZUL: decae el slow (el tinte azul se pinta abajo)
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
	elif burned_t > 0.0:
		# QUEMADO: oscurecido/carbonizado que se aclara de a poco hasta normal
		burned_t = maxf(0.0, burned_t - delta)
		var bt := burned_t / BURN_DUR   # 1 (recién quemado) -> 0 (recuperado)
		sprite.modulate = Color(1, 1, 1, 1).lerp(Color(0.30, 0.23, 0.24, 1), bt)
		# el HUMO dura ~3s: cubre el golpe + la caída + LEVANTARSE humeando (como DAM);
		# después se disipa. El oscurecido (tinte) sí dura todo el BURN_DUR.
		var smoke_dur := 3.0
		var smk := clampf((burned_t - (BURN_DUR - smoke_dur)) / smoke_dur, 0.0, 1.0)
		var showing := smk > 0.01
		if burn_smoke != null:
			burn_smoke.visible = showing
			burn_smoke.modulate.a = 0.7 * smk           # DETRÁS: normal
		if burn_smoke_front != null:
			burn_smoke_front.visible = showing
			burn_smoke_front.modulate.a = 0.3 * smk     # DELANTE: MÁS TENUE (no tapa)
	elif deny_t > 0.0:
		# NO PUDO CASTEAR (sin recurso): GRIS medio segundo, desvaneciendo al final
		deny_t = maxf(0.0, deny_t - delta)
		var dk := clampf(deny_t / 0.2, 0.0, 1.0)   # los últimos 0.2s se desvanece
		sprite.modulate = Color(1, 1, 1, 1).lerp(Color(0.42, 0.42, 0.48, 1.0), dk)
	elif slow_t > 0.0:
		# ESFERA AZUL de Aye: rival AZUL y LENTO ~0.5s (tinte azul pulsante; el slow de movimiento va en el walk)
		var sk := 0.55 + 0.45 * absf(sin(slow_t * 16.0))
		sprite.modulate = Color(1, 1, 1, 1).lerp(Color(0.45, 0.7, 1.7, 1.0), sk)
	elif rage_mode:
		# BERSERK de DAM: figura OSCURA con dejo rojizo mientras dura la rabia
		sprite.modulate = Color(0.52, 0.34, 0.34, 1.0)
	elif sprite.modulate != Color(1, 1, 1, 1):
		sprite.modulate = Color(1, 1, 1, 1)
		if burn_smoke != null:
			burn_smoke.visible = false
		if burn_smoke_front != null:
			burn_smoke_front.visible = false
	elif (burn_smoke != null and burn_smoke.visible) or (burn_smoke_front != null and burn_smoke_front.visible):
		if burn_smoke != null:
			burn_smoke.visible = false
		if burn_smoke_front != null:
			burn_smoke_front.visible = false
	# pulso de las MARCAS de Fe sobre la cabeza (víctima marcada): respiran; con 3 laten rápido
	if fe_marks_node != null and fe_marks_node.visible:
		var _mt := float(Time.get_ticks_msec()) / 1000.0
		fe_marks_node.modulate.a = 0.55 + 0.45 * absf(sin(_mt * (9.0 if fe_mark_count >= 3 else 4.5)))
	# ELECTROCUTADO (independiente de la cadena de tintes: la figura NO se tiñe): silueta
	# blanca intermitente detrás mientras dure el timer
	if electro_t > 0.0:
		electro_t = maxf(0.0, electro_t - delta)
		# pose de ELECTROCUTADO estándar (GUIA-COMUN): si el personaje tiene su anim
		# "electrocuted" (convulsión estilo Street Fighter), la hace durante la descarga
		if electro_t > 0.0 and not koed and not is_downed() \
				and sprite.sprite_frames.has_animation("electrocuted") \
				and String(sprite.animation) != "electrocuted":
			sprite.play("electrocuted")
		if electro_t <= 0.0 and String(sprite.animation) == "electrocuted":
			sprite.play("pose")
		_electro_ghost_update()
	elif electro_ghost != null and electro_ghost.visible:
		electro_ghost.visible = false

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
	if _es_humano() and input_enabled and Input.is_action_pressed(act("ui_down")):
		down_recent_t = 0.4
	else:
		down_recent_t = maxf(0.0, down_recent_t - delta)
	# memoria de ADELANTE (hacia el rival) para el comando del ULTRA (→ R R)
	var _fwd := Input.get_axis(act("ui_left"), act("ui_right"))
	if _es_humano() and input_enabled and _fwd != 0.0 and int(signf(_fwd)) == facing:
		fwd_recent_t = 0.5
	else:
		fwd_recent_t = maxf(0.0, fwd_recent_t - delta)
	# memoria de ATRÁS (lejos del rival) para el motion ←→ del DASH DE AGUJAS de Fe
	if _es_humano() and input_enabled and _fwd != 0.0 and int(signf(_fwd)) == -facing:
		back_recent_t = 0.45
	else:
		back_recent_t = maxf(0.0, back_recent_t - delta)
	# HCB (→ ↓ ← = ADELANTE, ABAJO, ATRÁS) para el FROST ORB de Aye (+R). Máquina de estados con ventana.
	if _es_humano() and input_enabled:
		var _fh := _fwd != 0.0 and int(signf(_fwd)) == facing    # adelante
		var _bh := _fwd != 0.0 and int(signf(_fwd)) == -facing   # atrás
		var _dh := Input.is_action_pressed(act("ui_down"))            # abajo
		if _hcb_stage == 0 and _fh:
			_hcb_stage = 1; _hcb_win = 0.55
		elif _hcb_stage == 1 and _dh:
			_hcb_stage = 2
		elif _hcb_stage == 2 and _bh:
			hcb_t = 0.25; _hcb_stage = 0    # motion COMPLETO -> ventana para apretar R
		_hcb_win = maxf(0.0, _hcb_win - delta)
		if _hcb_win <= 0.0:
			_hcb_stage = 0
	hcb_t = maxf(0.0, hcb_t - delta)
	# ORBES DE AYE-2: RECALL con R (weak_punch). tap = 1 (más viejo) · hold ≥ ORB_RECALL_HOLD = los 3.
	if fx_floral and _es_humano() and input_enabled:
		if Input.is_action_pressed(act("weak_punch")):
			if not _orb_antiair_done:
				# PRIORIDAD: si hay esferas PLANTADAS (←→+color), R —parado o agachado— las RECOGE.
				if not airborne and _has_planted_orbs():
					_do_recall(3)   # vuelven TODAS las plantadas (pegan al cruzar)
				elif airborne:
					_do_spin()       # salto+R = ESCUDO GIRATORIO (las levanta al tocar)
				elif crouching:
					_do_antiair()    # ↓R = ANTI-AÉREO (círculo amplio hacia arriba)
				else:
					_do_throw_all()  # R de pie = tira las 3 adelante, una por una, y vuelven
				_orb_antiair_done = true
		else:
			_orb_antiair_done = false
	# DASH DE AGUJAS de Fe en curso: embiste hacia adelante y deja estela azul
	if fe_dash_t > 0.0:
		fe_dash_t = maxf(0.0, fe_dash_t - delta)
		position.x += float(facing) * FE_DASH_SPEED * delta
	# candado del CASTEO del BERSERK: usa special_t pero NO es el dash — quieto EN EL SITIO
	if special_t > 0.0 and String(sprite.animation) == "berserk_cast":
		special_t = maxf(0.0, special_t - delta)
	# EMBER DASH en curso: avanza ardiendo y suelta sombras
	elif special_t > 0.0:
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
	if rage_mode:
		breaker_fx_t = maxf(breaker_fx_t, 0.2)   # BERSERK: sombras ROJAS continuas mientras dure
	_update_rage_eyes()                          # chispas rojas de los OJOS en berserk
	if special_t > 0.0 or breaker_fx_t > 0.0 or water_bg or fe_dash_t > 0.0:
		ghost_timer -= delta
		if ghost_timer <= 0.0:
			ghost_timer = 0.038
			# Fe (fx_blue) SIEMPRE deja sombras AZULES (dash, agua, breaker, ultra); DAM rojas
			_spawn_ghost(water_bg or fe_dash_t > 0.0 or fx_blue)
	# Aye — W (kick) = PILAR ice-grow; ↓W (crouch_kick) = LUNA ice-moon (anti-aéreo, lanza al rival).
	# Al arrancar el cast spawna el hielo morado delante + SFX + aura MORADA. Una sola vez por golpe.
	if fx_floral and String(sprite.animation) == "kick" and sprite.is_playing():
		# ORBES aye2: el pilar de hielo y el freeze salen al IMPACTAR el 🩷 orbe
		# (main._orb_apply_effect), NO al tirar. Antes acá se spawneaba el pilar + _pilar_freeze_watch
		# en el gesto (congelaba sin impactar) — quitado a pedido.
		moon_cast_spawned = false
		spikes_cast_spawned = false
	elif fx_floral and String(sprite.animation) == "crouch_kick" and sprite.is_playing():
		# ORBES aye2: ↓W lanza el 🩷 orbe. Quitada la MEDIA LUNA (ice_moon) — no se usa por ahora.
		ice_cast_spawned = false
		spikes_cast_spawned = false
	elif fx_floral and String(sprite.animation) == "sweep" and sprite.is_playing():
		# ORBES aye2: ↓E lanza el 🔵 orbe. Quitadas las púas (ice_spikes).
		ice_cast_spawned = false
		moon_cast_spawned = false
	else:
		ice_cast_spawned = false
		moon_cast_spawned = false
		spikes_cast_spawned = false
	# Aye — E (crystal_cast): al gritar (#181) LANZA el proyectil de cristal + aura MORADA + borde
	# + voz "PRISM BOLT". El proyectil (viaje + impacto) lo maneja main._spawn_crystal_projectile.
	if fx_floral and String(sprite.animation) == "crystal_cast" and sprite.is_playing():
		if sprite.frame >= 5 and not crystal_fired:   # dispara ANTES para que el proyectil pegue dentro del combo
			crystal_fired = true
			breaker_fx_t = maxf(breaker_fx_t, 0.7)
			_cast_border_on(0.7)
			var vruta := "res://imagen-action/aye/sound-effect/prims-bolt-aye.mp3"
			if ResourceLoader.exists(vruta):
				voz_player.stream = load(vruta)
				voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
				voz_player.play()
			var mbp := get_parent()
			if mbp and mbp.has_method("_spawn_crystal_projectile"):
				mbp._spawn_crystal_projectile(self)
	elif fx_floral and String(sprite.animation) == "jump_kick_cast" and sprite.is_playing():
		# AYE jump_kick_cast (aéreo): dispara los 3 proyectiles EN CUANTO empieza a girar el báculo
		# (frame >=3), NO al final — si espera al lanzamiento no da tiempo antes de aterrizar. Salen uno
		# detrás del otro (main._aye_air_barrage: espaciados 0.13s, no los 3 a la vez).
		if jp_shots == 0 and sprite.frame >= 3:
			jp_shots = 3   # marca que ya disparó (no repetir)
			var mbp2 := get_parent()
			if mbp2 and mbp2.has_method("_aye_air_barrage"):
				mbp2._aye_air_barrage(self)
	elif fx_floral and String(sprite.animation) == "air_jab" and sprite.is_playing():
		# ORBES aye2: ↑R = RECALL (lo dispara el poll de weak_punch). Quitado el barrage de bolts.
		pass
	else:
		crystal_fired = false
		# corta el whoosh del giro al TERMINAR jump_kick_cast (si no seguiría sonando ~4.5s)
		if jp_shots > 0 and sfx_player.playing and sfx_key == "jump_kick_cast":
			sfx_player.stop()
		jp_shots = 0
	# BORDE MORADO de cast: se apaga solo al expirar el temporizador
	if cast_border_t > 0.0:
		cast_border_t = maxf(0.0, cast_border_t - delta)
		if cast_border_t == 0.0:
			var _cb := get_parent()
			if _cb and _cb.has_method("_cast_border"):
				_cb._cast_border(self, false)
	up_tap_t = maxf(0.0, up_tap_t - delta)
	double_up_t = maxf(0.0, double_up_t - delta)
	back_tap_win = maxf(0.0, back_tap_win - delta)
	fwd_tap_win = maxf(0.0, fwd_tap_win - delta)
	down_tap_t = maxf(0.0, down_tap_t - delta)
	double_down_t = maxf(0.0, double_down_t - delta)
	back_tap_t = maxf(0.0, back_tap_t - delta)
	double_back_t = maxf(0.0, double_back_t - delta)
	fwd_tap_t = maxf(0.0, fwd_tap_t - delta)
	double_fwd_t = maxf(0.0, double_fwd_t - delta)
	roum_super_t = maxf(0.0, roum_super_t - delta)   # timer del SÚPER ↓W de ROUM
	pq_tap_t = maxf(0.0, pq_tap_t - delta)
	pw_tap_t = maxf(0.0, pw_tap_t - delta)
	pe_tap_t = maxf(0.0, pe_tap_t - delta)
	pr_tap_t = maxf(0.0, pr_tap_t - delta)
	ultra_r_t = maxf(0.0, ultra_r_t - delta)
	dash_smoke_cd = maxf(0.0, dash_smoke_cd - delta)
	# DUST del AZOTE del KO de pie de Fe: su colapso nuevo toca el piso en el frame ~26
	if fx_blue and koed and String(sprite.animation) == "ko" and sprite.frame >= 26 \
			and not _ko_dust_done and sprite.sprite_frames.get_frame_count("ko") > 8:
		_ko_dust_done = true
		_spawn_jump_dust(0.85)
	# DUST del W de Fe: al disparar la patada ALTA (la 2ª) pivota fuerte en el pie de
	# apoyo -> ráfaga de polvo en el piso (boceto del usuario #310)
	if fx_blue and not airborne and String(sprite.animation) == "kick" and sprite.is_playing() \
			and sprite.frame >= 36 and sprite.frame <= 46 and dash_smoke_cd <= 0.0 \
			and sprite.sprite_frames.get_frame_count("kick") > 12:
		_spawn_dash_smoke(0.5, 200.0)
		dash_smoke_cd = 0.6

	# PARRY (Q+W): CONGELADO en la pose de desvío durante la ventana (~0.5s), con el borde/
	# aura del color del personaje. Si te pegan acá, main dispara el counter (y pone parry_t=0).
	# Si expira sin golpe, vuelve a la guardia (la barra ya se gastó al activarlo).
	if parry_t > 0.0 and not koed:
		parry_t = maxf(0.0, parry_t - delta)
		breaker_fx_t = maxf(breaker_fx_t, 0.15)   # sombras del color del personaje
		# GLOW PULSANTE (MORADO Aye / azul Fe / rojo DAM) para INDICAR que está en la postura de parry
		var pg := 0.55 + 0.45 * absf(sin((PARRY_WINDOW - parry_t) * 26.0))
		var pcol: Color = Color(1.5, 0.5, 2.0) if fx_floral else (Color(0.5, 0.85, 1.9) if fx_blue else (Color(0.95, 0.30, 1.85) if fx_dark else Color(1.9, 0.45, 0.35)))
		sprite.modulate = Color(1, 1, 1, 1).lerp(pcol, pg)
		if String(sprite.animation) == "counter":
			sprite.frame = 0                      # sostiene la pose de desvío (1er frame)
		if parry_t <= 0.0:
			sprite.modulate = Color(1, 1, 1, 1)   # sale de la postura: color normal
			sprite.play("pose")
		return   # quieto durante la ventana de parry

	# noqueado: si está EN EL AIRE, deja que CAIGA y aterrice tendido (el aterrizaje lo
	# pone en "ko"); ya en el SUELO queda tendido y no responde a nada.
	if koed and not airborne and not hit_flying:
		return

	# juggle aereo del ULTRA: se queda flotando donde lo pusieron (sin gravedad
	# ni pegarse al piso); el ultra controla su pose y posicion desde main.gd
	if ultra_hover:
		return

	# combo →+Q (encadena punch2): SOLO DAM y SOLO cuando punch2 sea arte v2 de video.
	# Con el punch2 VIEJO del sheet (6 frames) el corte a mitad del windup del punch v2
	# (48 frames) se veia "extraño y sin golpe" (pedido): mientras tanto →Q = UN corte
	# limpio. Al llegar punch2.mp4 (corte de REVES, prompt en GOLPES v2) esto revive solo:
	# encadena tras la EXTENSION del tajo (frame 20), no en el windup.
	# ROUM (warrior) NO encadena punch2: no tiene ese clip (es la POSE placeholder), así que →Q
	# saltaba a la pose en el frame 20 = GLITCH sin golpe. Su →Q = UN puñetazo limpio y completo.
	if punch_followup and not fx_floral and not fx_blue and archetype != "warrior" and sprite.animation == "punch" \
			and sprite.sprite_frames.get_frame_count("punch2") > 8 and sprite.frame >= 20:
		punch_followup = false
		sprite.play("punch2")

	# patada giratoria: viaja hacia adelante y se eleva un poco mientras gira.
	# Fe NUEVA (85 frames de video): gira con los PIES EN EL PISO — sin hover (el clip ya
	# trae el molinillo completo); solo viaja durante el giro real (frames 16-64).
	if sprite.animation == "spin_kick" and sprite.is_playing() and not airborne:
		var sp_nueva: bool = fx_blue and sprite.sprite_frames.get_frame_count("spin_kick") > 12
		var dam_torbellino: bool = not fx_blue and not fx_floral \
				and sprite.sprite_frames.get_frame_count("spin_kick") > 12
		if dam_torbellino:
			pass   # TORBELLINO v2 (pedido): gira EN EL SITIO — sin avance ni hover
		elif fx_floral:
			pass   # AYE-2: el E (orb_e) es un LANZAMIENTO parado — NO viaja ni flota
		elif sp_nueva:
			if sprite.frame >= 16 and sprite.frame <= 64:
				position.x += facing * SPIN_TRAVEL * delta
		else:
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
		# ZETMA: su clip de salto TERMINA en la pose de guardia (frames ~113+). Si el anim la
		# alcanza aún en el aire (airtime largo o re-salto), se ve "saltando en su pose". Cap al
		# frame de DESCENSO: nunca muestra la guardia hasta ATERRIZAR de verdad.
		if fx_dark and String(sprite.animation) == "jump" and int(sprite.frame) > 100:
			sprite.frame = 100
		# ROUM: su clip de jump hace el TUCK/crouch de aterrizaje en f89-113 -> se veía AGACHADO en el
		# aire antes de caer (#540). Cap al APEX extendido (f81): mantiene la pose aérea hasta ATERRIZAR.
		if fx_warrior and String(sprite.animation) == "jump" and int(sprite.frame) > 81:
			sprite.frame = 81
		# MUERTE AÉREA: sube con la pose de vuelo (el "vuelo por los aires"); en cuanto
		# EMPIEZA A BAJAR, pasa a BOCA ABAJO (ko_air) para caer y estrellarse de bruces.
		# KO AÉREO (pedido final): el VUELO entero usa hit_fly (el que se ve bien); el
		# clip ko-fly solo pone el CHOQUE y el tendido AL TOCAR el piso (aterrizaje)
		if koed and ko_facedown and String(sprite.animation) != "hit_fly" \
				and String(sprite.animation) != "ko_air" \
				and sprite.sprite_frames.has_animation("hit_fly"):
			sprite.play("hit_fly")
		# ROUM: mientras VUELA (juggle/KO aéreo) NO congelar el tendido plano; la pose sigue el ARCO
		# -> ARQUEADO al SUBIR (vel_y<0), horizontal al CAER (vel_y>0), nunca el tendido (f100+). Pedido.
		if String(sprite.animation) == "hit_fly" and hit_flying and sprite.sprite_frames.get_frame_count("hit_fly") > 100:
			var _hfc: int = sprite.sprite_frames.get_frame_count("hit_fly")
			var _arc: float = clampf(inverse_lerp(-1000.0, 800.0, vel_y), 0.0, 1.0)
			sprite.frame = clampi(int(lerpf(32.0, 86.0, _arc)), 0, _hfc - 1)
			sprite.speed_scale = 0.0
		var air_spin: bool = sprite.animation in ["spin_kick", "air_spin_kick"] and sprite.is_playing()
		# TODOS los ataques aéreos flotan: mientras golpeas en el aire, bajas
		# poco a poco (feel de combo aéreo de fighting game), no caes en picada.
		var air_atk: bool = air_spin or (sprite.animation in ["jump_punch", "jump_kick", "jump_kick_cast", "air_jab"] and sprite.is_playing())
		# jump_kick_cast (salto+E de Aye): mientras GIRA el báculo cae SUAVE (flota) SIEMPRE, para dar
		# tiempo a que se vea el giro completo (no depende de conectar ni de air_move_used).
		var jkc_spin: bool = fx_floral and String(sprite.animation) == "jump_kick_cast" and sprite.is_playing()
		# DAM ↑W: FLOTA mientras DESCARGA el tajo — la animación completa no cabía en la caída
		# normal (el aterrizaje la cortaba y "solo se veía subir la espada"). Pedido del usuario:
		# que no caiga tanto para que la animación original se vea entera. Al terminar, cae normal.
		var dam_jk: bool = not fx_blue and not fx_floral and not fx_dark and not fx_warrior and String(sprite.animation) == "jump_kick" and sprite.is_playing()   # ROUM NO flota (heredaba el hover del ↑W de DAM = se quedaba en el aire)
		var grab_hover: bool = fx_dark and String(sprite.animation) == "air_grab"
		if grab_hover:
			vel_y = 0.0   # ZETMA air_grab: FLOTA EN EL SITIO hasta terminar (no cae NI se desplaza)
			vel_x = 0.0
		position.y += vel_y * delta
		# FLOTA solo si el golpe aéreo CONECTÓ (juggle) Y aún NO gastaste tu siguiente golpe. En cuanto
		# tiras el próximo golpe (air_move_used) y NO conecta, deja de flotar y CAE NORMAL (no "cae lento").
		var floating: bool = (air_atk and air_float_t > 0.0 and not air_move_used) or jkc_spin or dam_jk
		var g_mult := (0.30 if dam_jk else (0.20 if jkc_spin else 0.35)) if floating else 1.0
		# caida BRUSCA del remate del ULTRA: al pasar el ápice se desploma
		if hard_fall and hit_flying and vel_y > 0.0:
			g_mult = 2.6
		# lanzado normal: una vez que YA va cayendo, cae más rápido (menos flote)…
		# …SALVO en pleno juggle (sostén tras rebote): ahí cae LENTO para que el
		# siguiente golpe del combo aéreo la alcance (estilo pro)
		elif hit_flying and vel_y > 0.0:
			g_mult = 0.85 if juggle_hold_t > 0.0 else 1.7
		# saltos PROPIOS de TODOS (no lanzados, no flotando): gravedad 1.5x — más secos
		# y rápidos; la altura se conserva porque JUMP_SPEED subió en proporción (v²/2g)
		elif not hit_flying and not floating:
			g_mult = 1.5
		if not grab_hover:
			vel_y += GRAVITY * g_mult * delta
		# TECHO: no dejar que suba tanto que se salga por arriba (el remate del ultra lanza
		# altísimo). Topa a ~520px sobre el piso y de ahí empieza a caer.
		if position.y < floor_y - 520.0:
			position.y = floor_y - 520.0
			if vel_y < 0.0:
				vel_y = 0.0
		if air_atk:
			if dam_jk:
				# ↑W de DAM = SALTO CORTO HACIA ADELANTE (flecha del usuario): mientras
				# descarga el tajo, avanza en arco y aterriza adelante
				position.x += facing * 300.0 * CHAR_SCALE * delta
			if floating:
				vel_y = minf(vel_y, (190.0 if (jkc_spin or dam_jk) else 300.0) * CHAR_SCALE)   # descenso lento (más suave en jkc / tajo de DAM)
			if air_spin and not fx_floral:
				position.x += facing * SPIN_TRAVEL * 0.8 * delta   # aye2: sus aéreos son LANZAMIENTOS parados, no viajan
		elif hit_flying:
			position.x += vel_x * delta
			# ESQUINA (estilo Marvel/anime): al llegar al borde NO rebota ni juega wall_splat. Se PEGA a la
			# pared y su impulso HORIZONTAL se convierte en VERTICAL -> SUBE por la pared (juggle de esquina).
			# Usa su pose de vuelo (hit_fly), sin animacion de pared.
			if (position.x <= 115.0 and vel_x < 0.0) or (position.x >= 1805.0 and vel_x > 0.0):
				var into_wall := absf(vel_x)
				vel_x = 0.0
				# solo convierte a VERTICAL si aún SUBE; si ya viene cayendo, la pared solo
				# lo frena y cae recto (sin pop hacia arriba = sin "rebote")
				if vel_y < 0.0:
					vel_y = minf(vel_y, -maxf(into_wall * 0.85, 340.0 * CHAR_SCALE))
			position.x = clampf(position.x, 115.0, 1805.0)
		elif _es_humano() and not grab_hover:
			var air_dir := Input.get_axis(act("ui_left"), act("ui_right"))
			if air_dir != 0.0:
				position.x += air_dir * WALK_SPEED * (1.30 if rage_mode else 1.0) * (SLOW_FACTOR if slow_t > 0.0 else 1.0) * spd * delta
		if position.y >= floor_y and vel_y >= 0.0:   # solo aterriza si NO va subiendo
			# REBOTE contra el suelo (E de ROUM): al TOCAR el piso rebota ARRIBA una vez y sigue volando
			# (sube y vuelve a caer), en vez de aterrizar. Se consume el flag -> la 2ª caída SÍ aterriza.
			if floor_bounce_pending and not koed:
				floor_bounce_pending = false
				position.y = floor_y
				vel_y = -maxf(900.0 * CHAR_SCALE, absf(vel_y) * 0.55)   # rebota HACIA ARRIBA (más chico que el impacto)
				vel_x *= 0.6                                           # pierde algo de empuje horizontal
				juggle_hold_t = 0.4
				_spawn_slam_dust(signi(int(vel_x)) if int(vel_x) != 0 else -facing, 0.9)   # polvo del rebote
				if sprite.sprite_frames.has_animation("hit_fly"):
					sprite.play("hit_fly")
				return   # rebota y sigue en el aire (no aterriza)
			position.y = floor_y
			airborne = false
			vel_y = 0.0
			sprite.speed_scale = 1.0   # ROUM hit_fly congelaba speed_scale=0: restaurar al caer
			air_move_used = false   # tocó el piso: puede volver a atacar en el aire
			water_bg = false   # tocó el suelo: dejan de salir las sombras azules
			if koed:
				# cayó noqueado desde el aire: queda TENDIDO
				var sdk := signi(int(vel_x))   # hacia dónde venía deslizando (antes de frenar)
				vel_x = 0.0
				hit_flying = false
				hard_fall = false
				_spawn_slam_dust(sdk if sdk != 0 else -facing, 1.0)   # AZOTE: cuña barrida
				if (fx_floral or fx_dark) and sprite.sprite_frames.has_animation("hit_down"):
					# AYE: completa su caída normal (hit_down) y queda TENDIDA BOCA ARRIBA
					# tal como termina esa anim (koed bloquea el get_up)
					sprite.play("hit_down")
					return
				if ko_facedown and sprite.sprite_frames.has_animation("ko_air"):
					# v2 (clip 103f): venía VOLANDO con hit_fly; al tocar el suelo arranca
					# el CHOQUE del ko-fly (#73) y el estrellón/rebote se ANIMA en el piso
					var _kac := sprite.sprite_frames.get_frame_count("ko_air")
					sprite.speed_scale = 1.0
					sprite.play("ko_air")
					sprite.frame = (73 if _kac > 100 else maxi(0, _kac - 1))
				else:
					sprite.play("ko")        # boca arriba (caída de espaldas)
					sprite.frame = maxi(0, sprite.sprite_frames.get_frame_count("ko") - 1)
				return
			if hit_flying:
				var sdh := signi(int(vel_x))   # hacia dónde venía deslizando
				hit_flying = false
				vel_x = 0.0
				if hard_fall:
					hard_fall = false
					wall_squash_t = SQUASH_DUR
					squash_horizontal = false   # cae al piso: comprime el alto
					_burst(1.3)
					_play_sfx_key("wall_bounce")
				# estrellón: AZOTE con la cuña barrida (los escombros son solo de PARED)
				_spawn_slam_dust(sdh if sdh != 0 else -facing)
				sprite.play("hit_down")  # se estrella y se levanta
			else:
				_spawn_jump_dust(0.6)   # aterrizaje de salto: polvito
				# amortigua con las rodillas (land) y se recupera — cualquier personaje con la anim
				if sprite.sprite_frames.has_animation("land"):
					sprite.play("land")
				else:
					sprite.play("pose")
		return

	# estrellandose / levantandose: no responde
	if sprite.animation == "hit_down" and sprite.is_playing():
		return

	# celebrando: quieto hasta que se le ordene volver
	if sprite.animation == "victory":
		return

	# EMPUJÓN de ROUM (shove_t): mientras lo están empujando NO camina ni actúa (ni IA ni humano).
	# Antes la IA caminaba de vuelta hacia ROUM y TAPABA el deslizamiento (por eso "en un facing no
	# empujaba"): el slide se aplicaba arriba pero el walk de la IA lo pisaba. Con esto el empujón se VE.
	if shove_t > 0.0:
		return

	if not _es_humano():
		_ai_process(delta)
		return
	if not input_enabled:
		return

	# buffer de entrada: el boton guardado sale apenas se abre la ventana
	if buffer_t > 0.0:
		buffer_t -= delta
		if _try_attack(buffer_action, buffer_air):
			buffer_t = 0.0

	# jump-cancel del lanzador: tras conectar el gancho puedes saltar de una
	# ZETMA además JUMP-CANCEL cualquiera de sus normales (R/Q/W/E) tras el frame de impacto ->
	# encadena combo aéreo (normal -> salto -> golpe aéreo -> air grab). Antes E (tope de la
	# escalera R→Q→W→E) cortaba el combo y era casi imposible encadenar con él.
	var _jc_dam: bool = sprite.animation == "crouch_kick" and sprite.frame > 2
	var _jc_zetma: bool = fx_dark and String(sprite.animation) in ["weak_punch", "punch", "kick", "spin_kick"] \
			and sprite.frame > _hit_frame_de(String(sprite.animation))
	if Input.is_action_just_pressed(act("ui_up")) and not airborne and (_jc_dam or _jc_zetma):
		airborne = true
		crouching = false
		vel_y = -JUMP_SPEED * jump_mult
		_spawn_jump_dust(0.6)   # polvo de despegue
		sprite.play("jump")
		# ZETMA: igual que el salto normal — saltar al DESPEGUE/tuck (frame 50), no mostrar los
		# ~50 frames de agacharse del clip mientras ya está en el aire (bug del jump-cancel).
		if fx_dark and sprite.sprite_frames.get_frame_count("jump") > 100:
			sprite.frame = 50
		return

	# DASH DE AGUJAS de Fe en curso: bloquea locomoción/salto/agacharse para que "walk"
	# NO pise la animación "dash" (el jugador mantiene ADELANTE durante el comando ←→+Q)
	if fe_dash_active or special_t > 0.0:
		return

	# ocupado: golpeando, recibiendo dano o bloqueando
	if sprite.animation in ["punch", "punch2", "kick", "spin_kick", "air_spin_kick", "weak_punch", "crouch_punch", "crouch_jab", "crouch_kick", "sweep", "take_hit", "take_hit_low", "block", "block_low", "water_cast", "crystal_cast"] \
			and sprite.is_playing():
		return

	# ---- AYE (wizard): CANALEO DE MANA (doble-tap ABAJO) — recarga rapido pero VULNERABLE ----
	if down_tap_win > 0.0:
		down_tap_win -= delta
	if channeling:
		var chmv := Input.get_axis(act("ui_left"), act("ui_right"))
		var ch_atk := Input.is_action_just_pressed(act("attack")) or Input.is_action_just_pressed(act("kick")) \
			or Input.is_action_just_pressed(act("spin_kick")) or Input.is_action_just_pressed(act("weak_punch"))
		if airborne or chmv != 0.0 or Input.is_action_just_pressed(act("ui_up")) or ch_atk:
			_stop_channel()   # mover/saltar/atacar CANCELA (cae al proceso normal este frame)
		else:
			var can := _channel_anim()
			if sprite.animation != can or not sprite.is_playing():
				sprite.play(can)
			_cast_border_on(0.25)   # mantiene el aura MORADA mientras canaliza
			return
	# ENTRAR al canaleo: doble toque ABAJO, solo magos, en el suelo y en neutro (sin izq/der)
	if fx_floral and not airborne and Input.is_action_just_pressed(act("ui_down")):
		if down_tap_win > 0.0 and Input.get_axis(act("ui_left"), act("ui_right")) == 0.0:
			_start_channel()
			return
		down_tap_win = 0.28
	# salto
	if Input.is_action_just_pressed(act("ui_up")) and not crouching:
		airborne = true
		vel_y = -JUMP_SPEED * jump_mult
		_spawn_jump_dust(1.05 if fx_warrior else 0.6)   # polvo de despegue (ROUM tanque: ráfaga MÁS grande y visible)
		# MORTAL de Fe (clip v2): saltar HACIA ADELANTE hace el flip. Los golpes aéreos
		# lo CANCELAN de una (neutral_spin no es golpe: no está en la lista de bloqueo,
		# así que _try_attack pisa la anim al instante). Neutro/atrás y demás: jump limpio.
		var _dirj := Input.get_axis(act("ui_left"), act("ui_right"))
		if fx_blue and _dirj != 0.0 and signi(int(_dirj)) == facing \
				and sprite.sprite_frames.has_animation("neutral_spin") \
				and sprite.sprite_frames.get_frame_count("neutral_spin") > 8:
			sprite.play("neutral_spin")
		else:
			sprite.play("jump")
			# ZETMA: su clip de salto trae ~50 frames de AGACHARSE antes del despegue; la
			# física ya despegó, así que arranca en el DESPEGUE/tuck (recoge los pies al
			# instante, como pediste) en vez de mostrar la preparación agachada en el aire.
			if fx_dark and sprite.sprite_frames.get_frame_count("jump") > 100:
				sprite.frame = 50
		return

	# AYE: deja que el ATERRIZAJE (land, flexión) se VEA — no lo cortes con caminar/idle mientras juega
	# (dura poco). El salto (arriba, ya chequeado) y los ataques (por _try_attack) SÍ lo pueden cancelar.
	if sprite.animation in ["land", "get_up"] and sprite.is_playing():
		return

	# agacharse: mantener abajo; al soltar se levanta en reversa
	var down_held := Input.is_action_pressed(act("ui_down"))
	if down_held and not crouching:
		crouching = true
		if fx_floral:
			sprite.speed_scale = 1.0   # AYE-2: agacharse a velocidad normal
		sprite.play("crouch")
	elif not down_held and crouching:
		crouching = false
		# ZETMA tiene un LEVANTARSE real (crouch_up); los demás lo hacen con la reversa
		if sprite.sprite_frames.has_animation("crouch_up") and sprite.sprite_frames.get_frame_count("crouch_up") > 1:
			sprite.play("crouch_up")
		else:
			# AYE-2: el levantarse-de-agachado va un poco MÁS rápido que agacharse (pedido).
			# speed_scale se restaura a 1.0 en _on_animation_changed al salir del crouch.
			if fx_floral:
				sprite.speed_scale = 1.5
			sprite.play_backwards("crouch")
	if crouching:
		return
	if sprite.animation in ["crouch", "crouch_up"] and sprite.is_playing():
		return  # agachándose o levantándose

	# PASO CORTO (doble-tap ←←/→→ de Fe y DAM): desliza con decaimiento y vuelve a guardia
	if step_t > 0.0:
		step_t = maxf(0.0, step_t - delta)
		position.x += step_vx * delta * (0.35 + 0.8 * step_t / STEP_DUR)
		if step_t <= 0.0:
			# el brinco de step/backdash ATERRIZA completo: si la anim sigue corriendo se
			# respeta (al terminar, _on_animation_finished la manda a pose); si ya quedo
			# congelada (placeholder walk) o termino antes que el deslizamiento -> pose ya
			var _sa := String(sprite.animation)
			if _is_locomotion_anim() or (_sa in ["step", "backdash"] and not sprite.is_playing()):
				sprite.play("pose")
		return
	# caminar: hacia el rival = avance, alejandose = retroceso en reversa
	var dir := Input.get_axis(act("ui_left"), act("ui_right"))
	if dir != 0.0:
		var forward := signi(int(dir)) == facing
		position.x += dir * (WALK_SPEED if forward else WALK_BACK_SPEED) * (1.30 if rage_mode else 1.0) * (1.7 if orb_haste_t > 0.0 else 1.0) * (SLOW_FACTOR if slow_t > 0.0 else 1.0) * spd * delta
		var want := 1 if forward else -1
		if walk_dir != want or not _is_locomotion_anim():
			_play_locomotion(forward)
		walk_dir = want
	else:
		walk_dir = 0
		if _is_locomotion_anim():
			sprite.play("pose")

# ¿está en una animación de locomoción? (walk adelante o walk_back atrás)
func _is_locomotion_anim() -> bool:
	return sprite.animation == "walk" or sprite.animation == "walk_back"

# reproduce la locomoción correcta: walk hacia adelante; al retroceder usa walk_back (animación
# PROPIA de back-pedal) si existe, si no cae al walk invertido (comportamiento anterior).
func _play_locomotion(forward: bool) -> void:
	if forward:
		sprite.play("walk")
	elif sprite.sprite_frames.has_animation("walk_back"):
		sprite.play("walk_back")
	else:
		sprite.play_backwards("walk")

func _ai_process(delta: float) -> void:
	# special_t: no camina/ataca durante un especial NI durante el casteo del berserk
	if not ai_enabled or koed or ai_target == null or airborne or special_t > 0.0:
		return
	# combo en curso: encadena el siguiente golpe al abrirse la ventana de cancel
	if ai_combo.size() > 0:
		var anim := String(sprite.animation)
		if anim in ["take_hit", "take_hit_low", "block", "block_low", "hit_down"]:
			ai_combo.clear()  # se lo interrumpieron
		elif anim in ATTACKS and sprite.is_playing():
			if sprite.frame > _hit_frame_de(anim):
				sprite.play(ai_combo.pop_front())
			return
		else:
			sprite.play(ai_combo.pop_front())
			return
	if sprite.animation in ["punch", "punch2", "kick", "spin_kick", "air_spin_kick", "weak_punch", "crouch_punch", "crouch_jab", "crouch_kick", "sweep", "jump_punch", "jump_kick", "jump_kick_cast", "take_hit", "take_hit_low", "block", "block_low", "hit_down", "ko", "victory", "crouch", "electrocuted"] \
			and sprite.is_playing():
		return
	var dist := absf(ai_target.position.x - position.x)
	ai_timer -= delta
	if ai_timer <= 0.0:
		ai_timer = randf_range(0.28, 0.6)   # decide más seguido (más agresiva)
		var r := randf()
		if ai_break_drill:
			# DRILL de BREAK: persigue y encadena combos casi siempre (para practicar romper)
			if dist > 430.0 * CHAR_SCALE:
				ai_action = "advance"
			else:
				ai_action = "combo_start" if r < 0.8 else "punch"
		elif dist > 620.0 * CHAR_SCALE:
			ai_action = "advance" if r < 0.92 else "idle"   # persigue casi siempre
		elif dist > 430.0 * CHAR_SCALE:
			if r < 0.50: ai_action = "advance"               # cierra distancia agresivo
			elif r < 0.66: ai_action = "kick"
			elif r < 0.78: ai_action = "spin_kick"
			elif r < 0.90: ai_action = "crouch_kick"
			elif r < 0.96: ai_action = "retreat"             # poco retreat/idle
			else: ai_action = "idle"
		else:
			if r < 0.42: ai_action = "combo_start"           # MUCHOS combos de cerca
			elif r < 0.57: ai_action = "weak_punch"
			elif r < 0.71: ai_action = "punch"
			elif r < 0.83: ai_action = "kick"
			elif r < 0.93: ai_action = "crouch_punch"
			elif r < 0.97: ai_action = "retreat"             # casi nunca retrocede/espera
			else: ai_action = "idle"
	match ai_action:
		"advance":
			position.x += facing * WALK_SPEED * 0.95 * (1.30 if rage_mode else 1.0) * (SLOW_FACTOR if slow_t > 0.0 else 1.0) * spd * delta   # persigue más rápido
			if sprite.animation != "walk" or walk_dir != 1:
				sprite.play("walk")
			walk_dir = 1
		"retreat":
			position.x -= facing * WALK_BACK_SPEED * 0.75 * spd * delta
			if walk_dir != -1 or not _is_locomotion_anim():
				_play_locomotion(false)
			walk_dir = -1
		"punch", "kick", "spin_kick", "crouch_punch", "crouch_kick":
			walk_dir = 0
			if fx_floral and ai_action == "spin_kick":
				ai_action = "sweep"   # AYE no tiene spin_kick propio (saldría DAM): usa sus púas
			if ai_action == "punch":
				punch_followup = randf() < 0.55  # encadena el doble más seguido
			sprite.play(ai_action)
			ai_action = "idle"
			ai_timer = randf_range(0.35, 0.7)   # vuelve a atacar antes
		"combo_start":
			walk_dir = 0
			ai_combo = AI_COMBOS[randi() % AI_COMBOS.size()].duplicate()
			if fx_floral:
				for k in ai_combo.size():
					if ai_combo[k] == "spin_kick":
						ai_combo[k] = "sweep"   # AYE: sin spin_kick propio (saldría DAM)
			sprite.play(ai_combo.pop_front())
			ai_action = "idle"
			ai_timer = randf_range(0.6, 1.0)   # presiona con el próximo combo antes
		_:
			walk_dir = 0
			if _is_locomotion_anim():
				sprite.play("pose")

func _unhandled_input(event: InputEvent) -> void:
	if not _es_humano() or not input_enabled:
		return
	# tecla de prueba U: celebracion de victoria / volver a guardia
	if debug_keys and event.is_action_pressed("victory_test") and not airborne and not koed:
		crouching = false
		if sprite.animation == "victory":
			sprite.play("pose")
		else:
			celebrate()   # incluye la frase de victoria
		return
	# tecla de prueba Y: cae noqueado / revivir
	if debug_keys and event.is_action_pressed("ko_test") and not airborne:
		koed = not koed
		crouching = false
		sprite.play("ko" if koed else "pose")
		return
	# tecla de prueba I: KO VOLANDO — lanzado por los aires y muere en pleno vuelo
	# (vuelo hit_fly subiendo -> ko_air bajando boca abajo -> se estrella y queda tendido)
	if debug_keys and event.is_action_pressed("ko_fly_test") and not airborne and not koed:
		receive_hit(false, true, -facing)   # lanzador
		die_ko()                            # muere EN EL AIRE -> completa el arco
		return
	# doble toque ATRÁS/ADELANTE: Aye = BLINK (teleport, maná); Fe y DAM = PASO CORTO
	# (←← backdash / →→ paso adelante, estilo Street Fighter).
	# ROUM (warrior/TANQUE) NO tiene dash: solo asesinos (DAM/Fe/Zetma) y magos (Aye=blink) lo tienen.
	if archetype != "warrior" and (event.is_action_pressed(act("ui_left")) or event.is_action_pressed(act("ui_right"))):
		var _bd := -1 if event.is_action_pressed(act("ui_left")) else 1
		if airborne or koed:
			back_tap_win = 0.0
			fwd_tap_win = 0.0
		elif _bd == -facing:
			fwd_tap_win = 0.0   # cambiar de dirección rompe la secuencia contraria
			if back_tap_win > 0.0:
				back_tap_win = 0.0
				if fx_floral:
					_start_blink(false)
				else:
					_start_quick_step(false)
				return
			back_tap_win = 0.28
		else:
			back_tap_win = 0.0
			if fwd_tap_win > 0.0:
				fwd_tap_win = 0.0
				if fx_floral:
					_start_blink(true)
				else:
					_start_quick_step(true)
				return
			fwd_tap_win = 0.28
	# doble toque ↑: habilita el breaker con movimiento (↑↑+E)
	if event.is_action_pressed(act("ui_up")):
		if up_tap_t > 0.0:
			double_up_t = 0.3
		up_tap_t = 0.35
	# doble toque ↓: habilita el INFIERNO (↓↓+E)
	if event.is_action_pressed(act("ui_down")):
		if down_tap_t > 0.0:
			double_down_t = 0.35
		down_tap_t = 0.4
	# doble toque ATRÁS (← ←): habilita el VOID LASH de ROUM (←←→ + W)
	var _btap := 0
	if event.is_action_pressed(act("ui_left")): _btap = -1
	elif event.is_action_pressed(act("ui_right")): _btap = 1
	if _btap != 0 and _btap == -facing:   # el press fue hacia ATRÁS (lejos del rival)
		if back_tap_t > 0.0:
			double_back_t = 0.4
		back_tap_t = 0.4
	if _btap != 0 and _btap == facing:    # el press fue hacia ADELANTE (hacia el rival): →→ del UPPERCUT
		if fwd_tap_t > 0.0:
			double_fwd_t = 0.4
		fwd_tap_t = 0.4
	# DEFENSA mientras te COMBEAN (te están pegando): PARRY (estándar) o COMBO BREAK (por personaje)
	var _combeado := not koed and (hit_flying \
		or (String(sprite.animation) in ["take_hit", "take_hit_low"] and sprite.is_playing()))
	if _combeado:
		var _e := event.is_action_pressed(act("spin_kick"))
		var _fwd := int(signf(Input.get_axis(act("ui_left"), act("ui_right"))))
		var _down := Input.is_action_pressed(act("ui_down")) or down_recent_t > 0.0
		var _mbp := get_parent()
		# COMBO BREAK (POR PERSONAJE): Fe = ↓→+E (spin) · DAM = ↑+E (o S de respaldo)
		var quiere_break := false
		if fx_blue:
			quiere_break = _e and _down and _fwd == facing          # Fe: ↓→+E
		elif fx_floral:
			quiere_break = event.is_action_pressed(act("weak_punch")) and double_up_t > 0.0   # Aye: ↑↑R
		elif fx_dark:
			quiere_break = _e and back_recent_t > 0.0 and _fwd == facing   # ZETMA: ←→+E (atrás→adelante) · rompe con su patada
		else:
			quiere_break = event.is_action_pressed(act("combo_break")) \
				or (_e and up_tap_t > 0.0)                          # DAM: ↑+E / S
		if quiere_break:
			# LÍMITE: solo se puede romper en los primeros 4 golpes del combo
			if _mbp and _mbp.has_method("combo_hits_on") and _mbp.combo_hits_on(self) > 4:
				return
			if _mbp and _mbp.has_method("meter_can_break") and not _mbp.meter_can_break(self):
				return
			if do_breaker():
				if _mbp and _mbp.has_method("on_breaker"):
					_mbp.on_breaker(self)
			return
	if event.is_action_pressed(act("combo_break")):
		return
	if koed or is_downed():
		return
	# marca el TAP reciente de Q y de W (para exigir que el parry sea con las dos SIMULTÁNEAS)
	if event.is_action_pressed(act("attack")):
		pq_tap_t = PARRY_SIMUL
	if event.is_action_pressed(act("kick")):
		pw_tap_t = PARRY_SIMUL
	# PARRY (Q+W A LA VEZ, estándar todos): entra en POSE de counter con borde ~0.5s. Si te pegan en
	# esa ventana → contraataque (3 golpes). Gasta 1 barra. Solo parado en el piso.
	# CLAVE: exige que Q y W se pulsen CASI A LA VEZ (dentro de PARRY_SIMUL). Mantener una y DESPUÉS
	# tocar la otra ya NO activa (la vieja expiró su ventana), aunque las dos queden apretadas.
	if not airborne and parry_t <= 0.0 \
			and Input.is_action_pressed(act("attack")) and Input.is_action_pressed(act("kick")) \
			and ((event.is_action_pressed(act("attack")) and pw_tap_t > 0.0) \
				or (event.is_action_pressed(act("kick")) and pq_tap_t > 0.0)):
		var _mbq := get_parent()
		if _mbq and _mbq.has_method("meter_can_parry") and _mbq.meter_can_parry(self):
			if do_parry():
				if _mbq.has_method("on_parry_start"):
					_mbq.on_parry_start(self)
				return
	# RABIA de DAM (E+R A LA VEZ, con el anillo LLENO): castea el berserk. Misma regla de
	# simultaneidad que el parry — mantener una y luego tocar la otra NO activa.
	if event.is_action_pressed(act("spin_kick")):
		pe_tap_t = PARRY_SIMUL
	if event.is_action_pressed(act("weak_punch")):
		pr_tap_t = PARRY_SIMUL
	if not airborne and not rage_mode \
			and Input.is_action_pressed(act("spin_kick")) and Input.is_action_pressed(act("weak_punch")) \
			and ((event.is_action_pressed(act("spin_kick")) and pr_tap_t > 0.0) \
				or (event.is_action_pressed(act("weak_punch")) and pe_tap_t > 0.0)):
		var _mbr := get_parent()
		if _mbr and _mbr.has_method("try_rage") and _mbr.try_rage(self):
			return
	# teclas de prueba de dano sobre uno mismo (E/R/T); el golpe llega de frente
	if debug_keys and event.is_action_pressed("take_hit") and not airborne:
		receive_hit(false, false, -facing)
		return
	if debug_keys and event.is_action_pressed("take_hit_low") and not airborne:
		crouching = true
		receive_hit(true, false, -facing)
		return
	if debug_keys and event.is_action_pressed("take_hit_strong") and not airborne:
		receive_hit(false, true, -facing)
		return
	# ZETMA ESPECIAL (↓←+E, cuarto ATRÁS + E): dispara la ORB de cámara lenta si está CARGADA (1/round)
	if fx_dark and not airborne and event.is_action_pressed(act("spin_kick")) and down_recent_t > 0.0:
		var _obd := Input.get_axis(act("ui_left"), act("ui_right"))
		if _obd != 0.0 and int(signf(_obd)) == -facing:
			var mob := get_parent()
			if mob and mob.has_method("_zetma_orb_special") and mob._zetma_orb_special(self):
				return
	# ROUM (warrior): ←←→ + W (dos atrás, adelante, W) = VOID LASH (súper de vendas a pantalla, ½ barra)
	if archetype == "warrior" and not airborne and event.is_action_pressed(act("kick")) and double_back_t > 0.0:
		var _vfd := Input.get_axis(act("ui_left"), act("ui_right"))
		if _vfd != 0.0 and int(signf(_vfd)) == facing:   # ADELANTE al apretar W
			var mvl := get_parent()
			if mvl and mvl.has_method("_roum_void_cast") and mvl._roum_void_cast(self):
				return
	# ROUM (warrior): ULTRA DE PORTALES = MANTENER R apretado ~½s y SOLTARLO (2 barras + combo vivo).
	# Al apretar R sale su empujón normal; si lo mantenés medio segundo y lo soltás, dispara el ultra.
	if archetype == "warrior" and event.is_action_pressed(act("weak_punch")):
		_r_press_ms = Time.get_ticks_msec()
	if archetype == "warrior" and not airborne and event.is_action_released(act("weak_punch")):
		var _held := Time.get_ticks_msec() - _r_press_ms
		_r_press_ms = 0
		if _held >= 450:
			var mpu := get_parent()
			if mpu and mpu.has_method("try_roum_portal_ultra") and mpu.try_roum_portal_ultra(self):
				return
	# ROUM (warrior): → → + Q (dos adelante, Q) = UPPERCUT (lanzador). Mismo esquema que el ←←→ del void lash.
	if archetype == "warrior" and not airborne and event.is_action_pressed(act("attack")) and double_fwd_t > 0.0 \
			and sprite.sprite_frames.has_animation("uppercut"):
		crouching = false
		double_fwd_t = 0.0
		sprite.play("uppercut")
		return
	if fx_floral:
		# --- AYE: su SÚPER propio. NO hereda los ultras de fuego de DAM ni los de agua de Fe. ---
		# CRYSTAL FLURRY (↓←+Q): ráfaga del báculo tras 3 golpes (cuesta 1.5 barras).
		if event.is_action_pressed(act("attack")) and down_recent_t > 0.0 and back_recent_t > 0.0:
			var maf := get_parent()
			if maf and maf.has_method("try_crystal_flurry") and maf.try_crystal_flurry(self):
				return
	elif sprite.sprite_frames.has_animation("water_cast"):
		# --- FE: sus propios especiales/ultra. NO hereda los ultras de fuego de DAM. ---
		# WHIRLPOOL (↓←+E): finisher tras combo (cuesta 1 barra).
		if event.is_action_pressed(act("spin_kick")) and down_recent_t > 0.0 and back_recent_t > 0.0:
			var mw := get_parent()
			if mw and mw.has_method("try_whirlpool") and mw.try_whirlpool(self):
				return
		# ULTRA CORTO (↑+E): combo aéreo tras combo de 3 (cuesta 2 barras). El breaker ↑+E
		# se revisó antes y solo entra si te están pegando, así que el ofensivo queda libre.
		if event.is_action_pressed(act("spin_kick")) and up_tap_t > 0.0:
			var mfu := get_parent()
			if mfu and mfu.has_method("try_fe_ultra") and mfu.try_fe_ultra(self):
				return
		# ULTRA LARGO (↓→ + R = cuarto adelante + R): APOCALYPSE (3 barras + combo + rival rojo)
		if event.is_action_pressed(act("weak_punch")) and down_recent_t > 0.0:
			var _fd := Input.get_axis(act("ui_left"), act("ui_right"))
			if _fd != 0.0 and int(signf(_fd)) == facing:
				var mfl := get_parent()
				if mfl and mfl.has_method("try_fe_ultra_long") and mfl.try_fe_ultra_long(self):
					return
	elif fx_dark:
		# --- ZETMA: ultras con inputs PROPIOS. ANIQUILACIÓN = ↓→ R (cuarto ADELANTE); APOCALIPSIS = ↓← W (cuarto ATRÁS). ---
		if event.is_action_pressed(act("weak_punch")) and down_recent_t > 0.0:   # ↓→ R = ANIQUILACIÓN
			var _afd := Input.get_axis(act("ui_left"), act("ui_right"))
			if _afd != 0.0 and int(signf(_afd)) == facing:                        # ADELANTE al apretar R
				var mzu := get_parent()
				if mzu and mzu.has_method("try_ultra") and mzu.try_ultra(self):
					return
		if event.is_action_pressed(act("kick")) and down_recent_t > 0.0:          # ↓← W = APOCALIPSIS
			var _pfd := Input.get_axis(act("ui_left"), act("ui_right"))
			if _pfd != 0.0 and int(signf(_pfd)) == -facing:                       # ATRÁS al apretar W
				var mzu2 := get_parent()
				if mzu2 and mzu2.has_method("try_ultra") and mzu2.try_ultra(self, true):
					return
		# (↓↓ E QUITADO: casteaba el INFERNO de DAM por error — NO es de Zetma. Su súper es el
		#  VOID ORB en ↓←E, con input propio. Sin remate de fuego para Zetma.)
	elif archetype == "warrior":
		# --- ROUM: su ultra CORTO propio (NO hereda los finishers de fuego de DAM). ---
		# ANNIHILATION (→ Q = ADELANTE + Q): agarre-machaque de suelo. 2 barras + combo(2) + rival ≤25%.
		# (→→Q = UPPERCUT se revisa ANTES; esto es el → SIMPLE sostenido + Q. Si no hay condiciones,
		#  cae al punch normal de abajo — es un REMATE que solo entra con el rival en rojo.)
		if event.is_action_pressed(act("attack")):
			var _ud := Input.get_axis(act("ui_left"), act("ui_right"))
			if _ud != 0.0 and int(signf(_ud)) == facing:
				var mru := get_parent()
				if mru and mru.has_method("try_roum_ultra") and mru.try_roum_ultra(self):
					return
	else:
		# --- DAM: sus finishers de fuego ---
		# comando ANIQUILACIÓN: → R (adelante reciente + R)
		if event.is_action_pressed(act("weak_punch")) and fwd_recent_t > 0.0:
			var mu := get_parent()
			if mu and mu.has_method("try_ultra") and mu.try_ultra(self):
				return
		# comando INFIERNO (crítico de fuego): ↓↓ + E
		if event.is_action_pressed(act("spin_kick")) and double_down_t > 0.0:
			var mc := get_parent()
			if mc and mc.has_method("try_critical") and mc.try_critical(self):
				return
		# comando APOCALIPSIS: → E (version larga)
		if event.is_action_pressed(act("spin_kick")) and fwd_recent_t > 0.0:
			var mu2 := get_parent()
			if mu2 and mu2.has_method("try_ultra") and mu2.try_ultra(self, true):
				return
	var accion := ""
	for a in ["attack", "kick", "spin_kick", "weak_punch"]:
		if event.is_action_pressed(act(a)):
			accion = a
			break
	if accion == "":
		return
	# AYE: input TERRESTRE en el aire -> se GUARDA y sale al ATERRIZAR (el buffer no corre
	# mientras está en el aire: el físico aéreo retorna antes de procesarlo).
	# 1) Con ↓ SOSTENIDO (y sin dirección horizontal, para no comerse el ↓→Q aéreo) la
	#    intención es el movimiento de SUELO (↓Q/↓E): vale durante TODO el salto.
	# 2) Sin ↓: solo en la ventana pegada al piso (cayendo, últimos ~150px).
	if fx_floral and airborne and ( 			(Input.is_action_pressed(act("ui_down")) and Input.get_axis(act("ui_left"), act("ui_right")) == 0.0) 			or (vel_y > 0.0 and position.y > floor_y - 150.0)):
		buffer_action = accion
		buffer_t = 0.45
		buffer_air = false   # intención TERRESTRE deliberada de Aye: SÍ abre agachados al aterrizar
		return
	# UN solo golpe aéreo por salto (hasta CAER o hasta que CONECTE). Corta el spam
	# de golpes aéreos (y el sonido agudo repetido).
	if airborne and air_move_used:
		# EXCEPCIÓN (Aye): puede CANCELAR su jump_kick_cast con el TELEPORT (↓→Q) para SEGUIR el combo
		# aéreo. Cuesta 1 barra, así que no es spam. Cualquier otro golpe aéreo sigue bloqueado.
		var _adx := Input.get_axis(act("ui_left"), act("ui_right"))
		var tele_cancel: bool = fx_floral and accion == "attack" and down_recent_t > 0.0 \
			and String(sprite.animation) == "jump_kick_cast" \
			and _adx != 0.0 and int(signf(_adx)) == facing
		# EXCEPCIÓN (Aye): cancelar salto E <-> salto R DESPUÉS de que salgan los 3 bolts (jp_shots>=3),
		# para encadenar casteos aéreos (E recto -> R diagonal-abajo y viceversa).
		var cast_cancel: bool = fx_floral and jp_shots >= 3 and ( \
			(String(sprite.animation) == "jump_kick_cast" and accion == "weak_punch") or \
			(String(sprite.animation) == "air_jab" and accion == "spin_kick"))
		if not tele_cancel and not cast_cancel:
			return
	if _try_attack(accion):
		if airborne and String(sprite.animation) in AIR_MOVES:
			air_move_used = true
	else:
		# aun no se abre la ventana: se guarda y dispara solo en cuanto abra.
		# Si vino del AIRE, el replay al aterrizar NO puede abrir golpes agachados
		# ("salto + ↓R y sale el tigre" — pedido: los abajo SOLO con press en el suelo)
		buffer_action = accion
		buffer_t = 0.3
		buffer_air = airborne

# hit_frame REAL de una anim para las VENTANAS de cancel/encadenado: el global de
# ATTACKS corrido a donde de verdad pega el arte v2 de video (anims mucho mas largas
# que las viejas del sheet — sin esto el cancel abria ANTES de que el golpe se viera)
func _hit_frame_de(anim: String) -> int:
	var hf: int = int(ATTACKS[anim]["hit_frame"]) if ATTACKS.has(anim) else 0
	# ROUM (warrior): sus clips son de 145f con hit_frame REAL medido (deben coincidir con current_attack).
	# La ventana de cancel se abre CUANDO el golpe DE VERDAD conecta -> el Q pega y RECIÉN ahí encadena
	# a W (Q→W combo). Antes caía en el override de DAM (15/32) y cancelaba ANTES de pegar (whiff).
	if fx_warrior:
		match anim:
			"punch": return 82
			"kick": return 76
			"weak_punch": return 66
			"spin_kick": return 93
			"crouch_jab": return 40
			"crouch_punch": return 32
			"crouch_kick": return 110
			"sweep": return 78
			"jump_punch": return 42
			"jump_kick": return 68
			"air_jab": return 70
			"air_spin_kick": return 88
			_: return hf
	# DAM punch v2 (48 frames): el TAJO smear barre en los frames 12-16
	if not fx_blue and not fx_floral and anim == "punch" \
			and sprite.sprite_frames.get_frame_count("punch") > 8:
		hf = 15
	# DAM kick v3 (MACHETAZO, 51 frames): descarga en ~32
	if not fx_blue and not fx_floral and anim == "kick" \
			and sprite.sprite_frames.get_frame_count("kick") > 12:
		hf = 23 if fx_dark else 32
	# DAM spin_kick (TORBELLINO, 71 frames): 1er golpe en ~20 (cancel tras conectarlo)
	if not fx_blue and not fx_floral and anim == "spin_kick" \
			and sprite.sprite_frames.get_frame_count("spin_kick") > 12:
		hf = 11 if fx_dark else 20
	# DAM sweep v2 (barrido a ras, 62 frames): cruza en ~32
	if not fx_blue and not fx_floral and anim == "sweep" \
			and sprite.sprite_frames.get_frame_count("sweep") > 12:
		hf = 15 if fx_dark else 32
	# DAM crouch_jab v2 (estocada baja, 33 frames): extiende en ~21
	if not fx_blue and not fx_floral and anim == "crouch_jab" \
			and sprite.sprite_frames.get_frame_count("crouch_jab") > 8:
		hf = 10 if fx_dark else 21
	# DAM crouch_kick v2 (gancho ascendente, 74 frames): el corte sube en ~30
	if not fx_blue and not fx_floral and anim == "crouch_kick" \
			and sprite.sprite_frames.get_frame_count("crouch_kick") > 12:
		hf = 13 if fx_dark else 30
	# DAM crouch_punch v3 (estocada agachada, 62 frames): extiende en ~22
	if not fx_blue and not fx_floral and anim == "crouch_punch" \
			and sprite.sprite_frames.get_frame_count("crouch_punch") > 8:
		hf = 15 if fx_dark else 22
	# DAM weak_punch POGO (43 frames): la 1a patada extiende en 5
	if not fx_blue and not fx_floral and anim == "weak_punch" \
			and sprite.sprite_frames.get_frame_count("weak_punch") > 8:
		hf = 39 if fx_dark else 5
	return hf

# intenta ejecutar un boton de ataque respetando ventana, familia y escalera
func _try_attack(accion: String, desde_aire := false) -> bool:
	var anim_actual := String(sprite.animation)
	if channeling:
		_stop_channel()   # cualquier ataque CANCELA el canaleo (evita que la anim de carga vuelva)
	if special_t > 0.0 or fe_dash_active:
		return false  # ni el dash especial ni el dash de agujas se cancelan
	if anim_actual in ["take_hit", "take_hit_low", "block", "block_low", "water_cast", "crystal_cast"] and sprite.is_playing():
		return false
	if anim_actual in ATTACKS and sprite.is_playing():
		if sprite.frame <= _hit_frame_de(anim_actual):
			return false
		# AYE: ↓E (sweep, freeze) CANCELA a E parado (crystal_cast, proyectil) aunque compartan botón:
		# freeze + proyectil se leen como COMBO. Salta las reglas de familia/escalera SOLO en ese caso
		# (igual respeta el hit_frame de arriba: la barrida debe haber conectado antes de cancelar).
		var aye_sweep_cast: bool = fx_floral and anim_actual == "sweep" and accion == "spin_kick" \
			and not (crouching or Input.is_action_pressed(act("ui_down"))) \
			and sprite.sprite_frames.has_animation("crystal_cast")
		if not aye_sweep_cast:
			if BTN_FAMILY.get(anim_actual, "") == accion:
				return false
			if BTN_LEVEL.get(accion, 0) < ANIM_LEVEL.get(anim_actual, 0):
				return false
	# (UPPERCUT de ROUM = → → + Q, se detecta en el event handler junto al void lash — no aquí)
	# agachados SOLO en el suelo Y con press EN EL SUELO: un botón apretado en el aire
	# (buffer de aterrizaje, desde_aire) NO abre agachados — evita "salto + ↓R = tigre"
	if not airborne and not desde_aire and (crouching or Input.is_action_pressed(act("ui_down"))):
		if accion == "attack":
			sprite.play("crouch_punch")
			return true
		if accion == "kick":
			# ROUM (warrior): ↓W = SÚPER (cabezazo + ONDA EXPANSIVA, ½ barra). Reemplaza el crouch_kick.
			# main._roum_super cobra la barra (deny si no hay). Los demás personajes: crouch_kick normal.
			if archetype == "warrior":
				var mbs := get_parent()
				if mbs and mbs.has_method("_roum_super"):
					mbs._roum_super(self)
					return true
			sprite.play("crouch_kick")
			return true
		if accion == "weak_punch" and sprite.sprite_frames.has_animation("crouch_jab"):
			# Fe v2: ↓R es el CAST del tigre — cuesta BARRA Y MEDIA (se cobra aquí).
			# Sin barra suficiente el cast NO sale (el input se consume igual).
			if fx_blue and sprite.sprite_frames.get_frame_count("crouch_jab") > 8:
				var mcj := get_parent()
				if mcj == null or not mcj.has_method("try_tiger_cost") or not mcj.try_tiger_cost(self):
					return true
				sprite.play("crouch_jab")
				# VOZ: "Let go, Tiger!" — primero la versión BATALLA (procesada ×1.35, tono
				# intacto); si faltara, el mp3 crudo acelerado por pitch. (No sonaba porque
				# el .wav no estaba IMPORTADO por Godot — exists() daba false en silencio.)
				var lgt := "res://imagen-action/favi/Fe-sound-effect/let-go-tiger-battle.wav"
				var lgt_raw := "res://imagen-action/favi/Fe-sound-effect/let_go_tiger.mp3"
				if ResourceLoader.exists(lgt):
					voz_player.stream = load(lgt)
					voz_player.pitch_scale = 1.0
					voz_player.play()
				elif ResourceLoader.exists(lgt_raw):
					voz_player.stream = load(lgt_raw)
					voz_player.pitch_scale = 1.3   # la cruda viene MUY lenta
					voz_player.play()
				if mcj.has_method("_fe_cast_fx"):
					mcj._fe_cast_fx(self, true, -84.0)   # cuerpo agachado: 84px tras el centro
					get_tree().create_timer(0.75).timeout.connect(func() -> void: mcj._fe_cast_fx(self, false), CONNECT_ONE_SHOT)
				if mcj.has_method("_fe_tiger_attack"):
					get_tree().create_timer(0.24).timeout.connect(func() -> void: mcj._fe_tiger_attack(self), CONNECT_ONE_SHOT)
				return true
			sprite.play("crouch_jab")
			return true
		if accion == "spin_kick" and sprite.sprite_frames.has_animation("sweep"):
			sprite.play("sweep")
			return true
		return false
	match accion:
		"attack":
			if airborne:
				# AYE: ↓→ + Q en el AIRE también teleporta (glitch). Sin ↓→ = jump_punch (invoca 3 cristales).
				if fx_floral:
					var adir_air := Input.get_axis(act("ui_left"), act("ui_right"))
					var aade_air := adir_air != 0.0 and int(signf(adir_air)) == facing
					if aade_air and down_recent_t > 0.0:
						_start_teleport()
						return true
				# ZETMA: ↓→Q en el AIRE = AIR GRAB (gancho aéreo que hala hacia él)
				if fx_dark and down_recent_t > 0.0:
					var zdir_air := Input.get_axis(act("ui_left"), act("ui_right"))
					if zdir_air != 0.0 and int(signf(zdir_air)) == facing:
						var mag := get_parent()
						if mag and mag.has_method("_zetma_air_grab") and mag._zetma_air_grab(self):
							return true
				sprite.play("jump_punch")
			else:
				var dir := Input.get_axis(act("ui_left"), act("ui_right"))
				var adelante := dir != 0.0 and int(signf(dir)) == facing
				# cuarto adelante (↓ reciente y ya suelto) + Q:
				#   AYE = TELEPORT (glitch morado) · Fe = ESPECIAL DE AGUA · DAM = EMBER DASH
				if adelante and down_recent_t > 0.0:
					if fx_floral:
						_start_teleport()          # Aye: teleport (NO el dash de fuego)
						return true
					elif fx_dark:
						# ZETMA: ↓→Q = GROUND GRAB (estira la mano y HALA). NO el dash de DAM.
						var mgg := get_parent()
						if mgg and mgg.has_method("_zetma_ground_grab"):
							mgg._zetma_ground_grab(self)
						return true
					elif sprite.sprite_frames.has_animation("water_cast"):
						_start_water_special(1)
						return true
					elif archetype != "warrior":
						# DAM: EMBER DASH — ahora CUESTA ½ barra de súper (pedido). Sin barra:
						# deny (barra parpadea + personaje gris) y NO embiste.
						var _md := get_parent()
						if _md and _md.has_method("try_meter_cost") and not _md.try_meter_cost(self, 0.5):
							return true
						_start_special()
						return true
				# ←→+Q (atrás luego adelante): ROUM = GROUND GRAB (carga/grappler) · Fe = DASH DE AGUJAS
				if adelante and back_recent_t > 0.0:
					if archetype == "warrior":
						# ROUM: ←→Q = GROUND GRAB (estira las VENDAS y HALA). Solo sale si el rival está a
						# ≤1.5 CUERPOS (main._roum_ground_grab valida rango) para que las vendas no se vean
						# CORTADAS. Si está lejos: NO sale el agarre -> cae al puño normal de abajo.
						var _mg := get_parent()
						if _mg and _mg.has_method("_roum_ground_grab") and _mg._roum_ground_grab(self):
							return true
					elif sprite.sprite_frames.has_animation("water_cast"):
						_start_fe_dash()
						return true
				# →+Q (hacia el rival): doble corte encadenado
				punch_followup = adelante
				sprite.play("punch")
			return true
		"kick":
			if not airborne:
				var kdir := Input.get_axis(act("ui_left"), act("ui_right"))
				var kade := kdir != 0.0 and int(signf(kdir)) == facing
				# ↓↘→+W (medialuna adelante) = ESPECIAL DE AGUA de Fe a 2 CUERPOS
				# AYE ↓→+W = BACKSTAB: se teleporta DETRÁS del rival, golpea y lo EMPUJA ~3 cuerpos hacia
				# adelante (si hay orbe delante, lo mete en ella -> congela). Mixup con el orb.
				if fx_floral and kade and down_recent_t > 0.0:
					if not _spell_afford(0.30):
						return true
					_start_backstab()
					return true
				# ↓↘→+W (medialuna adelante) = ESPECIAL DE AGUA de Fe a 2 CUERPOS
				if kade and down_recent_t > 0.0 and sprite.sprite_frames.has_animation("water_cast"):
					_start_water_special(2)
					return true
			if airborne and fx_floral and down_recent_t > 0.0:
				# AYE en el AIRE: ↓→+W = BACKSTAB también (teleporta DETRÁS del rival y aterriza)
				var kdir_a := Input.get_axis(act("ui_left"), act("ui_right"))
				if kdir_a != 0.0 and int(signf(kdir_a)) == facing:
					if not _spell_afford(0.30):
						return true
					_start_backstab()
					return true
			sprite.play("jump_kick" if airborne else "kick")
			if airborne and not fx_blue and not fx_floral:
				# ↑W de DAM = salto CORTO: corta la subida YA y empieza el arco adelante-abajo
				# (el flote + avance hacen el resto; sin esto seguía subiendo altísimo)
				vel_y = maxf(vel_y, 90.0)
			return true
		"spin_kick":
			# AYE (E) = CRYSTAL CAST a distancia: grita y alza el báculo (#181). El proyectil que
			# viaja se anima aparte (crystal_shard) y se cablea cuando exista. En el suelo.
			if fx_floral and not airborne and sprite.sprite_frames.has_animation("crystal_cast"):
				if not _spell_afford(0.20):
					return true
				_start_crystal_cast()
				return true
			if not airborne:
				var edir := Input.get_axis(act("ui_left"), act("ui_right"))
				var eade := edir != 0.0 and int(signf(edir)) == facing
				# ↓↘→+E (medialuna adelante) = ESPECIAL DE AGUA de Fe a 3 CUERPOS
				if eade and down_recent_t > 0.0 and sprite.sprite_frames.has_animation("water_cast"):
					_start_water_special(3)
					return true
			# AYE salto+E = jump_kick_cast: gira el báculo e INVOCA 3 proyectiles de cristal rectos
			# (reemplaza el air_spin_kick que caía a DAM). Los 3 disparos salen en la fase de lanzamiento.
			if airborne and fx_floral and sprite.sprite_frames.has_animation("jump_kick_cast"):
				if not _spell_afford(0.20):
					return true
				jp_shots = 0
				sprite.play("jump_kick_cast")
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
						voz_player.pitch_scale = 1.0   # resetea el pitch heredado del canal (bug: voz grave/lenta)
						voz_player.play()
				# DAM: SU voz ("Dancing Sword") ya suena desde _on_animation_changed —
				# FUERA la vieja "FURIOUS KICKING" (_play_kick_voz), se solapaban las dos
				return true
			return false
		"weak_punch":
			# salto + R = PATADA AÉREA DOBLE de Fe (air_jab), exclusiva (DAM no la tiene)
			if airborne and sprite.sprite_frames.has_animation("air_jab"):
				# AYE-2 (↑R = patada de ballet, grand jeté): SIN maná ni barrage — eso era de la AYE VIEJA (fuera del roster).
				sprite.play("air_jab")
				return true
			if not airborne:
				# ROUM: ↓↓R = PIT GRAB (ANTI-AÉREO: azota vendas al frente-abajo por PORTAL, agarra al rival del aire)
				if archetype == "warrior" and double_down_t > 0.0:
					var mpg := get_parent()
					if mpg and mpg.has_method("_roum_pit_grab") and mpg._roum_pit_grab(self):
						return true
				# ROUM: ←→R (atrás luego adelante + R) = WARP GRAB (agarre por PORTAL de vendas)
				if archetype == "warrior" and back_recent_t > 0.0:
					var _wd := Input.get_axis(act("ui_left"), act("ui_right"))
					if _wd != 0.0 and int(signf(_wd)) == facing:
						var mw := get_parent()
						if mw and mw.has_method("_roum_warp_grab") and mw._roum_warp_grab(self):
							return true
				# AYE: → ↓ ← + R (media luna atrás) = FROST ORB (PRISM ORB), la orbe congelante
				if fx_floral and hcb_t > 0.0 and sprite.sprite_frames.has_animation("crystal_cast"):
					hcb_t = 0.0
					if not _spell_afford(0.50):
						return true
					_start_frost_orb()
					return true
				if sprite.sprite_frames.has_animation("weak_punch"):
					sprite.play("weak_punch")
					return true
			return false
	return false

# corta el SFX si TODAVIA esta sonando ese mismo stream (efectos cortos con mp3 largos)
func _sfx_cut(st: AudioStream) -> void:
	if sfx_player.playing and sfx_player.stream == st:
		sfx_player.stop()

func _on_animation_finished() -> void:
	# la VOZ "Power Twister" NO queda COLGADA: se corta al terminar la peonza/voladora
	if String(sprite.animation) in ["spin_kick", "air_spin_kick"] and spin_voz_sfx != null \
			and voz_player.playing and voz_player.stream == spin_voz_sfx:
		voz_player.stop()
	# y el WHOOSH giratorio de la peonza de Fe TAMPOCO: whoosh.mp3 es largo y quedaba
	# estancado sonando después de que ella ya paró de girar
	if fx_blue and String(sprite.animation) == "spin_kick" \
			and sfx_player.playing and sfx_key == "spin_kick":
		sfx_player.stop()
	# y el whoosh del E de DAM (suelo y aereo) igual: se corta con la animación
	if not fx_blue and not fx_floral and String(sprite.animation) in ["spin_kick", "air_spin_kick"] \
			and sfx_player.playing and sfx_key == String(sprite.animation):
		sfx_player.stop()
	if sprite.animation == "hit_down":
		# ya se levanto: el castigo termino, se reinician los frenos de combo
		juggle_hits = 0
		wall_bounced = false
		# KO: queda TENDIDA tal como termina la caída (boca arriba), sin levantarse
		if koed:
			sprite.stop()
			sprite.frame = maxi(0, sprite.sprite_frames.get_frame_count("hit_down") - 1)
			return
		# LEVANTARSE (tendido -> de pie) antes de volver a idle: Aye y DAM tienen su anim
		if sprite.sprite_frames.has_animation("get_up") \
				and sprite.sprite_frames.get_frame_count("get_up") > 1:
			sprite.play("get_up")
			return
	if sprite.animation == "ko" or sprite.animation == "ko_air":
		return  # se queda tendido (ko_air = boca abajo del KO aéreo)
	if sprite.animation == "inferno_cast":
		# SOSTIENE la palma extendida hasta que el rito del inferno lo suelte (main
		# repone la pose al cerrar el ultra) — sin esto caia a "pose" a mitad del castigo
		sprite.stop()
		sprite.frame = sprite.sprite_frames.get_frame_count("inferno_cast") - 1
		return
	if sprite.animation == "victory":
		return  # sostiene la pose final
	if sprite.animation == "land":
		sprite.play("pose")   # terminó de amortiguar el aterrizaje -> vuelve a idle
		return
	if sprite.animation == "crouch_up":
		sprite.play("pose")   # ZETMA terminó de levantarse del agachado -> idle
		return
	if sprite.animation == "get_up":
		# DAM: su get_up ya empalma EXACTO con la pose (652 vs 650) — solo unas sombras
		# breves para vestir el levantón, sin aura ni sonido de maná (eso es de Aye)
		if not fx_floral:
			breaker_fx_t = maxf(breaker_fx_t, 0.35)
			sprite.play("pose")
			return
		# AYE "usa un poder" para levantarse: aura MORADA + sombras de poder -> ENMASCARA el snap del
		# último frame (#248, dos manos) a la pose idle relajada.
		_cast_border_on(0.6)
		breaker_fx_t = maxf(breaker_fx_t, 0.55)
		var pwr := "res://imagen-action/aye/sound-effect/spell-charge-mana.mp3"
		if ResourceLoader.exists(pwr):
			var st: AudioStream = load(pwr)
			sfx_player.stream = st
			sfx_player.play()
			# el mp3 es el del canal de maná (largo): cortarlo al terminar el destello
			get_tree().create_timer(0.75).timeout.connect(_sfx_cut.bind(st), CONNECT_ONE_SHOT)
		sprite.play("pose")   # terminó de levantarse -> idle (pose normal)
		return
	if sprite.animation == "jump_kick" and airborne:
		# DAM: corta el WHOOSH del molinete al terminar el giro (que no quede colgado)
		if not fx_blue and not fx_floral and sfx_player.playing and sfx_key == "jump_kick":
			sfx_player.stop()
		# FE: cae con la RECOGIDA de la voladora ("air_fall") — sostenida en el remate
		# abierto se veía "cayendo de pie, feo". DAM conserva su picada sostenida.
		if fx_blue and sprite.sprite_frames.has_animation("air_fall"):
			sprite.play("air_fall")
			return
		sprite.stop()
		sprite.frame = sprite.sprite_frames.get_frame_count("jump_kick") - 1  # sostiene la picada
		return
	if sprite.animation == "jump_punch" and airborne:
		sprite.play("jump")
		sprite.frame = sprite.sprite_frames.get_frame_count("jump") - 2
		return
	if sprite.animation in ["spin_kick", "air_spin_kick", "air_jab", "neutral_spin", "jump_kick_cast"] and airborne:
		# al terminar el golpe/mortal aéreo pasa a un frame de CAÍDA del salto normal (más natural)
		sprite.play("jump")
		sprite.frame = sprite.sprite_frames.get_frame_count("jump") - 2
		return
	if sprite.animation == "air_fall" and airborne:
		# terminó de plegar la pierna: sigue cayendo con el frame de caída del salto
		sprite.play("jump")
		sprite.frame = sprite.sprite_frames.get_frame_count("jump") - 2
		return
	if sprite.animation == "jump" and airborne:
		return  # mantiene el ultimo frame mientras cae
	if sprite.animation == "teleport":
		# GLITCH de teleport/blink/backstab: si el orquestador (main) aún tiene el control
		# (input deshabilitado), retiene el último frame — sin flash de "pose" a mitad del
		# efecto aunque la anim termine antes que la ventana. Con control devuelto: idle.
		if not input_enabled:
			sprite.stop()
			return
		sprite.play("pose")
		return
	if sprite.animation == "hit_fly" and hit_flying:
		sprite.stop()
		sprite.frame = sprite.sprite_frames.get_frame_count("hit_fly") - 1
		return  # sigue volando con la pose de despedido
	if sprite.animation == "wall_splat" and hit_flying:
		sprite.stop()
		sprite.frame = sprite.sprite_frames.get_frame_count("wall_splat") - 1
		return  # cae del rebote con la pose suelta del f4
	if sprite.animation in ["crouch_punch", "crouch_jab", "crouch_kick", "sweep", "take_hit_low", "block_low"]:
		if _es_humano() and (crouching or Input.is_action_pressed(act("ui_down"))):
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
	# sombra en el piso: sigue al peleador y se encoge al saltar. ANCLA a la línea de pies real
	# ((500+offset)×base_scale, igual que el polvo) subida un poco para quedar PEGADA bajo los pies
	# (no separada). El ANCHO usa el body_halfw del personaje (Zetma 130 / DAM 150 / Fe 90 / Aye 75)
	# para que COINCIDA con su tamaño en vez de un radio fijo.
	var height := floor_y - position.y
	var t: float = clampf(1.0 - height / 1280.0, 0.35, 1.0)
	var feet_local: float = (SHADOW_FEET_OFFSET + sprite.offset.y + swing_y_off) * base_scale.y - 34.0
	var ground_local := Vector2(0.0, (floor_y - position.y) + feet_local)
	draw_set_transform(ground_local, 0.0, Vector2(1.0, SHADOW_SQUASH))
	draw_circle(Vector2.ZERO, body_halfw * 1.8 * t, Color(0, 0, 0, SHADOW_ALPHA * t))
	draw_set_transform(Vector2.ZERO)
	_draw_hit_burst()   # la estela del arma la dibuja swing_layer (por delante del cuerpo)
	# ESFERA: barra de TIEMPO de cámara lenta sobre la cabeza del atrapado (se vacía)
	if orb_trap_t > 0.0:
		var _frac := clampf(orb_trap_t / maxf(0.01, orb_trap_max), 0.0, 1.0)
		var _bw := 220.0
		var _bh := 26.0
		var _by := orb_trap_top_y - _bh - 14.0   # PEGADA justo encima de la esfera (sigue su cima al crecer)
		draw_rect(Rect2(-_bw / 2.0 - 4.0, _by - 4.0, _bw + 8.0, _bh + 8.0), Color(0.04, 0.02, 0.08, 0.9))
		draw_rect(Rect2(-_bw / 2.0, _by, _bw, _bh), Color(0.12, 0.06, 0.18, 0.95))
		draw_rect(Rect2(-_bw / 2.0, _by, _bw * _frac, _bh), Color(0.85, 0.40, 1.75, 0.98))
		var _gp := 0.5 + 0.5 * absf(sin(float(Time.get_ticks_msec()) * 0.008))
		draw_rect(Rect2(-_bw / 2.0, _by, _bw * _frac, 3.0), Color(1.3, 0.8, 2.0, 0.6 * _gp))

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
	# AYE-2 TIRA ESFERAS, no da golpes: sus gestos de orbe NO llevan estela de swing (media luna).
	if fx_floral and _orb_color_for(anim) >= 0:
		return
	# Aye (fx_floral) puede tener un arco PROPIO por anim (ej. jump_punch barrido grande #171);
	# si no, cae al arco compartido SWING_FX.
	var fx_table: Dictionary = SWING_FX
	if fx_floral and AYE_SWING_FX.has(anim):
		fx_table = AYE_SWING_FX
	elif fx_blue and FAVI_SWING_FX.has(anim):
		fx_table = FAVI_SWING_FX
	elif fx_dark:
		fx_table = ZETMA_SWING_FX   # Zetma SOLO su tabla (nunca la de DAM/SWING_FX -> sin estelas heredadas como el molinete de jump_kick)
	elif fx_warrior:
		fx_table = ROUM_SWING_FX   # ROUM SOLO su tabla: anims sin entrada aquí NO dibujan estela (no hereda el arco de katana de DAM)
	if not fx_table.has(anim):
		return
	var fx: Dictionary = fx_table[anim]
	# las entradas "dark" (rastro de patada) son SOLO de DAM: Fe/Aye tienen sus propias
	# anims con ese nombre y no deben heredar este efecto
	if bool(fx.get("dark", false)) and (fx_blue or fx_floral):
		return
	var stages: Array = fx["stages"]
	var stage: int = sprite.frame - int(fx["base"])
	if bool(fx.get("loop_stages", false)) and stage >= 0:
		# "endf" opcional: ultimo frame CON estela (el torbellino de DAM frena y asienta
		# despues del giro — sin esto la helice seguia circulando sobre la pose quieta)
		if fx.has("endf") and sprite.frame > int(fx["endf"]):
			return
		stage = stage % stages.size()   # las etapas CICLAN toda la ráfaga (anim larga y fluida)
	# 2ª VENTANA opcional (base2/stages2): anims con DOS golpes separados (doble patada W
	# de Fe) llevan una estela POR GOLPE sin rellenar el hueco con etapas vacías
	if (stage < 0 or stage >= stages.size()) and fx.has("base2"):
		stages = fx["stages2"]
		stage = sprite.frame - int(fx["base2"])
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
	c = Vector2(c.x * bs, (c.y + sprite.offset.y + swing_y_off) * bs)
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
	elif fx_dark:
		# ZETMA (ninja de la OSCURIDAD): estela VOID violeta OSCURO — nada del fuego naranja de DAM
		c_out = Color(0.34, 0.06, 0.60, 0.40 * al)   # sombra violeta profunda (cuerpo/halo)
		c_core = Color(0.66, 0.20, 1.15, 0.62 * al)  # violeta medio caliente (nucleo)
		c_edge = Color(1.05, 0.55, 1.75, 0.80 * al)  # borde violeta brillante (filo del corte)
	elif fx_warrior:
		# ROUM (tanque de vendas oscuras / agujeros negros): estela SMOKY carmesí-NEGRA, pesada y
		# oscura — nada del fuego naranja de DAM. Baja luminancia = se siente densa/tanque.
		c_out = Color(0.10, 0.02, 0.06, 0.44 * al)   # humo negro-vino (halo)
		c_core = Color(0.40, 0.05, 0.12, 0.62 * al)  # carmesí muy oscuro (nucleo)
		c_edge = Color(0.78, 0.14, 0.22, 0.74 * al)  # filo rojo-vino apagado (no brillante)
	else:
		c_out = Color(1.0, 0.42, 0.12, 0.32 * al)
		c_core = Color(1.0, 0.85, 0.4, 0.55 * al)
		c_edge = Color(1.6, 1.2, 0.55, 0.75 * al)
	# "dark": efecto de PATADA — humo carmesí OSCURO (no el fuego brillante de la espada).
	# NO aplica a Zetma (fx_dark): él mantiene su violeta void en TODOS sus golpes.
	if bool(fx.get("dark", false)) and not fx_dark:
		c_out = Color(0.22, 0.03, 0.05, 0.38 * al)
		c_core = Color(0.5, 0.09, 0.10, 0.55 * al)
		c_edge = Color(0.85, 0.18, 0.14, 0.6 * al)
	# NEÓN (súper crystal_flurry): morado MUCHO más brillante + capa de GLOW ancha (bloom) detrás.
	if bool(fx.get("neon", false)):
		c_out = Color(1.15, 0.30, 1.95, 0.42 * al)   # violeta neón (halo)
		c_core = Color(1.95, 0.75, 2.0, 0.85 * al)   # magenta neón caliente
		c_edge = Color(2.0, 1.5, 2.0, 0.98 * al)     # borde blanco-lavanda brillante
		ci.draw_colored_polygon(_swing_poly(a0, a1, w * 1.9, r, c, flat), Color(0.85, 0.20, 1.7, 0.20 * al))
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
