{
  Retro programming in Borland Turbo Pascal

  Author: Johan Gardhage <johan.gardhage@gmail.com>
}

unit vector;

INTERFACE

uses crt,gfx;

type textype = record
                 x:integer;
                 px,py:byte;
               end;
     textable = array[0..199] of textype;
     textableptr = ^textable;

const divd=128;
      maxpolygons=24;
      maxpoints=14;
      maxdegrees=256; { 128, 256, 512, 1024 }
      xc:word = 0;
      yc:word = 0;
      zc:word = 250;

var cosinus:array[0..maxdegrees] of integer;
    sinus:array[0..maxdegrees] of integer;
    polyz:array[1..maxpolygons] of integer;
    pind:array[1..maxpolygons] of byte;
    le,re:array[0..199] of word; {edge tables for scan converter}
    xp,yp,zp:array[1..maxpoints] of integer;
    x,y,z,newx,newy,newz:integer;
    phix,phiy,phiz:integer;
    numvisible:integer;
{ real variables }
    rcosinus:array[0..359] of real;
    rsinus:array[0..359] of real;
    rx,ry,rz,rnewx,rnewy,rnewz:real;
    rphix,rphiy,rphiz:real;
{ lightsource variables }
    ux,uy,uz,vx,vy,vz:integer;
    nx,ny,nz:real;              { dotproduct }
    costheta:real;              { angle between lightsource and plane-normal }
    ll,nl:real;
    lx,ly,lz:real;           { lightsource coords }
    surfcol:byte;               { surface illumination factor }
    lightxp,lightyp:integer;
{ gouraud variables }
    cl,cr:array[0..199] of byte; {colour tables for scan converter}
    gnx:array[1..maxpolygons] of real;
    gny:array[1..maxpolygons] of real;
    gnz:array[1..maxpolygons] of real;
    gouraudcol1,gouraudcol2,gouraudcol3:byte;
{ texture variables }
    textureptr : pointer;
    textureaddr : word;

procedure scanconv(x1,y1,x2,y2:integer);
procedure draw_quad(x1,y1,x2,y2,x3,y3,x4,y4:integer;col:byte);
procedure draw_triangle(x1,y1,x2,y2,x3,y3:integer;col:byte);
procedure scanconv_gouraud(x1,y1,x2,y2:integer;c1,c2:byte);
procedure hline_gouraud(x1,x2,y:integer;c1,c2:byte;where:word);
procedure draw_tri_gouraud(x1,y1,x2,y2,x3,y3:integer;c1,c2,c3:byte);
procedure hline_glenz(x1,x2,y:integer;col:byte;where:word);
procedure draw_tri_glenz(x1,y1,x2,y2,x3,y3:integer;col:byte);
procedure draw_4_glenz(x1,y1,x2,y2,x3,y3,x4,y4:integer;col:byte);
procedure hline_texture(x1,x2,px1,py1,px2,py2,y:integer;source,dest:word);
procedure draw4texture(x1,y1,x2,y2,x3,y3,x4,y4,dim:integer);
procedure swap(var a,b:integer);
procedure quicksort(hi:integer);
procedure rotate(x,y,z,phix,phiy,phiz:integer;var newx,newy,newz:integer);
procedure rrotate(x,y,z:integer;rphix,rphiy,rphiz:real;var rnewx,rnewy,rnewz:real);
procedure conv3dto2d(newx,newy,newz:integer;var xp,yp:integer);
procedure rconv3dto2d(rnewx,rnewy,rnewz:real;var xp,yp:integer);
function checkvisible(x1,y1,x2,y2,x3,y3:integer):boolean;
procedure makevector(x1,y1,z1,x2,y2,z2:integer;var x3,y3,z3:integer);
procedure crossproduct(ux,uy,uz,vx,vy,vz:real;var nx,ny,nz:real);
function dotproduct(ux,uy,uz,vx,vy,vz:real):real;
function calclength(ux,uy,uz,vx,vy,vz:real):real;

IMPLEMENTATION

{****************************************************************************}

