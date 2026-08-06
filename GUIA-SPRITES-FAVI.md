# FAVI — The Twin Fang · Guía de sprites (personaje)

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

## Reglas generales (van en TODOS los prompts)

Pega esto al final de cada prompt, junto con la **imagen de referencia de FAVI**
(su hoja de diseño) adjunta:

> Mismo personaje exacto de la referencia: chica de pelo castaño oscuro largo y
> lacio, ojos cafés grandes, piel morena clara. Lleva una gabardina AZUL REY con
> capucha, larga y abierta (en la ESPALDA del abrigo va un logo grande de cabeza
> de TIGRE blanco); debajo una camiseta azul con estampado blanco de tigre,
> falda plisada LILA/lavanda, calcetas blancas, tenis altos AZUL-Y-BLANCO,
> guantes negros SIN dedos, y un dije/llavero de BALÓN DE FÚTBOL colgando del
> abrigo. Su arma son DOS AGUJAS: hojas largas, muy finas y afiladas, de metal
> AZUL, con una ANILLA (aro) en el mango; ligeras y precisas, con un brillo azul
> frío sutil en la punta. Lleva UNA aguja en CADA mano. Sin fuego, sin llamas,
> sin partículas: son agujas de metal, NO una katana, NO una espada ancha, NO una
> sola hoja. Misma paleta de colores exacta y mismo estilo de línea. Vista
> lateral de juego de pelea 2D (estilo KOF), personaje mirando a la DERECHA
> en TODOS los frames — nunca de frente a la cámara, nunca de espaldas.
> Los frames van en UNA o DOS filas, ordenados de izquierda a derecha (la
> fila de ARRIBA primero). Todos los personajes a la MISMA escala; dentro de
> cada fila los pies en la MISMA línea. Si hay dos filas, deja una franja
> horizontal VACÍA entre ellas: nada de la fila de arriba puede tocar la de
> abajo. Personaje completo en cada frame con margen (nada cortado
> por el borde). Deja espacio VACÍO claro entre personaje y personaje: las
> agujas de frames vecinos NUNCA deben tocarse ni traslaparse. Ojo con
> los frames de aguja EXTENDIDA al frente: entre la PUNTA de una aguja y el
> siguiente personaje debe quedar MÍNIMO medio cuerpo de espacio vacío.
> ANATOMÍA correcta: exactamente DOS brazos, DOS piernas, DOS manos de 5 dedos
> y EXACTAMENTE DOS agujas (una por mano) — ni una aguja de más ni de menos,
> nunca tres o cuatro agujas, nunca una sola. Cada aguja es una pieza continua
> sujeta por su anilla en la mano: nunca fragmentada, nunca tirada en el piso ni
> bajo los pies. Cada frame es UN solo personaje completo — jamás dos poses
> pegadas o fusionadas dentro del mismo frame.
> La gabardina azul mantiene su borde inferior NORMAL y limpio, exactamente
> como en la referencia: NO la dibujes rasgada, rota ni hecha jirones.
> Fondo VERDE PURO #00FF00 completamente plano y SIN NINGUNA marca: no
> pongas números, letras, rótulos ni líneas guía en la hoja — solo los
> personajes sobre el verde. Sin sombra en el piso. Sin desenfoque ni
> líneas de velocidad.

Guarda cada hoja en `imagen-action/favi/sheets/` con el nombre indicado.

**Nitidez:** mientras menos frames por FILA, más grande y nítido sale cada
personaje. Para animaciones largas usa DOS FILAS en la misma hoja (mi
procesador las lee solo: fila de arriba primero, de izquierda a derecha), o
divide en dos hojas: `walk-sheet.png` y `walk-sheet-2.png` — también las
une solo. Ambas cosas a la vez funcionan.

**Frames rebeldes:** si un frame concreto sale mal una y otra vez (pose de
espaldas, agujas quietas, tres agujas, etc.), deja de pedir la secuencia
completa: pide ESE frame SOLO, en su propia hoja de UN personaje, con
descripción hiperdetallada y prohibiciones explícitas. Nómbrala
`<accion>-f<numero>-sheet.png` (ej. `crouch-kick-f3-sheet.png`). Con un
solo personaje por imagen la IA obedece mucho mejor, y yo empalmo el frame
nuevo con los buenos de la hoja anterior (mi procesador escala frames
sueltos por masa corporal para que encajen).

---

## Las 17 hojas que necesitamos

### Básicas (empezar por estas 4)

1. **`pose-sheet.png`** — 4 frames. Postura de guardia de esgrima DUAL: una
   aguja al frente (mano adelantada) apuntando al rival, la otra recogida junto
   a la cadera lista. Respiración sutil: el pecho sube y baja, el brillo azul de
   las puntas varía apenas de intensidad. El loop debe cerrar (frame 4 conecta
   con frame 1).

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
   - f1: la POSE DE GUARDIA exacta (la misma de pose-sheet): agujas listas
     frente al cuerpo. NO una postura relajada de pie con los brazos colgando
   - f2: TRANSICIÓN visible: el torso empieza a girar y las dos agujas se
     recogen CRUZADAS sobre el pecho en X (cargando la tijera), a medio camino
   - f3: carga: las agujas totalmente cruzadas y recogidas contra el pecho, los
     codos atrás, horizontal
   - f4: carga MÁXIMA: torso girado, brazos comprimidos, las dos agujas listas
     para abrirse y barrer
   - f5: el barrido arranca: los brazos empiezan a abrirse, las agujas entran
     al frente todavía cerca del cuerpo, hojas horizontales
   - f6: a medio camino: las dos hojas cruzan por DELANTE del pecho abriéndose
     hacia afuera, horizontales, el torso desenroscándose
   - f7: IMPACTO — las dos agujas COMPLETAMENTE extendidas al frente cruzándose
     en TIJERA a la altura del pecho, brazos estirados, torso girado
   - f8: follow-through: las hojas siguen de largo apenas pasadas del frente,
     el torso acompaña el giro
   - f9: desaceleración: las agujas frenando y regresando hacia el cuerpo
   - f10: regresa a la POSE DE GUARDIA exacta del f1 (el golpe abre y cierra en
     guardia). NO termina de pie relajado
     Las dos agujas deben estar en una POSICIÓN CLARAMENTE DISTINTA en cada
     frame, avanzando de forma PAREJA por el arco: entre frame y frame las hojas
     se mueven más o menos la misma distancia, sin saltos bruscos.

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

