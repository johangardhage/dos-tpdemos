{
  Retro programming in Borland Turbo Pascal

  Vector balls demo.

  Author: Johan Gardhage <johan.gardhage@gmail.com>
}

program demonstration;

uses crt,gfx,vector;

const border:boolean=false;
      xst=1; yst=1; zst=1;

{$I cube.vec}

    SprPic : array[0..15,0..15] of byte = (
    (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0),
    (0,0,0,0,1,2,2,2,2,2,2,1,0,0,0,0),
    (0,0,0,1,2,3,3,3,3,3,3,2,1,0,0,0),
    (0,0,1,2,3,4,4,4,4,4,4,3,2,1,0,0),
    (0,1,2,3,4,5,5,5,5,5,5,4,3,2,1,0),
    (0,2,3,4,5,6,6,6,6,6,6,5,4,3,2,0),
    (1,2,3,4,5,6,7,7,7,7,6,5,4,3,2,1),
    (1,2,3,4,5,6,7,8,9,7,6,5,4,3,2,1),
    (1,2,3,4,5,6,7,9,8,7,6,5,4,3,2,1),
    (1,2,3,4,5,6,7,7,7,7,6,5,4,3,2,1),
    (0,2,3,4,5,6,6,6,6,6,6,5,4,3,2,0),
    (0,1,2,3,4,5,5,5,5,5,5,4,3,2,1,0),
    (0,0,1,2,3,4,4,4,4,4,4,3,2,1,0,0),
    (0,0,0,1,2,3,3,3,3,3,3,2,1,0,0,0),
    (0,0,0,0,1,2,2,2,2,2,2,1,0,0,0,0),
    (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0));

var pointind:array[1..maxpoints] of integer;

procedure DrawSprite(X,Y : integer; dim : byte; Sprite : pointer;where:word); assembler;
asm
  push  ds
  lds   si, [Sprite]

  mov   es, [where]
  mov   bx, [y]
  add   bx, bx
  mov   di, word ptr [screen_offset + bx]
  add   di, [x]

  xor   ah, ah
  mov   cx, 320
  mov   al, [dim]
  sub   cx, ax

  mov   bh, [dim]
@yloop:

  mov   bl, [dim]
@xloop:
  mov   al, [ds:si]
  test  al, al
  jz    @zero
  mov   [es:di], al
@zero:
  inc   si
  inc   di

  dec   bl
  jnz   @xloop
  add   di, cx
  dec   bh
  jnz   @yloop

  pop   ds
end;

procedure quicksort(hi:integer);
procedure sort(l,r:integer);
var i,j,x,y:integer;
begin
  i:=l; j:=r; x:=zp[(l+r) div 2];
  repeat
    while zp[i]<x do inc(i);
    while x<zp[j] do dec(j);
    if i<=j then begin
      y:=zp[i]; zp[i]:=zp[j]; zp[j]:=y;
      y:=pointind[i]; pointind[i]:=pointind[j]; pointind[j]:=y;
      inc(i); dec(j);
    end;
  until i>j;
  if l<j then sort(l,j);
  if i<r then sort(i,r);
end;

begin
  sort(1,hi);
end;

procedure mainloop;
var loop1:integer;
begin
  cls(vaddr);
  repeat
    swapdisplay;
    if border then setborder(50);

    for loop1:=1 to maxpoints do begin
      x:=points[loop1,1]; y:=points[loop1,2]; z:=points[loop1,3];
      rotate(x,y,z,phix,phiy,phiz,newx,newy,newz);
      conv3dto2d(newx,newy,newz,xp[loop1],yp[loop1]);
      dec(yp[loop1],8); { compensate for bitmap }
      zp[loop1]:=newz;
    end;

    phix:=(phix+xst) and (maxdegrees-1);
    phiy:=(phiy+yst) and (maxdegrees-1);
    phiz:=(phiz+zst) and (maxdegrees-1);

    for loop1:=1 to maxpoints do
      pointind[loop1]:=loop1;

    quicksort(maxpoints);

    for loop1:=1 to maxpoints do
      drawsprite(xp[pointind[loop1]],yp[pointind[loop1]],16,addr(SprPic),vaddr);

    if border then setborder(0);
  until keypressed;
end;

var loop1:integer;
begin
  setmcga;
  setupvirtual;
  for loop1:=1 to 10 do pal(loop1,loop1+10,loop1+10 shr 2,loop1+10);
  mainloop;
  shutdownvirtual;
  settext;
end.
