# AYE — Crystal Witch (ZONER) · Guía de sprites

> Guía ESPECÍFICA de AYE, la 3ª peleadora. Es una **MAGA/WIZARD de LARGA DISTANCIA
> (ZONER)**: controla el espacio con **CRISTALES MORADOS** que brotan de su báculo
> de flor-de-cristal. Su firma es **CAPTURAR/CONGELAR** al rival encerrándolo en un
> cristal morado. Las reglas de producción (chroma verde, mirando a la derecha, un
> personaje por frame, etc.) siguen calcadas de `GUIA-SPRITES-FAVI.md`.

> **Lo que manda en TODAS sus animaciones:**
> 1. Empuña un **BÁCULO** (mango morado, flor de cristal rosa/magenta en la punta).
> 2. Su energía son **CRISTALES MORADOS/LILA** y destellos (NADA de fuego ni agua;
>    lo floral vive solo en la flor de cristal del báculo).
> 3. Es **ZONER**: su fuerte es a distancia (proyectiles, pilares, congelación). Su
>    cuerpo a cuerpo es **corto y débil A PROPÓSITO** — golpes de báculo solo para
>    empujar y ganar espacio, no para combos largos.

---

## Diseño de AYE (de la imagen de referencia #133 — es la CANÓNICA)

Pega esto en cada prompt, con la **imagen de referencia de AYE** adjunta:

> Mismo personaje EXACTO de la referencia — ILUSTRACIÓN CHIBI estilo anime, una
> pequeña MAGA de fantasía (personaje de videojuego, arte de caricatura estilizado,
> NO una persona real ni una foto): piel morena, pelo castaño oscuro RIZADO recogido
> en una **COLETA ALTA** con un **scrunchie ROSA** (mechones rizados sueltos), ojos
> grandes de estilo anime. Viste un **VESTIDO LILA/lavanda de MANGAS FAROL** (puff
> sleeves cortas), cuello cuadrado con **ribete DORADO**, un **MOÑO ROSA** grande en
> la cintura, una **enagua ROSA** que asoma bajo la falda, y el ruedo con ribete
> dorado. Calza **BOTAS DE LLUVIA de degradé** (de arriba a abajo: amarillo → rosa →
> celeste) con asas rosas. Su arma es un **BÁCULO/cetro** de mango MORADO largo y
> delgado, rematado en una **FLOR DE CRISTAL** (cristales facetados rosa/magenta en
> forma de loto abierto, con brillo). Sus proporciones son SIEMPRE IDÉNTICAS en TODAS
> las hojas: la MISMA relación cabeza-a-cuerpo y la misma altura que en
> `walk-sheet.png` / `pose-sheet.png` (esas dos mandan el tamaño). NUNCA la dibujes
> más cabezona ni más rechoncha en unas hojas que en otras. Su energía son CRISTALES
> MORADOS/LILA facetados y destellos magenta — NADA de fuego, NADA de agua, NADA de
> katana ni agujas: UN báculo con flor de cristal. Misma paleta y mismo estilo de
> línea exactos. Vista lateral de juego de pelea 2D (estilo KOF), personaje mirando a
> la DERECHA en TODOS los frames — nunca de frente ni de espaldas (salvo giros).
> Los frames van en UNA o DOS filas, de izquierda a derecha (fila de ARRIBA primero),
> pies en la misma línea dentro de cada fila. Si hay dos filas, deja una franja
> horizontal VACÍA entre ellas. Personaje completo en cada frame con margen (nada
> cortado por el borde). Deja espacio VACÍO claro entre personaje y personaje: el
> BÁCULO de frames vecinos NUNCA debe tocarse. En los frames de báculo EXTENDIDO al
> frente, deja MÍNIMO medio cuerpo de espacio vacío hasta el siguiente personaje.
> El báculo es UNA sola pieza continua en las manos: nunca fragmentado, duplicado ni
> tirado. Cada frame es UN solo personaje completo. ANATOMÍA correcta: DOS brazos,
> DOS piernas, DOS manos de 5 dedos y UN báculo. El vestido mantiene su borde inferior
> NORMAL y limpio (NO rasgado). Fondo VERDE PURO #00FF00 plano y SIN NINGUNA marca
> (sin números, letras ni líneas guía). Sin sombra en el piso. Sin desenfoque global
> ni líneas de velocidad (los smears van SOLO donde se indique, ver Fluidez).

