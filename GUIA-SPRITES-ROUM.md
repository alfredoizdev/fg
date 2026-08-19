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
> **⚠️ COLOR Y COLGANTES DE LAS VENDAS (garantía OBLIGATORIA en TODO prompt — el generador las
> pinta blancas y se come las colas):** las vendas de AMBOS antebrazos (y las de los pies) son
> **OSCURAS — negro/gris carbón/marrón cuero con toques morados**, EXACTAMENTE del color de la
> referencia. **NUNCA son blancas, crema, beige ni venda médica/gasa**; NO se aclaran, NO cambian
> de color y **AMBOS brazos llevan el MISMO tono oscuro** (uno no se vuelve blanco). Además, las
> **COLAS/tiras SUELTAS que cuelgan** de sus vendas (los extremos colgando del antebrazo/cintura)
> **están SIEMPRE presentes, en cada frame** — no desaparecen ni se recogen. En inglés (pegar en
> cada prompt): _"His forearm and foot bandages are DARK — black / charcoal-grey / dark leather-
> brown with faint purple, EXACTLY the color in the reference. They are NEVER white, cream, beige
> or medical/gauze bandages; they do NOT lighten or change color, and BOTH arms wear the SAME dark
> wraps (neither arm turns white). The loose dangling bandage TAILS hanging off his forearms stay
> present in EVERY frame — they never vanish or retract."_
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
> of CRIMSON RED wisps/glow off his wrapped forearms (crimson, NOT purple). LOCKED SHOT: strict SIDE PROFILE facing the RIGHT
> edge of the screen the WHOLE clip — he never turns, mirrors or goes frontal. Fixed camera, NO
> zoom (not even in the middle), SAME SIZE in every frame. He stays DEAD-CENTER with feet planted
> on the same spot (in place, no sliding). Pure flat green #00FF00 background, full body head-to-
> feet with green margin all around, no opponent, no text, no effects, no ground shadow (no cast
> shadow or dark blob under him).

**`walk` (avanzar):**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] He walks FORWARD toward the right with a HEAVY, slow, powerful
> stride — big steps, weight rolling side to side, belly and rope weights swaying, unhurried and
> unstoppable like a heavyweight. CRITICAL — his SILHOUETTE stays FAT and MASSIVE in every walk
> frame, IDENTICAL bulk to his idle pose: the big ROUND BELLY/GUT and thick heavy torso must NOT
> shrink, slim, tuck in or turn athletic while he moves — he is the same fat heavyweight walking as
> when standing. He walks IN PLACE like on a treadmill (the background does NOT
> move and he does NOT drift across the frame). Loopable cycle, feet returning to the same line.
> LOCKED SHOT: strict SIDE PROFILE facing the RIGHT edge of the screen the WHOLE clip — never
> turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME SIZE in every frame. He stays DEAD-
> CENTER, walking in place (no real travel across the panel). Pure flat green #00FF00 background,
> full body head-to-feet with green margin all around, no opponent, no text, no effects, no ground
> shadow (no cast shadow or dark blob under him).

**`jump` (salto):**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] He bends his heavy legs and heaves himself straight UP into a
> weighty jump — a big man leaving the ground, knees pulling up a little, reaches the peak and
> starts to fall, landing solidly back in his stance. Heavy and powerful, VERTICAL only (no flip,
> no spin). LOCKED SHOT: strict SIDE PROFILE facing the RIGHT edge of the screen the WHOLE clip —
> never turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME SIZE in every frame. He stays
> centered and jumps straight up-and-down in place (no sideways travel), landing on the same spot.
> Pure flat green #00FF00 background, full body with green margin all around, no opponent, no text,
> no effects, no ground shadow (no cast shadow or dark blob under him).

