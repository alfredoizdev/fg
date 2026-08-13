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

6. **`crouch-punch-sheet.png`** — 3 frames. Corte rápido de katana desde la
   posición agachada, al frente y a media altura: carga → corte → recogida.

7. **`crouch-kick-sheet.png`** — **4 frames en 1 fila** (f1 f2 f3 f4 de izq→der).
   GANCHO ASCENDENTE (uppercut de arma pesada, anti-aéreo): un corte que arranca
   cargado ABAJO y termina con la katana ARRIBA tras el hombro. Es UN SOLO golpe.
   **TODO de PERFIL mirando a la DERECHA** — se ve su mejilla y ojo derechos, el
   pecho apunta a la derecha. **REGLA:** si se ve el logo del LOBO de la espalda del
   abrigo, el frame está MAL (la espalda NUNCA apunta a la cámara). Los pies SIEMPRE
   tocan el piso (NO es un salto). Fondo VERDE #00FF00. **Mismo tamaño de personaje
   en los 4 frames.** Katana bien AGARRADA (dedos cerrados en el mango), nunca suelta.
   - **f1 — CARGA:** en cuclillas profundas, torso volcado sobre la rodilla
     delantera, katana con AMBAS manos AL FRENTE, la hoja apuntando al PISO (cargando,
     como un leñador a punto de arrancar el hacha del suelo).
   - **f2 — CORTE (impacto):** en zancada baja (rodilla delantera flexionada, pierna
     trasera estirada), torso inclinado HACIA ADELANTE. Los DOS brazos lanzados hacia
     adelante-arriba, ESTIRADOS, katana en DIAGONAL ASCENDENTE: empuñadura a la altura
     del pecho, PUNTA de la hoja a la altura de los ojos, apuntando arriba-adelante.
     Es el momento EXACTO de un corte hacia arriba EN MOVIMIENTO (NO una guardia
     quieta), cuerpo tenso, abrigo volando hacia atrás.
   - **f3 — REMATE (follow-through):** ya de pie en zancada (ambos pies firmes en el
     piso), los dos brazos CRUZADOS por ENCIMA de la cabeza: la katana terminó el
     corte y apunta hacia ATRÁS-ARRIBA por detrás del hombro. Pecho y cadera hacia la
     derecha, abrigo asentándose tras el movimiento.
   - **f4 — RECOGIDA:** baja la katana y vuelve a las cuclillas del f1.

   El arco de la hoja debe quedar CLARAMENTE distinto en cada frame: al piso →
   diagonal subiendo al frente → arriba tras el hombro → bajando. PROHIBIDO: pose de
   frente simétrica, pose de espaldas, o la espada quieta en vertical de guardia.

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

23. **`crouch-jab-sheet.png`** — 4 frames. PINCHAZO BAJO (↓R): estocada
    corta y veloz con una mano desde la guardia agachada. TODO de perfil,
    pies plantados, altura agachada en los 4 frames:
    - f1: agachado de perfil, carga corta — la mano del arma retrocede
      junto a la cadera, la hoja apunta adelante-abajo
    - f2: ESTOCADA — brazo extendido, hoja horizontal a la altura de la
      espinilla, punta hacia adelante (dejar medio cuerpo de espacio
      libre delante para la hoja)
    - f3: sostiene la estocada con leve vibración del impacto
    - f4: recoge el brazo y vuelve a la guardia agachada
      El movimiento es PEQUEÑO y seco: no se levanta, no gira, no salta.

24. **`sweep-sheet.png`** — 6 frames. BARRIDO DERRIBADOR (↓E): corte
    amplio a RAS DEL PISO que cruza todo el frente, para tumbar al rival.
    TODO de perfil, agachado, pies plantados:
    - f1: carga — el torso gira levemente atrás, la katana cargada
      atrás-abajo con la punta casi tocando el piso detrás
    - f2: arranca el barrido — la hoja corta bajando, raspando el piso
      por detrás y por debajo
    - f3: PICO — la hoja COMPLETAMENTE extendida al frente a ras del
      piso, brazo estirado, el corte cruza todo el frente (dejar medio
      cuerpo de espacio libre delante para la hoja extendida)
    - f4: el arco continúa — la hoja sigue el barrido apenas subiendo,
      el torso gira con el impulso
    - f5: frenado — la hoja termina cruzada del otro lado del cuerpo,
      aún agachado
    - f6: vuelve a la guardia agachada
      NO es una patada: DAM barre con la katana. NO se pone de pie en
      ningún frame.

