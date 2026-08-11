import { PNG } from '/Users/alfredoizquierdo/Desktop/apps/soccer/soccer-mobile-app/node_modules/pngjs/lib/png.js';
import fs from 'fs';

const FG = '/Users/alfredoizquierdo/Desktop/fg';
const CANVAS_W = 1300, CANVAS_H = 1280, FEET_Y = 1139, FEET_X = 650;
// Escala POR CARA (el tamaño de la cabeza es invariante a la pose): cada hoja se escala
// para que su cara mida TARGET_FACE px. Así Favi tiene la MISMA estatura en toda acción
// (parada, agachada, pateando) y las poses quedan proporcionales. Calibrado con walk.
let TARGET_FACE = 0;
let TARGET_AREA = 0;   // fallback si no se detecta cara
let TARGET_HEAD = 0;   // ANCHO DE CABEZA objetivo (px de salida) = el de walk.
// La cabeza es INVARIANTE a la pose (no se dobla como el cuerpo), así que
// escalar cada acción para que su cabeza mida TARGET_HEAD da la MISMA estatura
// real en toda pose (parada, agachada, etc). Este es el método por defecto.

// Ancho de cabeza desde la máscara (px de fuente): mide solo el tramo contiguo
// que pasa por la CORONILLA, así ignora brazos/piernas/agujas separados.
function headWmask(mask, W, miny) {
  const topXs = [];
  for (const v of mask) { const y = (v / W) | 0; if (y <= miny + 3) topXs.push(v - y * W); }
  if (!topXs.length) return 0;
  topXs.sort((a, b) => a - b);
  let mid = topXs[topXs.length >> 1];
  const has = (x, y) => mask.has(y * W + x);
  const ws = [];
  for (let y = miny + 8; y < miny + 68; y++) {
    let cx = Math.round(mid);
    if (!has(cx, y)) { let f = -1; for (let d = 1; d < 34; d++) { if (has(cx - d, y)) { f = cx - d; break; } if (has(cx + d, y)) { f = cx + d; break; } } if (f < 0) continue; cx = f; }
    let l = cx; while (l > 0 && has(l - 1, y)) l--;
    let r = cx; while (r < W - 1 && has(r + 1, y)) r++;
    ws.push(r - l); mid = (l + r) / 2;
  }
  if (!ws.length) return 0;
  ws.sort((a, b) => a - b); return ws[ws.length >> 1];
}
// mediana robusta de anchos de cabeza (descarta frames con la cabeza gacha/oculta)
function robustHead(cells) {
  const hs = cells.filter(c => c).map(c => c.headW).filter(x => x > 0).sort((a, b) => a - b);
  if (!hs.length) return 0;
  const m = hs[hs.length >> 1];
  const good = hs.filter(x => x >= 0.55 * m && x <= 1.8 * m);
  return good[good.length >> 1];
}

function chroma(p) {
  const out = new PNG({ width: p.width, height: p.height });
  for (let i = 0; i < p.data.length; i += 4) {
    const r = p.data[i], g = p.data[i + 1], b = p.data[i + 2];
    const green = g > 90 && g > r * 1.25 && g > b * 1.25;
    if (green) { out.data[i] = out.data[i+1] = out.data[i+2] = out.data[i+3] = 0; }
    else { let gg = g; if (g > r && g > b) gg = Math.max(r, b);
      out.data[i] = r; out.data[i+1] = gg; out.data[i+2] = b; out.data[i+3] = 255; }
  }
  return out;
}

