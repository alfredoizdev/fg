import {PNG} from '/Users/alfredoizquierdo/Desktop/apps/soccer/soccer-mobile-app/node_modules/pngjs/lib/png.js';
import fs from 'fs';
const CANVAS_W=1300,CANVAS_H=1280;
const isGreen=(r,g,b)=>g>90&&g>r*1.20&&g>b*1.20;
const OUT='/Users/alfredoizquierdo/Desktop/fg/imagen-action/dam/air_jab';
fs.rmSync(OUT,{recursive:true,force:true});fs.mkdirSync(OUT,{recursive:true});
// SALTO+R = MORTAL (jum-mortal.mp4): TODOS los frames aereos f22..f64 (43). Es una ROTACION
// -> ancla por CENTROIDE por frame -> (650, 811) fijo: el giro queda centrado y la fisica
// del juego pone el movimiento. SC=1.724 (familia, parado 369).
const SRC=Array.from({length:43},(_,k)=>22+k);
const SC=1.724;
let o=1;
for(const idx of SRC){
  const p=PNG.sync.read(fs.readFileSync('dmort_raw/f_'+String(idx).padStart(3,'0')+'.png'));
  const{width:W,height:H,data:D}=p;
  let sx=0,sy=0,n=0;
  for(let y=0;y<H;y++)for(let x=0;x<W;x++){
    const k=(y*W+x)*4;if(D[k+3]<20)continue;
    if(isGreen(D[k],D[k+1],D[k+2]))continue;sx+=x;sy+=y;n++;
  }
  const cx=sx/n, cy=sy/n;
  const out=new PNG({width:CANVAS_W,height:CANVAS_H});out.data.fill(0);
  for(let oy=40;oy<1250;oy++)for(let ox=10;ox<1298;ox++){
    const gx=Math.round(cx+(ox-650)/SC),gy=Math.round(cy+(oy-811)/SC);
    if(gx<0||gx>=W||gy<0||gy>=H)continue;
    const si=(gy*W+gx)*4;let r=D[si],g=D[si+1],b=D[si+2],a=D[si+3];
    if(a<20)continue;if(isGreen(r,g,b))continue;
    const mx=Math.max(r,b);if(g>mx+8)g=mx+8;
    const oi=(oy*CANVAS_W+ox)*4;out.data[oi]=r;out.data[oi+1]=g;out.data[oi+2]=b;out.data[oi+3]=255;
  }
  fs.writeFileSync(OUT+'/dam-air_jab-'+o+'.png',PNG.sync.write(out));o++;
}
console.log('dam air_jab (mortal):',o-1,'frames');
