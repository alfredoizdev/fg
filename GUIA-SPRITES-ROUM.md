# ROUM — Coloso de las VENDAS OSCURAS y los AGUJEROS NEGROS · Animation guide

> **(ES) Cómo usar:** cada bloque es UN prompt **completo y autocontenido** para generar UNA
> animación (un clip). Copiás el bloque, lo pegás con la imagen de referencia de ROUM, generás
> y guardás el clip como `imagen-action/roum/sheets/<accion>.mp4`. Yo lo proceso al juego. Si
> sale con zoom/ángulo/transformaciones, regenerá (el generador de video a veces las mete).

> **⚠️ REGLAS DE IMAGEN — valen para TODA pose (van en cada prompt):** flat 2D **FIGHTING-GAME
> SPRITE**, perfil lateral ESTRICTO mirando a la DERECHA, **ORTOGRÁFICO** (sin ángulo 3/4, sin
> vista de espalda, sin escorzo ni perspectiva). **Sin cámara, sin zoom** — el personaje
> PEQUEÑO y de **cuerpo completo** (cabeza a pies) con **MUCHO margen verde en los 4 lados**,
> nunca recortado, **mismo tamaño y encuadre en todas las poses del mismo movimiento**. Fondo
> **verde plano #00FF00**, sin oponente, sin texto, sin sombra en el suelo.
>
> **CUERPO Y ATUENDO (idénticos a la referencia, NO inventar nada):** ROUM es un hombre ENORME y
> PESADO (210 cm, 165+ kg) — corpulento, de **gran panza/torso musculoso**, hombros anchos, piel
> bronceada, **pelo negro despeinado y BARBA NEGRA POBLADA**. Lleva: un **chaleco/gabán de cuero
> negro SIN MANGAS**, corto y ABIERTO al frente (deja el pecho y la panza al descubierto); los
> **ANTEBRAZOS ENVUELTOS en VENDAS OSCURAS gruesas** (negro/morado profundo, tipo cuero enrollado)
> — son su **arma y su defensa**; una **CADENA metálica** cruzando el pecho/cuello; una **soga
> gruesa** a la cintura con **dos pesas/calabazas redondas colgando** (estilo cuerda de monje/
> sumo); **pantalón holgado BEIGE/CRUDO**; los **PIES ENVUELTOS en vendas** con sandalias abiertas
> (dedos descubiertos). Ropa simple y resistente. **NO** agregues piezas de ropa, cinturones,
> hebillas, armaduras ni telas que no estén en la referencia. **NADA de arma de metal/robot, NADA
> de espada, fuego, agua ni cristales.**
>
> **LAS VENDAS (su sello) — regla para TODO prompt donde se extienden:** las vendas oscuras de sus
> antebrazos **se DESENROLLAN y se ESTIRAN** al frente como **tiras/tentáculos de TELA OSCURA**
> (negro-morado, flotando como cinta/lazo), alargándose MUCHO hacia la derecha; son CLOTH/cloth
> ribbons — SÍ ondulan y se estiran como tela (no rígidas), pero **siempre salen de sus antebrazos
> y NUNCA se sueltan del todo del brazo** (quedan conectadas al antebrazo). No son cadenas, no son
> metal, no son fuego. En inglés: _"His dark forearm bandages UNWRAP and STRETCH forward as long
> dark cloth ribbons/tendrils (black-purple, flowing like cloth) reaching far to the right; they
> stay ATTACHED to his forearms and never fully detach. Cloth ribbons — NOT chains, NOT metal, NOT
> fire."_
>
> **AGUJEROS NEGROS (cuando aparezcan):** discos/portales circulares de **vacío NEGRO** con un
> **borde de energía MORADA girando** (remolino oscuro). Si el prompt no los pide, NO los dibujes
> (el juego los agrega por shader).

