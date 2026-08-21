# ZETMA — Cyber Ninja (BRAZO MECÁNICO EXTENSIBLE / AGARRES) · Animation guide

> **(ES) Cómo usar:** cada bloque es UN prompt **completo y autocontenido** para generar UNA
> animación (un clip). Copiás el bloque, lo pegás con la imagen de referencia de Zetma, generás
> y guardás el clip como `imagen-action/zetma/sheets/<accion>.mp4`. Yo lo proceso al juego. Si
> sale con zoom/ángulo/transformaciones, regenerá (el generador de video a veces las mete).

> **⚠️ REGLAS DE IMAGEN — valen para TODA pose (van en cada prompt):** flat 2D **FIGHTING-GAME
> SPRITE**, perfil lateral ESTRICTO mirando a la DERECHA, **ORTOGRÁFICO** (sin ángulo 3/4, sin
> vista de espalda, sin escorzo ni perspectiva). **Sin cámara, sin zoom** — el personaje
> PEQUEÑO y de **cuerpo completo** (cabeza a botas) con **MUCHO margen verde en los 4 lados**,
> nunca recortado, **mismo tamaño y encuadre en todas las poses del mismo movimiento**. Fondo
> **verde plano #00FF00**, sin oponente, sin texto, sin sombra en el suelo. **Brazos:** UNO es
> mecánico de **metal negro** (con luces naranjas); el otro es de **carne + tela** (piel,
> guante). La **daga la sostiene la mano de CARNE** (nunca la de metal), agarrada firme (no la
> suelta). El brazo que se estira llega a **largo humano natural** (no exagerar). **SOLO UN
> BRAZO es mecánico** (metal). Las **PIERNAS y los PIES son NORMALES** (humanos, pantalón de
> tela + sneakers) — NUNCA volver mecánica/metal una pierna ni un pie, ni añadirles piezas
> robóticas. El otro brazo también es de carne/tela.
> **MISMO ATUENDO EXACTO de la referencia** — NO inventar ni añadir cinturones, fajas, correas,
> bolsillos, hebillas, piezas de tela o de armadura, ni ningún elemento de ropa que NO esté en
> la referencia. Ropa, máscara y accesorios idénticos a la imagen de referencia en toda pose.
> **CHAQUETA CORTA:** su chaqueta con capucha es CORTA y termina en la CINTURA/CADERA (estilo
> bomber/hoodie). NO tiene faldón largo, cola, gabardina, túnica, ni ninguna tela colgando por
> debajo de la cintura — nada se extiende ni cuelga por debajo de la chaqueta. En inglés para el
> prompt: _"His hooded jacket is SHORT and ends at the WAIST (bomber/hoodie style) — it has NO
> long coat-tail, NO trench-coat skirt, NO robe/tunic hem, NO fabric flap or extension hanging
> below the waist; nothing drapes below the jacket."_
> **TRES GARANTÍAS OBLIGATORIAS (van en TODO prompt, sobre todo en los que estiran el brazo):**
> (1) **NO recortar** — la mano/garra y el brazo, aun COMPLETAMENTE EXTENDIDOS, deben caber
> ENTEROS dentro del cuadro, con margen verde de sobra hacia donde apunta el brazo; nunca tocan
> ni cruzan el borde del panel. (2) **La OTRA mano NUNCA se vuelve robótica/metálica** — solo UN
> brazo es de metal negro; el otro brazo y su mano son SIEMPRE de carne + guante de tela, nunca
> cambian a metal, nunca crecen piezas mecánicas. (3) **La daga NUNCA desaparece** — está
> SIEMPRE visible, agarrada firme en la mano de CARNE, en cada frame; no se borra, no se
> enfunda, no cambia de mano, no se transforma. En inglés: _"The fully-extended arm and claw
> must stay COMPLETELY INSIDE the frame, never cropped at the panel edge (keep extra green
> margin). ONLY one arm is metal — the OTHER hand NEVER turns robotic/metal, it stays flesh with
> a cloth glove. The dagger is ALWAYS visible, gripped in the flesh hand every frame — it never
> disappears, never sheathes, never changes hands."_

> ZETMA = **4º peleador**, un **CYBER-NINJA / GRAPPLER**. Poder firma ÚNICO: su **BRAZO MECÁNICO
> EXTENSIBLE** — el brazo de metal negro **telescopea lejos** para **AGARRAR** al rival y jalarlo.
> Sus técnicas son **SALTAR y ESTIRAR el brazo robótico**: tiene un **AGARRE DESDE EL SUELO**
> (estira el brazo al frente para atrapar) y un **AGARRE DESDE EL AIRE** (salta y estira el brazo
> para atrapar en el aire). **NO hace clones ni sombras** — ese poder ya NO existe; donde antes
> decía "sombra/clon" ahora es el **brazo extensible**. Energía = destellos de las luces naranjas
> del brazo + humo mecánico tenue. Paleta: **negro + morado oscuro + verde tóxico** (acentos
> naranjas del metal). NO fuego, NO agua, NO cristales, NO clones de sombra.

---

## BASE — hacer estas primero (lo hacen jugable)

**`pose` (idle / guardia):**

> A stylized 2D anime video-game NINJA (the exact character in the reference image): black
> mechanical mask with FOUR glowing toxic-green eyes and pointed ear-blades, black hooded
> jacket with dark-purple accents, a full black MECHANICAL right arm, a black dagger with a
> purple-wrapped handle on his lower back, black cargo pants with purple straps, black
> sneakers with purple soles. He stands in a low, coiled ninja guard: weight low, knees
> bent, left gloved hand forward and open, right mechanical arm cocked back ready, body
> alert. A subtle idle breathing loop — chest rising, hood and jacket hem shifting slightly,
> the green eyes giving a faint slow pulse, tiny wisps of dark smoke curling off his
> shoulders. LOCKED SHOT: strict SIDE PROFILE facing the RIGHT edge of the screen the WHOLE
> clip — he never turns, mirrors or goes frontal. Fixed camera, NO zoom (not even in the
> middle), SAME SIZE in every frame. He stays DEAD-CENTER with boots planted on the same
> spot (in place, no sliding). ONE rigid dagger of constant shape, never splits or changes
> hands; his right arm is ONE continuous mechanical limb. Pure flat green #00FF00 background,
> full body head-to-boots with green margin all around, no opponent, no text, no effects, no ground shadow (no cast shadow or dark blob under him).

