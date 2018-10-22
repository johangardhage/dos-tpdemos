{
  Retro programming in Borland Turbo Pascal

  Flat shaded cube on fire with z light source demo. Drawn with quads.

  Author: Johan Gardhage <johan.gardhage@gmail.com>
}

program demonstration;

uses crt,gfx,vector;

const border:boolean=false;
      xst=1; yst=1; zst=1;

{$I cube.vec}

procedure firefadeout; assembler;
asm
  mov   es, vaddr
  xor   di, di

  xor   dx, dx
  xor   cx, cx          { cx = y }
 @yloop:
  xor   bx, bx          { bx = x }
 @xloop:
  mov   dl, es:[di]     { dl = get color }
  mov   ax, dx          { ax = color }
  mov   dl, es:[di+319]
  add   ax, dx
  mov   dl, es:[di+640]
  add   ax, dx
  mov   dl, es:[di+321]
  add   ax, dx
  shr   ax, 2           { ax = average color }
  jz    @skip
  dec   al              { if col > 0 => dec col }
 @skip:
  stosb                 { store new col }
  inc   bx              { next x }
  cmp   bx, 320
  jne   @xloop
  inc   cx              { next y }
  cmp   cx, 199
  jne   @yloop
end;

procedure mainloop;
var loop1:integer;
begin
  cls(vaddr);
  repeat
    waitretrace;
    flip(vaddr,VGA);
    if border then setborder(5);

    for loop1:=1 to maxpoints do begin
      x:=points[loop1,1]; y:=points[loop1,2]; z:=points[loop1,3];
      rotate(x,y,z,phix,phiy,phiz,newx,newy,newz);
      conv3dto2d(newx,newy,newz,xp[loop1],yp[loop1]);
      zp[loop1]:=newz;
    end;

    phix:=(phix+xst) and (maxdegrees-1);
    phiy:=(phiy+yst) and (maxdegrees-1);
    phiz:=(phiz+zst) and (maxdegrees-1);

    for loop1:=1 to maxpolygons do begin
      polyz[loop1]:=(zp[polygons[loop1,1]]+zp[polygons[loop1,2]]+zp[polygons[loop1,3]]+zp[polygons[loop1,4]]) div 4;
      pind[loop1]:=loop1;
    end;

    quicksort(maxpolygons);

    for loop1:=maxpolygons-maxvisible to maxpolygons do
      draw_quad(xp[polygons[pind[loop1],1]],yp[polygons[pind[loop1],1]],
                xp[polygons[pind[loop1],2]],yp[polygons[pind[loop1],2]],
                xp[polygons[pind[loop1],3]],yp[polygons[pind[loop1],3]],
                xp[polygons[pind[loop1],4]],yp[polygons[pind[loop1],4]],polyz[loop1]+200);

    firefadeout;

    if border then setborder(0);
  until keypressed;
end;

var i:integer;
begin
  setmcga;
  setupvirtual;
  for i:=0 to 63 do pal(i,0,0,0);
  for i:=0 to 63 do pal(64+i,0,0,i shr 1);
  for i:=0 to 63 do pal(128+i,i,i shr 1,31-i shr 1);
  for i:=0 to 63 do pal(192+i,63,32+i shr 1,0);
  mainloop;
  shutdownvirtual;
  settext;
end.
