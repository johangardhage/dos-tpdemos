{
  Retro programming in Borland Turbo Pascal

  Morphing dot objects with z light source demo.

  Author: Johan Gardhage <johan.gardhage@gmail.com>
}

program demonstration;

uses crt,gfx,vector;

const border:boolean=false;
      rxst=2; ryst=2; rzst=2;
      maxpoints=9*9*9;
      dotmincol=-245;
      dotmaxcol=423;

type xyztype = record x,y,z:integer; end;

var RealObj: array[1..MaxPoints] of xyztype;
    TempObj: array[1..MaxPoints] of xyztype;
    MorphData: array[1..MaxPoints] of xyztype;
    dotxp,dotyp,dotzp:integer;
    dotcolor,dotcoloradd:real;
    dotcolortable:array[dotmincol..dotmaxcol] of integer;

procedure initialize;
var loop1:integer;
begin
  dotcolor:=0;
  dotcoloradd:=(64/(dotmaxcol-dotmincol));
  for loop1:=dotmincol to dotmaxcol do begin
    dotcolortable[loop1]:=round(dotcolor);
    dotcolor:=dotcolor+dotcoloradd;
  end;
end;

Procedure CreateBox(var objectptr:array of xyztype);
Var a1,a2,a3,loop,loopx,loopy,loopz: Integer;
Begin
  a1:=-40;
  a2:=-40;
  a3:=-40;
  loop:=0;
  For Loopz := 0 to 8 do
    for loopy:=0 to 8 do
      for loopx:=0 to 8 do begin
        objectptr[loop].x := (a1+10*loopx) shl 6;
        objectptr[loop].y := (a2+10*loopy) shl 6;
        objectptr[loop].z := (a3+10*loopz) shl 6;
        inc(loop);
      End;
End;

Procedure Createtri(var objectptr:array of xyztype);
Var a1,a2,a3,loop,multi,antal,loopz,loopx: Integer;
Begin
  loop:=0;
  antal:=1;
  a1:=-10;
  a2:=-90;
  a3:=-10;
  repeat
    for loopz:=1 to antal do
      for loopx:=1 to antal do begin
        objectptr[loop].x := (a1+10*loopx) shl 6;
        objectptr[loop].y := (a2+10*antal) shl 6;
        objectptr[loop].z := (a3+10*loopz) shl 6;
        inc(loop);
      end;
    inc(antal);
    a1:=a1-5;
    a3:=a3-5;
  until antal=13;
  repeat
    objectptr[loop].x := 0;
    objectptr[loop].y := 0;
    objectptr[loop].z := 0;
    inc(loop);
  until loop=maxpoints;
End;

procedure doallpoints;
var loop1:integer;
begin
    for loop1:=1 to maxpoints do begin
      x:=(realobj[loop1].x) div 64; y:=(realobj[loop1].y) div 64; z:=(realobj[loop1].z) div 64;
      rrotate(x,y,z,rphix,rphiy,rphiz,rnewx,rnewy,rnewz);
      rconv3dto2d(rnewx,rnewy,rnewz,dotxp,dotyp);
      dotzp:=round(rnewz);

      putpixel(dotxp,dotyp,dotcolortable[dotzp],vaddr);
    end;

    rphix:=rphix+rxst; if rphix<0 then rphix:=rphix+359 else if rphix>359 then rphix:=rphix-359;
    rphiy:=rphiy+ryst; if rphiy<0 then rphiy:=rphiy+359 else if rphiy>359 then rphiy:=rphiy-359;
    rphiz:=rphiz+rzst; if rphiz<0 then rphiz:=rphiz+359 else if rphiz>359 then rphiz:=rphiz-359;
end;

Procedure RealMorph;
Var Loop1, Loop2: Integer;
Begin
  For Loop1 := 1 to MaxPoints Do
  Begin
    MorphData[Loop1].x := (RealObj[Loop1].x - TempObj[Loop1].x) div 64;
    MorphData[Loop1].y := (RealObj[Loop1].y - TempObj[Loop1].y) div 64;
    MorphData[Loop1].z := (RealObj[Loop1].z - TempObj[Loop1].z) div 64;
  End;
  For Loop1 := 1 to 64 Do
  Begin
    For Loop2 := 1 to MaxPoints Do
    Begin
      Dec(RealObj[Loop2].x,MorphData[Loop2].x);
      Dec(RealObj[Loop2].y,MorphData[Loop2].y);
      Dec(RealObj[Loop2].z,MorphData[Loop2].z);
    End;
    if keypressed then exit;
    swapdisplay;
    DoAllPoints;
  End;
End;

procedure mainloop;
var loop1:integer;
begin
  cls(vaddr);
  Createbox(realobj);
  repeat
    if border then setborder(50);

    for loop1:=1 to 300 do begin
      if keypressed then exit;
      swapdisplay;
      DoAllPoints;
    end;
    Createtri(tempobj);
    realmorph;
    for loop1:=1 to 300 do begin
      if keypressed then exit;
      swapdisplay;
      DoAllPoints;
    end;
    Createbox(tempobj);
    realmorph;

    if border then setborder(0);
  until keypressed;
end;

begin
  initialize;
  setmcga;
  setupvirtual;
  mainloop;
  shutdownvirtual;
  settext;
end.