**`crouch` (agacharse):**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] He drops his big body into a low, wide CROUCH — sinking onto his
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

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] He throws ONE heavy straight PUNCH forward to the right with a
> DARK-bandage-wrapped fist — winding his shoulder back a touch, then driving the wrapped fist out
> with his whole bodyweight behind it, then pulling it back to guard. Slow-ish wind-up but a HEAVY,
> powerful blow; his torso rotates into it. A pure fist strike — the bandages stay wrapped on the
> forearm (they do NOT unravel or extend here). BANDAGE COLOR (critical): both forearm wraps are
> DARK — black / charcoal-grey / dark leather-brown with faint purple, EXACTLY as in the reference;
> they are NEVER white, cream, beige or medical gauze, they do NOT lighten, and BOTH arms keep the
> SAME dark tone (neither arm turns white). The loose dangling bandage TAILS hanging off his
> forearms stay visible in EVERY frame (they never vanish). LOCKED SHOT: strict SIDE PROFILE facing
> the RIGHT edge of the screen the WHOLE clip — never turns, mirrors or goes frontal. Fixed camera,
> NO zoom, SAME SIZE in every frame. He stays DEAD-CENTER with feet planted in place (only the
> stance leans, no sliding). Pure flat green #00FF00 background, full body with green margin all
> around (extra room on the RIGHT), no opponent, no text, no effects, no ground shadow.

**`kick` (W — rodillazo / patada pesada que lanza):**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] He drives ONE heavy KNEE/low front KICK forward: he loads his
> weight, then rams his bandaged shin/knee up and forward with force, hips driving through, then
> plants the foot back and recovers to guard. A big, weighty launching strike (not a fast snap).
> A pure LEG strike — hands stay in guard, bandages stay wrapped. LOCKED SHOT: strict SIDE PROFILE
> facing RIGHT the WHOLE clip — never turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME
> SIZE in every frame. He stays DEAD-CENTER, the standing foot planted on the same spot (no
> sliding). Pure flat green #00FF00 background, full body with green margin all around (extra room
> on the RIGHT for the leg), no opponent, no text, no effects, no ground shadow.

**`weak_punch` (R — CABEZAZO rápido / HEADBUTT):**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] He delivers ONE quick HEADBUTT: he rocks
> his head and upper torso slightly BACK to load, then snaps his FOREHEAD sharply FORWARD to the RIGHT
> in a fast headbutt, then pulls his head back to his normal stance. The weapon is his HEAD/forehead —
> a short, sharp, brutal close-range headbutt.
> CRITICAL — this is NOT a punch and NOT a kick: BOTH hands stay UP in guard near his chest/face the
> WHOLE time and NEVER strike, NEVER extend, NEVER reach out — the arms do not attack at all. Do NOT
> throw any fist. The only forward motion is the HEAD snapping forward from a slight backward load.
> Keep it compact and fast — his feet stay planted, only the head/upper body rock back then drive
> forward. Bandages stay wrapped (no unravel). BANDAGE
> COLOR (critical): both forearm wraps are DARK — black / charcoal-grey / dark leather-brown with
> faint purple, EXACTLY as in the reference; they are NEVER white, cream, beige or medical gauze,
> and BOTH arms keep the SAME dark tone (neither turns white). The loose dangling bandage TAILS
> hanging off his forearms stay visible in EVERY frame — they never vanish or retract. LOCKED
> SHOT: strict SIDE PROFILE facing RIGHT the WHOLE clip — never turns, mirrors or goes frontal.
> Fixed camera, NO zoom, SAME SIZE in every frame. He stays DEAD-CENTER with feet planted in place.
> Pure flat green #00FF00 background, full body with green margin all around, no opponent, no text,
> no ground shadow. ABSOLUTELY NO EFFECTS: NO motion streak, NO swoosh/whoosh arc, NO speed lines,
> NO light trail, NO energy/glow, NO blur ribbon — ONLY the plain character moving, the path
> completely clean.

