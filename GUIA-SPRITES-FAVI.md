# FAVI — The Twin Fang · Guía de sprites (personaje)

> ⚠️ **WORKFLOW NUEVO (2026-08): CLIPS DE VIDEO, ya NO hojas de frames.**
> Cada acción se genera como UN CLIP DE VIDEO con la herramienta de animación:
> fondo verde puro #00FF00 plano, UNA toma continua, personaje de PERFIL mirando a la
> DERECHA (si sale a la izquierda no importa: lo volteo yo), cámara TRÍPODE fija (sin
> zoom/pan — OJO: la herramienta suele hacer ZOOM-IN en los saltos; igual lo corrijo
> midiendo por frame), mismo tamaño todo el clip, cuerpo completo con margen. Guardar
> como `imagen-action/favi/sheets/<accion>.mp4` y avisarme: yo recorto el croma, ELIJO
> los frames, calibro el TAMAÑO ESTÁNDAR de Fe y lo conecto. Los "conteos de frames" y
> reglas de HOJAS de más abajo son HISTÓRICOS: valen como descripción del movimiento
> (fases, poses, agujas), pero el formato de entrega es SIEMPRE el clip. Ver la sección
> "NIVELACIÓN con AYE" al final para prompts de video ya afinados.

> Esta es la guía ESPECÍFICA de FAVI: su identidad y la animación detallada de
> cada movimiento con sus DOS AGUJAS. Las reglas de producción, el roster de
> movimientos y los efectos compartidos están en **`GUIA-COMUN.md`** (sirven
> para todos los personajes). Está calcada de **`GUIA-SPRITES.md`** (la de DAM):
> mismo moveset, mismos conteos de frames y mismos timings — lo ÚNICO que cambia
> es que FAVI empuña DOS AGUJAS (no una katana) y su energía es AZUL (no fuego).

> **Diferencia clave que manda en TODAS las animaciones:** FAVI pelea con
> **DOS agujas, una en cada mano** (dual-wield). Es ligera y precisa: en vez de
> los cortes pesados y amplios de la katana de DAM, ella hace estocadas rápidas,
> piquetes de una sola aguja y cruces en TIJERA con las dos. Cuando un golpe de
> DAM era "una katana barriendo", en FAVI son "las dos agujas cruzándose".

> **DECISIONES ABIERTAS (dime si las cambio):**
>
> 1. **Título/epíteto:** propongo **"The Twin Fang" (Doble Colmillo)** — enlaza
>    el tigre de su abrigo con sus dos agujas. Alternativa: _"The Blue Needle /
>    La Aguja Azul"_.
> 2. **Su especial (equivalente al fuego de DAM):** propongo la **"Tormenta de
>    Agujas"** — lanza una ráfaga de agujas de energía AZUL que viaja hacia el
>    rival. Alternativa: una _onda/filo azul_ en media luna.

## Reglas generales (van en TODOS los prompts de clip)

Cada prompt de clip lleva SIEMPRE: la **imagen de referencia de FAVI** adjunta
+ el bloque **IDENTITY** al inicio + los párrafos **STATIC POSITION** y
**WEAPONS LOCKED** al final, pegados tal cual (en inglés — la herramienta
obedece mejor).

**IDENTITY (pegar al inicio de cada prompt):**

> Same girl as the reference image: long straight dark-brown hair, big brown
> eyes, light tan skin. She wears a ROYAL BLUE hooded long open coat (big white
> TIGER-head logo on the back), a blue t-shirt with a white tiger print, a
> LILAC/lavender pleated skirt, white socks, blue-and-white high-top sneakers,
> black fingerless gloves and a small soccer-ball keychain hanging from the
> coat. STRICT SIDE VIEW facing RIGHT the whole clip (never frontal, never from
> behind), flat pure green #00FF00 background, nothing else in frame — no
> effects, no particles, no floor shadow, no motion blur, no text or marks. One
> single continuous take, fixed TRIPOD camera (no zoom, no pan), she stays the
> SAME SIZE the whole clip, full body always inside the frame with margin.

**STATIC POSITION (pegar en cada prompt — el desplazamiento lo pone el juego):**

> STATIC POSITION: she stays in the CENTER of the frame for the ENTIRE clip —
> the whole action happens ON ONE SPOT. She does NOT walk, slide or drift
> forward/backward; if the move includes a jump, the jump goes STRAIGHT UP and
> she lands on the EXACT SAME SPOT. Camera completely fixed, no panning, no
> zooming.

**WEAPONS LOCKED (pegar en cada prompt):**

> WEAPONS LOCKED: she holds TWO identical SHORT THIN STRAIGHT needles (slim stilettos),
> ONE in each hand, exact same size and shape in EVERY frame. Each needle is ONE PLAIN
> SMOOTH THIN METAL ROD with the same thin thickness from end to end, like a long sewing
> needle — NO handle, NO grip, NO crossguard, NO hilt, NO pommel. NOT swords, NOT long
> blades, NOT curved knives, NOT kunai with rings, NOT daggers, NOT a dagger with a
> handle and guard, no extra weapons, they never disappear, never change hands, never
> change length, never grow a handle.

Guarda cada clip como `imagen-action/favi/sheets/<accion>.mp4` y avísame: yo
recorto el croma, elijo la sección (usando TODOS sus frames — el ritmo lo pongo
con los FPS), calibro el TAMAÑO ESTÁNDAR de Fe y lo conecto al juego. Si sale
mirando a la IZQUIERDA no pasa nada: lo volteo yo al procesar.

**Clips rebeldes:** si la herramienta muta algo una y otra vez (katana, tres
agujas, se va del centro, gira la cámara), NO alargues el prompt: pide un clip
más CORTO de SOLO esa fase del movimiento, con la prohibición explícita en
MAYÚSCULAS. Los SHORT PROMPTS (ver `jump_kick` y `air_jab` al final) están
funcionando mejor que los prompts largos.

---

## El kit de movimientos (descripción de cada acción)

> ⚠️ Estas entradas describen el MOVIMIENTO de cada acción (fases, poses, qué
> hacen las agujas) y siguen siendo la referencia de diseño. Pero IGNORA todo
> lo de "N frames / filas / hoja .png" que quede en el texto: para regenerar
> una acción, convierte su descripción en un SHORT PROMPT de clip (inglés) +
> IDENTITY + STATIC POSITION + WEAPONS LOCKED, y guárdala como `<accion>.mp4`.

### Básicas (empezar por estas 4)

1. **`pose-sheet.png`** — 4 frames (2 filas de 2). **Guardia BAJA de asesina
   (bladed, ágil)**: cuerpo DE COSTADO / tres cuartos hacia la derecha (hombro
   adelantado), **rodillas FLEXIONADAS y peso bajo y centrado**, lista para
   lanzarse (postura felina). La aguja de la mano **ADELANTADA** se sostiene
   **BAJA y en DIAGONAL** (NO rígida apuntando al frente); la aguja de la mano de
   **ATRÁS** en **AGARRE INVERTIDO** (reverse-grip, punta hacia abajo/atrás) junto
   a la cadera. Mirada afilada al frente. Pelo y gabardina con leve movimiento.
   Respiración sutil: el torso sube y baja APENAS, las agujas oscilan un poquito,
   el brillo azul de las puntas varía apenas. Los pies NO se mueven. El loop debe
   cerrar (frame 4 conecta con frame 1). **CUERPO COMPLETO dentro del cuadro: los
   pies/tenis ENTEROS, con margen debajo — NUNCA recortados por el borde.**

2. **`walk-sheet.png`** — 8 frames en 2 filas de 4. Ciclo de caminata de
   COMBATE: el torso casi quieto en guardia, las DOS agujas siempre listas (una
   apuntando adelante-abajo, la otra recogida junto a la cadera), los brazos SIN
   balanceo de paseo. Las piernas hacen el ciclo clásico de animación:
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

3. **`punch-sheet.png`** — 10 frames en DOS FILAS de 5 (fila de arriba:
   f1-f5, fila de abajo: f6-f10). TIJERA DOBLE HORIZONTAL: las dos agujas
   barren de lado a lado a la altura del pecho y se CRUZAN en el impacto (como
   tijeras). Las hojas se mantienen más o menos PARALELAS AL PISO durante todo
   el barrido — NUNCA suben por encima de la cabeza, NO es un corte de arriba
   hacia abajo:
   **Aplica la CAPA DE KEYFRAME de `GUIA-COMUN.md` (carga comprimida → SMEAR
   de contacto → overshoot). SOLO el f7 lleva smear; el resto va nítido.**
   - f1: la POSE DE GUARDIA exacta (la misma de pose-sheet): agujas listas
     frente al cuerpo. NO una postura relajada de pie con los brazos colgando
   - f2: TRANSICIÓN visible: el torso empieza a girar (y a ENCOGERSE) y las dos
     agujas se recogen CRUZADAS sobre el pecho en X (cargando la tijera), a
     medio camino
   - f3: carga: las agujas totalmente cruzadas y recogidas contra el pecho, los
     codos atrás, horizontal
   - f4: CARGA COMPRIMIDA (extremo): torso girado y ENCOGIDO, brazos comprimidos
     y las dos agujas cruzadas en X apretadas contra el pecho, codos atrás,
     peso atrás — el cuerpo como RESORTE cargado. Silueta compacta, distinta
     de la guardia
   - f5: el barrido arranca: los brazos empiezan a abrirse, las agujas entran
     al frente todavía cerca del cuerpo, hojas horizontales
   - f6: a medio camino: las dos hojas cruzan por DELANTE del pecho abriéndose
     hacia afuera, horizontales, el torso desenroscándose y ganando velocidad
   - f7: IMPACTO (el frame clave): las dos agujas COMPLETAMENTE extendidas al
     frente cruzándose en TIJERA a la altura del pecho, con las hojas apenas
     ALARGADAS/estiradas en la dirección del barrido (motion-blur SUTIL de
     bordes definidos — NO arcos gigantes: el listón grande lo pone el motor
     `_draw_swing_trail`). Siguen saliendo de las manos y pegadas al cuerpo.
     Cuerpo ESTIRADO y volcado adelante, brazos al máximo. SIGUEN SIENDO DOS
     agujas, nunca una sola
   - f8: OVERSHOOT (extremo): las dos agujas (ya nítidas otra vez) pasaron de
     largo abiertas hacia afuera del OTRO lado; el torso SOBRE-GIRADO y
     DESBALANCEADO hacia adelante, el pie trasero despegando por la inercia —
     NO vuelve limpio, se pasó del golpe
   - f9: asienta: desde el overshoot el cuerpo frena y las agujas regresan
     hacia el cuerpo, recuperando el equilibrio
   - f10: regresa a la POSE DE GUARDIA exacta del f1 (el golpe abre y cierra en
     guardia). NO termina de pie relajado
     Las dos agujas en POSICIÓN CLARAMENTE DISTINTA en cada frame, avanzando de
     forma PAREJA por el arco (EXCEPTO el f7, que es el smear de contacto);
     entre frame y frame las hojas se mueven más o menos la misma distancia.