Guarda cada hoja en `imagen-action/aye/sheets/` con el nombre indicado.

**Nitidez vs. fluidez:** menos frames por FILA = cada personaje sale más grande y
nítido. Para animaciones largas usa DOS FILAS (mi procesador las lee solo: arriba
primero) o dos hojas (`walk-sheet.png` + `walk-sheet-2.png`).

**Frames rebeldes:** si un frame sale mal repetido (de espaldas, báculo quieto, dos
báculos), pídelo SOLO en su propia hoja de un personaje, hiperdetallado.
Nómbrala `<accion>-f<numero>-sheet.png`.

---

## FLUIDEZ estilo SF3 (Dudley) — la clave para que se vea NÍTIDA y FLUIDA

Analizando los sprites de Dudley (SF3): lo que los hace fluidos NO es solo "más
frames", sino **keyframes correctos**. Aplicar a TODAS las hojas de acción:

1. **Idle vivo:** la pose NO es estática — respira/rebota (por eso "vive"). Aye:
   pecho sube/baja, cristal del báculo latiendo, algún cristalito flotando.
2. **Estructura de cada ataque:** *anticipación (1-2 frames, recoge/carga) → golpe
   con SMEAR (1 frame de estela en la parte más rápida) → IMPACTO/hold (1) →
   recuperación (1-2, vuelve a la guardia).* Nunca saltar de guardia a impacto directo.
3. **SMEAR:** en el frame más veloz, la punta del báculo (o el cristal) deja una
   **estela borrosa** en el arco del movimiento (mancha alargada semitransparente),
   como en SF3. Solo ESE frame lleva estela; los demás nítidos.
4. **Squash & stretch sutil:** en el impacto el cuerpo se comprime/estira un toque;
   al aterrizar de un salto, se achata un frame.
5. **Volumen y silueta CONSTANTES:** la niña mide y pesa igual en todos los frames;
   la pose se debe leer incluso en silueta negra.

---

## Las hojas BASE (empezar por estas)

1. **`pose-sheet.png`** — **6 frames** (subimos de 4 → 6 para el idle vivo, en 2
   filas de 3). Guardia de maga alegre: sostiene el báculo con una mano al
   frente-abajo (flor de cristal apuntando adelante), la otra mano relajada.
   Respiración: pecho sube/baja, la flor de cristal LATE (brillo variando), 1-2
   cristalitos flotando. El loop CIERRA (f6 conecta con f1).

2. **`walk-sheet.png`** — 8 frames en 2 filas de 4. Caminata de COMBATE: torso en
   guardia, báculo siempre listo, ciclo clásico de piernas (contacto → apoyo →
   cruce → alcance), f8 conecta con f1. Sube-y-baja SUTIL, misma altura base.

3. **`crouch-sheet.png`** — 3 frames. Se agacha hasta cuclillas, báculo recogido
   cruzado sobre las rodillas.

4. **`jump-sheet.png`** — 6 frames. Salto: impulso (rodillas dobladas + squash 1
   frame) → sube con el báculo pegado → ápice → cae. El loop de caída se sostiene.

### Cuerpo a cuerpo (CORTO y débil — es zoner)

5. **`weak-punch-sheet.png`** — 4 frames en 1 fila. Piquete rápido con la PUNTA del
   báculo (destello de cristal). Anticipación f1-2, SMEAR f3 (estela de la punta),
   recupera f4.

