# DAM — The Flame Wielder · Guía de sprites (personaje)

> ⚠️ **WORKFLOW NUEVO (2026-08): CLIPS DE VIDEO, ya NO hojas de frames.**
> Cada acción se genera como UN CLIP DE VIDEO con la herramienta de animación:
> fondo verde puro #00FF00 plano, UNA toma continua, personaje de PERFIL mirando a la
> DERECHA, cámara TRÍPODE fija (sin zoom/pan), mismo tamaño todo el clip, cuerpo
> completo con margen. Guardar como `imagen-action/dam/sheets/<accion>.mp4` y avisarme:
> yo recorto el croma, ELIJO los frames, calibro el TAMAÑO ESTÁNDAR de DAM y lo conecto.
> Los "conteos de frames", "filas ordenadas" y demás reglas de HOJAS de más abajo son
> HISTÓRICOS: sirven como descripción de cada movimiento (fases, poses, arma), pero el
> formato de entrega es SIEMPRE el clip de video. Ver la sección "NIVELACIÓN con AYE"
> al final para ejemplos de prompts de video ya afinados.

> Esta es la guía ESPECÍFICA de DAM: su identidad y la animación detallada de
> cada movimiento con su katana. Las reglas de producción, el roster de
> movimientos y los efectos compartidos están en **`GUIA-COMUN.md`** (sirven
> para todos los personajes). Para un personaje nuevo: copia la estructura de
> `GUIA-COMUN.md`, cambia solo el bloque de identidad y las descripciones de
> animación.

## Reglas generales (van en TODOS los prompts)

Pega esto al final de cada prompt, junto con la **imagen de referencia del personaje** (la hoja de diseño de DAM) adjunta:

> Mismo personaje exacto de la referencia: pelo ROJO intenso en púas (spiky),
> ojos ROJOS. Lleva una GABARDINA/abrigo ROJO largo y abierto, de cuello alto
> (en la ESPALDA del abrigo va un emblema negro de cabeza de LOBO — "Fire Wolf");
> debajo, camiseta/top NEGRO de cuello alto, pantalón NEGRO con correas rojas y
> negras, guantes NEGROS sin dedos con detalles rojos, y botas/tenis NEGROS
> chunky con detalles ROJOS. Su arma es una KATANA GRANDE (oversized): hoja
> ANCHA y pesada de metal NEGRO con el FILO y los detalles al ROJO brillante
> (borde rojo encendido) — simple e impactante. Sin fuego, sin llamas, sin
> partículas, sin brasas. Misma paleta exacta (rojos, negros, grises) y mismo
> estilo de línea. Vista lateral de juego de pelea 2D (estilo KOF), personaje
> mirando a la DERECHA en TODOS los frames — nunca de frente a la cámara, nunca
> de espaldas.
> Los frames van en UNA o DOS filas, ordenados de izquierda a derecha (la
> fila de ARRIBA primero). Todos los personajes a la MISMA escala; dentro de
> cada fila los pies en la MISMA línea. Si hay dos filas, deja una franja
> horizontal VACÍA entre ellas: nada de la fila de arriba puede tocar la de
> abajo. Personaje completo en cada frame con margen (nada cortado
> por el borde). Deja espacio VACÍO claro entre personaje y personaje: las
> katanas de frames vecinos NUNCA deben tocarse ni traslaparse. Ojo con
> los frames de katana EXTENDIDA al frente (ocupan mucho más ancho): entre
> la PUNTA de una katana y el siguiente personaje debe quedar MÍNIMO medio
> cuerpo de espacio vacío.
> La katana es UNA sola pieza continua sujeta en las manos del personaje:
> nunca fragmentada, nunca duplicada, nunca tirada en el piso ni debajo de
> los pies. La katana MIDE SIEMPRE LO MISMO (mismo largo y mismo grosor de
> hoja) en TODOS los frames — no la agrandes ni la achiques entre frames, y va
> SIEMPRE NÍTIDA (nunca deformada ni hecha arco: el arco de corte lo pone el
> motor). Cada frame es UN solo personaje completo — jamás dos poses pegadas o
> fusionadas dentro del mismo frame.
> ANATOMÍA de la katana, SIEMPRE en este orden de atrás hacia la punta:
> (1) un POMO con ANILLO metálico al extremo trasero, (2) el MANGO envuelto
> (empuñadura larga, la ÚNICA parte por donde se agarra), (3) una pequeña
> GUARDA (tsuba) que separa el mango de la hoja, (4) la HOJA negra ancha con el
> FILO ROJO. El pomo de anillo va SIEMPRE en el extremo de atrás
> (detrás de la mano), nunca junto a la hoja.
> TAMAÑO DE LA HOJA — REGLA FIJA: largo NORMAL/razonable (aprox. el largo del
> brazo o un poco más), NUNCA una hoja enorme ni larguísima. El personaje NUNCA se
> achica para que la katana quepa en el lienzo: si algo se ajusta, es la katana
> (más corta y proporcionada), jamás encoger al personaje.
> AGARRE — REGLA FIJA: la(s) mano(s) sujetan la katana SIEMPRE por el MANGO
> envuelto (entre el pomo de anillo y la guarda), con los dedos CERRADOS
> alrededor del mango. La mano NUNCA toca la HOJA ni el filo, NUNCA la sujeta
> por el medio de la hoja. La GUARDA siempre queda ENTRE la mano y la hoja.
> La HOJA es un objeto RÍGIDO y RECTO (con su leve curva natural): no se dobla,
> no se derrite, no se tuerce, no cambia de forma ni de largo. Si una pose no
> deja ver la hoja completa, dibújala COMPLETA igual — nunca la recortes,
> borres ni la hagas desaparecer.
> PROPORCIONES CONSISTENTES: en TODOS los frames el personaje mide lo MISMO
> (misma estatura) y su CABEZA mide LO MISMO — la cabeza es la unidad y NO
> cambia de tamaño con la pose (si se agacha, la cabeza solo se ACERCA al
> piso, no se achica ni se agranda). Mismo grosor de cuerpo, mismo grosor de
> línea y misma paleta exacta en todos los frames. Nada de un frame más flaco,
> más gordo, más alto o más bajo que otro.
> TAMAÑO GRANDE Y CONSISTENTE: dibuja al personaje GRANDE, ocupando casi toda la
> ALTURA del frame de la cabeza a los pies (deja solo un margen pequeño y parejo
> arriba y abajo). NO lo dibujes chico ni flotando en medio del verde. El
> personaje debe verse IGUAL de grande en TODAS las hojas (pose, walk, golpes…),
> para que todas las animaciones queden a la misma escala.
> El abrigo rojo mantiene su borde inferior NORMAL y limpio, exactamente
> como en la referencia: NO lo dibujes rasgado, roto ni hecho jirones.
> Fondo VERDE PURO #00FF00 completamente plano y SIN NINGUNA marca: no
> pongas números, letras, rótulos ni líneas guía en la hoja — solo los
> personajes sobre el verde. Sin sombra en el piso. Sin desenfoque ni
> líneas de velocidad.
> por favor no cambies la katana de tamano no la cambies de mano no hagas
> extremidades estras manten la porpocion no hagas el personaje muy cabezon

Guarda cada hoja en `imagen-action/dam/sheets/` con el nombre indicado.

**Un solo lado (importante):** dibuja SIEMPRE al personaje mirando a la DERECHA.
El juego lo ESPEJA (voltea horizontal) solo cuando el rival está del otro lado
— así que NO hay que crear frames mirando a la izquierda. Con dibujar un lado
basta; el motor hace el otro. (Si un render sale mirando a la izquierda, lo
volteo yo al procesarlo.)

**Nitidez:** mientras menos frames por FILA, más grande y nítido sale cada
personaje. Para animaciones largas usa DOS FILAS en la misma hoja (mi
procesador las lee solo: fila de arriba primero, de izquierda a derecha), o
divide en dos hojas: `walk-sheet.png` y `walk-sheet-2.png` — también las
une solo. Ambas cosas a la vez funcionan.

**Frames rebeldes:** si un frame concreto sale mal una y otra vez (pose de
espaldas, espada quieta, etc.), deja de pedir la secuencia completa: pide
ESE frame SOLO, en su propia hoja de UN personaje, con descripción
hiperdetallada y prohibiciones explícitas. Nómbrala
`<accion>-f<numero>-sheet.png` (ej. `crouch-kick-f3-sheet.png`). Con un
solo personaje por imagen la IA obedece mucho mejor, y yo empalmo el frame
nuevo con los buenos de la hoja anterior (mi procesador escala frames
sueltos por masa corporal para que encajen).

---

## Las 17 hojas que necesitamos

### Básicas (empezar por estas 4)