4. **`kick-sheet.png`** — 10 frames en DOS FILAS de 5 (fila de arriba:
   f1-f5, fila de abajo: f6-f10). CLAVADO DOBLE DESCENDENTE: un remate pesado
   de arriba a abajo con las dos agujas juntas/en X — cada frame una posición
   distinta:
   - f1: la POSE DE GUARDIA exacta; las rodillas empiezan a flexionarse
   - f2: las dos agujas alzándose en diagonal sobre el hombro
   - f3: las dos agujas COMPLETAMENTE arriba, cruzadas en X sobre la cabeza,
     cuerpo estirado
   - f4: máxima tensión: cuerpo arqueado atrás, las hojas apenas empiezan
     a inclinarse hacia adelante
   - f5: el clavado arranca, las dos agujas en diagonal delantera alta (45°)
   - f6: IMPACTO — las dos agujas al frente a la altura del pecho, hojas juntas
     apuntando adelante, cuerpo inclinado adelante
   - f7: las hojas siguen bajando, en diagonal baja delantera
   - f8: las hojas casi tocando el piso, con zancada profunda
   - f9: sostiene la pose baja un instante (peso del golpe)
   - f10: recupera la POSE DE GUARDIA exacta del f1
     Las dos agujas deben verse en una posición DISTINTA del arco en cada frame,
     avanzando de forma PAREJA (sin saltos bruscos). MUCHO CUIDADO en los frames
     finales (f8-f10): las agujas siguen EN LAS MANOS en todo momento — nunca en
     el piso, nunca bajo el pie, y cada frame es un solo personaje (no dos poses
     pegadas). Siguen siendo DOS agujas, nunca se fusionan en una espada.

### Agachado

5. **`crouch-sheet.png`** — 3 frames. Se agacha progresivamente hasta quedar
   en cuclillas con las dos agujas listas: de pie → semiagachado → agachado firme.

6. **`crouch-punch-sheet.png`** — 3 frames. Pinchazo DOBLE rápido de las dos
   agujas desde la posición agachada, al frente y a media altura: carga → doble
   estocada → recogida.

7. **`crouch-kick-sheet.png`** — 5 frames. GANCHO ASCENDENTE DOBLE (anti-aéreo,
   estilo uppercut): un corte que arranca cargado abajo y termina con las dos
   agujas arriba tras la espalda. Los pies SIEMPRE tocan el piso (NO es un salto):
   - f1: CARGA — en cuclillas profundas, el torso volcado sobre la rodilla
     delantera, las dos agujas agarradas AL FRENTE del cuerpo con las hojas
     apuntando hacia el PISO (cargando el golpe)
   - f2: el swing arranca POR ABAJO: aún agachada, las dos agujas barren hacia
     abajo y atrás pasando RASANTE junto a sus piernas, las hojas cerca del piso
   - f3: IMPACTO — el corte SUBE: los DOS brazos ESTIRADOS hacia
     adelante-arriba con las dos agujas EN PLENO BARRIDO frente al cuerpo
     (hojas en diagonal ascendente, las puntas a la altura de la cabeza),
     el torso inclinado HACIA ADELANTE levantándose en zancada — se debe ver
     que las agujas van EN MOVIMIENTO hacia arriba, NO es una pose de guardia
     sostenida. Vista LATERAL, perfil hacia la derecha
   - f4: REMATE — el cuerpo ya levantado en zancada (ambos pies firmes en
     el piso), las dos agujas terminaron el arco: quedaron ARRIBA y por DETRÁS
     del hombro, los brazos cruzados por encima de la cabeza en el
     follow-through. SIEMPRE de PERFIL mirando a la derecha (se le ve la
     cara de lado) — NUNCA de espaldas a la cámara
   - f5: recogida: baja las agujas y vuelve a las cuclillas del f1
     El arco completo de las hojas: frente-abajo → rasante atrás → subiendo
     al frente → arriba tras el hombro. Posición CLARAMENTE distinta de las
     hojas en cada frame.

   **Los f3 y f4 salen mal en secuencia (la IA los pone de espaldas o con
   las agujas quietas). Pedirlos JUNTOS en UNA sola hoja de 2 frames
   (NO uno por uno):**

### Salto

8. **`jump-sheet.png`** — 4 frames. Salto vertical: impulso (rodillas
   flexionadas) → subiendo (cuerpo estirado) → punto más alto → cayendo. Las dos
   agujas recogidas junto al cuerpo.

9. **`jump_punch`** — 4 frames. Corte aéreo doble: en el aire, doble
   estocada de agujas al frente: preparación → corte → extendido → recogida
   (sigue en el aire).

10. **`jump-kick-sheet.png`** — 3 frames. Ataque aéreo descendente: en el
    aire, doble aguja/patada en diagonal hacia abajo: preparación → extensión → sostenido.

### Recibir daño

11. **`take-hit-sheet.png`** — 4 frames. Golpeada de pie: impacto en el
    rostro/pecho, cabeza hacia atrás, retrocede encorvada, casi recupera guardia.
    Las dos agujas flojas en las manos.

12. **`take-hit-low-sheet.png`** — 3 frames. Animación de RETROCESO en cuclillas
    para un juego de pelea 2D estilo anime (SOLO lenguaje corporal, una reacción
    de sobresalto): sin levantarse, el torso se contrae hacia atrás y los hombros
    se encogen un instante, la cabeza se ladea hacia atrás; en el último frame casi
    vuelve a su guardia agachada firme. Las dos agujas quedan flojas en las manos.
    Contenido apto: NADA de sangre, heridas, moretones ni violencia gráfica — es
    puro gesto de reacción de videojuego.
    (Nota: evitá las palabras "golpeada/impacto/golpe" en el prompt; el filtro de
    la IA las marca. Describí solo el movimiento del cuerpo.)

12b. **`pummeled-sheet.png`** — EXACTAMENTE **6 frames** en **2 filas de 3** (fila
arriba = f1 f2 f3 izq→der; fila abajo = f4 f5 f6 izq→der). Fondo VERDE puro
#00FF00. Favi SIEMPRE de **perfil mirando a la DERECHA**. **NO dibujes:** pared,
piso, líneas de velocidad, polvo, chispas ni ningún efecto — SOLO la niña sobre
el verde. Los 6 frames al **MISMO tamaño de personaje** que las demás hojas.
Contenido apto: NADA de sangre, heridas ni violencia gráfica — es puro lenguaje
corporal de videojuego.
(Nota: evitá las palabras "golpe/golpeada/impacto"; el filtro de la IA las marca.
Describí SOLO el movimiento del cuerpo.)

    ESTADO: Favi **tambalea DE PIE** sin control, sacudida hacia atrás una y otra vez
    por una ráfaga que llega de frente (desde su derecha). **NUNCA cae ni apoya la
    rodilla en el piso** — se mantiene parada, encogida y a la defensiva. Cabeza y
    torso van y vienen; las dos agujas flojas colgando de las manos (sujetas por la
    anilla, dedos en el aro). NADA de pose de fuerza ni de ataque.

    Es un CICLO CONTINUO que **se repite en bucle**: el frame 6 debe empalmar
    SUAVEMENTE con el frame 1 (sin salto brusco). Es un temblor/vaivén EN EL SITIO
    (los pies casi fijos). Piensa el eje del cuerpo (cabeza→pies):
    - **f1 — RETROCEDE:** el torso se va hacia atrás, la cabeza se ladea atrás, los
      hombros empiezan a subir, los pies clavados en el sitio.
    - **f2 — MÁS ATRÁS:** el cuerpo se encoge y recula más, rodillas cediendo un poco,
      la barbilla arriba-atrás, brazos flojos arrastrando.
    - **f3 — PUNTO MÁS ENCOGIDA:** cuerpo compacto y hundido, cabeza metida entre los
      hombros, espalda curvada hacia atrás — el instante más comprimido.
    - **f4 — VUELVE ADELANTE:** rebota hacia adelante, la cabeza cae adelante-abajo,
      los hombros bajan, el cuerpo empieza a enderezarse.
    - **f5 — VAIVÉN:** el torso oscila un poco al frente absorbiendo, los hombros se
      tuercen, la cabeza floja balanceándose.
    - **f6 — REGRESA AL CENTRO:** el cuerpo casi vuelve a la postura de f1 (torso
      recuperando el eje, cabeza subiendo), listo para reiniciar el ciclo.
    → alimenta la animación `pummeled` (el tambaleo continuo mientras recibe la
    ráfaga del ULTRA). Va en BUCLE: por eso f6 debe empalmar con f1.

13. **Golpe fuerte que la manda a volar — se hace en DOS HOJAS** (mejor calidad:
    menos frames por hoja = personajes más grandes y limpios, sin invasión).

    **13a. `strong-fly-sheet.png`** — 4 frames, EN UNA SOLA FILA. El VUELO por el
    aire tras un golpe fuerte: cuerpo arqueado hacia atrás, pies DESPEGADOS del
    piso, pelo y abrigo al viento. Progresión de izquierda a derecha: (1) recién
    golpeada, el torso empieza a irse hacia atrás; (2) en pleno vuelo, casi
    horizontal; (3) punto más alto del arco; (4) empezando a caer. En los CUATRO
    frames está EN EL AIRE — nada toca el piso. Las dos agujas flojas, colgando de
    la anilla y arrastrando hacia atrás.
    → alimenta la animación `hit_fly`.

    **13b. `strong-fly-sheet-2.png`** — 5 frames, EN UNA SOLA FILA. El ATERRIZAJE
    duro y la recuperación, de izquierda a derecha: (1) toca el piso de espalda o
    de costado; (2) rodando por el suelo; (3) boca abajo, apoyándose con las manos;
    (4) empujándose hacia arriba; (5) arrodillada sobre UNA rodilla, casi de pie,
    lista para volver a guardia. Las dos agujas en las manos (sujetas por la
    anilla). Deja ESPACIO claro entre frame y frame (no que se pisen las poses).
    → alimenta la animación `hit_down`.

13c. **`wall-bounce-sheet.png`** — EXACTAMENTE **6 frames** en **2 filas de 3**
(fila arriba = f1 f2 f3 izq→der; fila abajo = f4 f5 f6 izq→der). Fondo VERDE
puro #00FF00. Favi SIEMPRE de **perfil mirando a la DERECHA**. **NO dibujes:**
pared, piso, líneas de velocidad, polvo, chispas ni ningún efecto — SOLO la
niña flotando sobre el verde (la pared y el golpe los pone el motor).

    ⚠️ **PROPORCIONES (LO MÁS IMPORTANTE — antes salió MAL):** mismas proporciones
    que sus otras hojas (caminar/vuelo). Cuerpo **ESBELTO y ÁGIL de asesina
    adolescente**, **piernas y brazos LARGOS**, torso estilizado, **cabeza
    PROPORCIONADA y más bien pequeña respecto al cuerpo**. **NO la dibujes con
    proporciones de nena chiquita / bebé / chibi** (cabeza grande, cuerpo corto y
    rechoncho, piernas cortas): la silueta debe verse **ALTA y ESTILIZADA**, igual
    de madura que en las demás hojas.

    **TAMAÑO:** el personaje debe **LLENAR la celda** (misma escala que la hoja de
    vuelo `hit_fly`), NO salir pequeña con mucho verde alrededor. La **MISMA
    estatura y proporciones en los 6 frames** — solo cambia la pose, nunca el
    tamaño ni la contextura.

    ESTADO: Favi está **NOQUEADA en el aire**, cuerpo de **muñeca de trapo** sin
    control, ojos cerrados/apretados, cara floja, pelo y gabardina al viento. NADA
    de pose de fuerza ni de ataque en ningún frame.

    AGUJAS (regla fija en los 6 frames): las **dos agujas SIEMPRE en las manos**
    (sujetas por la anilla, dedos cerrados en el aro), **flojas y colgando/arrastrando**
    hacia atrás por la inercia. PROHIBIDO que floten sueltas separadas de las manos,
    que las agarre por la hoja, o cualquier pose de ataque.

    Es UN SOLO movimiento continuo: **vuela horizontal de espaldas → choca y se
    comprime contra la pared invisible → se despega cayendo de BRUCES (boca abajo).**
    Cada frame CONTINÚA el anterior. Piensa el eje del cuerpo (cabeza→pies):
    - **f1 — VUELO:** cuerpo casi HORIZONTAL en el aire, la ESPALDA por delante
      (va de espaldas hacia la pared), cabeza colgando hacia atrás, brazos y
      piernas arrastrando, gabardina ondeando fuerte hacia atrás.
    - **f2 — POR CHOCAR:** casi vertical, la espalda/hombros llegando a la pared
      invisible, el cuerpo empezando a comprimirse, rodillas subiendo por el impacto.
    - **f3 — IMPACTO (aplastada):** cuerpo COMPRIMIDO contra la pared (vertical,
      apretado), cabeza hundida entre los hombros, todo el cuerpo en su punto más
      compacto — el momento del golpe (**pero SIN volverse cabezona**: la cabeza
      se hunde entre los hombros, no crece).
    - **f4 — REBOTE:** se despega de la pared, todavía casi vertical pero la cabeza
      cae hacia ADELANTE-abajo, el cuerpo empieza a volcarse boca abajo.
    - **f5 — VOLCANDO:** cuerpo en diagonal cayendo de bruces, cabeza y torso
      abajo-adelante, piernas subiendo atrás, brazos colgando (muñeca de trapo).
    - **f6 — CAE DE BRUCES:** casi HORIZONTAL otra vez pero **boca abajo**, todo el
      cuerpo a punto de tocar el piso de frente, agujas colgando de las manos.
    → alimenta la animación `wall_splat` (el estrellón contra la pared). Tras esto
    el motor encadena `hit_down` (13b) para que se levante.