function components(p, x0, x1, y0, y1) {
  const W = p.width, seen = new Int32Array((x1-x0)*(y1-y0));
  const idx = (x,y) => (y-y0)*(x1-x0)+(x-x0);
  const on = (x,y) => p.data[(y*W+x)*4+3] > 10;
  const comps = [], stack = [];
  for (let y=y0;y<y1;y++) for (let x=x0;x<x1;x++){
    if (!on(x,y) || seen[idx(x,y)]) continue;
    const px=[]; stack.length=0; stack.push(x,y); seen[idx(x,y)]=1; let area=0;
    while(stack.length){
      const cy=stack.pop(), cx=stack.pop(); px.push(cx,cy); area++;
      for(let dy=-1;dy<=1;dy++)for(let dx=-1;dx<=1;dx++){
        const nx=cx+dx,ny=cy+dy;
        if(nx<x0||nx>=x1||ny<y0||ny>=y1) continue;
        if(!seen[idx(nx,ny)] && on(nx,ny)){ seen[idx(nx,ny)]=1; stack.push(nx,ny); }
      }
    }
    comps.push({px,area});
  }
  return comps;
}

function detectFeet(mask, W, minx, maxx, maxy, MINW=22) {
  for (let y=maxy; y>=0; y--) { let w=0; for (let x=minx;x<=maxx;x++) if (mask.has(y*W+x)) w++; if (w>=MINW) return y; }
  return maxy;
}

function isSkin(r,g,b){ return r>150&&r<247&&g>105&&g<206&&b>75&&b<182&&r>g+8&&(r-b)>20; }

function extractCell(p, W, x0, x1, y0, y1, sx0, sx1, keepExtra=false) {
  if(sx0===undefined){ sx0=x0; sx1=x1; }
  const comps=components(p,x0,x1,y0,y1);
  if(!comps.length) return null;
  let main=null, best=-1;
  for(const c of comps){ let m=0; for(let k=0;k<c.px.length;k+=2) if(c.px[k]>=sx0&&c.px[k]<sx1) m++; if(m>best){best=m;main=c;} }
  const mask=new Set();
  for(let k=0;k<main.px.length;k+=2) mask.add(main.px[k+1]*W+main.px[k]);
  let minx=1e9,maxx=-1,miny=1e9,maxy=-1;
  for(const v of mask){const x=v%W,y=(v-x)/W; if(x<minx)minx=x;if(x>maxx)maxx=x;if(y<miny)miny=y;if(y>maxy)maxy=y;}
  // renderMask: lo que se DIBUJA. Por defecto = solo el cuerpo (main). Con keepExtra suma los
  // componentes CERCANOS (agua/energía que rodea el cuerpo) cuyo bbox se solapa con el del
  // cuerpo — así el remolino azul del dash entra, pero NO el bleed del frame vecino (que está
  // lejos, en el margen). Las MEDIDAS (pies, cabeza, altura) siguen usando solo main (mask).
  let renderMask=mask;
  if(keepExtra){
    renderMask=new Set(mask);
    const exX=(maxx-minx)*0.14, exY=(maxy-miny)*0.12;
    for(const c of comps){
      if(c===main) continue;
      let cminx=1e9,cmaxx=-1,cminy=1e9,cmaxy=-1;
      for(let k=0;k<c.px.length;k+=2){const x=c.px[k],y=c.px[k+1];
        if(x<cminx)cminx=x;if(x>cmaxx)cmaxx=x;if(y<cminy)cminy=y;if(y>cmaxy)cmaxy=y;}
      const overlap = cmaxx>=minx-exX && cminx<=maxx+exX && cmaxy>=miny-exY && cminy<=maxy+exY;
      if(overlap) for(let k=0;k<c.px.length;k+=2) renderMask.add(c.px[k+1]*W+c.px[k]);
    }
  }
  const feetY=detectFeet(mask,W,minx,maxx,maxy);
  let fminx=1e9,fmaxx=-1;
  for(let y=feetY-8;y<=feetY;y++)for(let x=minx;x<=maxx;x++) if(mask.has(y*W+x)){if(x<fminx)fminx=x;if(x>fmaxx)fmaxx=x;}
  // altura de la CARA en la zona alta (piel tostada)
  const topZone = miny + (feetY-miny)*0.45;
  let cmin=1e9,cmax=-1, skin=0;
  for(const v of mask){ const x=v%W, y=(v-x)/W; if(y>topZone) continue;
    const q=(y*W+x)*4; if(isSkin(p.data[q],p.data[q+1],p.data[q+2])){ if(y<cmin)cmin=y; if(y>cmax)cmax=y; skin++; } }
  const faceH = (cmax>=0 && skin>60) ? cmax-cmin : 0;
  return {mask, renderMask, feetY, miny, maxy, charH:feetY-miny, area:main.area, faceH, headW:headWmask(mask,W,miny), feetCx:(fminx+fmaxx)/2, bboxCx:(minx+maxx)/2, bboxCy:(miny+maxy)/2};
}