> ROUM = **5º peleador**, un **GRAPPLER / TANQUE de CONTROL DE ESPACIO**. Personalidad: **calmado,
> confiado, disfruta el combate.** Poder firma: **manipulación de VENDAS OSCURAS + AGUJEROS NEGROS
> (gravedad/vacío)**. Aísla y elimina rivales controlando el campo: **estira las vendas hacia el
> rival, abre un agujero negro, lo mete y lo saca por OTRO agujero (arriba/abajo/detrás), dejándolo
> caer o al frente.** Es GRANDE y PESADO pero **muy fuerte**: se mueve con **peso y potencia** (no
> ágil, no veloz). Paleta: **piel bronceada + marrones + cuero negro + MORADO/NEGRO del vacío.**

---

## BASE — hacer estas primero (lo hacen jugable)

**`pose` (idle / guardia):**

> A stylized 2D anime video-game GRAPPLER (the exact huge character in the reference image): a
> massive heavyset man, tan skin, black messy hair and a thick black BEARD, an open sleeveless
> black leather vest showing his big bare chest and belly, both FOREARMS wrapped in thick dark
> (black-purple) BANDAGES, a metal CHAIN across his chest, a thick rope belt at the waist with two
> round hanging weights, loose beige pants, bandage-wrapped feet in open sandals. He stands in a
> calm, confident, heavy fighting stance — feet wide and planted, weight low and solid, fists up
> loosely, chin slightly up, relaxed but ready, enjoying the fight. A subtle idle breathing loop —
> the big chest and belly rising, the bandages and rope weights swaying a hair, a faint slow curl
> of dark purple wisps off his wrapped forearms. LOCKED SHOT: strict SIDE PROFILE facing the RIGHT
> edge of the screen the WHOLE clip — he never turns, mirrors or goes frontal. Fixed camera, NO
> zoom (not even in the middle), SAME SIZE in every frame. He stays DEAD-CENTER with feet planted
> on the same spot (in place, no sliding). Pure flat green #00FF00 background, full body head-to-
> feet with green margin all around, no opponent, no text, no effects, no ground shadow (no cast
> shadow or dark blob under him).

**`walk` (avanzar):**

> [Same ROUM from the reference.] He walks FORWARD toward the right with a HEAVY, slow, powerful
> stride — big steps, weight rolling side to side, belly and rope weights swaying, unhurried and
> unstoppable like a heavyweight. He walks IN PLACE like on a treadmill (the background does NOT
> move and he does NOT drift across the frame). Loopable cycle, feet returning to the same line.
> LOCKED SHOT: strict SIDE PROFILE facing the RIGHT edge of the screen the WHOLE clip — never
> turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME SIZE in every frame. He stays DEAD-
> CENTER, walking in place (no real travel across the panel). Pure flat green #00FF00 background,
> full body head-to-feet with green margin all around, no opponent, no text, no effects, no ground
> shadow (no cast shadow or dark blob under him).

**`jump` (salto):**

> [Same ROUM from the reference.] He bends his heavy legs and heaves himself straight UP into a
> weighty jump — a big man leaving the ground, knees pulling up a little, reaches the peak and
> starts to fall, landing solidly back in his stance. Heavy and powerful, VERTICAL only (no flip,
> no spin). LOCKED SHOT: strict SIDE PROFILE facing the RIGHT edge of the screen the WHOLE clip —
> never turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME SIZE in every frame. He stays
> centered and jumps straight up-and-down in place (no sideways travel), landing on the same spot.
> Pure flat green #00FF00 background, full body with green margin all around, no opponent, no text,
> no effects, no ground shadow (no cast shadow or dark blob under him).

**`crouch` (agacharse):**

> [Same ROUM from the reference.] He drops his big body into a low, wide CROUCH — sinking onto his
> haunches, thighs spread, weight settled low, fists up, head slightly down, solid and grounded. He
> HOLDS the low crouch (a short idle at the bottom) and never stands back up during the clip. LOCKED
> SHOT: strict SIDE PROFILE facing the RIGHT edge of the screen the WHOLE clip — never turns,
> mirrors or goes frontal. Fixed camera, NO zoom, SAME SIZE in every frame. He stays DEAD-CENTER
> with feet planted in place (no sliding). Pure flat green #00FF00 background, full body with green
> margin all around, no opponent, no text, no effects, no ground shadow (no cast shadow or dark blob
> under him).