**`walk` (avanzar):**

> [Same Zetma from the reference.] He walks FORWARD toward the right in a low ninja
> crouch-walk — smooth, stalking, predatory, knees bent, staying low and coiled, arms ready.
> He walks IN PLACE like on a treadmill (the background does NOT move and he does NOT drift
> across the frame). Loopable cycle, feet returning to the same line. LOCKED SHOT: strict
> SIDE PROFILE facing the RIGHT edge of the screen the WHOLE clip — never turns, mirrors or
> goes frontal. Fixed camera, NO zoom (not even in the middle), SAME SIZE in every frame. He
> stays DEAD-CENTER, walking in place (no real travel across the panel). ONE rigid dagger of
> constant shape, never splits or changes hands; his right arm is ONE continuous mechanical
> limb. Pure flat green #00FF00 background, full body head-to-boots with green margin all
> around, no opponent, no text, no effects, no ground shadow (no cast shadow or dark blob under him).

**`jump` (salto):**

> [Same Zetma from the reference.] He crouches and springs straight UP into a nimble ninja
> leap — a compact tuck, knees pulling up, one arm tucked — reaches the peak and starts to
> fall, landing softly back in his low guard. Light and agile, VERTICAL only. LOCKED SHOT:
> strict SIDE PROFILE facing the RIGHT edge of the screen the WHOLE clip — never turns,
> mirrors or goes frontal. Fixed camera, NO zoom (not even in the middle), SAME SIZE in
> every frame. He stays centered and jumps straight up-and-down in place (no sideways
> travel), landing on the same spot. ONE rigid dagger of constant shape, never splits or
> changes hands; his right arm is ONE continuous mechanical limb. Pure flat green #00FF00
> background, full body with green margin all around, no opponent, no text, no effects, no ground shadow (no cast shadow or dark blob under him).

**`crouch` (agacharse):**

> [Same Zetma from the reference.] He drops into a very low CROUCH, folding onto his
> haunches, compact and coiled close to the ground, guard up, head low, ready to spring. He
> HOLDS the low crouch (a short idle at the bottom) and never stands back up during the
> clip. LOCKED SHOT: strict SIDE PROFILE facing the RIGHT edge of the screen the WHOLE clip
> — never turns, mirrors or goes frontal. Fixed camera, NO zoom (not even in the middle),
> SAME SIZE in every frame. He stays DEAD-CENTER with boots planted in place (no sliding).
> ONE rigid dagger of constant shape, never splits or changes hands; his right arm is ONE
> continuous mechanical limb. Pure flat green #00FF00 background, full body with green margin
> all around, no opponent, no text, no effects, no ground shadow (no cast shadow or dark blob under him).

---

## CLOSE COMBAT (daga + puños, rápido)

**`punch` (Q — corte rápido de daga):**

> [Same Zetma from the reference.] He snaps ONE fast diagonal DAGGER slash across the front
> at chest height with his NORMAL human hand (flesh, cloth fingerless glove — NOT the robot
> arm) — the blade whips out in a short crisp arc and snaps back to guard. His MECHANICAL
> black-metal robot arm is the OTHER arm and stays tucked in guard, never holds the dagger.
> Fast and light, minimal body travel, ONE clean slash (no combo). LOCKED
> SHOT: strict SIDE PROFILE facing the RIGHT edge of the screen the WHOLE clip — never
> turns, mirrors or goes frontal. Fixed camera, NO zoom (not even in the middle), SAME SIZE
> in every frame. He stays DEAD-CENTER with boots planted in place (no sliding). ONE rigid
> dagger of constant length and shape — it never bends, splits, duplicates or changes hands;
> his right arm is ONE continuous mechanical limb. Pure flat green #00FF00 background, full
> body with green margin all around (extra room on the RIGHT), no opponent, no text, no
> effects, no ground shadow (no cast shadow or dark blob under him).

**`kick` (W — patada alta):**

> [Same Zetma from the reference.] He throws ONE real HIGH KICK: he chambers his RIGHT leg,
> then snaps it up and forward in a fast rising roundhouse/front high-kick, the boot reaching
> HEAD height at full extension, hips and standing leg driving the motion, then he retracts
> the leg and recovers to guard. A pure LEG strike — the dagger stays SHEATHED and both hands
> stay tight to the body, NO blade slash at all. LOCKED SHOT: strict SIDE PROFILE facing the
> RIGHT edge of the screen the WHOLE clip — never turns, mirrors or goes frontal. Fixed
> camera, NO zoom (not even in the middle), SAME SIZE in every frame. He stays DEAD-CENTER,
> the standing (support) boot planted on the same spot (no sliding). ONE rigid dagger of
> constant shape (stays sheathed here), never splits or changes hands; his right arm is ONE
> continuous mechanical limb that stays attached. Pure flat green #00FF00 background, full
> body with green margin all around (extra room on the RIGHT for the extended leg), no
> opponent, no text, no effects, no ground shadow (no cast shadow or dark blob under him).

**`weak_punch` (R — jab de la mano mecánica):**

> [Same Zetma from the reference.] He throws a fast straight PUNCH by EXTENDING his RIGHT
> mechanical arm forward: ONLY the RIGHT black-metal mechanical arm TELESCOPES OUT to the RIGHT
> in rigid piston segments (segments sliding straight out like a piston, glowing orange at the
> joints, NOT rubbery, NOT organic, NOT a chain), ending in a CLOSED METAL FIST / knuckle that
> SHOOTS forward to PUNCH at full reach, then the segments SNAP BACK and the arm retracts
> instantly to his side. Quick and dry like a piston-snap, but the arm clearly EXTENDS a long way
> to reach — the extension IS the punch. It is ONLY the mechanical (right) arm that stretches and
> delivers the hit; the LEFT arm does NOT extend. ⛔ The mechanical arm ends in a FIST, NOT a
> blade: there is NO sword, NO knife and NO dagger mounted on the arm or at its tip — the
> extending limb is a PUNCHING FIST only. The SINGLE dagger stays ONLY in the LEFT (flesh) hand
> the whole time (held back near his chest, blade forward); it NEVER moves to the mechanical arm
> and never splits. ⛔ He is NOT pushed or shoved BACKWARD and does NOT slide back or recoil — his
> boots stay PLANTED in a wide stance and his weight drives FORWARD into the punch. LOCKED SHOT:
> strict SIDE PROFILE facing the RIGHT edge of the screen the WHOLE clip — he NEVER turns to face
> the camera, NEVER goes frontal, NEVER mirrors. Fixed camera, NO zoom (not even in the middle),
> SAME SIZE in every frame. He stays roughly centered with boots planted. His right arm is ONE
> continuous telescoping mechanical limb that stays attached (never detaches). Pure flat green
> #00FF00 background, full body with LOTS of extra room on the RIGHT so the fully-extended
> arm+fist fits inside the frame (never cropped), no opponent, no text, no effects, no ground shadow.