6. **`punch-sheet.png`** — **8 frames** en 2 filas de 4 (bajamos de 10 → 8 para que
   salgan más grandes; lo importante son los keyframes). BARRIDO corto de báculo a la
   altura del pecho, soltando ESQUIRLAS de cristal:
   - f1: guardia · f2-3: carga (recoge el báculo atrás, cristal cargando)
   - f4: **SMEAR** — el báculo barre al frente con estela borrosa
   - f5: IMPACTO — báculo extendido, estallido de cristales morados
   - f6-8: sigue el arco y recupera la guardia

7. **`kick-sheet.png`** — 8 frames en 2 filas de 4. Mazazo AMPLIO de báculo (de arriba
   al frente), más lento y pesado, estalla en una flor de cristal al impactar. Misma
   estructura (carga → smear f4 → impacto f5 → recupera).

8. **`crouch-punch-sheet.png`** — 3 frames. Estocada baja con la punta del báculo.

9. **`crouch-kick-sheet.png`** — 5 frames. GANCHO ASCENDENTE anti-aéreo: barre el
   báculo de abajo-arriba en diagonal, cristales que suben (smear en el frame medio).

10. **`jump-punch-sheet.png`** — 4 frames. Corte aéreo: barrido diagonal de báculo
    con esquirlas.

11. **`jump-kick-sheet.png`** — 4 frames. Picada aérea: clava el báculo hacia
    abajo-adelante.

### Recibir daño / defensa / final

12. **`take-hit-sheet.png`** — 4 frames. Retroceso de pie (sobresalto, torso atrás).
13. **`take-hit-low-sheet.png`** — 3 frames. Retroceso en cuclillas.
14. **Salir despedida — DOS hojas:** `strong-fly-sheet.png` (4f, vuela arqueada) +
    `strong-fly-sheet-2.png` (5f, cae/rebota/tirada). (→ `hit_fly` y `hit_down`.)
15. **`block-sheet.png`** — 2 frames. Báculo horizontal como barrera, domo de cristal
    tenue al frente. **`block-low-sheet.png`** — 2 frames, agachada.
16. **`ko-sheet.png`** — 5 frames. Se tambalea → cae de rodillas → queda sentada con
    el báculo caído al lado (sin soltarlo del todo).
17. **Victoria — DOS hojas de 4 frames:** de pie, alegre, alza el báculo con cristales
    girando y mueve la BOCA. `victory-sheet.png` + `victory-sheet-2.png`.

---

## KIT ZONER de CRISTAL (el corazón del personaje)

Estas son sus herramientas de LARGA DISTANCIA. La animación de AYE va en su hoja; el
CRISTAL/proyectil se dibuja como **efecto aparte** sobre verde (como los efectos de Fe).

18. **`crystal-cast-sheet.png`** — 6 frames (reusa el slot `water_cast` del motor).
    **DISPARO DE CRISTAL** (proyectil recto, su ataque principal a distancia):
    - f1: guardia · f2: apunta el báculo al frente, cristal cargando en la flor
    - f3: **BOCA gritando** el nombre, cristal al máximo brillo (anticipación)
    - f4: **SMEAR** — empuja el báculo al frente, el cristal SALE disparado
    - f5-6: recupera la guardia. Se queda DE PIE en su sitio.
    **Efecto:** `crystal-shard-sheet.png` — 4 frames del proyectil: una **esquirla/
    lanza de CRISTAL MORADO** facetada girando, con estela de destellos lila. Sobre
    verde, sin personaje (vuela horizontal).

19. **`crystal-pillar-cast-sheet.png`** — 5 frames. **PILAR DE CRISTAL** (zoning: clava
    un muro/columna de cristal del piso a 1/2/3 cuerpos de distancia, para cortar el
    acercamiento). Clava el báculo hacia el piso, boca gritando, energía morada bajando.
    Se queda de pie.
    **Efecto:** `crystal-pillar-sheet.png` — 6 frames de la columna (grieta → púa que
    crece → cristal alto facetado → destella → se agrieta → se disuelve), anclada al
    piso donde brota.