---

## CLOSE COMBAT (puños envueltos + rodillazos, PESADOS y fuertes)

**`punch` (Q — puñetazo pesado):**

> [Same ROUM from the reference.] He throws ONE heavy straight PUNCH forward to the right with a
> bandage-wrapped fist — winding his shoulder back a touch, then driving the wrapped fist out with
> his whole bodyweight behind it, then pulling it back to guard. Slow-ish wind-up but a HEAVY,
> powerful blow; his torso rotates into it. A pure fist strike — the bandages stay wrapped on the
> forearm (they do NOT unravel or extend here). LOCKED SHOT: strict SIDE PROFILE facing the RIGHT
> edge of the screen the WHOLE clip — never turns, mirrors or goes frontal. Fixed camera, NO zoom,
> SAME SIZE in every frame. He stays DEAD-CENTER with feet planted in place (only the stance leans,
> no sliding). Pure flat green #00FF00 background, full body with green margin all around (extra
> room on the RIGHT), no opponent, no text, no effects, no ground shadow.

**`kick` (W — rodillazo / patada pesada que lanza):**

> [Same ROUM from the reference.] He drives ONE heavy KNEE/low front KICK forward: he loads his
> weight, then rams his bandaged shin/knee up and forward with force, hips driving through, then
> plants the foot back and recovers to guard. A big, weighty launching strike (not a fast snap).
> A pure LEG strike — hands stay in guard, bandages stay wrapped. LOCKED SHOT: strict SIDE PROFILE
> facing RIGHT the WHOLE clip — never turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME
> SIZE in every frame. He stays DEAD-CENTER, the standing foot planted on the same spot (no
> sliding). Pure flat green #00FF00 background, full body with green margin all around (extra room
> on the RIGHT for the leg), no opponent, no text, no effects, no ground shadow.

**`weak_punch` (R — jab rápido de venda):**

> [Same ROUM from the reference.] He throws ONE short quick JAB straight forward with his bandaged
> fist — a fast, light poke, the arm punching out a short distance and pulling back instantly. His
> fastest, lightest move: minimal motion, no big swing, bandages stay wrapped (no unravel). LOCKED
> SHOT: strict SIDE PROFILE facing RIGHT the WHOLE clip — never turns, mirrors or goes frontal.
> Fixed camera, NO zoom, SAME SIZE in every frame. He stays DEAD-CENTER with feet planted in place.
> Pure flat green #00FF00 background, full body with green margin all around (extra room on the
> RIGHT), no opponent, no text, no effects, no ground shadow.

**`spin_kick` (E — VENDA EXTENSIBLE, su SELLO de poke largo):**

