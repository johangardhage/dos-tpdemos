{
  Retro programming in Borland Turbo Pascal

  Rotating starfield with z light source demo.

  Author: Johan Gardhage <johan.gardhage@gmail.com>
}

program demonstration;

uses crt,gfx,vector;

const border:boolean=false;
      NofPoints=300;
      Speed=1;
      xst=1; yst=1; zst=1;
      dotmincol=-125;
      dotmaxcol=125;

var Points:array[1..NofPoints] of record X,Y,Z : integer; end;
    Xp,Yp,zp : array[1..NofPoints] of integer;
    dotcolor,dotcoloradd:real;
    dotcolortable:array[dotmincol..dotmaxcol] of integer;

procedure Init;
var loop1:integer;
begin
  randomize;
  for loop1 := 1 to NofPoints do begin
    Points[loop1].X := random(250)-125;
    Points[loop1].Y := random(250)-125;
    points[loop1].z := random(250)-125;
  end;

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
    if border then setborder(50);

    for loop1 := 1 to NofPoints do begin
      inc(Points[loop1].Z,Speed);
      if Points[loop1].Z > (dotmaxcol-speed) then Points[loop1].Z := dotmincol;

      x:=points[loop1].x; y:=points[loop1].y; z:=points[loop1].z;
      rotate(x,y,z,phix,phiy,phiz,newx,newy,newz);
      conv3dto2d(newx,newy,newz,xp[loop1],yp[loop1]);
      zp[loop1]:=newz;

      if (xp[loop1]>=0) and (xp[loop1]<=319) and (yp[loop1]>=0) and (yp[loop1]<=199)
      and (zp[loop1]>dotmincol) and (zp[loop1]<dotmaxcol) then
        putpixel(xp[loop1],yp[loop1],dotcolortable[zp[loop1]],vaddr);
    end;

    phix:=(phix+xst) and (maxdegrees-1);
    phiy:=(phiy+yst) and (maxdegrees-1);
    phiz:=(phiz+zst) and (maxdegrees-1);

    if border then setborder(0);
  until keypressed;
end;

var loop1:integer;
begin
  Init;
  setmcga;
  setupvirtual;
  for loop1:=1 to 64 do pal(loop1,loop1,loop1,loop1);
  mainloop;
  shutdownvirtual;
  settext;
end.