**`spin_kick` (E — BRAZO EXTENSIBLE, su SELLO):**

> [Same Zetma from the reference, strict SIDE PROFILE facing RIGHT.] He has ONE mechanical
> BLACK-METAL robot arm (glossy black segments, small green joint-lights) and ONE normal
> cloth-sleeved arm. In this clip the SAME mechanical robot arm — and only that one — extends:
> its forearm telescopes STRAIGHT forward toward the right to full reach, punches, then
> retracts to guard. The extending forearm is ONE smooth straight metal PISTON (2-3 nested
> tubes, like a hydraulic ram): it only gets LONGER, it does NOT get wider, thicker or bigger,
> it does NOT expand, swell, bend, curl or stretch like flesh, and it is NOT a chain of many
> beads, a snake or a tentacle. Same thickness throughout — only the LENGTH changes. It always
> reads as an ARM (shoulder → upper arm → long forearm → metal fist), one connected limb
> attached at the shoulder, never detached or split. The metal hand is a CLOSED FIST (knuckles
> forward) the whole time — it is a PUNCH; the hand NEVER opens into a flat palm or open hand.
>
> BODY IMPULSE: he pushes the punch with his body — he shifts his weight forward onto his
> front leg and rotates his torso/shoulder forward as the arm shoots out, then rocks back and
> settles as it retracts. His feet stay planted dead-center (the stance leans but does NOT
> slide across the screen).
>
> CRITICAL CONSISTENCY (the whole clip): it is ALWAYS the same mechanical arm that extends —
> the arms NEVER swap, and the normal cloth arm stays bent in guard and NEVER extends. The
> normal (cloth) hand HOLDS the black DAGGER the entire clip and keeps holding it — the dagger
> stays visible in that same hand in EVERY frame, never disappears, never changes hands, and
> is never thrown. No spinning, no kick, no lunge (ignore the move's name — it is just an
> extend-punch). Fixed camera, NO zoom, same body SIZE every frame (only the arm length and
> the lean change). Pure flat green #00FF00 background, full body, lots of green room on the
> RIGHT, no opponent, no text, no effects, no ground shadow (no cast shadow or dark blob under him).

---

## CROUCHING ATTACKS

**`crouch_jab` (↓R — PATADA BAJA rápida desde el agache):**

> [Same Zetma from the reference, strict SIDE PROFILE facing RIGHT.] A committed low
> hand-supported KICK (capoeira/breakdance style) that clearly reaches out to strike a
> low opponent. Motion: he drops low and PLANTS his MECHANICAL black-metal robot hand flat on
> the GROUND for support, LEANS his torso down and forward over that supporting arm, and SWINGS
> his leg out LOW and FAR to the right in one strong committed low kick — the boot sweeping/
> shooting out at shin/ankle height, reaching a LONG distance ahead to strike — then he pulls
> the leg back and rises to the low guard. His body commits and tilts into it so it reads as a
> REAL powerful strike reaching an enemy (not a small tap).
> HANDS: the supporting hand on the floor is his MECHANICAL robot hand (it stays a ROBOT hand —
> black metal, do NOT turn it human). His OTHER, NORMAL human hand keeps HOLDING the black
> dagger the whole clip (dagger in that same hand, never switches, never dropped). Exactly two
> hands, both attached, nothing detaches or flies off.
> Only ONE leg kicks out; the supporting knee/foot and the planted hand keep him balanced (he
> does not topple over). Stays LOW the whole clip — he does not fully stand up. Feet/hand return
> to the same spot (no sliding across the panel).
> LOCKED SHOT: strict SIDE PROFILE facing the RIGHT the WHOLE clip — never turns, mirrors or goes
> frontal. Fixed camera, NO zoom, SAME SIZE in every frame. Pure flat green #00FF00 background,
> full body with LOTS of green room on the RIGHT for the far-reaching kick, no opponent, no text,
> no effects, no ground shadow (no cast shadow or dark blob under him).

**`crouch_punch` (↓Q — daga baja):**

> [Same Zetma from the reference.] He is CROUCHED LOW and stays crouched the ENTIRE clip. He
> does ONE quick low DAGGER slash at knee height, blade snapping forward and back, then
> recovers to the crouched guard. Small, fast, compact — he never stands up.
> WHICH HAND: the dagger is held and swung by his NORMAL human hand (flesh, cloth/fabric
> fingerless glove) — the slashing hand is the NORMAL one. His MECHANICAL black-metal robot
> arm is the OTHER arm; it does NOT hold the dagger and does NOT do the slash — it stays
> tucked in guard at his side. The dagger hand is NEVER the robot hand, and the dagger stays
> in that same normal hand the whole clip.
> LOCKED SHOT: strict SIDE PROFILE facing the RIGHT edge of the screen the WHOLE clip — never
> turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME SIZE in every frame, boots
> planted dead-center (no sliding). ONE rigid dagger of constant shape, never splits or
> changes hands. Pure flat green #00FF00 background, full body with green margin all around,
> no opponent, no text, no effects, no ground shadow (no cast shadow or dark blob under him).

**`crouch_kick` (↓W — ANTI-AÉREO / lanzador: CUCHILLAZO fuerte hacia ARRIBA con la daga):**

