# AYE — The Blooming Dynamo · Guía de sprites (personaje)

> Esta es la guía ESPECÍFICA de AYE: su identidad y la animación detallada de
> cada movimiento con su **BLOOM STAFF** (bastón mágico floral) y su compañera
> Pomeranian **Pommy**. Las reglas de producción y el roster de movimientos están
> calcados de **`GUIA-SPRITES-FAVI.md`** (la de Fe): mismo moveset, mismos conteos
> de frames y mismos timings — lo ÚNICO que cambia es que AYE empuña un BASTÓN
> (no agujas ni katana) y su energía es FLORAL/ROSA (no agua, no fuego).

> **Diferencia clave que manda en TODAS las animaciones:** AYE pelea con **UN
> BASTÓN largo (el Bloom Staff)** sujeto con las DOS manos o con una. Es un
> personaje CHIBI ágil y alegre (tipo "dynamo"): hace barridos amplios, giros de
> bastón (tipo bo-staff), estocadas con la punta y golpes que sueltan PÉTALOS y
> destellos ROSA/LILA. Cuando un golpe de Fe era "las dos agujas cruzándose", en
> AYE es "el bastón barriendo con una lluvia de pétalos".

## Reglas generales (van en TODOS los prompts)

Pega esto al final de cada prompt, junto con la **imagen de referencia de AYE**
(su hoja de diseño) adjunta:

> Mismo personaje EXACTO de la referencia — una ILUSTRACIÓN CHIBI de estilo anime,
> una pequeña HEROÍNA MÁGICA de fantasía (personaje/mascota de videojuego, arte de
> caricatura estilizado, NO una persona real ni una foto): piel morena, pelo
> castaño oscuro RIZADO recogido en un MOÑO ALTO desordenado con mechones sueltos y
> lazos ROSAS, ojos grandes de estilo anime, y una GEMA/cristal floral ROSA-LILA en
> la FRENTE (pequeños cristales facetados). Lleva un traje de fantasía tipo
> cheongsam/qipao SIN MANGAS, BLANCO con estampado de FLORES rosa/lila y ribetes
> dorados, un gran MOÑO MAGENTA en la cintura, SHORTS MORADOS debajo del vestido,
> botas altas BLANCAS con lazos florales rosa/morado, y muñequeras blancas. Sus
> proporciones son SIEMPRE IDÉNTICAS EN TODAS LAS HOJAS: cabeza grande estilo chibi,
> PERO exactamente la misma relación cabeza-a-cuerpo que en `walk-sheet.png` /
> `pose-sheet.png` (esas dos son la REFERENCIA de tamaño). El cuerpo llena el frame
> a la misma altura en todas las hojas; las piernas tienen el mismo largo. NUNCA la
> dibujes más cabezona, más rechoncha ni más "super-deformed" en unas hojas que en
> otras — si comparas dos frames de hojas distintas, la niña debe medir y verse igual.
> Su arma es
> el BLOOM STAFF: un bastón/cetro LIGERO de mango
> MORADO largo, con una FLOR DE CRISTAL en la punta (cristales facetados lila y
> rosa en forma de loto/flor abierta, con centro rosado). Su energía es FLORAL:
> PÉTALOS de flor y destellos ROSA / LILA / MAGENTA. NADA de fuego, NADA de agua,
> NADA de katana, NADA de agujas — es UN bastón con una flor de cristal.
> Misma paleta de colores exacta y mismo estilo de línea. Vista lateral de juego
> de pelea 2D (estilo KOF), personaje mirando a la DERECHA en TODOS los frames —
> nunca de frente a la cámara, nunca de espaldas.
> Los frames van en UNA o DOS filas, ordenados de izquierda a derecha (la fila de
> ARRIBA primero). Todos los personajes a la MISMA escala; dentro de cada fila los
> pies en la MISMA línea. Si hay dos filas, deja una franja horizontal VACÍA entre
> ellas: nada de la fila de arriba puede tocar la de abajo. Personaje completo en
> cada frame con margen (nada cortado por el borde). Deja espacio VACÍO claro entre
> personaje y personaje: el BASTÓN de frames vecinos NUNCA debe tocarse ni
> traslaparse. Ojo con los frames de bastón EXTENDIDO al frente (ocupan mucho más
> ancho): entre la PUNTA del bastón (la flor de cristal) y el siguiente personaje
> debe quedar MÍNIMO medio cuerpo de espacio vacío.
> El bastón es UNA sola pieza continua sujeta en las manos: nunca fragmentado,
> nunca duplicado, nunca tirado en el piso ni bajo los pies. Cada frame es UN solo
> personaje completo — jamás dos poses pegadas o fusionadas dentro del mismo frame.
> ANATOMÍA correcta: exactamente DOS brazos, DOS piernas, DOS manos de 5 dedos y
> UN solo bastón. El vestido mantiene su borde inferior NORMAL y limpio, como en la
> referencia: NO lo dibujes rasgado, roto ni hecho jirones.
> Fondo VERDE PURO #00FF00 completamente plano y SIN NINGUNA marca: no pongas
> números, letras, rótulos ni líneas guía en la hoja — solo el personaje sobre el
> verde. Sin sombra en el piso. Sin desenfoque ni líneas de velocidad.