procedure scanconv(x1,y1,x2,y2:integer);
var xadd,x,loop1,temp1:integer;
begin
  if y2<y1 then begin
    temp1:=y1;y1:=y2;y2:=temp1;
    temp1:=x1;x1:=x2;x2:=temp1;
  end;

  temp1:=y2-y1;
  if temp1=0 then temp1:=1;

  xadd:=((x2-x1) shl 7) div temp1;
  x:=x1 shl 7;
  for loop1:=y1 to y2-1 do begin
    temp1:=x shr 7;
    if temp1<le[loop1] then le[loop1]:=temp1;
    if re[loop1]<temp1 then re[loop1]:=temp1;
    inc(x,xadd);
  end;
end;

{****************************************************************************}

procedure draw_quad(x1,y1,x2,y2,x3,y3,x4,y4:integer;col:byte);
var loop1,topy,boty:integer;
begin
  for loop1:=0 to 199 do le[loop1]:=319;
  for loop1:=0 to 199 do re[loop1]:=0;
  scanconv(x1,y1,x2,y2);
  scanconv(x2,y2,x3,y3);
  scanconv(x3,y3,x4,y4);
  scanconv(x4,y4,x1,y1);
  topy:=y1;if y2<topy then topy:=y2;if y3<topy then topy:=y3;if y4<topy then topy:=y4;
  boty:=y1;if y2>boty then boty:=y2;if y3>boty then boty:=y3;if y4>boty then boty:=y4;
  for loop1:=topy to boty-1 do
    hline(le[loop1],re[loop1],loop1,col,vaddr);
end;

{****************************************************************************}

procedure draw_triangle(x1,y1,x2,y2,x3,y3:integer;col:byte);
var loop1,topy,boty:integer;
begin
  for loop1:=0 to 199 do le[loop1]:=319;
  for loop1:=0 to 199 do re[loop1]:=0;
  scanconv(x1,y1,x2,y2);
  scanconv(x2,y2,x3,y3);
  scanconv(x3,y3,x1,y1);
  topy:=y1;if y2<topy then topy:=y2;if y3<topy then topy:=y3;
  boty:=y1;if y2>boty then boty:=y2;if y3>boty then boty:=y3;
  for loop1:=topy to boty-1 do
    hline(le[loop1],re[loop1],loop1,col,vaddr);
end;

{****************************************************************************}

procedure scanconv_gouraud(x1,y1,x2,y2:integer;c1,c2:byte);
var xadd,x,loop1,temp1,coladd,color:integer;
begin
  if y2<y1 then begin
    temp1:=y1;y1:=y2;y2:=temp1;
    temp1:=x1;x1:=x2;x2:=temp1;
    temp1:=c1;c1:=c2;c2:=temp1;
  end;

  temp1:=y2-y1;
  if temp1=0 then temp1:=1;
  xadd:=((x2-x1) shl 7) div temp1;
  coladd:=((c2-c1) shl 7) div temp1;

  x:=x1 shl 7;
  color:=c1 shl 7;

  for loop1:=y1 to y2-1 do begin
    temp1:=x shr 7;
    if temp1<le[loop1] then begin
      le[loop1]:=temp1;
      cl[loop1]:=color shr 7;
    end;
    if temp1>re[loop1] then begin
      re[loop1]:=temp1;
      cr[loop1]:=color shr 7;
    end;
    inc(color,coladd);
    inc(x,xadd);
  end;
end;

{****************************************************************************}

procedure hline_gouraud(x1,x2,y:integer;c1,c2:byte;where:word);
var color,addcol,temp1,loop1:integer;
begin
  temp1:=x2-x1;
  if temp1=0 then temp1:=1;
  addcol:=((c2-c1) shl 8) div temp1;
  color:=c1 shl 8;

  asm
  mov   es, [where]
  mov   bx, [y]
  add   bx, bx
  mov   di, word ptr [screen_offset + bx]
  add   di, [x1]

  mov   cx, [x2]
  sub   cx, [x1]
  cmp   cx, 0
  jle   @exit

  mov   dx, color
  mov   bx, addcol
@loop2:
  mov   al, dh
  stosb
  add   dx, bx
  loop  @loop2
@exit:
  end;
end;

{****************************************************************************}

procedure draw_tri_gouraud(x1,y1,x2,y2,x3,y3:integer;c1,c2,c3:byte);
var loop1,topy,boty:integer;
begin
  for loop1:=0 to 199 do le[loop1]:=319;
  for loop1:=0 to 199 do re[loop1]:=0;
  scanconv_gouraud(x1,y1,x2,y2,c1,c2);
  scanconv_gouraud(x2,y2,x3,y3,c2,c3);
  scanconv_gouraud(x3,y3,x1,y1,c3,c1);
  topy:=y1;if y2<topy then topy:=y2;if y3<topy then topy:=y3;
  boty:=y1;if y2>boty then boty:=y2;if y3>boty then boty:=y3;
  for loop1:=topy to boty-1 do
    hline_gouraud(le[loop1],re[loop1],loop1,cl[loop1],cr[loop1],vaddr);