> [Same Zetma from the reference, strict SIDE PROFILE facing RIGHT.] He stays CROUCHED LOW the
> whole clip (one knee bent, hips low, feet planted — he never stands up or straightens his
> legs), and he LEANS his upper body slightly FORWARD as he strikes.
> He grips the dagger with BOTH HANDS together (a two-handed hold on the one blade). Motion:
> he first draws the dagger BACK and down (short windup), then drives it UP and FORWARD with
> force in one strong two-handed rising SLASH toward the upper-right (an anti-air launching
> cut), then returns to the crouched guard. Both arms are NORMAL-length arms doing a normal
> swing — they do NOT stretch, extend or telescope; only a back-then-up-forward swing.
> HANDS — READ CAREFULLY: he has EXACTLY TWO hands, both attached and both gripping the dagger.
> ONE hand is his NORMAL human hand (flesh, cloth glove). The OTHER hand is his MECHANICAL
> BLACK-METAL ROBOT hand (glossy black segments, small orange lights) and it MUST STAY a robot
> hand the whole clip — do NOT turn it into a human/flesh hand. So: one human hand + one robot
> hand, both on the dagger grip. Nothing detaches, duplicates or flies off; no extra or
> floating hand ever appears. ONE rigid dagger of constant shape, never leaves the hands.
> Fixed camera, NO zoom, SAME SIZE in every frame, boots planted dead-center. Pure flat green
> #00FF00 background, full body with room to the upper-right for the blade, no opponent, no
> text, no effects, no ground shadow (no cast shadow or dark blob under him).

**`sweep` (↓E — barrida de pierna, derriba):**

> [Same Zetma from the reference.] He is CROUCHED LOW and stays crouched the ENTIRE clip —
> he never stands up. ONE wide low LEG sweep: his extended leg spins across the floor at
> ankle height, whole front swept, then returns to the crouched guard. LOCKED SHOT: strict
> SIDE PROFILE facing the RIGHT edge of the screen the WHOLE clip — never turns, mirrors or
> goes frontal. Fixed camera, NO zoom (not even in the middle), SAME SIZE in every frame. He
> pivots on one spot, dead-center, no travel across the panel. ONE rigid dagger of constant
> shape (sheathed), never splits or changes hands; his right arm is ONE continuous
> mechanical limb. Pure flat green #00FF00 background, full body with green margin all
> around, no opponent, no text, no effects, no ground shadow (no cast shadow or dark blob under him).

---

## JUMP ATTACKS (aéreos — cuerpo entero en el aire, sin piso)

**`jump_punch` (salto+Q — daga aérea):**

> [Same Zetma from the reference — KEEP HIM IDENTICAL: same mask, same ONE black-metal robot
>
> > arm, same hood, same exact outfit; do NOT add belts/straps/pouches or restyle mask/arms.] He
> > is AIRBORNE the whole clip (feet off the ground, in a jump, over pure green, NO floor — never
> > lands or stands). He does ONE forward DAGGER STAB: his FLESH human hand (bare skin, cloth
> > sleeve, glove) thrusts the dagger forward to the right to a natural human reach, then pulls
> > back. The BLACK-METAL ROBOT arm (glossy metal, orange lights — stays metal, never human) is
> > cocked BACK, empty. He grips the dagger FIRMLY the whole clip (never drops/loosens/releases
> > it). LOCKED SHOT — flat 2D fighting-game sprite: strict SIDE PROFILE facing RIGHT, orthographic,
> > no 3/4 angle, no turning. FIXED camera, NO zoom in/out, no camera move. Character SMALL and
> > FULL-BODY with lots of green margin, NEVER cropped, SAME size every frame, centered. Pure flat
> > green #00FF00 background, no opponent, no text, no effects, no ground shadow (nothing under him).

**`jump_kick` (salto+W — patada aérea):**

> [Same Zetma from the reference — KEEP HIM IDENTICAL: same mask (same shape, same glowing
>
> > eyes), same ONE black-metal robot arm, same hood, same exact outfit. Do NOT add or invent any
> > belt, sash, strap, pouch, buckle or clothing element that is not in the reference, and do NOT
> > restyle the mask or arms.] IMPORTANT — LIMBS: he has only ONE mechanical arm (black metal).
> > Everything else is NORMAL human: BOTH LEGS are normal human legs in black cloth cargo pants
> > and sneakers, and the other arm is flesh/cloth. Do NOT make any leg mechanical/metal, do NOT
> > add robotic parts to the legs or feet — legs stay normal cloth pants the whole clip. He is
> > AIRBORNE the whole clip (feet off the ground, in a jump, over pure green, NO floor — never
> > lands or stands). He throws a HIGH flying KICK: one leg snaps out UP-and-FORWARD to the right
> > at a HIGH angle (the boot rising to around WAIST/CHEST height, kicking upward-forward, NOT a
> > low downward kick), then tucks back — an agile high ninja flying kick. The dagger stays
> > SHEATHED; both arms tucked in. The BLACK-METAL ROBOT arm stays metal (never human). LOCKED SHOT — flat 2D fighting-game sprite: strict SIDE PROFILE
> > facing RIGHT, ORTHOGRAPHIC, no 3/4 angle, no turning. FIXED camera, NO zoom in/out, NO camera
> > move. Character SMALL and FULL-BODY with lots of green margin on all sides, NEVER cropped,
> > SAME size every frame, centered. Pure flat green #00FF00 background, no opponent, no text, no
> > effects, no ground shadow (nothing under him — he is in the air).

**`air_spin_kick` (salto+E — patada giratoria aérea):**

> [Same Zetma from the reference — KEEP HIM IDENTICAL: same mask, same ONE black-metal robot
>
> > arm, same hood, same exact outfit; do NOT add clothing elements or restyle mask/arms.] He is
> > AIRBORNE the whole clip (feet off the ground, jump, NO floor — never lands/stands). He does a
> > spinning/roundhouse AIR KICK: one leg snaps out to the right and whips around, then tucks
> > back — a pure LEG kick (NO arm-extend/telescoping; that is a special move only). Dagger stays
> > SHEATHED, both arms tucked; the metal robot arm stays metal. LOCKED SHOT — flat 2D sprite:
> > strict SIDE PROFILE facing RIGHT, orthographic, no turning. FIXED camera, NO zoom, no camera
> > move. Character SMALL, FULL-BODY, lots of green margin, never cropped, same size every frame,
> > centered. Pure flat green #00FF00 background, no opponent, no text, no effects, no ground shadow.

**`air_jab` (salto+R — jab mecánico aéreo):**