20. **`crystal-capture-sheet.png`** — 6 frames. **★ CAPTURA / CONGELACIÓN ★** (la
    FIRMA de Aye). Extiende el báculo al frente con las DOS manos, la flor de cristal
    disparando un haz morado; boca gritando; postura triunfal. Se queda de pie
    mientras el rival queda atrapado.
    - f1-2: alza y apunta el báculo, cristal cargando fuerte
    - f3: **BOCA MUY ABIERTA** gritando, haz de cristal saliendo de la flor
    - f4-6: mantiene el báculo extendido, cristales orbitando su punta
    **Efecto (va SOBRE el rival):** `crystal-prison-sheet.png` — 6 frames de un
    **cristal morado facetado ENCERRANDO** un hueco con forma de cuerpo (aparecen
    esquirlas → crece la prisión de cristal traslúcido morado → sellado brillante →
    se mantiene → grietas → estalla en esquirlas). Sobre verde, SIN personaje (es la
    jaula; en el motor se dibuja encima del rival "congelado").

21. **`crystal-rain-cast-sheet.png`** — 5 frames. **LLUVIA DE CRISTALES** (control
    aéreo/overhead): alza el báculo al cielo, la flor destella, invoca cristales que
    caen. Boca gritando.
    **Efecto:** `crystal-rain-sheet.png` — 6 frames de varias esquirlas de cristal
    cayendo en diagonal y estallando al tocar el piso. Sobre verde.

22. **`teleport-sheet.png`** — 4 frames. **DESTELLO DE CRISTAL** (escape del zoner:
    backdash/parpadeo corto): se disuelve en un estallido de esquirlas moradas y se
    rearma. f1: pose · f2: se fragmenta en cristales · f3: casi invisible (nube de
    esquirlas) · f4: reaparece en guardia. (Para el motor: retroceso rápido con i-frames.)

23. **`spin-kick-sheet.png`** — 8 frames en 2 filas de 4. **GIRO DE BÁCULO** (peonza,
    su reversal cercano): junta los pies y gira como trompo con el báculo barriendo un
    círculo de cristales. Rota 360° (excepción: se ve de frente/espaldas según el giro).

24. **`air-spin-kick-sheet.png`** — 8 frames en 2 filas de 4. Giro aéreo con el báculo
    barriendo, estela de cristales.

---

## Efectos de impacto (sin personaje: SOLO el efecto sobre verde)

25. **`crystal-hit-sheet.png`** — 5 frames. Destello de impacto: estallido de
    **esquirlas de CRISTAL morado/magenta** con corazón blanco (equivalente al
    relámpago de impacto). Sobre verde, sin personaje.

---

## Recordatorios

- Energía SIEMPRE **cristal morado/lila** (esquirlas, prisión, pilar), NUNCA fuego ni
  agua. Lo floral solo en la flor de cristal del báculo.
- El báculo es UNA pieza continua; ojo con las puntas extendidas (medio cuerpo de
  espacio libre al frente).
- Reframe los prompts de hit/recoil SIN "golpe/impacto/golpeada" (el filtro de la IA
  los rechaza): usa "retroceso/sobresalto".
- ⚠️ **FILTRO DE CONTENIDO:** NO menciones EDAD ("niña", "nena", "child", "5 años").
  El filtro rechaza describir a un menor. Encuádrala SIEMPRE como **ilustración CHIBI
  de anime / maga de fantasía / personaje de videojuego** (arte de caricatura, no una
  persona real). Las proporciones chibi las aporta la imagen de referencia.
- **Prioridad de producción:** 1) las 4 base (pose, walk, crouch, jump) para tenerla
  jugable, 2) el kit zoner (crystal-cast + crystal-shard, capture + crystal-prison,
  pillar), 3) el resto (hit/block/ko/victory + normales cortos).