**`spin_kick` (E — VENDA EXTENSIBLE, su SELLO de poke largo):**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference, strict SIDE PROFILE facing RIGHT.] In this clip the dark BANDAGES
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

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference, strict SIDE PROFILE facing RIGHT.] He is CROUCHED LOW and stays
> crouched the ENTIRE clip. He throws ONE quick low bandaged PUNCH forward at knee/shin height,
> fist snapping out and back, then recovers to the crouched guard. Small, fast, compact — he never
> stands up. Bandages stay wrapped (no unravel). LOCKED SHOT: strict SIDE PROFILE facing RIGHT —
> never turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME SIZE every frame, feet planted
> dead-center (no sliding). Pure flat green #00FF00 background, full body with green margin all
> around, no opponent, no text, no effects, no ground shadow.

**`crouch_punch` (↓Q — gancho bajo pesado):**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] He is CROUCHED LOW and stays crouched the ENTIRE clip. He drives
> ONE heavy low HOOK/uppercut-ish bandaged punch forward at gut height, torso twisting into it,
> then recovers to the crouched guard. Weighty and committed but he never stands up. Bandages stay
> wrapped. LOCKED SHOT: strict SIDE PROFILE facing RIGHT the WHOLE clip — never turns, mirrors or
> goes frontal. Fixed camera, NO zoom, SAME SIZE every frame, feet planted dead-center. Pure flat
> green #00FF00 background, full body with green margin all around, no opponent, no text, no
> effects, no ground shadow.

**`crouch_kick` (↓W — ANTI-AÉREO: CABEZAZO ascendente):**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference, strict SIDE PROFILE facing RIGHT.] He starts CROUCHED LOW
> (hips down, knees bent), then EXPLODES straight UPWARD in a RISING HEADBUTT — he drives the TOP/CROWN
> of his HEAD UP toward the sky (a touch forward) as an anti-air, springing up from the crouch, head
> leading upward, then drops right back down into the low crouch. The weapon is his HEAD going UP.
> CRITICAL — this is a HEADBUTT, NOT a punch and NOT a kick: BOTH hands stay UP in guard near his
> chest the WHOLE time and NEVER strike, NEVER extend, NEVER reach out — the arms do not attack at
> all. Do NOT throw any fist, do NOT raise an arm up. The only thing that thrusts UP is his HEAD.
> The motion goes UPWARD (skyward), driven by his legs springing up from the crouch — it is NOT a
> forward headbutt (that is his standing move); this one rises UP as an anti-air, then returns to the
> crouch. Bandages stay wrapped (no unravel). LOCKED SHOT: strict SIDE
> PROFILE facing RIGHT — never turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME SIZE every
> frame, feet planted dead-center. Pure flat green #00FF00 background, full body with room ABOVE his
> head for the upward headbutt, no opponent, no text, no effects (NO swoosh/streak/trail), no ground shadow.

**`sweep` (↓E — barrida de pierna pesada, derriba):**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] He is CROUCHED LOW and stays crouched the ENTIRE clip — he never
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

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] He is AIRBORNE the whole clip (feet off the ground, jump, NO
> floor). He swings ONE heavy bandaged PUNCH downward-forward (a falling overhead blow toward the
> lower right), his weight behind it, then tucks back. Big and weighty. Bandages stay wrapped.
> LOCKED SHOT — flat 2D sprite: strict SIDE PROFILE facing RIGHT, orthographic, no turning. FIXED
> camera, NO zoom. Character SMALL, FULL-BODY, lots of green margin, never cropped, same size every
> frame, centered. Pure flat green #00FF00 background, no opponent, no text, no effects, no ground
> shadow (he is in the air).

**`jump_kick` (salto+W — rodillazo/patada aérea):**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] He is AIRBORNE the whole clip (jumping, feet off the ground, NO
> floor). He drives ONE heavy KNEE/kick forward-and-down to the right in mid-air, then tucks the
> leg back. A weighty air strike (no spin). Bandages stay wrapped. LOCKED SHOT — flat 2D sprite:
> strict SIDE PROFILE facing RIGHT, orthographic, no turning. FIXED camera, NO zoom. Character
> SMALL, FULL-BODY, lots of green margin, never cropped, same size every frame, centered. Pure flat
> green #00FF00 background, no opponent, no text, no effects, no ground shadow.