function processSheet(sheetRel, rows, cols, count, outDir, outName, marginL=0.02, marginR=0.02, scaleOverride=0, startIdx=0, cellStart=0, cxBbox=false, vCenter=false, keepExtra=false, flipH=false) {
  const raw = PNG.sync.read(fs.readFileSync(FG+'/'+sheetRel));
  const p = chroma(raw);
  const W=p.width, cellW=W/cols, cellH=p.height/rows;
  fs.mkdirSync(FG+'/'+outDir,{recursive:true});
  const cells=[];
  for (let i=0;i<count;i++){
    const r=Math.floor((cellStart+i)/cols), c=(cellStart+i)%cols;
    const sx0=Math.round(c*cellW), sx1=Math.round((c+1)*cellW);
    const x0=Math.max(0,Math.round(c*cellW - cellW*marginL));
    const x1=Math.min(W,Math.round((c+1)*cellW + cellW*marginR));
    cells.push(extractCell(p,W,x0,x1,Math.round(r*cellH),Math.round((r+1)*cellH),sx0,sx1,keepExtra));
  }
  const valid=cells.filter(c=>c);
  // ESCALA por ANCHO DE CABEZA (invariante a la pose) calibrada a walk: da la MISMA
  // estatura real en toda acción, parada o agachada. scaleOverride solo para hojas
  // AÉREAS, donde la cabeza sale foreshortened/tapada y el método no es fiable.
  // >0 = escala fija (aéreas) | <0 = método ÁREA (masa corporal, para ataques PARADOS
  // donde la AI dibuja la cabeza desproporcionada y el método cabeza los achica) |
  // 0 = método CABEZA (agachadas: misma estatura que walk).
  let sheetS, metodo;
  if(scaleOverride>0){ sheetS=scaleOverride; metodo='override'; }
  else if(scaleOverride<0){ sheetS=Math.sqrt(TARGET_AREA/valid[0].area); metodo='area'; }
  else { const hMed=robustHead(cells); sheetS = hMed>0 ? TARGET_HEAD/hMed : Math.sqrt(TARGET_AREA/valid[0].area); metodo = hMed>0?'cabeza':'area'; }
  const report=[];
  for (let i=0;i<count;i++){
    const cell=cells[i];
    if(!cell){report.push(`${outName}-${i+1}: VACIO`);continue;}
    const out=new PNG({width:CANVAS_W,height:CANVAS_H});
    for(let dy=0;dy<CANVAS_H;dy++)for(let dx=0;dx<CANVAS_W;dx++){
      // vCenter: centra el CENTRO del cuerpo (para poses que ROTAN, ej. mortal aéreo) en
      // el medio del lienzo. cxBbox: centra por bbox y ancla el borde bajo al piso (tiradas).
      const ax = (cxBbox || vCenter) ? cell.bboxCx : cell.feetCx;
      const ay = vCenter ? cell.bboxCy : (cxBbox ? cell.maxy : cell.feetY);
      const anchorY = vCenter ? (CANVAS_H * 0.5) : FEET_Y;
      const sx=ax+(dx-FEET_X)/sheetS, sy=ay+(dy-anchorY)/sheetS;
      const ix=Math.round(sx),iy=Math.round(sy), di=(dy*CANVAS_W+dx)*4;
      if(ix<0||iy<0||ix>=W||iy>=p.height||!cell.renderMask.has(iy*W+ix)){out.data[di+3]=0;continue;}
      const si=(iy*W+ix)*4;
      out.data[di]=p.data[si];out.data[di+1]=p.data[si+1];out.data[di+2]=p.data[si+2];out.data[di+3]=p.data[si+3];
    }
    // flipH: espeja horizontalmente el frame alrededor del ancla de pies (FEET_X=650),
    // para que la ORIENTACIÓN de la hoja empalme con la de otra animación (ej. wall_splat
    // debe mirar igual que hit_fly, si la IA la dibujó al revés).
    let final = out;
    if (flipH) {
      final = new PNG({width:CANVAS_W,height:CANVAS_H});
      for(let dy=0;dy<CANVAS_H;dy++)for(let dx=0;dx<CANVAS_W;dx++){
        const s=(dy*CANVAS_W+dx)*4, mx=2*FEET_X-dx, d=(dy*CANVAS_W+mx)*4;
        if(mx<0||mx>=CANVAS_W) continue;
        final.data[d]=out.data[s];final.data[d+1]=out.data[s+1];final.data[d+2]=out.data[s+2];final.data[d+3]=out.data[s+3];
      }
    }
    fs.writeFileSync(`${FG}/${outDir}/favi-${outName}-${startIdx+i+1}.png`,PNG.sync.write(final));
    report.push(`${outName}-${startIdx+i+1}: [${metodo} s=${sheetS.toFixed(3)}${flipH?' FLIP':''}] headOut ${Math.round(cell.headW*sheetS)} h=${Math.round(cell.charH*sheetS)}`);
  }
  processSheet.lastScale = sheetS;
  return report;
}