1. **`pose-sheet.png`** — 8 frames en 2 filas de 4 (arriba f1-f4, abajo f5-f8),
   loop. Postura idle RELAJADA y CON ACTITUD (NO la guardia genérica de espada al
   frente — esa se ve muy normal). POSE:
   DAM de PERFIL (o casi de perfil) mirando a la DERECHA, hacia su rival: la CARA
   y la MIRADA van a la DERECHA (al frente del combate), NUNCA hacia la cámara ni
   el espectador. El cuerpo puede estar APENAS de 3/4 para dar volumen, pero el
   hombro delantero y la cara apuntan claramente a la DERECHA. NO de frente a la
   cámara, NO de espaldas. Peso cargado sobre la pierna trasera, la delantera relajada,
   cadera ladeada (contrapposto, actitud chula). Lleva la katana con UNA mano
   RECOSTADA sobre el HOMBRO / apoyada contra la espalda: la HOJA INCANDESCENTE
   sube en diagonal por DETRÁS del hombro apuntando atrás-arriba, el filo al rojo
   vivo enmarcando su silueta y tiñendo apenas el hombro y la mejilla. La otra
   mano suelta y relajada al costado (o el pulgar en la cadera). Cabeza en alto,
   mirada firme y confiada.
   RESPIRACIÓN VISIBLE (CLAVE — que de verdad se NOTE que respira, no un cuerpo
   rígido que solo flota): el PECHO se INFLA y se DESINFLA notoriamente. Al
   inhalar la CAJA TORÁCICA se EXPANDE (el pecho se ensancha y se levanta, los
   hombros suben, la espalda se yergue un poco); al exhalar el pecho se DESINFLA
   y baja, los hombros caen. Es sutil pero CLARAMENTE visible frame a frame. Los
   pies NO se mueven. Sube DESPACIO de f1 a f5 y baja DESPACIO de f5 a f8
   (desacelera arriba y abajo, tipo seno):
   - f1: base — pecho vacío/neutro, cuerpo asentado
   - f2: empieza a INFLAR el pecho — la caja torácica se abre un poco, hombros suben
   - f3: inhalando — el pecho ya visiblemente más inflado, a medio camino
   - f4: casi lleno — pecho bien expandido, subiendo y desacelerando
   - f5: TOPE del aire — pecho COMPLETAMENTE inflado, hombros arriba, micro-pausa
     (el punto MÁS ALTO); el brillo incandescente de la hoja en su punto más intenso
   - f6: empieza a EXHALAR — el pecho se desinfla un poco, hombros empiezan a caer
   - f7: exhalando — el pecho ya visiblemente más vacío, a medio camino de bajar
   - f8: casi asentado — pecho casi vacío, bajando y desacelerando; CONECTA con f1 (loop)
     **ROPA CON BRISA (acción secundaria, MÁS fluida):** el abrigo rojo y el pelo
     despeinado se mueven SUAVE y CONTINUAMENTE en los 8 frames, como si una LEVE
     BRISA los meciera todo el tiempo — el faldón/borde inferior del abrigo ondea y
     flota levemente, los mechones del pelo se agitan apenas, las solapas y mangas
     ondulan un poco. NUNCA rígidos ni 100% quietos: siempre con un movimiento vivo
     y fluido (pero suave, no una tormenta). El abrigo mantiene su borde inferior
     NORMAL y limpio (NO rasgado). MISMA cabeza y MISMA estatura en los 8 frames.

   **Atajo — EDITAR en vez de regenerar:** si ya tienes un sheet de DAM que te
   gusta, adjúntalo en ChatGPT y pega esto para cambiarle SOLO la pose a esta:

   > Toma este MISMO DAM (idéntica cara, colores, pelo, línea y proporciones) y
   > cámbiale SOLO la POSE. Nueva pose idle, más cool y con actitud: DAM de
   > PERFIL (o casi de perfil) mirando a la DERECHA hacia su rival — la CARA y la
   > MIRADA van a la DERECHA, NUNCA hacia la cámara ni el espectador. Peso en la
   > pierna trasera, cadera
   > ladeada (relajado, chulo). Lleva la katana con UNA mano RECOSTADA sobre el
   > HOMBRO / apoyada en la espalda: la hoja incandescente sube en diagonal por
   > DETRÁS del hombro (apuntando atrás-arriba), tiñendo de rojo el hombro y la
   > mejilla. La otra mano suelta al costado. Cabeza en alto, mirada confiada.
   > Mantén los 8 frames en 2 filas de 4 con RESPIRACIÓN sutil (sube f1→f5, baja
   > f5→f8): el pecho y los hombros suben/bajan ~3-4%, el abrigo y el pelo
   > arrastran con retraso, la katana recostada hace un leve bob. Fondo VERDE
   > PURO #00FF00. Misma cabeza y misma estatura en los 8 frames.

2. **`walk-sheet.png`** — 8 frames en 2 filas de 4. Ciclo de caminata de
   COMBATE: el torso casi quieto en guardia, la katana siempre lista en la
   mano (apuntando adelante-abajo), los brazos SIN balanceo de paseo. Las
   piernas hacen el ciclo clásico de animación:
   - f1: CONTACTO — pie derecho adelante tocando con el talón, pie
     izquierdo atrás en la punta, zancada media
   - f2: APOYO — el peso cae sobre la pierna derecha (pie plano), el
     izquierdo se despega, el cuerpo BAJA un poquito
   - f3: CRUCE — la pierna izquierda pasa DOBLADA junto a la derecha,
     cuerpo en su punto más ALTO, pies casi juntos
   - f4: ALCANCE — la pierna izquierda se estira adelante buscando el
     piso, la derecha empuja atrás
   - f5-f8: lo MISMO con las piernas cambiadas (f5 contacto con el pie
     izquierdo adelante, f6 apoyo, f7 cruce, f8 alcance)
     El f8 conecta perfecto con el f1 (loop infinito). El sube-y-baja del
     cuerpo es SUTIL. Misma altura base en todos los frames.

3. **`punch-sheet.png`** — 6 frames en Dos fila. UN SOLO golpe SÓLIDO: corte
   HORIZONTAL de katana de lado a lado a la altura del pecho (la hoja NO sube por
   encima de la cabeza).
   **La katana va SIEMPRE NÍTIDA (hoja normal, sin deformar ni convertir en arco):
   el arco/estela de corte lo agrega el JUEGO por código (`_draw_swing_trail`).
   Tú solo dibujas el MOVIMIENTO sólido del cuerpo.** Aplica la CAPA DE KEYFRAME de
   `GUIA-COMUN.md` (windup → swing → follow-through), pero SIN smear en el sprite.
   - f1: WINDUP — desde la guardia, el torso se tuerce y ENCOGE, la katana
     recogida cruzada ATRÁS (resorte cargado, silueta compacta)
   - f2: ARRANCA el swing — la katana entra al frente barriendo (hoja nítida,
     horizontal), el cuerpo empezando a desenroscarse
   - f3: IMPACTO — la katana COMPLETAMENTE extendida al frente, horizontal a la
     altura del pecho, brazo al máximo; el cuerpo ESTIRADO y volcado adelante,
     cara de esfuerzo. Es el pico del golpe
   - f4: FOLLOW-THROUGH / OVERSHOOT — la katana pasó de largo cruzada al OTRO
     lado; el torso SOBRE-GIRADO y desbalanceado adelante (se pasó del golpe)
   - f5: RECUPERA — la katana regresa hacia el cuerpo, casi de vuelta a la guardia
     La katana SIEMPRE NÍTIDA y del MISMO tamaño (mismo largo/grosor) en los 5
     frames — NUNCA deformada ni hecha arco (eso lo pone el motor).
     **ANATOMÍA (crítico — la AI suele fallar):** en CADA frame dos brazos completos,
     dos piernas, dos manos de 5 dedos — NADA cortado ni fuera del frame; personaje
     COMPLETO con margen.

4. **`kick-sheet.png`** — 6 frames en DOS FILAS de 3 (arriba f1-f3, abajo f4-f6).
   CORTE PESADO DESCENDENTE: alza la katana grande por encima de la cabeza y la
   deja caer en un tajo vertical al frente. Movimiento SÓLIDO — la katana va
   SIEMPRE NÍTIDA (el arco/estela lo pone el MOTOR, no la AI). Aplica la CAPA DE
   KEYFRAME de `GUIA-COMUN.md` (windup → impacto → follow-through), SIN smear.
   - f1: WINDUP — desde la guardia, rodillas flexionadas, la katana empieza a
     alzarse en diagonal sobre el hombro
   - f2: CARGA ARRIBA — katana COMPLETAMENTE en alto sobre la cabeza, cuerpo
     arqueado atrás, tenso, listo para descargar (resorte cargado)
   - f3: EL TAJO ARRANCA — la katana baja rápido en diagonal delantera alta, el
     cuerpo empieza a volcarse adelante
   - f4: IMPACTO — la katana llega abajo-al-frente (tajo completo), cuerpo
     inclinado y volcado adelante en zancada, brazos al máximo. Es el pico del golpe
   - f5: FOLLOW-THROUGH — la hoja siguió de largo hacia abajo, el cuerpo
     sobre-comprometido en la zancada baja (el peso del golpe)
   - f6: RECUPERA — se endereza y vuelve casi a la guardia, la katana subiendo de vuelta
     **⚠️ CRÍTICO — TAMAÑO CONSISTENTE (esto FALLÓ antes):** el PERSONAJE (cuerpo y
     cabeza) mide EXACTAMENTE LO MISMO en los 6 frames. Aunque en el f2 la katana
     se alce por encima de la cabeza, NO agrandes al personaje en ese frame — SOLO
     la KATANA se extiende hacia arriba; el CUERPO y la CABEZA quedan del mismo
     tamaño y con los PIES en la misma línea que en los demás frames. Grilla PAREJA
     (las 6 celdas del MISMO tamaño), personaje centrado en su celda con margen.
     **ANATOMÍA:** dos brazos completos, dos piernas, dos manos de 5 dedos, NADA
     cortado por el borde. La katana SIEMPRE nítida y del mismo largo y grosor.

### Agachado