end;

{****************************************************************************}

procedure hline_glenz(x1,x2,y:integer;col:byte;where:word); assembler;
asm
  mov   es, [where]
  mov   bx, [y]
  add   bx, bx
  mov   di, word ptr [screen_offset + bx]
  add   di, [x1]

  mov   cx, [x2]
  sub   cx, [x1]
  cmp   cx, 0
  jle   @exit

  xor   dx, dx
  cmp   [col], 2
  jne   @loop1
  mov   dl, 2
@loop1:
  mov   al, es:[di]
  cmp   al, 0
  je    @plot

  add   al, dl

@plot:
  add   al, [col]
  stosb
  loop  @loop1
@exit:
end;

{****************************************************************************}

procedure draw_tri_glenz(x1,y1,x2,y2,x3,y3:integer;col:byte);
var loop1,topy,boty:integer;
begin
  for loop1:=0 to 199 do le[loop1]:=319;
  for loop1:=0 to 199 do re[loop1]:=0;
  scanconv(x1,y1,x2,y2);
  scanconv(x2,y2,x3,y3);
  scanconv(x3,y3,x1,y1);
  topy:=y1;if y2<topy then topy:=y2;if y3<topy then topy:=y3;
  boty:=y1;if y2>boty then boty:=y2;if y3>boty then boty:=y3;
  for loop1:=topy to boty-1 do
    hline_glenz(le[loop1],re[loop1],loop1,col,vaddr);
end;

{****************************************************************************}

procedure draw_4_glenz(x1,y1,x2,y2,x3,y3,x4,y4:integer;col:byte);
var loop1,topy,boty:integer;
begin
  for loop1:=0 to 199 do le[loop1]:=319;
  for loop1:=0 to 199 do re[loop1]:=0;
  scanconv(x1,y1,x2,y2);
  scanconv(x2,y2,x3,y3);
  scanconv(x3,y3,x4,y4);
  scanconv(x4,y4,x1,y1);
  topy:=y1;if y2<topy then topy:=y2;if y3<topy then topy:=y3;if y4<topy then topy:=y4;
  boty:=y1;if y2>boty then boty:=y2;if y3>boty then boty:=y3;if y4>boty then boty:=y4;
  for loop1:=topy to boty-1 do
    hline_glenz(le[loop1],re[loop1],loop1,col,vaddr);
end;

{****************************************************************************}

procedure hline_texture(x1,x2,px1,py1,px2,py2,y:integer;source,dest:word);
var pxval,pxstep,pyval,pystep:integer;
    linewidth:integer;
begin
  linewidth:=(x2-x1+1);
  pxstep:=((px2-px1) shl 8) div linewidth;
  pystep:=((py2-py1) shl 8) div linewidth;
  pxval:=px1 shl 8;
  pyval:=py1 shl 8;
  asm
    push  ds
    mov   bx, [y]
    add   bx, bx
    mov   di, word ptr [screen_offset + bx]
    add   di, [x1]

    mov   es, [dest]
    mov   ds, [source]

    mov   cx, [linewidth]
    mov   ax, [pxval]
    mov   dx, [pyval]
@loop1:
    xor   bx, bx
    mov   bh, dh { bx = pyval * 256 }
    shr   bx, 2  { bx = pyval * 64 }
    add   bh, dh { bx = pyval * 320 }
    add   bl, ah { bx = bx + pxval }
    mov   si, bx

    movsb

    add   ax, [pxstep]
    add   dx, [pystep]
    loop  @loop1
    pop   ds
  end;
end;

{****************************************************************************}

procedure draw4texture(x1,y1,x2,y2,x3,y3,x4,y4,dim:integer);
var ymin,ymax,xstart,xend,ystart,yend:integer;
    xval,xstep:integer;
    pxstart,pxend,pystart,pyend:integer;
    pxval,pxstep,pyval,pystep:integer;
    count:integer;
    side:textableptr;
    left,right:textable;
