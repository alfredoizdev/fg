# AYE-2 — Magical-Idol Orb Dancer (REDESIGN) · Animation guide (describe the MOVEMENT)

> **(ES) Nota para vos:** los prompts van en **INGLÉS**. **Pegá SOLO el bloque citado `> ...`** de cada
> animación (ya trae la COLA reforzada: no-zoom + no-cambiar). Adjuntá SIEMPRE la **imagen de referencia
> del skin** que estés haciendo. Los títulos y notas (ES) NO se pegan.
>
> **Guía NUEVA desde 0** (**Aye-2**). Por ahora **LO BÁSICO** + la **hoja de la esfera aparte**.
> **El SÚPER (línea/red de energía) lo dejamos para después.**

> **(ES) ⚠️ REGLA DE ORO — NO nombrar las esferas en los prompts del PERSONAJE.**
> Si "orb/sphere/ball/esfera" aparece, la IA se la dibuja en la mano. Los prompts describen **SOLO el
> gesto** con manos vacías. Las esferas son un **sprite APARTE** (motor las tiñe 🟡🩷🔵).

> **(ES) ⚠️ ZOOM:** en cada cola digo **una sola vez** "do NOT zoom in on the character" — NO lo repitas
> ni pongas "push in", porque el generador copia la palabra y termina haciendo zoom. Si tu herramienta
> tiene _negative prompt_ aparte, ahí sí poné: `zoom in, push in, close-up, camera move, change character,
redesign, deformed, extra fingers, VFX, glow, blur`.

---

## COLAS DE RESTRICCIÓN (una por skin — ya van pegadas al final de cada prompt)

> **(ES) skin-1 (tutú):**
> `IMPORTANT — do NOT zoom in on the character and do NOT change her: locked static wide full-body shot, she stays the EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan skin, long dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura, particles, motion blur or post FX.`
>
> **(ES) skin-2 (overol):**
> `IMPORTANT — do NOT zoom in on the character and do NOT change her: locked static wide full-body shot, she stays the EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan skin, long dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura, particles, motion blur or post FX.`

---

## Concepto (leer una vez — NO pegar)