### Counter / Parry (mecánica defensiva NUEVA — gasta 1 barra)

18. **`counter-sheet.png`** — EXACTAMENTE **6 frames** en **2 filas de 3** (arriba
    f1 f2 f3, abajo f4 f5 f6, izq→der), con separación entre filas y frames. Es el
    CONTRAATAQUE: Favi **desvía** el golpe del rival con sus agujas y responde con
    una **ráfaga rápida de 3 estocadas**. Perfil a la DERECHA, cuerpo completo (pies
    enteros), MISMO tamaño en los 6 frames, proporciones esbeltas. Puntas de las
    agujas con brillo AZUL tenue.
    - **f1 — DESVÍO (parry):** postura firme desviando un golpe entrante, las dos
      agujas CRUZADAS/levantadas al frente (guardia de tijera), cuerpo braced hacia
      el rival, peso adelantado.
    - **f2 — 1ª estocada:** pincha rápido al frente con UNA aguja (brazo extendido).
    - **f3 — 2ª estocada:** pincha con la OTRA aguja (cruce), la primera se recoge.
    - **f4 — 3ª estocada (la fuerte):** las DOS agujas clavando al frente juntas,
      cuerpo lanzado adelante — el golpe más potente.
    - **f5 — follow-through:** la extensión tras el 3er golpe, agujas al frente,
      brillo azul en las puntas.
    - **f6 — recuperación:** vuelve a la guardia baja.
      → alimenta la animación `counter` (el parry-contraataque).

### Defensa

14. **`block-sheet.png`** — 2 frame. Bloqueo de pie: cubierta con las dos
    agujas CRUZADAS en X frente al cuerpo (guardia de tijera), postura firme.

15. **`block-low-sheet.png`** — 2 frame. Bloqueo agachado: en CUCLILLAS
    PROFUNDAS, cuerpo COMPACTO y encogido (cabeza baja, a la misma altura
    que la postura agachada normal — NO erguida, NO de rodillas con el
    torso vertical), cubriéndose con las dos agujas CRUZADAS en HORIZONTAL por
    encima de la cabeza, como un techo. Las hojas NO apuntan al cielo.

### Final de ronda

16. **`ko-sheet.png`** — 5 frames. Derrota: tambalea → cae de rodillas →
    se desploma → tendida en el piso boca arriba → inmóvil (las dos agujas
    apagadas a su lado). El último frame se queda en pantalla.

17. **Victoria — se hace en DOS HOJAS de 4 frames** (8 en total, mejor calidad).
    Favi gana, cruza las dos agujas en X frente al PECHO (guardia de tijera
    triunfal) y DICE algo (tipo "nice try") — así que **la BOCA cambia de forma
    en cada frame**. NO guarda las agujas, NO las levanta por encima de la cabeza:
    se quedan CRUZADAS a la altura del pecho todo el tiempo.

    > ⚠️ CLAVE: la BOCA se mueve como si HABLARA. En cada frame la boca tiene una
    > forma DISTINTA (bien abierta, entreabierta, cerrada). NO dejes la boca igual
    > entre frames — es lo que la hace parecer que dice "nice try".

    **17a. `victory-sheet.png`** — 4 frames, EN UNA SOLA FILA:
    - f1: baja la guardia tras ganar, las dos agujas sueltas a los costados,
      cuerpo relajándose, media sonrisa, boca CERRADA
    - f2: sube las dos agujas y empieza a CRUZARLAS frente al pecho, mirada
      segura, boca CERRADA
    - f3: las dos agujas CRUZADAS en X a la altura del PECHO, cabeza en alto,
      sonrisa confiada, la boca EMPIEZA A ABRIRSE (arranca a hablar); puntas con
      brillo azul
    - f4: mantiene la X al pecho, la BOCA BIEN ABIERTA (primera sílaba, tipo
      "nii-"), cabeza en alto

    **17b. `victory-sheet-2.png`** — 4 frames, EN UNA SOLA FILA:
    - f5: sigue la X cruzada al pecho, boca ABIERTA en otra forma (segunda
      palabra, tipo "-try"), mirada pícara
    - f6: X al pecho, boca ENTREABIERTA terminando de hablar, media sonrisa
    - f7: X al pecho, boca CERRADA con sonrisa confiada plena, cabeza ligeramente
      ladeada, segura
    - f8: pose final: mantiene las dos agujas CRUZADAS al pecho, postura relajada
      y segura, sonrisa tranquila, el dije de balón colgando, boca CERRADA. Este
      frame se queda en pantalla.

---

## Golpes especiales

18. **`spin-kick-sheet.png`** — 8 frames en DOS FILAS de 4. **PEONZA DE AGUJAS**
    (giro-taladro, NO una patada): FAVI junta los PIES y gira como un trompo/peonza
    sobre las puntas, con los **DOS BRAZOS ABIERTOS de par en par** y una aguja
    extendida en cada mano, de modo que las agujas barren un círculo completo a su
    alrededor mientras se desliza hacia adelante. Piensa en una bailarina/patinadora
    girando con los brazos en cruz, pero con una aguja en cada mano. EXCEPCIÓN ÚNICA
    a la regla de perfil: como el personaje ROTA 360°, los frames intermedios sí la
    muestran de FRENTE y de ESPALDAS según el punto del giro. Los PIES van JUNTOS y
    pegados todo el giro (nunca una pierna extendida, NO es patada). Aunque en el
    juego avanza, dibuja TODOS los frames EN EL MISMO SITIO (cadera sobre la misma
    vertical) — el desplazamiento lo hace el motor:
    - f1: perfil (derecha), pies juntándose, se agacha apenas cargando el giro, los
      brazos EMPEZANDO a abrirse, las dos agujas separándose del cuerpo hacia afuera
    - f2: arranca el giro, 3/4 hacia la cámara, pies YA JUNTOS sobre las puntas,
      brazos abriéndose en cruz, las dos agujas apuntando hacia afuera
    - f3: DE FRENTE a la cámara, pies juntos, BRAZOS TOTALMENTE ABIERTOS en cruz
      horizontal, una aguja extendida a cada lado (silueta en T), pelo y gabardina
      abriéndose por la fuerza del giro
    - f4: 3/4 de espaldas, sigue girando, brazos abiertos, las agujas barriendo hacia
      el lado contrario, la gabardina volando en abanico
    - f5: DE ESPALDAS a la cámara, pies juntos, brazos aún abiertos, las agujas
      barriendo el fondo del círculo
    - f6: 3/4 volviendo al frente, brazos abiertos, las agujas siguen barriendo
    - f7: casi de perfil otra vez, pies juntos, el giro desacelera, los brazos
      empiezan a cerrarse recogiendo las agujas
    - f8: perfil (derecha), pies juntos aterrizando, agujas recogidas a la guardia
      Los pies van SIEMPRE juntos y las dos agujas SIEMPRE en las manos (una por mano),
      con los brazos abiertos hacia afuera durante todo el giro — nunca una pierna
      extendida, nunca las agujas sueltas ni desaparecidas. Energía/brillo AZUL sutil
      en las puntas al girar; nada de fuego.

19. **`weak-punch-sheet.png`** — 4 frames en UNA fila. PIQUETE RÁPIDO DE UNA
    AGUJA: el golpe más ligero y veloz del personaje — un piquete corto con
    UNA sola aguja (la de la mano delantera), sin girar el cuerpo. Aprovecha que
    es LIGERA y PRECISA:
    - f1: desde la guardia, el brazo delantero empieza a lanzar UNA aguja
      al frente (la otra mano con su aguja recogida, cerca del cuerpo)
    - f2: IMPACTO — brazo extendido al frente con UNA aguja, hoja
      horizontal apuntando adelante a la altura del pecho, hombro
      adelantado; el cuerpo casi no se mueve de la guardia
    - f3: el brazo regresa, la aguja a medio camino de vuelta
    - f4: pose de guardia otra vez
      Es un movimiento CORTO y SECO: poca extensión, nada de barridos
      amplios ni giros de torso — pura velocidad de brazo. La otra aguja
      SIEMPRE visible, recogida.

20. **`air-spin-kick-sheet.png`** — 8 frames en DOS FILAS de 4. SALTO
    MORTAL HACIA ADELANTE con remate de patada (para usar en el aire):
    FAVI gira de cabeza a pies EN EL PLANO DE LA PANTALLA (voltereta
    frontal, como una rueda que avanza) y termina lanzando una patada
    diagonal. TODOS los frames en vista de PERFIL (la voltereta rota el
    cuerpo, no la cámara — siempre se le ve el costado derecho). Dibuja
    todos los frames EN EL MISMO SITIO y a la MISMA escala — el vuelo lo
    pone el motor. Las dos agujas van EN LAS MANOS, pegadas al cuerpo, todo el giro:
    - f1: en el aire, encogiéndose: rodillas al pecho, el cuerpo empieza
      a rotar hacia adelante (cabeza inclinándose adelante)
    - f2: rotada ~90°: cuerpo HORIZONTAL en bola, cabeza apuntando hacia
      adelante, espalda arriba
    - f3: INVERTIDA (~180°): completamente boca abajo, en bola, la cabeza
      apuntando al piso
    - f4: rotada ~270°: la cabeza apunta hacia atrás-abajo, el cuerpo
      empieza a abrirse
    - f5: la voltereta termina: el cuerpo casi vertical otra vez, la
      pierna derecha empezando a lanzarse hacia adelante
    - f6: PATADA — pierna derecha COMPLETAMENTE extendida en diagonal
      hacia abajo-adelante, torso ligeramente inclinado atrás, el remate
      del mortal
    - f7: sostiene la patada con leve variación (el impulso del golpe)
    - f8: recoge la pierna, postura de caída en el aire (brazos
      equilibrando con las agujas)