// calibra con WALK (tamaño correcto): TARGET_FACE = cara más grande de walk * su escala-área
function calibrate(){
  const p=chroma(PNG.sync.read(fs.readFileSync(FG+'/imagen-action/favi/sheets/walk-sheet.png')));
  const W=p.width, cellW=W/4, cellH=p.height/2, cells=[];
  for(let i=0;i<8;i++){const r=Math.floor(i/4),c=i%4;
    cells.push(extractCell(p,W,Math.round(c*cellW+0.02*cellW),Math.round((c+1)*cellW-0.02*cellW),Math.round(r*cellH),Math.round((r+1)*cellH)));}
  TARGET_AREA = cells[0].area * 1.409 * 1.409;
  TARGET_FACE = Math.max(...cells.map(c=>c.faceH)) * 1.409;
  // walk se renderiza a escala 1.409; su ancho de cabeza a esa escala es el objetivo.
  TARGET_HEAD = robustHead(cells) * 1.409;
  console.log('calibrado walk: TARGET_HEAD='+Math.round(TARGET_HEAD)+' (px salida)');
}
calibrate();

const S = 'imagen-action/favi/sheets/';
// [file, rows, cols, count, name, marginL, marginR, scaleOverride]
// override>0 sólo para hojas AGACHADAS (frame-1 doblado engaña al área):
//   crouch_punch = 0.954 (misma celda 724 que crouch -> misma escala fuente)
//   crouch_kick  = 1.055 (celda 434, dibujada más chica; masa del frame agachado = la de crouch)
// GROUNDED (parada/agachada) -> override 0 = método CABEZA (misma estatura que walk).
// AÉREAS (jump*) -> override congelado a ojo: en el aire la cabeza no es fiable y el
// cuerpo encogido hace que igualar cabeza se vea grande; se calibran mirando walk.
const jobs = {
  walk:        ['walk-sheet.png',2,4,8,'walk',0.02,0.02,0],
  pose:        ['pose-sheet.png',2,2,4,'pose',0.05,0.05,0],
  punch:       ['punch-sheet.png',2,5,10,'punch',0.04,0.06,-1],
  kick:        ['kick-sheet.png',2,5,10,'kick',0.22,0.06,-1],   // marginL 0.22: el pie de atrás del lunge (f5) se sale ~62px de la celda
  // weak_punch (jab R): brazo extendido como punch -> método ÁREA (la cabeza dibujada
  // grande engaña al método cabeza, igual que en punch/kick).
  weak_punch:  ['weak-punch-sheet.png',1,4,4,'weak_punch',0.04,0.06,-1],
  // counter (parry-contraataque): 6 frames en 2 filas de 3. f1 desvío (agujas cruzadas),
  // f2-f5 las 3 estocadas (agujas MUY extendidas -> marginR grande), f6 recuperación. La IA
  // dibujó la cabeza grande (método cabeza la achicaba ~9%), así que override 1.20 para que
  // quede del tamaño de su POSE/presencia normal, no chiquita.
  counter:     ['counter-sheet.png',2,3,6,'counter',0.05,0.35,1.20],
  // whirlpool (finisher ↓←E): giro mortal EN EL LUGAR con VÓRTICE de agua creciendo. 4 frames
  // (2 filas de 2): f1 pose (arranca), f2-f3 girando, f4 tornado completo. Rota + rings de agua
  // anchos -> escala por ALTURA (como spin_kick) + keepExtra (el vórtice azul se sale de la celda).
  whirlpool:   ['Whirlpool-move.png',2,2,4,'whirlpool',0.03,0.03,1.07,true],
  // spin_kick (E suelo): PEONZA de agujas, gira 360° con pies juntos y brazos abiertos.
  // Rota (cabeza de frente/perfil varía) y brazos MUY abiertos (área se infla) -> escala por
  // ALTURA de cuerpo a ojo (pies en el piso). keepExtra por si el brillo azul se separa.
  spin_kick:   ['spin-kick-sheet.png',2,4,8,'spin_kick',0.03,0.03,1.46,true],
  // crouch_jab (↓R): estocada baja de aguja en cuclillas. Agachada con cabeza visible -> método
  // CABEZA (0); marginR generoso porque la aguja se extiende al frente.
  crouch_jab:  ['crouch-jab-sheet.png',1,4,4,'crouch_jab',0.08,0.42,0],
  // air_jab (salto+R): PATADA AÉREA DOBLE, semisentada en el aire pateando alante.
  // Aérea tucked -> override manual (como los otros saltos). vCenter: centra el cuerpo.
  air_jab:     ['air-jab-sheet.png',1,4,4,'air_jab',0.04,0.06,1.75],
  // dash (←→+Q): CORRIDA/embestida inclinada con remolino de agua. Override por ZAPATO
  // (invariante fiable en poses dinámicas; el pelo suelto engaña al método cabeza).
  // 1.53 -> zapato ≈ walk (área daba 1.671 = zapato 115, un 10% grande).
  // keepExtra=true -> conserva el REMOLINO DE AGUA (blob azul separado del cuerpo).
  dash:        ['fe-dash-sheet.png',1,4,4,'dash',0.05,0.10,1.53,true],
  crouch:      ['crouch-sheet.png',1,3,3,'crouch',0.12,0.4,0],
  crouch_punch:['crouch-punch-sheet.png',1,3,3,'crouch_punch',0.12,0.45,0],
  crouch_kick: ['crouch-kick-sheet.png',1,5,5,'crouch_kick',0.1,0.4,0],
  jump:        ['jump-sheet.png',1,6,6,'jump',0.05,0.05,1.20],
  jump_punch:  ['jump-punch-sheet.png',1,4,4,'jump_punch',0.08,0.3,1.067],
  jump_kick:   ['jump-kick-sheet.png',1,4,4,'jump_kick',0.08,0.35,1.25],
  take_hit:    ['take-hit-sheet.png',1,4,4,'take_hit',0.08,0.12,0.98],
  take_hit_low:['take-hit-low-sheet.png',1,3,3,'take_hit_low',0.12,0.4,0],
  // pummeled (tambaleo CONTINUO bajo la ráfaga del ULTRA): 6 frames en 2 filas de 3.
  // De PIE tambaleándose -> estatura COMPLETA (~walk 555) para que no se vea chica al
  // lado de DAM. La IA la dibujó ENCOGIDA en la fuente: a 0.98 salía chica (410-470) y
  // a 1.10 quedaba corta (460-528); override 1.22 la sube a ~510-585 (frame erguido ~=
  // walk). Cabeza sacudida -> no sirve el método CABEZA. BUCLE: f6 empalma con f1.
  pummeled:    ['pummeled-sheet.png',2,3,6,'pummeled',0.08,0.12,1.22,false,true],   // flipH: la hoja está dibujada mirando a la IZQUIERDA; se espeja para que mire a la DERECHA como el resto
  // vuelo/piso: la cabeza no es fiable (arqueada/tirada), escala fija a ojo (matchea walk)
  hit_fly:     ['strong-fly-sheet.png',1,4,4,'hit_fly',0.1,0.3,1.139],
  hit_down:    ['strong-fly-sheet-2.png',1,5,5,'hit_down',0.1,0.3,1.47],
  // wall_splat (estrellón contra la pared → cae de bruces): 6 frames en 2 filas de 3.
  // NOQUEADA muñeca de trapo. Hoja REGENERADA con proporciones esbeltas (ya no "nenana").
  // La IA aún la dibuja MÁS CHICA que hit_fly (área de piel ~66% -> override 1.40 iguala el
  // tamaño en pantalla). Esta versión mira YA como hit_fly (cabeza a la IZQ) -> flipH=false.
  // keepExtra=false: sin efectos, y evita que se cuele el bleed de zapatos del frame vecino.
  wall_splat:  ['wall-bounce-sheet.png',2,3,6,'wall_splat',0.1,0.3,1.40,false,false],
  // block: hoja con 2 poses casi iguales -> uso solo la 1ª (el juego usa 1 frame).
  // ÁREA porque las agujas cruzadas suben por encima de la cabeza (engañan al método cabeza).
  block:       ['block-sheet.png',1,2,1,'block',0.05,0.2,-1],
  // block_low: 2 poses casi iguales -> uso la 1ª. Agachada profunda con agujas de
  // techo tapando la cabeza -> override a ojo (matchea la familia agachada).
  block_low:   ['block-low-sheet.png',1,2,1,'block_low',0.08,0.15,-1],
  water_cast:  ['water-cast-fe-sheet.png',1,5,5,'water_cast',0.06,0.22,1.00],
};
function run(k){ const [f,r,c,n,name,ml,mr,ov,ke,fh]=jobs[k]; console.log(k+':\n'+processSheet(S+f,r,c,n,'imagen-action/favi/'+name,name,ml,mr,ov,0,0,false,false,ke,fh).join('\n')); }
// SWEEP: 2 hojas de 3 frames -> 6 frames, con la MISMA escala (agachada; override para
// que matchee el tamaño de crouch). marginR generoso porque la aguja se extiende al frente.
function runSweep(){
  const OV = 0;   // método CABEZA (cada hoja calibra su cabeza a la de walk)
  const r1 = processSheet(S+'sweep-sheet.png',1,3,3,'imagen-action/favi/sweep','sweep',0.12,0.45,OV,0);
  const r2 = processSheet(S+'sweep-sheet-2.png',1,3,3,'imagen-action/favi/sweep','sweep',0.12,0.45,OV,3);
  console.log('sweep:\n'+r1.concat(r2).join('\n'));
}
// KO: la hoja mezcla frames DE PIE (grandes) y TIRADA (dibujados chicos), así que va en
// DOS grupos con escala distinta: pie/rodillas 1.13 (bien) y tirada 1.47 (como hit_down).
function runKo(){
  // 3 frames: pie(1) + rodillas(2) a 1.13, y UNA sola tirada (última celda 4). La tirada
  // se centra por BBOX (no por pies) y con márgenes amplios para NO cortar pelo/cabeza/pies.
  const r1 = processSheet(S+'ko-sheet.png',1,5,2,'imagen-action/favi/ko','ko',0.08,0.3,1.13,0,0);
  const r2 = processSheet(S+'ko-sheet.png',1,5,1,'imagen-action/favi/ko','ko',0.3,0.3,1.20,2,4,true);
  // borrar frames viejos 4 y 5 (ahora la anim tiene 3)
  for(const n of [4,5]) for(const ext of ['png','png.import']){ const f=FG+'/imagen-action/favi/ko/favi-ko-'+n+'.'+ext; if(fs.existsSync(f)) fs.unlinkSync(f); }
  console.log('ko:\n'+r1.concat(r2).join('\n'));
}
// VICTORY: 2 hojas de 4 -> 8 frames. De pie con agujas cruzadas al pecho (puntas sobre
// la cabeza -> método ÁREA). Para que NO salte el tamaño entre hojas, la 2ª usa la MISMA
// escala que la 1ª (área de la hoja A aplicada como override a la B).
function runVictory(){
  // El arte de victoria es LANKY (cabeza chica, cuerpo largo): head-match la hace torre, y el
  // 0.80 fijo la dejaba "pequeña" (cabeza 88). Punto medio: override POR HOJA para altura
  // CONSISTENTE (~660, un ~18% sobre walk = pose orgullosa) con cabeza ~100. Cada hoja tiene
  // tamaño distinto en el sheet, por eso dos valores (la 2ª se dibujó un pelín más chica).
  const OV1 = 0.94, OV2 = 1.00;
  const r1 = processSheet(S+'victory-sheet.png',1,4,4,'imagen-action/favi/victory','victory',0.08,0.22,OV1,0);
  const r2 = processSheet(S+'victory-sheet-2.png',1,4,4,'imagen-action/favi/victory','victory',0.08,0.22,OV2,4);
  console.log('victory:\n'+r1.concat(r2).join('\n'));
}
// AIR SPIN KICK (salto+E): mortal frontal (rota, hay frame invertido) + patada. 2 hojas de 4.
// vCenter=true: centra el CENTRO del cuerpo en el lienzo para que la rotación se vea natural.
function runAirSpin(){
  // sheet 1 (mortal) bien a 1.10; sheet 2 (patada) se dibujó con la CABEZA chica -> se ve
  // pequeña, así que va a mayor escala (1.60) para igualar la cabeza/tamaño de la sheet 1.
  const r1 = processSheet(S+'air-spin-kick-sheet.png',1,4,4,'imagen-action/favi/air_spin_kick','air_spin_kick',0.1,0.3,0.94,0,0,false,true);
  const r2 = processSheet(S+'air-spin-kick-sheet-2.png',1,4,4,'imagen-action/favi/air_spin_kick','air_spin_kick',0.1,0.3,1.40,4,0,false,true);
  console.log('air_spin_kick:\n'+r1.concat(r2).join('\n'));
}
// MORTAL AÉREO HACIA ADELANTE (salto+alante): flip que rota 360°, vCenter (centro del
// cuerpo). Los frames vienen chicos -> override para agrandar (matchea los otros aéreos).
function runNeutralSpin(scale){
  const r = processSheet(S+'neutral-spin.png',1,4,4,'imagen-action/favi/neutral_spin','neutral_spin',0.05,0.05,scale,0,0,false,true);
  console.log('neutral_spin:\n'+r.join('\n'));
}
const arg = process.argv[2] || 'all';
if (arg==='all'){ for(const k of Object.keys(jobs)) run(k); runSweep(); runKo(); runVictory(); runAirSpin(); }
else if (arg==='neutral_spin') runNeutralSpin(Number(process.argv[3])||1.0);
else if (arg==='sweep') runSweep();
else if (arg==='ko') runKo();
else if (arg==='victory') runVictory();
else if (arg==='air_spin_kick') runAirSpin();
else if (jobs[arg]) run(arg);
else if (arg==='ckf34') console.log(processSheet(S+'crouch-kick-f3-f4-sheet.png',1,2,2,'imagen-action/favi/_tmp_ckf34','ck',0.1,0.15).join('\n'));