begin
  ymin := y1; ymax := y1;
  if y2 > ymax then ymax := y2; if y3 > ymax then ymax := y3;
  if y4 > ymax then ymax := y4; if y2 < ymin then ymin := y2;
  if y3 < ymin then ymin := y3; if y4 < ymin then ymin := y4;

  xstart := x1; ystart := y1; xend := x2; yend := y2;
  pxstart := 0; pystart := 0; pxend := dim-1; pyend := 0;
  if ystart > yend then begin
      swap(xstart, xend);
      swap(ystart, yend);
      swap(pxstart, pxend);
      side := @left;
  end else side := @right;
  xval := xstart shl 8;
  xstep := ((xend-xstart) shl 8) div (yend-ystart+1);
  pxval := pxstart shl 8;
  pxstep := ((pxend-pxstart) shl 8) div (yend-ystart+1);
  for count := ystart to yend do begin
      side^[count].x := xval shr 8;
      side^[count].px := pxval shr 8;
      side^[count].py := pystart;
      xval := xval + xstep;
      pxval := pxval + pxstep;
  end;

  xstart := x2; ystart := y2; xend := x3; yend := y3;
  pxstart := dim-1; pystart := 0; pxend := dim-1; pyend := dim-1;
  if ystart > yend then begin
      swap(xstart, xend);
      swap(ystart, yend);
      swap(pystart, pyend);
      side := @left;
  end
  else side := @right;
  xval := (xstart) shl 8;
  xstep := ((xend-xstart) shl 8) div (yend-ystart+1);
  pyval := pystart shl 8;
  pystep := ((pyend-pystart) shl 8) div (yend-ystart+1);
  for count := ystart to yend do begin
      side^[count].x := xval shr 8;
      side^[count].py := pyval shr 8;
      side^[count].px := pxstart;
      xval := xval + xstep;
      pyval := pyval + pystep;
  end;

  xstart := x3; ystart := y3; xend := x4; yend := y4;
  pxstart := dim-1; pystart := dim-1; pxend := 0; pyend := dim-1;
  if ystart > yend then begin
      swap(xstart, xend);
      swap(ystart, yend);
      swap(pxstart, pxend);
      side := @left;
  end
  else side := @right;
  xval := (xstart) shl 8;
  xstep := ((xend-xstart) shl 8) div (yend-ystart+1);
  pxval := pxstart shl 8;
  pxstep := ((pxend-pxstart) shl 8) div (yend-ystart+1);
  for count := ystart to yend do begin
      side^[count].x := xval shr 8;
      side^[count].px := pxval shr 8;
      side^[count].py := pystart;
      xval := xval + xstep;
      pxval := pxval + pxstep;
  end;

  xstart := x4; ystart := y4;xend := x1; yend := y1;
  pxstart := 0;  pystart := dim-1; pxend := 0; pyend := 0;
  if ystart > yend then begin
      swap(xstart, xend);
      swap(ystart, yend);
      swap(pystart, pyend);
      side := @left;
  end
  else side := @right;
  xval := (xstart) shl 8;
  xstep := ((xend-xstart) shl 8) div (yend-ystart+1);
  pyval := pystart shl 8;
  pystep := ((pyend-pystart) shl 8) div (yend-ystart+1);
  for count := ystart to yend do begin
      side^[count].x := xval shr 8;
      side^[count].py := pyval shr 8;
      side^[count].px := pxstart;
      xval := xval + xstep;
      pyval := pyval + pystep;
  end;

  for count := ymin to ymax do
    if left[count].x < right[count].x
      then hline_texture(left[count].x, right[count].x,
                         left[count].px, left[count].py,
                         right[count].px, right[count].py,
                         count, textureaddr, vaddr)
      else hline_texture(right[count].x, left[count].x,
                         right[count].px, right[count].py,
                         left[count].px, left[count].py,
                         count, textureaddr, vaddr);
end;

{****************************************************************************}

procedure swap(var a, b : integer);
var t : integer;
begin
  t := a;
  a := b;
  b := t;
end;

{****************************************************************************}

procedure quicksort(hi:integer);
procedure sort(l,r:integer);
var i,j,x,y:integer;
begin
  i:=l; j:=r; x:=polyz[(l+r) div 2];
  repeat
    while polyz[i]<x do inc(i);
    while x<polyz[j] do dec(j);
    if i<=j then begin
      y:=polyz[i]; polyz[i]:=polyz[j]; polyz[j]:=y;
      y:=pind[i]; pind[i]:=pind[j]; pind[j]:=y;
      inc(i); dec(j);
    end;
  until i>j;
  if l<j then sort(l,j);
  if i<r then sort(i,r);