21. **`water-cast-fe-sheet.png`** — 5 frames en UNA fila. **ESPECIAL DE AGUA de FE**
    (animación `water_cast`, exclusiva de Fe; NO es fuego). Comando en el juego:
    **↓↘→ + W** (medialuna adelante + W). Fe INVOCA un poder de agua: clava una
    aguja hacia el SUELO, levanta la otra mano y GRITA el nombre del poder → un
    GÉISER de agua brota del suelo justo bajo el rival y lo lanza hacia arriba.
    Se queda DE PIE en su sitio todo el tiempo (no avanza ni salta).

    > ⚠️ CLAVE: la BOCA se mueve como si GRITARA/llamara el poder — forma DISTINTA
    > en cada frame (cerrada, entreabierta, bien abierta). NO la dejes igual.
    - f1: postura de invocación: apunta una aguja hacia ABAJO al piso frente a
      ella, la otra mano empieza a subir; concentrada, boca CERRADA apretada
    - f2: la aguja firme apuntando al SUELO, la mano libre subiendo, aura AZUL/agua
      tenue naciendo alrededor de la aguja; la boca EMPIEZA A ABRIRSE (llama)
    - f3: la aguja clavando la energía hacia el suelo, la mano ALZADA bien arriba,
      BOCA MUY ABIERTA gritando, remolino de energía AZUL-agua concentrándose
    - f4: mantiene: mano arriba, aguja al piso, boca ABIERTA en otra forma (a media
      palabra), máximo brillo azul, gotas de agua girando a su alrededor
    - f5: descarga: baja la mano con fuerza hacia el suelo, mirada fiera, boca casi
      cerrada terminando el grito, la energía azul se hunde en el piso (dispara el
      géiser). Energía AZUL/agua siempre, NADA de fuego.

    **Efecto que acompaña (ya procesado):** `power-wather-favi-sheet.png` → géiser
    de agua de 8 frames (`imagen-action/impact-effect/water-geyser-fe/`), anclado al
    piso: gota → domo → columna → erupción → splash → se dispersa. Brota bajo el rival.
    **SFX:** al brotar el agua suena `Fe-sound-effect/water-splahs.mp3` (chapoteo).

22. **`fe-dash-sheet.png`** — 4 frames en UNA fila (con espacio entre ellos). **DASH DE
    AGUJAS de FE** (animación `dash`, exclusiva de Fe). ✅ **YA PROCESADO**
    (`imagen-action/favi/dash/`, override por ZAPATO 1.53 = zapato de walk ≈107; es un
    sprint BAJO, la cabeza queda más baja por la inclinación, es normal).
    Comando en el juego: **← → + Q** (atrás, luego adelante, + Q). Fe hace una
    **CORRIDA/EMBESTIDA rápida** hacia adelante envuelta en un **remolino de AGUA azul**,
    dejando **estela de sombras AZULES**. **NO levanta al rival ni lo empuja lejos**: si la
    embestida **CONECTA** (rival en el suelo), Fe **frena en seco** y suelta el **golpe que
    arranca el combo** → **3 pinchazos** (semi-combo automático), dejando al rival **en el
    mismo sitio** para **seguir combeando**. ACERCADOR/abre-combos, no finisher. AZUL/agua.

    **El sheet = la corrida (los 5 frames abajo).** El golpe de arranque del combo lo mete
    el juego reproduciendo `punch` justo al terminar la embestida (los 3 pinchazos = daño).
    - f1: casi de pie, empieza a impulsarse, remolino de agua naciendo en las agujas
    - f2: se inclina hacia adelante, remolino de agua azul creciendo alrededor del torso
    - f3: **plena corrida baja** — torso muy inclinado, pierna estirada, máximo remolino
    - f4: **estirada al frente** con la aguja adelante (buen enganche para el golpe del combo)

---

23. **`Whirlpool-move.png`** — 6 frames en DOS FILAS de 3. **WHIRLPOOL** (FINISHER de Fe,
    equivalente al INFERNO de DAM). ✅ **YA PROCESADO** (`imagen-action/favi/whirlpool/`,
    override por altura 1.54 + keepExtra para el vórtice de agua). Comando: **↓← + E**
    (abajo-atrás + E), se habilita tras un COMBO VIVO de 2-3 golpes. Fe gira en el LUGAR
    (peonza) mientras un VÓRTICE de agua azul CRECE a su alrededor y atrapa al rival,
    golpeándolo repetido SIN lanzarlo por los aires y quitándole ~40% de la vida. Grita
    "Whirlpool" al ejecutar. Los 6 frames muestran el remolino naciendo → creciendo (de
    frente, brazos abiertos, rings grandes) → decreciendo. Energía AZUL/agua, nada de fuego.

---

26. **`neutral-spin.png`** — 4 frames en UNA fila. **MORTAL AÉREO HACIA ADELANTE**
    (animación `neutral_spin`, exclusiva de Fe). ✅ **YA PROCESADO** (override 1.40, vCenter
    porque rota). Cuando el jugador SALTA hacia ADELANTE (↑ + hacia el rival) hace un
    FLIP/mortal que gira 360° en el aire (como los juegos de pelea). Si aprieta Q/W/E/R entra
    el ataque aéreo correspondiente. Los 4 frames son el giro: encogida → horizontal → de
    cabeza (pies arriba) → saliendo del giro. Vista de perfil, agujas recogidas.

---

## Efectos de combate propios de FAVI (sin personaje: SOLO el efecto sobre verde)

> Los efectos GENÉRICOS ya están hechos y se comparten con DAM — FAVI los
> reutiliza tal cual, NO hay que regenerarlos: relámpago de impacto
> (`fx-hit`), anillo de bloqueo (`fx-block`), polvo de salto (`jump-dust`) y
> humo de dash (`dash-smoke`). Lo ÚNICO propio de FAVI es su proyectil AZUL
> (su especial), porque el de DAM es fuego naranja y no le pega a su paleta.

Reglas para los efectos: fondo VERDE PURO #00FF00, SIN personaje, SIN texto ni
marcas. Una sola fila de frames, todos a la MISMA escala y CENTRADOS. Estilo
cel-anime de juego de pelea: formas con bordes DEFINIDOS y núcleos sólidos —
nada de brumas o auras translúcidas grandes. PROHIBIDO usar tonos verdes en el
efecto.

21. **`needle-wave-sheet.png`** — 6 frames (loop). PROYECTIL "TORMENTA DE
    AGUJAS" que viaja. SOLO el efecto, sin personaje. Fondo verde puro
    #00FF00. Estilo cel-anime: un HAZ/enjambre apretado de agujas de energía
    AZUL brillante avanzando en formación, núcleo blanco-celeste ardiente,
    cuerpo azul eléctrico, bordes de línea definidos, con esquirlas y chispas
    azules saltando. Apunta/avanza hacia la DERECHA (yo lo espejo). Los 6
    frames son el mismo enjambre GIRANDO/vibrando en su sitio (loop) para que
    se vea vivo mientras viaja:
    - f1-f6: las agujas azules se enroscan y se estiran en espiral apretada,
      chispas orbitando. El f6 conecta con el f1 (loop).
      Centrado en el mismo punto en los 6 frames.

22. **`needle-wave-sheet-impact.png`** — 6 frames (UNA vez, NO loop). ESTALLIDO
    AZUL cuando la tormenta CONECTA con el rival. SOLO el efecto, sin personaje.
    Fondo verde puro #00FF00. Estilo cel-anime:
    - f1: estallido máximo — núcleo blanco-celeste cegador con picos radiales
      de agujas azules disparándose hacia afuera.
    - f2-f3: el destello se apaga hacia el centro, las esquirlas azules se
      expanden y flotan.
    - f4-f5: nube de chispas azules disipándose.
    - f6: casi todo tenue que se desvanece.
      Todos los frames CENTRADOS en el mismo punto. Lo reproduzco 1 vez sobre el
      torso del rival y se apaga solo.

---

## Movimientos agachados y de reacción (personaje: aplican las reglas generales)

23. **`crouch-jab-sheet.png`** — 4 frames. PINCHAZO BAJO (↓R): estocada
    corta y veloz con UNA aguja desde la guardia agachada. TODO de perfil,
    pies plantados, altura agachada en los 4 frames:
    - f1: agachada de perfil, carga corta — la mano de la aguja delantera
      retrocede junto a la cadera, la hoja apunta adelante-abajo (la otra
      aguja recogida)
    - f2: ESTOCADA — brazo extendido, aguja horizontal a la altura de la
      espinilla, punta hacia adelante (dejar medio cuerpo de espacio
      libre delante para la hoja)
    - f3: sostiene la estocada con leve vibración del impacto
    - f4: recoge el brazo y vuelve a la guardia agachada
      El movimiento es PEQUEÑO y seco: no se levanta, no gira, no salta.

24. **`air-jab-sheet.png`** — 4 frames. **PATADA AÉREA DOBLE** (salto + R): en el
    AIRE se encoge SEMISENTADA (rodillas arriba, como sentada flotando) y agita los
    pies pateando al frente DOS veces seguidas — un pie y luego el otro (shuffle
    alante-atrás), rápido. NO usa las agujas para pegar (las lleva recogidas, una en
    cada mano). Vista de perfil, mirando a la DERECHA, TODO en el aire (nada toca el
    piso), la MISMA altura de cuerpo en los 4 frames. Es un ataque aéreo ligero y veloz:
    - f1: en el aire, se ENCOGE semisentada (muslos arriba, rodillas dobladas), las
      dos agujas recogidas junto al cuerpo; un pie empieza a estirarse
    - f2: PRIMERA patada — estira un pie al FRENTE (pierna casi recta, patada
      horizontal), el otro pie recogido bajo el cuerpo
    - f3: SEGUNDA patada — recoge ese pie y estira el OTRO al frente (cambio
      alante-atrás, tipo pedaleo/flutter en el aire), se ve el "agitar" de los pies
    - f4: recoge las dos piernas de nuevo bajo el cuerpo (recuperación en el aire)
      Movimiento compacto y rápido (doble patadita aérea); el torso semisentado,
      agujas siempre recogidas, misma altura en los 4 frames.

