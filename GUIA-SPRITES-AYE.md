# AYE — Crystal Witch (ZONER) · Animation guide (describe the MOVEMENT)

> **(ES) Nota para vos:** los prompts están en **INGLÉS** para que la herramienta de IA
> los entienda mejor. Pegá cada bloque tal cual. Los títulos de sección van en inglés,
> pero cualquier duda me preguntás en español.

> AYE-specific guide, the 3rd fighter. She is a **LONG-RANGE MAGE / WIZARD (ZONER)**:
> she controls space with **PURPLE CRYSTALS** shot from her crystal-flower staff. Her
> signature is **CAPTURE/FREEZE** — trapping the opponent inside a purple crystal.

> **NEW WORKFLOW (important):** we no longer build sprite sheets. We now use an
> **ANIMATION tool**: we give it **Aye's reference image** + a **prompt that DESCRIBES
> THE MOVEMENT** we want, and the tool generates the animation itself; **I then process
> it** for the game. So this guide is just a list of **MOVEMENT DESCRIPTIONS**, one per
> animation — we never ask for counts or sheets, we only describe HOW she moves.

> **What rules ALL her animations:**
>
> 1. She wields a **STAFF** (straight purple shaft, pink/magenta crystal flower at the tip).
> 2. Her energy is **PURPLE/LILAC CRYSTALS** and sparkles (NO fire, NO water; the only
>    floral element is the crystal flower on the staff tip).
> 3. She is a **ZONER**: her strength is at range (projectiles, pillars, freezing). Her
>    close combat is **short and weak ON PURPOSE** — staff pokes just to push and gain
>    space, not long combos.

---

## Generation rules (apply to EVERY prompt)

Always set these, and attach **Aye's reference image** as the starting image (for the
face use `aye-face`; for body/pose use the #133 reference):

- **Aspect ratio: 1:1 (square)** — NOT 9:16 vertical (vertical crops the weapon on swings).
- **LOCKED / FIXED camera**: no zoom, no pan, no push-in or pull-out. CRITICAL (if the
  camera moves I can't process a clean animation).
- **Aye ALWAYS centered, the SAME SIZE the whole time**, full body, feet visible on a flat
  ground line, **side view facing RIGHT**.
- **She moves IN PLACE** (walks/jumps/spins without traveling or leaving the frame, like on
  a treadmill). She never exits the frame, not even during a swing.
- **PURE GREEN #00FF00 flat, STATIC background**, no ground shadow, no text/marks, no
  background particles.
- **STRAIGHT, RIGID staff** (a ruler-straight rod, never curved/bent) and an **UPRIGHT,
  STRAIGHT BACK**.
- **PLAIN staff, NO effects — in EVERY animation:** the staff has NO glow, aura, energy or
  sparkle on the shaft, and **NO crystals floating/orbiting** around her. All crystal magic
  (charge, shards, prison, pillar, rain, impact) lives ONLY in the **separate EFFECT clips**
  (over green, no character) — the engine composites it on top. The crystal flower at the tip
  is a PHYSICAL part of the staff (always present), but with **no extra glow**.
- **Empty green space on the LEFT and RIGHT** so staff swings don't get cut (see "Framing").
- No camera blur or post FX; the motion must look **crisp**.

**Saving:** save whatever the tool outputs (clip or image) into `imagen-action/aye/sheets/`
named after the action (e.g. `walk`, `crystal-cast`). I process it into
`imagen-action/aye/<action>/aye-<action>-N.png`.

---

## AYE design (reference image #133 — this is CANONICAL)

Paste this design block into EVERY prompt, along with the reference image:

> The EXACT same character as the reference — a CHIBI anime-style illustration, a small
> fantasy MAGE (a video-game character, stylized cartoon art, NOT a real person or a photo):
> brown skin, dark-brown CURLY hair tied in a **HIGH PONYTAIL** with a **PINK scrunchie**
> (loose curly strands), big anime eyes. She wears a **LILAC/lavender PUFF-SLEEVE DRESS**
> (short puff sleeves), a square neckline with **GOLD trim**, a big **PINK BOW** at the
> waist, a **PINK underskirt** peeking below, and a gold-trimmed hem. She wears **gradient
> RAIN BOOTS** (top to bottom: yellow → pink → light blue) with pink pull loops. Her weapon
> is a **STAFF** with a long, thin, **PERFECTLY STRAIGHT purple shaft** (like a spear shaft,
> never curved or bent), tipped with a **CRYSTAL FLOWER** (faceted pink/magenta crystals in
> an open-lotus shape). She holds it with a **STRAIGHT BACK and UPRIGHT torso** — firm,
> elegant posture, shoulders back; NEVER hunched or bent over the staff. **Keep the SAME
> size and the SAME proportions (head-to-body ratio) the WHOLE time** — never more big-headed
> or chubbier. Her energy is faceted PURPLE/LILAC CRYSTALS and magenta sparkles — NO fire,
> NO water, NO katana, NO needles: ONE staff with a crystal flower. Same palette and same
> line style. 2D fighting-game side view (KOF style), facing **RIGHT**. Full body with margin
> (nothing cropped by the edge). Correct anatomy: TWO arms, TWO legs, TWO five-fingered hands,
> and ONE single staff (one continuous piece, never fragmented or duplicated). The dress hem
> stays NORMAL and clean (NOT torn). PURE GREEN #00FF00 flat background with no marks.

### Framing and SIDE SPACE (key for swings)

The framing must leave **empty green space on the LEFT and RIGHT** of Aye the WHOLE time, so
a **staff swing** doesn't get cut (see the viking reference, image #147: character centered
with plenty of green on both sides and front/back).

- **1:1 square** (not 9:16 vertical, which cuts the weapon on swings).
- Aye takes up **~60% of the height**, centered, with **green margin on all 4 sides**: at
  least **half a body-width** of green on the left and right, plus headroom and footroom.
- The **staff at full extension NEVER touches the frame edge**.
- Same body size and feet on the same line the whole time.
- _(My processing: 1300×1280 canvas, body centered at x=650 → ~475px free on each side; for
  very long staff swings I widen the canvas to 1600, which is safe.)_

---

## How she should MOVE (SF3 / Dudley quality)

This is what makes her look CRISP and FLUID — describe it in the prompts when relevant:

1. **Idle and walk are ALIVE and LOOP:** they end where they started (the last instant links
   to the first) so the cycle doesn't jump. The idle is NOT static: she breathes.
2. **Every attack has 3 beats:** _anticipation (wind-up/charge) → fast strike (the fast part
   leaves a light motion streak at the staff tip) → impact → recovery to GUARD._ Never jump
   straight from guard to impact. **Start and end in the guard pose** (so the motion links and
   closes cleanly).
3. **Subtle squash & stretch:** on impact the body compresses/stretches a touch; on landing a
   jump it squashes for a moment.
4. **CONSTANT volume and silhouette:** she is the same size and weight the whole time; the pose
   should read even as a silhouette.

---

## MOVEMENT PROMPTS (one per animation)

> For each: paste the **design block** above + the **generation rules** + the movement text
> below. All: fixed camera, in place, facing right, pure green. **In ALL of them: the staff is
> PLAIN (no glow/effect) and NO floating crystals; crystal magic lives ONLY in the separate
> EFFECT clips.**

### BASE — do these first (they make her playable)

**`pose` (idle):**

> Aye stands in a mage guard, still in place, **breathing softly**: chest rises and falls
> slowly, shoulders relaxed, a minimal sway. She **holds the staff with ONE hand** down-front
> (crystal flower pointing forward), the other hand relaxed at her side. The **staff is PLAIN,
> with no glow or effect, and NO crystals floating** around her. Minimal, calm motion, **closed
> loop**. Feet planted.