5. **`crouch-sheet.png`** — 4 frames. Se agacha progresivamente hasta quedar
   en cuclillas con la katana lista: de pie → semiagachado → agachado firme.
   La ropa se mueve acorde al movimiento si se agacha la cola del sobretodo va hacia arriva ligeramnte y
   cuando ya se agacha cae

6. **`crouch-punch.mp4`** ✅ HECHO (2026-08-15) — ↓Q, estocada agachada. Prompt (pegar
   con la referencia + el bloque "Reglas fijas del clip" de GOLPES v2 al final):

   > He is CROUCHED LOW on one knee in his guard and stays crouched the ENTIRE clip.
   > ONE quick strike from the crouch: the big sword pulls back and up, then DRIVES
   > forward in a long low THRUST at waist height, both arms extending fully, torso
   > leaning into it, coat snapping — then recovers back into the same crouched
   > guard. Small, fast, compact — he never stands up, knees stay bent in every frame.

7. **`crouch-kick.mp4`** — ↓W, gancho ascendente antiaéreo. Prompt (pegar con la
   referencia + el bloque "Reglas fijas del clip" de GOLPES v2 al final):

   > He starts CROUCHED LOW, torso folded over his front knee, the big sword held
   > with BOTH hands low in front, blade tip pointing at the GROUND — loaded like a
   > lumberjack about to rip an axe out of the earth. Then ONE explosive RISING cut:
   > he drives upward into a low lunge, both arms launching forward-and-up, the blade
   > sweeping a rising diagonal until it ends crossed high behind his shoulder
   > pointing back-and-up, chest and hips still pointing RIGHT, coat blasted backward
   > by the motion. Then he lowers the sword and sinks back down into the starting
   > crouch. ONE single uppercut swing, his feet stay on the ground the whole time —
   > this is NOT a jump, he never leaves the floor.

### Salto

8. **`jump-sheet.png`** — 4 frames. Salto vertical: impulso (rodillas
   flexionadas) → subiendo (cuerpo estirado) → punto más alto → cayendo.

9. **`jump-punch-sheet.png`** — 4 frames. Corte aéreo: en el aire, corte de
   katana al frente: preparación → corte → extendido → recogida (sigue en el aire).

10. **`jump_kick`** — 3 frames. Ataque aéreo descendente: en el
    aire, corte o patada en diagonal hacia abajo: preparación → extensión → sostenido.

### Recibir daño

11. **`take-hit-sheet.png`** — 4 frames. Golpeado de pie: impacto en el
    rostro/pecho, cabeza hacia atrás, retrocede encorvado, casi recupera guardia.

12. **`take-hit-low-sheet.png`** — 2 frames. Recibe un GOLPE BAJO estando DE PIE
    (NO agachado): un ataque bajo le pega en las piernas / parte baja y DAM se
    DOBLA por el impacto — la pierna delantera cede, el torso se va hacia
    ADELANTE-ABAJO y la cabeza baja del golpe, pero SIGUE DE PIE (no se agacha a
    propósito, es la reacción de dolor a un golpe bajo). La katana en la mano.
    - f1: el golpe bajo impacta: la pierna cede y el torso se dobla
      adelante-abajo, gesto de dolor, cabeza baja.
    - f2: empieza a recuperar la postura de pie (aún ligeramente doblado).

13. **`strong-fly-sheet.png`** — **6 frames en 2 filas de 3**. GIRO EN EL AIRE al
    salir volando por un golpe fuerte: el cuerpo GIRA 360° sobre su eje mientras
    vuela (de frente → perfil → de espaldas → perfil → de frente). Muñeco de trapo
    noqueado, ojos cerrados, la katana en UNA sola mano floja. NADA de piso, pared
    ni efectos, solo el personaje sobre verde. (El estrellón contra la pared y el
    levantarse del piso son OTRAS hojas: `wall-bounce` y `hit-down`.)

    **`hit-down-sheet.png`** — **5 frames. LEVANTARSE DEL PISO** tras caer noqueado
    (esto es lo que se ve cuando toca el suelo). TODO de **PERFIL mirando a la
    DERECHA**. Fondo VERDE #00FF00, **SIN piso, pared, sombra ni efectos** (el suelo
    lo pone el motor). **Mismo tamaño de personaje en los 5 frames**, y el punto de
    apoyo contra el piso (cuerpo tendido / rodilla / pies) SIEMPRE en la MISMA línea
    inferior. Es una progresión CONTINUA de tirado en el suelo → de pie.
    Katana: al inicio CAÍDA en el piso junto a la mano; la RECOGE al incorporarse
    (una sola mano floja); recién en el último frame vuelve a empuñarla en guardia.
    - **f1 — BOCA ABAJO:** tendido de bruces en el piso, cuerpo COMPLETAMENTE
      HORIZONTAL pegado al suelo, brazos y piernas flojos, cabeza de lado, KO total.
      La katana en el piso junto a la mano.
    - **f2 — EMPUJA:** apoya las DOS manos en el piso y arquea la espalda; la cabeza
      y el pecho se despegan del suelo, las piernas aún tendidas atrás. Cara de
      aturdido/dolorido.
    - **f3 — UNA RODILLA:** sube a UNA rodilla (rodilla trasera en el piso, pie
      delantero apoyado), una mano en el suelo, la otra recogiendo la katana. Torso
      encorvado, cabeza gacha.
    - **f4 — LEVANTÁNDOSE:** casi de pie pero encorvado y tambaleante, recuperando
      el equilibrio, la katana ya en la mano colgando al costado.
    - **f5 — GUARDIA:** de pie y recuperado, vuelve a su POSTURA DE COMBATE (igual
      que la pose idle), katana empuñada lista.
      PROHIBIDO: de espaldas a la cámara (nunca se ve el logo del lobo), pose de
      salto, pose de ataque, o que el personaje cambie de tamaño entre frames.

### Defensa

14. **`block-sheet.png`** — 1 frame. Bloqueo de pie: cubierto con la katana
    en vertical frente al cuerpo (o antebrazos cruzados), postura firme.

15. **`block-low-sheet.png`** — 1 frame. Bloqueo agachado: en CUCLILLAS
    PROFUNDAS, cuerpo COMPACTO y encogido (cabeza baja, a la misma altura
    que la postura agachada normal — NO erguido, NO de rodillas con el
    torso vertical), cubriéndose con la katana en posición HORIZONTAL por
    encima de la cabeza, como un techo. La hoja NO apunta al cielo.

### Counter / Parry (mecánica defensiva NUEVA — gasta 1 barra)

**`counter-sheet.png`** — EXACTAMENTE **6 frames** en **2 filas de 3** (arriba f1 f2
f3, abajo f4 f5 f6, izq→der), con separación entre filas y frames. Es el
CONTRAATAQUE: DAM **desvía** el golpe del rival con la katana y responde con una
**ráfaga de 3 cortes rápidos**. Perfil a la DERECHA, cuerpo completo, MISMO tamaño en
los 6 frames. SIN fuego/llamas/partículas (los pone el motor); solo el filo ROJO de
la katana.

- **f1 — DESVÍO (parry):** katana levantada desviando un golpe entrante, cuerpo
  braced hacia el rival, peso adelantado.
- **f2 — 1er corte:** tajo rápido al frente.
- **f3 — 2do corte:** corte de retorno (cruce).
- **f4 — 3er corte (el fuerte):** katana lanzada al frente, cuerpo adelantado — el
  golpe más potente.
- **f5 — follow-through:** la extensión tras el corte, filo ROJO brillante.
- **f6 — recuperación:** vuelve a la guardia.
  → alimenta la animación `counter` (el parry-contraataque).

### Final de ronda (¡nuevas — completan el juego!)

16. **`ko-sheet.png`** — **5 frames. DERROTA: UNA sola caída HACIA ATRÁS, continua y
    FLUIDA, hasta quedar TENDIDO BOCA ARRIBA en el piso.** Vista lateral mirando a la
    DERECHA, fondo VERDE #00FF00, SIN piso/sombra/efectos (el suelo lo pone el motor).
    **Mismo tamaño de personaje en los 5 frames** (no se achica ni agranda). Es UNA
    sola dirección: se cae **de espaldas**. PROHIBIDO agacharse/arrodillarse boca
    ABAJO o en cuatro patas, y PROHIBIDO cambiar de sentido a mitad de la caída
    (si termina boca arriba, TODA la caída es hacia atrás).
    - **f1 — TAMBALEA:** de pie pero perdiendo el equilibrio HACIA ATRÁS; rodillas
      cediendo, torso y cabeza inclinándose atrás, brazos empezando a soltarse.
    - **f2 — SE VA DE ESPALDAS:** más inclinado hacia atrás, un pie se despega del
      piso, cuerpo arqueado cayendo de espaldas (aún en diagonal alta).
    - **f3 — EN PLENA CAÍDA:** cuerpo a ~45° cayendo de espaldas hacia el suelo,
      brazos y piernas flojos (muñeco de trapo), cabeza hacia atrás.
    - **f4 — TOCA EL PISO:** la espalda llega al suelo, cuerpo ya casi HORIZONTAL
      boca arriba, piernas y brazos asentándose.
    - **f5 — TENDIDO BOCA ARRIBA:** completamente horizontal en el suelo, boca arriba,
      inmóvil, ojos cerrados, KO total. La katana caída en el piso junto a la mano.
      Este frame se queda en pantalla.
    - **NOTA — dos KO distintos:** este `ko` (boca ARRIBA, caída de espaldas) es para el
      KO **en el suelo**. El KO **en el aire** (cuando el golpe mortal lo lanzó) usa la
      anim `ko_air` (sheet `ok-2-sheet.png`, 3 frames): cae de BRUCES → se estrella →
      queda TENDIDO BOCA ABAJO. Coherente con salir despedido hacia adelante. Al morir
      lanzado, el rival pasa directo a `ko_air` (no gira ni flota) y aterriza boca abajo.
    - **`ok-2-sheet.png`** — 3 frames, KO aéreo boca abajo, vista lateral a la DERECHA,
      fondo VERDE, mismo tamaño de personaje en los 3. f1: cayendo de bruces en el aire
      (cuerpo diagonal, cabeza hacia abajo-adelante). f2: casi horizontal, estrellándose.
      f3: tendido completamente horizontal boca abajo en el piso, brazos/piernas flojos.
      Los frames 4-5 apoyan el cuerpo en la MISMA línea inferior (piso).
      **TAMAÑO DE LA KATANA (importante):** hoja de LARGO NORMAL/razonable (tipo espada,
      aprox. el largo del brazo o un poco más), NUNCA una hoja enorme ni muy larga. El
      PERSONAJE nunca se debe achicar para que la katana quepa en el lienzo: si algo se
      ajusta, es la katana (mantenla proporcionada y más corta), jamás encoger al
      personaje. El personaje ocupa el lienzo a tamaño completo y consistente.