> [Same Zetma from the reference — KEEP HIM IDENTICAL: same mask, same ONE black-metal robot
>
> > arm, same hood, same exact outfit; do NOT add clothing elements or restyle mask/arms.] He is
> > AIRBORNE the whole clip (feet off the ground, jump, NO floor). Clear WIND-UP first: he
> > COCKS his BLACK-METAL ROBOT fist BACK to his shoulder/chest, elbow bent, shoulder twisting
> > slightly — you SEE him load the punch — THEN he snaps that fist forward into a quick short
> > JAB and pulls it back to guard. Three beats: pull back → punch out → recover. The fist stays
> > BLACK-METAL ROBOT (glossy metal, orange lights — stays metal, never human), punches out a
> > SHORT distance to the right. Fast and light, small motion (NO long arm-extend, the arm does
> > NOT telescope). NO DAGGER AND NO BLADE ANYWHERE in the whole clip — the dagger is NOT drawn,
> > NOT held, NOT visible; nothing comes out of either hand. His OTHER hand (the flesh hand) hangs
> > relaxed and EMPTY at his side and does nothing. This is a pure bare-fist robot punch — zero
> > weapons on screen. LOCKED SHOT — flat 2D sprite: strict
> > SIDE PROFILE facing RIGHT, orthographic, no turning. FIXED camera, NO zoom, no camera move.
> > Character SMALL, FULL-BODY, lots of green margin, never cropped, same size every frame,
> > centered. Pure flat green #00FF00 background, no opponent, no text, no effects, no ground shadow.

---

## EXTENSIBLE-ARM KIT (el corazón del personaje) — brazo mecánico + AGARRES

> El poder de Zetma es UNO solo: su brazo mecánico negro se ESTIRA/telescopea** al frente para
> AGARRAR. El brazo extensible es un clip del PERSONAJE (no un FX aparte): se ve el metal negro
> con luces naranjas alargándose por segmentos telescópicos. Reglas del estirado (valen para
> TODOS los agarres): SOLO el brazo mecánico se alarga; el resto del cuerpo queda quieto. El
> brazo se extiende por **segmentos rígidos que se deslizan** uno fuera de otro (telescópico,
> mecánico) — NO se estira como goma/carne, NO crece orgánicamente, NO es una cadena. **El brazo
> solo se ALARGA (gana LARGO), NUNCA se ENGORDA:** mantiene el MISMO grosor/ancho delgado del
> brazo normal en toda su extensión, no se vuelve más grueso, ancho ni voluminoso. **NO deformar
> el cuerpo:** el brazo sale de su hombro NORMAL de siempre; NO aparece un segundo hombro, ni una
> articulación/hombro extra en medio del brazo, ni un brazo/extremidad de más en un lugar
> equivocado. Solo su brazo de siempre, más largo. La mano es su **mano de metal negro NORMAL\*\*
> (tamaño normal, no una garra gigante) que se ABRE al salir y se CIERRA al final como agarrando.
> La daga sigue en la mano de CARNE (el otro brazo), nunca en el brazo que se estira.
> En inglés: _"The robot arm only gets LONGER (extends in length); it NEVER gets thicker or
> wider — it keeps the SAME slim thickness as his normal arm along its whole length. Do NOT
> deform his body: the arm comes from his ONE normal shoulder — do NOT add a second shoulder, an
> extra joint/shoulder mid-arm, or any extra limb in the wrong place. Just his normal arm, made
> longer, ending in his NORMAL-size robot hand (not a giant claw)."_

**`ground_grab` (↓→+E — AGARRE DESDE EL SUELO):** _(agarre de pie)_

> [Same Zetma from the reference — he faces RIGHT.] Standing on the ground, he winds his
> BLACK-METAL ROBOT arm back a little, then SHOOTS that arm FORWARD to the RIGHT — the metal
> arm EXTENDS far out in front of him by rigid telescoping segments (the segments slide out of
> each other like a mechanical piston, straight and rigid, NOT rubbery, NOT organic, NOT a
> chain). The arm only gets LONGER, keeping its SAME slim thickness (it does NOT get thicker or
> wider), coming from his ONE normal shoulder with NO extra shoulder or joint added. It ends in
> his NORMAL black-metal robot HAND (ordinary size, NOT an oversized claw, nothing new appears):
> the hand simply OPENS and reaches out to GRAB. At full reach the HAND grips/CLOSES shut as if
> seizing an enemy, and then he PULLS: the closed hand RETRACTS back sharply toward his own body
> as if YANKING/DRAGGING the grabbed enemy in toward him — a clear hard PULL motion, his shoulder
> and torso leaning BACK and bracing with the effort of pulling, the metal segments collapsing
> back in fast — ending with the arm pulled back near his body in guard. The sequence reads
> clearly: shoot out → hand grabs → PULL/yank it back in. Only the
> robot arm moves/extends — his torso stays roughly in place (it may lean back with the pull),
> legs and boots stay planted, he does NOT walk or slide forward. The OTHER (flesh) hand keeps
> holding the SINGLE dagger the whole time; the dagger is NEVER on the extending metal arm and
> never disappears. Orange lights glint along the metal segments. LOCKED SHOT: strict SIDE
> PROFILE facing the RIGHT edge of the screen the WHOLE clip — never turns, mirrors or goes
> frontal. Fixed camera, NO zoom (not even in the middle), SAME SIZE in every frame — leave
> EXTRA green room on the RIGHT so the fully-extended arm+claw fits inside the frame, never
> cropped. He stays roughly centered. Pure flat green #00FF00 background, full body with green
> margin all around, no opponent, no text, no effects, no ground shadow (no cast shadow or dark blob under him).

**`air_grab` (↓→+E saltando — AGARRE DESDE EL AIRE):** _(agarre aéreo)_