**`walk`:**

> Aye walks IN PLACE (like on a treadmill, without traveling), side view facing right, in a
> combat guard: torso firm, staff always ready. **Clear, natural leg cycle** (heel contact →
> plant → push-off → legs crossing), a slight up-and-down bob, ponytail and skirt swaying a bit.
> Determined pace. Continuous loop, same size, feet on the same line. Plain staff: no glow, no
> beam, no crystals, no magic effects.

**`walk_back` (retreat — BACKWARD HOPS):**

> The tool keeps turning a "backward jumping" into a forward walk, so we use BACKWARD HOPS
> instead — a distinct motion it animates reliably, and a cute retreat for her. Paste this as
> don't make her smile or talking
> PLAIN TEXT (no markdown symbols), with the design block + reference image

A cute chibi anime fantasy mage character, cartoon video-game art, side view. She stays
turned to the RIGHT the whole time, looking at an enemy on her right. She does small light
HOPS BACKWARD, jumping to the LEFT: she bends her knees a little, pushes off both feet, hops
up and lands a short distance to the LEFT, then immediately hops backward again, over and over,
like a bunny hopping in reverse. She is hopping AWAY from the enemy, moving to the LEFT, but her
face and chest keep pointing to the RIGHT the entire time. She never turns around and never
faces left. She holds a plain straight purple staff with a crystal-flower tip in ONE hand, and
the staff has no glow and no floating crystals around her. Pure green screen background, flat and
static. The hops loop smoothly and evenly, same size, feet landing on the same ground line. Do
not walk forward. Do not move to the right. Do not turn around.

**`crouch`:**

> Aye crouches from the guard down into a squat and holds it: bends knees, lowers her center,
> tucks the staff across her knees, torso compact but back straight. Short, firm motion. Plain
> staff: no glow, no beam, no crystals, no magic effects.

**`jump`:**

> Aye jumps straight up in place: bends knees (anticipation, compresses for a moment) →
> pushes up with the staff held close → apex → falls → squashes for a moment on landing. She goes
> up and down inside the frame (never leaves it). Plain staff: no glow, no beam, no crystals, no
> magic effects.

**`neutral_spin` (FORWARD jump / mortal — spinning leap) — OPTIONAL:**

> ⚠️ OPTIONAL: right now Aye's forward jump just reuses the normal `jump` (no separate spin).
> Only make this if you want a distinct spinning forward-jump; if its frames exist, the engine
> uses it for forward jumps automatically. A COMBAT spinning leap with the staff, NOT joyful.
> Paste as PLAIN TEXT:

```
A cute chibi anime fantasy mage character, cartoon video-game art, side view. This is a COMBAT
forward jump for a fighting game: she leaps UP and slightly FORWARD (to the right, toward an
enemy) while doing ONE controlled spin in the air, sweeping her straight purple crystal-flower
staff around her body in a circle. Serious, focused expression, NOT joyful, NOT cheering. She
takes off from the ground, spins once in mid-air, and comes back down. Compact and controlled
(not arms flailing). She stays inside the frame the whole time. The staff is a plain straight
rod with NO glow, NO sparkles, NO floating crystals, and NO effects of any kind. Pure green
screen background #00FF00, flat and static. Do NOT smile or cheer; do NOT add any effect on the
staff.
```

### CLOSE COMBAT (short and weak — she's a zoner)

**`weak_punch`:**

> PHYSICAL melee, NOT magic. Aye does a quick short POKE forward with the tip of the staff (used
> as a stick) to jab the enemy on her right, then snaps back to guard. Fast, short reach, serious
> expression. NO effects: no beam, no glow, no crystals, no magic — just a plain physical
> stick-poke. Start and end in guard.

**`punch`:**

> PHYSICAL melee, NOT magic. Aye grips the staff like a POLE and THRUSTS it straight forward to
> jab/poke the enemy at chest height, then pulls it back to guard (draw back → thrust → recover).
> Quick physical stick-strike, serious combat expression. NO effects: do NOT cast a spell, do NOT
> shoot a beam/ray/projectile, do NOT make the crystal glow — the staff is a plain solid rod, no
> magic. Start and end in guard.

**`kick` (W) = ICE-GROW — she summons a purple ice/crystal PILLAR from the ground:**

> NOTE (for you, do NOT paste this line): the W is NOT a physical kick — Aye INVOKES her purple
> ice pillar from the ground. TWO SEPARATE generations: (1) Aye's cast = the `kick` clip below;
> (2) the `ice-grow` effect = the second block. Paste ONLY the code blocks, ONE at a time. The
> look of the ice = reference #161, but generated on green.

Aye's cast (the `kick` clip) — PASTE THIS:

```
A cute chibi anime fantasy mage character, cartoon video-game art, side view, facing RIGHT,
serious focused expression. She raises her straight purple staff UP high overhead with both hands
(a windup), then SLAMS the bottom of the staff DOWN onto the ground in front of her (to the
right) and plants it firmly, both hands on the staff. She holds that planted pose a moment, then
lifts the staff back up to a guard. She stays standing in place, facing right the whole time. Just
her body movement — plain staff, no glow, no beam, no crystals, NO magic, NOTHING coming out of
the ground or the staff. Pure green screen #00FF00, flat and static.
```