17. **`victory-sheet.png` + `victory-sheet-2.png`** — 8 frames en total
    (4 por hoja). Victoria, con la envainada COMPLETA — cada frame una
    posición claramente distinta:
    - f1: baja la guardia, katana suelta al costado
    - f2: alza la katana a medio camino, en diagonal
    - f3: katana COMPLETAMENTE arriba, brazo estirado, pose triunfal,
      la hoja al máximo brillo
    - f4: mantiene el triunfo, cabeza en alto (ligera variación del f3)
    - f5: baja la katana al costado y acerca la hoja a la vaina,
      mirando la empuñadura
    - f6: la hoja ENTRANDO a la vaina, a medio camino, el brillo
      apagándose
    - f7: katana envainada por completo, la mano suelta la empuñadura
    - f8: postura final relajada, mano en el bolsillo. Este frame se
      queda en pantalla.
      dice como dos palabras tiene que hacer moviendo la boca por como dos plabras

---

## Golpes especiales

18. **`spin-kick-sheet.png`** — 8 frames en DOS FILAS de 4. PATADA
    GIRATORIA que avanza (estilo tatsumaki): DAM gira 360° sobre su eje
    con una pierna extendida horizontal. EXCEPCIÓN ÚNICA a la regla de
    perfil: como el personaje ROTA, los frames intermedios sí lo muestran
    de frente y de espaldas según el punto del giro. IMPORTANTE: aunque en
    el juego el movimiento viaja hacia adelante, dibuja TODOS los frames
    EN EL MISMO SITIO (pies/cadera sobre la misma vertical) — el
    desplazamiento lo hace el motor:
    - f1: agazapado en perfil (derecha), brazos recogidos, katana pegada
      al cuerpo — cargando el giro
    - f2: arranca el giro: semi-frente a la cámara, pierna derecha
      subiendo, torso rotando
    - f3: IMPACTO — perfil derecha, PATADA EXTENDIDA horizontal a la
      altura del pecho, pierna recta al frente
    - f4: el giro continúa: de espaldas a la cámara, la pierna extendida
      barriendo al lado contrario
    - f5: semi-perfil volviendo: la pierna aún extendida
    - f6: SEGUNDO IMPACTO — perfil derecha otra vez, patada extendida
      horizontal
    - f7: aterrizando: la pierna se recoge, el cuerpo baja
    - f8: pose de guardia (perfil derecha)
      La katana permanece EN LA MANO, pegada al cuerpo, durante todo el
      giro — nunca se suelta ni desaparece.

19. **`weak-punch-sheet.png`** — 4 frames en UNA fila. JAB RÁPIDO DE UNA
    MANO: el golpe más ligero y veloz del personaje — un piquete corto de
    katana con UNA sola mano, sin girar el cuerpo:
    - f1: desde la guardia, el brazo delantero empieza a lanzar la katana
      al frente CON UNA MANO (la otra mano suelta, cerca del cuerpo)
    - f2: IMPACTO — brazo extendido al frente con UNA mano, katana
      horizontal apuntando adelante a la altura del pecho, hombro
      adelantado; el cuerpo casi no se mueve de la guardia
    - f3: el brazo regresa, la katana a medio camino de vuelta
    - f4: pose de guardia otra vez
      Es un movimiento CORTO y SECO: poca extensión, nada de barridos
      amplios ni giros de torso — pura velocidad de brazo.

20. **`air-spin-kick-sheet.png`** — 6 frames en DOS FILAS de 3. DOBLE PATADA
    AÉREA (arriba+E): DAM salta y lanza DOS patadas rectas al FRENTE mientras
    sostiene la katana ABAJO-al frente, QUIETA. Todo en PERFIL mirando a la
    DERECHA, en el aire, dibujado EN EL MISMO SITIO y a la MISMA escala (el
    vuelo lo pone el motor). NADA de voltereta ni giro.
    **LA KATANA (clave para que salga consistente):** va en la mano de ATRÁS,
    con el brazo BAJO y la HOJA apuntando hacia ABAJO-ADELANTE (diagonal, la
    punta hacia adelante-abajo), COMPLETAMENTE QUIETA e IDÉNTICA en los 6
    frames — NO gira, NO sube, NO se mueve, NO cambia de forma ni de tamaño.
    Es solo un apoyo visual; lo único que se mueve son las PIERNAS.
    - f1: en el aire, rodillas recogidas y cadera cargada atrás, listo para
      la primera patada. Katana abajo-al frente.
    - f2: PRIMERA PATADA — la pierna delantera se dispara RECTA al FRENTE
      (horizontal), extendida al máximo. Katana igual, abajo-al frente.
    - f3: recoge esa pierna (rodilla al pecho), transición entre patadas.
    - f4: SEGUNDA PATADA — la OTRA pierna se dispara RECTA al FRENTE,
      extendida al máximo (un pelín más alta que la primera para que se note
      que son dos golpes). Katana igual.
    - f5: recoge la pierna, el torso se endereza un poco (fin del segundo golpe).
    - f6: postura de caída en el aire, piernas recogiéndose. Katana igual.
      NUNCA muevas la katana entre frames: va SIEMPRE abajo-al frente, idéntica.
      Nada de giro, voltereta ni katana en alto.

20b. **`air-jab-sheet-1.png`** — 4 frames en UNA fila. JAB AÉREO DOBLE (arriba+R):
DAM da DOS puñetazos rápidos al FRENTE con el PUÑO LIBRE (la mano que NO tiene
la katana) mientras sostiene la katana ABAJO-al frente, QUIETA. Perfil mirando
a la DERECHA, en el aire, dibujado EN EL MISMO SITIO y a la MISMA escala.
**LA KATANA (clave para que salga consistente):** igual que en la doble patada
— en la mano de ATRÁS, brazo BAJO, la HOJA apuntando ABAJO-ADELANTE, QUIETA e
IDÉNTICA en los 4 frames (no gira, no sube, no se mueve). Lo único que se
mueve es el BRAZO LIBRE que da los jabs. - f1: en el aire, puño libre cargado atrás (junto al mentón), listo. - f2: PRIMER JAB — el puño libre sale RECTO al frente, brazo extendido. - f3: recoge el puño (vuelve junto al mentón). - f4: SEGUNDO JAB — el puño libre sale RECTO al frente otra vez, extendido.
Es un golpe LIGERO y RÁPIDO (jab), poca extensión del cuerpo. La katana
SIEMPRE abajo-al frente, idéntica. Nada de katana en alto ni girando.

---

## Efectos de combate (sin personaje: SOLO el efecto sobre verde)

Reglas para TODOS los efectos: fondo VERDE PURO #00FF00, SIN personaje,
SIN texto ni marcas. Una sola fila de frames, todos a la MISMA escala y
CENTRADOS en su espacio. Estilo cel-anime de juego de pelea: formas con
bordes DEFINIDOS y núcleos sólidos — nada de brumas o auras translúcidas
grandes (se pierden al recortar el verde). PROHIBIDO usar tonos verdes
en el efecto.

21. **`fx-hit-sheet.png`** — 5 frames. RELÁMPAGO DE IMPACTO gigante
    (estilo 2XKO): ráfagas de RAYOS DENTADOS muy ALARGADOS en diagonal
    (zigzag afilado, como látigos de relámpago), núcleo BLANCO ardiente
    con contorno amarillo-naranja. La forma es ALTA y en diagonal, no una
    estrella redonda. EMPIEZA PEQUEÑO y crece muchísimo:
    - f1: nace — un flash chico y compacto, apenas unas puntas
    - f2: crece — los rayos dentados se disparan en diagonal, ya el
      doble de grande
    - f3: PICO — ENORME: ráfaga de relámpagos alargados cruzando en
      diagonal todo el espacio del frame, grueso y saturado de blanco
    - f4: se rompe — los rayos se fragmentan en trozos separados que
      conservan la dirección diagonal
    - f5: se disuelve — esquirlas débiles dispersándose
      Los 5 frames CENTRADOS en el mismo punto (el punto del impacto es
      el centro de cada frame, y desde ahí crece).

