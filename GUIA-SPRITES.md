# DAM — The Flame Wielder · Guía de sprites (personaje)

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

7. **`crouch-kick-sheet.png`** — 5 frames. GANCHO ASCENDENTE (anti-aéreo,
   estilo uppercut de arma pesada): un corte que arranca cargado abajo y
   termina con la katana arriba tras la espalda. Los pies SIEMPRE tocan el
   piso (NO es un salto):
   - f1: CARGA — en cuclillas profundas, el torso volcado sobre la rodilla
     delantera, la katana agarrada con AMBAS manos AL FRENTE del cuerpo
     con la hoja apuntando hacia el PISO (cargando el golpe, como un
     leñador a punto de arrancar el hacha del suelo)
   - f2: el swing arranca POR ABAJO: aún agachado, la katana barre hacia
     abajo y atrás pasando RASANTE junto a sus piernas, la hoja cerca
     del piso
   - f3: IMPACTO — el corte SUBE: los brazos ESTIRADOS hacia
     adelante-arriba con la katana EN PLENO BARRIDO frente al cuerpo
     (hoja en diagonal ascendente, la punta a la altura de la cabeza),
     el torso inclinado HACIA ADELANTE levantándose en zancada — se debe
     ver que la espada va EN MOVIMIENTO hacia arriba, NO es una pose de
     guardia sostenida. Vista LATERAL, perfil hacia la derecha
   - f4: REMATE — el cuerpo ya levantado en zancada (ambos pies firmes en
     el piso), la katana terminó el arco: quedó ARRIBA y por DETRÁS del
     hombro, los brazos cruzados por encima de la cabeza en el
     follow-through. SIEMPRE de PERFIL mirando a la derecha (se le ve la
     cara de lado) — NUNCA de espaldas a la cámara
   - f5: recogida: baja la katana y vuelve a las cuclillas del f1
     El arco completo de la hoja: frente-abajo → rasante atrás → subiendo
     al frente → arriba tras el hombro. Posición CLARAMENTE distinta de la
     hoja en cada frame.

   **Los f3 y f4 salen mal en secuencia (la IA los pone de espaldas o con
   la espada quieta). Pedirlos SUELTOS, un personaje por hoja:**

   `crouch-kick-f3-sheet.png` (un solo frame):

   > UN SOLO personaje, frame único. DAM de PERFIL mirando a la DERECHA
   > (se ve su mejilla y ojo derechos, el pecho apunta a la derecha). En
   > zancada baja: rodilla delantera flexionada, pierna trasera estirada,
   > torso inclinado HACIA ADELANTE. Los DOS brazos lanzados hacia
   > adelante-arriba, estirados, sujetando la katana en DIAGONAL
   > ASCENDENTE: la empuñadura a la altura del pecho y la PUNTA de la
   > hoja a la altura de los ojos, apuntando arriba-adelante. Es el
   > momento EXACTO de un corte hacia arriba en movimiento — cuerpo
   > tenso, abrigo volando hacia atrás. PROHIBIDO: pose simétrica de
   > frente, pose de espaldas, espada en vertical de guardia.

   `crouch-kick-f4-sheet.png` (un solo frame):

   > UN SOLO personaje, frame único. de PERFIL mirando a la DERECHA —
   > su CARA VISIBLE de lado (mejilla y ojo derechos). REGLA: si se ve el
   > logo del lobo de la espalda del abrigo, el frame está MAL — la
   > espalda NUNCA apunta a la cámara. De pie en zancada (ambos pies en
   > el piso), los dos brazos CRUZADOS por ENCIMA de la cabeza en
   > follow-through: la katana ya terminó el corte y apunta hacia
   > ATRÁS-ARRIBA por detrás de su hombro. El pecho y la cadera
   > orientados hacia la derecha, abrigo asentándose tras el movimiento.

### Salto

8. **`jump-sheet.png`** — 4 frames. Salto vertical: impulso (rodillas
   flexionadas) → subiendo (cuerpo estirado) → punto más alto → cayendo.

9. **`jump-punch-sheet.png`** — 4 frames. Corte aéreo: en el aire, corte de
   katana al frente: preparación → corte → extendido → recogida (sigue en el aire).

10. **`jump-kick-sheet.png`** — 3 frames. Ataque aéreo descendente: en el
    aire, corte o patada en diagonal hacia abajo: preparación → extensión → sostenido.

### Recibir daño