25. **`sweep-sheet.png` + `sweep-sheet-2.png`** — 6 frames en DOS hojas de
    **3 frames cada una** (f1-f2-f3 en la primera, f4-f5-f6 en la segunda).
    IMPORTANTE: sólo **3 frames por hoja** para que cada personaje tenga MUCHO
    espacio y la aguja extendida al frente NUNCA toque ni se acerque al frame
    de al lado (dejá al menos UN CUERPO ENTERO de green vacío entre la punta de
    la aguja de un frame y el siguiente personaje). BARRIDO DERRIBADOR (↓E):
    FAVI se deja caer MUY ABAJO (en cuclillas profundas, casi sentada sobre
    el talón) y barre la **aguja delantera** en un arco HORIZONTAL rasante al
    PISO que cruza todo el frente, para engancharle los tobillos al rival y
    tumbarlo. Es RÁPIDO, PLANO y BAJO — como un jugador barriendo en fútbol,
    pero con la aguja.

    REGLAS que mandan en TODOS los frames (críticas — la IA suele fallarlas):
    - SIEMPRE de **PERFIL mirando a la DERECHA**: se ve su mejilla y ojo
      derechos, el pecho apunta a la derecha. Si se ve el logo del TIGRE de la
      espalda del abrigo, el frame está MAL (nunca de espaldas, nunca de frente).
    - SIEMPRE **AGACHADA y BAJA**: cadera casi a la altura de los tobillos,
      rodillas muy flexionadas, cabeza a media altura. **NUNCA de pie, NUNCA
      salta, NUNCA es una patada** — barre con la AGUJA, no con la pierna. La
      altura de la cabeza es casi la misma en los 6 frames (se mantiene abajo).
    - Los DOS pies SIEMPRE plantados en el piso (pivota sobre las plantas). La
      aguja de atrás (mano trasera) queda RECOGIDA y quieta junto al cuerpo todo
      el tiempo; sólo se mueve la aguja DELANTERA.
    - La hoja delantera va SIEMPRE a ras del piso (horizontal, a la altura de
      los tobillos), NUNCA sube por encima de la rodilla.

    Los 6 frames (cada uno una posición CLARAMENTE distinta del arco):
    - f1: CARGA — en cuclillas profundas, el torso girado un poco hacia ATRÁS
      (a la izquierda); la aguja delantera cargada ATRÁS-ABAJO, la punta casi
      tocando el piso DETRÁS de ella (a su izquierda).
    - f2: ARRANQUE — el brazo empieza a barrer hacia adelante; la hoja raspa el
      piso pasando por DEBAJO del cuerpo, horizontal, punta hacia adelante-abajo.
    - f3: PICO DEL BARRIDO — la aguja COMPLETAMENTE extendida al FRENTE (a la
      derecha) a RAS del piso, brazo estirado, la hoja horizontal cruzando todo
      el frente a la altura de los tobillos. Deja MEDIO CUERPO de espacio verde
      vacío delante de la punta (no debe tocar el frame vecino).
    - f4: SEGUIMIENTO — la hoja sigue el arco un poco más allá del frente, apenas
      empezando a subir del piso; el torso acompaña el giro hacia la derecha.
    - f5: FRENADO — el brazo frena y la aguja regresa cruzando por delante del
      cuerpo hacia el centro, aún bien abajo en cuclillas.
    - f6: RECUPERA la guardia AGACHADA (postura de crouch normal, agujas listas),
      sin levantarse.

    Fondo VERDE PURO #00FF00, sin sombra en el piso, sin líneas de velocidad.
    Franja verde vacía entre frame y frame: la aguja extendida de un frame NUNCA
    toca al personaje del frame de al lado. ANATOMÍA correcta: DOS brazos, DOS
    piernas, DOS manos de 5 dedos, EXACTAMENTE DOS agujas (una por mano).

26. **`wall-bounce-sheet.png`** — 6 frames. VUELO RECTO Y ESTRELLÓN
    CONTRA LA PARED. TODO de perfil, SIN pared, SIN piso, SIN líneas ni
    marcas de impacto, SIN efectos (solo el personaje sobre verde).
    El personaje está NOQUEADA EN EL AIRE: cuerpo suelto de muñeco de
    trapo, SIN control, ojos cerrados/apretados. Los frames son UNA
    SOLA caída continua — cada frame continúa el movimiento del anterior.
    AGUJAS: cada mano floja agarrando SOLO por la anilla, los brazos cuelgan
    arrastrados y las hojas apuntan hacia atrás-abajo.
    PROHIBIDO: pose de ataque, agarrarlas por la hoja, levantarlas, soltarlas.
    - f1: VUELO — cuerpo COMPLETAMENTE HORIZONTAL (paralelo al piso,
      como acostada en el aire), la espalda va por delante, cabeza
      atrás, brazos y piernas arrastrando al lado contrario del vuelo,
      abrigo ondeando fuerte
    - f2: VUELO 2 — igual de horizontal, las piernas suben un poco y
      la cabeza baja un poco (leve giro del cuerpo, alterna con f1)
    - f3: ESTRELLÓN — el cuerpo rota a VERTICAL y se APLASTA de
      espaldas contra una superficie invisible: columna comprimida en
      C, hombros y cadera atrás, brazos y piernas LANZADOS hacia
      adelante por la inercia, el pelo y el abrigo aplastados
    - f4: DESPEGUE — el cuerpo se despega inclinándose hacia adelante
      (~45°), cayendo suelta de bruces, extremidades colgando muertas
      Misma escala en todos los frames.

27. **`pummeled-sheet.png`** — 4 frames (loop). FAVI SIENDO MACHACADA de
    pie durante el super: se tambalea recibiendo golpes rápidos de
    frente, pies plantados en el piso (NO flota, NO salta). Todo de
    perfil, las dos agujas en manos flojas y bajas. CRÍTICO: los 4 frames miran
    a la MISMA dirección (a la DERECHA), NUNCA uno mirando al otro lado.
    ANATOMÍA correcta: exactamente DOS brazos, DOS piernas, DOS manos de
    5 dedos, EXACTAMENTE DOS agujas — NADA de manos, dedos, brazos, piernas ni
    agujas de más. Los 4 frames forman un ciclo continuo:
    - f1: cabeza y torso SNAPEADOS hacia ATRÁS por un golpe frontal,
      desbalanceada atrás, brazos flotando arriba a la defensiva
    - f2: DOBLADA hacia adelante (golpe al estómago), encorvada, cabeza abajo
    - f3: torso TORCIDO a un lado (golpe lateral), tambaleándose, cabeza volteada
    - f4: SNAPEADA atrás otra vez, a punto de reconectar con f1
      Cara de dolor, cuerpo suelto de muñeca pero DE PIE. El f4 conecta
      con el f1 (loop infinito rápido).

28. **`flame-cast-sheet.png`** — 5 frames. FAVI LANZA LA TORMENTA DE AGUJAS
    (su crítico/especial): junta la energía entre sus dos agujas y la suelta al
    frente. Perfil, mira a la derecha, pies plantados, agujas con brillo azul.

    > Nota de nombre: mantengo el archivo como `flame-cast-sheet.png` para que
    > el procesador y el código lo conecten igual que en DAM (la animación se
    > llama `flame_cast` en el motor). Visualmente NO hay fuego: es energía AZUL.
    - f1: carga — baja apenas, lleva las dos agujas ATRÁS-ABAJO juntando
      energía azul entre las puntas, cuerpo tenso
    - f2: ALZA las dos agujas cruzándolas al frente del pecho, la energía azul
      concentrándose entre ambas hojas
    - f3: pico de carga — las agujas separándose un punto, una esfera/haz de
      energía azul brillante formándose entre ellas, torso listo para descargar
    - f4: DESCARGA — empuje rápido de las dos agujas hacia ADELANTE, lanzando la
      tormenta azul al frente, torso volcado adelante
    - f5: remate — brazos extendidos al frente tras soltar, las dos agujas
      apuntando adelante (postura de recuperación)
      (Yo sincronizo el proyectil azul para que salga en el f4.)

---

## Fase 2 (más adelante, no ahora)

- `needle-dash.mp4` — dash veloz dejando estela azul de agujas
- `needle-storm-burst.mp4` — super ataque en área (lluvia de agujas)
- `intro.mp4` — entrada al escenario antes del Round 1

## Recordatorios

- Genera TODO en la misma conversación con tu IA, siempre adjuntando la
  referencia de FAVI. Si el clip sale con otros colores, con una katana, con
  una sola aguja o con agujas de más, repítelo antes de guardar.
- Yo recorto el verde, elijo la sección del clip y lo conecto — tú solo avísame
  cuál está. Frames finales: los genero yo en `imagen-action/favi/` como
  `favi-[accion]-N.png`.
- El moveset y los timings son los de DAM (ver `GUIA-SPRITES.md` y
  `GUIA-COMUN.md`). Si algo no cuadra, manda la de DAM.

---

## NIVELACIÓN con AYE — clips de VIDEO que faltan (workflow nuevo)

> Estas animaciones se generan como CLIPS DE VIDEO (no hojas): 960×960, fondo verde puro
> #00FF00 plano, UNA toma continua. Guardar como `imagen-action/favi/sheets/<accion>.mp4`.
> Yo los proceso a frames. Adjuntar SIEMPRE la referencia de FAVI.
> OJO facing: si el clip sale mirando a la IZQUIERDA no pasa nada — aviso: lo volteo yo al
> procesar (gotcha conocida de las hojas de Fe).

**Reglas fijas del clip (pegar al final de cada prompt):**

> Same exact character as the reference image. STRICT SIDE VIEW / PROFILE, facing RIGHT the
> whole time (NEVER frontal, NEVER three-quarter). Fixed locked TRIPOD camera — no zoom, no
> pan, no drift. She stays the SAME SIZE and on the SAME SPOT the entire clip. Pure flat
> green #00FF00 background. Nobody else in the frame; no effects, no particles, no glow.
> Her TWO thin needles are RIGID SOLID straight rods of CONSTANT length — one in EACH hand,
> no bending, stretching or warping, identical every frame.
>
> STATIC POSITION: she stays in the CENTER of the frame for the ENTIRE clip — the whole
> action happens ON ONE SPOT. She does NOT walk, slide or drift forward/backward; if the
> move includes a jump, the jump goes STRAIGHT UP and she lands on the EXACT SAME SPOT.
> Camera completely fixed, no panning, no zooming.

**`get_up`** _(tendida boca arriba → se para COMPLETA hasta su idle. Hoy se para con snap):_

> She is LYING flat on her BACK on the ground, head toward the LEFT and feet toward the
> RIGHT, eyes closed, still holding her two thin needles, arms relaxed on the ground. She
> wakes and GETS UP in one continuous, light, agile motion: opens her eyes, rolls her weight
> forward, brings her legs under herself and springs up to her FEET — quick and nimble (she
> is a fast assassin, NOT heavy). She MUST END standing EXACTLY in her relaxed idle stance
> from the reference: upright, facing right, one needle in each hand held low at her sides.
> Do NOT stop halfway (no kneeling/sitting end). Her long hair follows the motion and
> settles at the end.

**`ko_air`** _(derrota cayendo BOCA ABAJO — hoy recicla el KO boca arriba. Anti-filtro: es
"desmayo por agotamiento", cero combate):_

> She is STANDING, completely exhausted and dizzy, eyes closing. She FAINTS forward gently:
> her knees give in, she drops onto her knees, then her body tips FORWARD and she ends LYING
> flat FACE-DOWN on the ground, head toward the RIGHT and feet toward the LEFT, arms loose
> beside her head, her two needles dropped on the ground next to her hands, eyes closed,
> completely still. The LAST third of the clip she stays MOTIONLESS lying face-down (hold
> that final pose — the game freezes on it). Soft, slow collapse — like falling asleep
> standing up; NO bouncing, NO jumping, and she does NOT end on her back.

**`land`** _(aterrizaje del salto: flexión corta — hoy cae seca al idle):_

> She is already IN THE AIR just above the ground, falling feet-first (start the clip with
> her boots a small distance above the floor). She LANDS lightly on both feet on the SAME
> SPOT like a cat: knees bend briefly absorbing the impact, torso dips a touch, her long
> hair and outfit bounce once and settle. Then she straightens up and ENDS standing EXACTLY
> in her relaxed idle stance from the reference (one needle in each hand, held low). Short
> clip, one single soft landing, no jump afterwards, feet stay planted after touching down.


**`jump_kick` (Jump + W — needle dive) — SHORT PROMPT (copy everything below as one prompt):**

> Same girl as the reference image. STRICT SIDE VIEW facing RIGHT, flat pure green #00FF00
> background, fixed camera, she stays the SAME SIZE the whole clip. She starts STANDING on
> the ground in her fighting stance (the reference pose). Then, in ONE continuous motion:
> she bends her knees, JUMPS powerfully straight UP off the ground, rises into the air, and
> AT THE TOP of the jump she tilts her body forward and DIVES down-forward, striking with
> ONE needle pointed diagonally DOWN in front of her, the other arm swept back, hair and
> open coat trailing upward. She falls with the dive and lands back on her feet. She never
> hovers or floats in place — it is one athletic jump, dive, land.
>
> STATIC POSITION: keep her near the CENTER of the frame the whole clip — the dive is
> SHORT and steep (she lands barely one step forward of where she jumped), she never
> crosses the screen. Camera completely fixed, no panning, no zooming.
>
> WEAPONS LOCKED: she holds TWO identical SHORT THIN STRAIGHT needles (slim stilettos),
> ONE in each hand, exact same size and shape in EVERY frame. Each needle is ONE PLAIN
> SMOOTH THIN METAL ROD with the same thin thickness from end to end, like a long sewing
> needle — NO handle, NO grip, NO crossguard, NO hilt, NO pommel. NOT swords, NOT long
> blades, NOT curved knives, NOT kunai with rings, NOT daggers, NOT a dagger with a
> handle and guard, no extra weapons, they never disappear, never change hands, never
> change length, never grow a handle.