22. **`fx-block-sheet.png`** — 5 frames en UNA fila. ANILLO DE BARRERA de bloqueo
    que ROTA sobre su propio eje (estilo 2XKO). Un ARO OVALADO VERTICAL (más alto
    que ancho, como un escudo frente al cuerpo) de energía AZUL brillante con
    núcleo BLANCO-CELESTE. El aro se dibuja como un TRAZO tipo SWOOSH — una
    pincelada GRUESA de bordes DEFINIDOS (cel-anime) que barre en círculo, con las
    PUNTAS AFILADAS donde el trazo abre y cierra (queda una ABERTURA en el aro,
    no es un óvalo perfecto cerrado). SOLO se dibuja el BORDE — el interior queda
    VACÍO (verde puro), para ver a través en el juego.
    **La ROTACIÓN es la clave:** la abertura y las puntas del trazo GIRAN de
    posición frame a frame, como si el aro rotara sobre su eje.
    - f1: NACE — un swoosh azul corto empezando a curvarse (medio aro), brillo suave
    - f2: FORMA — el trazo barre y cierra casi todo el óvalo, brillo creciendo
    - f3: PICO — el aro completo, grueso y MUY brillante, núcleo blanco-celeste;
      la abertura hacia arriba-derecha
    - f4: ROTA — el mismo aro pero con la abertura/puntas GIRADAS a otro ángulo
      (se ve que rotó sobre su eje), el borde empezando a adelgazar
    - f5: SE DISIPA — el aro se abre y se deshace en un swoosh tenue que se desvanece
      Todos los aros CENTRADOS en el mismo punto y del MISMO tamaño. Estilo
      cel-anime: bordes de línea DEFINIDOS y núcleo sólido brillante, NADA de bruma
      translúcida. Colores AZUL brillante + blanco-celeste. PROHIBIDO usar tonos
      verdes en el efecto (el verde es solo el fondo). Fondo VERDE PURO #00FF00, sin
      personaje, sin texto ni marcas. Debe leerse claramente DISTINTO al relámpago
      naranja de daño.

---

## Movimientos agachados nuevos (personaje: aplican las reglas generales)

23. **`crouch-jab.mp4`** — ↓R, pinchazo bajo. Prompt para el tool de animación (pegar
    con la referencia + el bloque "Reglas fijas del clip" de GOLPES v2 al final):

    > He is CROUCHED LOW in his guard and stays crouched the ENTIRE clip. ONE short
    > quick one-hand THRUST low to the front: the sword hand pulls back beside his
    > hip, then the blade shoots straight forward HORIZONTAL at SHIN height, point
    > first, arm extending — then retracts just as fast back into the same crouched
    > guard. Short and DRY: minimal body motion, no wide swings, he never stands up,
    > never jumps. The fastest, lightest low poke he has.
    >
    > SIDE VIEW LOCKED: this is a STRICT PROFILE in every single frame — his face in
    > profile pointing at the RIGHT edge of the screen, ONE shoulder toward the
    > camera, his chest NEVER square to the camera. He NEVER turns around, NEVER
    > faces the viewer, we NEVER see the wolf logo on the back of his coat — even at
    > the peak of the thrust his nose keeps pointing at the RIGHT edge of the screen.
    >
    > ONE SWORD ONLY: he owns exactly ONE sword — the same single sword the WHOLE
    > clip, gripped in his forward hand. It NEVER splits in two, never duplicates,
    > never becomes two blades, and NO second weapon ever appears anywhere. His
    > OTHER hand stays EMPTY (a bare closed fist near his body) in every frame.

24. **`sweep.mp4`** — ↓E, barrido derribador a ras de piso. Prompt para el tool de
    animación (pegar con la referencia + el bloque "Reglas fijas del clip" al final):

    > He is CROUCHED LOW and stays crouched the ENTIRE clip — he never stands up in
    > any frame. ONE wide floor-scraping sweep WITH THE SWORD (this is NOT a kick):
    > the blade loads low BEHIND him toward the LEFT edge of the screen, tip almost
    > touching the ground, then sweeps LOW across the front toward the RIGHT edge of
    > the screen at ankle height hugging the floor, arm fully extended at the peak,
    > his torso leaning into it — and the blade brakes low in front — then he returns
    > to the same crouched guard.
    >
    > SIDE VIEW LOCKED: this is a STRICT PROFILE in every single frame — his face in
    > profile pointing at the RIGHT edge of the screen, ONE shoulder toward the
    > camera, his chest NEVER square to the camera. He NEVER turns around, NEVER
    > spins his body, NEVER faces the viewer, and we NEVER see the wolf logo on the
    > back of his coat. The sweep is done with the ARM and a slight lean of the torso
    > — his knees, chest and NOSE keep pointing at the RIGHT edge of the screen in
    > EVERY frame, even at the peak of the sweep. Only the SWORD travels across the
    > screen; the man does not rotate.

    > ONE SWORD ONLY: he owns exactly ONE sword — the same single sword the WHOLE
    > clip, gripped in his forward hand. It NEVER splits in two, never duplicates,
    > never becomes two blades, and NO second weapon ever appears anywhere. His
    > OTHER hand stays EMPTY (a bare closed fist near his body) in every frame.

25. **`jump-dust-sheet.png`** — 6 frames. POLVO DE SALTO (anillo de
    despegue). SOLO el humo, sin personaje ni piso. Fondo verde puro
    #00FF00. Estilo cel-anime: humo gris claro/blanco con bordes de
    línea definidos y sombras grises (nubes de humo de anime de peleas),
    NADA de degradados borrosos ni humo translúcido. El punto de
    despegue queda en el CENTRO-ABAJO, anclado igual en los 6 frames:
    - f1: estallido pequeño y compacto de polvo en el centro-abajo
    - f2: crece a los lados, se forman dos lóbulos de humo izq/der
    - f3: PICO — anillo ancho y bajo, dos lóbulos grandes esponjosos a
      los lados curvándose hacia arriba y afuera, con motitas saltando
    - f4: el anillo se abre más, los lóbulos se separan y suben,
      adelgazando
    - f5: se disuelve en jirones y nubecitas sueltas
    - f6: casi ido, hilitos tenues de polvo
      (Después haremos `land-dust-sheet.png` para la caída: más pesado,
      el polvo se aplasta hacia afuera al golpear el piso.)

26. **`dash-smoke-sheet.png`** — 6 frames. RÁFAGA DE HUMO DE DASH/GOLPE.
    SOLO el humo, sin personaje. Fondo verde puro #00FF00. Estilo
    cel-anime: humo blanco con bordes de línea definidos y sombras gris
    claro, NADA borroso. Nube esponjosa que brota hacia arriba con un
    jirón enroscándose a un costado y una COLA/ESTELA afilada apuntando
    a UN lado (la dirección del dash; yo la espejo en el juego). Base
    anclada igual en los 6 frames:
    - f1: brote pequeño y compacto, la cola insinuándose
    - f2: crece, la nube sube y la cola se estira al lado
    - f3: PICO — nube grande de lóbulos redondos + jirón en espiral a un
      costado + cola swoosh apuntando al lado
    - f4: se abre y adelgaza
    - f5: se disuelve en jirones sueltos
    - f6: casi ido, hilitos tenues

27. **`pummeled-sheet.png`** — 4 frames (loop). DAM SIENDO MACHACADO de
    pie durante el super: se tambalea recibiendo golpes rápidos de
    frente, pies plantados en el piso (NO flota, NO salta). Todo de
    perfil, katana en mano floja y baja. CRÍTICO: los 4 frames miran a
    la MISMA dirección (a la DERECHA), NUNCA uno mirando al otro lado.
    ANATOMÍA correcta: exactamente DOS brazos, DOS piernas, DOS manos de
    5 dedos, UNA sola katana — NADA de manos, dedos, brazos o piernas
    de más. Los 4 frames forman un ciclo continuo:
    - f1: cabeza y torso SNAPEADOS hacia ATRÁS por un golpe frontal,
      desbalanceado atrás, brazos flotando arriba a la defensiva
    - f2: DOBLADO hacia adelante (golpe al estómago), encorvado,
      cabeza abajo
    - f3: torso TORCIDO a un lado (golpe lateral), tambaleándose,
      cabeza volteada
    - f4: SNAPEADO atrás otra vez, a punto de reconectar con f1
      Cara de dolor, cuerpo suelto de muñeco pero DE PIE. El f4 conecta
      con el f1 (loop infinito rápido).

28. **`flame-cast-sheet.png`** — 5 frames. DAM LANZA EL INFIERNO (crítico
    de fuego): alza la katana y suelta el poder. Perfil, mira a la
    derecha, pies plantados, katana incandescente:
    - f1: carga — baja apenas, lleva la katana ATRÁS-ABAJO juntando
      energía, cuerpo tenso
    - f2: ALZA la katana en alto sobre la cabeza, ambas manos, el cuerpo
      estirado hacia arriba
    - f3: pico de carga — katana en lo más alto, brazos extendidos, torso
      arqueado atrás listo para descargar
    - f4: DESCARGA — swing rápido de la katana hacia ADELANTE-abajo,
      lanzando el poder al frente, torso volcado adelante
    - f5: remate — brazo extendido al frente tras soltar, katana apuntando
      adelante-abajo (postura de recuperación)
      (Yo sincronizo el proyectil de fuego para que salga en el f4.)