9. **`jump-punch-sheet.png`** — 4 frames. Corte aéreo doble: en el aire, doble
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

13. **`strong-fly-sheet.png`** — 9 frames. Golpe fuerte que la manda a volar:
    frames 1-4 volando hacia atrás por los aires (cuerpo arqueado, pies
    despegados), frames 5-7 estrellándose y rodando por el piso, frames 8-9
    incorporándose hasta quedar en una rodilla. Las dos agujas flojas, sujetas
    por la anilla, arrastrando.

### Defensa

14. **`block-sheet.png`** — 1 frame. Bloqueo de pie: cubierta con las dos
    agujas CRUZADAS en X frente al cuerpo (guardia de tijera), postura firme.

15. **`block-low-sheet.png`** — 1 frame. Bloqueo agachado: en CUCLILLAS
    PROFUNDAS, cuerpo COMPACTO y encogido (cabeza baja, a la misma altura
    que la postura agachada normal — NO erguida, NO de rodillas con el
    torso vertical), cubriéndose con las dos agujas CRUZADAS en HORIZONTAL por
    encima de la cabeza, como un techo. Las hojas NO apuntan al cielo.

### Final de ronda

16. **`ko-sheet.png`** — 5 frames. Derrota: tambalea → cae de rodillas →
    se desploma → tendida en el piso boca arriba → inmóvil (las dos agujas
    apagadas a su lado). El último frame se queda en pantalla.

17. **`victory-sheet.png` + `victory-sheet-2.png`** — 8 frames en total
    (4 por hoja). Victoria, guardando las dos agujas — cada frame una
    posición claramente distinta:
    - f1: baja la guardia, las dos agujas sueltas a los costados
    - f2: hace un FLORISH: gira las dos agujas hacia arriba, en diagonal
    - f3: las dos agujas COMPLETAMENTE arriba, brazos estirados, pose triunfal,
      las puntas al máximo brillo azul
    - f4: mantiene el triunfo, cabeza en alto (ligera variación del f3)
    - f5: baja las agujas a los costados, empezando a guardarlas
    - f6: mete las dos agujas en las presillas/correas de su abrigo, a medio
      camino, el brillo apagándose
    - f7: agujas guardadas por completo, las manos sueltas
    - f8: postura final relajada, una mano en el bolsillo, el dije de balón
      colgando. Este frame se queda en pantalla.

---

## Golpes especiales

18. **`spin-kick-sheet.png`** — 8 frames en DOS FILAS de 4. PATADA
    GIRATORIA que avanza (estilo tatsumaki): FAVI gira 360° sobre su eje
    con una pierna extendida horizontal. EXCEPCIÓN ÚNICA a la regla de
    perfil: como el personaje ROTA, los frames intermedios sí la muestran
    de frente y de espaldas según el punto del giro. IMPORTANTE: aunque en
    el juego el movimiento viaja hacia adelante, dibuja TODOS los frames
    EN EL MISMO SITIO (pies/cadera sobre la misma vertical) — el
    desplazamiento lo hace el motor:
    - f1: agazapada en perfil (derecha), brazos recogidos, las dos agujas
      pegadas al cuerpo — cargando el giro
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
      Las dos agujas permanecen EN LAS MANOS, pegadas al cuerpo, durante todo el
      giro — nunca se sueltan ni desaparecen.

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

24. **`sweep-sheet.png` + `sweep-sheet-2.png`** — 6 frames en DOS hojas de
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

25. **`wall-bounce-sheet.png`** — 6 frames. VUELO RECTO Y ESTRELLÓN
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

26. **`pummeled-sheet.png`** — 4 frames (loop). FAVI SIENDO MACHACADA de
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

27. **`flame-cast-sheet.png`** — 5 frames. FAVI LANZA LA TORMENTA DE AGUJAS
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

- `needle-dash-sheet.png` — dash veloz dejando estela azul de agujas
- `needle-storm-burst-sheet.png` — super ataque en área (lluvia de agujas)
- `intro-sheet.png` — entrada al escenario antes del Round 1

## Recordatorios

- Genera TODO en la misma conversación con tu IA, siempre adjuntando la
  referencia de FAVI. Si un frame sale con otros colores, con una katana, con
  una sola aguja o con agujas de más, repítelo antes de guardar la hoja.
- Yo recorto el verde, alineo y conecto cada hoja — tú solo avísame cuál está.
- Frames finales: los genero yo en `imagen-action/favi/` como `favi-[accion]-N.png`.
- El moveset, los conteos de frames y los timings son EXACTAMENTE los de DAM
  (ver `GUIA-SPRITES.md` y `GUIA-COMUN.md`). Si algo no cuadra, manda la de DAM.