Aye-2 es una **idol mágica / bailarina** que comanda **tres esferas de energía** que orbitan a su
alrededor. Ataca **disparando una esfera** al frente con un gesto de la mano: sale, **golpea y VUELVE**
(boomerang), y las dirige a distintas **alturas**. Efecto al impactar: 🟡 daño fuerte · 🩷 congela ·
🔵 recarga maná. **Zoner.** Órbita/viaje/retorno/color/impacto = motor; el arte del personaje = **solo el
gesto**. **Es la más chica del juego.** **DOS SKINS** (misma pose y movimientos, solo cambia la ropa):
skin-1 = tutú (ref #14) · skin-2 = overol (ref #15); carpetas `sheets/skin-1/` y `sheets/skin-2/`.

---

## Generation rules (apply to EVERY prompt)

Attach the **Aye-2 reference image** of the skin you are making. Always: **1:1 square (1024×1024)**;
**locked static camera, fixed wide full-body framing the whole clip, she stays the same size** (do NOT
zoom in on her); **centered, full body, feet on a flat ground line, 3/4 side view facing RIGHT**;
**moves IN PLACE**; **open empty hands**; **PURE GREEN #00FF00 static background**, no shadow/text; **no
VFX/post** (flat cel shading).

**Saving:** into `imagen-action/aye-2/sheets/skin-1|skin-2/`, named after the action. I process it into
`imagen-action/aye-2/<action>/aye2-<action>-N.png`.

---

## Framing and SIDE SPACE

Leave **empty green space in front (RIGHT)** and some behind (LEFT); on a forward hand-thrust the arm
reaches far right and must never touch the frame edge. Feet on the same ground line (except aerials).

---

# MOVEMENT PROMPTS (paste only the `> ...` block — the tail is already inside)

## BASE — do these FIRST

**`pose skin-1` (idle — tutú):** _(ref #14)_

> The magical-idol girl holds a dynamic ready fighting stance exactly like the reference: legs planted
> wide and athletic, torso in 3/4 view facing right, one hand raised forward and up with open fingers,
> the other hand back near her ponytail — a poised, dancer-like guard. She breathes gently and her long
> ponytail and outfit sway subtly; seamless loop that returns exactly to the first pose. Feet
> planted on a flat ground line, in place. Open empty hands. Pure green #00FF00 background. IMPORTANT —
> do NOT zoom in on the character and do NOT change her: locked static wide full-body shot, she stays the
> EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement.
> Keep her exact design: same face, tan skin, long dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura, particles,
> motion blur or post FX.

**`pose skin-2` (idle — overol):** _(ref #15)_

> The magical-idol girl holds a dynamic ready fighting stance exactly like the reference: legs planted
> wide and athletic, torso in 3/4 view facing right, one hand raised forward and up with open fingers,
> the other hand back near her ponytail — a poised, dancer-like guard. She breathes gently and her long
> ponytail, outfit sway subtly; seamless loop that returns exactly to the first pose.
> Feet planted on a flat ground line, in place. Open empty hands. Pure green #00FF00 background. IMPORTANT
> — do NOT zoom in on the character and do NOT change her: locked static wide full-body shot, she stays
> the EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan skin, long dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel
> shading — no glow, aura, particles, motion blur or post FX.

**`walk skin-1` (forward — tutú):** _(ref #14)_

> The magical-idol girl walks forward (to the right) in place, a smooth graceful glide-walk, her long
> ponytail and outfit trailing and bouncing. 3/4 side view facing right, feet on the ground
> line, seamless loop. Open empty hands. Pure green #00FF00 background. IMPORTANT — do NOT zoom in on the
> character and do NOT change her: locked static wide full-body shot, she stays the EXACT same size,
> framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact
> design: same face, tan skin, long dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura, particles, motion
> blur or post FX.

**`walk skin-2` (forward — overol):** _(ref #15)_

> The magical-idol girl walks forward (to the right) in place, a smooth graceful glide-walk, her long
> ponytail, outfit trailing and bouncing. 3/4 side view facing right, feet on the
> ground line, seamless loop. Open empty hands. Pure green #00FF00 background. IMPORTANT — do NOT zoom in
> on the character and do NOT change her: locked static wide full-body shot, she stays the EXACT same
> size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her
> exact design: same face, tan skin, long dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow,
> aura, particles, motion blur or post FX.

**`walk_back skin-1` (retreat — tutú):** _(ref #14)_

> The magical-idol girl steps backward (to the left) in place with light, cautious backward hops, still
> facing right (she retreats without turning), ponytail and outfit trailing forward. Seamless loop.
> Open empty hands. Pure green #00FF00 background. IMPORTANT — do NOT zoom in on the character and do NOT
> change her: locked static wide full-body shot, she stays the EXACT same size, framing and position in
> every frame; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan skin,
> long dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura, particles, motion blur or post FX.

**`walk_back skin-2` (retreat — overol):** _(ref #15)_

> The magical-idol girl steps backward (to the left) in place with light, cautious backward hops, still
> facing right (she retreats without turning), ponytail, outfit trailing forward.
> Seamless loop. Open empty hands. Pure green #00FF00 background. IMPORTANT — do NOT zoom in on the
> character and do NOT change her: locked static wide full-body shot, she stays the EXACT same size,
> framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact
> design: same face, tan skin, long dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura,
> particles, motion blur or post FX.

> **(ES) De acá para abajo dejo la cola de skin-1 (tutú). Para skin-2, cambiá la última parte por la
> COLA skin-2 de arriba (overol).**

**`crouch`:**

> The magical-idol girl lowers into a low crouch and holds, 3/4 side view facing right, staying in place,
> hands in a low guard. Short settle-in then hold. Open empty hands. Pure green #00FF00 background.
> IMPORTANT — do NOT zoom in on the character and do NOT change her: locked static wide full-body shot,
> she stays the EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent anatomy, correct hands
> and fingers. Keep her exact design: same face, tan skin, long dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow,
> aura, particles, motion blur or post FX.

**`jump`:**

> The magical-idol girl jumps straight up and comes down, in place, a light graceful leap with ponytail
> and outfit billowing up then settling. 3/4 side view facing right. NO ground shadow. Open empty hands.
> Pure green #00FF00 background. IMPORTANT — do NOT zoom in on the character and do NOT change her: locked
> static wide full-body shot, she stays the EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged;
> consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan skin, long dark
> ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura, particles, motion blur or post FX.

**`get_up`:**

> The magical-idol girl is lying on the ground and rises back to her feet into the standing ready stance:
> lying → pushing up → rising → standing guard. Quick and graceful, feet end on the ground line. 3/4 side
> view facing right. Pure green #00FF00 background. IMPORTANT — do NOT zoom in on the character and do NOT
> change her: locked static wide full-body shot, she stays the EXACT same size, framing and position in
> every frame; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan skin,
> long dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura, particles, motion blur or post FX.

---

## STRIKES — her normals (describe ONLY the hand gesture; NEVER name a thrown object)

**`orb_jab` (R — quick poke):**

> 3/4 side view facing right. From an open-handed guard, a fast short flick of the lead hand forward at
> chest height — a quick snap — then immediately pull the hand back to guard. Open empty hands. Pure green
> #00FF00 background. IMPORTANT — do NOT zoom in on the character and do NOT change her: locked static
> wide full-body shot, she stays the EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent
> anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan skin, long dark ponytail,
> her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat
> cel shading — no glow, aura, particles, motion blur or post FX.

**`orb_throw` (Q — straight forward throw):**

> 3/4 side view facing right, looking and facing FORWARD toward the target (to the right). A BIG
> committed forward throw with the WHOLE body: first she WINDS UP — the throwing hand pulls back near her
> shoulder, torso coiling, weight onto the back foot — then she UNWINDS and hurls STRAIGHT FORWARD,
> stepping into it, the arm thrusting fully extended forward at chest/shoulder height, aimed STRAIGHT
> AHEAD at the target (a level, horizontal throw — NOT downward and NOT upward), hips and shoulders
> rotating through. Hold the fully-extended forward pose briefly, then recover to guard. Open empty hand.
> Pure green #00FF00 background. IMPORTANT — do NOT zoom in on the character and do NOT change her: locked
> static wide full-body shot, she stays the EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged;
> consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan skin, long dark
> ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any
> garment). Flat cel shading — no glow, aura, particles, motion blur or post FX.

**`orb_e` (E — overhead throw · 3rd orb):**

> 3/4 side view facing right, looking and facing FORWARD toward the target (to the right). A powerful
> OVERHEAD throw: she cocks the throwing arm STRAIGHT UP HIGH (elbow high, hand reaching up overhead,
> arm fully raised), leaning her torso back with weight on the back foot, then snaps the whole arm
> forward-and-down in one big over-the-top motion, stepping into it and hurling straight toward the
> target as her hips and shoulders rotate through — a hard overhand smash, clearly different from a
> straight throw. Throughout the wind-up the arm stays raised UP in the OPEN AIR, well clear and away
> from her body. Hold the followed-through extended pose briefly, then recover to guard. Open empty hand. Pure
> green #00FF00 background. IMPORTANT — do NOT zoom in on the character and do NOT change her: locked
> static wide full-body shot, she stays the EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged;
> consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan skin, long dark
> ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any
> garment). Flat cel shading — no glow, aura, particles, motion blur or post FX.

**`orb_low` (W — low skimming throw · 2nd orb):** _(ES: antes `wer` — renombrado para no confundir con las teclas)_

> 3/4 side view facing right, looking and facing FORWARD toward the target (to the right). A LOW forward
> throw: she bends her knees and drops low, swinging the throwing arm down and then whipping it forward
> low, releasing near the ground and hurling straight forward at a LOW/skimming angle (aimed low, at the
> target's feet/legs), stepping into it. Hold the low extended forward pose briefly, then recover to
> guard. Open empty hand. Pure green #00FF00 background. IMPORTANT — do NOT zoom in on the character and
> do NOT change her: locked static wide full-body shot, she stays the EXACT same size, framing and
> position in every frame; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same
> face, tan skin, long dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add,
> remove or change any garment). Flat cel shading — no glow, aura, particles, motion blur or post FX.

**`orb_push` (R — two-hand shove · especial):**

> 3/4 side view facing right. From guard, she brings both hands together and pushes them forward in a firm
> double-palm shove at chest height, holds the extended pose, then pulls both hands back to guard. Open
> empty hands. Pure green #00FF00 background. IMPORTANT — do NOT zoom in on the character and do NOT change
> her: locked static wide full-body shot, she stays the EXACT same size, framing and position in every
> frame; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan skin, long
> dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura, particles, motion blur or post FX.

> **(ES) GOLPES EN EL AIRE (v2, 20 ago): 3 ORBES + 1 PATADA. ↑Q=`jump_throw`(recto) · ↑W=`jump_down`(diagonal ↓)
> · ↑E=`jump_up`(diagonal ↑) · ↑R=`air_kick`(patada de ballet). Reemplazan al viejo `jump_orb`.**

**`jump_throw` (↑Q · aire — orbe RECTO):** _(ES: reemplaza al viejo `jump_orb`)_

> The magical-idol girl airborne (compact jump pose, NO ground line, NO shadow, nothing at the bottom of
> the frame) does a committed forward hand thrust STRAIGHT AHEAD at chest height, then recovers to a
> compact air-guard. 3/4 side view facing right. Open empty hand. Pure green #00FF00 background. IMPORTANT
> — do NOT zoom in on the character and do NOT change her: locked static wide full-body shot, she stays the
> EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement.
> Keep her exact design: same face, tan skin, long dark ponytail, her outfit and colors EXACTLY like the
> reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura, particles,
> motion blur or post FX.

**`air_kick` (↑R · aire — PATADA de ballet · es una PATADA, NO un orbe):** _(ES: antes se llamaba `jump_kick`; va en ↑R)_

> The girl airborne (compact jump pose, NO ground line, NO shadow, nothing at the bottom of
> the frame) performs a graceful AERIAL KICK: she extends one leg in a high, elegant flying kick
> forward and slightly downward, toe pointed like a dancer, the other leg tucked, arms poised for balance,
> then folds the leg back into a compact air pose. It is a LEG kick — no object and no orb in her hands.
> 3/4 side view facing right. Open empty hands. Pure green #00FF00 background. IMPORTANT — do NOT zoom in on
> the character and do NOT change her: locked static wide full-body shot, she stays the EXACT same size,
> framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement.
> Keep her exact design: same face, tan skin, long dark ponytail, her outfit and colors EXACTLY like the
> reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura, particles,
> motion blur or post FX.

**`jump_down` (↑W · aire — orbe DIAGONAL hacia abajo):**

> The magical-idol girl airborne (compact jump pose, NO ground line, NO shadow, nothing at the bottom of
> the frame) thrusts her lead hand forward and DOWN at a steep downward-diagonal angle (aiming toward the
> ground below and forward), then recovers to a compact air-guard. 3/4 side view facing right. Open empty
> hand. Pure green #00FF00 background. IMPORTANT — do NOT zoom in on the character and do NOT change her:
> locked static wide full-body shot, she stays the EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged;
> consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan skin, long dark
> ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any
> garment). Flat cel shading — no glow, aura, particles, motion blur or post FX.

**`jump_up` (↑E · aire — orbe DIAGONAL hacia ARRIBA):**

> The magical-idol girl airborne (compact jump pose, NO ground line, NO shadow, nothing at the bottom of
> the frame) thrusts her lead hand forward and UP at an upward-diagonal angle (aiming UP and forward, above
> herself), then recovers to a compact air-guard. 3/4 side view facing right. Open empty hand. Pure green
> #00FF00 background. IMPORTANT — do NOT zoom in on the character and do NOT change her: locked static wide
> full-body shot, she stays the EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement.
> Keep her exact design: same face, tan skin, long dark ponytail, her outfit and colors EXACTLY like the
> reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura, particles,
> motion blur or post FX.

---

## CROUCH STRIKES — golpes AGACHADA (se queda agachada TODO el clip)

> **(ES) lean: 1 ORBE (`crouch_low`) + 1 PATADA de ballet (`crouch_kick`). `crouch_jab` (poke) queda
> OPCIONAL. Mantené la pose agachada TODO el clip. Cola skin-1 abajo; para skin-2 cambiá la cola por overol.**

**`crouch_kick` (agachada — PATADA baja de ballet · es una PATADA, NO un orbe):**

> 3/4 side view facing right, staying LOW in a crouch. From the low crouch she snaps a quick, graceful LOW
> BALLET KICK straight FORWARD to the RIGHT with her lead leg — the kicking leg extends out low and forward
> TOWARD THE OPPONENT ON THE RIGHT (aimed LOW, at the opponent's legs and feet, ankle/shin height), toe
> pointed like a dancer, the foot reaching toward the RIGHT edge of the frame — then she RETRACTS the leg
> back in and settles into the low crouch. She kicks FORWARD, to the RIGHT — NEVER backward, NEVER to the
> LEFT. She stays crouched low the whole time, in place. She has EXACTLY TWO legs at all times: ONE foot
> stays planted on the ground line, the OTHER is the single kicking leg — do NOT draw a third leg, a
> duplicate leg or any extra/ghost limb. It is a LEG kick — no object and no orb in her hands. Her arms and
> torso MOVE WITH the kick for balance (they do NOT stay frozen): as the leg snaps out, one arm swings
> forward and the other counterbalances back, her torso leans and twists slightly with the motion, then
> everything settles back into a light graceful low guard — a fluid, dancer-like whole-body kick, never
> stiff or static. Pure green #00FF00 background. IMPORTANT — do NOT zoom in on the character and do NOT change her:
> locked static wide full-body shot, she stays the EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement.
> Keep her exact design: same face, tan skin, long dark ponytail, her outfit and colors EXACTLY like the
> reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura, particles,
> motion blur or post FX.

**`crouch_jab` (agachada — poke rápido bajo) — _OPCIONAL_:**

> 3/4 side view facing right, staying in a LOW crouch the whole time. From the low crouch guard, a fast
> short forward flick of the lead hand at low height (around knee/waist level) — a quick snap forward —
> then immediately pull the hand back to the low guard, still crouched. She stays crouched low, in place,
> feet on the ground line. Open empty hands. Pure green #00FF00 background. IMPORTANT — do NOT zoom in on
> the character and do NOT change her: locked static wide full-body shot, she stays the EXACT same size,
> framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact
> design: same face, tan skin, long dark ponytail, her outfit and colors EXACTLY like the reference image
> (do NOT add, remove or change any garment). Flat cel shading — no glow, aura, particles, motion blur or
> post FX.

**`crouch_low` (agachada — lanzamiento bajo rasante):**

> 3/4 side view facing right, staying LOW in a crouch the whole time. From the low crouch she whips the
> throwing arm forward low, releasing near the ground and hurling STRAIGHT FORWARD at a low/skimming angle
> along the floor (aimed at the opponent's feet), then recovers back to the low crouch guard. She stays
> crouched low, in place, feet on the ground line. Open empty hand. Pure green #00FF00 background.
> IMPORTANT — do NOT zoom in on the character and do NOT change her: locked static wide full-body shot,
> she stays the EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent anatomy, correct hands
> and fingers. Keep her exact design: same face, tan skin, long dark ponytail, her outfit and colors
> EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow,
> aura, particles, motion blur or post FX.

---

## REACTIONS / STATES

**`take_hit`:**

> girl flinches from a hit to the upper body — head and torso snap back, ponytail whips —
> then recovers toward guard. 3/4 side view facing right, in place. Pure green #00FF00 background.
> IMPORTANT — do NOT zoom in on the character and do NOT change her: locked static wide full-body shot,
> she stays the EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent anatomy, correct hands
> and fingers. Keep her exact design: same face, tan skin, long dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow,
> aura, particles, motion blur or post FX.

**`take_hit_low`:**

> girl reacts to a low/body hit — she doubles slightly, then recovers. 3/4 side view
> facing right, in place. Pure green #00FF00 background. IMPORTANT — do NOT zoom in on the character and do
> NOT change her: locked static wide full-body shot, she stays the EXACT same size, framing and position
> in every frame; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan
> skin, long dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura, particles, motion blur or post FX.

**`block` (standing / high guard):**

> The magical-idol girl is ALREADY holding a standing defensive guard from the very first frame: both
> forearms raised and CROSSED into an X directly IN FRONT OF HER FACE — a vertical shield held right in
> front of her face, the hands at about eyebrow/forehead height but kept OUT IN FRONT of the face (not
> touching it, not resting on the head), the forearms roughly VERTICAL, elbows pointing down and forward.
> She is guarding her face and upper body from a frontal blow coming from the RIGHT (the opponent's side),
> weight slightly back. Her arms stay IN FRONT of her face — they do NOT rise above the top of her head,
> are NOT crossed over her hair, and do NOT shield from directly overhead; and she does NOT push open palms
> forward or stretch her arms toward the opponent — the forearms stay close, vertical, crossed in front of
> the face. She simply HOLDS this crossed guard with only a tiny settle/breath. Both feet stay
> PLANTED on the exact same spot the whole clip — she does NOT step, lunge, walk or shift forward or
> backward at any point; only a subtle sway, the legs and feet do not move. 3/4 side view facing
> right, in place. Pure green #00FF00 background. IMPORTANT — do NOT zoom in on the character and do NOT
> change her: locked static wide full-body shot, she stays the EXACT same size, framing and position in
> every frame; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan skin,
> long dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura, particles, motion blur or post FX.

**`block_low` (crouching / low guard):**

> girl stays LOW in a deep defensive crouch the whole time and performs a LOW BLOCK:
> already crouched with knees bent close to the ground, she snaps both forearms DOWN and CROSSES them into
> an X low in FRONT of her shins and knees to guard against a LOW attack or sweep, with a small BRACE and
> RECOIL as if absorbing the blow, then holds the low crossed guard. She stays crouched low throughout —
> she does NOT stand up. Both feet stay PLANTED on the exact same spot; she does NOT step, lunge, walk or
> shift forward or backward — only her arms sweep down into the low guard and her body braces. 3/4 side view
> facing right, in place. Pure green #00FF00 background. IMPORTANT — do NOT zoom in on the character and do
> NOT change her: locked static wide full-body shot, she stays the EXACT same size, framing and position
> in every frame; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan
> skin, long dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura, particles, motion blur or post FX.

**`hit_fly` (knocked into the air):**

> The magical-idol girl gets hit hard and is KNOCKED BACKWARD off her feet: she launches UP and BACK
> toward the LEFT (away from the attacker, who is to the RIGHT), body limp and reeling, torso leaning back,
> arms and long ponytail trailing behind her. It is ONE clean knockback ARC — she does NOT somersault,
> cartwheel, flip or spin in circles; she just gets blown back limp. She rises to the PEAK of the arc and
> then FALLS back DOWN and CRASHES onto her BACK on the GROUND on the left, ending LYING FLAT on her back
> on the floor line (face up, arms out, ponytail spread) — the clip goes all the way from standing-hit to
> lying down on the ground, it does NOT end in mid-air. She keeps FACING RIGHT the whole time (knocked back
> WITHOUT turning around). 3/4 side view facing right. She lands on a flat ground line at the bottom; NO
> cast shadow. Pure green #00FF00 background. IMPORTANT — the CAMERA is LOCKED and does NOT
> zoom or move; ONLY SHE travels along the arc across a fixed wide frame; do NOT zoom in on her and do NOT
> change her: she stays the EXACT same size the whole clip (never enlarged, shrunk or cropped); consistent
> anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan skin, long dark ponytail, her
> outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel
> shading — no glow, aura, particles, motion blur or post FX.

**`hit_down` (crash + get back up):**

> The magical-idol girl is knocked down and falls BACKWARD to the ground, ending FLAT ON HER BACK on the
> floor: thrown off balance, she TOPPLES straight DOWN and back and lands on her back — she does NOT jump or
> leap UP, does NOT rise, hop or bounce UP into the air, and does NOT step or lunge FORWARD at any point
> (she only goes DOWN and back) — and the clip ENDS with her LYING FLAT on the ground — her whole body
> HORIZONTAL along the floor line, head, torso and legs all down on the ground, arms sprawled, motionless.
> She is clearly LYING on the floor, NOT standing; she does NOT get back up in this clip — it ENDS with her
> down on the ground on her back. Her body contact stays on the floor line.
> 3/4 side view facing right. Pure green
> #00FF00 background. IMPORTANT — do NOT zoom in on the character and do NOT change her: locked static wide
> full-body shot, she stays the EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent anatomy,
> correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan skin, long dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading —
> no glow, aura, particles, motion blur or post FX.
> _(ES: hit_down TERMINA tendida en el piso; el LEVANTÓN es `get_up` aparte — el motor los encadena
> hit_down→get_up. La silueta se ACHICA natural al estar tendida — NO la infles; ver [[ai-clip-scale-jitter]].)_

**`ko` (defeated):**

> The magical-idol girl collapses and lies defeated on the ground on her back, motionless, hair spread
> out, ending lying flat on the floor line. 3/4 side view facing right. Pure green #00FF00 background.
> IMPORTANT — do NOT zoom in on the character and do NOT change her: locked static wide full-body shot, she
> stays the EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged; consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan skin, long dark ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura,
> particles, motion blur or post FX.

**`victory`:**

> The magical-idol girl does a graceful victory flourish — a cute dancer pose with a sweep of the hands
> and a small settle, then holds; loops seamlessly. 3/4 side view facing right, in place. Open empty
> hands. Pure green #00FF00 background. IMPORTANT — do NOT zoom in on the character and do NOT change her:
> locked static wide full-body shot, she stays the EXACT same size, framing and position in every frame — she stays SMALL and CENTERED in the MIDDLE of the frame with empty green margin on all four sides, filling only part of the frame, NEVER cropped or enlarged;
> consistent anatomy, correct hands and fingers, natural believable motion — NO unnatural, impossible, broken or contorted poses, NO jerky, floaty or warping movement. Keep her exact design: same face, tan skin, long dark
> ponytail, her outfit and colors EXACTLY like the reference image (do NOT add, remove or change any garment). Flat cel shading — no glow, aura, particles, motion blur or post FX.

---

## SEPARATE ORB SHEET (the effect — over green, NO character)

> **(ES) Acá SÍ es la esfera** (no hay personaje) y el glow SÍ va. UNA sola, clara/casi blanca para teñir
> fácil; el motor la duplica ×3 y la tiñe 🟡🩷🔵.

**`orb` (floating spinning energy sphere — seamless loop):**

> A single glowing spherical orb of magical energy floating in the center, slowly rotating and shimmering
> in place, soft inner swirls and a gentle glow halo. Bright, glassy, near-white / pale energy so it can
> be tinted any color. Seamless loop. NOTHING else — no character, no hands, no ground, no text. PURE
> GREEN #00FF00 background. Same size, centered. Locked static camera, do NOT zoom in, same framing the
> whole clip.

**`orb_impact` (burst on hit — optional):**

> A single energy orb bursts at the center: a quick bright flash and expanding ring of sparkles, then
> fades to nothing (last frames empty green). No character, no ground. PURE GREEN #00FF00 background.
> Locked static camera, do NOT zoom in, same framing the whole clip.

---

## NOT YET — SUPER / signature (do NOT generate)

> **(ES) Todavía NO:** conectar las esferas con una LÍNEA/RED de energía. Lo diseñamos aparte más
> adelante.

---

## Reminders

- **Pegá solo el bloque `> ...`** (ya trae la cola no-zoom + no-cambiar). One clip per animation, **1:1
  square (1024×1024), green #00FF00, 3/4 facing right, in place, feet on the ground line** (aerials: no
  ground/shadow). Adjuntá la **referencia del skin**.
- **NUNCA nombres las esferas** en los prompts del personaje. **"do NOT zoom in" una sola vez** por
  prompt (no repetir "zoom").
- Para **skin-2**, cambiá la cola por la **COLA skin-2** (overol) de arriba.