11. **`take-hit-sheet.png`** — 4 frames. Golpeado de pie: impacto en el
    rostro/pecho, cabeza hacia atrás, retrocede encorvado, casi recupera guardia.

12. **`take-hit-low-sheet.png`** — 2 frames. Golpeado estando agachado: se
    encoge por el impacto sin levantarse → casi recupera la postura agachada.

13. **`strong-fly-sheet.png`** — 9 frames. Golpe fuerte que lo manda a volar:
    frames 1-4 volando hacia atrás por los aires (cuerpo arqueado, pies
    despegados), frames 5-7 estrellándose y rodando por el piso, frames 8-9
    incorporándose hasta quedar en una rodilla.

### Defensa

14. **`block-sheet.png`** — 1 frame. Bloqueo de pie: cubierto con la katana
    en vertical frente al cuerpo (o antebrazos cruzados), postura firme.

15. **`block-low-sheet.png`** — 1 frame. Bloqueo agachado: en CUCLILLAS
    PROFUNDAS, cuerpo COMPACTO y encogido (cabeza baja, a la misma altura
    que la postura agachada normal — NO erguido, NO de rodillas con el
    torso vertical), cubriéndose con la katana en posición HORIZONTAL por
    encima de la cabeza, como un techo. La hoja NO apunta al cielo.

### Final de ronda (¡nuevas — completan el juego!)

16. **`ko-sheet.png`** — 5 frames. Derrota: tambalea → cae de rodillas →
    se desploma → tendido en el piso boca arriba → inmóvil (la katana
    apagada a su lado). El último frame se queda en pantalla.

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

20. **`air-spin-kick-sheet.png`** — 8 frames en DOS FILAS de 4. SALTO
    MORTAL HACIA ADELANTE con remate de patada (para usar en el aire):
    DAM gira de cabeza a pies EN EL PLANO DE LA PANTALLA (voltereta
    frontal, como una rueda que avanza) y termina lanzando una patada
    diagonal. TODOS los frames en vista de PERFIL (la voltereta rota el
    cuerpo, no la cámara — siempre se le ve el costado derecho). Dibuja
    todos los frames EN EL MISMO SITIO y a la MISMA escala — el vuelo lo
    pone el motor. La katana va EN LA MANO, pegada al cuerpo, todo el giro:
    - f1: en el aire, encogiéndose: rodillas al pecho, el cuerpo empieza
      a rotar hacia adelante (cabeza inclinándose adelante)
    - f2: rotado ~90°: cuerpo HORIZONTAL en bola, cabeza apuntando hacia
      adelante, espalda arriba
    - f3: INVERTIDO (~180°): completamente boca abajo, en bola, la cabeza
      apuntando al piso
    - f4: rotado ~270°: la cabeza apunta hacia atrás-abajo, el cuerpo
      empieza a abrirse
    - f5: la voltereta termina: el cuerpo casi vertical otra vez, la
      pierna derecha empezando a lanzarse hacia adelante
    - f6: PATADA — pierna derecha COMPLETAMENTE extendida en diagonal
      hacia abajo-adelante, torso ligeramente inclinado atrás, el remate
      del mortal
    - f7: sostiene la patada con leve variación (el impulso del golpe)
    - f8: recoge la pierna, postura de caída en el aire (brazos
      equilibrando)

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

    KATANA (regla fija en los 6 frames): **una sola mano floja** sujeta SOLO el
    **mango por el extremo**; el brazo cuelga muerto y la **hoja apunta hacia
    abajo-atrás, arrastrada**. PROHIBIDO: dos manos, agarrarla por la hoja,
    levantarla o cualquier pose de ataque.

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

30. **`fire-wave-sheet.png`** — 6 frames (loop). PROYECTIL DE FUEGO que
    viaja (el INFIERNO). SOLO el fuego, sin personaje. Fondo verde puro
    #00FF00. Estilo cel-anime: VÓRTICE/ola de fuego girando, núcleo
    blanco-amarillo ardiente, cuerpo naranja, bordes de línea definidos,
    con esquirlas y chispas saltando. Apunta/avanza hacia la DERECHA
    (yo lo espejo). Los 6 frames son el mismo vórtice GIRANDO en su sitio
    (loop) para que se vea vivo mientras viaja:
    - f1-f6: el remolino de llamas rota, las lenguas de fuego se enroscan
      y se estiran, chispas orbitando. El f6 conecta con el f1 (loop).
      Centrado en el mismo punto en los 6 frames.

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