25. **`wall-bounce-sheet.png`** — EXACTAMENTE **6 frames** en **2 filas de 3**
    (fila de arriba = f1 f2 f3 de izq→der; fila de abajo = f4 f5 f6 de izq→der).
    Fondo VERDE puro #00FF00. Personaje SIEMPRE de **perfil mirando a la DERECHA**.
    **NO dibujes:** pared, piso, líneas de velocidad, polvo, chispas ni ningún
    efecto — SOLO el personaje flotando sobre el verde (la pared y el golpe los
    pone el motor). Los 6 frames al **MISMO tamaño de personaje** (misma escala).

    ESTADO: DAM está **NOQUEADO en el aire**, cuerpo de **muñeco de trapo** sin
    control, ojos cerrados/apretados, cara floja. NO hay ninguna pose de fuerza
    ni de ataque en NINGÚN frame.

    KATANA (regla fija en los 6 frames — SIEMPRE bien AGARRADA):
    - **La mano NUNCA la suelta.** En CADA UNO de los 6 frames se ven los
      **dedos cerrados envolviendo el mango**, la mano PEGADA al mango. La katana
      está SIEMPRE unida a la mano — PROHIBIDO que flote suelta, separada de la
      mano, o cayéndose aparte (esto pasa mucho, EVÍTALO en todos los frames).
    - La sujeta con **una sola mano** por el mango, con el brazo estirado **hacia
      ADELANTE** (en la dirección del vuelo/caída), de modo que la **hoja apunta
      hacia ADELANTE-abajo**, arrastrándose por DELANTE del cuerpo (no colgando
      recta hacia abajo ni hacia atrás).
    - PROHIBIDO: soltarla, que quede flotando separada de la mano, dos manos,
      agarrarla por la hoja, levantarla, o cualquier pose de ataque.

    La animación es UN SOLO movimiento continuo: **vuela horizontal → choca y se
    comprime → se despega cayendo de bruces.** Cada frame CONTINÚA el anterior.
    Piensa el ángulo del EJE del cuerpo (línea cabeza→pies) en cada frame:
    - **f1 — VUELO:** cuerpo **totalmente HORIZONTAL** (tumbado en el aire, eje
      cabeza→pies paralelo al piso). La ESPALDA va por delante, la cabeza cae
      hacia atrás, brazos y piernas arrastran hacia atrás, el abrigo ondea FUERTE
      hacia atrás. (Imagínalo acostado boca-arriba sobre una cama invisible.)
    - **f2 — VUELO 2:** igual de horizontal, leve balanceo de trapo (las piernas
      suben un poco y la cabeza baja un poco). Mismo cuerpo suelto.
    - **f3 — IMPACTO:** el cuerpo gira de golpe a **VERTICAL** y se **APLASTA de
      espaldas** contra una superficie invisible detrás: columna arqueada en "C"
      (hombros y cadera echados atrás), brazos y piernas **lanzados hacia
      ADELANTE** por la inercia, pelo y abrigo aplastados hacia adelante.
    - **f4 — REBOTE:** sigue casi vertical pero ya despegándose; la cabeza cae
      hacia adelante, hombros vencidos, brazos colgando muertos.
    - **f5 — DESPEGUE:** el cuerpo se inclina hacia adelante **~45°**, empezando a
      caer de bruces, extremidades colgando flojas.
    - **f6 — CAÍDA:** casi HORIZONTAL otra vez pero **boca abajo**, todo el cuerpo
      flojo cayendo, cabeza, brazos, piernas y abrigo colgando hacia abajo.

    TIP para que la AI lo respete: adjunta el model sheet de DAM como referencia,
    y si falla, genera SOLO la fila de arriba (f1-f3) y luego SOLO la de abajo
    (f4-f6) en dos pasadas — le cuesta menos 3 poses que 6 de una.

26. **`jump-dust-sheet.png`** — 6 frames. POLVO DE SALTO (anillo de
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

27. **`dash-smoke-sheet.png`** — 6 frames. RÁFAGA DE HUMO DE DASH/GOLPE.
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

28. **`pummeled-sheet.png`** — 4 frames (loop). DAM SIENDO MACHACADO de
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

29. **`flame-cast-sheet.png`** — 5 frames. DAM LANZA EL INFIERNO (crítico
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

30. **`fire-wave-sheet.png`** — 6 frames en 2 filas de 3. GRAN OLA DE FUEGO que
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
