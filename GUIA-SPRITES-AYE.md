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
> Determined pace. Continuous loop, same size, feet on the same line.

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
> tucks the staff across her knees, torso compact but back straight. Short, firm motion.

**`jump`:**

> Aye jumps straight up in place: bends knees (anticipation, compresses for a moment) →
> pushes up with the staff held close → apex → falls → squashes for a moment on landing. She goes
> up and down inside the frame (never leaves it).

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

> Aye does a quick short poke forward with the TIP of the staff and returns **immediately to
> guard**. Snappy, fast, short reach. Plain staff, no effects (the shards are in the separate
> clip). Start and end in guard.

**`punch`:**

> Aye does a short staff SWEEP at chest height\*\*, back to front: draws the staff back → sweeps
> forward hard (a light MOTION streak at the tip) → extends → recovers to guard. PLAIN staff, no
> glow; the crystal SHARDS that come out on the extension are in the separate EFFECT clip.
> Start and end in guard.

**`kick`:**

> Aye does a **wide, heavy overhead SMASH** with the staff, top to front (like a slow, weighty
> chop); on impact the **crystal burst is in the separate EFFECT clip**. Then recovers to guard.
> Plain staff. Slower and heavier than the punch. Start and end in guard.

**`crouch_punch`:**

> Crouched in a squat, Aye does a **quick low jab** with the staff tip forward and pulls it back.
> Short. Start and end crouched in low guard.

**`crouch_kick`:**

> From a crouch, Aye does a **rising anti-air UPPERCUT sweep**: sweeps the staff diagonally
> bottom-to-top; the rising crystals are in the separate EFFECT clip. Returns to low guard. Plain
> staff. Start and end crouched.

**`jump_punch`** _(aerial — give it a starting image of her jumping if you can):_

> Suspended in the air, Aye does a downward diagonal slash with the staff toward down-forward;
> legs tucked. Body airborne the whole time.

**`jump_kick`** _(aerial):_

> Suspended, Aye **stabs the staff down-forward** in a dive, body leaning. Airborne the whole time.

### CRYSTAL ZONER KIT (the heart of the character)

Aye's motion is her own clip; the **CRYSTAL/projectile is a SEPARATE clip** (only the effect over
green, no character) — so the engine draws it separately.

**`crystal_cast`** _(straight shot — her main ranged attack; uses the `water_cast` engine slot):_

> From guard, Aye **aims the staff forward**, opens her MOUTH shouting the spell, and **thrusts the
> staff forward** in a shooting gesture; then recovers to guard. She stays **standing in place** (it's
> ranged). **PLAIN staff**: the energy charge and the fired crystal are ALL in the separate EFFECT
> clip — draw no glow or projectile in her clip. Start and end in guard.

> **Effect `crystal_shard`** (separate clip, OVER GREEN, NO character): a faceted **PURPLE CRYSTAL
> shard/lance** flying horizontally to the right, spinning, with a trail of lilac sparkles.

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

**`teleport`** _(escape / backdash with invincibility):_

> Aye **dissolves into a burst of purple shards and reforms** a bit further back: pose → she fragments into
> crystals → nearly invisible (cloud of shards) → reappears in guard. Fast and clean.

**`spin_kick`** _(spinning top — her close reversal):_

> Aye brings her feet together and **spins like a top**, sweeping the staff in a full circle (360°); the
> circling crystals are in the separate EFFECT clip. Returns to guard. Centered, same size.

**`air_spin_kick`** _(aerial):_

> Suspended, Aye **spins in the air** sweeping the staff in a circle; the crystals are in the separate EFFECT
> clip. Airborne the whole time.

### TAKING DAMAGE / DEFENSE / FINISH

> _(For the AI content filter: avoid "hit/impact/struck"; use "recoil/flinch".)_

**`take_hit`:**

> Aye gives a standing **FLINCH/recoil**: her torso snaps back, her head reacts, one foot steps back, then
> returns to guard. Don't draw who pushes her.

**`take_hit_low`:**

> Crouched, Aye gives a small **flinch/recoil in a squat** and recovers.

**`strong_fly`** _(she's knocked away → I get `hit_fly` and `hit_down` from this clip):_

> Aye is **flung backward**: first she **flies through the air arched** (arms and staff loose, body in an arc),
> then she **falls, bounces once** on the ground and **ends lying FACE-UP** (without fully letting go of the
> staff). One continuous motion: fly → fall → lying. Frame it so the fly and the fall both fit.

**`block`:**

> Aye takes the **guard/block**: she holds the staff horizontally in front as a barrier; the faint purple
> crystal dome is in the separate EFFECT clip. She holds firm. Short motion (raise guard → hold).

**`block_low`:**

> Same but **crouched**: low block in a squat with the staff and the crystal dome in front.

**`ko`:**

> Aye is defeated: she **staggers, drops to her knees and ends slumped/sitting** with the staff fallen to one
> side (without fully letting go), head down. One continuous motion: stagger → fall → still.

**`victory`:**

> Aye **celebrates the win**: standing, cheerful, she **raises the staff and spins purple crystals** around her,
> smiles and **moves her MOUTH** (as if saying something), triumphant pose. Short celebration loop.

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