29. **`fire-wave-sheet.png`** — 6 frames en 2 filas de 3. GRAN OLA DE FUEGO que
    BARRE el carril hacia adelante (el INFIERNO) — como una MURALLA/ola de fuego
    ancha y alta que erupciona y se estira a lo LARGO, NO un vórtice compacto.
    SOLO el fuego, sin personaje. Fondo verde puro #00FF00. Estilo cel-anime,
    líneas definidas, con lenguas de fuego, esquirlas y chispas saltando.
    **COLOR = FUEGO ROJO:** núcleo BLANCO-AMARILLO ardiente en la base → cuerpo
    NARANJA → lenguas y puntas ROJO intenso (NADA de azul ni morado). La ola es
    más ANCHA que alta (barre horizontal), naciendo a la IZQUIERDA y estirándose
    a la DERECHA (yo la espejo).
    - f1: NACE — una lengua de fuego baja y ancha brota desde la izquierda.
    - f2: CRECE — la ola se estira a la derecha, ganando alto, lenguas
      enroscándose hacia arriba.
    - f3: casi extendida — la muralla de fuego cubre gran parte del ancho.
    - f4: PICO — la ola LLENA todo el ancho a máxima altura, muralla de fuego
      dramática con chispas volando.
    - f5: empieza a bajar, las llamas se acuestan y se separan en jirones.
    - f6: se disuelve dejando brasas y humo tenue (deja el terreno ardiendo).
      Dibuja la ola LARGA (ocupa casi todo el ancho del frame en el pico); deja
      margen verde de sobra.

30b. **`fire-floor-sheet.png`** — 4 frames (loop). FUEGO EN EL PISO que QUEDA
tras el inferno (un charco de llamas ardiendo en el suelo). SOLO el fuego,
sin personaje. Fondo verde #00FF00. Una franja BAJA y ancha de llamas ROJO-
naranja lamiendo el piso, con lenguas que suben y ondean; núcleo amarillo en
la base, puntas rojas. Los 4 frames son el fuego ONDULANDO en su sitio (loop
suave: f4 conecta con f1). Más ancho que alto, pegado al piso.

31. **`fire-wave-sheet-impact.png`** — 6 frames (UNA vez, NO loop). EXPLOSIÓN
    del INFIERNO cuando el vórtice CONECTA con el rival. SOLO el fuego/humo,
    sin personaje. Fondo verde puro #00FF00. Estilo cel-anime:
    - f1: estallido máximo — núcleo blanco-amarillo cegador con picos de
      fuego radiales y una nube de humo oscuro rodeándolo.
    - f2-f3: el fuego se apaga hacia el centro, el humo se expande y se
      enrosca, esquirlas naranjas incandescentes flotando.
    - f4-f5: bola de humo oscuro con brasas naranjas dentro, disipándose.
    - f6: casi todo humo tenue que se desvanece (conecta con "desaparecido").
      Todos los frames CENTRADOS en el mismo punto (yo recorto uniforme para
      que la explosión no salte de tamaño). Lo reproduzco 1 vez sobre el torso
      del rival y se apaga solo.

---

## Paridad con FAVI (Salto+R y mortal neutral)

32. **`air-jab-sheet.png`** — 4 frames en UNA fila. **DOBLE CORTE AÉREO** (salto + R):
    en el AIRE se encoge un poco (rodillas subidas) y hace DOS cortes rápidos y ligeros
    de katana al frente, uno y luego el otro (jab aéreo veloz, no un tajo pesado). Vista
    de perfil, mirando a la DERECHA, TODO en el aire (nada toca el piso), la MISMA altura
    de cuerpo en los 4 frames:
    - f1: en el aire, encogido (muslos arriba), katana recogida junto al cuerpo cargando
    - f2: PRIMER corte — extiende la katana al frente en un tajo horizontal corto y rápido
    - f3: SEGUNDO corte — recoge y vuelve a cortar al frente (segundo tajo veloz), la hoja
      incandescente marcando el filo
    - f4: recoge la katana de nuevo junto al cuerpo (recuperación en el aire)
      Movimiento compacto y rápido (doble tajo aéreo); torso encogido, misma altura en los 4.

33. **`neutral-spin.png`** — 4 frames en UNA fila. **MORTAL AÉREO HACIA ADELANTE** (salto
    hacia el rival): un FLIP/mortal que gira 360° en el aire, como los juegos de pelea
    cuando saltan hacia adelante. La katana va RECOGIDA/pegada al cuerpo durante el giro
    (no corta, es un movimiento de desplazamiento). EXCEPCIÓN a la vista de perfil: como
    ROTA, los frames lo muestran de perfil, de cabeza y saliendo del giro:
    - f1: casi de pie/encogido, empieza a rotar hacia adelante, katana recogida
    - f2: horizontal a mitad del giro (cabeza hacia adelante-abajo), cuerpo doblado
    - f3: DE CABEZA (pies arriba, cabeza abajo), en pleno mortal
    - f4: saliendo del giro, los pies bajando para caer
      Los 4 frames van EN EL MISMO SITIO (el desplazamiento lo hace el motor). La katana
      SIEMPRE recogida y en una pieza; energía roja/incandescente sutil, nada de fuego.

---

## Fase 2 (más adelante, no ahora)

- `fire-slash-sheet.png` — proyectil de fuego (Fire Slash)
- `ember-dash-sheet.png` — dash envuelto en llamas
- `inferno-burst-sheet.png` — super ataque en área
- `intro-sheet.png` — entrada al escenario antes del Round 1

## Recordatorios

- Genera TODO en la misma conversación con tu IA, siempre adjuntando la
  referencia de DAM. Si un frame sale con otros colores o detalles, repítelo
  antes de guardar la hoja.
- Yo recorto el verde, alineo y conecto cada hoja — tú solo avísame cuál está.
- Frames finales: los genero yo en `imagen-action/dam/` como `dam-[accion]-N.png`.

---

## NIVELACIÓN con AYE — clips de VIDEO que faltan (workflow nuevo)

> Estas animaciones se generan como CLIPS DE VIDEO (no hojas): 960×960, fondo verde puro
> #00FF00 plano, UNA toma continua. Guardar como `imagen-action/dam/sheets/<accion>.mp4`.
> Yo los proceso a frames. Adjuntar SIEMPRE la referencia de DAM.

**Reglas fijas del clip (pegar al final de cada prompt):**

> Same exact character as the reference image. STRICT SIDE VIEW / PROFILE, facing RIGHT the
> whole time (NEVER frontal, NEVER three-quarter). Fixed locked TRIPOD camera — no zoom, no
> pan, no drift. He stays the SAME SIZE and on the SAME SPOT the entire clip. Pure flat green
> #00FF00 background. Nobody else in the frame; no effects, no particles, no fire, no glow.
> His oversized sword is a RIGID SOLID blade of CONSTANT length and shape — no bending,
> stretching, warping or redesign, identical every frame, and it never changes hands.
> He owns exactly ONE sword: it never SPLITS in two, never duplicates, never mirrors —
> NO second blade or extra weapon ever appears in any frame; his free hand stays EMPTY.
> CAMERA HARD-LOCKED — this is STATIC WIDE footage, like a fixed security camera: the framing
> of the FIRST frame is the framing of EVERY frame. WIDE FULL-BODY SHOT the entire clip: his
> whole body from the top of his head to the soles of his boots visible in every frame, with
> clear green margin above his head and below his feet — that empty green space is CORRECT
> and REQUIRED, do NOT reframe or move closer to fill it. His head must be the SAME SIZE in
> pixels in the first frame, the middle frame and the last frame — if he gets bigger at ANY
> point, the clip is WRONG.

**`get_up`** _(tendido boca arriba → se para COMPLETO hasta su idle. Hoy el juego lo para de
golpe con un snap — esta anim lo arregla):_

> He is LYING flat on his BACK on the ground, head toward the LEFT and feet toward the RIGHT,
> eyes closed, one hand still GRIPPING his big sword which rests flat on the ground beside
> him. He wakes and GETS UP in one continuous motion: opens his eyes, pushes off the ground
> with his free hand, brings his legs under himself and RISES all the way up to his FEET,
> lifting the sword with him. He MUST END standing EXACTLY in his relaxed idle stance from
> the reference: upright, facing right, the sword resting over his SHOULDER held in one hand,
> the other arm relaxed at his side. Do NOT stop halfway (no kneeling/sitting end), do NOT
> jump to his feet instantly — a natural, grounded recovery, slightly heavy (he is a
> heavyweight fighter). The coat follows the motion and settles at the end.

**`land`** _(aterrizaje del salto: flexión corta de rodillas — hoy cae seco al idle):_

> He is already IN THE AIR just above the ground, falling feet-first (start the clip with his
> boots a small distance above the floor). He LANDS on both feet on the SAME SPOT: knees BEND
> deep for one beat absorbing the impact, torso leans slightly forward, the long coat flares
> up and then settles down, hair bounces once. Then he straightens back up and ENDS standing
> EXACTLY in his relaxed idle stance from the reference (sword over his shoulder). Short clip,
> one single landing, no jump afterwards, feet stay planted after touching down.

## GOLPES v2 (clips de video) — de pie, bajos e INFERNO cast

> Cada acción = UN clip. Guardar como `imagen-action/dam/sheets/<accion>.mp4` y me avisas.
> **Pegar al final de CADA prompt el bloque "Reglas fijas del clip" de arriba** (perfil
> derecha + cámara de seguridad fija + espada rígida) y adjuntar la referencia de DAM.
> El arco/estela del corte lo dibuja el MOTOR: la espada va SIEMPRE nítida, sin líneas de
> velocidad. Todos los golpes: UN solo ataque, EN EL SITIO, y termina de vuelta en guardia.