**`air_jab` (Jump + R — double air kick) — SHORT PROMPT (copy everything below as one prompt):**

> Same girl as the reference image. STRICT SIDE VIEW facing RIGHT, flat pure green #00FF00
> background, fixed camera, she stays the SAME SIZE the whole clip. She starts STANDING in
> her fighting stance, bends her knees and JUMPS powerfully straight UP, rising HIGH into
> the air. While she hangs at the top of the jump, with BOTH feet clearly OFF the ground
> the whole time (she never touches the floor between the kicks), she kicks TWO TIMES —
> TWO separate kicks, NOT one:
>
> KICK 1: her LEFT leg snaps straight FORWARD at chest height — then she PULLS IT BACK in.
>
> KICK 2: immediately after, her RIGHT leg snaps straight FORWARD slightly HIGHER — then
> pulls back in.
>
> One-two rhythm, like a mid-air scissor combo: the clip must clearly show the FIRST kick
> fully RETRACT before the SECOND kick fires. Her torso leans back slightly and both
> needles stay gripped in her hands close to her body (the kicks do the hitting, not the
> needles). ONLY AFTER the second kick finishes does she FALL back down, land on both feet
> on the same spot, and END standing in the EXACT SAME fighting stance she started in
> (hold that final stance for a beat).
>
> STATIC POSITION: she stays in the CENTER of the frame for the ENTIRE clip — the jump goes
> STRAIGHT UP and she lands on the EXACT SAME SPOT. She does NOT travel forward, backward,
> or drift to the sides; only vertical movement. Camera completely fixed, no panning, no
> zooming.
>
> WEAPONS LOCKED: she holds TWO identical SHORT THIN STRAIGHT needles (slim stilettos),
> ONE in each hand, exact same size and shape in EVERY frame. Each needle is ONE PLAIN
> SMOOTH THIN METAL ROD with the same thin thickness from end to end, like a long sewing
> needle — NO handle, NO grip, NO crossguard, NO hilt, NO pommel. NOT swords, NOT long
> blades, NOT curved knives, NOT kunai with rings, NOT daggers, NOT a dagger with a
> handle and guard, no extra weapons, they never disappear, never change hands, never
> change length, never grow a handle.

**`kick` (Ground + W — double rising kick, same leg) — SHORT PROMPT (copy everything below
as one prompt):**

> Same girl as the reference image. STRICT SIDE VIEW facing RIGHT, flat pure green #00FF00
> background, fixed camera, she stays the SAME SIZE the whole clip. She starts STANDING on
> the ground in her fighting stance (the reference pose). She stays STANDING ON THE GROUND
> the whole clip — her support leg stays PLANTED on the floor at all times, she never jumps.
> Then she kicks TWO TIMES with the SAME leg — TWO separate kicks, NOT one:
>
> KICK 1: her front leg snaps straight FORWARD at WAIST height — then she pulls the foot
> back to a chambered position WITHOUT putting it down on the floor.
>
> KICK 2: immediately after, the SAME leg snaps UP much HIGHER — a rising kick at FACE
> height, powerful, her torso leaning back for the height.
>
> One-two rhythm: the clip must clearly show the FIRST kick fully RETRACT (foot chambered,
> knee up) before the SECOND kick fires upward. Both needles stay gripped in her hands
> close to her body (the kicks do the hitting, not the needles). After the second kick she
> lowers the leg and ENDS standing in the EXACT SAME fighting stance she started in (hold
> that final stance for a beat).
>
> STATIC POSITION: she stays in the CENTER of the frame for the ENTIRE clip — the whole
> action happens ON ONE SPOT. She does NOT walk, slide or drift forward/backward. Camera
> completely fixed, no panning, no zooming.
>
> WEAPONS LOCKED: she holds TWO identical SHORT THIN STRAIGHT needles (slim stilettos),
> ONE in each hand, exact same size and shape in EVERY frame. Each needle is ONE PLAIN
> SMOOTH THIN METAL ROD with the same thin thickness from end to end, like a long sewing
> needle — NO handle, NO grip, NO crossguard, NO hilt, NO pommel. NOT swords, NOT long
> blades, NOT curved knives, NOT kunai with rings, NOT daggers, NOT a dagger with a
> handle and guard, no extra weapons, they never disappear, never change hands, never
> change length, never grow a handle.

**`spin_kick` (Ground + E — needle top-spin) — SHORT PROMPT (copy everything below as one
prompt):**

> Same girl as the reference image. STRICT SIDE VIEW facing RIGHT, flat pure green #00FF00
> background, fixed camera, she stays the SAME SIZE the whole clip. She starts STANDING on
> the ground in her fighting stance (the reference pose). Then she SPINS IN PLACE at very
> high speed like a spinning top, arms and needles held straight OUT to the sides, one
> full clean turn after another. She stays ON THE GROUND the whole clip — feet
> planted/pivoting on one spot, no jump.
>
> Sequence: quick wind-up (she coils, arms crossing in) → FAST TOP SPIN (2-3 full turns,
> fastest here) → the spin SLOWS DOWN GRADUALLY over several frames (a smooth, natural
> deceleration — NOT a sudden stop) → she ENDS standing in the EXACT SAME fighting stance
> she started in, in the SAME strict SIDE VIEW facing RIGHT (hold that final stance for a
> beat). She must NEVER end facing the camera: the final frames are pure PROFILE view,
> identical to the first frame of the clip.
>
> STATIC POSITION: she stays in the CENTER of the frame for the ENTIRE clip — the whole
> action happens ON ONE SPOT. She does NOT walk, slide or drift forward/backward. Camera
> completely fixed, no panning, no zooming.
>
> WEAPONS LOCKED: she holds TWO identical SHORT THIN STRAIGHT needles (slim stilettos),
> ONE in each hand, exact same size and shape in EVERY frame. Each needle is ONE PLAIN
> SMOOTH THIN METAL ROD with the same thin thickness from end to end, like a long sewing
> needle — NO handle, NO grip, NO crossguard, NO hilt, NO pommel. NOT swords, NOT long
> blades, NOT curved knives, NOT kunai with rings, NOT daggers, NOT a dagger with a
> handle and guard, no extra weapons, they never disappear, never change hands, never
> change length, never grow a handle.

**`weak_punch` (Ground + R — quick needle jab) — SHORT PROMPT (copy everything below as one
prompt):**

> Same girl as the reference image. STRICT SIDE VIEW facing RIGHT, flat pure green #00FF00
> background, fixed camera, she stays the SAME SIZE the whole clip. She starts STANDING on
> the ground in her fighting stance (the reference pose), knees slightly bent. Then she
> throws ONE quick needle JAB: her FRONT arm snaps straight FORWARD at chest height,
> stabbing with the needle held in that hand — a fast, precise fencing-style thrust, arm
> FULLY extended for an instant, her body leaning just slightly into it, back arm guarding
> at her hip. Then she snaps the arm back and ENDS standing in the EXACT SAME fighting
> stance she started in (hold that final stance for a beat). It is ONE single fast jab —
> no combo, no spin, no kick, her feet stay planted the whole time.
>
> STATIC POSITION: she stays in the CENTER of the frame for the ENTIRE clip — the whole
> action happens ON ONE SPOT. She does NOT walk, slide or drift forward/backward. Camera
> completely fixed, no panning, no zooming.
>
> WEAPONS LOCKED: she holds TWO identical SHORT THIN STRAIGHT needles (slim stilettos),
> ONE in each hand, exact same size and shape in EVERY frame. Each needle is ONE PLAIN
> SMOOTH THIN METAL ROD with the same thin thickness from end to end, like a long sewing
> needle — NO handle, NO grip, NO crossguard, NO hilt, NO pommel. NOT swords, NOT long
> blades, NOT curved knives, NOT kunai with rings, NOT daggers, NOT a dagger with a
> handle and guard, no extra weapons, they never disappear, never change hands, never
> change length, never grow a handle.

**`whirlpool` (↓←+E finisher — WHIRLPOOL, water vortex spin) — SHORT PROMPT (copy
everything below as one prompt):**

> Same girl as the reference image. STRICT SIDE VIEW facing RIGHT, flat pure green #00FF00
> background, fixed camera, she stays the SAME SIZE the whole clip. She starts STANDING on
> the ground in her fighting stance (the reference pose). Then she performs her ultimate
> technique: she coils, then SPINS IN PLACE at extreme speed, and a spiral of PURE WHITE
> ENERGY rises from the ground and wraps around her body like a small TORNADO — she
> becomes the core of a spinning column of blinding white light with silver-white electric
> arcs crackling around it, needles held out as the vortex whirls around her. Hold the
> full raging vortex for the middle of the clip (this is the loop the game will cycle).
> Then the energy bursts apart into white sparks, the spin slows down gradually, and she
> ENDS standing in the EXACT SAME fighting stance she started in, in the SAME strict SIDE
> VIEW facing RIGHT — she must NEVER end facing the camera.
>
> The energy is WHITE and SILVER only (no blue, no fire colors, no green tint anywhere).
> The vortex stays TIGHT around her body — it does NOT fill the frame, and nothing
> touches the frame edges; full column always visible with margin.
>
> STATIC POSITION: she stays in the CENTER of the frame for the ENTIRE clip — the whole
> action happens ON ONE SPOT. She does NOT walk, slide or drift forward/backward. Camera
> completely fixed, no panning, no zooming.
>
> WEAPONS LOCKED: she holds TWO identical SHORT THIN STRAIGHT needles (slim stilettos),
> ONE in each hand, exact same size and shape in EVERY frame. Each needle is ONE PLAIN
> SMOOTH THIN METAL ROD with the same thin thickness from end to end, like a long sewing
> needle — NO handle, NO grip, NO crossguard, NO hilt, NO pommel. NOT swords, NOT long
> blades, NOT curved knives, NOT kunai with rings, NOT daggers, NOT a dagger with a
> handle and guard, no extra weapons, they never disappear, never change hands, never
> change length, never grow a handle.

**LOS 4 AGACHADOS** — cada prompt es AUTOCONTENIDO (copia el bloque entero tal cual, con
sus párrafos STATIC POSITION y WEAPONS LOCKED incluidos). El arma va anclada desde la
PRIMERA línea: es donde más muta la herramienta. Guardar como `crouch_jab.mp4` /
`crouch_punch.mp4` / `crouch_kick.mp4` / `sweep.mp4`.

**`crouch_jab` (↓ + R — CAST del TIGRE: señala al frente agachada) — SHORT PROMPT (copy
everything below as one prompt):**