> [Same Zetma from the reference — he faces RIGHT.] He is AIRBORNE the whole clip (jumping,
> feet off the ground, NO floor). At the top of his jump he SHOOTS his BLACK-METAL ROBOT arm
> DOWN-AND-FORWARD (diagonally toward the lower right) — the metal arm EXTENDS far by rigid
> telescoping segments (segments sliding out of each other like a mechanical piston, straight
> and rigid, NOT rubbery, NOT organic, NOT a chain). It is just his NORMAL black-metal robot
> HAND at the end of the arm (the same ordinary hand, NORMAL size — NOT an oversized claw, NOT
> giant talons, and nothing new appears out of nowhere): the hand simply OPENS and reaches down
> to GRAB an enemy below, then the HAND CLOSES/grips as if seizing them. At full reach the hand
> grips shut, and then he PULLS: the closed hand RETRACTS back sharply UP toward his own body as
> if YANKING/DRAGGING the grabbed enemy up toward him — a clear hard PULL motion, his torso
> recoiling with the effort, the metal segments collapsing back in fast — ending with the arm
> pulled back near his body. The sequence reads clearly: shoot down → hand grabs → PULL/yank it
> back up. Only the robot arm extends; his body stays in the jump pose, legs tucked, and he
> does NOT land or stand up — he stays AIRBORNE. The OTHER (flesh) hand keeps holding the SINGLE
> dagger the whole time; the dagger is NEVER on the extending metal arm and never disappears.
> Orange lights glint along the metal segments.
> LOCKED SHOT: strict SIDE PROFILE facing the RIGHT edge of the screen the WHOLE clip — never
> turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME SIZE in every frame — leave EXTRA
> green room toward the LOWER RIGHT so the fully-extended arm+claw fits inside the frame, never
> cropped. Pure flat green #00FF00 background, full body with green margin all around, no
> opponent, no text, no effects, no ground shadow (nothing under him — he is in the air).

### SUPER — VOID ORB (ESFERA DE VACÍO)

> **(ES) Este es el súper REAL de Zetma en el juego (comando ↓ ← E, con su propio anillo de carga).**
> La esfera atrapa al rival en CÁMARA LENTA y lo drena. **El arte de la esfera va APARTE** (shader
> procedural del motor), igual que las esferas de Aye — el clip del personaje es **solo el gesto de
> casteo**, sin dibujar la esfera. _(El viejo MEGA GRAB quedó DESCARTADO, no se implementó.)_

**`orb_cast` (súper — carga y lanza la esfera de vacío):** _(clip del personaje)_

> [Same Zetma from the reference — he faces RIGHT.] He plants his feet and raises the black-metal
> robot arm FORWARD to the RIGHT, the forearm reshaping into a short CANNON / emitter aimed straight
> ahead; dark void energy gathers and crackles at the open muzzle as he WINDS UP, then he THRUSTS the
> arm forward and releases the shot straight ahead, HOLDING the extended cast pose at the end (arm
> locked out toward the right). Only the robot arm moves; torso and boots stay planted, no
> walking/sliding. The OTHER (flesh) hand keeps holding the SINGLE dagger the whole time; the dagger
> never disappears. **Do NOT draw the orb / sphere / energy ball itself — the game spawns and tints
> it; his hand and the muzzle stay EMPTY, this clip is ONLY the casting gesture.** LOCKED SHOT: strict
> SIDE PROFILE facing the RIGHT edge of the screen the WHOLE clip — never turns, mirrors or goes
> frontal. Fixed camera, NO zoom (not even in the middle), SAME SIZE in every frame — leave extra green
> room on the RIGHT for the extended arm, never cropped. He stays roughly centered, natural believable
> motion (no unnatural or broken poses). Pure flat green #00FF00 background, full body with green margin
> all around, no opponent, no text, no other effects, no ground shadow (no cast shadow or dark blob under him).

---

## RECIBIR DAÑO / DEFENSA / FINAL

**`take_hit` (golpeado de pie):**

> [Same Zetma from the reference.] An invisible blow snaps him: his head and torso whip
> BACKWARD (to the left) sharply as if struck in the chest, then he recovers his guard. A
> quick sharp whiplash — jerks back and returns. LOCKED SHOT: strict SIDE PROFILE facing the
> RIGHT edge of the screen the WHOLE clip — never turns, mirrors or goes frontal. Fixed
> camera, NO zoom, SAME SIZE in every frame. He stays DEAD-CENTER with boots planted in
> place. ONE rigid dagger, never changes; right arm ONE continuous mechanical limb. Pure
> flat green #00FF00 background, full body with green margin all around, nobody touches him,
> no opponent, no text, no effects, no ground shadow (no cast shadow or dark blob under him).

**`take_hit_low` (golpeado abajo):**

> [Same Zetma from the reference.] An invisible low blow folds him: he doubles over, head
> dropping toward his waist as if hit in the gut, staggering, then straightens back to
> guard. The whole body crunches down and rises. LOCKED SHOT: strict SIDE PROFILE facing the
> RIGHT edge of the screen the WHOLE clip — never turns, mirrors or goes frontal. Fixed
> camera, NO zoom, SAME SIZE in every frame. He stays DEAD-CENTER with boots planted in
> place. ONE rigid dagger, never changes; right arm ONE continuous mechanical limb. Pure
> flat green #00FF00 background, full body with green margin all around, no opponent, no
> text, no effects, no ground shadow (no cast shadow or dark blob under him).

**`hit-fly.mp4` (lanzado por los aires → se estrella) — de este saco `hit_fly` + `hit_down`:**

> [Same Zetma from the reference.] An invisible force BLASTS him off his feet: his whole
> body is LAUNCHED up-and-back to the LEFT in a knockout ragdoll — limbs loose, head thrown
> back, no control — flies in an arc and CRASHES flat onto his back on the ground, bounces
> once, slides, and ends sprawled motionless on his back with his head toward the LEFT and
> boots toward the RIGHT. He GRIPS his SINGLE dagger in his flesh hand the ENTIRE time — the
> dagger stays HELD in his hand through the whole launch, flight and crash, and is still in his
> hand when he lands; it NEVER disappears, NEVER gets sheathed, NEVER leaves his grip. He does
> NOT somersault, does NOT do a full flip or spin, does NOT rotate head-over-heels — his body
> keeps the SAME side-facing orientation the whole time (he never flips to the other side); he
> just gets knocked back flat and lands on his back. CAMERA HARD-LOCKED, STATIC WIDE — the
> framing of the first frame is the framing of every frame, NO zoom, NO following him: his
> whole body stays inside the fixed frame the entire flight and crash, SAME SIZE. Strict side
> view, he does not mirror or turn to face the other direction. Pure flat green #00FF00
> background, no smoke, no dust, no opponent, no effects, no ground shadow (no cast shadow or dark blob under him).