> [Same ROUM from the reference, strict SIDE PROFILE facing RIGHT.] In this clip the dark BANDAGES
> on ONE of his forearms UNWRAP and SHOOT forward to the RIGHT: the dark cloth ribbons stretch far
> out in front of him like flowing black-purple tendrils, reaching to full length, then whip back
> and re-wrap onto his forearm. The ribbons ripple like cloth (they DO stretch/flow — not rigid,
> not a chain, not metal, not fire) and stay ATTACHED to his forearm the whole time (they never
> fully detach). Only the bandages extend — his big body stays planted, weight shifting forward as
> the wraps shoot out and rocking back as they retract. He does NOT walk or slide. His OTHER forearm
> stays wrapped in guard. LOCKED SHOT: strict SIDE PROFILE facing RIGHT the WHOLE clip — never
> turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME body SIZE every frame (only the
> ribbons' length and the lean change). Pure flat green #00FF00 background, full body, LOTS of
> green room on the RIGHT so the fully-extended ribbons fit inside the frame (never cropped), no
> opponent, no text, no effects, no ground shadow.

---

## CROUCHING ATTACKS

**`crouch_jab` (↓R — golpe bajo rápido):**

> [Same ROUM from the reference, strict SIDE PROFILE facing RIGHT.] He is CROUCHED LOW and stays
> crouched the ENTIRE clip. He throws ONE quick low bandaged PUNCH forward at knee/shin height,
> fist snapping out and back, then recovers to the crouched guard. Small, fast, compact — he never
> stands up. Bandages stay wrapped (no unravel). LOCKED SHOT: strict SIDE PROFILE facing RIGHT —
> never turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME SIZE every frame, feet planted
> dead-center (no sliding). Pure flat green #00FF00 background, full body with green margin all
> around, no opponent, no text, no effects, no ground shadow.

**`crouch_punch` (↓Q — gancho bajo pesado):**

> [Same ROUM from the reference.] He is CROUCHED LOW and stays crouched the ENTIRE clip. He drives
> ONE heavy low HOOK/uppercut-ish bandaged punch forward at gut height, torso twisting into it,
> then recovers to the crouched guard. Weighty and committed but he never stands up. Bandages stay
> wrapped. LOCKED SHOT: strict SIDE PROFILE facing RIGHT the WHOLE clip — never turns, mirrors or
> goes frontal. Fixed camera, NO zoom, SAME SIZE every frame, feet planted dead-center. Pure flat
> green #00FF00 background, full body with green margin all around, no opponent, no text, no
> effects, no ground shadow.

**`crouch_kick` (↓W — ANTI-AÉREO / lanzador: gancho/venda hacia ARRIBA):**

> [Same ROUM from the reference, strict SIDE PROFILE facing RIGHT.] He stays CROUCHED LOW the whole
> clip (thighs low, feet planted — he never stands up), leaning slightly forward. Motion: he draws
> his bandaged arm back and down (short windup), then drives it UP and FORWARD hard in one strong
> rising uppercut toward the upper-right (an anti-air launching blow), then returns to the crouched
> guard. A normal-length arm swing (the bandages do NOT extend here) — just a powerful back-then-
> up-forward hook. LOCKED SHOT: strict SIDE PROFILE facing RIGHT — never turns, mirrors or goes
> frontal. Fixed camera, NO zoom, SAME SIZE every frame, feet planted dead-center. Pure flat green
> #00FF00 background, full body with room to the upper-right for the arm, no opponent, no text, no
> effects, no ground shadow.

**`sweep` (↓E — barrida de pierna pesada, derriba):**

> [Same ROUM from the reference.] He is CROUCHED LOW and stays crouched the ENTIRE clip — he never
> stands up. ONE wide low LEG SWEEP: he plants one bandaged hand on the ground for support and
> swings his big leg across the floor at ankle height in a strong low arc to the right (a tripping
> sweep), then pulls it back to the crouched guard. Heavy and grounded. LOCKED SHOT: strict SIDE
> PROFILE facing RIGHT the WHOLE clip — never turns, mirrors or goes frontal. Fixed camera, NO
> zoom, SAME SIZE every frame, low and planted (no sliding). Pure flat green #00FF00 background,
> full body with LOTS of green room on the RIGHT for the far-reaching leg, no opponent, no text,
> no effects, no ground shadow.

---

## AIR (pesado en el aire)

**`jump_punch` (salto+Q — puñetazo aéreo descendente):**

> [Same ROUM from the reference.] He is AIRBORNE the whole clip (feet off the ground, jump, NO
> floor). He swings ONE heavy bandaged PUNCH downward-forward (a falling overhead blow toward the
> lower right), his weight behind it, then tucks back. Big and weighty. Bandages stay wrapped.
> LOCKED SHOT — flat 2D sprite: strict SIDE PROFILE facing RIGHT, orthographic, no turning. FIXED
> camera, NO zoom. Character SMALL, FULL-BODY, lots of green margin, never cropped, same size every
> frame, centered. Pure flat green #00FF00 background, no opponent, no text, no effects, no ground
> shadow (he is in the air).

**`jump_kick` (salto+W — rodillazo/patada aérea):**

> [Same ROUM from the reference.] He is AIRBORNE the whole clip (jumping, feet off the ground, NO
> floor). He drives ONE heavy KNEE/kick forward-and-down to the right in mid-air, then tucks the
> leg back. A weighty air strike (no spin). Bandages stay wrapped. LOCKED SHOT — flat 2D sprite:
> strict SIDE PROFILE facing RIGHT, orthographic, no turning. FIXED camera, NO zoom. Character
> SMALL, FULL-BODY, lots of green margin, never cropped, same size every frame, centered. Pure flat
> green #00FF00 background, no opponent, no text, no effects, no ground shadow.

**`air_jab` (salto+R — jab aéreo rápido):**

> [Same ROUM from the reference.] He is AIRBORNE the whole clip (feet off the ground, jump, NO
> floor). Clear WIND-UP first: he cocks a bandaged fist back, then snaps it forward into a quick
> short JAB and pulls it back. Fast and light (no bandage unravel). LOCKED SHOT — flat 2D sprite:
> strict SIDE PROFILE facing RIGHT, orthographic, no turning. FIXED camera, NO zoom. Character
> SMALL, FULL-BODY, lots of green margin, never cropped, same size every frame, centered. Pure flat
> green #00FF00 background, no opponent, no text, no effects, no ground shadow.

**`air_spin_kick` (salto+E — VENDA aérea abajo-adelante):**

> [Same ROUM from the reference, strict SIDE PROFILE facing RIGHT.] He is AIRBORNE the whole clip.
> The dark BANDAGES on one forearm UNWRAP and SHOOT down-and-forward to the lower right — the black-
> purple cloth ribbons stretch far diagonally, then whip back and re-wrap. Cloth ribbons that flow/
> stretch (not rigid, not a chain, not metal, not fire), staying ATTACHED to his forearm, never
> fully detaching. Only the bandages extend; his body stays in the jump pose and he stays airborne.
> LOCKED SHOT — flat 2D sprite: strict SIDE PROFILE facing RIGHT, orthographic, no turning. FIXED
> camera, NO zoom, same body size every frame. Leave EXTRA green room toward the LOWER RIGHT so the
> extended ribbons fit inside the frame (never cropped). Pure flat green #00FF00 background, no
> opponent, no text, no effects, no ground shadow (he is in the air).

---

## BLACK-HOLE / BANDAGE KIT (el corazón del personaje) — AGARRES + AGUJEROS NEGROS

> El poder de ROUM: sus **VENDAS OSCURAS se estiran** para AGARRAR y HALAR, y abre **AGUJEROS
> NEGROS** para reubicar al rival. En los clips de agarre se ve al PERSONAJE estirando las vendas
> (los agujeros negros los agrega el juego por shader, salvo que el prompt los pida). Reglas del
> estirado (todos los agarres): SOLO las vendas se alargan (tela oscura que ondula y se estira),
> salen de sus antebrazos, NUNCA se sueltan del todo, y el cuerpo grande queda plantado.

**`ground_grab` (↓→+E — AGARRE DESDE EL SUELO con vendas):** _(agarre de pie)_

> [Same ROUM from the reference — he faces RIGHT.] Standing planted, he winds a bandaged forearm
> back a little, then the dark BANDAGES UNWRAP and SHOOT FORWARD to the RIGHT — long black-purple
> cloth ribbons stretch far out in front of him (flowing like cloth, rippling, NOT rigid, NOT a
> chain, NOT metal, NOT fire), reaching a long distance as if to seize an enemy. At full reach the
> ribbon-ends CLOSE/coil shut as if GRABBING, and then he PULLS: the ribbons RETRACT back sharply
> toward his body as if YANKING/DRAGGING the grabbed enemy in toward him — a clear hard PULL, his
> big torso leaning BACK and bracing with the effort, the cloth coiling back onto his forearm fast
> — ending with the bandages re-wrapped near his body in guard. Reads clearly: shoot out → coil/
> grab → PULL back in. Only the bandages extend; his torso stays roughly in place (leans back with
> the pull), feet planted, he does NOT walk or slide. The ribbons stay ATTACHED to his forearm and
> never fully detach. LOCKED SHOT: strict SIDE PROFILE facing RIGHT the WHOLE clip — never turns,
> mirrors or goes frontal. Fixed camera, NO zoom, SAME SIZE every frame — leave LOTS of extra green
> room on the RIGHT so the fully-extended ribbons fit inside the frame (never cropped). Pure flat
> green #00FF00 background, full body with green margin all around, no opponent, no text, no
> effects, no ground shadow.

**`air_grab` (↓→+E saltando — AGARRE DESDE EL AIRE con vendas):** _(agarre aéreo)_

> [Same ROUM from the reference — he faces RIGHT.] He is AIRBORNE the whole clip (jumping, feet off
> the ground, NO floor). At the top of his jump the dark BANDAGES on his forearm UNWRAP and SHOOT
> DOWN-AND-FORWARD (diagonally toward the lower right) — long black-purple cloth ribbons stretch
> far (flowing like cloth, NOT rigid, NOT a chain, NOT metal), the ends coiling shut as if GRABBING
> an enemy below, then he PULLS them back sharply UP toward his body as if YANKING the enemy up —
> the cloth coiling back onto his forearm, torso recoiling with the effort. Reads clearly: shoot
> down → coil/grab → PULL up. Only the bandages extend; his body stays in the jump pose and he
> stays AIRBORNE (does NOT land). Ribbons stay ATTACHED, never fully detach. LOCKED SHOT: strict
> SIDE PROFILE facing RIGHT the WHOLE clip — never turns, mirrors or goes frontal. Fixed camera, NO
> zoom, SAME SIZE every frame — leave EXTRA green room toward the LOWER RIGHT so the extended
> ribbons fit inside the frame (never cropped). Pure flat green #00FF00 background, full body, no
> opponent, no text, no effects, no ground shadow (he is in the air).

### SÚPER — VOID GRAB (AGUJERO NEGRO)

**`void_cast` (súper — mete las vendas en el agujero negro):** _(clip del personaje)_

> [Same ROUM from the reference — he faces RIGHT.] A powered-up VOID grab: he plants his feet wide,
> his wrapped forearms surging with dark PURPLE energy, and he THRUSTS both bandaged forearms
> FORWARD to the RIGHT — the dark BANDAGES UNWRAP and BLAST out as long black-purple cloth ribbons
> reaching far, driven with his whole bodyweight, the ribbon-ends spreading wide as they lunge out
> to seize an enemy, then SNAP shut hard as if grabbing. He HOLDS that fully-extended thrust pose at
> the end (arms locked out, ribbons stretched and gripping), leaning into it with power and a calm
> confident look. Only the bandages extend; his big body stays planted, no walking/sliding. Ribbons
> stay ATTACHED to his forearms. (No black hole drawn — the game adds the void portals.) LOCKED
> SHOT: strict SIDE PROFILE facing RIGHT the WHOLE clip — never turns, mirrors or goes frontal.
> Fixed camera, NO zoom, SAME SIZE every frame — LOTS of extra green room on the RIGHT so the very
> long extended ribbons fit fully inside the frame (never cropped). Pure flat green #00FF00
> background, full body with green margin all around, no opponent, no text, no other effects, no
> ground shadow.

**`get_pull` (VÍCTIMA — halado hacia el agujero):** _(este lo juega el RIVAL, pero cada personaje necesita el suyo; para ROUM como víctima)_

> [Same ROUM from the reference — he faces RIGHT.] An invisible force GRABS him and DRAGS him: his
> body is YANKED forward/off-balance (pulled toward the left as if something seized him and hauls
> him in), arms flailing a little, feet skidding/dragging, unable to resist — a clear "being pulled
> in" reaction, held for the clip. LOCKED SHOT: strict SIDE PROFILE facing RIGHT the WHOLE clip —
> never turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME SIZE every frame. Pure flat
> green #00FF00 background, no opponent, no text, no effects, no ground shadow.

---

## RECIBIR DAÑO / DEFENSA / FINAL

**`take_hit` (golpeado de pie):**

> [Same ROUM from the reference.] An invisible blow snaps him: his head and torso whip BACKWARD (to
> the left) as if struck in the chest, the big body rocking back, then he recovers his guard. A
> heavy flinch — rocks back and returns (he is big, so it is a solid stagger, not a light snap).
> LOCKED SHOT: strict SIDE PROFILE facing RIGHT the WHOLE clip — never turns, mirrors or goes
> frontal. Fixed camera, NO zoom, SAME SIZE every frame, feet planted in place. Pure flat green
> #00FF00 background, full body with green margin all around, nobody touches him, no opponent, no
> text, no effects, no ground shadow.

**`take_hit_low` (golpeado abajo):**

> [Same ROUM from the reference.] An invisible low blow folds him: he doubles over, big torso
> crunching down as if hit in the gut, staggering, then straightens back to guard. LOCKED SHOT:
> strict SIDE PROFILE facing RIGHT — never turns, mirrors or goes frontal. Fixed camera, NO zoom,
> SAME SIZE every frame, feet planted in place. Pure flat green #00FF00 background, full body with
> green margin all around, no opponent, no text, no effects, no ground shadow.

**`hit-fly.mp4` (lanzado por los aires → se estrella) — de este saco `hit_fly` + `hit_down`:**

> [Same ROUM from the reference.] An invisible force BLASTS his heavy body off his feet: he is
> LAUNCHED up-and-back to the LEFT in a knockout ragdoll — limbs loose, head thrown back, no
> control — flies in an arc and CRASHES flat onto his back on the ground, bounces once, slides, and
> ends sprawled on his back with his head toward the LEFT and feet toward the RIGHT. He does NOT
> somersault, does NOT flip head-over-heels, keeps the SAME side-facing orientation the whole time
> (never flips to the other side). CAMERA HARD-LOCKED, STATIC WIDE — same framing and SAME SIZE
> every frame, NO zoom, NO following him: his whole body stays inside the fixed frame the entire
> flight and crash. Strict side view, no mirror/turn. Pure flat green #00FF00 background, no smoke,
> no dust, no opponent, no effects, no ground shadow.

**`ko-face-up.mp4` (derrotado, cae de espaldas):**

> [Same ROUM from the reference — he faces RIGHT.] He gets knocked out and TIPS OVER BACKWARD,
> toppling toward the LEFT edge of the screen (behind him), like a heavyweight falling flat when
> KO'd: his head and shoulders drop back to the ground FIRST while his feet slide out, and his BACK
> hits the floor, leaving him lying FACE-UP with his big chest and belly pointing UP toward the
> sky. CRITICAL: he does NOT pitch FORWARD, does NOT face-plant, does NOT land on his stomach,
> hands or knees — he falls BACKWARD and lands on his BACK, face-up. Keep the fallen pose fairly
> COMPACT (one knee bent up, arms resting close to his body), a crumpled defeated heap, NOT a full
> spread-eagle sprawl. He holds the lying pose. CAMERA HARD-LOCKED, STATIC WIDE, NO zoom, SAME SIZE
> every frame, strict side view facing right (no mirror), body stays inside the frame. Pure flat
> green #00FF00 background, no opponent, no effects, no ground shadow.

**`get-up.mp4` (se levanta hasta la guardia):**

> [Same ROUM from the reference.] Lying on his back, he rolls to one side, pushes up heavily with
> his big arms to one knee, and heaves himself back up to his wide heavy stance in one solid
> motion, ending standing in guard. CAMERA HARD-LOCKED, STATIC WIDE, NO zoom, SAME SIZE every
> frame, strict side view facing right (no mirror), he rises IN PLACE (feet stay on the same spot),
> body inside the frame. Pure flat green #00FF00 background, no opponent, no effects, no ground
> shadow.

**`block.mp4` (bloqueo de pie):**

> [Same ROUM from the reference.] A DEFENSIVE BLOCK in STRICT SIDE PROFILE facing RIGHT. He raises
> both bandaged forearms up and IN, crossing them in front of his chest/face like a solid wall,
> elbows tucked, and his big body RECOILS BACKWARD a little (weight onto the back foot) as if an
> invisible blow lands on his guard and shoves him, then he settles and holds the guard. CLEARLY
> defensive: every motion goes TOWARD his body or BACKWARD — he NEVER punches, NEVER reaches or
> steps forward, the bandages do NOT extend. LOCKED SHOT: strict SIDE PROFILE facing RIGHT the
> WHOLE clip — never turns frontal, never mirrors, never shows his back. Fixed camera, NO zoom,
> SAME SIZE every frame, feet planted (only the small backward flinch). Pure flat green #00FF00
> background, full body with green margin all around, nothing touches him, no opponent, no effects,
> no ground shadow.

**`block_low.mp4` (bloqueo agachado):**

> [Same ROUM from the reference.] He is CROUCHED LOW the entire clip, compact, head down. He CROSSES
> his two bandaged forearms in front of his body in a clear X-SHAPE guard low in front of his
> chest/knees, and absorbs hits from the front-low with small downward jolts, never rising, arms
> staying crossed. Bandages stay wrapped (no extend). LOCKED SHOT: strict SIDE PROFILE facing RIGHT
> the WHOLE clip — never turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME SIZE every
> frame, crouched, feet planted in place. Pure flat green #00FF00 background, full body with green
> margin all around, no opponent, no effects, no ground shadow.

**`parry.mp4` (postura de desvío — Q+W):**

> [Same ROUM from the reference.] Pure DEFENSIVE deflect — he NEVER attacks, NEVER punches, the
> bandages NEVER extend. ONE quick tense SNAP then a HOLD: he brings both bandaged forearms up-and-
> across into a tight DEFLECT guard angled in front of his face, calm and confident, eyes locked
> forward-right, then HOLDS that ready deflect stance for the rest of the clip (only breathing, the
> rope weights settling). A SHORT tight snap to guard — the arms do NOT reach out or strike, and he
> ends still holding the deflect (does NOT return to neutral). LOCKED SHOT: strict SIDE PROFILE
> facing RIGHT the WHOLE clip — never turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME
> SIZE every frame, feet planted in place. Pure flat green #00FF00 background, full body with green
> margin all around, no opponent, no effects, no ground shadow.

---

## Recordatorios

- Cada bloque de arriba ya es un prompt completo — **copiás uno, pegás la referencia de ROUM, listo.**
- Guardá los clips en `imagen-action/roum/sheets/<accion>.mp4` y avisame.
- Orden sugerido: `pose` → `walk`, `jump`, `crouch` → golpes (Q/W/R) → la **VENDA extensible**
  (`spin_kick`) → los AGARRES (`ground_grab`, `air_grab`, `void_cast`) → reacciones.
- Paleta lock: **piel bronceada + marrones + cuero negro + MORADO/NEGRO del vacío.** NO metal/robot,
  NO espada, NO fuego, NO agua, NO cristales.
- Lo #1 a vigilar: **las vendas se estiran = tiras de TELA OSCURA que ondulan** (no rígidas, no
  cadena, no metal), salen de sus antebrazos, **nunca se sueltan del todo**, y **siempre de perfil
  a la derecha** (que no se voltee, que no lo recorten). Dejá margen verde extra hacia donde se
  estiran las vendas. Es GRANDE y PESADO: todo se mueve con **peso y potencia**, no ágil.
- Los **AGUJEROS NEGROS** los agrega el juego por shader (reusa el del VOID ORB de Zetma,
  recoloreado a negro/morado) — NO hace falta dibujarlos en los clips salvo que lo indique el bloque.