> Same girl as the reference image, holding her signature weapons: TWO identical SHORT
> THIN STRAIGHT needles (slim metal stilettos), ONE in each hand — these two needles are
> the ONLY weapons in the clip and must stay IDENTICAL to the reference in every frame.
> STRICT SIDE VIEW facing RIGHT, flat pure green #00FF00 background, fixed camera, she
> stays the SAME SIZE the whole clip. She is CROUCHED LOW on deeply bent knees, compact
> guard. She stays CROUCHED the ENTIRE clip — she never stands up. From the crouch her
> front arm sweeps out and POINTS straight FORWARD, needle in hand aimed forward like a
> general commanding an attack, her face fierce and focused, hair and coat reacting with
> a small burst of wind. She HOLDS that commanding pointing pose for a moment. Then she
> pulls the arm back and ENDS in the EXACT SAME crouched guard she started in (hold it a
> beat). No jab, no kick — just the commanding point-forward gesture. She is ALONE in the
> frame the entire clip. NO effects of any kind: no glow, no aura, no particles, no
> energy, no light rays, no sparks — ONLY the girl on the flat green background (the game
> engine adds all effects separately).
>
> CAMERA HARD-LOCKED: absolutely NO zoom in, NO zoom out, NO push-in, NO pan, NO drift —
> the camera is a fixed tripod for the ENTIRE clip. Her body must be the SAME SIZE in
> pixels in the FIRST frame and the LAST frame (only her arm pose changes, never her
> scale). This is a SIMPLE, SUBTLE animation — do NOT invent extra action or camera
> drama.
>
> STATIC POSITION: she stays in the CENTER of the frame for the ENTIRE clip — the whole
> action happens ON ONE SPOT. She does NOT walk, slide or drift forward/backward.
>
> WEAPONS LOCKED: she holds TWO identical SHORT THIN STRAIGHT needles (slim stilettos),
> ONE in each hand, exact same size and shape in EVERY frame. Each needle is ONE PLAIN
> SMOOTH THIN METAL ROD with the same thin thickness from end to end, like a long sewing
> needle — NO handle, NO grip, NO crossguard, NO hilt, NO pommel. NOT swords, NOT long
> blades, NOT curved knives, NOT kunai with rings, NOT daggers, NOT a dagger with a
> handle and guard, no extra weapons, they never disappear, never change hands, never
> change length, never grow a handle.

**`tiger.mp4` (el TIGRE DE ENERGÍA BLANCA del ↓R — efecto SIN personaje) — SHORT PROMPT
(copy everything below as one prompt):**

> Pure visual effect on a flat pure green #00FF00 background — NO human character, NO
> floor, NO shadow, nothing else in frame. A fierce TIGER made of PURE WHITE ENERGY (white
> spectral tiger, glowing white body with wisps of white flame-like energy tracing it,
> mouth open in a roar — like the reference image). The clip has 3 phases:
>
> PHASE 1 — APPEAR: the tiger MATERIALIZES from swirling wisps of white energy that
> gather and take its shape (fast, dramatic).
>
> PHASE 2 — RUN: in STRICT SIDE VIEW it RUNS powerfully from the LEFT side toward the
> RIGHT side of the frame at a constant height, full gallop with claws out and mouth
> roaring, leaving a short trail of white energy wisps behind it. Make the RUN CYCLE clean
> and even (the game will loop these frames while the tiger travels and mauls the enemy).
>
> PHASE 3 — DISSOLVE: the tiger breaks apart and DISSOLVES into white energy wisps and
> sparks that fade out.
>
> The energy is WHITE and SILVER only — no blue, no orange, no green tint anywhere. The
> tiger is the ONLY thing in the frame.
>
> CAMERA HARD-LOCKED: absolutely NO zoom in, NO zoom out, NO push-in, NO pan, NO drift —
> the camera is a fixed tripod for the ENTIRE clip. The tiger stays the EXACT SAME SIZE
> in pixels from the moment it forms until it dissolves — it does NOT grow, does NOT get
> closer to the camera, does NOT get bigger as it runs. Its body height is the same in
> every frame; only its legs and energy wisps move.

**`crouch_punch` (↓ + Q — crouch double thrust) — SHORT PROMPT (copy everything below as
one prompt):**

> Same girl as the reference image, holding her signature weapons: TWO identical SHORT
> THIN STRAIGHT needles (slim metal stilettos), ONE in each hand — the needles stay
> SEPARATE at all times, one per hand, they NEVER touch each other, NEVER cross, NEVER
> join together, and must stay IDENTICAL to the reference in every frame. STRICT SIDE
> VIEW facing RIGHT, flat pure green #00FF00 background, fixed camera, she stays the SAME
> SIZE the whole clip. She is CROUCHED LOW on deeply bent knees, compact guard. She stays
> CROUCHED the ENTIRE clip — she never stands up. From the crouch, BOTH arms punch
> straight FORWARD SIMULTANEOUSLY — the two arms move as ONE, launching at the EXACT SAME
> MOMENT and arriving at the EXACT SAME MOMENT (NOT one hand first and then the other,
> NOT a one-two: a single synchronized double stab). Fast DOUBLE STAB at waist height,
> needles pointing forward SIDE BY SIDE and PARALLEL, one hand slightly above the other,
> clearly separated. Arms fully extended for an instant. Then she pulls both arms back
> TOGETHER and ENDS in the EXACT SAME crouched guard she started in (hold it a beat).
> Feet planted, no kick, no spin.
>
> STATIC POSITION: she stays in the CENTER of the frame for the ENTIRE clip — the whole
> action happens ON ONE SPOT. She does NOT walk, slide or drift forward/backward. Camera
> completely fixed, no panning, no zooming.
>
> WEAPONS LOCKED: she holds TWO identical SHORT THIN STRAIGHT needles (slim stilettos),
> ONE in each hand, exact same size and shape in EVERY frame. Each needle is ONE PLAIN
> SMOOTH THIN METAL ROD with the same thin thickness from end to end, like a long sewing
> needle — NO handle, NO grip, NO crossguard, NO hilt, NO pommel. NOT swords, NOT long
> blades, NOT curved knives, NOT kunai with rings, NOT daggers, NOT a dagger with a
> handle and guard, no extra weapons, they never disappear, never change hands, never
> change length, never grow a handle.

**`crouch_kick` (↓ + W — rising needles, launcher) — SHORT PROMPT (copy everything below
as one prompt):**

> Same girl as the reference image, holding her signature weapons: TWO identical SHORT
> THIN STRAIGHT needles (slim metal stilettos), ONE in each hand — these two needles are
> the ONLY weapons in the clip and must stay IDENTICAL to the reference in every frame.
> STRICT SIDE VIEW facing RIGHT for the ENTIRE clip — pure PROFILE, she NEVER turns
> toward the camera. Flat pure green #00FF00 background, fixed camera, she stays the SAME
> SIZE the whole clip. The move has 3 phases:
>
> PHASE 1: she is CROUCHED LOW on deeply bent knees, compact guard, needles held low.
>
> PHASE 2: she thrusts BOTH needles in a fast rising DIAGONAL strike IN FRONT of her
> body: the needles travel from her KNEES up to her FACE level, ending pointed diagonally
> UP-FORWARD at 45 degrees IN FRONT of her chest — an anti-air uppercut with the blades.
> Her legs push up into a forward LUNGE (half-rise) but her feet STAY PLANTED on the
> floor — she does NOT jump. IMPORTANT: the needles STOP at face height IN FRONT of her.
> They NEVER go above her head, NEVER behind her head, and her arms NEVER cross each
> other — both blades point the same diagonal direction, up and forward.
>
> PHASE 3: she sinks straight back down and ENDS in the EXACT SAME crouched guard from
> PHASE 1 (hold it a beat).
>
> STATIC POSITION: she stays in the CENTER of the frame for the ENTIRE clip — the whole
> action happens ON ONE SPOT. She does NOT walk, slide or drift forward/backward. Camera
> completely fixed, no panning, no zooming.
>
> WEAPONS LOCKED: she holds TWO identical SHORT THIN STRAIGHT needles (slim stilettos),
> ONE in each hand, exact same size and shape in EVERY frame. Each needle is ONE PLAIN
> SMOOTH THIN METAL ROD with the same thin thickness from end to end, like a long sewing
> needle — NO handle, NO grip, NO crossguard, NO hilt, NO pommel. NOT swords, NOT long
> blades, NOT curved knives, NOT kunai with rings, NOT daggers, NOT a dagger with a
> handle and guard, no extra weapons, they never disappear, never change hands, never
> change length, never grow a handle.

**`sweep` (↓ + E — ground leg sweep) — SHORT PROMPT (copy everything below as one
prompt):**

> Same girl as the reference image, holding her signature weapons: TWO identical SHORT
> THIN STRAIGHT needles (slim metal stilettos), ONE in each hand — these two needles are
> the ONLY weapons in the clip, they stay GRIPPED in her hands and IDENTICAL to the
> reference in every frame (the KICK does the hitting, the needles never strike). STRICT
> SIDE VIEW facing RIGHT, flat pure green #00FF00 background, fixed camera, she stays the
> SAME SIZE the whole clip. She is CROUCHED VERY LOW, hands near the ground for balance.
> She stays LOW the ENTIRE clip — she never stands up. From that low crouch she sweeps
> ONE leg in a wide fast arc along the GROUND in front of her — a classic fighting-game
> leg sweep at ankle height, skirt and coat flaring with the motion — and brings the leg
> back under her. She ENDS in the EXACT SAME low crouched guard she started in, in the
> SAME strict SIDE VIEW facing RIGHT (never facing the camera). One single sweep, the
> sweeping foot skims just above the floor.
>
> STATIC POSITION: she stays in the CENTER of the frame for the ENTIRE clip — the whole
> action happens ON ONE SPOT. She does NOT walk, slide or drift forward/backward. Camera
> completely fixed, no panning, no zooming.
>
> WEAPONS LOCKED: she holds TWO identical SHORT THIN STRAIGHT needles (slim stilettos),
> ONE in each hand, exact same size and shape in EVERY frame. Each needle is ONE PLAIN
> SMOOTH THIN METAL ROD with the same thin thickness from end to end, like a long sewing
> needle — NO handle, NO grip, NO crossguard, NO hilt, NO pommel. NOT swords, NOT long
> blades, NOT curved knives, NOT kunai with rings, NOT daggers, NOT a dagger with a
> handle and guard, no extra weapons, they never disappear, never change hands, never
> change length, never grow a handle.

**`crouch` (↓ — solo agacharse y quedarse) — SHORT PROMPT (copy everything below as one
prompt):**

> Same girl as the reference image. STRICT SIDE VIEW facing RIGHT, flat pure green #00FF00
> background. This is a SIMPLE, SUBTLE animation — almost nothing happens, do NOT invent
> extra action. She starts STANDING in her fighting stance (the reference pose). She
> smoothly LOWERS into a DEEP CROUCH: knees bend fully, hips drop, torso stays upright and
> compact, keeping her guard — one needle in each hand, held close. Then she HOLDS that
> crouched guard for the REST of the clip, completely still except a subtle breathing
> motion. She does NOT attack, does NOT stand back up, does NOT walk.
>
> CAMERA HARD-LOCKED: absolutely NO zoom in, NO zoom out, NO push-in, NO pan, NO drift —
> the camera must be a fixed tripod for the ENTIRE clip. Her body must be the SAME SIZE in
> pixels in the FIRST frame and the LAST frame (only her pose changes, never her scale).
>
> STATIC POSITION: she stays in the CENTER of the frame for the ENTIRE clip — the whole
> action happens ON ONE SPOT. She does NOT walk, slide or drift forward/backward.
>
> WEAPONS LOCKED: she holds TWO identical SHORT THIN STRAIGHT needles (slim stilettos),
> ONE in each hand, exact same size and shape in EVERY frame. Each needle is ONE PLAIN
> SMOOTH THIN METAL ROD with the same thin thickness from end to end, like a long sewing
> needle — NO handle, NO grip, NO crossguard, NO hilt, NO pommel. NOT swords, NOT long
> blades, NOT curved knives, NOT kunai with rings, NOT daggers, NOT a dagger with a
> handle and guard, no extra weapons, they never disappear, never change hands, never
> change length, never grow a handle.