**`ko-face-up.mp4` (derrotado, cae de espaldas):**

> [Same Zetma from the reference — he faces RIGHT.] He gets knocked out and TIPS OVER
> BACKWARD, toppling toward the LEFT edge of the screen (the direction BEHIND him, away from
> the right side he faces), like a boxer falling flat when KO'd: his head and shoulders drop
> back toward the ground FIRST while his boots slide out, and his SPINE / BACK hits the floor,
> leaving him lying FACE-UP with his belly, chest and the front of his mask pointing UP toward
> the SKY/ceiling. CRITICAL: he does NOT slump or pitch FORWARD, does NOT fall toward the
> right, does NOT face-plant, does NOT land on his stomach, chest, hands or knees — he falls
> BACKWARD and lands on his BACK, face-up. He holds the lying pose. Keep the fallen pose
> COMPACT, NOT spread
> out: his torso stays fairly gathered, ONE knee is bent up (legs not stretched straight out),
> his arms rest CLOSE to his body (not flung wide) — the whole body occupies a SHORT horizontal
> span, like a crumpled defeated heap, NOT a full-length spread-eagle sprawl. He KEEPS his
> SINGLE dagger in his flesh hand (or it rests right next to that hand) — the dagger does NOT
> fly off far away across the ground. ONE continuous collapse. CAMERA HARD-LOCKED, STATIC WIDE,
> NO zoom, SAME SIZE every frame, strict side view facing right (no mirror), boots planted
> until the fall, body stays inside the frame. Pure flat green #00FF00 background, no opponent,
> no effects, no ground shadow (no cast shadow or dark blob under him).

**`get-up.mp4` (se levanta hasta la guardia):**

> [Same Zetma from the reference.] Lying on his back, he rolls up, pushes to one knee, and
> springs back up to his low ninja guard in one fluid motion, ending in his standing stance.
> CAMERA HARD-LOCKED, STATIC WIDE, NO zoom, SAME SIZE every frame, strict side view facing
> right (no mirror), he rises IN PLACE (feet stay on the same spot), body inside the frame.
> Pure flat green #00FF00 background, no opponent, no effects, no ground shadow (no cast shadow or dark blob under him).

**`block.mp4` (bloqueo de pie):**

> [Same Zetma from the reference.] A DEFENSIVE BLOCK, seen in STRICT SIDE PROFILE facing RIGHT.
> Motion sequence: he starts from his stance, then quickly PULLS his SINGLE dagger UP and IN
> toward his own chest/face into a GUARD — blade held roughly VERTICAL close in front of his
> body like a small shield, elbows tucked in — and his BLACK-METAL ROBOT forearm braces in
> beside it. As the guard sets, his whole body RECOILS BACKWARD a little (leans/flinches away,
> weight shifting onto the back foot) as if an invisible blow lands on his guard and shoves him
> back, then he settles and holds the guard. This is CLEARLY defensive: every motion goes
> TOWARD his own body or BACKWARD — he NEVER thrusts, NEVER stabs, NEVER swings, NEVER reaches
> or steps FORWARD, nothing ever moves toward the right/forward. The dagger only comes IN to
> shield him, never out. EXACTLY ONE DAGGER in the whole image, held in his flesh hand only;
> the ROBOT forearm is EMPTY (bare black-metal arm, NO weapon, NO second dagger). Do NOT give
> him two daggers, do NOT put a blade in the robot hand. The single dagger keeps a steady
> constant shape; the robot arm stays BLACK-METAL. LOCKED SHOT: strict SIDE PROFILE facing the
> RIGHT edge of the screen the WHOLE clip — he STAYS sideways, NEVER turns frontal, NEVER faces
> the viewer, never mirrors, never shows his back. Fixed camera, NO zoom, SAME SIZE every
> frame. He stays roughly centered with boots planted (only the small backward flinch). Pure
> flat green #00FF00 background, full body with green margin all around, nothing touches him, no opponent, no effects, no ground shadow (no cast shadow or dark blob under him).

**`block_low.mp4` (bloqueo agachado):**

> [Same Zetma from the reference.] A DEFENSIVE LOW BLOCK, strict SIDE PROFILE facing RIGHT,
> CROUCHED LOW the entire clip (knees deeply bent, compact, head down). The KEY read: he
> BRINGS his BLACK-METAL ROBOT forearm UP AND FORWARD, presenting it edge-on OUT TOWARD THE
> RIGHT/FRONT like a raised SHIELD to intercept a low blow coming from the front, and his
> OTHER (flesh) hand brings the DAGGER forward too, braced in beside/behind the robot forearm
> to reinforce that forward guard (blade angled flat to deflect). The forearm-and-dagger guard
> is clearly EXTENDED toward the incoming attack — the robot arm FACES the blow — so it is
> OBVIOUS he is blocking (not just hugging himself). He braces there and ABSORBS hits from the
> front-low with small BACKWARD/DOWNWARD jolts (the guard gets shoved and holds), never rising,
> staying crouched. This is CLEARLY a BLOCK, NOT an attack: the arm and dagger come forward to
> SHIELD and BRACE and then HOLD firm — he NEVER thrusts, NEVER stabs, NEVER swings, no strike
> motion; the guard only presents forward and holds steady. EXACTLY ONE DAGGER, in his flesh
> hand only; the ROBOT forearm is EMPTY black-metal (NO weapon in the robot hand, NO second
> dagger). The dagger keeps a steady constant shape; the robot arm stays BLACK-METAL, one
> continuous limb. LOCKED SHOT: strict SIDE PROFILE facing the RIGHT edge of the screen the
> WHOLE clip — never turns, mirrors or goes frontal. Fixed camera, NO zoom, SAME SIZE every
> frame. He stays DEAD-CENTER, crouched, boots planted in place. Pure flat green #00FF00
> background, full body with green margin all around, no opponent, no effects, no ground shadow (no cast shadow or dark blob under him).

**`parry.mp4` (postura de desvío — Q+W):**