**`air_jab` (salto+R — jab aéreo rápido):**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] He is AIRBORNE the whole clip (feet off the ground, jump, NO
> floor). Clear WIND-UP first: he cocks a bandaged fist back, then snaps it forward into a quick
> short JAB and pulls it back. Fast and light (no bandage unravel). LOCKED SHOT — flat 2D sprite:
> strict SIDE PROFILE facing RIGHT, orthographic, no turning. FIXED camera, NO zoom. Character
> SMALL, FULL-BODY, lots of green margin, never cropped, same size every frame, centered. Pure flat
> green #00FF00 background, no opponent, no text, no effects, no ground shadow.

**`air_spin_kick` (salto+E — RODILLAZO aéreo simple):**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference, strict SIDE PROFILE facing RIGHT.] He is AIRBORNE the whole clip. ONE
> SIMPLE attack: he drives ONE KNEE up-and-forward hard to the right — a KNEE STRIKE (thigh raised,
> knee leading forward) — then tucks the leg back in. That is the whole move: just a quick, weighty
> airborne KNEE, fast and compact.
> IMPORTANT — absolutely NO bandages unwrapping, NO cloth ribbons, NO whips, NO extending/flying
> wraps of any kind: his forearm bandages stay WRAPPED and STILL on both arms (only the normal short
> dangling tails, they do NOT fly or stretch). Both hands stay in guard near his chest — the arms do
> NOT attack. It is JUST a knee. No slow windup — the knee comes out quick. He stays airborne (feet
> off the ground, no floor). LOCKED SHOT — flat 2D sprite: strict SIDE PROFILE facing RIGHT,
> orthographic, no turning. FIXED camera, NO zoom, same body size every frame. Character SMALL and
> CENTERED, full body, never cropped. Pure flat green #00FF00 background, no opponent, no text,
> no effects (no swoosh/streak/trail), no ground shadow (he is in the air).

**`jump_knee` (PALMETAZO / APLAUSO al frente — las dos manos chocan):** _(slot en el juego a definir)_

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference — he faces RIGHT.] A HULK-style THUNDERCLAP (the motion only, no effect): he starts with BOTH arms swung WIDE OUT to the sides (open hands/palms apart, arms spread), then he SWINGS both open palms together HARD and SLAPS them together in ONE big forward clap in front of his chest — exactly the Hulk thunderclap motion (both flat hands slamming together to make a shockwave), pointed FORWARD to the right — then his hands part back to guard. KEY: it is the SWING-AND-SLAM — the two arms travel from WIDE APART and SLAP together forcefully in front; NOT a static prayer/pressed-hands pose, and NOT hands just held together. ONE single clap only, QUICK and IMMEDIATE (almost no wind-up beyond the arms being spread, then the fast slam). DIRECTION: the clap is FORWARD at CHEST height, arms roughly horizontal — do NOT clap UP, do NOT raise the hands above his shoulders, NOT overhead. Fast, heavy and powerful, whole bodyweight behind it. NO effects at all — NO shockwave, NO burst, NO wind, NO lines — ONLY the plain slam/clap MOTION. His feet stay planted. NO bandages unwrapping, NO ribbons, NO whips — the wraps stay wrapped. LOCKED SHOT — flat 2D sprite: strict SIDE PROFILE facing RIGHT, orthographic, no turning. FIXED camera, NO zoom, SAME body size every frame. Character SMALL and CENTERED, FULL BODY head-to-feet with green margin all around, never cropped. Pure flat green #00FF00 background, no opponent, no text, no effects (no swoosh/streak/trail), no ground shadow.

---