---

## SALE VOLANDO (`hit_fly`) — pendiente: el arte actual es de hojas viejas (4 frames tiesos)

**`hit_fly` (sale VOLANDO por un lanzador — la mueve el motor, ella solo vuela) — SHORT
PROMPT (copy everything below as one prompt):**

> Same girl as the reference image, holding her signature weapons: TWO identical SHORT
> THIN STRAIGHT needles (slim metal stilettos), ONE in each hand — these two needles are
> the ONLY weapons in the clip and must stay IDENTICAL to the reference in every frame.
> STRICT SIDE VIEW facing RIGHT, flat pure green #00FF00 background, fixed camera, she
> stays the SAME SIZE the whole clip. ONE single knockback, in ONE direction only: she
> has just been BLASTED off her feet and flies BACKWARD (toward the LEFT side of the
> frame) in ONE clean arc — launched up-and-back with her back arched belly-up, head
> thrown back, arms whipping loosely, legs trailing bent, hair and coat lashing, eyes
> squeezed shut, mouth open in pain — the arc peaks, she starts to DROP, and she FALLS
> to the ground landing flat on her BACK, sliding a tiny bit, ending lying on the
> ground. The flight is ONE continuous smooth trajectory: up-back, arc over, fall down,
> land. ORIENTATION LOCKED the whole clip: her HEAD points toward the RIGHT side of the
> frame and her FEET toward the LEFT side, from the first frame of the flight to the
> final landing — she lands on her back with her head STILL toward the RIGHT and her
> feet STILL toward the LEFT, exactly the same orientation she flew with. The direction
> of travel NEVER reverses: she moves steadily toward the LEFT from launch to landing —
> she does NOT turn around, does NOT flip head-to-feet, does NOT come back toward the
> right, does NOT bounce mid-air, does NOT float in place. NO effects: no glow, no
> aura, no particles, no dust, no motion lines — only the girl.
>
> CAMERA HARD-LOCKED: absolutely NO zoom in, NO zoom out, NO push-in, NO pan, NO drift —
> the camera is a fixed tripod for the ENTIRE clip. Her body must be the SAME SIZE in
> pixels in the FIRST frame and the LAST frame.
>
> WEAPONS LOCKED: she holds TWO identical SHORT THIN STRAIGHT needles (slim stilettos),
> ONE in each hand, exact same size and shape in EVERY frame. Each needle is ONE PLAIN
> SMOOTH THIN METAL ROD with the same thin thickness from end to end, like a long sewing
> needle — NO handle, NO grip, NO crossguard, NO hilt, NO pommel. NOT swords, NOT long
> blades, NOT curved knives, NOT kunai with rings, NOT daggers, NOT a dagger with a
> handle and guard, no extra weapons, they never disappear, never change hands, never
> change length, never grow a handle.

> _Guardar como `sheets/hit-fly.mp4` → lo proceso a `favi/hit_fly/` (drop-in: el juego
> ya usa esa anim al salir volando)._

## K.O. (`ko`) — colapso final (hoy usa la cola del clip de hit_fly; clip propio pendiente)

**`ko` (recibe el GOLPE FINAL de pie y colapsa) — SHORT PROMPT (copy everything below
as one prompt):**

> Same girl as the reference image, holding her signature weapons: TWO identical SHORT
> THIN STRAIGHT needles (slim metal stilettos), ONE in each hand — these two needles are
> the ONLY weapons in the clip and must stay IDENTICAL to the reference in every frame.
> STRICT SIDE VIEW facing RIGHT, flat pure green #00FF00 background, fixed camera, she
> stays the SAME SIZE the whole clip. She has just taken the FINAL blow of the fight and
> is KNOCKED OUT: from her standing guard her head snaps back, her arms drop LIMP (the
> needles still loosely in her hands), her knees BUCKLE under her, and she COLLAPSES
> BACKWARD in one continuous fall — landing flat on her BACK on the ground, head toward
> the LEFT side of the frame and feet toward the RIGHT, hair spilling on the floor. She
> ends COMPLETELY STILL, lying flat on her back, eyes closed, mouth slightly open,
> defeated — HOLD that final lying pose for a good beat. Her feet stay roughly planted
> where she stood while the body falls back — she does NOT walk, does NOT get thrown
> across the frame, does NOT get up, does NOT bounce. One single collapse, one
> direction, ending still on the floor. NO effects: no glow, no aura, no particles, no
> dust, no motion lines — only the girl.
>
> CAMERA HARD-LOCKED: absolutely NO zoom in, NO zoom out, NO push-in, NO pan, NO drift —
> the camera is a fixed tripod for the ENTIRE clip. Her body must be the SAME SIZE in
> pixels in the FIRST frame and the LAST frame.
>
> WEAPONS LOCKED: she holds TWO identical SHORT THIN STRAIGHT needles (slim stilettos),
> ONE in each hand, exact same size and shape in EVERY frame. Each needle is ONE PLAIN
> SMOOTH THIN METAL ROD with the same thin thickness from end to end, like a long sewing
> needle — NO handle, NO grip, NO crossguard, NO hilt, NO pommel. NOT swords, NOT long
> blades, NOT curved knives, NOT kunai with rings, NOT daggers, NOT a dagger with a
> handle and guard, no extra weapons, they never disappear, never change hands, never
> change length, never grow a handle.

> _Guardar como `sheets/ko.mp4` → lo proceso a `favi/ko/` (drop-in: reemplaza la
> versión provisional sacada del aterrizaje de hit_fly)._

## ⚡ CAMBIO DE PODER (2026-08): ENERGÍA PURA BLANCA (ya NO agua)

> El elemento de Fe pivota de AGUA a **ENERGÍA PURA BLANCA** (enlaza con el TIGRE de su
> abrigo). Reemplazos: los géiseres de agua (↓→Q/W/E) pasan a ser **THUNDER**: un rayo
> anime (núcleo blanco + glow azul eléctrico, como la imagen de referencia del rayo) que
> CAE del cielo y revienta en el suelo. Y gana un proyectil nuevo: el **TIGRE DE
> ENERGÍA**. Los clips de EFECTO van SIN personaje, solo el efecto sobre verde puro.

**`thunder-cast.mp4` (Fe INVOCA el rayo — personaje solo, sin efectos) — SHORT PROMPT
(copy everything below as one prompt):**

> Same girl as the reference image, holding her signature weapons: TWO identical SHORT
> THIN STRAIGHT needles (slim metal stilettos), ONE in each hand — these two needles are
> the ONLY weapons in the clip and must stay IDENTICAL to the reference in every frame.
> STRICT SIDE VIEW facing RIGHT, flat pure green #00FF00 background, fixed camera, she
> stays the SAME SIZE the whole clip. From her standing fighting guard she THRUSTS her
> front arm up to the SKY, needle held high overhead pointing straight UP like a
> conductor's baton commanding the heavens, chin lifted, face fierce, hair and coat
> reacting with a small burst of wind. She HOLDS the sky-point for a beat, then WHIPS the
> arm down in one sharp motion so the needle points straight FORWARD at chest height,
> like ordering a strike. Then she returns to the EXACT SAME standing guard she started
> in (hold it a beat). No jab, no kick, no jump — just the sky-point and the downward
> command whip. She is ALONE in the frame the entire clip. NO effects of any kind: no
> glow, no aura, no particles, no energy, no light rays, no sparks — ONLY the girl on
> the flat green background (the game engine adds all effects separately).
>
> CAMERA HARD-LOCKED: absolutely NO zoom in, NO zoom out, NO push-in, NO pan, NO drift —
> the camera is a fixed tripod for the ENTIRE clip. Her body must be the SAME SIZE in
> pixels in the FIRST frame and the LAST frame (only her arms change, never her scale).
> This is a SIMPLE, SUBTLE animation — do NOT invent extra action or camera drama.
>
> STATIC POSITION: she stays in the CENTER of the frame for the ENTIRE clip — the whole
> action happens ON ONE SPOT. She does NOT walk, slide or drift forward/backward.
>
> WEAPONS LOCKED: she holds TWO identical SHORT THIN STRAIGHT needles (slim stilettos),
> ONE in each hand, exact same size and shape in EVERY frame. Each needle is ONE PLAIN
> SMOOTH THIN METAL ROD with the same thin thickness from end to end, like a long sewing
> needle — NO handle, NO grip, NO crossguard, NO hilt, NO pommel. NOT swords, NOT long
> blades, NOT curved knives, NOT kunai with rings, NOT daggers, NOT a dagger with a
> handle and guard, no extra weapons, they never disappear, never change hands, never
> change length, never grow a handle.

**`thunder.mp4` (el RAYO que cae — efecto SIN personaje; adjunta la imagen del rayo como
referencia) — SHORT PROMPT (copy everything below as one prompt):**

> Animate the attached image. The attached image is the EXACT artwork: a THIN, WIRY,
> needle-thin electric CRACK of white light — a jagged broken LINE with long thin sharp
> spikes and hard angular turns — with a blinding white core and an electric cyan-blue
> glow, reaching down into a white spiky impact STARBURST at the bottom, on a flat pure
> green #00FF00 background. NO character, NO person, NO floor, NO ground plane, NO
> shading on the background, NO clouds, NO rain — the green is one single flat tone edge
> to edge. KEEP THE EXACT SILHOUETTE of the electric crack from the attached image — the
> same thin zigzag path, the same angles, the same thin spikes, the same proportions. Do
> NOT redesign it, do NOT simplify it, do NOT thicken it.
>
> The animation is simple, ONE single strike: the thin electric crack SNAPS into view
> from the top in 1-2 frames, the starburst FLARES at the impact point for a brief
> moment, then the whole crack breaks into thin white arcs and sparks and DISAPPEARS,
> the cyan glow fading last until the frame is pure green again. It appears ONCE and
> vanishes — no repeated strikes, no flickering loop. Fixed camera, NO zoom, NO pan. The
> impact point stays at the SAME SPOT the whole clip; the crack does not travel sideways.
>
> SHAPE LOCKED: the electric crack is a THIN broken LINE (like a crack in glass), never
> a thick solid shape. It is NOT a lightning-bolt icon, NOT a thunderbolt symbol, NOT a
> logo, NOT an emoji, NOT a wide filled arrow shape — if the shape becomes a fat solid
> zigzag ribbon it is WRONG. Every segment stays needle-thin with a soft glow, exactly
> like the attached image, in EVERY frame.

**`tiger.mp4`** _(el PROYECTIL nuevo: tigre de energía del ↓R — el prompt canónico está
en la sección de los AGACHADOS, justo debajo del cast `crouch_jab`; con fases APPEAR /
RUN / DISSOLVE)._

> _Nota de cableado (para mí): thunder reemplaza los frames de
> `impact-effect/water-geyser-fe/` (drop-in, mismo código) pero ANCLADO POR EL IMPACTO:
> la base del starburst va a la línea de suelo del canvas (el rayo cae de arriba; el
> géiser subía — el punto de spawn en el suelo no cambia). thunder-cast reemplaza los
> frames de `favi/water_cast/` (drop-in). Los tintes azules en juego (water_flash, borde
> de cast) YA calzan con el glow azul de la referencia — no hay que tocarlos._

> _Note: reuse the "WEAPONS LOCKED" paragraph verbatim in EVERY short Fe prompt — it is what
> stops the tool from mutating her needles._