> [Same Zetma from the reference.] Pure DEFENSIVE deflect — he NEVER attacks, NEVER swings the
> dagger, NEVER punches. ONE quick defensive SNAP then a tense HOLD: he raises his DAGGER-hand
> and his BLACK-METAL ROBOT forearm together up-and-across into a tight DEFLECT guard angled in
> front of his face (blade held flat/edge-out to turn a blow aside, NOT stabbing), coiled
> sideways behind it, eyes locked forward-right, then HOLDS that ready deflect stance for the
> rest of the clip (only breathing, hood settling). The motion is a SHORT tight snap to guard,
> the arms do NOT reach out or strike. He does NOT swing, does NOT return to neutral guard —
> ends still holding the deflect. The dagger is DRAWN and held (blade steady, constant shape,
> never splits or changes hands); the robot arm stays BLACK-METAL, ONE continuous limb. LOCKED
> SHOT: strict SIDE PROFILE facing the RIGHT edge of the screen the WHOLE clip — never turns,
> mirrors or goes frontal. WIDE STATIC ORTHOGRAPHIC shot, fixed flatbed scanner (not a movie
> camera): SAME body SIZE every frame (never grows/shrinks/gets closer — a size change is a glitch,
> FORBIDDEN), green margin on all sides that never tightens. He stays DEAD-CENTER with boots planted in place. Pure flat green #00FF00 background,
> full body with green margin all around, no opponent, no effects, no ground shadow (no cast shadow or dark blob under him).

**`victory.mp4` (pose de VICTORIA — REVEAL: se vira de espalda, se quita la máscara y le cae el pelo largo morado):**

> ⚠️ ESTA POSE ES LA EXCEPCIÓN: **SÍ gira** (de perfil a mostrar la ESPALDA / 3-4 traseros) — es un reveal cinematográfico, NO respeta el "strict side profile" de las demás.
>
> [Same Zetma from the reference — SAME outfit exactly: SHORT hooded jacket ending at the waist with dark-purple accents (NO long coat-tail/skirt/robe hanging below the waist), ONE full BLACK MECHANICAL right arm (metal, orange lights) and the other arm flesh + cloth glove, black cargo pants with purple straps, black sneakers with purple soles. His legs and feet are NORMAL (human) — never mechanical.] A slow, calm VICTORY pose — he has WON and lowers his guard. He starts in side profile facing right, then TURNS AWAY from the camera to show his BACK (rotating to a back / three-quarter-back view, we see the back of his short hooded jacket). He pushes his HOOD DOWN off his head, and his BLACK-METAL MECHANICAL hand reaches up and SLOWLY PULLS OFF his black mechanical mask (a plain matte-black mask with four narrow eye-slits — the slits are DARK, NOT lit, NOT glowing, and are NOT green — comes away in his metal hand), and as the mask lifts free his LONG PURPLE HAIR SPILLS/CASCADES DOWN loose over his back and shoulders (long, flowing dark-purple hair that was hidden under the hood and mask). He holds the removed matte-black mask down at his side in the mechanical hand (its four eye-slits stay DARK and unlit — no green, no glow), head tilted slightly, calm and menacing, victorious. ⛔ THE MASK EYES ARE NEVER GREEN and NEVER GLOW in this clip — do NOT paint any green, toxic-green, neon or lit eyes on the mask (green reads as background and gets keyed out, leaving holes). His FLESH hand still grips the black purple-handled DAGGER (never disappears). A quiet, confident, dangerous, calm air. Reads clearly: standing → turns to show his back → hood down → metal hand removes the mask → long purple hair falls loose → holds the final unmasked, back-turned pose. This is the ONLY pose where he turns his back and where his face/hair is revealed.
>
> ⛔⛔ WIDE STATIC ORTHOGRAPHIC SHOT — the camera is a fixed flatbed scanner, not a movie camera. Treat this like a GAME SPRITE-SHEET animation exported from a fixed rig: every frame is the SAME sprite drawn at the SAME scale, like frames on a sheet. The framing is FROZEN and IDENTICAL in every frame — the first frame's framing IS the last frame's framing. He stays the EXACT SAME SIZE and SAME height in EVERY single frame from first to last — his head-to-boots pixel height is IDENTICAL in frame 1 and the final frame and must not change even 1% at any moment (no growing, no shrinking — a size change looks like a glitch and is FORBIDDEN). Keep him SMALL in the frame with LOTS of empty green margin on ALL FOUR sides the whole time — the wide margin never tightens. Boots planted DEAD-CENTER on the SAME ground line the whole clip — he ONLY turns his body in place (no sliding, no drifting, no rising up, no crouching lower — his standing height stays constant, only his facing rotates). ⛔ KEEP HIM IDENTICAL: his design, body proportions, height, build, face, hair, hands, arms, outfit and colors stay EXACTLY like the reference the whole clip — do NOT restyle, redesign, age, beautify or change him. His anatomy stays CORRECT and CONSISTENT: hands, fingers, arms, legs and face do NOT morph, melt, warp, break, distort, duplicate, swap or grow/lose parts; the mechanical arm stays ONE clean metal limb and the flesh hand stays a normal 5-finger hand. ⛔ ZERO effects: NO smoke, NO dust, NO mist, NO fog, NO haze, NO glow, NO aura, NO green energy, NO sparks, NO particles, NO wind, NO speed lines — ONLY the character himself (the game adds any effects). NO opponent, NO text. Pure flat green #00FF00 background, full body head-to-boots with green margin all around, no ground shadow (no cast shadow or dark blob under him).

---

## Recordatorios

- Cada bloque de arriba ya es un prompt completo — **copiás uno, pegás la referencia, listo.**
- Guardá los clips en `imagen-action/zetma/sheets/<accion>.mp4` y avisame.
- Orden sugerido: `pose` (✅ hecho) → `walk`, `jump`, `crouch` → dagas (Q/W) → los AGARRES del
  brazo extensible (`ground_grab`, `air_grab`, `mega_grab_cast`).
- Paleta lock: **negro + morado + verde tóxico** (acentos naranjas del metal). NO fuego, NO
  agua, NO cristales, **NO clones/sombras** (ese poder se eliminó).
- Lo #1 a vigilar: **el brazo mecánico se estira = segmentos telescópicos rígidos** (no goma,
  no orgánico, no cadena), la mano es una **garra de metal negro** que se cierra al agarrar, y
  **siempre de perfil a la derecha** (que no se voltee). Dejá margen verde extra hacia donde se
  estira el brazo para que la garra NO se recorte.