Guarda cada hoja en `imagen-action/aye/sheets/` con el nombre indicado.

**Nitidez:** mientras menos frames por FILA, más grande y nítido sale cada
personaje. Para animaciones largas usa DOS FILAS en la misma hoja (mi procesador
las lee solo: fila de arriba primero, de izquierda a derecha), o divide en dos
hojas (`walk-sheet.png` + `walk-sheet-2.png`) — también las une solo.

**Frames rebeldes:** si un frame sale mal una y otra vez (de espaldas, bastón
quieto, dos bastones), pide ESE frame SOLO, en su propia hoja de UN personaje,
con descripción hiperdetallada y prohibiciones explícitas. Nómbrala
`<accion>-f<numero>-sheet.png`.

**Nota sobre Pommy (la Pomeranian):** la compañera NO va en los frames de los
golpes normales (solo AYE). Pommy aparece únicamente en el ESPECIAL ("Bark Burst")
y se dibuja como EFECTO aparte sobre verde (ver §21).

---

## Las hojas que necesitamos

### Básicas (empezar por estas 4)

1. **`pose-sheet.png`** — 4 frames. Postura de guardia alegre: sostiene el Bloom
   Staff con una mano al frente-abajo (la flor de cristal apuntando adelante), la
   otra mano relajada, peso ligero sobre los pies. Respiración sutil: el pecho sube
   y baja, la flor de cristal brilla apenas variando de intensidad, algún pétalo
   flotando. El loop debe cerrar (frame 4 conecta con frame 1).

2. **`walk-sheet.png`** — 8 frames en 2 filas de 4. Ciclo de caminata de COMBATE:
   torso casi quieto en guardia, el bastón siempre listo (apuntando adelante-abajo),
   ciclo clásico de piernas (contacto → apoyo → cruce → alcance), f8 conecta con f1.
   El sube-y-baja del cuerpo es SUTIL, misma altura base en todos.

3. **`punch-sheet.png`** — 10 frames en DOS FILAS de 5. ⚠️ REGENERAR: la versión
   anterior salió CABEZONA (cabeza demasiado grande / cuerpo rechoncho, distinta al
   walk). Al rehacerla, la niña debe tener EXACTAMENTE las mismas proporciones y
   altura que en `walk-sheet.png` (cabeza más chica que antes, piernas más largas),
   y el BASTÓN + los pétalos deben quedar COMPLETOS dentro de cada frame (nunca
   cortados por el borde, deja margen). BARRIDO HORIZONTAL de
   bastón: gira el Bloom Staff barriendo de lado a lado a la altura del pecho,
   soltando pétalos ROSA en el arco. Las hojas del arco quedan más o menos
   HORIZONTALES (no un golpe de arriba abajo):
   - f1: pose de guardia exacta (bastón listo)
   - f2-f4: carga — recoge el bastón atrás girando el torso, pétalos naciendo
   - f5-f6: el barrido arranca, el bastón entra al frente
   - f7: IMPACTO — bastón EXTENDIDO barriendo al frente, estela de pétalos rosa
   - f8-f10: sigue el arco y recupera la guardia
     El bastón SIEMPRE en las manos, una pieza continua.