## BLACK-HOLE / BANDAGE KIT (el corazón del personaje) — AGARRES + AGUJEROS NEGROS

> El poder de ROUM: sus **VENDAS OSCURAS se estiran** para AGARRAR y HALAR, y abre **AGUJEROS
> NEGROS** para reubicar al rival. En los clips de agarre se ve al PERSONAJE estirando las vendas
> (los agujeros negros los agrega el juego por shader, salvo que el prompt los pida). Reglas del
> estirado (todos los agarres): SOLO las vendas se alargan (tela oscura que ondula y se estira),
> salen de sus antebrazos, NUNCA se sueltan del todo, y el cuerpo grande queda plantado.

**`ground_grab` (↓→+E — AGARRE DESDE EL SUELO con vendas):** _(agarre de pie)_

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference — he faces RIGHT.] Standing planted, he winds a bandaged forearm
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

### SÚPER — VOID GRAB (AGUJERO NEGRO)

**`void_cast` (súper — BATTLE-ROPES: bate brazos ↑↓, ondas de MUCHAS vendas al frente):** _(clip del personaje)_

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference — he faces RIGHT.] A powered-up SUPER, like the BATTLE-ROPES
> exercise: he plants his feet wide and holds MANY long ribbons that stream FORWARD to the right from
> BOTH forearms, and he BEATS/WHIPS both arms UP and DOWN rapidly and powerfully — exactly like a
> person gripping the ends of two heavy ropes and slamming both arms up and down to send WAVES
> rippling down the ropes. This drives fast UNDULATING WAVES down the MANY ribbons — lots of thick
> ribbons flowing FORWARD to the right, rippling in waves at HIGH SPEED (constant fast up-down arm
> beating, not a single thrust-and-hold). The ribbons wave/ripple forward the whole clip.
> MOTION (key): both arms pump UP and DOWN fast and repeatedly (the battle-rope slam) — this is a
> continuous beating, NOT one thrust. The waves travel forward along the ribbons.
> COLOR (important): during the super his forearm BANDAGES turn/charge to a DARK CRIMSON RED, and the
> ribbons and their glow/energy/sparks are CRIMSON RED — deep dark red / crimson (NOT purple, NOT
> violet). Any aura, light or sparks along his arms and ribbons is crimson red.
> His big body stays planted (feet wide, no walking/sliding); only his arms beat up-and-down and the
> ribbons wave forward. Ribbons stay ATTACHED to his forearms. (No black hole drawn — the game adds
> the void portals.)
> LOCKED SHOT: strict SIDE PROFILE facing RIGHT the WHOLE clip — never turns, mirrors or goes
> frontal. Fixed camera, NO zoom, SAME SIZE every frame — LOTS of extra green room on the RIGHT so
> the many long ribbons fit fully inside the frame (never cropped). Pure flat green #00FF00
> background, full body with green margin all around, no opponent, no text, no ground shadow.

**`get_pull` (VÍCTIMA — halado hacia el agujero):** _(este lo juega el RIVAL, pero cada personaje necesita el suyo; para ROUM como víctima)_

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference — he faces RIGHT.] An invisible force GRABS him and DRAGS him: his
> body is YANKED forward/off-balance (pulled toward the left as if something seized him and hauls
> him in), arms flailing a little, feet skidding/dragging, unable to resist — a clear "being pulled
> in" reaction, held for the clip. LOCKED SHOT: strict SIDE PROFILE facing RIGHT the WHOLE clip —
> never turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME SIZE every frame. Pure flat
> green #00FF00 background, no opponent, no text, no effects, no ground shadow.

---

## RECIBIR DAÑO / DEFENSA / FINAL