**`punch.mp4` (Q — corte horizontal al pecho):**

> From his fighting guard he delivers ONE single powerful HORIZONTAL slash at chest height:
> first he COILS — torso twisting, the big sword pulled back across his body like a loaded
> spring — then the blade sweeps FLAT across the front from left to right, arm fully
> extended at the peak, body leaning hard into the cut, long coat and hair whipping with it,
> and the swing OVERSHOOTS past his other side before he pulls the sword back and settles
> into the same guard. The blade stays BELOW head height the whole swing. FAST and heavy —
> one clean slash, no combo, no second swing.

**`punch2.mp4` (encadenado — corte de REVÉS):**

> From a stance with his big sword already crossed to his LEFT side (as if he just finished
> a slash), he whips ONE single BACKHAND horizontal cut the opposite way — the blade sweeps
> FLAT back across the front at chest height, arm extending fully, torso uncoiling into it,
> coat snapping with the motion — then he recovers into his fighting guard. One clean
> return-slash, blade below head height, fast and heavy.

**`kick.mp4` (W — tajo vertical PESADO):**

> From his fighting guard he raises the big sword ALL THE WAY overhead — body arching back,
> loaded like a spring, feet planted (only the SWORD goes high, his body and head stay the
> same size) — then CRASHES it down in one heavy vertical cleave to the low front, body
> pitching forward into a deep lunge with the weight of the blow, coat flying up behind him,
> the blade ending low in front — then he straightens back up into the same guard. ONE
> single overhead cleave, slow to load and BRUTAL coming down.

**`weak_punch.mp4` (R — piquete rápido a UNA mano):**

> From his fighting guard he snaps ONE short quick THRUST with the sword in ONE hand — the
> blade shoots straight forward horizontal at chest height, point first, shoulder driving
> in, the other hand staying loose near his body — and he retracts it just as fast back
> into the same guard. A SHORT, DRY poke: minimal body motion, no wide swings, no torso
> spin — pure arm speed. The fastest, lightest move he has.

**`spin_kick.mp4` (E — patada giratoria estilo tatsumaki):**

> From a slight crouch he ROTATES 360 degrees on his axis with one leg extended straight
> out horizontal at chest height, kicking all the way around — the ONLY allowed exception
> to the side-view rule: as he spins, intermediate frames naturally show his front and his
> back. The big sword stays GRIPPED in his hand, pulled in TIGHT against his body for the
> whole spin — it never swings, never leaves his hand. He spins ON ONE SPOT (no traveling),
> lands back in his side-view fighting guard facing RIGHT. One or two full spins, fast.

**`crouch_punch.mp4` (↓Q — corte rápido agachado):**

> He is CROUCHED LOW in his guard and stays crouched the ENTIRE clip. ONE quick mid-height
> slash from the crouch: the sword pulls back short, then sweeps a fast FLAT cut forward at
> waist height, arm extending, torso leaning in — then recovers back into the same crouched
> guard. Small, fast, compact — he never stands up, never rises, knees stay bent in every
> frame.

**`crouch_jab.mp4` (↓R — estocada baja a una mano):**

> He is CROUCHED LOW in his guard and stays crouched the ENTIRE clip. ONE short one-hand
> THRUST low to the front: the sword hand pulls back beside his hip, then the blade shoots
> straight forward HORIZONTAL at SHIN height, point first — then retracts back into the
> same crouched guard. Short and dry, minimal motion, he never stands up, never rises.

**`crouch_kick.mp4` (↓W — gancho ascendente de arma pesada, antiaéreo):**

> He starts CROUCHED LOW, torso folded over his front knee, the big sword held with BOTH
> hands low in front, blade tip pointing at the GROUND — loaded like a lumberjack about to
> rip an axe out of the earth. Then ONE explosive RISING cut: he drives upward into a low
> lunge, both arms launching forward-and-up, the blade sweeping a rising diagonal until it
> ends crossed high behind his shoulder pointing back-and-up, chest and hips still pointing
> RIGHT, coat blasted backward by the motion. Then he lowers the sword and sinks back down
> into the starting crouch. ONE single uppercut swing, feet on the ground the whole time —
> this is NOT a jump.

**`sweep.mp4` (↓E — barrido derribador a ras de piso):**

> He is CROUCHED LOW and stays crouched the ENTIRE clip — he never stands up in any frame.
> ONE wide floor-scraping sweep WITH THE SWORD (this is NOT a kick): the blade loads
> back-and-down behind him, tip almost touching the ground, then sweeps LOW across the
> entire front at ankle height hugging the floor, arm fully extended at the peak, torso
> rotating with the momentum, and the blade brakes crossed on his other side — then he
> returns to the same crouched guard.

**`inferno_cast.mp4` (canaleo del INFERNO — reemplaza el frame congelado del super viejo):**

> He RESTS his big sword over his SHOULDER (one clean motion: the flat of the blade
> comes to rest on his shoulder, held relaxed in one hand — his signature idle carry —
> and it STAYS there the rest of the clip). Then he plants his feet WIDE and THRUSTS
> his OTHER hand out open-palmed toward the RIGHT edge of the screen, arm locked
> straight. The moment the palm opens, a HURRICANE-FORCE WIND slams against him from
> the right: his long coat and his hair get BLASTED violently BACKWARD (toward the
> LEFT edge of the screen), whipping and snapping, his sleeve rippling, his stance low
> and rigid leaning INTO the wind, the outstretched arm trembling with strain. He
> HOLDS this pose for the whole clip — the only motion is the violent backward
> whipping of coat and hair and small tense shudders of the body. He stays ON ONE
> SPOT, never walks, the sword never leaves his shoulder.
>
> HIS HAND IS EMPTY: the open palm is a BARE gloved hand — NOTHING comes out of it,
> NOTHING appears in it or around it. NO fire, NO flames, NO glow, NO energy ball, NO
> light, NO smoke, NO particles ANYWHERE in the clip — only the man and the wind. (The
> game engine draws all the fire later; this clip is ONLY the actor performing.)
>
> CAMERA HARD-LOCKED — STATIC WIDE footage, like a fixed security camera: the framing
> of the FIRST frame is the framing of EVERY frame. His whole body head-to-boots
> visible always, with clear green margin above his head and below his feet — that
> empty space is REQUIRED, do NOT move closer to fill it. NO zoom in, NO push-in, NO
> pan, NO drift, NO slow creep for drama. His head must be the SAME SIZE in pixels in
> the first, middle and last frame — if he gets bigger at ANY point, the clip is WRONG.

### DEFENSA v2 (clips de video) — `block`, `block_low` y `parry`

> Igual que los GOLPES v2: cada acción = UN clip, guardar como
> `imagen-action/dam/sheets/<accion>.mp4` y me avisas. **Pegar al final de CADA prompt
> el bloque "Reglas fijas del clip"** y adjuntar la referencia de DAM. IMPORTANTE en
> los tres: NADIE lo ataca en el clip (no hay rival), y CERO efectos — sin chispas,
> sin destellos, sin ondas de choque (los pone el motor al bloquear).

**`block.mp4` (bloqueo DE PIE — aguanta golpes cubierto):**

> From his fighting guard he snaps into a braced DEFENSIVE stance: the big sword raised
> VERTICAL in front of his body, blade edge facing forward, both hands gripping the
> handle, body turned slightly behind the flat of the blade like a shield, knees bent,
> weight low. Holding that guard, his body ROCKS under heavy invisible pressure two or
> three times during the clip — sharp little jolts BACKWARD: shoulders compressing, head
> ducking a touch, boots sliding back an inch on the ground, coat jumping with each jolt
> — but the sword NEVER drops and the guard NEVER breaks. Between jolts he re-plants and
> braces harder. At the end he lowers the sword back into his normal fighting guard.
> Nothing touches him and nothing appears in the clip: NO flashes, NO sparks, NO shock
> waves, NO opponent — only the man bracing and rocking. He stays ON ONE SPOT, SAME SIZE
> the whole clip.

**`block_low.mp4` (bloqueo AGACHADO — cubierto abajo):**

> He is CROUCHED LOW and stays crouched the ENTIRE clip — deep squat, body COMPACT and
> tucked, head DOWN at the same height as his normal crouch (never rising, never
> kneeling upright). He holds the big sword HORIZONTAL above his head like a ROOF — the
> flat of the blade facing up, both hands bracing it, the blade NEVER pointing at the
> sky. Under that roof his body COMPRESSES two or three times during the clip — sharp
> little downward jolts, like heavy pressure landing on the blade from above: elbows
> flexing, torso crunching tighter, coat puffing out with each jolt — but the roof
> guard NEVER collapses. At the end he eases back into his normal crouched guard, still
> low. Nothing touches him and nothing appears in the clip: NO flashes, NO sparks, NO
> opponent — only the crouched man bracing. He stays ON ONE SPOT, SAME SIZE the whole
> clip, knees bent in every frame.

**`parry.mp4` (postura de DESVÍO — ventana del counter Q+W):**

