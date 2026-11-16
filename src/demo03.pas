{
  Retro programming in Borland Turbo Pascal

  Dot ball with z light source demo.

  Author: Johan Gardhage <johan.gardhage@gmail.com>
}

program demonstration;

uses gfx,vector;

const border:boolean=false;
      rxst=2; ryst=2; rzst=2;
      radius=90;
      dotmaxpoints=2020;
      dotmincol=20;
      dotmaxcol=91;

var
  dotpoints:array[1..dotmaxpoints,1..3] of integer;
  nofpoints:word;
  dotxp,dotyp,dotzp:integer;
  dotcolor,dotcoloradd:real;
  dotcolortable:array[dotmincol..dotmaxcol+dotmincol] of integer;

procedure setpalette;
var loop1:integer;
begin
  for loop1:=1 to 64 do pal(loop1,loop1-1,loop1-1,loop1-1);

  dotcolor:=0;
  dotcoloradd:=(64/(dotmaxcol-dotmincol));
  for loop1:=dotmincol to (dotmaxcol+dotmincol) do begin
    dotcolortable[loop1]:=round(dotcolor);
    dotcolor:=dotcolor+dotcoloradd;
  end;
end;

procedure dotinitialize;
const
  step=0.1;
var
  alpha,beta:real;
  i:word;
  r,x,y,z:integer;
begin
  i:=1;
  alpha:=2*pi;
  while alpha>0 do begin
    beta:=pi;
    while beta>0 do begin
      { sphere }
      x:=round(radius*cos(alpha)*sin(beta));
      y:=round(radius*cos(beta));
      z:=round(radius*sin(alpha)*sin(beta));
      dotpoints[i,1]:=x; dotpoints[i,2]:=y; dotpoints[i,3]:=z;
      beta:=beta-step;
      inc(i);
      if i>dotmaxpoints then begin
        writeln('too many points, change step...');
        halt;
      end;
    end;
    alpha:=alpha-step;
  end;
  nofpoints:=pred(i);
end;

procedure mainloop;
var loop1:integer;
begin
  cls(vaddr);
  repeat
    swapdisplay;
    if border then setborder(5);

    for loop1:=1 to nofpoints do begin
      x:=dotpoints[loop1,1]; y:=dotpoints[loop1,2]; z:=dotpoints[loop1,3];
      rrotate(x,y,z,rphix,rphiy,rphiz,rnewx,rnewy,rnewz);
      rconv3dto2d(rnewx,rnewy,rnewz,dotxp,dotyp);
      dotzp:=round(rnewz);

      if (dotxp>=0) and (dotxp<=319) and (dotyp>=0) and (dotyp<=199) and
         (dotzp<dotmaxcol) and (dotzp>dotmincol) then
        putpixel(dotxp,dotyp,dotcolortable[dotzp],vaddr);
    end;

    rphix:=rphix+rxst; if rphix<0 then rphix:=rphix+360 else if rphix>=360 then rphix:=rphix-360;
    rphiy:=rphiy+ryst; if rphiy<0 then rphiy:=rphiy+360 else if rphiy>=360 then rphiy:=rphiy-360;
    rphiz:=rphiz+rzst; if rphiz<0 then rphiz:=rphiz+360 else if rphiz>=360 then rphiz:=rphiz-360;

    if border then setborder(0);
  until keyhit;
end;

begin
  dotinitialize;
  setmcga;
  setupvirtual;
  setpalette;
  mainloop;
  shutdownvirtual;
  settext;
end.
