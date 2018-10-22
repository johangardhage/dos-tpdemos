{
  Retro programming in Borland Turbo Pascal

  Dot tunnel with z light source demo.

  Author: Johan Gardhage <johan.gardhage@gmail.com>
}

program demonstration;

uses crt,gfx,vector;

const border:boolean=false;
      nofcircles=87;
      zstep=5;
      radius=50;
      astep=5;
      dotmincol=-240;
      dotmaxcol=nofcircles*zstep;

var circle:array[1..256 div astep] of record x,y:word; end;
    zpos:array[1..nofcircles] of integer;
    dotcolor,dotcoloradd:real;
    dotcolortable:array[dotmincol..dotmaxcol] of integer;

procedure initialize;
var loop1:integer;
begin
  for loop1:=1 to 256 div astep do begin
    circle[loop1].x:=radius*cosinus[loop1*astep] div (divd-20);
    circle[loop1].y:=radius*sinus[loop1*astep] div divd;
  end;
  z:=dotmincol;
  for loop1:=1 to nofcircles do begin
    zpos[loop1]:=z;
    inc(z,zstep);
  end;

  dotcolor:=0;
  dotcoloradd:=(64/dotmaxcol);
  for loop1:=dotmincol to dotmaxcol do begin
    dotcolortable[loop1]:=round(dotcolor);
    dotcolor:=dotcolor+dotcoloradd;
  end;
end;

procedure sort(l,r:integer);
var i,j,x,y:integer;
begin
  i:=l; j:=r; x:=zpos[(l+r) div 2];
  repeat
    while zpos[i]<x do inc(i);
    while x<zpos[j] do dec(j);
    if i<=j then begin
      y:=zpos[i]; zpos[i]:=zpos[j]; zpos[j]:=y;
      inc(i); dec(j);
    end;
  until i>j;
  if l<j then sort(l,j);
  if i<r then sort(i,r);
end;

procedure mainloop;
var si,i,j,angle:word;
    xo,yo,xp,yp:integer;
begin
  si:=0;
  cls(vaddr);
  repeat
    swapdisplay;
    if border then setborder(50);

    sort(1,nofcircles);

    for j:=1 to nofcircles do begin
      angle:=1; i:=1;

      xo:=cosinus[(2*si+3*j) mod 256] div 4+sinus[(si+2*j) mod 256] div 3;
      yo:=cosinus[(2*si+2*j) mod 256] div 5+sinus[(2*si+3*j) mod 256] div 4;

      while angle<256 do begin
        conv3dto2d(circle[i].x,circle[i].y,zpos[j],xp,yp);
        inc(xp,xo); inc(yp,yo);
        if (xp>0) and (xp<320) and (yp>0) and (yp<200) then
          putpixel(xp,yp,dotcolortable[zpos[j]],vaddr);
        inc(angle,astep); inc(i);
      end;
      inc(zpos[j]);
      if zpos[j]>=(dotmincol+nofcircles*zstep) then zpos[j]:=dotmincol;
    end;
    inc(si,-1);

    if border then setborder(0);
  until keypressed;
end;

var loop1:integer;
begin
  initialize;
  setmcga;
  setupvirtual;
  for loop1:=1 to 64 do pal(loop1,loop1,loop1,loop1);
  mainloop;
  shutdownvirtual;
  settext;
end.