The `ice-grow` effect (separate clip, over GREEN, NO character — look of ref #161):

```
SEPARATE EFFECT CLIP, no character, no person — only the effect over a PURE GREEN screen #00FF00
(flat, static). A single block of PURPLE ICE (frozen ice: icy, jagged, translucent purple with
frosty white edges) — it is ICE, NOT a shiny gemstone or jewel. It ERUPTS and GROWS UPWARD from
the ground: the ground cracks, a sharp purple ice spike bursts out, then the SAME ice keeps
growing taller and taller into one tall jagged purple ice pillar, with a white swirling frost ring
around it and small purple ice shards and frost sparkles flying off. It reaches full height, holds
a moment, then cracks and shatters into purple ice shards. It is ALWAYS the SAME purple ice, just
growing bigger — do NOT add any other element (no fire, no water, no lightning, no plants, no
leaves), NO other colors, NO separate different crystals, only ONE purple ice pillar. Anchored to
the ground at the bottom. Camera fixed. NO character.
```

**`crouch_punch`:**

> PHYSICAL melee, NOT magic. Crouched in a squat, Aye does a quick low POKE forward with the staff
> tip, then pulls back. Short physical stick-poke. NO effects: no beam, no glow, no crystals, no
> magic. Start and end crouched in low guard.

**`crouch_kick` (↓W) = ICE-MOON — she summons a purple ice CRESCENT MOON from the ground:**

> NOTE (for you, do NOT paste this line): ↓W works EXACTLY like W, but the shape that erupts from
> the ground is a purple ice CRESCENT MOON (ref #166) instead of the tall pillar. TWO SEPARATE
> generations: (1) Aye's cast = the `crouch_kick` clip below; (2) the `ice-moon` effect = the
> second block. Paste ONLY the code blocks, ONE at a time. The look of the moon = reference #166,
> but generated on green.

Aye's cast (the `crouch_kick` clip) — PASTE THIS:

```
A cute chibi anime fantasy mage character, cartoon video-game art, side view, facing RIGHT, serious
focused expression. She is in a low crouch/squat. She raises her straight purple staff and SWEEPS
it down in a low arc, then plants the staff tip firmly on the ground in front of her (to the right)
and holds, both hands on the staff, staying low. She holds that planted pose a moment, then lifts
back up to a low guard. She stays crouched in place, facing right the whole time. Just her body
movement — plain staff, no glow, no beam, no crystals, NO magic, NOTHING coming out of the ground
or the staff. Pure green screen #00FF00, flat and static.
```

The `ice-moon` effect (separate clip, over GREEN, NO character — shape of ref #166):

```
SEPARATE EFFECT CLIP, no character, no person — only the effect over a PURE GREEN screen #00FF00
(flat, static). A single PURPLE ICE CRESCENT MOON, shaped EXACTLY like ref #166 and kept in that
EXACT SAME upright orientation the whole time (the crescent's outer curve on the LEFT, opening to
the RIGHT, both horns pointing UP) — translucent faceted purple ice with frosty white cracked edges
and thick curved horns. It is ICE, NOT a shiny gemstone or jewel. Animation: the ground cracks, a
small snowy ice mound forms at the base, and the crescent-moon of ice GROWS/SCALES UP FAST straight
from that base, getting bigger IN PLACE until it reaches full size — like an ice sculpture rising
out of the floor. It reaches full size, holds a brief moment, then cracks and shatters into purple
ice shards. VERY IMPORTANT: the crescent moon does NOT rotate, spin, tilt, turn, orbit or change
angle — it stays perfectly still in the SAME fixed upright pose (identical to ref #166) and ONLY
grows bigger in size from the ground up. Its bottom stays planted on the snowy base at all times. It
is ALWAYS the SAME purple ice crescent moon, just scaling up — do NOT add any other element (no
fire, no water, no lightning, no plants, no leaves), NO other colors, NO separate different
crystals, only ONE purple ice crescent moon. Anchored to the ground at the bottom (snowy base).
Camera fixed and locked. FAST growth. NO character.
```

**`crouch_jab` (↓R):**

> PHYSICAL melee, NOT magic. Aye is CROUCHED low in a squat (knees bent, staying down the whole
> time, she does NOT stand up). She holds the staff in both hands and does ONE VERY QUICK, short low
> POKE forward — thrusting the staff tip straight ahead at knee/shin height — then instantly snaps
> it back to a low crouch guard. It is a fast, snappy little stick-jab (draw back → quick poke →
> recover), body low and compact, facing right.
>
> CRITICAL — THE STAFF NEVER CHANGES LENGTH: The reach of the poke comes ONLY from her ARMS and
> BODY extending forward (she leans and pushes her hands out) — the staff itself is a solid wooden
> rod of FIXED, UNCHANGING length that slides forward as ONE rigid piece. Both ends (crystal-flower
> tip AND back butt-end) move forward together by the exact same amount. The staff does NOT grow,
> stretch, elongate, extend, telescope or get longer to reach the target — if it looks longer in
> the poke frame than in the guard frame, it is WRONG. Measure it: same number of pixels long in
> every single frame. It is a RIGID SOLID STRAIGHT ROD of CONSTANT length and shape — do NOT deform,
> stretch, squash, bend, curve, warp, taper, or change its size at any point; and NO motion-blur,
> smear or speed-trail on the staff (a fast poke of a solid stick, NOT a rubber band).
>
> NO effects at all: no beam, no ray, no glow, no aura, no energy, no sparkles, no crystals, no
> magic — the staff tip is plain and empty, NOTHING comes out of it. Start and end crouched in low
> guard.

**`sweep` (↓E) = ICE-SPIKES — she summons purple ice SPIKES from the ground:**

> NOTE (for you, do NOT paste this line): ↓E is now a CAST (like W and ↓W), NOT a physical hit. TWO
> SEPARATE generations: (1) Aye's cast = the `sweep` clip below (a low spinning staff sweep, plain
> staff, no ice); (2) the `ice-spikes` effect = the second block (the purple ice spikes of ref #190
> that erupt from the ground). Paste ONLY the code blocks, ONE at a time.

Aye's cast (the `sweep` clip) — PASTE THIS:

```
A cute chibi anime fantasy mage character, cartoon video-game art, side view, facing RIGHT, serious
focused expression. Starting from a low crouch she rises and does ONE fast, low spinning staff
sweep — she swings her straight purple crystal-flower staff around in a low circle close to the
ground and finishes by pointing/planting the staff tip DOWN-FORWARD at the floor in front of her
(to the right), as if striking the ground to summon something, then recovers to guard. Quick,
controlled casting flourish, facing right (wind-up → low spin sweep → point staff down-forward →
recover). The staff is a RIGID SOLID STRAIGHT ROD of CONSTANT length — do NOT deform, stretch,
squash, bend, warp or change its size, and no motion-blur/smear on it; the reach comes from her
ARMS, the stick stays the exact same length in every frame. Just her body movement — plain staff,
no glow, no beam, no crystals, NO magic, NOTHING coming out of the ground or the staff (the ice is
a separate clip). Pure green screen #00FF00, flat and static.
```

The `ice-spikes` effect (separate clip, over GREEN, NO character — shape of ref #190):

```
SEPARATE EFFECT CLIP, no character, no person — only the effect over a PURE GREEN screen #00FF00
(flat, static). A cluster of PURPLE ICE SPIKES erupting from the ground, shaped EXACTLY like ref
#190: two or three tall sharp translucent faceted purple ice spikes / shards (low-poly crystalline
look, deep purple cores with pale frosty white cracked edges and highlights), leaning and pointing
DIAGONALLY UP-AND-TO-THE-RIGHT, rising out of a low snowy/frosty ice mound at their base. It is ICE,
NOT shiny gemstones or jewels. Animation: the ground cracks, a frosty snow base forms, and the
sharp ice spikes SHOOT UP FAST and erupt straight out of the ground to full height (a quick jagged
burst, like frost spears stabbing upward from the floor) — they reach full size, hold a brief
moment, then crack and shatter into small purple ice shards that fall. VERY IMPORTANT: the spikes
keep the SAME fixed diagonal orientation the whole time (identical lean to ref #190, tips up-right)
— they do NOT rotate, spin, tilt, turn or change angle; they ONLY grow/erupt upward in size from
the ground. Their bottoms stay planted on the snowy base at all times. It is ALWAYS the SAME purple
ice spikes, just erupting and scaling up — do NOT add any other element (no fire, no water, no
lightning, no plants, no leaves), NO other colors, only the ONE cluster of purple ice spikes.
Anchored to the ground at the bottom (snowy base). Camera fixed and locked. FAST eruption. NO
character.
```

**`jump_punch`** _(aerial — now a SUMMON: she fires 3 crystal projectiles; give it a jumping start image if you can):_

> STRICT SIDE VIEW / PROFILE, facing RIGHT — her body is turned to the RIGHT (we see her side/profile, the
> SAME camera angle as all her other combat sprites). She is NEVER frontal, NEVER facing the camera, NEVER
> turned toward the viewer. Do NOT rotate her body to face front; keep her in pure side profile the whole clip.
>
> AERIAL MOVE — she is fully OFF THE GROUND, JUMPING / floating high in mid-air the ENTIRE clip. Both feet
> are OFF the floor (do NOT plant a foot down, do NOT stand, do NOT run), knees/legs bent and TUCKED UP in a
> compact jump pose. There is NO ground, NO floor line and NO shadow beneath her — nothing touches the bottom;
> she hovers in empty space. Keep her airborne from first to last frame.
>
> Aye is JUMPING — caught mid-leap, body UPRIGHT (head UP, feet BELOW her), compact, in profile facing RIGHT.
> She grips the staff with BOTH HANDS in front of her and SPINS THE WHOLE STAFF in big fast CIRCLES — like
> twirling a bo-staff / a spinning windmill (propeller) held two-handed, seen FROM THE SIDE. The ENTIRE rod
> rotates round-and-round in the vertical plane (the crystal-flower tip sweeps a full circle: up → forward →
> down → back → up), several full revolutions while she stays airborne and upright, still in profile facing
> right. Same energetic two-handed twirl as her SUPER, performed as a forward summoning wind-up — it reads as
> "she conjures and launches something forward (to the right)."
>
> The staff is a RIGID SOLID STRAIGHT ROD of CONSTANT length and shape — do NOT deform, bend, stretch,
> squash, curve, warp, taper, arc or change its size/shape at ANY point in the spin; the whole stick
> rotates as ONE rigid piece, her two hands stay near the middle as the pivot. CRITICAL: DURING THE SPIN
> the staff must NOT elongate, bow or curve — NO motion-blur, NO smear, NO speed/streak trail, NO glowing
> arc drawn where the stick swept; it keeps its exact same straight fixed length in every single frame
> (a solid rigid stick, NOT elastic/rubber, NOT a bending arc). Show clean separate positions of a
> straight rod as it rotates, not a blurred curved streak.
>
> NO projectiles and NO effects drawn in HER clip — the 3 crystal projectiles are the SEPARATE effect the
> engine fires (reusing the existing crystal/ice-moon projectile). The staff is plain; you MAY add only a
> faint PURPLE glow on the crystal-flower tip as it spins (nothing shooting out of it). She does NOT hang
> limp, float sideways or go upside-down. Pure green screen #00FF00, flat and static.

**`jump_kick`** _(aerial):_

> PHYSICAL melee, NOT magic. Aye is JUMPING — caught mid-leap, body UPRIGHT (head UP, feet BELOW
> her). She STARTS with the staff raised HIGH above her head, then CHOPS/SWINGS it DOWN and forward
> in one clean overhead strike, ending with the staff extended down-forward (to the right). The
> whole motion goes FROM ABOVE downward — do NOT start with the staff low and raise it, and do NOT
> lower it first; it comes straight down from overhead. She stays off the ground (airborne) the
> whole time, upright, facing right — she does NOT hang limp, float sideways, spin, or go
> upside-down/horizontal (do NOT dive head-first). The staff is a RIGID SOLID STRAIGHT ROD of
> CONSTANT length and shape — do NOT deform, stretch, squash, bend, curve, warp, taper or change
> its size/shape at any point; it stays the exact same straight staff in every frame. CRITICAL:
> DURING THE SWING the staff must NOT get longer or elongate — no motion-blur, no smear, no speed
> trail, no stretching of the stick as it moves; it keeps its exact same fixed length through the
> whole swing (a solid rigid stick, NOT elastic/rubber). Keep the swing controlled and clear, not a
> fast blur. NO effects: no beam, no glow, no crystals, no magic — plain staff.

**`air_jab`** _(aerial — salto R — a DOWNWARD crystal cast; twin of jump_kick_cast but aimed DOWN):_

> STRICT SIDE VIEW / PROFILE, facing RIGHT (never frontal, never facing camera). AERIAL MOVE — she is fully
> OFF THE GROUND, jumping / floating high the ENTIRE clip: both feet off the floor, knees tucked, NO ground
> line and NO shadow beneath her (she hovers in empty space).
>
> It's a quick DOWNWARD SUMMON. She HOLDS THE STAFF WITH BOTH HANDS and does NOT spin it — she simply POINTS
> / AIMS it DIAGONALLY DOWN-AND-FORWARD (the crystal-flower tip aimed toward the LOWER-RIGHT, a ~45° diagonal
> toward the ground in front of her) with a short, sharp two-handed aiming thrust, casting downward — as if
> flinging magic down at an enemy below. Simple motion: bring the staff (both hands) to the diagonal
> down-forward aim → hold that pose (tip pointing diagonally down-right). Body upright and compact, in profile
> facing right; she does NOT spin the staff, dive head-first, go upside-down, or drift sideways.
>
> PLAIN staff — NO glow, NO light, NO aura, NO effect anywhere on it (not on the tip, not on the shaft). The
> crystal flower is just its normal solid self, same as in her other animations.
>
> CRITICAL — NOTHING GROWS AND NOTHING IS LAUNCHED FROM THE STAFF: the crystal-flower TIP must NOT grow,
> enlarge, swell, extend or lengthen, and NEITHER END / no EXTREMITY of the staff may grow or stretch out.
> The staff does NOT shoot, launch, emit, spray or fire ANYTHING in her clip — no bolt, no beam, no orb, no
> shard leaves the staff (the 3 crystal bolts are added SEPARATELY by the engine, not drawn here). Her clip is
> ONLY her body + the plain glowing-tip staff.
>
> THE STAFF IS A RIGID SOLID STRAIGHT ROD of the EXACT SAME fixed length and shape in every frame — do NOT
> STRETCH, elongate, grow, bend, curve, squash, taper, warp or smear it at any point (no motion-blur, no speed
> trail): the same straight staff, same length, every frame. Pure green screen #00FF00, flat, camera fixed and
> locked.

### SUPER — CRYSTAL FLURRY (like DAM's inferno)

**`crystal_flurry`** (her signature SUPER: a rapid multi-hit staff flurry, then it FREEZES the foe):

> NOTE (for you, do NOT paste): this is Aye's special/super — a fast multi-hit. In the engine it
> lands SEVERAL rapid CRITICAL hits and ends leaving the rival FROZEN ~1s (the same purple freeze as
> her ↓E). This clip is ONLY her body flurry; the crit sparks + ice are added by the engine.

```
A cute chibi anime fantasy mage character, cartoon video-game art, side view, facing RIGHT, serious
focused determined expression. Aye plants her feet, THRUSTS her straight purple crystal-flower staff
FORWARD (to the right), then BRANDISHES it UP AND DOWN extremely FAST — a rapid-fire flurry of many
quick staff strikes in front of her, EXACTLY like Chun-Li's lightning-fast "Hyakuretsukyaku"
(lightning legs) but performed with the STAFF hammering up-down-up-down at very high speed, many
strikes per second. Her body leans forward into the assault. It is a sustained rapid flurry: thrust
staff forward → many fast up-down strikes in place → recover to guard. She stays STANDING in place
the whole time, facing right.

CRITICAL — THE STAFF NEVER CHANGES LENGTH: even at this high speed the staff is a RIGID SOLID
STRAIGHT ROD of CONSTANT length — do NOT stretch, elongate, bend, warp, taper, squash or change its
size as it chops up and down; the reach comes from her ARMS, the stick stays the exact same length
in every frame (a solid rod, NOT an elastic rubber band).

NEON LIGHT (this is her SUPER, so it glows): the TIP of the staff (the crystal flower) is lit up with
a bright PURPLE NEON glow — a vivid glowing magenta-purple light at the tip. As the staff chops UP and
DOWN at high speed it leaves a PURPLE NEON light TRAIL / streak tracing the up-down motion — bright neon
ribbons / afterglow sweeping up and down together with the tip, like glowing neon speed-lines following
the staff. Purple / magenta NEON is the ONLY light effect here (no other color, no fire, no ice — the
ice and critical sparks are added by the engine). IMPORTANT: the neon is GLOWING LIGHT painted ON TOP of
the motion — the solid staff underneath still keeps its exact same fixed length and straight rigid shape;
the glow does NOT stretch, bend or lengthen the actual stick. The middle up-down strikes should tile /
loop cleanly so they can repeat for the multi-hit. Pure green screen #00FF00, flat and static camera.
```

### CRYSTAL ZONER KIT (the heart of the character)

Aye's motion is her own clip; the **CRYSTAL/projectile is a SEPARATE clip** (only the effect over
green, no character) — so the engine draws it separately.

**`crystal_cast`** _(straight shot — her main ranged attack; uses the `water_cast` engine slot):_

> From guard, Aye aims the staff forward, opens her MOUTH shouting the spell, and **thrusts the
> staff forward** in a shooting gesture; then recovers to guard. She stays standing in place (it's
> ranged). PLAIN staff: the energy charge and the fired crystal are ALL in the separate EFFECT
> clip — draw no glow or projectile in her clip. Start and end in guard.

> **Effect `crystal_shard`** (separate EFFECT clip, OVER PURE GREEN #00FF00).
>
> ⚠️ CRITICAL — NO CHARACTER AT ALL: this clip shows ONLY the flying ice-moon effect, floating alone
> over the green screen. There is NO person, NO girl, NO mage, NO hands, NO staff, NOBODY casting,
> holding, throwing or summoning it. Do NOT show anyone. From the VERY FIRST frame the crescent moon
> is ALREADY there, flying on its own — it does not get cast or created by a character; it is just
> the moon by itself, start to finish. NO ground, NO wall, NO background objects.
>
> The effect: a **PURPLE ICE CRESCENT MOON** flying RIGHT — a crescent-moon shape made of
> faceted PURPLE ICE with frosty white cracked edges and a soft icy glow, EXACTLY the look of ref
> #188 (frozen purple ice, translucent facets, NOT a gemstone, NOT liquid/energy). It trails frosty
> white ice sparkles and tiny purple ice shards behind it (to the LEFT).
>
> SIZE: it is a CONSTANT MEDIUM size the WHOLE time — it does NOT grow or shrink; it stays exactly
> the same medium size from start to finish (only a subtle frosty shimmer and the trailing sparkles
> move — the moon's shape and size stay fixed, and it keeps the SAME orientation, it does NOT spin
> or rotate).
>
> IMPORTANT — it TRAVELS IN PLACE: the ice moon stays in the SAME SPOT, CENTERED in the frame the
> whole time (camera LOCKED/FIXED, no pan, no zoom). It does NOT fly across the frame — it hovers in
> the center with its frosty trail streaming behind it (to the LEFT), as if frozen mid-flight (the
> game engine moves it across the screen).
>
> Then, in the LAST part of the clip, THE SAME ICE MOON IMPACTS AND SHATTERS: this exact crescent
> moon (not a new/separate object) CRACKS and BURSTS APART into flying purple ICE SHARDS and frosty
> white powder, as if it slammed into an invisible wall — a crisp ICE-SHATTER (sharp broken purple
> ice pieces + frost spray flying outward), then the shards fade. The shatter must come CONTINUOUSLY
> out of the SAME traveling moon — same purple ice, ATTACHED, one continuous piece (do NOT spawn a
> separate explosion beside it or a second object; the moon ITSELF is what shatters). It looks
> EXACTLY as if it hit a post/wall — but do NOT draw any post, wall, pole, ground or surface; draw
> ONLY the ice moon and its own shatter over the flat green. NO character. Camera fixed. It is
> ALWAYS the same purple ICE — no energy/liquid, no other color or element.

**`crystal_pillar_cast`** _(zoning wall):_

> Aye **stabs the staff toward the ground** and, standing, mouth shouting, makes the gesture of summoning
> a crystal wall/pillar at range; recovers to guard. Stays standing. **PLAIN staff**: the energy and the
> pillar are in the separate EFFECT clips.

> **Effect `crystal_pillar`** (separate, OVER GREEN, NO character): a **PURPLE faceted crystal COLUMN
> erupting from the ground** (crack → spike growing fast → tall bright crystal → flashes → cracks →
> dissolves). Anchored to the ground.

**`crystal_capture`** _(★ her SIGNATURE — capture/freeze):_

> Aye **extends the staff forward with BOTH hands** (exception: this capture IS two-handed), **mouth wide
> open** shouting the spell, triumphant firm posture; she holds the staff extended aiming at the opponent.
> She stays standing while (separately) the opponent gets trapped. **PLAIN staff**: the beam and the crystal
> prison are in the separate EFFECT clips. Start in guard, end holding the capture pose.

> **Effect `crystal_prison`** (separate, OVER GREEN, NO character): a **translucent faceted PURPLE crystal**
> forming to **enclose a body-shaped hollow** (shards appear → the prison grows → bright seal → holds →
> cracks → shatters into shards). In-game it's drawn **on top of the "frozen" opponent**.

**`crystal_rain_cast`** _(aerial control / overhead):_

> Aye **raises the staff to the sky**, mouth shouting, in the gesture of summoning a rain of crystals; recovers
> to guard. Stays standing. **PLAIN staff**: the flash and the rain are in the separate EFFECT clips.

> **Effect `crystal_rain`** (separate, OVER GREEN, NO character): several purple crystal shards **falling
> diagonally** from above and **shattering when they hit the ground**.

**`frost_orb`** _(★ FROST ORB — a slow spinning crystal orb that travels, freezes ~1.5s, then SHATTERS (breaks like the ice moon); if the opponent touches it → FROZEN + it breaks. Look of ref #220):_

> NOTE (for you, do NOT paste): mechanic — she casts it (her body uses her normal `crystal_cast` pose); the
> engine sends this orb DRIFTING forward while SPINNING (up to ~4 of her body-lengths), then it HOVERS in
> place ~1.5s, then SHATTERS (breaks apart into purple ice shards, like the crescent moon — NOT an explosion).
> As it drifts it leaves a PURPLE FREEZE TRAIL on the GROUND beneath it, along the whole path it travels, which
> then FADES out behind it (engine-generated, like the purple ghost-trail of her projectiles — NOT a clip).
> If the opponent contacts it at ANY point (walks in, jumps into it, or is pushed into it) → they get FROZEN
> (purple freeze, ~1s) and the orb breaks. It is ONE single EFFECT clip: grow+spin → hold → shatter → vanish.

The `frost_orb` effect — ONE single clip (separate, OVER GREEN, NO character): grow+spin → hold → shatter → vanish.

```
SEPARATE EFFECT CLIP, no character, no person — only the effect over a PURE GREEN screen #00FF00 (flat,
static, fixed camera). A PURPLE CRYSTAL / FROST ORB — a swirling sphere of purple ICE energy: the top is a
glossy DARK-PURPLE SPIRAL SWIRL (like a spinning spiral / soft-serve swirl), and below and around it a
lighter PURPLE-AND-WHITE CRYSTALLINE ICE VORTEX twists upward (jagged, frosty, translucent purple ice with
frosty-white edges), thin WHITE WIND STREAKS orbiting it and a faint white frost RING at its base.

ONE CONTINUOUS ANIMATION, in this exact order:
1) GROW UP FROM THE GROUND + SPIN: it STARTS SMALL — a tiny spinning orb SITTING ON THE GROUND — and GROWS
   UPWARD from there. CRITICAL: its BOTTOM / BASE (the frost ring where it touches the ground) STAYS PLANTED
   on the SAME ground line the WHOLE time and does NOT move down or drift; ONLY the TOP rises as it gets
   bigger, so the orb grows UPWARD out of the ground (like ice erupting from the floor / like a scoop of
   soft-serve being piled UP from its base) — NOT growing downward and NOT dropping onto the floor. While it
   grows it keeps SPINNING / ROTATING ON ITS OWN VERTICAL AXIS (the spiral swirls and the ice vortex turn,
   wind streaks circling). It scales up smoothly to full size, base fixed, top rising, always spinning.
2) HOLD: at full size (base still planted on the same ground line) it keeps spinning in place a brief moment.
3) SHATTER + VANISH: it slows and freezes solid, thin white CRACKS spread across it, then it BREAKS APART
   like a purple ice crescent moon shattering (NOT an explosion, NOT an outward blast ring) into jagged
   translucent PURPLE ICE SHARDS with a puff of frost; the shards FALL / scatter and FADE OUT COMPLETELY
   until NOTHING is left on screen — the orb does NOT stay or linger, the LAST frames are just empty green.

The shards stay CLOSE to the center as they scatter (a compact break, they do not fly far). It is ALL purple
ICE / FROST — do NOT add fire, water, lightning, plants or any other color. Camera fixed and locked. NO
character.
```

**`teleport`** _(↓→Q — glitch teleport, invincible; replaces the fire dash):_

> Aye TELEPORTS with a purple GLITCH / TV-static dissolve — the look of ref #207 (a body breaking up into
> digital scanline glitches), but in PURPLE. One continuous clip: OUT → gone → IN, facing RIGHT the whole
> time, plain rigid staff.
>
> 1. START: normal standing guard pose, solid and clean.
> 2. GLITCH OUT: her body starts tearing into HORIZONTAL GLITCH BANDS / scanline slices that shift and
>    slide sideways (a corrupted-TV / datamosh look — the image shears left-right in stripes), each band
>    offset from the next, edges hard and pixelated. A few PURPLE crystal shards pop off. Chromatic split:
>    faint magenta/cyan fringes on the edges of the slices. Her silhouette smears and stretches
>    HORIZONTALLY as it comes apart.
> 3. DISSOLVED: she is fully broken into a spread of purple glitch stripes + static + shards, her shape
>    almost unreadable, then it all thins out and she is GONE (nothing but a last flicker of purple static).
> 4. GLITCH IN (reverse): the purple glitch stripes + shards snap BACK together from static, sliding into
>    place, chromatic fringes pulling in, and REASSEMBLE cleanly into her solid standing pose again.
>
> Style: bright HARD-EDGED digital glitch — TV static, scanlines, datamosh, pixel-tear — in purple /
> magenta / cyan. NOT smoke, NOT fire, NOT a soft particle cloud, NOT a fade. The STAFF glitches and
> dissolves WITH her (same purple) and reforms rigid, straight and unchanged (do not bend/stretch the real
> staff — only the glitch tears it). Fast and snappy. Pure green screen #00FF00, flat and static camera.

**`spin_kick`** _(spinning top — her close reversal):_

> STRICT SIDE VIEW / PROFILE, facing RIGHT — same camera angle as all her other sprites (never frontal, never
> facing the camera). Aye brings her feet TOGETHER and SPINS LIKE A TOP in place: one fast, controlled 360°
> turn of her whole body, sweeping the staff out horizontally in a full circle around her at about waist
> height. She stays CENTERED on the exact same spot (does NOT travel across the screen), upright and balanced,
> then comes cleanly OUT of the spin back into her standing guard, facing right. Both feet stay on the GROUND —
> it is a spinning pivot, NOT a jump (she never leaves the floor). Short and snappy: wind up → one full 360°
> spin → recover to guard.
>
> Do NOT draw the circling crystals — that ring of crystals is a SEPARATE engine effect; her clip is ONLY her
> body + staff spinning. THE STAFF IS A RIGID SOLID STRAIGHT ROD of the EXACT SAME fixed length, thickness and
> straight shape in EVERY frame — do NOT bend, curve, stretch, elongate, shorten, squash, taper or warp it as
> it sweeps, and NO motion-blur, smear or streak that makes it look longer. Plain staff, no glow. Pure green
> screen #00FF00, flat, camera fixed and locked.

**`air_spin_kick`** _(aerial):_

> STRICT SIDE VIEW / PROFILE, facing RIGHT (never frontal). Aye is AIRBORNE the ENTIRE clip — fully off the
> ground, NO floor line and NO shadow beneath her, knees/feet tucked up compact. She SPINS in mid-air like an
> airborne top, sweeping the staff around her in a full 360° circle at about waist height, body kept UPRIGHT
> and compact while suspended. She does NOT dive, does NOT go head-down or upside-down, does NOT drift sideways
> or hang limp — a clean controlled aerial spin held in the air. Short: tuck in mid-air → one airborne 360°
> spin → hold, still airborne.
>
> Do NOT draw the circling crystals (SEPARATE engine effect). THE STAFF IS A RIGID SOLID STRAIGHT ROD of the
> EXACT SAME fixed length and straight shape in every frame — no bending, stretching, shortening, tapering,
> warping, and NO motion-blur or smear; the same straight staff throughout. Plain staff, no glow. Pure green
> screen #00FF00, flat, camera fixed and locked.

### MANA CHANNEL — recharge (wizard resource)

> **(ES) nota:** versión MINIMALISTA (efecto chico) para que el personaje se mida limpio y quede
> del tamaño exacto y pegado al suelo. Animación en LOOP mientras canaliza (recarga rápido,
> vulnerable; moverse/golpe la cancela). Con Grok: pega SOLO este prompt + la imagen de referencia.

**`mana_charge` (channel to recharge mana — LOOP, minimal FX):**

> Same character as the reference image: a chibi anime mage girl in a lilac puff-sleeve dress, holding a straight purple staff with a pink crystal flower on top. Side view, facing RIGHT. CRITICAL: fixed locked camera, NO zoom in or out at all, she stays the EXACT SAME SIZE and IN PLACE the whole time, feet flat on the ground; seamless loop. She stands still MEDITATING to recharge magic: upright, feet planted, holding the straight staff vertical with both hands, head lightly bowed, eyes half-closed, calm. THE MAIN MOTION is her CLOTHES and HAIR moving VIOLENTLY: her lilac dress, skirt and her curly hair and ponytail whip and flutter HARD UPWARD (as if a strong updraft blows up through her), then settle, looping. KEEP THE EFFECTS VERY MINIMAL: the ONLY effect is a SMALL, tight, faint purple glowing ring on the GROUND right under her feet — it stays SMALL and CONTAINED and does NOT expand, open wide or rise up. NO glow or shine on the staff or crystal (the crystal does NOT light up or flare), NO bright light burst, NO wide spreading particles. If any tiny sparkles appear, keep them very few and hugging CLOSE to her body, not spread out. Pure green #00FF00 flat static background, no motion blur.

### TAKING DAMAGE / DEFENSE / FINISH

> _(For the AI content filter: avoid "hit/impact/struck"; use "recoil/flinch".)_

**`take_hit`:**

> SIDE VIEW / PROFILE, facing RIGHT — same camera angle as all her other sprites (never frontal, never facing
> camera). Aye is STANDING on the ground and gives a sharp standing **FLINCH / recoil**, reacting to a blow
> coming from the RIGHT (the side she faces). In one quick snap her HEAD jerks back and to the UPPER-LEFT
> (chin flicks up), her UPPER BODY / torso whips BACKWARD (leaning left, away from the front), her front
> shoulder pulls back, and her FRONT foot slides/steps back a short step so her weight drops onto her BACK
> foot — a clear "knocked-back a little" recoil. Her free arm flails back slightly and her hair/ponytail and
> dress swing forward-then-back from the jolt. Then she springs back UPRIGHT and re-settles into her standing
> guard, facing right. Short and snappy: neutral → hard recoil back → recover to guard. She stays on her feet
> (does NOT fall, does NOT crouch, does NOT leave the ground). Do NOT draw the attacker, and NO weapon, fist,
> spark, blood or impact effect touching her — only HER reaction.
>
> She keeps hold of her staff the whole time. THE STAFF IS A RIGID SOLID STRAIGHT ROD of the EXACT SAME fixed
> length, thickness and straight shape in EVERY frame — do NOT bend, curve, stretch, elongate, shorten,
> squash, warp, taper or thin it, and NO motion-blur or smear on it. Pure green screen #00FF00, flat, no
> ground shadow needed, camera fixed and locked.
>
> _(Content filter: avoid "hit/impact/struck/punch" — describe it as a "flinch/recoil/jolt/reaction".)_

**`take_hit_low`:**

> SIDE VIEW / PROFILE, facing RIGHT — same camera angle as her other sprites (never frontal). Aye is already
> DOWN IN A LOW CROUCH / squat (knees deeply bent, hips low, close to the floor) and from there gives a small
> flinch / recoil while staying crouched, reacting to a blow from the RIGHT. Her HEAD and upper body
> snap/recoil BACKWARD and slightly DOWN (she scrunches lower and leans away, chin tucking, front shoulder
> pulling back) as the jolt hits, ponytail and dress swinging from the shake — but she NEVER stands up and
> NEVER falls over; she stays low in the squat the entire time. Then she settles back into her steady low
> crouch guard, facing right. Short and snappy: crouched → recoil back-and-down while still squatting →
> recover to the low crouch. Do NOT draw the attacker, and NO weapon, fist, spark, blood or impact effect
> touching her — only HER reaction.
>
> She keeps hold of her staff. THE STAFF IS A RIGID SOLID STRAIGHT ROD of the EXACT SAME fixed length,
> thickness and straight shape in EVERY frame — do NOT bend, curve, stretch, elongate, shorten, squash,
> warp, taper or thin it, and NO motion-blur or smear on it. Pure green screen #00FF00, flat, camera fixed
> and locked.
>
> _(Content filter: avoid "hit/impact/struck/punch" — describe it as a "flinch/recoil/jolt/reaction".)_

**`strong_fly`** _(she's knocked away → I get `hit_fly` and `hit_down` from this clip):_

> STRICT SIDE VIEW / PROFILE. Aye is FLUNG BACKWARD to the LEFT (knocked away from a blow coming from the
> RIGHT) in ONE continuous motion with TWO clearly separated phases, so I can cut it into "flying" and "fallen".
> Her FACE shows PAIN the WHOLE clip: EYES WIDE OPEN and MOUTH OPEN (crying out / wincing in pain) — never calm,
> never eyes-closed, never neutral.
>
> IMPORTANT — SHE NEVER DROPS THE STAFF: she keeps a FIRM GRIP on her staff in the SAME ONE hand the ENTIRE time
> and NEVER lets go, NEVER drops it, NEVER throws it, NEVER opens that hand, and NEVER switches it to her other
> hand or passes it between hands — it is always the SAME single hand gripping the shaft, through the launch, the
> arc, the bounce and the landing. The staff is a RIGID SOLID STRAIGHT ROD of CONSTANT length and shape (no
> bending, stretching, warping, tapering or smear); it just tumbles WITH her, always held in that same hand.
>
> (1) FLY — she is launched off her feet up into the air, body ARCHED and tilted BACK (head trailing back and
> LEFT, feet up and RIGHT), her FREE (empty) arm flailing loose while the OTHER hand keeps its firm hold on the
> staff, ponytail and dress streaming from the speed, eyes wide and mouth open in pain. She is FULLY airborne,
> carried up-and-back through an arc.
>
> (2) FALL & LIE — she drops, hits the floor and BOUNCES once, then comes to rest LYING FLAT ON HER BACK,
> FACE-UP, head toward the LEFT and feet toward the RIGHT. CRITICAL: her hand NEVER opens and NEVER lets go of the
> staff — her fingers stay CLOSED and WRAPPED tightly around the shaft the ENTIRE time; she is always HOLDING it
> in her hand. As she lands, her arm lowers so the staff comes to a DIAGONAL angle held in her fist near her
> chest. Keep the staff RIGHT-SIDE-UP: the CRYSTAL FLOWER is the TOP end and points UP-and-BACK (up in the air,
> over toward her head), while the plain pointed butt-end is the LOWER end (toward her feet) — do NOT flip the
> staff upside down, and the crystal flower must NEVER point down toward her feet or the floor. The staff is NEVER
> left standing straight UP, and it is NEVER dropped, thrown, or lying loose on the floor apart from her hand — it
> always stays gripped in her closed hand. Eyes open, mouth open, pained.
>
> Frame it TALL/WIDE enough that BOTH the top of the airborne arc AND the final lying-down pose are fully in
> view (her whole body never cut off). Do NOT draw the attacker, and NO fists, weapons, sparks, blood or impact
> effects touching her — only HER being flung and landing. Pure green screen #00FF00, flat, camera fixed and locked.
>
> _(Content filter: avoid "hit/impact/struck/punch" — say "flung / knocked back / thrown / falls / lands".)_

**`get_up`** _(recovery from the downed pose — reference image = the LYING pose with the staff up; she lowers the staff and STANDS UP COMPLETELY):_

> Same character as the reference image: she is LYING on her BACK on the ground, head toward the LEFT and feet toward the RIGHT, holding her straight purple staff raised UP in one hand. STRICT SIDE VIEW / PROFILE, facing RIGHT the WHOLE time (NEVER frontal, NEVER facing the camera, NEVER three-quarter). Fixed locked camera, she stays IN PLACE, the SAME SIZE the whole time, one continuous clip. TWO phases:
>
> PHASE 1 — LOWER THE STAFF (she is still knocked out): she stays limp and motionless on her back — her EYES STAY CLOSED, her MOUTH STAYS CLOSED, and her body does NOT change its position at all. The ONLY thing that moves is her raised arm, which slowly LOWERS the staff down until it rests low. She keeps GRIPPING the staff the whole time — she never lets go and never drops it.
>
> PHASE 2 — STAND ALL THE WAY UP (finish EXACTLY in the idle pose): then she RECOVERS and gets up COMPLETELY — her eyes open, she pushes off the ground, brings her legs under her, and RISES all the way up to her FEET. She MUST END standing EXACTLY in her calm RELAXED idle pose, matching the reference: standing upright and relaxed, arms DOWN, holding the staff LOOSELY in ONE hand hanging DOWN at her side with the staff VERTICAL and its bottom tip resting near the ground (her OTHER hand relaxed at her side), head level, eyes open, looking forward. Do NOT end with the staff raised up in front of her chest, do NOT hold it with BOTH hands, do NOT tilt her chin up — end in the loose, relaxed, arms-down idle exactly like the reference standing sprite. Do NOT stop halfway (no lying/sitting/kneeling/crouching).
>
> IMPORTANT — DO NOT CHANGE THE STAFF: the staff and its crystal flower keep the EXACT SAME simple shape and size as the reference the ENTIRE clip — do NOT redesign, ornament, deform, bend, stretch, taper, enlarge, or add extra crystals to it; it is always a plain thin STRAIGHT rigid rod with the same small crystal flower on top, held in the SAME one hand the whole time.
>
> Pure green #00FF00 flat static background, camera fixed and locked, no motion blur. Do NOT draw an attacker or any impact effects.

**`pummeled`** _(repeated stagger while being comboed — LOOPS. Truco anti-filtro: se describe como VIENTO + mareo, cero combate):_

> STRICT SIDE VIEW / PROFILE, facing RIGHT the whole time (NEVER frontal, NEVER three-quarter). Fixed locked
> camera, pure flat green #00FF00 background, she stays on the SAME SPOT and the SAME SIZE the entire clip.
>
> She is STANDING, dizzy and dazed with her eyes squeezed shut, while sudden POWERFUL GUSTS OF WIND coming
> from the RIGHT side of the frame rock her on her feet, in a repeating cycle that alternates two reactions:
>
> HIGH GUST — her head snaps back toward the LEFT, chin up, back arching, shoulders thrown back, one foot
> sliding back a small step to keep her balance, ponytail whipping across her face and skirt flaring.
>
> LOW GUST — she doubles over at the waist, head and shoulders dropping down and forward, hair falling over
> her face, knees dipping slightly.
>
> Each reaction is a SHARP, FAST snap followed by a brief wobbly half-recovery — she stays dazed the whole
> time, arms hanging loose and swinging with each snap, legs staggering under her, but she NEVER falls,
> NEVER kneels, NEVER crouches and NEVER leaves the ground. Dizzy expression throughout: eyes squeezed shut,
> brows knit, mouth open.
>
> She keeps GRIPPING her staff in the SAME one hand the whole clip — that arm swings loosely, the staff
> never leaves her hand and never touches the ground. The staff is a plain RIGID SOLID STRAIGHT rod of
> CONSTANT length and thickness with its small crystal flower on top — no bending, stretching, warping,
> tapering or redesign, identical every frame.
>
> Seamless LOOP: the LAST frame returns to the EXACT pose of the FIRST frame so the clip repeats forever
> without a jump. Nobody else in the frame; no visible wind lines, no effects, no particles, no glow — only
> HER body moving.

**`block`:**

> Standing GUARD/BLOCK — a DEFENSIVE, dodging brace (NOT an attack, NOT arms spread wide). Aye holds her
> staff DIAGONALLY across her chest — the crystal-flower tip raised UP toward her BACK shoulder (up-and-
> behind, upper-left) and the plain far end angled DOWN and FORWARD (lower-right), a SLANTED deflecting
> guard tilted about 35° — clearly DIAGONAL, NOT horizontal and NOT vertical. She grips it with BOTH
> hands about shoulder-width apart near the middle of the staff (do NOT spread her arms out to the far
> ends). At the same time she LEANS her upper body slightly BACK — recoiling/flinching away from an
> incoming blow, weight shifted onto her BACK foot, chin tucked, as if bracing and dodging. Defensive
> and compact, facing right. Short motion: bring the staff up to the slanted diagonal guard while
> leaning back → hold firm.
>
> CRITICAL — THE STAFF DOES NOT CHANGE: it is a RIGID SOLID STRAIGHT ROD of the EXACT SAME fixed length,
> thickness and straight shape in EVERY frame — do NOT bend, curve, stretch, elongate, shorten, squash,
> warp, taper or thin it, and NO motion-blur or smear on it. If the staff looks longer, shorter, bent or
> different in ANY frame, it is WRONG — measure it: the same straight staff, same length, every frame.
>
> PLAIN staff — no glow, no beam, no crystals, no magic (the faint purple crystal shield is a SEPARATE
> effect the engine adds). Pure green screen #00FF00, flat and static.

**`block_low`:**

> Crouched LOW GUARD/BLOCK. Aye is in a DEEP SQUAT — body COMPACT and hunched, head LOW, exactly the same
> low height as her normal crouch pose (she does NOT stand up, she is NOT kneeling with the torso vertical,
> she stays low and compact). She covers herself by holding the staff HORIZONTAL above/in front of her head
> like a ROOF/shield (both hands). The staff lies FLAT/horizontal — its tip does NOT point up at the sky.
> Firm, braced, staying low the whole time, facing right. The staff is a RIGID SOLID STRAIGHT ROD of
> CONSTANT length — do NOT deform, bend, stretch or change its size. PLAIN staff — no glow, no beam, no
> crystals, no magic (the crystal dome/shield is a SEPARATE effect). Short motion: bring up the low
> horizontal guard → hold. Pure green screen #00FF00, flat and static.

**`ko`:**

> STRICT SIDE VIEW / PROFILE. Aye is DEFEATED — one continuous COLLAPSE: she STAGGERS (head lolling, knees
> buckling under her), then SINKS DOWN and ends CRUMPLED on the floor — either slumped sitting with her head
> hung low, OR lying on her back/side — EYES CLOSED, body limp and motionless ("out cold"). Her staff FALLS
> from her grip and comes to rest on the ground right BESIDE her body (near her, NOT flung far away). One
> motion: totter → crumple → still, HOLDING the final downed pose at the end.
>
> Frame it TALL/WIDE enough that her WHOLE body and the final downed pose stay fully in view (she must NOT be
> cut off when she's low on the ground). IMPORTANT: keep her BODY as the clear main mass on the floor with the
> staff as a thin object beside it (so her collapsed body reads clearly, not hidden behind the staff). Do NOT
> draw the attacker or any impact effect. The staff is a RIGID SOLID STRAIGHT ROD of CONSTANT length and shape
> — no bending, stretching or warping (it just drops, still rigid). Pure green screen #00FF00, flat, camera
> fixed and locked.
>
> _(Content filter: "defeated / collapses / faints / knocked out / out cold" — avoid "killed/dead".)_

**`victory`:**

> STRICT SIDE VIEW / PROFILE, facing RIGHT (a gentle 3/4 turned slightly toward the camera is OK, but keep it
> close to her side view — never fully frontal). Aye CELEBRATES her win — a cheerful, triumphant LOOP: standing
> tall and happy, she RAISES her staff high (crystal-flower tip pointing UP), strikes a proud, cute victory
> pose (a little bounce and/or a hair-flip is welcome), SMILING brightly, and clearly MOVES HER MOUTH as if
> saying a victory line. Energetic and joyful; it should LOOP seamlessly (settle into the pose → small
> celebratory motion → back to start). She stays STANDING on the ground the whole time (does NOT jump away, does
> NOT leave the frame).
>
> Do NOT draw the swirling crystals — those purple victory crystals are a SEPARATE engine effect; her clip is
> ONLY her body + staff. THE STAFF IS A RIGID SOLID STRAIGHT ROD of CONSTANT length and shape — no bending,
> stretching, tapering, warping or smear; the same straight staff every frame. Pure green screen #00FF00, flat,
> camera fixed and locked — a STATIC WIDE flatbed shot, not a movie camera. She is the EXACT SAME SIZE (same
> head-to-feet pixel height) in the FIRST, MIDDLE and LAST frame — she never grows or shrinks, never gets closer
> or farther (a size change looks like a glitch and is FORBIDDEN). WIDE full-body framing with green margin on
> all four sides that NEVER tightens; the framing of the first frame is the framing of every frame.

### IMPACT EFFECT (only the effect over green, no character)

**`crystal_hit`:**

> OVER GREEN, NO character: a **burst of PURPLE/magenta CRYSTAL shards with a bright white core** (a short
> spark). Fixed camera.

---

## Reminders

- Energy is ALWAYS **purple/lilac crystal** (shards, prison, pillar), NEVER fire or water. The only floral
  element is the crystal flower on the staff tip.
- The staff is **STRAIGHT and ONE continuous piece**; mind the extended tip (leave half a body of clear air
  in front).
- Damage prompts avoid "hit/impact/struck" → use "recoil/flinch" (the filter rejects the others).
- ⚠️ **CONTENT FILTER:** do NOT mention AGE ("girl", "child", "kid", "years old"). The filter rejects
  describing a minor. Always frame her as a **CHIBI anime illustration / fantasy mage / video-game character**
  (cartoon art, not a real person). The chibi proportions come from the reference image.
- **Priority:** 1) base (pose, walk, crouch, jump) to make her playable · 2) zoner kit (crystal-cast +
  crystal-shard, capture + crystal-prison, pillar) · 3) the rest (hit/block/ko/victory + short normals + effects).