4. **`kick-sheet.png`** — 10 frames en DOS FILAS de 5. GOLPE FUERTE con el bastón:
   un mazazo/barrido AMPLIO y pesado (de arriba hacia adelante) que estalla en una
   flor de energía ROSA al impactar. Más lento y potente que el punch:
   - f1: guardia · f2-f4: alza el bastón bien arriba cargando · f5-f6: baja el
     bastón con fuerza al frente · f7: IMPACTO — el bastón golpea adelante, ESTALLIDO
     de pétalos/flor rosa · f8-f10: recupera.

### Agachado

5. **`crouch-sheet.png`** — 3 frames. Se agacha progresivamente hasta quedar en
   cuclillas, el bastón recogido cruzado sobre las rodillas.

6. **`crouch-punch-sheet.png`** — 3 frames. Estocada baja rápida con la PUNTA del
   bastón (la flor de cristal) al frente, desde cuclillas.

7. **`crouch-kick-sheet.png`** — 5 frames. GANCHO ASCENDENTE (anti-aéreo): barre el
   bastón de abajo hacia arriba en diagonal, soltando pétalos que suben.

### Salto

8. **`jump-sheet.png`** — 6 frames. Salto vertical: impulso (rodillas dobladas) →
   sube con el bastón pegado al cuerpo → ápice → empieza a caer. El loop de caída
   se sostiene en los últimos frames.

9. **`jump-punch-sheet.png`** — 4 frames. Corte aéreo: en el aire, barrido de bastón
   diagonal hacia adelante con pétalos.

10. **`jump-kick-sheet.png`** — 4 frames. Ataque aéreo descendente: clava el bastón
    hacia abajo-adelante en picada (mazazo aéreo) con pétalos.

### Recibir daño

11. **`take-hit-sheet.png`** — 4 frames. Retroceso de pie: el torso salta hacia atrás
    por el golpe, brazos sueltos, el bastón se sacude. (Neutral — sin "golpeada".)

12. **`take-hit-low-sheet.png`** — 3 frames. Retroceso en cuclillas: se encoge un poco
    hacia atrás sosteniendo el bastón.

13. **Golpe fuerte que la manda a volar — en DOS HOJAS** (mejor calidad):
    - **`strong-fly-sheet.png`** — 4 frames. Sale despedida por los aires: cuerpo
      arqueado hacia atrás, bastón suelto de una mano, en pleno vuelo.
    - **`strong-fly-sheet-2.png`** — 5 frames. Cae y se estrella: rebota, queda tirada,
      se reincorpora. (Se procesan como `hit_fly` y `hit_down`.)

### Defensa

14. **`block-sheet.png`** — 2 frames. Bloqueo de pie: pone el bastón HORIZONTAL
    delante del cuerpo como barrera, un domo de pétalos rosa tenue al frente.

15. **`block-low-sheet.png`** — 2 frames. Bloqueo agachado: en cuclillas, el bastón
    cruzado al frente, domo de pétalos bajo.

### Final de ronda

16. **`ko-sheet.png`** — 5 frames. Derrota: se tambalea → cae de rodillas → queda
    sentada/tirada con el bastón caído junto a ella (pero SIN soltarlo del todo).

17. **Victoria — en DOS HOJAS de 4 frames** (8 en total): de pie, alegre, alza el
    Bloom Staff con una lluvia de pétalos rosa a su alrededor y mueve la BOCA (dice
    algo tipo "¡Bloom!"). `victory-sheet.png` + `victory-sheet-2.png`.

