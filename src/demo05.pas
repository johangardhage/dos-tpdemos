{
  Retro programming in Borland Turbo Pascal

  Starfield with z light source demo.

  Author: Johan Gardhage <johan.gardhage@gmail.com>
}

program demonstration;

uses crt,gfx,vector;

const border:boolean=false;
      speed=3;
      maxstars=1000;
      dotmincol=-200;
      dotmaxcol=250-speed;

var points:array[1..maxstars] of record x,y,z:integer; end;
    xp,yp:array[1..maxstars] of integer;
    dotcolor,dotcoloradd:real;
    dotcolortable:array[dotmincol..dotmaxcol] of integer;

procedure init;
var loop1:integer;
begin
  randomize;
  for loop1:=1 to maxstars do
    repeat
      points[loop1].x:=random(320)-160;
      points[loop1].y:=random(200)-100;
      points[loop1].z:=random(450)-200;
    until (points[loop1].x<>0) and (points[loop1].y<>0);

  dotcolor:=0;
  dotcoloradd:=(64/(dotmaxcol-dotmincol));
  for loop1:=dotmincol to dotmaxcol do begin
    dotcolortable[loop1]:=round(dotcolor);
    dotcolor:=dotcolor+dotcoloradd;
  end;
end;

procedure mainloop;
var loop1:integer;
begin
  cls(vaddr);
  repeat
    swapdisplay;
    for loop1:=1 to maxstars do begin
      if points[loop1].z<(250-speed) then inc(points[loop1].z,speed) else begin
        points[loop1].z:=-200;
        repeat
          points[loop1].x:=random(320)-160;
          points[loop1].y:=random(200)-100;
        until (points[loop1].x<>0) and (points[loop1].y<>0);
      end;
      conv3dto2d(points[loop1].x,points[loop1].y,points[loop1].z,xp[loop1],yp[loop1]);
      if (xp[loop1]>=0) and (xp[loop1]<=319) and (yp[loop1]>=0) and (yp[loop1]<=199) then
        putpixel(xp[loop1],yp[loop1],dotcolortable[points[loop1].z],vaddr);
    end;
  until keypressed;
end;

var loop1:integer;
begin
  init;
  setmcga;
  setupvirtual;
  for loop1:=1 to 64 do pal(loop1,loop1,loop1,loop1);
  mainloop;
  shutdownvirtual;
  settext;
end.