end;

begin
  sort(1,hi);
end;

{****************************************************************************}

procedure rotate(x,y,z,phix,phiy,phiz:integer;var newx,newy,newz:integer);
var tempx,tempy,tempz:integer;
begin
  tempx:=(cosinus[phiy]*x-sinus[phiy]*z) div divd;
  tempy:=(cosinus[phiz]*y-sinus[phiz]*tempx) div divd;
  tempz:=(cosinus[phiy]*z+sinus[phiy]*x) div divd;
  newx:=(cosinus[phiz]*tempx+sinus[phiz]*y) div divd;
  newy:=(cosinus[phix]*tempy+sinus[phix]*tempz) div divd;
  newz:=(cosinus[phix]*tempz-sinus[phix]*tempy) div divd;
end;

{****************************************************************************}

procedure rrotate(x,y,z:integer;rphix,rphiy,rphiz:real;var rnewx,rnewy,rnewz:real);
var tempx,tempy,tempz:real;
begin
  tempx:=(rcosinus[round(rphiy)]*x-rsinus[round(rphiy)]*z);
  tempy:=(rcosinus[round(rphiz)]*y-rsinus[round(rphiz)]*tempx);
  tempz:=(rcosinus[round(rphiy)]*z+rsinus[round(rphiy)]*x);
  rnewx:=(rcosinus[round(rphiz)]*tempx+rsinus[round(rphiz)]*y);
  rnewy:=(rcosinus[round(rphix)]*tempy+rsinus[round(rphix)]*tempz);
  rnewz:=(rcosinus[round(rphix)]*tempz-rsinus[round(rphix)]*tempy);
end;

{****************************************************************************}

procedure conv3dto2d(newx,newy,newz:integer;var xp,yp:integer);
begin
  xp:=160 + (xc*newz-newx*zc) div (newz-zc);
  yp:=100 + (yc*newz-newy*zc) div (newz-zc);
end;

{****************************************************************************}

procedure rconv3dto2d(rnewx,rnewy,rnewz:real;var xp,yp:integer);
begin
  xp:=160 + round((xc*rnewz-rnewx*zc) / (rnewz-zc));
  yp:=100 + round((yc*rnewz-rnewy*zc) / (rnewz-zc));
end;

{****************************************************************************}

function checkvisible(x1,y1,x2,y2,x3,y3:integer):boolean;
begin
  checkvisible:=false;
  if ((x1-x3)*(y1-y2))-((x1-x2)*(y1-y3))<0 then checkvisible:=true;
end;

{****************************************************************************}

procedure makevector(x1,y1,z1,x2,y2,z2:integer;var x3,y3,z3:integer);
begin
  x3:=x1-x2;
  y3:=y1-y2;
  z3:=z1-z2;
end;

{****************************************************************************}

procedure crossproduct(ux,uy,uz,vx,vy,vz:real;var nx,ny,nz:real);
begin
  nx:=ux*vz-vy*uz;
  ny:=uz*vx-vz*ux;
  nz:=ux*vy-vx*uy;
end;

{****************************************************************************}

function dotproduct(ux,uy,uz,vx,vy,vz:real):real;
begin
  dotproduct:=ux*vx+uy*vy+uz*vz;
end;

{****************************************************************************}

function calclength(ux,uy,uz,vx,vy,vz:real):real;
begin
  calclength:=sqrt(ux*vx+uy*vy+uz*vz);
end;

{****************************************************************************}

var loop1:integer;
    v,vadd : real;
begin
	v:=0.0;
	vadd:=(2.0*pi/maxdegrees);
	for loop1:=0 to maxdegrees do begin
		sinus[loop1]:=round(sin(v)*divd);
		cosinus[loop1]:=round(cos(v)*divd);
		v:=v+vadd;
	end;

  for loop1:=0 to 359 do begin
    rcosinus[loop1]:=cos(loop1 * pi / 180);
    rsinus[loop1]:=sin(loop1 * pi / 180);
  end;

  phix:=0; phiy:=0; phiz:=0;
  rphix:=0; rphiy:=0; rphiz:=0;
end.