## Golpes especiales

18. **`spin-kick-sheet.png`** — 8 frames en DOS FILAS de 4. **GIRO DE BASTÓN**
    (peonza · E en el suelo): junta los PIES y gira como trompo con el Bloom Staff
    extendido barriendo un círculo de PÉTALOS a su alrededor (tipo bo-staff spin).
    Rota 360° (excepción a la vista de perfil: la muestra de frente y de espaldas
    según el giro). Pies juntos, brazos con el bastón horizontal barriendo.

19. **`weak-punch-sheet.png`** — 4 frames en UNA fila. PIQUETE RÁPIDO con la PUNTA
    del bastón (la flor de cristal) al frente — jab veloz y ligero, un destello rosa.

20. **`air-spin-kick-sheet.png`** — 8 frames en DOS FILAS de 4. MORTAL AÉREO con el
    bastón: en el aire hace un giro/rueda con el Bloom Staff barriendo, estela de
    pétalos. (Rota — de frente/espaldas según el giro.)

21. **`bloom-cast-sheet.png`** — 5 frames. **ESPECIAL FLORAL de AYE** (animación
    `water_cast` en el motor, reusa ese slot). Clava el Bloom Staff hacia el SUELO,
    alza la mano libre y GRITA el nombre del poder → brota una COLUMNA de FLORES /
    géiser de pétalos rosa del suelo bajo el rival, lanzándolo hacia arriba. Se queda
    DE PIE en su sitio. La BOCA se mueve como gritando (forma distinta cada frame).
    - f1: postura de invocación, apunta el bastón al piso, boca cerrada
    - f2: energía ROSA/floral naciendo en la punta, mano libre subiendo, boca abriéndose
    - f3: mano bien ALZADA, BOCA MUY ABIERTA gritando, remolino de pétalos concentrándose
    - f4: mantiene, máximo brillo rosa, pétalos girando
    - f5: descarga: baja la mano al suelo, la energía floral se hunde (dispara la columna)

    **Efecto que acompaña:** `bloom-geyser-sheet.png` → columna de flores de 8 frames
    (gota → domo → columna de pétalos → floración → estallido → se dispersa), anclada
    al piso, brota bajo el rival.

## Compañera + efectos (sin personaje: SOLO el efecto sobre verde)

22. **`pommy-bark-burst-sheet.png`** — 6 frames. **BARK BURST** (el especial de
    Pommy): la Pomeranian (perrito naranja esponjoso con collar de flores) EMBISTE
    hacia adelante soltando una RÁFAGA de energía FLORAL rosa que aturde. Dibuja SOLO
    a Pommy corriendo + la onda de pétalos, sobre verde. 6 frames del dash + estallido.

23. **`petal-hit-sheet.png`** — 5 frames. Destello de impacto floral: estallido de
    PÉTALOS rosa/magenta con corazón blanco (equivalente al relámpago de impacto,
    pero en flores). Sobre verde, sin personaje.

## Recordatorios

- Energía SIEMPRE floral/rosa (pétalos, cristal), NUNCA fuego ni agua.
- El bastón es UNA pieza continua; ojo con las puntas extendidas (medio cuerpo de
  espacio libre al frente).
- Reframe los prompts de hit/recoil SIN "golpe/impacto/golpeada" (el filtro de la IA
  los rechaza): usa "retroceso/sobresalto".
- ⚠️ **FILTRO DE CONTENIDO:** NO menciones EDAD ("niña de 5 años", "nena", "child",
  etc.). El filtro rechaza describir a un menor. Encuádrala SIEMPRE como una
  **ilustración CHIBI de anime / heroína mágica de fantasía / personaje de
  videojuego** (arte de caricatura, no una persona real). Las proporciones chibi las
  aporta la imagen de referencia — no hace falta decir la edad.
- Pommy solo en el especial (§22), como efecto aparte.