**`take_hit` (golpeado de pie):**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] An invisible blow snaps him: his head and torso whip BACKWARD (to
> the left) as if struck in the chest, the big body rocking back, then he recovers his guard. A
> heavy flinch — rocks back and returns (he is big, so it is a solid stagger, not a light snap).
> LOCKED SHOT: strict SIDE PROFILE facing RIGHT the WHOLE clip — never turns, mirrors or goes
> frontal. Fixed camera, NO zoom, SAME SIZE every frame, feet planted in place. Pure flat green
> #00FF00 background, full body with green margin all around, nobody touches him, no opponent, no
> text, no effects, no ground shadow.

**`take_hit_low` (golpeado abajo):**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] An invisible low blow folds him: he doubles over, big torso
> crunching down as if hit in the gut, staggering, then straightens back to guard. LOCKED SHOT:
> strict SIDE PROFILE facing RIGHT — never turns, mirrors or goes frontal. Fixed camera, NO zoom,
> SAME SIZE every frame, feet planted in place. Pure flat green #00FF00 background, full body with
> green margin all around, no opponent, no text, no effects, no ground shadow.

**`hit-fly.mp4` (lanzado por los aires → se estrella) — de este saco `hit_fly` + `hit_down`:**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] An invisible force BLASTS his heavy body off his feet: he is
> LAUNCHED up-and-back to the LEFT in a knockout ragdoll — limbs loose, head thrown back, no
> control — flies in an arc and CRASHES flat onto his back on the ground, bounces once, slides, and
> ends sprawled on his back with his head toward the LEFT and feet toward the RIGHT. He does NOT
> somersault, does NOT flip head-over-heels, keeps the SAME side-facing orientation the whole time
> (never flips to the other side). CAMERA HARD-LOCKED, STATIC WIDE — same framing and SAME SIZE
> every frame, NO zoom, NO following him: his whole body stays inside the fixed frame the entire
> flight and crash. Strict side view, no mirror/turn. Pure flat green #00FF00 background, no smoke,
> no dust, no opponent, no effects, no ground shadow.

**`ko-face-up.mp4` (derrotado, cae de espaldas):**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference — he faces RIGHT.] He gets knocked out and TIPS OVER BACKWARD,
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

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] Lying on his back, he rolls to one side, pushes up heavily with
> his big arms to one knee, and heaves himself back up to his wide heavy stance in one solid
> motion, ending standing in guard. CAMERA HARD-LOCKED, STATIC WIDE, NO zoom, SAME SIZE every
> frame, strict side view facing right (no mirror), he rises IN PLACE (feet stay on the same spot),
> body inside the frame. Pure flat green #00FF00 background, no opponent, no effects, no ground
> shadow.

**`block.mp4` (bloqueo de pie):**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] A DEFENSIVE BLOCK in STRICT SIDE PROFILE facing RIGHT. He raises
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

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] He is CROUCHED LOW the entire clip, compact, head down. He CROSSES
> his two bandaged forearms in front of his body in a clear X-SHAPE guard low in front of his
> chest/knees, and absorbs hits from the front-low with small downward jolts, never rising, arms
> staying crossed. Bandages stay wrapped (no extend). LOCKED SHOT: strict SIDE PROFILE facing RIGHT
> the WHOLE clip — never turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME SIZE every
> frame, crouched, feet planted in place. Pure flat green #00FF00 background, full body with green
> margin all around, no opponent, no effects, no ground shadow.

**`parry.mp4` (postura de desvío — Q+W):**

> [Same ROUM from the reference — KEEP his HEAVY FAT BODY (huge round belly/gut + massive heavyset bulk, EXACTLY as heavy and thick as the reference - NEVER slimmed, leaned or made athletic), his DARK bandages (never white/gauze) and the loose hanging bandage TAILS on BOTH forearms, and his OUTFIT UNCHANGED (short OPEN vest ending around the upper belly - NO extra cloth, tabard, loincloth, apron, skirt or long ragged flap hanging over his groin or front; below the rope belt is ONLY his loose beige pants), exactly like the reference.] Pure DEFENSIVE deflect — he NEVER attacks, NEVER punches, the
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