> ONE quick defensive SNAP and then a tense HOLD: from his fighting guard he whips the
> big sword up-and-across in one sharp motion into a DEFLECT position — the blade held
> DIAGONAL in front of his chest and face, edge facing forward-and-up, both hands on the
> handle, elbows tucked, body coiled sideways behind the blade, front foot braced, eyes
> locked forward over the guard. He then HOLDS that coiled deflect stance for the REST
> of the clip, perfectly ready: the only motion is tense breathing, tiny adjustments of
> his grip, and his coat and hair settling from the snap. He does NOT swing, does NOT
> attack, does NOT return to guard — the clip ENDS still holding the deflect stance.
> Nothing touches him and nothing appears: NO flashes, NO glow, NO sparks, NO opponent.
> He stays ON ONE SPOT, SAME SIZE the whole clip.

> _Guardar como `sheets/block.mp4`, `sheets/block_low.mp4` y `sheets/parry.mp4` → los
> proceso a `dam/block/`, `dam/block-low/` (drop-in sobre los frames estáticos de 1
> cuadro) y a la anim nueva `parry` (la postura del desvío Q+W; el contraataque de 3
> cortes sigue siendo la anim `counter` existente)._

### REACCIONES v2 (clip de video) — `hit_fly` + `hit_down` (UN solo clip)

> Guardar como `imagen-action/dam/sheets/hit-fly.mp4` y me avisas. **Pegar al final el
> bloque "Reglas fijas del clip"** y adjuntar la referencia de DAM. De este ÚNICO clip
> saco DOS animaciones: los frames del vuelo alimentan `hit_fly` (el arco por los aires
> lo mueve el motor) y los del choque contra el piso alimentan `hit_down`.

**`hit-fly.mp4` (lanzado por los aires → se estrella contra el suelo):**

> An invisible force BLASTS him off his feet: from his fighting guard his whole body is
> LAUNCHED backward and upward into the air toward the LEFT edge of the screen — a total
> knockout ragdoll: head thrown back, back arched, arms flailing loose, legs trailing,
> long coat and hair whipping forward past him from the force. He is UNCONSCIOUS in the
> air: slack face, eyes shut, ZERO control, a rag doll — no bracing, no attack pose, no
> landing on his feet. He flies in a high arc and CRASHES flat onto his BACK on the
> ground, bounces once with the impact, slides a little, and ends LYING sprawled on his
> back, motionless, limbs loose — except ONE thing: his sword hand. A lifelong
> warrior's reflex keeps that fist DEATH-GRIPPED around the handle even unconscious:
> the sword arm hugs the big sword IN AGAINST his body, pinned across his chest and
> side, and it rides the whole flight and the whole crash PINNED there, slamming into
> the ground together WITH him, never separating from his fist. Nothing else appears
> in the clip: NO opponent, NO impact flashes, NO speed lines — and ABSOLUTELY NO
> SMOKE: no dust clouds, no dirt kicked up, no debris, no haze — the crash raises
> NOTHING from the ground, the floor stays perfectly clean (the game engine draws all
> dust later). If any smoke or dust appears in ANY frame, the clip is WRONG.
>
> SCREEN DIRECTION LOCKED: at the start he stands in SIDE VIEW facing the RIGHT edge of
> the screen; the invisible force comes FROM the right, so he travels toward the LEFT.
> His ragdoll body may tumble and rotate naturally during the flight, but the SCENE
> must NEVER mirror or flip horizontally — the first frame's left-right orientation is
> the orientation of the WHOLE clip. If at any point he appears standing in guard
> facing the LEFT edge, the clip is WRONG.
>
> THE SWORD — THE MOST IMPORTANT RULE OF THIS CLIP. The sword NEVER leaves his fist:
> not at the launch, not during the flight, not at the crash, not in the bounce, not
> in the final sprawl. Frame by frame his fingers stay CLOSED around the handle, the
> blade PINNED against his body by his own arm — it does NOT wave around loose, it
> does NOT fly off, it does NOT land on the ground away from him. In the final lying
> pose the sword rests ON him / in his closed fist. If the sword is separated from
> his hand in ANY frame, the clip is WRONG — regenerate. It is ONE single greatsword,
> EXACTLY the design in the reference image: same LENGTH, same SHAPE, same THICKNESS
> in every frame — never transforms, never bends, never splits into two, never
> shrinks or grows, never disappears. His other hand is EMPTY the whole clip.
>
> CAMERA HARD-LOCKED — STATIC WIDE footage, like a fixed security camera: the framing
> of the FIRST frame is the framing of EVERY frame. NO zoom in, NO push-in, NO pan, NO
> drift, NO following him through the air — his whole body stays fully INSIDE the fixed
> frame during the entire flight, crash and slide, with clear green margin all around;
> that empty space is REQUIRED, do NOT move closer to fill it. His head must be the
> SAME SIZE in pixels in the first, middle and last frame — if he gets bigger at ANY
> point, the clip is WRONG.

> _Del vuelo saco `hit_fly` (pose de muñeco por los aires) y del estrellón `hit_down`
> (choca de espaldas, rebota y queda tendido). El levantarse ya lo cubre `get_up`._

### VICTORIA v2 (clip de video) — `victory.mp4` (pose de triunfo ÉPICA)

> Guardar como `imagen-action/dam/sheets/victory.mp4` y me avisas. **Pegar al final el
> bloque "Reglas fijas del clip"** y adjuntar la referencia de DAM. El juego la
> reproduce al ganar la ronda y RETIENE la pose final — el último tramo debe ser él
> sosteniendo la pose. El motor pone el HAAAA y los efectos: el clip va LIMPIO.

**`victory.mp4` (la victoria del lobo — remate de ronda):**

> READ THIS FIRST — THE #1 RULE: this is a STATIC, LOCKED-OFF shot. The character is
> the SAME SIZE in pixels in EVERY single frame — first frame, MIDDLE frames, and last
> frame all identical in scale. There is absolutely NO zoom, the camera NEVER moves,
> and the character NEVER grows or shrinks at any point — especially not in the MIDDLE
> of the clip, where it keeps breaking. Treat it like a sprite-sheet pose: a fixed
> character on a fixed background, only limbs and cloth animating. If his scale changes
> even slightly between the start, the middle, and the end, the clip is WRONG and must
> be redone.
>
> The battle is WON. From his fighting guard he whips the big sword in ONE heavy
> circular FLOURISH over his head — a slow, arrogant, powerful arc, coat fanning out
> with the spin — and SLAMS the blade POINT-DOWN into the ground in front of him, the
> impact shuddering through his arms. He plants BOTH hands stacked on the pommel,
> straightens up TALL and proud behind the standing sword, chest out — then throws his
> head BACK and lets out a silent victory ROAR to the sky, mouth open wide, veins of
> effort in his neck, his long coat and wild hair BILLOWING hard from his own power.
> He holds that final pose — head high, hands on the pommel, the sword standing like a
> monument — breathing heavy, coat settling, for the REST of the clip. ONE continuous
> action: flourish → slam → straighten → roar → hold. He stays ON ONE SPOT.
>
> THE SWORD — ONE single greatsword, EXACTLY the design in the reference image: same
> LENGTH, same SHAPE, same THICKNESS in every frame. It never transforms, never bends,
> never splits into two, never shrinks or grows, never disappears. Once slammed into
> the ground it stays PLANTED, rigid, never wobbling like rubber. His hands stay ON
> the pommel from the slam to the last frame.
>
> NOTHING appears in the clip: NO fire, NO flames, NO glow, NO energy, NO light rays,
> NO sparks, NO dust from the slam, NO smoke, NO opponent — only the man and his
> sword. The ground stays perfectly clean (the game engine draws all effects later).
> If any effect appears in ANY frame, the clip is WRONG.
>
> SCREEN DIRECTION LOCKED: SIDE VIEW facing the RIGHT edge of the screen the whole
> clip — the roar tilts his head UP, not toward the camera. The scene must NEVER
> mirror or flip horizontally.
>
> CAMERA HARD-LOCKED — STATIC WIDE footage, like a fixed security camera: the framing
> of the FIRST frame is the framing of EVERY frame. NO zoom in, NO push-in, NO pan,
> NO drift, NO dramatic creep during the roar — his whole body head-to-boots visible
> always, with clear green margin above his head and below his feet; that empty space
> is REQUIRED, do NOT move closer to fill it. His head must be the SAME SIZE in
> pixels in the first, middle and last frame — if he gets bigger at ANY point, the
> clip is WRONG.
>
> BODY LOCKED IN PLACE (CRITICAL — this is what keeps breaking): his BOOTS stay
> PLANTED on the exact same two spots on the ground for the ENTIRE clip — he does NOT
> step, shuffle, slide, drift sideways, or shift his stance. His HEAD stays at the
> SAME height above the ground the whole clip — he does NOT crouch down low then rise
> up tall; keep him STANDING at a constant, upright height from the very first frame.
> He does NOT lean his whole body far back then far forward. The only things that move
> are his ARMS (the flourish and the sword), his coat, and his hair — his torso and
> head hold a steady, upright position over his planted feet. Picture a statue that
> only moves its arms: the silhouette's top (head) and bottom (feet) never travel. If
> his head bobs up/down, or his body slides left/right, or he shrinks and grows, the
> clip is WRONG.

> _Se procesa a `dam/victory/` (drop-in sobre la victoria vieja; el juego ya retiene
> el último cuadro). El HAAAA y las llamas del triunfo los añade el motor. Si el clip
> mantiene la CABEZA y los PIES quietos, se puede usar ENTERO (floreo incluido); si el
> cuerpo se agacha/estira/mueve, solo se aprovecha la pose final sostenida._
